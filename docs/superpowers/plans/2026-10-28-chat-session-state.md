# Chat Session State Implementation Plan

**Goal:** Implement the approved session isolation design and update Pixel Fold 37011FDH8119SS.

**Architecture:** Keep ChatBloc as the application coordinator, with immutable session projections and private task resources keyed by conversation/run ID. Remote requests abort individually; local requests share a FIFO execution slot. UI binds drafts and settings to the selected session.

**Tech Stack:** Flutter, Dart, BLoC, existing http abortable requests, adb.

Work in the current checkout; preserve unrelated changes. No branches, worktrees, commits, or pushes. Run GitNexus impact before existing-symbol edits. Parallel ownership is disjoint; the coordinator owns integrated validation and installation.

## 1. Session coordinator

- Owner: session_core; files app_bloc/chat/lib/src/chat/* and app_bloc/chat/test/*.
- Preserve selected-session compatibility getters; add per-session state/drafts/configuration and explicit target IDs on public events.
- Replace single active stream with task resources, generation IDs, independent metrics, guarded asynchronous callbacks and local FIFO queue.
- Add regression tests for remote concurrency, cancellation, local ordering, duplicate sends, navigation, stale callbacks, errors and existing metrics.
- Run focused chat package tests and analysis.

## 2. Remote request cancellation

- Owner: remote_cancellation; files app_lib/chat/lib/src/repositories/remote_llm_repository.dart and focused repository tests.
- Add optional generationId to generateResponse and stopGeneration; use AbortableRequest with independently scoped abort triggers.
- Verify aborting A does not close B or the injected shared client, including before response headers arrive; clean up on completion/disposal.

## 3. Session UI

- Owner: coordinator; files lib/screens/chat/*, lib/duo/* and relevant UI tests only.
- Bind ChatInputBar to session drafts, including selection and attachment callbacks captured before async work.
- Use selected session settings without mutating global Agent activation. Target send/stop/edit/regenerate at explicit conversation IDs.
- Show Running/queued/error/stopped/draft/unread states in history, plus Running filter. Keep stable ordering while streaming.
- Explain stop-and-delete in destructive confirmations and prevent accidental cross-session actions.
- Validate draft switch/restore, Running display/filter, pending input and existing chat widgets; inspect integrated diff.

## 4. Delivery and verification

- Run changed-file formatting and analysis, chat package tests, repository request tests, chat widget and Duo coordination tests.
- Build Android APK using current signing configuration; inspect actual device/package compatibility and update with adb install -r, preserving data.
- Launch on Pixel Fold; verify state restoration, concurrent remote sessions, targeted stopping, list status and available display configurations. Report any unavailable physical posture or local-model checks explicitly.
- Update design status with actual implementation/verification limits. No automatic commit or push.


## Execution outcome

Implementation and automated checks completed: 62 chat_bloc + 79 app_chat + 51 chat/Duo UI + 4 local HTTP tests passed (196 total); one existing app_chat conditional test skipped. Scoped analysis and diff checks passed. Real HTTP cancellation-future failure found on Pixel Fold was reproduced in integration tests and repaired.

Pixel Fold arm64 release-mode build/install and remote/draft/list verification completed; final corrected build installed successfully, cold launched in 330ms, and physical Stop displays Stopped. Local FIFO device acceptance is blocked by the bundled lib_litert_lm 0.1.0 callback-after-delete native crash, tracked at gsmlg-app/lib_litert_lm#3. No vendored workaround or upstream code modification. Compact UI checked with state emulation and reset; physical folding not claimed. No commit/push.

Temporary remote/local test conversations were deleted individually after checks; persistent existing user conversations retained. Final device returned to its original conversation and OPENED state with no state override. No more model requests after user requested Max Agent only.
