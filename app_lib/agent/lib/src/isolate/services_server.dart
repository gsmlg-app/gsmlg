import 'dart:async';
import 'dart:isolate';

import 'package:app_database/app_database.dart' show ServiceProvider;

import '../models/inference.dart';
import '../models/wire_codecs.dart';
import '../services/local_llm_gateway.dart';
import '../services/secret_reader.dart';
import '../services/tool_data_source.dart';
import 'services_protocol.dart';

/// Main-isolate side of the services bridge: serves [SecretReader],
/// [ToolDataSource] and [LocalLlmGateway] requests from agent isolates that
/// hold an `AgentServicesClient` built from [port].
class AgentServicesServer {
  AgentServicesServer({
    required SecretReader secrets,
    required ToolDataSource data,
    required LocalLlmGateway localLlm,
  }) : _secrets = secrets,
       _data = data,
       _localLlm = localLlm {
    _port.listen(_onMessage);
  }

  final SecretReader _secrets;
  final ToolDataSource _data;
  final LocalLlmGateway _localLlm;
  final _port = ReceivePort('agent-services');
  final _clients = <SendPort>{};
  final _streams = <(SendPort, int), StreamSubscription<ChatGenerationChunk>>{};
  bool _closed = false;

  SendPort get port => _port.sendPort;

  /// Stops serving: cancels active generations and tells every client that
  /// has called in to fail its pending and future requests.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _port.close();
    final subs = _streams.values.toList();
    _streams.clear();
    for (final client in _clients) {
      client.send(const {'closed': true});
    }
    _clients.clear();
    await Future.wait([for (final s in subs) s.cancel()]);
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
        _streams.remove((reply, id))?.cancel();
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
      default:
        throw ArgumentError('Unknown agent services op: $op');
    }
  }

  void _generate(SendPort reply, int id, Map<String, Object?> a) {
    final key = (reply, id);
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
      );
      _streams[key] = stream.listen(
        (chunk) => _send(reply, {'id': id, 'chunk': chunk.toWire()}),
        onError: (Object e) {
          _streams.remove(key);
          _send(reply, {'id': id, 'error': errorToWire(e)});
        },
        onDone: () {
          _streams.remove(key);
          _send(reply, {'id': id, 'done': true});
        },
        cancelOnError: true,
      );
    } catch (e) {
      _send(reply, {'id': id, 'error': errorToWire(e)});
    }
  }
}
