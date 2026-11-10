import 'dart:async';
import 'dart:isolate';

import 'package:dio/dio.dart' show CancelToken;
import 'package:isolate_orchestrator/isolate_orchestrator.dart';

import '../agent/agent_event.dart';
import '../agent/agent_runner.dart';
import '../models/agent_definition.dart';
import '../models/inference.dart';
import '../models/message.dart';
import '../models/model_config.dart';
import '../repositories/remote_llm_repository.dart';
import '../services/secret_reader.dart';
import 'agent_worker.dart';
import 'services_server.dart';
import 'wire.dart';

/// Error type of runs whose agent isolate failed, stopped or restarted.
const agentIsolateLostErrorType = 'AgentIsolateLost';

/// Runs each agent definition in its own long-lived isolate
/// (`/agents/agent:<id>`, restart type transient) and streams run events
/// back on the main isolate.
///
/// Workers are spawned on first use and removed after [idleTimeout] without
/// runs. Acknowledgements of [ModelTurnCompletedEvent] and
/// [ToolCallCompletedEvent] are relayed to the worker, which waits for them
/// before continuing; an ack missing for [ackTimeout] fails the run
/// ([ackTimeoutErrorType]). A worker that fails, stops or restarts during a run
/// ends that run with [AgentRunFailedEvent] ([agentIsolateLostErrorType]).
///
/// Workers log to the current log store ingest port: [logIngest] initially,
/// then each value of `logIngestChanges` (the log store restarted), which is
/// sent to live workers and used for later spawns.
class AgentHost implements AgentRunner {
  AgentHost({
    required IsolateHub hub,
    required AgentServicesServer services,
    required SendPort? logIngest,
    required Future<AgentDefinition?> Function(String id) loadDefinition,
    required SecretReader secrets,
    List<String> Function()? mcpProfiles,
    Stream<SendPort?>? logIngestChanges,
    this.ackTimeout = const Duration(seconds: 90),
    this.idleTimeout = const Duration(minutes: 10),
    this.startTimeout = const Duration(seconds: 10),
    this.stopTimeout = const Duration(seconds: 5),
  }) : _hub = hub,
       _services = services,
       _logIngest = logIngest,
       _loadDefinition = loadDefinition,
       _secrets = secrets,
       _mcpProfiles = mcpProfiles {
    _hubEvents = hub.events.listen(_onHubEvent);
    _logIngestChanges = logIngestChanges?.listen(_onLogIngest);
  }

  static const groupName = 'agents';
  static const groupPath = '/agents';
  static const workerRole = 'agent';

  /// Supervision-tree name of the worker for [agentId].
  static String workerName(String agentId) => 'agent:$agentId';

  final IsolateHub _hub;
  final AgentServicesServer _services;
  SendPort? _logIngest;
  final Future<AgentDefinition?> Function(String id) _loadDefinition;
  final SecretReader _secrets;

  /// Remote MCP profiles (JSON strings) sent with every run.
  final List<String> Function()? _mcpProfiles;

  /// A run whose event is not acknowledged within this time fails.
  final Duration ackTimeout;

  /// A worker without runs for this long is stopped.
  final Duration idleTimeout;

  /// Bound on spawning a worker and on the worker accepting a run.
  final Duration startTimeout;

  /// After [stop], a run that has not ended within this time ends cancelled.
  final Duration stopTimeout;

  late final StreamSubscription<HubEvent> _hubEvents;
  StreamSubscription<SendPort?>? _logIngestChanges;
  final _runs = <String, _HostRun>{};
  final _workers = <String, _WorkerSlot>{};
  Future<void>? _group;
  bool _disposed = false;

  @override
  Stream<ChatAgentEvent> runStream({
    required String agentId,
    required String runId,
    required String sessionId,
    String? generationId,
    required ModelConfig modelConfig,
    required List<Message> historyMessages,
    required String userPrompt,
    CancelToken? cancelToken,
    int maxTurns = 25,
    Set<String>? allowedTools,
    void Function()? onFirstToken,
  }) {
    if (_disposed || _runs.containsKey(runId)) {
      return Stream.value(
        AgentRunFailedEvent(
          runId: runId,
          sessionId: sessionId,
          error: StateError(
            _disposed ? 'AgentHost is disposed' : 'Run $runId is active',
          ),
        ),
      );
    }
    final slot = _workers.putIfAbsent(agentId, () => _WorkerSlot(agentId));
    final run = _HostRun(
      agentId: agentId,
      runId: runId,
      sessionId: sessionId,
      local: modelConfig.inferenceMode == ChatInferenceMode.local,
      onFirstToken: onFirstToken,
    );
    run.controller = StreamController<ChatAgentEvent>(
      onCancel: () {
        run.detached = true;
        unawaited(stop(runId));
      },
    );
    _runs[runId] = run;
    slot.runs.add(runId);
    slot.idleTimer?.cancel();
    if (cancelToken != null) {
      unawaited(cancelToken.whenCancel.then((_) => stop(runId)));
    }

    unawaited(
      _start(
        run,
        slot,
        generationId: generationId ?? runId,
        modelConfig: modelConfig,
        history: historyMessages,
        userPrompt: userPrompt,
        maxTurns: maxTurns,
        allowedTools: allowedTools,
      ),
    );
    return run.controller.stream;
  }

  @override
  Future<void> stop(String runId) async {
    final run = _runs[runId];
    if (run == null || run.cancelRequested) return;
    run.cancelRequested = true;
    // Before the worker accepted the run, _start ends it.
    if (run.accepted) _sendCancel(run);
  }

  /// Fails active runs and stops all agent workers.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _hubEvents.cancel();
    await _logIngestChanges?.cancel();
    for (final run in _runs.values.toList()) {
      _fail(
        run,
        const RemoteAgentError(
          type: 'AgentHostDisposed',
          message: 'Agent host disposed',
        ),
      );
    }
    for (final slot in _workers.values) {
      slot.idleTimer?.cancel();
      try {
        await _hub.removeNode(workerName(slot.agentId));
      } catch (_) {
        // Not spawned, or the hub is already stopped.
      }
    }
    _workers.clear();
  }

  Future<void> _start(
    _HostRun run,
    _WorkerSlot slot, {
    required String generationId,
    required ModelConfig modelConfig,
    required List<Message> history,
    required String userPrompt,
    required int maxTurns,
    required Set<String>? allowedTools,
  }) async {
    bool stopped() {
      if (run.done) return true;
      if (!run.cancelRequested) return false;
      _finish(
        run,
        AgentRunCancelledEvent(
          runId: run.runId,
          sessionId: run.sessionId,
          reason: 'Stopped before start',
        ),
      );
      return true;
    }

    try {
      final apiKey = await _apiKey(modelConfig);
      if (stopped()) return;
      final handle = await _ensureWorker(slot).timeout(startTimeout);
      if (stopped()) return;

      final port = ReceivePort();
      run.port = port;
      run.isolateId = handle.id;
      port.listen((message) => _onWire(run, message));

      final start = StartRun(
        runId: run.runId,
        sessionId: run.sessionId,
        generationId: generationId,
        history: history,
        userPrompt: UserMessage(
          id: '${run.runId}:prompt',
          content: userPrompt,
          conversationId: run.sessionId,
          timestamp: DateTime.now(),
        ),
        modelConfig: modelConfig,
        apiKey: apiKey,
        allowedTools: allowedTools?.toList(),
        maxTurns: maxTurns,
        mcpProfiles: _mcpProfiles?.call() ?? const [],
        eventsPort: port.sendPort,
      );
      await _hub.call<Object?>(handle.id, {
        'op': agentOpStart,
        'run': start.toWire(),
      }, timeout: startTimeout);
      if (run.done) return;
      run.accepted = true;
      if (run.cancelRequested) _sendCancel(run);
    } catch (error, stackTrace) {
      _fail(
        run,
        RemoteAgentError(
          type: switch (error) {
            final RemoteAgentError r => r.type,
            final other => other.runtimeType.toString(),
          },
          message: 'Agent run could not start: $error',
        ),
        stackTrace,
      );
    }
  }

  /// Spawns the worker for [slot] unless it runs; serialized per agent.
  Future<IsolateHandle> _ensureWorker(_WorkerSlot slot) {
    final result = slot.lock.then((_) => _spawnIfNeeded(slot));
    slot.lock = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<IsolateHandle> _spawnIfNeeded(_WorkerSlot slot) async {
    final name = workerName(slot.agentId);
    final node = _hub.lookupNode(name);
    if (node is IsolateNode &&
        (node.state == NodeState.starting ||
            node.state == NodeState.restarting)) {
      // The supervisor is (re)starting it; spawning now would race it.
      await _hub.events
          .where(
            (e) =>
                e is NodeStateChanged &&
                e.path == node.path &&
                e.state != NodeState.starting &&
                e.state != NodeState.restarting,
          )
          .first
          .timeout(startTimeout);
    }
    final running = _hub.getByName(name);
    if (running != null && running.state == IsolateState.running) {
      slot.isolateId = running.id;
      return running;
    }

    await (_group ??= _createGroup());
    AgentDefinition? definition;
    try {
      definition = await _loadDefinition(slot.agentId);
    } catch (_) {
      // Informational only; runs carry their own config.
    }
    final logIngest = _logIngest;
    final handle = await _hub.spawn<Object?>(
      role: workerRole,
      name: name,
      entryPoint: agentEntryPoint,
      parentPath: groupPath,
      restartType: ChildRestartType.transient,
      config: {
        'agentId': slot.agentId,
        'definition': definition?.toWire(),
        'servicesPort': _services.port,
        // The worker installs its own re-pointable Logger.root bridge, so no
        // orchestrator `loggerPort`.
        'logIngest': logIngest,
        'ackTimeoutMs': ackTimeout.inMilliseconds,
      },
    );
    slot.isolateId = handle.id;
    // The port changed while spawning.
    if (_logIngest != logIngest) _sendLogPort(handle.id, _logIngest);
    return handle;
  }

  Future<void> _createGroup() async {
    try {
      await _hub.createGroup(
        name: groupName,
        // A failing group never escalates to the root (and the log store).
        restartType: ChildRestartType.temporary,
      );
    } catch (_) {
      _group = null;
      rethrow;
    }
  }

  Future<String?> _apiKey(ModelConfig config) async {
    final accountId = config.remoteAccountId;
    if (config.inferenceMode != ChatInferenceMode.remote ||
        config.remoteUsesDummyToken ||
        accountId == null) {
      return null;
    }
    try {
      return await _secrets.read(
        RemoteLlmRepository.accountSecretKey(accountId),
      );
    } catch (_) {
      // The worker falls back to the services bridge, which reports the error.
      return null;
    }
  }

  void _onWire(_HostRun run, Object? message) {
    if (run.done) return;
    try {
      final m = (message as Map).cast<String, Object?>();
      final ackId = m['ackId'] as String?;
      Completer<void>? ack;
      if (ackId != null) {
        ack = Completer<void>();
        ack.future.then(
          (_) => _sendAck(run, ackId, ok: true),
          onError: (Object error) =>
              _sendAck(run, ackId, ok: false, error: error.toString()),
        );
      }
      final event = agentEventFromWire(m, acknowledgement: ack);
      if (run.detached) ack?.complete();

      if (!run.firstToken &&
          event is ModelChunkReceivedEvent &&
          ((event.textChunk?.isNotEmpty ?? false) ||
              (event.thoughtChunk?.isNotEmpty ?? false))) {
        run.firstToken = true;
        try {
          run.onFirstToken?.call();
        } catch (_) {}
      }

      if (event is AgentRunCompletedEvent ||
          event is AgentRunFailedEvent ||
          event is AgentRunCancelledEvent) {
        _finish(run, event);
      } else if (!run.detached) {
        run.controller.add(event);
      }
    } catch (error, stackTrace) {
      _fail(
        run,
        RemoteAgentError(type: 'AgentWireError', message: error.toString()),
        stackTrace,
      );
    }
  }

  void _sendAck(_HostRun run, String ackId, {required bool ok, String? error}) {
    final isolateId = run.isolateId;
    if (isolateId == null) return;
    final ack = RunAck(runId: run.runId, ackId: ackId, ok: ok, error: error);
    try {
      _hub.cast(isolateId, {'op': agentOpAck, 'ack': ack.toWire()});
    } catch (_) {
      // Worker gone; the run is failed through the hub events.
    }
  }

  void _sendCancel(_HostRun run) {
    final isolateId = run.isolateId;
    try {
      if (isolateId == null) throw StateError('no worker');
      _hub.cast(isolateId, {
        'op': agentOpCancel,
        'cancel': CancelRun(runId: run.runId).toWire(),
      });
    } catch (_) {
      _finish(
        run,
        AgentRunCancelledEvent(
          runId: run.runId,
          sessionId: run.sessionId,
          reason: 'Stopped; agent isolate unavailable',
        ),
      );
      return;
    }
    run.stopTimer ??= Timer(stopTimeout, () {
      _finish(
        run,
        AgentRunCancelledEvent(
          runId: run.runId,
          sessionId: run.sessionId,
          reason: 'Stopped; agent isolate did not confirm',
        ),
      );
    });
  }

  void _onLogIngest(SendPort? port) {
    _logIngest = port;
    for (final slot in _workers.values) {
      final isolateId = slot.isolateId;
      if (isolateId != null) _sendLogPort(isolateId, port);
    }
  }

  void _sendLogPort(String isolateId, SendPort? port) {
    try {
      _hub.cast(isolateId, {'op': agentOpLogPort, 'port': port});
    } catch (_) {
      // Worker gone; a respawn uses the current port.
    }
  }

  void _onHubEvent(HubEvent event) {
    if (event is IsolateReady) {
      // A supervisor restart reuses the original spawn config, whose log port
      // may be stale.
      final name = event.handle.name;
      if (name.startsWith('$workerRole:')) {
        _sendLogPort(event.handle.id, _logIngest);
      }
      return;
    }
    final (isolateId, reason) = switch (event) {
      IsolateFailed(:final handle, :final error) => (handle.id, error),
      IsolateStopped(:final id) => (id, 'stopped'),
      IsolateRestarting(:final id) => (id, 'restarting'),
      _ => (null, ''),
    };
    if (isolateId == null) return;
    for (final slot in _workers.values) {
      if (slot.isolateId == isolateId) slot.isolateId = null;
    }
    var lostLocal = false;
    for (final run in _runs.values.toList()) {
      if (run.isolateId != isolateId) continue;
      lostLocal |= run.local;
      _fail(
        run,
        RemoteAgentError(
          type: agentIsolateLostErrorType,
          message: 'Agent isolate ${workerName(run.agentId)} lost: $reason',
        ),
      );
    }
    // The dead worker can no longer cancel its bridged local generation. Local
    // runs hold the single local slot, so every active stream is the lost one.
    if (lostLocal) unawaited(_services.cancelAllStreams());
  }

  void _fail(_HostRun run, RemoteAgentError error, [StackTrace? stackTrace]) {
    if (run.done) return;
    // Best effort: a worker that is still alive drops the run.
    final isolateId = run.isolateId;
    if (isolateId != null && run.accepted) {
      try {
        _hub.cast(isolateId, {
          'op': agentOpCancel,
          'cancel': CancelRun(runId: run.runId).toWire(),
        });
      } catch (_) {}
    }
    _finish(
      run,
      AgentRunFailedEvent(
        runId: run.runId,
        sessionId: run.sessionId,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  void _finish(_HostRun run, ChatAgentEvent terminal) {
    if (run.done) return;
    run.done = true;
    run.stopTimer?.cancel();
    run.port?.close();
    if (identical(_runs[run.runId], run)) _runs.remove(run.runId);
    if (!run.controller.isClosed) {
      if (!run.detached) run.controller.add(terminal);
      unawaited(run.controller.close());
    }
    final slot = _workers[run.agentId];
    if (slot == null) return;
    slot.runs.remove(run.runId);
    if (slot.runs.isEmpty && !_disposed) {
      slot.idleTimer?.cancel();
      slot.idleTimer = Timer(idleTimeout, () => _stopIdle(slot));
    }
  }

  void _stopIdle(_WorkerSlot slot) {
    final stopped = slot.lock.then((_) async {
      if (slot.runs.isNotEmpty || _disposed) return;
      slot.isolateId = null;
      try {
        await _hub.removeNode(workerName(slot.agentId));
      } catch (_) {
        // Already gone.
      }
    });
    slot.lock = stopped.then<void>((_) {}, onError: (_) {});
  }
}

class _WorkerSlot {
  _WorkerSlot(this.agentId);

  final String agentId;
  final runs = <String>{};

  /// Serializes spawn and idle stop.
  Future<void> lock = Future.value();
  String? isolateId;
  Timer? idleTimer;
}

class _HostRun {
  _HostRun({
    required this.agentId,
    required this.runId,
    required this.sessionId,
    required this.local,
    required this.onFirstToken,
  });

  final String agentId;
  final String runId;
  final String sessionId;

  /// Uses the main-isolate local model through the services bridge.
  final bool local;
  final void Function()? onFirstToken;
  late final StreamController<ChatAgentEvent> controller;
  ReceivePort? port;

  /// Isolate the run was started on; events of other isolates don't fail it.
  String? isolateId;
  Timer? stopTimer;
  bool accepted = false;
  bool cancelRequested = false;
  bool detached = false;
  bool firstToken = false;
  bool done = false;
}
