import 'dart:async';
import 'dart:isolate';

import 'package:app_database/app_database.dart';

import '../models/inference.dart';
import '../models/message.dart';
import '../models/model_config.dart';
import '../models/wire_codecs.dart';
import '../services/local_llm_gateway.dart';
import '../services/secret_reader.dart';
import '../services/tool_data_source.dart';
import 'services_protocol.dart';
import 'wire.dart' show RemoteAgentError;

/// Agent-isolate side of the services bridge. Forwards every call to the
/// `AgentServicesServer` behind [serverPort].
///
/// Unary calls time out after [timeout]; generation streams have no total
/// timeout and send a cancel when their subscription is cancelled. Server
/// errors are thrown as [RemoteAgentError]. Call [close] when done.
class AgentServicesClient
    implements SecretReader, ToolDataSource, LocalLlmGateway {
  AgentServicesClient(
    SendPort serverPort, {
    this.timeout = const Duration(seconds: 30),
  }) : _server = serverPort {
    _port.listen(_onMessage);
  }

  final SendPort _server;
  final Duration timeout;
  final _port = ReceivePort('agent-services-client');
  final _unary = <int, Completer<Object?>>{};
  final _streams = <int, StreamController<ChatGenerationChunk>>{};
  var _nextId = 0;
  bool _closed = false;

  /// Fails pending calls and releases the reply port.
  void close() {
    _port.close();
    _shutDown();
  }

  RemoteAgentError get _closedError => const RemoteAgentError(
    type: servicesClosedType,
    message: 'Agent services bridge is closed',
  );

  void _shutDown() {
    _closed = true;
    final unary = _unary.values.toList();
    final streams = _streams.values.toList();
    _unary.clear();
    _streams.clear();
    for (final c in unary) {
      c.completeError(_closedError);
    }
    for (final s in streams) {
      s.addError(_closedError);
      s.close();
    }
  }

  void _onMessage(Object? raw) {
    if (raw is! Map) return;
    final m = raw.cast<String, Object?>();
    if (m['closed'] == true) return _shutDown();
    final id = m['id'];
    if (id is! int) return;
    if (m.containsKey('ok')) {
      final c = _unary.remove(id);
      if (c == null) return;
      if (m['ok'] == true) {
        c.complete(m['value']);
      } else {
        c.completeError(_remoteError(m['error']));
      }
      return;
    }
    final s = _streams[id];
    if (s == null) return;
    if (m.containsKey('chunk')) {
      s.add(chatGenerationChunkFromWire((m['chunk'] as Map).cast()));
    } else if (m.containsKey('error')) {
      _streams.remove(id);
      s.addError(_remoteError(m['error']));
      s.close();
    } else if (m['done'] == true) {
      _streams.remove(id);
      s.close();
    }
  }

  RemoteAgentError _remoteError(Object? e) {
    final m = (e as Map).cast<String, Object?>();
    return RemoteAgentError(
      type: m['type'] as String,
      message: m['message'] as String,
    );
  }

  Future<Object?> _call(String op, [Map<String, Object?> args = const {}]) {
    if (_closed) return Future.error(_closedError);
    final id = _nextId++;
    final completer = Completer<Object?>();
    _unary[id] = completer;
    _server.send({'id': id, 'op': op, 'args': args, 'reply': _port.sendPort});
    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _unary.remove(id);
        throw TimeoutException('Agent services call $op timed out', timeout);
      },
    );
  }

  static Map<String, dynamic> _json(Object? v) =>
      Map<String, dynamic>.from(v as Map);

  static List<DnsZoneTableData> _zones(Object? v) => [
    for (final z in v as List) DnsZoneTableData.fromJson(_json(z)),
  ];

  @override
  Future<String?> read(String key) async =>
      await _call(opSecretsRead, {'key': key}) as String?;

  @override
  Future<List<DnsZoneTableData>> listDnsZones() async =>
      _zones(await _call(opListDnsZones));

  @override
  Future<List<DnsZoneTableData>> findDnsZones({
    int? localZoneId,
    String? zoneId,
    String? zoneName,
    String? provider,
  }) async => _zones(
    await _call(opFindDnsZones, {
      'localZoneId': localZoneId,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'provider': provider,
    }),
  );

  @override
  Future<ServiceAccountTableData?> serviceAccountById(int id) async {
    final v = await _call(opServiceAccountById, {'id': id});
    return v == null ? null : ServiceAccountTableData.fromJson(_json(v));
  }

  @override
  Future<List<ServiceAccountTableData>> serviceAccountsByProvider(
    ServiceProvider provider, {
    int? id,
  }) async {
    final v = await _call(opServiceAccountsByProvider, {
      'provider': provider.name,
      'id': id,
    });
    return [
      for (final a in v as List) ServiceAccountTableData.fromJson(_json(a)),
    ];
  }

  @override
  Future<void> stop() async {
    await _call(opLocalLlmStop);
  }

  @override
  Stream<ChatGenerationChunk> generate(
    List<Message> messages, {
    required ModelConfig config,
    List<Map<String, dynamic>> tools = const [],
  }) {
    late final StreamController<ChatGenerationChunk> controller;
    int? id;
    controller = StreamController<ChatGenerationChunk>(
      onListen: () {
        if (_closed) {
          controller.addError(_closedError);
          controller.close();
          return;
        }
        final requestId = id = _nextId++;
        _streams[requestId] = controller;
        _server.send({
          'id': requestId,
          'op': opLocalLlmGenerate,
          'args': {
            'messages': [for (final m in messages) m.toWire()],
            'config': config.toWire(),
            'tools': tools,
          },
          'reply': _port.sendPort,
        });
      },
      onCancel: () {
        final requestId = id;
        if (requestId == null || _streams.remove(requestId) == null) return;
        if (!_closed) {
          _server.send({
            'id': requestId,
            'op': opCancel,
            'reply': _port.sendPort,
          });
        }
      },
    );
    return controller.stream;
  }
}
