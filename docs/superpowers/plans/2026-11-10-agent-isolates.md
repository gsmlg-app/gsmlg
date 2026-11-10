# Agents in Isolates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `app_lib/chat` into `app_lib/agent`, run each agent and the DuckDB log store in their own isolates, add GPTs-style agents with per-agent settings, and close the remaining agent logging gaps.

**Architecture:** One `IsolateHub` in the main isolate supervises a `logstore` worker (DuckDB) and an `/agents` group with one worker per agent definition. Run events and acks cross isolates as plain maps over SendPorts; workers reach main-isolate services (vault, tool data, local LLM) through a request/reply services port. Persistence and the local model stay on the main isolate.

**Tech Stack:** Flutter/Dart workspace (melos), `isolate_orchestrator` (in-repo), `dart_agent_core`, Drift, DuckDB via flutter_rust_bridge, BLoC, go_router.

**Spec:** `docs/superpowers/specs/2026-11-10-agent-isolates-design.md`

## Global Constraints

- Agent-loop behaviour unchanged: acknowledged persistence before continuing, per-run cancellation, stale-event dropping, local FIFO lease on main isolate.
- Only plain maps/lists/primitives/`SendPort`/`TransferableTypedData` cross isolates; no `Completer`, exceptions, or class instances.
- Idle agent isolate stops after **10 minutes** without runs; restart type `transient`; group path `/agents`; worker name `agent:<agentDefinitionId>`.
- Log store worker name `logstore`; it is the only isolate that opens DuckDB.
- Logging never throws into producers; app fully works if the hub, log store, or an agent isolate fails (agent runs then fail with a visible error, never hang).
- No credentials in logs, wire messages to the log store, or categories.
- `app_agent`, `chat_bloc` and other non-app packages must not depend on `app_duckdb`.
- Workspace deps use `any`; strings via ARB (en + zh) + `flutter gen-l10n`; DI in `MainProvider`.
- Commit on the current branch; no Claude attribution trailers; never stage `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

## Review Focus

1. **Agent isolate crashes mid-run** → the session shows an error and becomes idle; no hang; next message respawns the isolate (test in Task 8).
2. **Persistence ack rejected/slow on main** → agent does not run the next tool before ack; rejection fails the run (test in Task 8).
3. **User stops a run** → cancel reaches the worker, HTTP aborts, partial assistant message persisted as stopped (test in Task 9).
4. **Log store isolate down** → producers do not throw or block; Log Center shows an error state (test in Task 2).
5. **Legacy data** → existing conversations without `agent_id` and SharedPreferences agents migrate; nothing lost (test in Task 4).

---

## Phase A — Log store isolate

### Task 1: `logstore` worker and client (`app_duckdb`)

**Files:** Create `app_lib/duckdb/lib/src/isolate/log_store_worker.dart`, `log_store_client.dart`, `port_log_sink.dart`; modify `app_lib/duckdb/lib/app_duckdb.dart`, `pubspec.yaml`; test `app_lib/duckdb/test/log_store_isolate_test.dart`.

**Interfaces — Produces:**
- `void logStoreEntryPoint(SendPort hubPort)` (top-level) running `LogStoreWorker extends Worker<Object?>`; config keys `dbPath` (String, `':memory:'` allowed). `onInit` runs `AppDuckDb.initialize()`, opens, `ensureLogSchemas()`, creates a `ReceivePort` ingest port.
- `onCall` ops (request is `{'op': String, ...}`): `ingestPort` → SendPort; `queryLogs`, `countLogs`, `listCategories`, `queryAgentRuns`, `countAgentRuns`, `deleteOlderThan`, `clearLogsTable`, `exportJsonl`, `queryJson`, `flush` — args/returns mirror `AppDuckDb` methods with `LogFilter`/`LogRecordItem` as maps (`LogFilter.toWire/fromWire`; items returned as raw row maps).
- Ingest messages (on the ingest port): `{'k': 'api'|'agent'|'usage', 'r': <record toJson map>}` and `{'k': 'system', 'r': SerializableLogRecord.toMap()}`; buffered via existing `BatchBuffer`/`DuckDbLogSink` mapping.
- `abstract interface class LogStore` with the query API used by the Log Center (`queryLogs`, `countLogs`, `listCategories`, `queryAgentRuns`, `countAgentRuns`, `deleteOlderThan`, `clearLogsTable`, `exportJsonl`, `queryJson`, `flush`); implemented by `AppDuckDb` (direct, tests) and `LogStoreClient(IsolateHub hub, {String target = 'logstore'})`.
- `class PortLogSink implements LogSink { PortLogSink(SendPort ingest); }` (from `app_logging`'s `LogSink`) — `writeApi/Agent/Usage` send `{'k','r'}`; never throws.
- `LogRecord`/model classes need `fromJson` where the worker must rebuild them; add `ApiExchangeRecord.fromJson`, `AgentLogEvent.fromJson`, `UsageEvent.fromJson` in `app_logging` if absent (round-trip tests).

- [ ] **Step 1: Failing tests** with a real `IsolateHub` + `logstore` worker on `:memory:`: write via `PortLogSink` then `flush` op then `countLogs('api_exchanges') == 1`; `queryLogs` returns the row; `deleteOlderThan` works through the client; unknown op → `TaskException`.
- [ ] **Step 2–4:** fail → implement → pass (`cargo build` first; the worker isolate loads the dylib via the existing fallback loader).
- [ ] **Step 5: Commit** `feat(duckdb): run log store in its own isolate`

### Task 2: App wiring for the log store isolate

**Files:** Modify `lib/main.dart`, `lib/app.dart`, `app_lib/provider/lib/src/main.dart` (+pubspec), `lib/screens/settings/log_center_screen.dart`, `app_widget/adaptive/lib/src/log/*` (take `LogStore` instead of `AppDuckDb`); test `test/core/log_store_wiring_test.dart`.

**Interfaces:** `main.dart` creates and starts one `IsolateHub` (`AppIsolates.hub`), registers `ChildSpec(name: 'logstore', entryPoint: logStoreEntryPoint, config: {'dbPath': <support dir>/gsmlg_logs.duckdb}, restartType: permanent)`, then attaches `LogCapture.instance.attach(PortLogSink(ingest))` and forwards `Logger.root.onRecord` as `system` messages. On any failure: no sink, warning logged, app continues. `MainProvider` provides `IsolateHub` and `LogStore` (= `LogStoreClient`). Exit/background flush calls `LogStore.flush()`. The in-process `DuckDbLogSink`/`DuckDbLogOutput` are no longer used by the app (keep for tests only if still referenced).

- [ ] **Step 1: Failing tests:** Log Center screen works against a fake `LogStore`; with a `LogStore` whose calls throw, the screen shows its error state and does not crash; `PortLogSink` to a closed port does not throw.
- [ ] **Step 2–4:** fail → implement → pass; `flutter build macos --debug`; run the app ~15 s, quit, confirm rows exist (temporary inspection test, then delete it).
- [ ] **Step 5: Commit** `feat(app): route all logging through the log store isolate`

## Phase B — Package refactor

### Task 3: `app_lib/chat` → `app_lib/agent` (`app_agent`)

**Files:** `git mv app_lib/chat app_lib/agent`; rename package to `app_agent`, barrel `lib/app_agent.dart` (keep `lib/chat_models.dart` renamed `lib/agent_models.dart`); update root `pubspec.yaml` workspace + deps, every importer (see list: `app_bloc/chat`, `app_lib/provider`, `lib/screens/chat/**`, `lib/screens/settings/**`, `lib/duo/**`, `integration_test/**`, `test/**`); update `docs/chat-agent-runtime.md` paths.

- [ ] **Step 1:** Move + rename; no code changes beyond imports/package names.
- [ ] **Step 2: Verify:** `flutter pub get`; `flutter analyze --fatal-warnings` on all touched packages; `flutter test` in `app_lib/agent`, `app_bloc/chat`, root `test/screens/chat test/screens/settings test/duo` → same pass/fail set as before the move (known pre-existing failures: `chat_ttft_test` 3, `home_screen_test` 9, `session_menu_test` 2).
- [ ] **Step 3: Commit** `refactor(agent): move app_chat to app_lib/agent (app_agent)`

## Phase C — Agent definitions and sessions

### Task 4: Persisted agent definitions + conversation ownership

**Files:** Create `app_lib/database/lib/src/tables/agent_definition.dart`; modify `app_lib/database/lib/src/database.dart` (schema **21**, migration), `tables/chat_conversation.dart` (`agentId` nullable text); create `app_lib/agent/lib/src/models/agent_definition.dart`, `repositories/agent_repository.dart`; modify `ChatStorageRepository`, `Conversation` (+`agentId`); tests `app_lib/database/test/agent_definition_migration_test.dart`, `app_lib/agent/test/agent_repository_test.dart`.

**Interfaces — Produces:**
- `class AgentDefinition { String id, name; String? avatar /*emoji*/, description, instructions; ModelConfig config; bool thinkingEnabled; List<String>? allowedTools; DateTime createdAt, updatedAt; Map<String,Object?> toWire(); factory fromWire(...) }` (Equatable).
- `class AgentRepository { AgentRepository(AppDatabase db); Future<List<AgentDefinition>> list(); Future<AgentDefinition?> get(String id); Future<void> save(AgentDefinition); Future<void> delete(String id); Future<void> importLegacy(SharedPreferences prefs) }` — `importLegacy` reads `chat_agents` JSON (format in `app_bloc/chat/lib/src/settings/bloc.dart` `_agentFromJson`/`_configToJson`) once, guarded by pref flag `agents_migrated_v1`, preserving ids.
- `Conversation.agentId` persisted; `ChatStorageRepository.loadConversations({String? agentId})` filter.

- [ ] **Step 1: Failing tests:** v20→v21 migration keeps existing conversations (agent_id null) and creates the table; `importLegacy` imports 2 legacy agents with ids/config intact and is idempotent; CRUD round-trip incl. `allowedTools`.
- [ ] **Step 2–4:** fail → `dart run build_runner build --delete-conflicting-outputs` in app_lib/database → implement → pass.
- [ ] **Step 5: Commit** `feat(agent): persist agent definitions and session ownership`

### Task 5: Settings and chat blocs use agent definitions

**Files:** Modify `app_bloc/chat/lib/src/settings/*` (agents from `AgentRepository`; `ChatAgent` replaced by `AgentDefinition`; events gain avatar/description/allowedTools), `app_bloc/chat/lib/src/chat/*` (new conversation stores `agentId`; load restores agent; `runStream` receives `allowedTools` and the agent's instructions), `app_lib/provider` wiring, `lib/screens/chat/**` compile fixes; tests in `app_bloc/chat/test/`.

- [ ] **Step 1: Failing tests:** saving an agent persists via repository; a new session with agent X stores `agentId` X and reloading the conversation restores X and its config; `allowedTools` reaches `runStream`.
- [ ] **Step 2–4:** fail → implement → pass (plus existing chat_bloc tests except known `chat_ttft_test`).
- [ ] **Step 5: Commit** `feat(chat): sessions belong to persisted agents`

## Phase D — Agents in isolates

### Task 6: Wire protocol and codecs

**Files:** Create `app_lib/agent/lib/src/isolate/wire.dart` (+ codecs next to models); tests `app_lib/agent/test/wire_test.dart`.

**Interfaces — Produces:** `toWire()/fromWire()` for `Message` subtypes, `Conversation`, `ModelConfig`, `AgentDefinition`, `AgentMessageMetadata`, `ToolInvocationReceipt`, `LogContext`; `Map<String,Object?> agentEventToWire(ChatAgentEvent e, {String? ackId})` and `ChatAgentEvent agentEventFromWire(Map m, {Completer<void>? acknowledgement})`; messages `StartRun{runId, sessionId, generationId, history, userPrompt, modelConfig, apiKey?, allowedTools, maxTurns, mcpProfiles, eventsPort}`, `RunAck{runId, ackId, ok, error?}`, `CancelRun{runId}`.

- [ ] **Step 1: Failing tests:** every event type and message subtype round-trips (`fromWire(toWire(x)) == x` for value types); the encoded map passes a `SendPort.send` to a test isolate without error.
- [ ] **Step 2–4:** fail → implement → pass. **Step 5: Commit** `feat(agent): isolate wire protocol`

### Task 7: Services bridge (main ↔ agent isolate)

**Files:** Create `app_lib/agent/lib/src/isolate/services_server.dart`, `services_client.dart`; introduce narrow interfaces `SecretReader`, `ToolDataSource`, `LocalLlmGateway` in `app_lib/agent/lib/src/services/`; refactor `ToolExecutor`, `RemoteLlmRepository`, `RepositoryAgentLlmClient`, `BackplaneServiceRepository` to depend on them (main-isolate implementations wrap `VaultRepository`/`AppDatabase`/`GemmaRepository`); tests `app_lib/agent/test/services_bridge_test.dart`.

**Interfaces:** `AgentServicesServer({required SecretReader secrets, required ToolDataSource data, required LocalLlmGateway localLlm})` exposes `SendPort get port`; request `{id, op, args}` → reply `{id, ok, value|error}`; stream ops (`localLlm.generate`) reply with `{id, chunk}`* then `{id, done}` / `{id, error}`, and accept `{id, op: 'cancel'}`. `AgentServicesClient(SendPort serverPort)` implements the three interfaces in the worker. `ToolDataSource` ops are exactly the DB reads/writes `ToolExecutor`/`BackplaneServiceRepository` perform today (enumerate from their `_database` call sites).

- [ ] **Step 1: Failing tests:** through a real isolate: `secrets.read` returns the value; a `ToolDataSource` op round-trips; `localLlm.generate` streams chunks and honours cancel; server error → client exception with message; existing `ToolExecutor`/remote LLM tests still pass with main-isolate implementations.
- [ ] **Step 2–4:** fail → implement → pass. **Step 5: Commit** `feat(agent): services bridge for agent isolates`

### Task 8: Agent worker and host

**Files:** Create `app_lib/agent/lib/src/isolate/agent_worker.dart` (`void agentEntryPoint(SendPort)`), `agent_host.dart`; `abstract interface class AgentRunner { Stream<ChatAgentEvent> runStream({...same params as ChatAgentRuntime.runStream + String agentId, List<String>? allowedTools}); Future<void> stop(String runId); }` implemented by `ChatAgentRuntime` (in-process adapter) and `AgentHost`; tests `app_lib/agent/test/agent_host_test.dart`.

**Interfaces:** `AgentHost({required IsolateHub hub, required AgentServicesServer services, required SendPort? logIngest, required Future<AgentDefinition?> Function(String id) loadDefinition, Duration idleTimeout = const Duration(minutes: 10)})`. Worker config: `{definition, servicesPort, logIngest, loggerPort}`; worker builds `ChatAgentRuntime` with `AgentServicesClient`, `LoggingHttpClient`, `LogCapture.attach(PortLogSink(logIngest))`. Host: spawns on demand (`/agents` group, `transient`), forwards events to the returned stream, converts ack-bearing events back into Completers whose completion sends `RunAck` via `hub.cast`; `stop(runId)` casts `CancelRun`; isolate failure/stop during a run → emit `AgentRunFailedEvent` and close; idle timer stops the worker.

- [ ] **Step 1: Failing tests** (real isolates, fake LLM via loopback HTTP server): a run streams events in order and waits for each ack before the next tool; a rejected ack fails the run; killing the worker mid-run yields `AgentRunFailedEvent` within 5 s and the next run respawns; idle timeout (shortened in test) stops the worker; `stop(runId)` ends the run as cancelled.
- [ ] **Step 2–4:** fail → implement → pass. **Step 5: Commit** `feat(agent): run each agent in its own isolate`

### Task 9: ChatBloc runs agents through `AgentHost`

**Files:** Modify `app_bloc/chat/lib/src/chat/bloc.dart` (depend on `AgentRunner`; local-model lease unchanged on main), `app_lib/provider/lib/src/main.dart` (construct `AgentServicesServer` + `AgentHost`; pass the hub), `lib/main.dart`; tests `app_bloc/chat/test/chat_agent_host_test.dart`.

- [ ] **Step 1: Failing tests:** with a fake `AgentRunner`, existing session/stop/persistence tests pass; stop sends `stop(runId)` and persists the partial assistant as stopped; host failure surfaces as session error.
- [ ] **Step 2–4:** fail → implement → pass; `flutter build macos --debug`; run app, open an agent session, confirm an `agent:` isolate starts (log line) — real LLM chat unverified without an account.
- [ ] **Step 5: Commit** `feat(chat): sessions run on per-agent isolates`

## Phase E — Agents UI

### Task 10: GPTs-style agents home, editor, sessions

**Files:** Create `lib/screens/agents/agents_screen.dart` (grid/list: avatar, name, description, "New agent"), `agent_editor_screen.dart` (name, avatar emoji, description, instructions, model, thinking, allowed tools from `ToolExecutor` definitions), `agent_sessions_screen.dart` (sessions of one agent + new session); routes under the existing chat route tree; reuse `ChatScreen` for the conversation with the agent preselected; replace `_AgentSelector` entry points to open the agents home; ARB en+zh; tests `test/screens/agents/*`.

- [ ] **Step 1: Failing tests:** agents home lists agents from the bloc and opens the editor; editor saves avatar/description/allowedTools; sessions screen lists only that agent's conversations and starts a new one with the agent set.
- [ ] **Step 2–4:** fail → implement → pass. **Step 5: Commit** `feat(agents): agents home, editor and per-agent sessions`

## Phase F — Logging fixes

### Task 11: Agent logging gaps

**Files:** Modify `app_lib/agent/lib/src/agent/tool_gateway.dart`, `chat_agent_runtime.dart` (pass current turn into the tool zone `LogContext`), `app_lib/logging/lib/src/capture/api_capture_interceptor.dart` (Dio cancel → `aborted: true`, `error: null`), `app_lib/agent/lib/src/agent/sub_agent_supervisor.dart` (`conversationId` on sub-agent records); tests alongside.

- [ ] **Step 1: Failing tests:** tool HTTP record inside turn 2 has `context.turn == 2`; Dio `CancelToken.cancel()` → record `aborted == true`, `error == null`; sub-agent records carry `conversation_id`.
- [ ] **Step 2–4:** fail → implement → pass.
- [ ] **Step 5: Final verification:** `cargo build`; `melos run analyze`; `melos run test` (known pre-existing failures only); `flutter build macos --debug`; app run with log check.
- [ ] **Step 6: Commit** `fix(logging): turn on tool traffic, clean cancels, sub-agent context`
