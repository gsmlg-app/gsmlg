# App Logging: Agent Chat Debug Log, API Exchange Log, Usage Log

- **Date**: 2026-11-10
- **Status**: Ready for approval
- **Builds on**: the DuckDB log store migrated from yellow-dog-app (`app_lib/duckdb`, `DuckDbLogOutput` on `Logger.root`, Log Center under Settings → Device).

## 1. Why

The AI agent chat sometimes fails and we cannot tell why.

- **LLM API.** `RemoteLlmRepository` (`app_lib/chat/lib/src/repositories/remote_llm_repository.dart`) talks to the configured provider over one `http.Client`. On a non-2xx status it throws with a *shortened* body. While streaming, it silently `continue`s past lines it cannot interpret, so a malformed or unexpected chunk leaves no trace.
- **Tool calls.** `ToolExecutionGateway` (`app_lib/chat/lib/src/agent/tool_gateway.dart`) dispatches to shell, sub-agent, memory, skills, or `ToolExecutor` (Dio-based HTTP tools, remote MCP, Route53/Cloudflare clients). A failure reaches the model only as the text `Tool execution failed: $e`. The agent already emits `ChatAgentEvent`s (run started, model turn, tool prepared/started/completed, run failed or cancelled), but none of them are persisted.

The logs are for **debugging**, so they must hold the **full data**, not summaries.

A second, independent need: understand **how the app is used** (which menus get tapped, which modules, how long each screen is viewed). This data stays on the device and can be exported for analysis.

## 2. Goals

1. Every LLM HTTP call made by chat is recorded in full (request and response), in the proxy-dump JSONL format described in §4.
2. Every agent tool call is recorded in full: arguments, which backend ran it, result or error with stack trace, timing, and cancellation.
3. Records are linked as conversation → agent run → model turn / tool call, so one failed chat can be read as a single ordered timeline.
4. API records carry a **category** identifying the endpoint/service, so each service's logs can be found by filtering.
5. All other app API clients (GitHub, Vultr, Cloudflare DNS, Route53) are recorded the same way, with their own categories.
6. Usage: sessions, screen views with visible duration, and menu taps are recorded on device.
7. The Log Center can browse, filter, and export these logs, and the user can delete data older than N days.

### On/off

All logging (system, API, agent, usage) is **on by default**. The capture layer may expose a programmatic switch per log type (for a future setting), but **no UI to turn logging off is built in this work**.

## 3. Non-goals and anti-goals

**Non-goals**
- Uploading logs or usage data anywhere. Everything stays on the device.
- Usage dashboards or charts (summaries come later, or after export).
- Automatic retention, rotation, or size caps.
- Settings UI to disable logging.
- Capturing large binary downloads (see §4.4).

**Anti-goals: a failure even if it "works"**
- **Truncated or summarized bodies** in debug records. The point is to see exactly what was sent and received.
- **Credentials written to disk.** API keys, bearer tokens, AWS secrets, and cookies must never be stored.
- **Logging that changes behavior.** Logging must not alter the requests, consume or reorder a stream the app is reading, or add noticeable latency to streaming output. If the log store is unavailable, the app works exactly as before.
- **Logging failures surfacing as app failures.** Write errors are reported to stderr and dropped, as `DuckDbLogOutput` does today.

## 4. Record format: API exchanges

### 4.1 Shape

Follow the user-supplied reference `proxy-dump-log.jsonl`. One JSON object per record:

```jsonc
{
  "ts": "2026-03-12T18:24:24.739327+08:00",   // ISO-8601 with local offset, microseconds
  "request_id": "uuid-v4",                    // links request/response records of one call
  "record_type": "exchange" | "request" | "response",
  "duration_ms": 1501,                        // on "exchange" and "response" only
  "request": {
    "method": "POST",
    "scheme": "https",
    "host": "api.example.com",
    "uri": "/v1/messages?beta=true",          // path + query
    "proto": "HTTP/1.1",
    "remote_addr": null,                       // a client cannot know this reliably; may be null
    "headers": { "Content-Type": ["application/json"], "Authorization": ["[REDACTED]"] },
    "body": { ... } | "raw text" | "base64",
    "body_encoding": "json" | "text" | "base64",
    "body_truncated": false,
    "content_type": "application/json",
    "content_length": 1234
  },
  "response": {
    "status": 200,
    "headers": { "Content-Type": ["text/event-stream; charset=utf-8"] },
    "body": "event: message_start\ndata: {...}\n\n...",
    "body_encoding": "text",
    "body_truncated": false,
    "content_type": "text/event-stream; charset=utf-8"
  }
}
```

- **Non-streamed call** → one `exchange` record with both `request` and `response`.
- **Streamed call** → a `request` record written when the request is sent, then a `response` record written when the stream ends (normally, by error, or by user abort), holding the **complete raw stream text** exactly as received. Same `request_id` on both.
- `body_encoding`: `json` when the body parses as JSON (stored as a JSON value), `text` for other textual content types, `base64` for binary.

### 4.2 Extensions for this app (my call)

Extra top-level fields added to the reference format. A consumer of the reference format can ignore them.

| Field | Meaning |
|---|---|
| `category` | Endpoint/service identity, see §4.3 |
| `context` | `{conversation_id, run_id, turn, generation_id, tool_call_id}`, whichever apply; absent outside chat |
| `error` | For transport failures with no HTTP response (DNS, TLS, timeout, connection reset, abort): `{type, message, stack_trace}` |
| `aborted` | `true` when the user stopped the generation |

A failed call with no response is still recorded (`exchange` or `response` record with `error` and no `response` object).

### 4.3 Category

Category answers "which service's logs are these?". Proposed values (my call):

| Source | Category |
|---|---|
| Chat LLM | `llm:<account or endpoint name>`, e.g. `llm:openrouter`. Falls back to the base-URL host when no account name exists. The API type (chat completions / responses / anthropic messages) is kept as a separate filterable field. |
| Model listing for an LLM endpoint | same `llm:<…>` category |
| Remote MCP / HTTP tools | `mcp:<server/profile name>` or `tool:<tool name>` |
| GitHub / Vultr / Cloudflare DNS / Route53 | `github`, `vultr`, `cloudflare_dns`, `route53`, plus the service account where one exists |

### 4.4 Credentials and binary data

- **Redact** (value replaced with `[REDACTED]`, header name kept): `Authorization`, `Proxy-Authorization`, `X-Api-Key`, `Api-Key`, `Cookie`, `Set-Cookie`, AWS SigV4 `X-Amz-Security-Token`, and API keys appearing in the query string. Keep the redaction list in one place.
- **Call-site secrets (my call):** headers with user-chosen names also carry credentials: `RemoteAuthType.customHeader` (`remoteAuthHeaderName`), user-configured remote MCP headers (`DartMcpHttpServerConfig.headers`), and configured HTTP-tool headers. Each call site passes the names of the headers it treats as secret to the capture layer, which redacts them together with the fixed list. For MCP and HTTP-tool configurations, **every user-configured header is treated as secret** (name kept, value `[REDACTED]`). Redaction is by header name; bodies are not scanned.
- Request/response **bodies are not redacted**. They are what we need to debug. *(Consequence: conversation content is stored in plain text in the log DB, the same as the chat history DB.)*
- **Binary bodies** (audio uploads/downloads, any non-text content type) are stored base64 *up to a cap* with `body_truncated: true` past it (builder chooses the cap, e.g. 1 MB). The Gemma model downloads in `GemmaRepository` (multi-GB, raw `HttpClient`) are **not** captured as API exchanges. A lifecycle line in `system_logs` is enough.

## 5. Record format: agent events and tool calls

Persist the agent's event stream so a run reads as a timeline:

- Run started / completed / failed (with error + stack) / cancelled.
- Model turn started / completed, with the `request_id` of its LLM exchange.
- Tool call prepared / started / completed: tool name, raw argument string, **backend that handled it** (shell, sub_agent, memory, skill, tool_executor, none), full result (string or JSON), `is_error`, error type/message/stack when an exception was thrown, `duration_ms`, cancelled flag.
- Model chunk events are **not** stored individually. The raw stream is already in the LLM `response` record.

Every agent record carries `conversation_id`, `run_id`, and, where relevant, `turn` and `tool_call_id`. Sub-agent runs also carry `parent_run_id`.

## 6. Usage records

All on device, in the same DuckDB file.

- **Session**: one per app launch, with `session_id`, start/end time, platform, app version.
- **Screen view**: route name + path, **module** (Home, Service, Toolbox, Chat, Settings, derived from the top-level route), `entered_at`, `visible_ms`.
  - Time with the app backgrounded, hidden, or minimized does not count (my call). Leaving the foreground closes the visit and returning opens a new one.
  - Captured centrally (router listener plus app lifecycle), so new screens need no per-screen code.
- **Menu tap**: main navigation tabs (`Destinations.changeHandler`) and the menu entries inside Service, Toolbox, and Settings lists. Records what was tapped (`target` route/name), which module, and the screen it was tapped from. Only navigation-style taps (my call). Ordinary buttons are not tracked.
- No usage of chat content, typed text, or account identifiers.

## 7. Storage

- Same DuckDB file as today (`gsmlg_logs.duckdb`, `AppDuckDb`), written through the existing batching `DuckDbLogOutput` pattern (buffer + periodic flush, non-blocking).
- New dedicated tables (names are the builder's choice): API exchanges, agent events, usage sessions/views/taps. Each API exchange row keeps the **full JSONL record verbatim** (so export is exact) plus extracted columns for filtering: `ts`, `request_id`, `record_type`, `category`, `method`, `host`, `path`, `status`, `duration_ms`, `has_error`, and the context IDs.
- `system_logs` keeps receiving general `package:logging` records as today.
- **Remove** the yellow-dog leftovers: `dns_logs`, `dhcp_logs`, the legacy `app_logs`, their Rust appenders/queries and Dart routing (`LogRouter` DNS/DHCP branches). Update the `v_all_logs` view accordingly. This means changing `app_lib/duckdb/rust/src/api/duckdb.rs` and regenerating the flutter_rust_bridge bindings (`flutter_rust_bridge_codegen generate`). Existing user DB files may already contain those tables. Dropping them is acceptable (they hold no gsmlg data).
- **Retention**: keep everything. No automatic pruning.

## 8. Log Center UI

Extends the existing Settings → Device → Log Center screen:

- Tabs: **All**, **System**, **API**, **Agent**, **Usage**.
- **All** (my call): one cross-type timeline built from a common summary projection (`id`, `ts`, `log_type`, `category`, `level`, one-line `summary`) over system, API, and agent records. Usage records are excluded (they are analytics, not debug events). Tapping a row opens the detail view for its type. `v_all_logs` is redesigned around this projection, and `DuckDbLogViewer` dispatches the detail view by `log_type`.
- API tab: filter by category, status/error, method, time range, keyword. The detail view shows full request/response (headers, pretty JSON, raw stream text) and has "copy as JSONL".
- Agent tab: list runs by conversation. Opening a run shows its timeline (turns, LLM exchanges, tool calls) with links to the full exchange records.
- **Delete old data**: the user enters N days and confirms. Records older than N days are deleted from the selected log type (or all). This replaces the current fixed 7/30-day buttons.
- **Export**:
  - API exchanges → `.jsonl` in §4 format, filtered by the current filters (e.g. one category, or one conversation).
  - Usage → `.jsonl` (CSV optional later).
  - Uses the platform save/share mechanism already used elsewhere in the app (builder to pick).

## 9. Delivery order

1. Storage changes (tables, Rust appenders, codegen, remove DNS/DHCP) and export plumbing.
2. **Chat**: LLM exchange capture in `RemoteLlmRepository` (streaming and non-streaming, `listModels`), agent event and tool call capture, context linking, Log Center API + Agent tabs.
3. Usage tracking + Usage tab.
4. Other API clients (GitHub, Vultr, Cloudflare DNS, Route53, Dio in `ToolExecutor` / `DartMcpToolClient`).

Each step is shippable on its own.

## 10. Constraints

- **Platforms (my call):** the app must keep building and running on every platform it ships today (CI builds Linux on every change, and release builds Android, iOS, Linux, and macOS). Delivery step 1 therefore starts with platform enablement: Rust targets in `rust-toolchain.toml`, the native-assets hook, and CI. Wherever the store fails to load at runtime, capture is a no-op.
- **Dependency direction (my call):** `app_chat`, `app_api/*` and the BLoCs do **not** depend on `app_duckdb`. They write through a thin sink interface (in `app_logging`) that the app wires to DuckDB in `main.dart`/`MainProvider`. With no sink attached, capture does nothing.

- Flutter monorepo conventions (AGENTS.md): workspace packages with `any`, BLoC for UI state, DI in `MainProvider`, strings in ARB via `context.l10n`.
- `app_lib/duckdb` is native (Rust via flutter_rust_bridge + native assets hook). DuckDB is a process-wide connection behind a Rust mutex. Writes from a background isolate need `RustLib.init()` in that isolate or must be forwarded to the main isolate.
- Startup: the store opens in `lib/main.dart` before the first log, and failure is non-fatal (already in place).
- Platforms: macOS is verified today. Linux/Windows/Android/iOS builds of the Rust crate still need verifying (`rust-toolchain.toml` lists only `aarch64-apple-darwin`).
- Tests: package tests for `app_duckdb` need the crate built (`cargo build` in `app_lib/duckdb/rust`).

## 11. Left to the builder

- Exact table/column names and indexes.
- Where the capture hooks live (an `http.Client` wrapper, a Dio interceptor, wrapping `ToolExecutionGateway`, a `GoRouter` listener, etc.) and how logging context (conversation/run/turn IDs) reaches the HTTP layer, as long as §3's anti-goals hold.
- The binary body cap.
- Export file mechanics and file naming.
- Pagination/virtualization for large bodies in the detail view.
