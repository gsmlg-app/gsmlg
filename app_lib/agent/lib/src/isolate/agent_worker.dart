import 'dart:async';
import 'dart:isolate';

import 'package:app_logging/app_logging.dart' show LogCapture, PortLogSink;
import 'package:dio/dio.dart' show CancelToken;
import 'package:http/http.dart' as http;
import 'package:isolate_orchestrator/isolate_orchestrator.dart';

import '../agent/agent_event.dart';
import '../agent/chat_agent_runtime.dart';
import '../repositories/remote_llm_repository.dart';
import '../services/secret_reader.dart';
import '../services/tool_executor.dart';
import 'services_client.dart';
import 'wire.dart';

/// Ops of the host <-> agent worker messages. `start` is a `hub.call`
/// (`{op, run: StartRun}` -> `{accepted: true}`); `ack` (`{op, ack: RunAck}`)
/// and `cancel` (`{op, cancel: CancelRun}`) are casts.
const agentOpStart = 'start';
const agentOpAck = 'ack';
const agentOpCancel = 'cancel';

/// Error type of a run whose acknowledgement the main isolate rejected.
const ackRejectedErrorType = 'AcknowledgementRejected';

/// Entry point of an agent isolate (`agent:<agentDefinitionId>`).
///
/// Spawn config: `servicesPort` (AgentServicesServer), `logIngest` (log store
/// ingest port or null), `loggerPort` (same port, for `Logger.root`), and
/// informational `agentId`/`definition`. Runs never use cached definition
/// data: every [StartRun] carries its own config.
@pragma('vm:entry-point')
void agentEntryPoint(SendPort hubPort) =>
    runWorker<Object?>(hubPort, AgentWorker.new);

/// Runs [ChatAgentRuntime] turns for one agent definition inside its isolate.
class AgentWorker extends Worker<Object?> with WorkerMetricsMixin<Object?> {
  AgentWorker(this.context);

  @override
  final WorkerContext context;

  late final AgentServicesClient _services;
  final http.Client _http = http.Client();
  final _runs = <String, _WorkerRun>{};

  @override
  Future<void> onInit(Map<String, dynamic> config) async {
    initMetrics();
    _services = AgentServicesClient(config['servicesPort'] as SendPort);
    final ingest = config['logIngest'] as SendPort?;
    if (ingest != null) LogCapture.instance.attach(PortLogSink(ingest));
  }

  @override
  Future<Object?> onTask(
    Object? data, {
    String? taskType,
    Map<String, dynamic>? metadata,
  }) => throw UnsupportedError('AgentWorker accepts calls and casts only');

  @override
  Future<Object?> onCall(
    Object? request, {
    required IsolateAddress sender,
    Map<String, dynamic>? metadata,
  }) async {
    final m = _asMap(request);
    if (m['op'] != agentOpStart) {
      throw ArgumentError('Unknown agent call op: ${m['op']}');
    }
    _start(StartRun.fromWire(_asMap(m['run'])));
    return const {'accepted': true};
  }

  @override
  Future<void> onCast(
    Object? message, {
    required IsolateAddress sender,
    Map<String, dynamic>? metadata,
  }) async {
    final m = _asMap(message);
    switch (m['op']) {
      case agentOpAck:
        _onAck(RunAck.fromWire(_asMap(m['ack'])));
      case agentOpCancel:
        _runs[CancelRun.fromWire(_asMap(m['cancel'])).runId]?.cancel();
    }
  }

  @override
  Future<void> onShutdown() async {
    for (final run in _runs.values.toList()) {
      run.cancel();
    }
    _runs.clear();
    _services.close();
    _http.close();
    LogCapture.instance.attach(null);
  }

  void _start(StartRun start) {
    if (_runs.containsKey(start.runId)) {
      throw StateError('Run ${start.runId} is already active');
    }
    final config = start.modelConfig;
    final remote = RemoteLlmRepository(
      secrets: _RunSecrets(
        key: config.remoteAccountId == null
            ? null
            : RemoteLlmRepository.accountSecretKey(config.remoteAccountId!),
        apiKey: start.apiKey,
        fallback: _services,
      ),
      client: _http,
    );
    final run = _WorkerRun(start, remote);
    _runs[start.runId] = run;
    try {
      _run(run);
    } catch (_) {
      _runs.remove(start.runId);
      unawaited(remote.dispose());
      rethrow;
    }
  }

  void _run(_WorkerRun run) {
    final start = run.start;
    final config = start.modelConfig;

    final runtime = ChatAgentRuntime(
      toolExecutor: ToolExecutor(
        data: _services,
        secrets: _services,
        remoteMcpProfilesProvider: () => start.mcpProfiles,
      ),
      remoteRepository: run.remote,
      // The bridge leases the local model on the main isolate.
      localLlm: _services,
      awaitAcknowledgements: true,
    );
    runtime
        .runStream(
          runId: start.runId,
          sessionId: start.sessionId,
          generationId: start.generationId,
          modelConfig: config,
          historyMessages: start.history,
          userPrompt: start.userPrompt.content,
          cancelToken: run.cancelToken,
          maxTurns: start.maxTurns,
          allowedTools: start.allowedTools?.toSet(),
        )
        .listen((event) => _forward(run, event), onDone: () => _end(run));
  }

  void _forward(_WorkerRun run, ChatAgentEvent event) {
    final terminal = _isTerminal(event);
    final failure = run.failure;
    if (failure != null) {
      // After a rejected ack only the (failed) terminal event is sent.
      if (!terminal) {
        _acknowledgementOf(event)?.complete();
        return;
      }
      event = AgentRunFailedEvent(
        runId: event.runId,
        sessionId: event.sessionId,
        error: failure,
      );
    }

    String? ackId;
    final ack = _acknowledgementOf(event);
    if (ack != null) {
      if (run.cancelled) {
        // A stop never waits for persistence.
        ack.complete();
      } else {
        ackId = '${run.nextAckId++}';
        run.acks[ackId] = ack;
      }
    }

    try {
      run.start.eventsPort.send(agentEventToWire(event, ackId: ackId));
    } catch (error) {
      run.acks.remove(ackId);
      if (ack != null && !ack.isCompleted) ack.complete();
      if (terminal) {
        run.start.eventsPort.send(
          agentEventToWire(
            AgentRunFailedEvent(
              runId: event.runId,
              sessionId: event.sessionId,
              error: RemoteAgentError(
                type: 'AgentWireError',
                message: error.toString(),
              ),
            ),
          ),
        );
      } else {
        run.fail(
          RemoteAgentError(type: 'AgentWireError', message: error.toString()),
        );
      }
    }
    if (terminal) _end(run);
  }

  void _onAck(RunAck ack) {
    final run = _runs[ack.runId];
    final completer = run?.acks.remove(ack.ackId);
    if (run == null || completer == null || completer.isCompleted) return;
    if (ack.ok) {
      completer.complete();
      return;
    }
    final error = RemoteAgentError(
      type: ackRejectedErrorType,
      message: ack.error ?? 'Acknowledgement rejected',
    );
    run.fail(error);
    completer.future.ignore();
    completer.completeError(error);
  }

  void _end(_WorkerRun run) {
    if (!identical(_runs[run.start.runId], run)) return;
    _runs.remove(run.start.runId);
    for (final ack in run.acks.values) {
      if (!ack.isCompleted) ack.complete();
    }
    run.acks.clear();
    unawaited(run.remote.dispose());
  }
}

class _WorkerRun {
  _WorkerRun(this.start, this.remote);

  final StartRun start;
  final RemoteLlmRepository remote;
  final cancelToken = CancelToken();
  final acks = <String, Completer<void>>{};
  int nextAckId = 0;
  bool cancelled = false;
  RemoteAgentError? failure;

  void _abort(String reason) {
    if (!cancelToken.isCancelled) cancelToken.cancel(reason);
    unawaited(remote.stopGeneration());
  }

  /// Fails the run: it is cancelled and ends with [AgentRunFailedEvent].
  void fail(RemoteAgentError error) {
    failure ??= error;
    _abort(error.message);
  }

  /// Cancels the run; pending acks are released so nothing waits on them.
  void cancel() {
    cancelled = true;
    _abort('Cancelled by user');
    for (final ack in acks.values) {
      if (!ack.isCompleted) ack.complete();
    }
    acks.clear();
  }
}

/// Serves the run's API key (resolved on the main isolate) for its account
/// and falls back to the services bridge for every other secret.
class _RunSecrets implements SecretReader {
  _RunSecrets({
    required this.key,
    required this.apiKey,
    required this.fallback,
  });

  final String? key;
  final String? apiKey;
  final SecretReader fallback;

  @override
  Future<String?> read(String key) {
    final apiKey = this.apiKey;
    if (key == this.key && apiKey != null) return Future.value(apiKey);
    return fallback.read(key);
  }
}

Completer<void>? _acknowledgementOf(ChatAgentEvent event) => switch (event) {
  ModelTurnCompletedEvent(:final acknowledgement) ||
  ToolCallCompletedEvent(:final acknowledgement) => acknowledgement,
  _ => null,
};

bool _isTerminal(ChatAgentEvent event) =>
    event is AgentRunCompletedEvent ||
    event is AgentRunFailedEvent ||
    event is AgentRunCancelledEvent;

Map<String, Object?> _asMap(Object? v) => (v as Map).cast<String, Object?>();
