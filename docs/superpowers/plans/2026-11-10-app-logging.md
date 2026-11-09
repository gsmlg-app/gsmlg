# App Logging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist full LLM/API HTTP exchanges, agent run/tool events, and on-device usage events into the DuckDB log store, and browse/export/delete them from the Log Center.

**Architecture:** `app_logging` gains a backend-agnostic capture layer (`LogCapture` + `LogSink`, record models, an `http.Client` wrapper, a Dio interceptor). `app_duckdb` implements `LogSink` with batched Rust appenders into new tables. Producers (`app_chat`, BLoCs, app screens) depend only on `app_logging`; `main.dart` attaches the DuckDB sink.

**Tech Stack:** Flutter/Dart workspace (melos), Rust `duckdb` 1.20000.1 via flutter_rust_bridge 2.13.0 native assets, `package:http`, `package:dio`, go_router, BLoC.

**Spec:** `docs/superpowers/specs/2026-11-10-app-logging-design.md`

## Global Constraints

- Bodies are **never truncated** except binary bodies over **1 MiB** (`body_truncated: true`, base64 of the first 1 MiB).
- Redacted value is exactly the string `[REDACTED]`; header name is kept; values stored as `List<String>`.
- Fixed redaction list (case-insensitive): `authorization`, `proxy-authorization`, `x-api-key`, `api-key`, `cookie`, `set-cookie`, `x-amz-security-token`, `x-goog-api-key`; query params `key`, `api_key`, `apikey`, `access_token`, `token`.
- All logging is on by default; `LogCapture` exposes `apiEnabled`, `agentEnabled`, `usageEnabled` (default `true`), no UI toggle.
- Logging never throws into producers, never alters requests/streams, and is a no-op when no sink is attached.
- `app_chat`, `app_bloc/*`, `app_api/*` must not depend on `app_duckdb`.
- Workspace deps use `any`; new strings go in `app_lib/locale/lib/arb/app_en.arb` and `app_zh.arb`; DI in `MainProvider`.
- Timestamps: `ts` is ISO-8601 with local offset and microseconds (e.g. `2026-03-12T18:24:24.739327+08:00`); DB rows store `timestamp_us` (UTC epoch µs).
- No commits to anything other than the current branch; commit messages without Claude attribution trailers.

## Review Focus

1. **User stops a streaming generation midway** → a `response` record is still written with the partial raw stream and `"aborted": true` (test in Task 5).
2. **Non-2xx on a streaming request** (repository reads body then throws) → the record holds the complete error body, `status` set (test in Task 5).
3. **Log store failed to open** → chat, API calls and navigation behave exactly as before; nothing throws (test in Task 7).
4. **Body declared `application/json` that does not parse / non-UTF-8 text** → stored as `text` or `base64` without throwing (test in Task 4).
5. **Custom auth header name** (`RemoteAuthType.customHeader`) and user-configured MCP headers → value is `[REDACTED]` in the stored record (tests in Tasks 8 and 10).

---

## Phase A — Storage and platforms

### Task 1: Native build on all shipping platforms

**Files:**
- Modify: `app_lib/duckdb/rust/rust-toolchain.toml`, `app_lib/duckdb/hook/build.dart`, `app_lib/duckdb/lib/src/app_duckdb.dart` (test-library fallback), `.github/workflows/ci.yml` (test job)

- [ ] **Step 1:** In `rust-toolchain.toml` keep `channel = "1.99.1"` and set `targets` to `aarch64-apple-darwin`, `x86_64-apple-darwin`, `aarch64-apple-ios`, `aarch64-apple-ios-sim`, `x86_64-apple-ios`, `aarch64-linux-android`, `armv7-linux-androideabi`, `x86_64-linux-android`, `x86_64-unknown-linux-gnu`, `aarch64-unknown-linux-gnu`, `x86_64-pc-windows-msvc`.
- [ ] **Step 2:** Remove the `extraCargoEnvironmentVariables: {'CARGO_HOME': '/tmp/isolated_cargo_home'}` override from `hook/build.dart` (breaks Windows, re-downloads crates).
- [ ] **Step 3:** Extend the `AppDuckDb.initialize` fallback candidates to `libapp_duckdb_rust.so` and `app_duckdb_rust.dll` in `rust/target/{debug,release}` (both relative to package root and repo root).
- [ ] **Step 4:** In `ci.yml` job `test`, before "Run tests", add a step `cargo build --manifest-path app_lib/duckdb/rust/Cargo.toml` (rustup is preinstalled on `ubuntu-latest`).
- [ ] **Step 5: Verify:** `cd app_lib/duckdb && flutter test` → all pass on macOS; `flutter build macos --debug` → ✓; `flutter build apk --debug` and `flutter build ios --debug --no-codesign` → ✓ (if a toolchain is missing locally, record it as unverified); Linux/Windows are verified by CI on push.
- [ ] **Step 6: Commit** `build(duckdb): build native log store on all release platforms`

### Task 2: New schema and Rust appenders

**Files:**
- Modify: `app_lib/duckdb/rust/src/api/duckdb.rs`; regenerate `app_lib/duckdb/rust/src/frb_generated.rs`, `app_lib/duckdb/lib/src/rust/**`
- Modify: `app_lib/duckdb/lib/app_duckdb.dart`, `lib/src/app_duckdb.dart`, `lib/src/log_router.dart`
- Delete: `app_lib/duckdb/rust/src/api/simple.rs`, `lib/src/rust/api/simple.dart` (template leftovers)
- Test: `app_lib/duckdb/test/app_duckdb_test.dart`, `test/log_router_test.dart`

**Interfaces — Produces (Rust structs exposed to Dart, all string fields `String`/`Option<String>`, ints `i64`/`Option<i32>`):**
- `ApiExchangeEntry { id, timestamp_us: i64, request_id, record_type, category, api_type: Option, method: Option, host: Option, path: Option, status: Option<i32>, duration_ms: Option<i32>, has_error: bool, aborted: bool, conversation_id: Option, run_id: Option, turn: Option<i32>, tool_call_id: Option, record_json: String }`
- `AgentEventEntry { id, timestamp_us, event_type, conversation_id: Option, run_id: Option, parent_run_id: Option, turn: Option<i32>, tool_call_id: Option, tool_name: Option, backend: Option, request_id: Option, level: String, is_error: bool, duration_ms: Option<i32>, summary: String, payload_json: Option }`
- `UsageEventEntry { id, timestamp_us, session_id, event_type, module: Option, screen_name: Option, route_path: Option, target: Option, source_screen: Option, duration_ms: Option<i64>, payload_json: Option }`
- Rust fns: `batch_append_api_exchanges(entries) -> Result<usize,String>`, `batch_append_agent_events(...)`, `batch_append_usage_events(...)`; tables `api_exchanges`, `agent_events`, `usage_events` (columns = struct fields, `id VARCHAR PRIMARY KEY`, indexes on `timestamp_us DESC` and `category` / `run_id` / `session_id` respectively).
- `ensure_log_schemas()` first runs `DROP VIEW IF EXISTS v_all_logs; DROP TABLE IF EXISTS dns_logs; DROP TABLE IF EXISTS dhcp_logs; DROP TABLE IF EXISTS app_logs;` then creates `system_logs` (unchanged), the three new tables, and `v_all_logs` with columns `id, timestamp_us, log_type, category, level, logger_name, message` (`log_type` ∈ `system|api|agent`; api `level` = `SEVERE` when `has_error` or `status >= 400` else `INFO`; api `message` = `method || ' ' || host || path || ' → ' || coalesce(status, 'ERR')`; agent `message` = `summary`). Usage is excluded.
- Removed everywhere: `DuckDbLogEntry`, `DnsLogEntry`, `DhcpLogEntry`, `append_log`, `batch_append_logs`, `batch_append_dns_logs`, `batch_append_dhcp_logs`, `ensure_log_schema`, `query_recent_logs`, `query_dns_logs`, `query_dhcp_logs`, `greet`; `LogRouter` keeps only `routeSerializable`/`routeRoot` → `SystemLogEntry`.
- Dart `AppDuckDb`: `batchAppendApiExchanges(List<ApiExchangeEntry>) → Future<int>`, `batchAppendAgentEvents(...)`, `batchAppendUsageEvents(...)`.

- [ ] **Step 1: Failing tests** in `app_duckdb_test.dart`: `test('ensureLogSchemas drops legacy dns/dhcp/app_logs tables')` (create `dns_logs` via `execute`, call `ensureLogSchemas`, `queryJson("SELECT count(*) AS n FROM information_schema.tables WHERE table_name IN ('dns_logs','dhcp_logs','app_logs')")` → `n == 0`); one append-and-read-back test per new table; `test('v_all_logs projects api error as SEVERE')`. Replace DNS/DHCP router tests with `test('all records route to system logs')`.
- [ ] **Step 2:** Run `cargo build` (in `rust/`) then `flutter test` → new tests fail to compile.
- [ ] **Step 3:** Implement Rust changes; run `flutter_rust_bridge_codegen generate` in `app_lib/duckdb`; update Dart exports and wrappers.
- [ ] **Step 4:** `cargo build && flutter test` in `app_lib/duckdb` → all pass.
- [ ] **Step 5: Commit** `feat(duckdb): add api/agent/usage tables, drop dns/dhcp legacy`

### Task 3: Queries, deletion by age, export

**Files:**
- Modify: `app_lib/duckdb/lib/src/log_query_builder.dart`, `lib/src/models/log_record_item.dart`, `lib/src/app_duckdb.dart`
- Test: `app_lib/duckdb/test/log_query_builder_test.dart`, `test/log_center_query_test.dart`

**Interfaces — Produces:**
- `class LogFilter { String? keyword; DateTimeRange? timeRange; String? level; String? category; String? conversationId; String? runId; String? sessionId; bool? errorsOnly; }` (const constructor, all optional).
- `AppDuckDb.queryLogs({required String tableOrView, LogFilter filter = const LogFilter(), int limit = 50, int offset = 0}) → Future<List<LogRecordItem>>`, `countLogs({required String tableOrView, LogFilter filter})` (replaces the old keyword/timeRange/level parameters; update `DuckDbLogViewer` callers).
- `AppDuckDb.listCategories() → Future<List<String>>` (distinct `category` from `api_exchanges`, sorted).
- `AppDuckDb.deleteOlderThan({required int days, required List<String> tables}) → Future<void>`; table names validated against `LogTables.all = ['system_logs','api_exchanges','agent_events','usage_events']`, throws `ArgumentError` otherwise; `days >= 1`.
- `AppDuckDb.exportJsonl({required String table, LogFilter filter = const LogFilter()}) → Future<String>`: for `api_exchanges` one `record_json` per line ordered by `timestamp_us ASC`; for `agent_events`/`usage_events` one JSON object of the row's columns per line.
- `LogRecordItem.logType` reads `log_type` column; adds `category`; for `api_exchanges` rows message = method + host + path, `status` = HTTP status.
- Keyword on `api_exchanges` searches `path`, `host`, `category`, `record_json`; on `agent_events` searches `summary`, `tool_name`, `payload_json`; on `usage_events` searches `screen_name`, `target`, `module`.

- [ ] **Step 1: Failing tests:** `deleteOlderThan(days: 7)` removes rows older than 7 days and keeps newer ones in every listed table; `deleteOlderThan(tables: ['users'])` throws `ArgumentError`; `exportJsonl(table: 'api_exchanges', filter: LogFilter(category: 'llm:x'))` returns exactly the stored `record_json` lines of that category in time order; `LogFilter(errorsOnly: true)` on `api_exchanges` returns only `has_error OR status >= 400`; category/conversation filters escape `'`.
- [ ] **Step 2:** Run → fail. **Step 3:** Implement. **Step 4:** `flutter test` in `app_duckdb` and `app_widget/adaptive` → pass.
- [ ] **Step 5: Commit** `feat(duckdb): filters, delete-older-than and JSONL export`

## Phase B — Capture layer

### Task 4: Capture core and record models (`app_logging`)

**Files:**
- Create: `app_lib/logging/lib/src/capture/log_capture.dart`, `capture/log_context.dart`, `capture/api_exchange_record.dart`, `capture/http_body.dart`, `capture/redaction.dart`, `capture/agent_log_event.dart`, `capture/usage_event.dart`
- Modify: `app_lib/logging/lib/app_logging.dart` (exports), `app_lib/logging/pubspec.yaml` (add `http: any`, `dio: any`, `uuid: any`, dev `test`)
- Test: `app_lib/logging/test/capture/api_exchange_record_test.dart`, `http_body_test.dart`, `redaction_test.dart`, `log_capture_test.dart`

**Interfaces — Produces:**
- `abstract interface class LogSink { void writeApi(ApiExchangeRecord r); void writeAgent(AgentLogEvent e); void writeUsage(UsageEvent e); }`
- `final class LogCapture { static LogCapture instance; void attach(LogSink? sink); bool apiEnabled = true, agentEnabled = true, usageEnabled = true; void api(ApiExchangeRecord r); void agent(AgentLogEvent e); void usage(UsageEvent e); }` — each method is a no-op without a sink or when disabled, and swallows sink exceptions to `stderr`.
- `class LogContext { final String? conversationId, runId, parentRunId, generationId, toolCallId; final int? turn; Map<String,Object?> toJson(); }`
- `class HttpMessageCapture { method, scheme, host, uri (path+query), proto = 'HTTP/1.1', remoteAddr (null), Map<String,List<String>> headers, Object? body, String bodyEncoding, bool bodyTruncated, String? contentType, int? contentLength }` with `static HttpMessageCapture.request({required String method, required Uri url, required Map<String,List<String>> headers, required List<int> bodyBytes, Set<String> secretHeaders})` and `.response(...)` analog with `status`.
- `HttpBody.encode(List<int> bytes, String? contentType) → ({Object? body, String encoding, bool truncated})`: `json` when content type contains `json` **and** bytes decode+parse; else `text` when content type is `text/*`, `*json*`, `*xml*`, `*event-stream*`, `*x-www-form-urlencoded*` and bytes are valid UTF-8; else `base64` capped at 1 MiB; empty bytes → `body: null, encoding: 'none'`.
- `Redaction.headers(Map<String,List<String>> h, {Set<String> extra = const {}}) → Map<String,List<String>>`; `Redaction.uri(Uri u) → Uri` (Global Constraints list).
- `class ApiExchangeRecord { DateTime ts; String requestId; String recordType ('exchange'|'request'|'response'); int? durationMs; HttpMessageCapture? request; HttpMessageCapture? response (adds status); String category; String? apiType; LogContext? context; ({String type, String message, String? stackTrace})? error; bool aborted; Map<String,Object?> toJson(); String toJsonLine(); }` — JSON keys exactly as spec §4.1/§4.2 (`ts`, `request_id`, `record_type`, `duration_ms`, `request`, `response`, `category`, `context`, `error`, `aborted`; inside messages `method, scheme, host, uri, proto, remote_addr, headers, body, body_encoding, body_truncated, content_type, content_length`, response `status`); null optional fields are omitted.
- `class AgentLogEvent { DateTime ts; String eventType; LogContext context; String? toolName, backend, requestId; String level; bool isError; int? durationMs; String summary; Map<String,Object?>? payload; }`
- `class UsageEvent { DateTime ts; String sessionId; String eventType ('session_start'|'session_end'|'screen_view'|'menu_tap'); String? module, screenName, routePath, target, sourceScreen; int? durationMs; Map<String,Object?>? payload; }`

- [ ] **Step 1: Failing tests:** `toJsonLine` of a streamed `request` record matches the reference key set (no `response`, no `duration_ms`); `Authorization: Bearer x` → `["[REDACTED]"]`, `extra: {'X-My-Key'}` redacts that header case-insensitively; `?api_key=abc` redacted in `uri`; `HttpBody.encode` for invalid JSON with `application/json` → `encoding == 'text'`; invalid UTF-8 `text/plain` → `base64`; 2 MiB binary → `truncated == true` and decoded length `== 1048576`; `LogCapture.api` with a throwing sink does not throw; with no sink does nothing.
- [ ] **Step 2:** `cd app_lib/logging && flutter test test/capture` → fail. **Step 3:** Implement. **Step 4:** → pass.
- [ ] **Step 5: Commit** `feat(logging): capture core and proxy-dump record models`

### Task 5: `LoggingHttpClient` for `package:http`

**Files:**
- Create: `app_lib/logging/lib/src/capture/logging_http_client.dart`
- Test: `app_lib/logging/test/capture/logging_http_client_test.dart`

**Interfaces:**
- Consumes: Task 4 models, `LogCapture.instance`.
- Produces: `class LoggingHttpClient extends http.BaseClient { LoggingHttpClient(http.Client inner, {String defaultCategory = 'http'}); }` and `class HttpCaptureTag { static void tag(http.BaseRequest r, {required String category, String? apiType, LogContext? context, Set<String> secretHeaders = const {}}); }` (an `Expando` keyed by the request).
- Behavior: request body bytes from `http.Request.bodyBytes` (other request types: body `null`). Response `text/event-stream` → write `request` record immediately after the inner `send` returns, then a `response` record when the passthrough stream completes, errors (`error` set) or is cancelled (`aborted: true`), with all bytes received so far. Any other response → one `exchange` record when the body stream completes. Transport exception from `inner.send` → `exchange` record with `error` and no `response`, then rethrow. The response stream handed back must emit the identical bytes/errors in the same order; capture copies bytes, never buffers delivery. `duration_ms` = send start → stream end.

- [ ] **Step 1: Failing tests** using `MockClient.streaming`/a fake `BaseClient` and a recording `LogSink`: non-streaming JSON 200 → one `exchange` with parsed body; SSE 200 consumed fully → `request` then `response` with identical `request_id` and the full raw text; SSE cancelled after first chunk → `response` with `aborted == true` and only the first chunk; SSE 401 body read by caller → record has `status 401` and full error body; inner throws `SocketException` → `exchange` with `error.type == 'SocketException'` and the exception propagates; caller receives byte-identical stream.
- [ ] **Step 2:** fail → **Step 3:** implement → **Step 4:** pass.
- [ ] **Step 5: Commit** `feat(logging): LoggingHttpClient captures full http exchanges`

### Task 6: Dio capture interceptor

**Files:**
- Create: `app_lib/logging/lib/src/capture/api_capture_interceptor.dart`
- Test: `app_lib/logging/test/capture/api_capture_interceptor_test.dart`

**Interfaces — Produces:** `class ApiCaptureInterceptor extends Interceptor { ApiCaptureInterceptor({required String category, Set<String> secretHeaders = const {}, LogContext? Function()? context}); }` plus `RequestOptions.extra['log_category']` / `extra['log_context']` (a `LogContext`) override per request. Writes one `exchange` record per request on response or error. Body encoding: `List<int>` → bytes; `String` → UTF-8 bytes; `Map`/`List` → `jsonEncode` bytes; anything else → `toString()` as text. Must be added **last** so it sees final headers (after `AwsSigV4Interceptor`).

- [ ] **Step 1: Failing tests** with a fake `HttpClientAdapter`: JSON request/response pair recorded with status and duration; `DioException` (404 with body) → record has `status 404`, full body, `error.type == 'DioException'`; header `X-Amz-Security-Token` redacted; per-request `extra['log_category']` overrides constructor category.
- [ ] **Step 2–4:** fail → implement → pass.
- [ ] **Step 5: Commit** `feat(logging): Dio interceptor capturing full api exchanges`

### Task 7: DuckDB sink and app wiring

**Files:**
- Create: `app_lib/duckdb/lib/src/duckdb_log_sink.dart`
- Modify: `app_lib/duckdb/lib/src/duckdb_log_output.dart` (share buffering/flush), `app_lib/duckdb/lib/app_duckdb.dart`, `app_lib/duckdb/pubspec.yaml` (`app_logging: any`), `lib/main.dart`
- Test: `app_lib/duckdb/test/duckdb_log_sink_test.dart`, `test/main_logging_test.dart` (root)

**Interfaces:**
- Consumes: `LogSink`, models (Task 4); `batchAppend*` (Task 2).
- Produces: `class DuckDbLogSink implements LogSink { DuckDbLogSink({required AppDuckDb duckDb, Duration flushInterval = const Duration(milliseconds: 500), int threshold = 50}); Future<void> flush(); Future<void> close(); }` mapping records → entries (`record_json = record.toJsonLine()`, `has_error = error != null`, `timestamp_us = ts.toUtc().microsecondsSinceEpoch`).
- `main.dart` `_attachDuckDbLogging()` also calls `LogCapture.instance.attach(DuckDbLogSink(duckDb: AppDuckDb.instance))`; on open failure no sink is attached. Add `AppLifecycleListener(onExitRequested: …)` in `App` that awaits sink/output `flush()` before allowing exit.

- [ ] **Step 1: Failing tests:** in-memory DB, write 3 api + 2 agent + 2 usage records, `flush()`, rows present with `record_json` round-tripping to the same `toJson()`; a 5 MB JSON request body is stored intact; with `AppDuckDb` closed, `writeApi` + `flush()` does not throw.
- [ ] **Step 2–4:** fail → implement → pass (`cargo build` first).
- [ ] **Step 5: Commit** `feat(duckdb): persist captured api/agent/usage records`

## Phase C — Agent chat

### Task 8: LLM traffic capture in `RemoteLlmRepository`

**Files:**
- Modify: `app_lib/chat/lib/src/repositories/remote_llm_repository.dart`, `app_lib/chat/lib/src/agent/repository_agent_llm_client.dart`, `app_lib/chat/lib/src/agent/chat_agent_runtime.dart`, `app_lib/chat/pubspec.yaml` (`app_logging: any`)
- Test: `app_lib/chat/test/remote_llm_logging_test.dart`

**Interfaces:**
- Consumes: `LoggingHttpClient`, `HttpCaptureTag`, `LogContext` (Tasks 4–5).
- Produces: `RemoteLlmRepository` wraps its client: `_client = LoggingHttpClient(client ?? http.Client())`. `generateResponse(..., {String? generationId, LogContext? logContext})`. Every request (generation and `listModels`) is tagged with `category: llmCategory(config)`, `apiType: config.remoteApiType.name`, `secretHeaders: {config.remoteAuthHeaderName}` when `remoteAuthType == RemoteAuthType.customHeader`, and `context`.
- `static String llmCategory(ModelConfig c)` → `'llm:<name>'` where name is the account/endpoint display name if `ModelConfig` carries one, else `Uri.parse(c.remoteBaseUrl).host`.
- `RepositoryAgentLlmClient` gains `final String? runId;` and an internal turn counter (1-based, incremented per model call), passing `LogContext(conversationId, runId, generationId, turn)`; `ChatAgentRuntime.runStream` passes `runId`.

- [ ] **Step 1: Failing tests** with a recording sink + `MockClient`: streaming anthropic generation yields the same chunks as before **and** writes `request`+`response` with category `llm:<host>`, `context.run_id`, `context.turn == 1`; custom auth header `X-Secret` stored as `[REDACTED]`; `listModels` 500 → `exchange` with full body; `stopGeneration` mid-stream → `aborted: true`.
- [ ] **Step 2–4:** fail → implement → pass; existing `app_lib/chat` tests still pass.
- [ ] **Step 5: Commit** `feat(chat): capture full LLM http exchanges`

### Task 9: Agent run and tool call events

**Files:**
- Modify: `app_lib/chat/lib/src/agent/agent_invocation.dart`, `agent/tool_gateway.dart`, `agent/chat_agent_runtime.dart`, `agent/sub_agent_supervisor.dart` (parent run id)
- Create: `app_lib/chat/lib/src/agent/agent_event_logger.dart`
- Test: `app_lib/chat/test/agent_event_logger_test.dart`, `test/tool_gateway_logging_test.dart`

**Interfaces — Produces:**
- `ToolInvocationReceipt` adds `String? backend` (`shell|sub_agent|memory|skill|tool_executor|none`), `int? durationMs`, `String? errorType`, `String? stackTrace` (also in `toJson`/`fromJson`).
- `AgentLogEvent agentLogEventFrom(ChatAgentEvent e, {int? turn})` in `agent_event_logger.dart`, `eventType` = event class name in snake_case without `_event` (e.g. `tool_call_completed`). `ModelChunkReceivedEvent` → `null` (not logged). Payload: tool `arguments` (raw string) and `result` (full), run failure error + stack.
- `ChatAgentRuntime.runStream` forwards every event to `LogCapture.instance.agent(...)` before adding it to the controller.

- [ ] **Step 1: Failing tests:** gateway with a tool that throws `StateError('boom')` → receipt `backend == 'tool_executor'`, `errorType == 'StateError'`, non-null `stackTrace`, `durationMs >= 0`; mapping of each event type; chunk events produce no record; a run with one tool call yields `run_started, model_turn_started, tool_call_prepared, tool_call_started, tool_call_completed, model_turn_completed, run_completed` in order with the same `run_id`.
- [ ] **Step 2–4:** fail → implement → pass.
- [ ] **Step 5: Commit** `feat(chat): persist agent run and tool call events`

### Task 10: Tool-side HTTP capture

**Files:**
- Modify: `app_lib/chat/lib/src/services/tool_executor.dart`, `services/dart_mcp_tool_client.dart`, `lib/screens/settings/remote_tools_settings_screen.dart:642`
- Test: `app_lib/chat/test/tool_http_logging_test.dart`

**Interfaces:** Every Dio created or injected in these files gets `ApiCaptureInterceptor` added last: remote MCP → `category: 'mcp:<profile/server name>'`, `secretHeaders` = all keys of the profile's configured headers; HTTP tools → `'tool:<tool name>'`; Route53/Cloudflare tool clients → `'route53'` / `'cloudflare_dns'`. Context = current tool call (`LogContext(runId, toolCallId)`) passed via `extra['log_context']` where the call site knows it.

- [ ] **Step 1: Failing tests:** MCP HTTP call with configured header `X-Team-Token` → record category `mcp:<name>`, header value `[REDACTED]`; HTTP tool failure (500) recorded with full body.
- [ ] **Step 2–4:** fail → implement → pass.
- [ ] **Step 5: Commit** `feat(chat): capture tool and MCP http traffic`

### Task 11: Log Center — All, API, Agent tabs, delete, export

**Files:**
- Modify: `lib/screens/settings/log_center_screen.dart`, `app_widget/adaptive/lib/src/log/duckdb_log_viewer.dart`, `log_filter_bar.dart` (category dropdown, errors-only), `log_detail_sheet.dart`
- Create: `app_widget/adaptive/lib/src/log/api_exchange_detail.dart`, `agent_run_timeline.dart`
- Modify: ARB `app_en.arb`, `app_zh.arb`; regenerate l10n
- Test: `test/screens/settings/log_center_screen_test.dart`, `app_widget/adaptive/test/api_exchange_detail_test.dart`

**Interfaces:**
- Consumes: Task 3 `LogFilter`, `queryLogs`, `listCategories`, `deleteOlderThan`, `exportJsonl`.
- Tabs: All (`v_all_logs`), System (`system_logs`), API (`api_exchanges`, category filter), Agent (`agent_events`, grouped by `run_id`), Usage (added in Task 13).
- `ApiExchangeDetail(record: Map<String,Object?>)`: sections Request / Response, headers table, JSON body pretty-printed, text/SSE body raw in a selectable monospace view, "Copy JSONL" button copying `record_json`.
- `AgentRunTimeline(runId)`: ordered events; a model turn with `request_id` links to its `ApiExchangeDetail`.
- Delete dialog: integer field N (≥1), scope = current tab's table or all of `LogTables.all`; calls `deleteOlderThan`.
- Export: `file_selector.getSaveLocation(suggestedName: 'gsmlg-<table>-<yyyyMMdd-HHmmss>.jsonl')` (pattern in `lib/screens/service/audio/audio_screen.dart:345`), writes `exportJsonl` with the current filter.

- [ ] **Step 1: Failing tests:** screen shows the four tabs; delete dialog rejects `0` and calls `deleteOlderThan(days: 3, tables: ['api_exchanges'])` on the API tab (fake `AppDuckDb` via `duckDb` parameter); `ApiExchangeDetail` renders SSE text verbatim and `[REDACTED]` headers.
- [ ] **Step 2–4:** fail → implement → pass. Manual check: run macOS app, send a chat message with a tool call, open Log Center → API and Agent tabs show the run; export file lines parse as JSON.
- [ ] **Step 5: Commit** `feat(log-center): api and agent views, delete by age, jsonl export`

## Phase D — Usage

### Task 12: Sessions and screen views

**Files:**
- Create: `lib/core/usage/usage_tracker.dart`
- Modify: `lib/app.dart` (attach to `AppRouter.router.routerDelegate` and `AppLifecycleListener`, like `_syncDuoState`)
- Test: `test/core/usage_tracker_test.dart`

**Interfaces — Produces:** `class UsageTracker { UsageTracker({DateTime Function()? clock, String? appVersion}); void start(); void onRouteChanged(Uri uri, String? routeName); void onForeground(); void onBackground(); void dispose(); String get sessionId; static String moduleFor(Uri uri); }` — `moduleFor`: first path segment `home|service|toolbox|chat|settings` → `Home|Service|Toolbox|Chat|Settings`, else `Other`. A visit is closed (one `screen_view` with `duration_ms`) on route change, background, or dispose; background time is not counted; `session_start` on `start`, `session_end` on dispose with total foreground ms. Splash route is not recorded.

- [ ] **Step 1: Failing tests** with a fake clock and recording sink: `/toolbox/whois` 5 s → `/settings` emits `screen_view{module:'Toolbox', duration_ms:5000}`; 3 s visible + 10 s background + 2 s visible → two views of 3000 and 2000 ms; `moduleFor(Uri.parse('/service/github'))` → `Service`.
- [ ] **Step 2–4:** fail → implement → pass.
- [ ] **Step 5: Commit** `feat(usage): track sessions and screen visible time`

### Task 13: Menu taps and Usage tab

**Files:**
- Create: `lib/core/usage/menu_navigation.dart`
- Modify: `lib/destination.dart` (`changeHandler`), `lib/screens/toolbox/toolbox_screen.dart`, `lib/screens/service/service_screen.dart`, `lib/screens/settings/settings_screen.dart`, `lib/screens/settings/log_center_screen.dart` (Usage tab + export)
- Test: `test/core/menu_navigation_test.dart`, extend `test/screens/settings/log_center_screen_test.dart`

**Interfaces — Produces:** `extension MenuNavigation on BuildContext { void menuGoNamed(String name, {String? label}); void menuGo(String location, {String? label}); }` — records `UsageEvent(eventType: 'menu_tap', target: name/location, module: UsageTracker.moduleFor(target uri), sourceScreen: current route name)` then navigates. Replace navigation calls in `Destinations.changeHandler` and in the menu tiles of the three list screens (not other buttons).

- [ ] **Step 1: Failing tests:** tapping a Toolbox tile records `menu_tap` with `target` = the tile's route name and `sourceScreen: 'Toolbox'`, then navigates; Log Center shows a Usage tab listing `usage_events`.
- [ ] **Step 2–4:** fail → implement → pass.
- [ ] **Step 5: Commit** `feat(usage): record menu taps and add usage tab`

## Phase E — Other API clients

### Task 14: GitHub, Vultr, Cloudflare DNS, Route53 capture

**Files:**
- Modify: `app_bloc/github/lib/src/bloc.dart` (`_createDio`), `app_bloc/domain/lib/src/record_bloc.dart` (`_createRoute53Dio`, `_createCloudflareDio`), the Vultr client construction in `app_bloc/vultr`, `lib/screens/service/domain/add_zone_screen.dart:90,132`; pubspecs of those blocs (`app_logging: any`)
- Test: `app_bloc/github/test/github_dio_logging_test.dart`, `app_bloc/domain/test/record_dio_logging_test.dart`

**Interfaces:** add `ApiCaptureInterceptor(category: 'github' | 'vultr' | 'cloudflare_dns' | 'route53')` **last** on each Dio. Where the creator knows the service account, append it: `'route53:<account name>'`.

- [ ] **Step 1: Failing tests:** the Dio built by each factory has `ApiCaptureInterceptor` as its last interceptor with the expected category; a fake-adapter Route53 call records `Authorization` as `[REDACTED]` after SigV4 signing.
- [ ] **Step 2–4:** fail → implement → pass.
- [ ] **Step 5: Final verification:** `melos run analyze`, `melos run format-check`, `melos run test` (after `cargo build`), `flutter build macos --debug`; run the app and confirm GitHub/Vultr screens produce API records.
- [ ] **Step 6: Commit** `feat(api): capture github, vultr and dns provider traffic`
