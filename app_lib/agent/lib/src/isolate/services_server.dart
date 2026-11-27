import 'dart:async';
import 'dart:isolate';

import 'package:app_database/app_database.dart' show ServiceProvider;

import '../agent/memory_provider.dart';
import '../models/inference.dart';
import '../models/wire_codecs.dart';
import '../services/agent_session_store.dart';
import '../services/local_llm_gateway.dart';
import '../services/secret_reader.dart';
import '../services/tool_data_source.dart';
import 'services_protocol.dart';

/// Main-isolate side of the services bridge: serves [SecretReader],
/// [ToolDataSource], [AgentMemoryGateway], [AgentSessionStore] and
/// [LocalLlmGateway] requests from agent isolates that hold an
/// `AgentServicesClient` built from [port].
class AgentServicesServer {
  AgentServicesServer({
    required SecretReader secrets,
    required ToolDataSource data,
    required LocalLlmGateway localLlm,
    AgentMemoryGateway? memory,
    AgentSessionStore? sessionStore,
  }) : _secrets = secrets,
       _data = data,
       _localLlm = localLlm,
       _memory = memory,
       _sessionStore = sessionStore {
    _port.listen(_onMessage);
  }

  final SecretReader _secrets;
  final ToolDataSource _data;
  final LocalLlmGateway _localLlm;
  final AgentMemoryGateway? _memory;
  final AgentSessionStore? _sessionStore;
  final _port = ReceivePort('agent-services');
  final _clients = <SendPort>{};
  final _streams = <(SendPort, int), _ActiveLocalStream>{};
  Future<void> _localPermitTail = Future<void>.value();
  bool _closed = false;

  SendPort get port => _port.sendPort;

  /// Stops serving: cancels active generations and tells every client that
  /// has called in to fail its pending and future requests.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _port.close();
    final active = _streams.values.toList();
    _streams.clear();
    for (final client in _clients) {
      client.send(const {'closed': true});
    }
    _clients.clear();
    await Future.wait([for (final entry in active) entry.cancel()]);
  }

  /// Cancels every active local generation, e.g. after a worker died without
  /// a known run id.
  Future<void> cancelAllStreams() async {
    final active = _streams.values.toList();
    _streams.clear();
    await Future.wait([for (final entry in active) entry.cancel()]);
  }

  /// Cancels only active local generations belonging to [runIds] (or legacy
  /// streams without a runId), avoiding cancelling a healthy run that
  /// subsequently acquired the local model lease.
  Future<void> cancelStreamsForRuns(Set<String> runIds) async {
    if (runIds.isEmpty) return;
    final matchingKeys = <(SendPort, int)>[];
    for (final entry in _streams.entries) {
      final streamRunId = entry.value.runId;
      if (streamRunId == null || runIds.contains(streamRunId)) {
        matchingKeys.add(entry.key);
      }
    }
    final toCancel = <_ActiveLocalStream>[];
    for (final key in matchingKeys) {
      final stream = _streams.remove(key);
      if (stream != null) toCancel.add(stream);
    }
    await Future.wait([for (final entry in toCancel) entry.cancel()]);
  }

  void _onMessage(Object? raw) {
    if (raw is! Map) return;
    final m = raw.cast<String, Object?>();
    final reply = m['reply'];
    final id = m['id'];
    if (reply is! SendPort || id is! int) return;
    _clients.add(reply);
    final op = m['op'] as String?;
    final args = (m['args'] as Map?)?.cast<String, Object?>() ?? const {};
    switch (op) {
      case opCancel:
        unawaited(_streams.remove((reply, id))?.cancel());
      case opLocalLlmGenerate:
        _generate(reply, id, args);
      default:
        _unary(reply, id, op, args);
    }
  }

  void _send(SendPort reply, Map<String, Object?> message) {
    if (!_closed) reply.send(message);
  }

  Future<void> _unary(
    SendPort reply,
    int id,
    String? op,
    Map<String, Object?> args,
  ) async {
    Map<String, Object?> message;
    try {
      message = {'id': id, 'ok': true, 'value': await _dispatch(op, args)};
    } catch (e) {
      message = {'id': id, 'ok': false, 'error': errorToWire(e)};
    }
    _send(reply, message);
  }

  Future<Object?> _dispatch(String? op, Map<String, Object?> a) async {
    switch (op) {
      case opSecretsRead:
        return _secrets.read(a['key'] as String);
      case opListDnsZones:
        return [for (final z in await _data.listDnsZones()) z.toJson()];
      case opFindDnsZones:
        final zones = await _data.findDnsZones(
          localZoneId: a['localZoneId'] as int?,
          zoneId: a['zoneId'] as String?,
          zoneName: a['zoneName'] as String?,
          provider: a['provider'] as String?,
        );
        return [for (final z in zones) z.toJson()];
      case opServiceAccountById:
        return (await _data.serviceAccountById(a['id'] as int))?.toJson();
      case opServiceAccountsByProvider:
        final accounts = await _data.serviceAccountsByProvider(
          ServiceProvider.values.byName(a['provider'] as String),
          id: a['id'] as int?,
        );
        return [for (final s in accounts) s.toJson()];
      case opLocalLlmStop:
        await _localLlm.stop();
        return null;
      case opMemoryExecute:
        final memory = _memory;
        if (memory == null) {
          return {'error': 'Persistent memory service is not configured'};
        }
        return memory.executeMemoryTool(
          toolName: a['toolName'] as String,
          arguments: Map<String, dynamic>.from(a['arguments'] as Map),
          sessionId: a['sessionId'] as String,
          agentId: a['agentId'] as String?,
        );
      case opSessionLoadState:
        return _sessionStore?.loadAgentState(a['sessionId'] as String);
      case opSessionSaveState:
        final store = _sessionStore;
        if (store != null) {
          await store.saveAgentState(
            a['sessionId'] as String,
            a['stateJson'] as String,
          );
        }
        return null;
      case opSessionDeleteState:
        final store = _sessionStore;
        if (store != null) {
          await store.deleteAgentState(a['sessionId'] as String);
        }
        return null;
      case opSessionSaveMessage:
        final store = _sessionStore;
        if (store != null) {
          await store.saveMessage(
            messageFromWire((a['message'] as Map).cast<String, Object?>()),
          );
        }
        return null;
      case opSessionDeleteMessage:
        final store = _sessionStore;
        if (store != null) {
          await store.deleteMessage(a['id'] as String);
        }
        return null;
      case opSessionLoadMessages:
        final store = _sessionStore;
        if (store == null) return const <Object?>[];
        final messages = await store.loadMessages(a['sessionId'] as String);
        return [for (final m in messages) m.toWire()];
      default:
        throw ArgumentError('Unknown agent services op: $op');
    }
  }

  void _generate(SendPort reply, int id, Map<String, Object?> a) {
    final key = (reply, id);
    final runId = a['runId'] as String?;
    final entry = _ActiveLocalStream(runId: runId);
    _streams[key] = entry;
    // Acknowledge immediately so queued local sub-agent inferences don't hit
    // the client's first-response timeout while waiting for the inference slot.
    _send(reply, {'id': id, 'started': true});

    final previous = _localPermitTail;
    final permitDone = Completer<void>();
    _localPermitTail = permitDone.future;

    void finishPermit() {
      if (!permitDone.isCompleted) permitDone.complete();
    }

    entry.onCancelHook = finishPermit;

    unawaited(() async {
      await previous;
      if (_closed || entry.cancelled || !identical(_streams[key], entry)) {
        finishPermit();
        return;
      }
      try {
        final stream = _localLlm.generate(
          [
            for (final m in a['messages'] as List)
              messageFromWire((m as Map).cast()),
          ],
          config: modelConfigFromWire((a['config'] as Map).cast()),
          tools: [
            for (final t in a['tools'] as List)
              Map<String, dynamic>.from(t as Map),
          ],
          runId: runId,
        );
        if (_closed || entry.cancelled || !identical(_streams[key], entry)) {
          finishPermit();
          return;
        }
        entry.subscription = stream.listen(
          (chunk) => _send(reply, {'id': id, 'chunk': chunk.toWire()}),
          onError: (Object e) {
            _streams.remove(key);
            finishPermit();
            _send(reply, {'id': id, 'error': errorToWire(e)});
          },
          onDone: () {
            _streams.remove(key);
            finishPermit();
            _send(reply, {'id': id, 'done': true});
          },
          cancelOnError: true,
        );
      } catch (e) {
        _streams.remove(key);
        finishPermit();
        _send(reply, {'id': id, 'error': errorToWire(e)});
      }
    }());
  }
}

class _ActiveLocalStream {
  _ActiveLocalStream({this.runId});

  final String? runId;
  StreamSubscription<ChatGenerationChunk>? subscription;
  void Function()? onCancelHook;
  bool cancelled = false;

  Future<void> cancel() async {
    cancelled = true;
    final sub = subscription;
    subscription = null;
    if (sub != null) {
      await sub.cancel();
    }
    onCancelHook?.call();
  }
}
