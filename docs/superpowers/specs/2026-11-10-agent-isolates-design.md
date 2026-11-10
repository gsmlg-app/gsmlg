# Agents in Isolates: Design

- **Date**: 2026-11-10
- **Status**: Approved direction (owner: "chat is refactored to agent", "each agent lives in an isolate", "DuckDB should have its own isolate"); details are the builder's calls, marked *(call)*.

## 1. Intent

Chat becomes **talking to agents**. An agent is a configured bot (like OpenAI GPTs / Grok bots) with per-agent settings; the user opens sessions with an agent and talks to it. The agent machinery moves out of `app_lib/chat` into a new `app_lib/agent` package, and **each agent runs in its own isolate** under `app_lib/isolate_orchestrator`. The **DuckDB log store runs in its own isolate**; every isolate (main, agents) sends log records to it. Afterwards, the remaining agent-chat logging gaps are fixed.

## 2. Goals

1. `app_lib/agent` (package `app_agent`) replaces `app_lib/chat` (`app_chat` is deleted); all consumers import `app_agent`.
2. Agent definitions are persisted in Drift with per-agent settings: name, avatar (emoji), description, instructions, model config, thinking, allowed tools *(call: null = all tools)*. Existing SharedPreferences `chat_agents` are migrated once.
3. A conversation (session) belongs to an agent (`agent_id` column); the agent is restored on load.
4. One long-lived isolate per agent definition, spawned on first use under a `/agents` supervision group, stopped after 10 idle minutes *(call)*, restart type `transient`. Sessions of that agent run inside its isolate (each run keeps its own cancellation domain).
5. The log store (DuckDB) runs in a `logstore` isolate. Producers send records through a port; the Log Center queries through a client. No other isolate opens DuckDB.
6. Agents UI like GPTs: an agents home (list/grid of agents with avatar, name, description), agent editor, per-agent session list, conversation view (existing chat widgets).
7. Logging fixes: tool HTTP records carry `turn`; Dio cancellations are `aborted` without `error`; sub-agent records carry `conversationId`.

## 3. Non-goals

- No behaviour change to the agent loop (dart_agent_core, tool gateway, receipts, plugin pinning).
- No new tools, no sub-agent wiring in production (still unwired today).
- Local on-device inference does **not** move off the main isolate.
- Renaming `app_bloc/chat` (`chat_bloc`) and `ChatBloc` *(call: kept to bound churn; follow-up)*.

## 4. Invariants that must survive

- **Acknowledged persistence**: `ModelTurnCompletedEvent` / `ToolCallCompletedEvent` are persisted by the main isolate before the agent continues (ack round-trip across isolates; reject → run fails).
- Per-run cancellation; stale events dropped; per-conversation task serialization in `ChatBloc`.
- Local model: single FIFO `LocalModelAccess` lease, held on the main isolate.
- Credentials never written to logs; logging never throws into producers; app works if the log store fails to start.

## 5. Architecture

```mermaid
flowchart LR
  subgraph Main isolate
    UI[Agents UI / ChatBloc] --> Host[AgentHost]
    Host --> Hub[IsolateHub]
    Svc[AgentServicesServer\nvault, tool data, MCP profiles,\nlocal LLM proxy] 
    Gemma[GemmaRepository + LocalModelAccess] --> Svc
    LC[Log Center] --> LSC[LogStoreClient]
  end
  Hub --> A1[agent:<id> isolate\nChatAgentRuntime + ToolExecutor\n+ RemoteLlmRepository]
  Hub --> LS[logstore isolate\nDuckDB]
  A1 -- services port --> Svc
  A1 -- run events / acks --> Host
  A1 -- log ingest port --> LS
  UI -. LogCapture/Logger.root .-> LS
  LSC -- call --> LS
```

- **Hub bootstrap** *(call)*: one `IsolateHub` created in `lib/main.dart`, started before `runApp`, provided via `MainProvider`; stopped on exit after log flush.
- **Streaming** *(call)*: the orchestrator has no streaming replies and workers cannot call the main isolate. Run events flow over a `SendPort` passed in the `StartRun` request; the main→worker direction uses `hub.cast` (ack, cancel). Worker→main services use a `servicesPort` passed in spawn config with a request/reply envelope (`{id, op, args}` → `{id, ok, value | error}`) and a stream variant for local LLM chunks.
- **Wire format**: plain maps/lists/primitives only. Events, messages, ModelConfig, agent definitions get `toWire`/`fromWire` codecs. `Completer`/exceptions never cross; acks are `{runId, ackId, ok, error?}`.
- **Secrets**: the remote API key is resolved on the main isolate and sent in `StartRun` *(call: avoids a vault round-trip per request)*; tool secrets go through `servicesPort` `secret.read`.
- **Logging**: in agent isolates, `LogCapture.instance.attach(PortLogSink(ingestPort))` and the orchestrator `IsolateLogBridge` (`loggerPort` = log store ingest) forward records. The main isolate does the same. The `logstore` worker batches into DuckDB with the existing `BatchBuffer`.
- **Failure**: agent isolate crash → in-flight runs end with `AgentRunFailedEvent` (host detects `IsolateFailed`/`IsolateStopped` or a run watchdog); log store failure → producers drop records silently (stderr), Log Center shows an error.

## 6. Left to the builder

Exact wire class names, the services op list (derived from the actual DB/vault call sites in `ToolExecutor`, `RemoteLlmRepository`, `BackplaneServiceRepository`), idle timer implementation, UI layout details within §2.6, test harness for real isolates.
