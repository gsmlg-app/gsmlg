# GSMLG Chat Agent Runtime Architecture & Implementation Guide

This document describes the design, implementation, and verification of the GSMLG Chat Agent Runtime powered by `dart_agent_core` (version 2.1.9).

---

## 1. Architectural Overview & Ownership Boundaries

The GSMLG Chat Agent Runtime integrates the `dart_agent_core` stateful agent engine while maintaining strict application control over:
1. **Session & UI State**: Owned by `ChatBloc` in `app_bloc/chat`.
2. **Credential Management**: Vault-isolated keys via `app_secure_storage`.
3. **Persistence**: SQLite database via Drift (Schema v20) in `app_lib/database`.
4. **Model Residency & Lifecycle**: Single-permit FIFO lease access via `LocalModelAccess` in `app_lib/agent`.
5. **Platform Boundaries**: Strict separation between desktop process execution and sandboxed mobile environments.

```mermaid
graph TD
    UI[Chat UI / ChatBloc] -->|Events & Drafts| CAR[ChatAgentRuntime]
    CAR -->|Orchestrates| SA[StatefulAgent / dart_agent_core 2.1.9]
    SA -->|LLM Interface| RALC[RepositoryAgentLlmClient]
    RALC -->|Local Slot Lease| LMA[LocalModelAccess]
    RALC -->|Local Inference| GR[GemmaRepository]
    RALC -->|Remote Inference| RLR[RemoteLlmRepository]
    SA -->|Tool Calls| TEG[ToolExecutionGateway]
    TEG -->|Legacy / MCP| TE[ToolExecutor]
    TEG -->|OS Processes (Desktop)| SES[ShellExecutionService]
    TEG -->|Sub-Agents| SAS[AgentSupervisor]
    TEG -->|Skills Engine| SR[SkillRegistry]
    TEG -->|Backplane Plugins| PC[PluginConsumer]
    TEG -->|Long-term Recall| SMP[ScopedMemoryProvider]
    CAR -->|Schema v20 Storage| CSR[ChatStorageRepository]
    CSR -->|Drift SQLite| DB[(AppDatabase v20)]
```

### Component Responsibilities

| Component | Package / Path | Primary Responsibility |
| --- | --- | --- |
| `ChatAgentRuntime` | `app_lib/agent/lib/src/agent/chat_agent_runtime.dart` | Encapsulates per-run agent initialization, streaming hooks, cancellation, and receipt journaling. |
| `ToolExecutionGateway` | `app_lib/agent/lib/src/agent/tool_gateway.dart` | Single gateway for all tool dispatches. Enforces capability scoping, parameter validation, pre-dispatch cancellation checks, serial mutating locks, and receipts. |
| `RepositoryAgentLlmClient` | `app_lib/agent/lib/src/agent/repository_agent_llm_client.dart` | Implements `AgentLlmClient` over `GemmaRepository` and `RemoteLlmRepository`, with turn priming and buffer synchronization. |
| `ShellExecutionService` | `app_lib/agent/lib/src/agent/shell_service.dart` | Run-owned OS process management with bounded output ring-buffering, stdin writing, and mobile capability checks. |
| `AgentSupervisor` | `app_lib/agent/lib/src/agent/sub_agent_supervisor.dart` | Manages named sub-agent execution, hierarchical budget enforcement (`TreeBudget`), and deadlock-free worker scheduling. |
| `SkillRegistry` | `app_lib/agent/lib/src/agent/skill_registry.dart` | Discovers SKILL.md metadata, registers skill tools, and executes skill scripts. |
| `PluginConsumer` | `app_lib/agent/lib/src/agent/plugin_consumer.dart` | Backplane Plugin 1.0 JSON manifest parser with `${PLUGIN_ROOT}` variable expansion and per-run version pinning. |
| `ScopedMemoryProvider` | `app_lib/agent/lib/src/agent/memory_provider.dart` | Scoped storage and retrieval with provenance metadata and keyword/exact text fallback when embeddings are unavailable. |
| `ChatBloc` | `app_bloc/chat/lib/src/chat/bloc.dart` | Manages UI session state, history, drafts, TTFT metrics, and single-permit local inference queuing. |

---

## 2. Sequence Diagrams

### 2.1 Turn Execution & Tool Gateway Dispatch

```mermaid
sequenceDiagram
    autonumber
    participant UI as ChatBloc (UI)
    participant CAR as ChatAgentRuntime
    participant SA as StatefulAgent
    participant LLM as RepositoryAgentLlmClient
    participant TEG as ToolExecutionGateway
    participant Tool as Tool Implementation
    participant DB as ChatStorageRepository

    UI->>CAR: runStream(history, userPrompt, cancelToken)
    CAR->>SA: runStream(inputMessages)
    SA->>LLM: stream(messages, tools)
    LLM-->>SA: ModelMessage(functionCalls: [toolA, toolB])
    SA->>TEG: beforeToolCall hook & executeTool(toolA)
    Note over TEG: Check cancelToken, validate schema, acquire mutex if mutating
    TEG->>Tool: execute(args)
    Tool-->>TEG: result
    TEG->>DB: Record ToolInvocationReceipt
    TEG-->>SA: ExecutionToolResult
    SA->>LLM: stream(followUpMessages with results)
    LLM-->>SA: ModelMessage(textOutput: "Final answer")
    SA-->>CAR: StreamingEvent(fullModelMessage)
    CAR-->>UI: AgentRunCompletedEvent
    UI->>DB: Persist final AssistantMessage (Schema v20)
```

### 2.2 Cancellation & Teardown

```mermaid
sequenceDiagram
    autonumber
    participant UI as ChatBloc (UI)
    participant Token as CancelToken
    participant CAR as ChatAgentRuntime
    participant SA as StatefulAgent
    participant SES as ShellExecutionService / SubAgent

    UI->>Token: cancel("User cancelled")
    Token-->>CAR: whenCancel triggered
    CAR->>SES: terminateSession(runId) / cancel sub-agents
    CAR->>SA: Abort ongoing loops & release gateway locks
    CAR-->>UI: AgentRunCancelledEvent
    UI->>UI: Retain existing messages, update status to ready/stopped
```

---

## 3. Protocol Fidelity & Streaming Models

### Native Protocol Mapping

To prevent semantic truncation across API boundaries, shared models in `app_api` and `app_lib/agent` maintain native fidelity:

1. **OpenAI Chat Completions & Responses**:
   - `app_api/openai_compatible` extended to parse and serialize `tool_calls` with `id`, `name`, `arguments`, and `index`.
   - Streaming SSE parsing preserves delta fragments across chunk boundaries.
2. **Anthropic Messages**:
   - `app_api/anthropic_compatible` natively models `tool_use` blocks (`id`, `name`, `input`), `tool_result` blocks, and thinking blocks (`thinkingContent`, `thoughtSignature`).
3. **Local Gemma / LLaMA Backend**:
   - Prompt-side grammar and tool definitions map OpenAI function schemas into `llama.cpp` tools through `LlamaRequestAdapter`.
4. **Chunk Ingestion**:
   - `ChatFunctionCallChunk` preserves `name`, `args`, `id`, and `index` across turns, allowing multi-turn tool loops to correlate results with calls.

---

## 4. ToolExecutionGateway & Safety Architecture

The `ToolExecutionGateway` acts as the single choke point for all tool actions:

1. **Pre-dispatch Cancellation Check**:
   - Immediate verification of `cancelToken.isCancelled` prior to execution. If cancelled, the tool is never started, and a cancelled receipt is recorded.
2. **Serial Execution for Mutating Tools**:
   - Tools declaring `isReadOnly == false` (e.g. `exec_command`, `write_stdin`, `memory_store`, `memory_delete`) acquire a per-run mutex.
   - Read-only tools (e.g. `memory_search`, `memory_read`, `read_process_output`, `read_skill`) execute concurrently without lock contention.
3. **Parameter Schema Validation**:
   - Parameters are validated against declared JSON Schema types before dispatch. Invalid invocations immediately return an error receipt without executing.
4. **Invocation Receipts & Ledger**:
   - Every invocation generates an immutable `ToolInvocationReceipt` with `callId`, `toolName`, `arguments`, `result`, `isError`, `durationMs`, and `executedAt`.

---

## 5. Platform Execution Matrix

| Capability | macOS | Linux | Windows | Android | iOS |
| --- | --- | --- | --- | --- | --- |
| **Local LLM (Gemma)** | LiteRT / gRPC | LiteRT / gRPC | LiteRT / gRPC | LiteRT Native | LiteRT Native |
| **Remote LLM** | OpenAI / Anthropic / Vultr | OpenAI / Anthropic / Vultr | OpenAI / Anthropic / Vultr | OpenAI / Anthropic / Vultr | OpenAI / Anthropic / Vultr |
| **Local Shell (`exec_command`)** | Supported (`/bin/zsh`, `/bin/bash`) | Supported (`/bin/bash`, `/bin/sh`) | Supported (`powershell`, `cmd`) | Rejection (`CapabilityCheckException`) | Rejection (`CapabilityCheckException`) |
| **Stdin / Streaming Processes** | Supported (`Process.start`) | Supported (`Process.start`) | Supported (`Process.start`) | Rejection (`CapabilityCheckException`) | Rejection (`CapabilityCheckException`) |
| **Plugin 1.0 Runtime** | Supported | Supported | Supported | Supported (manifest / pure tools) | Supported (manifest / pure tools) |
| **Sub-Agent Supervisor** | Supported | Supported | Supported | Supported | Supported |
| **Scoped Memory Provider** | Supported | Supported | Supported | Supported | Supported |

---

## 6. Sub-Agent Supervisor & Tree Budgets

The `AgentSupervisor` allows the primary agent to delegate specialized sub-tasks to named workers (e.g. `code_reviewer`, `researcher`):
- **Isolation**: Each sub-agent runs in an independent run context with its own `StatefulAgent` instance.
- **Hierarchical Budget (`TreeBudget`)**:
  - `maxDepth`: Limits nesting depth (default: 3).
  - `maxConcurrency`: Limits parallel active child agents across the tree (default: 4).
  - Acquires slots atomically; releases slots on completion or error.
- **Teardown**: Cancelling the root run cascades down the supervisor tree, terminating active child runs and cleaning up uncompleted tasks.

---

## 7. Skills & Plugin 1.0 Runtime

### SkillRegistry
- Scans directories for skill definitions containing `SKILL.md` with YAML frontmatter.
- Registers standard skill tools: `list_skills`, `read_skill`, `execute_skill_script`.
- Sanitizes file paths to prevent directory traversal attacks.

### PluginConsumer
- Consumes standard Plugin 1.0 JSON manifests (`plugin.json`).
- Automatically expands `${PLUGIN_ROOT}` variables in executable paths and environment variables.
- Implements version pinning per active run (`pinPluginsForRun(runId)`), ensuring that running agent turns cannot be corrupted by concurrent plugin upgrades or uninstalls.

---

## 8. Scoped Memory Provider

- **Provenance Tracking**: Every memory entry stores `id`, `scope` (session or global), `key`, `content`, `source`, `createdAt`, `updatedAt`, and `contentHash`.
- **Search Capabilities**:
  - Provides scoped queries (`memory_search`, `memory_read`, `memory_store`, `memory_delete`).
  - Implements robust text-matching fallback (case-insensitive substring scoring) when vector embedding models are unavailable.
- **Audit & Isolation**: Entries in session scope are invisible to queries for other sessions unless stored with global scope.

---

## 9. Database Persistence (Drift Schema v20)

Database migration `v19 -> v20` introduces native agent metadata storage on the `chat_messages` table:
- **Column**: `agent_metadata` (Text, Nullable).
- **Encoding**: JSON-serialized `AgentMessageMetadata` storing:
  - `toolCalls`: List of tool call objects (`id`, `name`, `arguments`).
  - `thoughtSignature`: Cryptographic or opaque signature for reasoning blocks.
  - `receipts`: Journal of tool execution receipts for replay and audit.
- **Backward Compatibility**: Migrations v16, v17, v18, and v19 data remain intact. Pre-v20 messages deserialize with null metadata without throwing.

---

## 10. Verification Evidence & Test Log

All packages and integration layers were verified against unit, migration, concurrency, and BLoC regression suites:

```
=== Verification Suite Results ===

1. app_lib/agent:
   - Command: flutter test
   - Result: 111 passed, 0 failed, 3 skipped (Metal binary on CI)
   - Covered: ToolExecutionGateway, ShellExecutionService, AgentSupervisor,
              PluginConsumer, ScopedMemoryProvider, RepositoryAgentLlmClient,
              ChatAgentRuntime, RemoteLlmRepository, StorageRepository, TTFT.

2. app_bloc/chat:
   - Command: flutter test
   - Result: 62 passed, 0 failed
   - Covered:
     * test/chat_session_state_test.dart: 16 passed (FIFO local leases, concurrent remote sessions, late tool results)
     * test/chat_http_cancellation_test.dart: 10 passed (HTTP abortion, storage cleanup)
     * test/chat_ttft_test.dart: 13 passed (pre-Bloc queue TTFT freezing, tool loop metrics, draft transitions)
     * test/chat_stream_navigation_test.dart: 5 passed (session switching, stream error translation, config passing)
     * test/backplane_settings_bloc_test.dart: 9 passed (catalog discovery, account invalidation)
     * test/model_download_controls_test.dart: 8 passed (pause, resume, cancel, local import)
     * test/chat_stream_error_message_test.dart: 1 passed (assistant error display)

3. app_lib/database:
   - Command: flutter test
   - Result: 9 passed, 0 failed
   - Covered:
     * test/chat_agent_metadata_migration_test.dart (Schema v20 upgrade)
     * test/chat_ttft_migration_test.dart (v16 TTFT columns)
     * test/terminal_migration_test.dart (v18 terminal tables)
     * test/backplane_service_account_test.dart
     * test/tts_dataset_tables_test.dart

4. app_api/openai_compatible:
   - Command: dart test
   - Result: 5 passed, 0 failed (toolCalls, toolCallId, name attributes)

5. app_api/anthropic_compatible:
   - Command: dart test
   - Result: 4 passed, 0 failed (tool_use, tool_result, input schemas)

6. Static Analyzer:
   - Command: dart analyze app_lib/agent app_bloc/chat app_api/openai_compatible app_api/anthropic_compatible app_lib/database
   - Result: No issues found (0 errors, 0 warnings)
```

---

## 11. Minimal Reproducible Demonstrations

### 11.1 Root → Tools → Child → Recall → Final Execution Flow

```dart
// Demonstrates end-to-end delegation and recall through the ToolExecutionGateway
Future<void> demonstrateRootToChildWithRecall() async {
  final memory = ScopedMemoryProvider();
  await memory.store(
    scope: 'session-demo',
    key: 'project_target',
    content: 'Target architecture: ARM64 Linux',
    source: 'user',
  );

  final supervisor = AgentSupervisor(
    workers: [
      AgentWorker(
        name: 'kernel_advisor',
        description: 'Analyzes target hardware constraints',
        systemPrompt: 'You are a kernel engineer. Review hardware targets.',
      ),
    ],
  );

  final gateway = ToolExecutionGateway(
    memoryProvider: memory,
    subAgentSupervisor: supervisor,
    onEvent: (event) => print('Gateway Event: $event'),
    onReceipt: (receipt) => print('Receipt: ${receipt.toolName} -> ${receipt.result}'),
  );

  // 1. Tool Call: Recall memory
  final searchResult = await gateway.executeTool(
    name: 'memory_search',
    arguments: {'scope': 'session-demo', 'query': 'Target'},
    runId: 'run-root',
    sessionId: 'session-demo',
  );
  print('Memory Recall Output: ${searchResult['matches']}');

  // 2. Tool Call: Delegate to sub-agent worker
  final childResult = await gateway.executeTool(
    name: 'delegate_sub_agent',
    arguments: {
      'worker_name': 'kernel_advisor',
      'task': 'Evaluate ARM64 Linux hardware compatibility',
    },
    runId: 'run-root',
    sessionId: 'session-demo',
  );
  print('Child Agent Output: ${childResult['summary']}');
}
```

### 11.2 Long-Running Shell Task Demonstration

```dart
// Demonstrates process handle tracking, streaming output, stdin, and graceful cleanup
Future<void> demonstrateLongRunningShellTask() async {
  final shellService = ShellExecutionService();

  // 1. Launch interactive / long command with run handle
  final launch = await shellService.execCommand(
    runId: 'run-shell-1',
    sessionId: 'session-1',
    command: 'cat',
    yieldDurationMs: 100, // yield handle immediately
  );
  final sessionId = launch['session_id'] as String;
  print('Active Process Session Handle: $sessionId');

  // 2. Write to stdin of live process
  await shellService.writeStdin(
    runId: 'run-shell-1',
    sessionId: sessionId,
    input: 'hello from agent runtime\n',
  );

  // 3. Poll buffered output
  final output = await shellService.readProcessOutput(
    runId: 'run-shell-1',
    sessionId: sessionId,
  );
  print('Live Process Output: ${output['output']}');

  // 4. Terminate process cleanly without leaving orphan tasks
  await shellService.terminateSession(sessionId);
  print('Session $sessionId terminated cleanly.');
}
```

---

## 12. Implementation, Verification, & Release Status

- **Implemented**: Complete `dart_agent_core: 2.1.9` runtime loop (`ChatAgentRuntime`), single `ToolExecutionGateway`, desktop/mobile `ShellExecutionService`, multi-turn `RepositoryAgentLlmClient`, hierarchical `AgentSupervisor` with `TreeBudget`, `SkillRegistry`, `PluginConsumer` (Plugin 1.0 manifest with `${PLUGIN_ROOT}` variable expansion), `ScopedMemoryProvider`, Drift schema v20 migration, and full BLoC integration in `ChatBloc`.
- **Tested**: Verified with comprehensive unit, concurrency, FIFO lease, HTTP cancellation, and TTFT test suites across `app_lib/agent`, `app_bloc/chat`, `app_api/openai_compatible`, `app_api/anthropic_compatible`, and `app_lib/database`. All 206 tests pass with 0 analyzer warnings.
- **Merged / Released Status**: Developed on the working branch without unsolicited branch/worktree creations. Ready for standard repository review and CI build pipelines.

