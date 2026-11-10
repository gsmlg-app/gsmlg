import 'dart:async';
import 'dart:isolate';

import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Worker-side scenarios. Each runs in a spawned isolate, talks to the main
/// isolate only through [AgentServicesClient], and reports a plain map back.
Future<void> _worker(List<Object?> args) async {
  final serverPort = args[0] as SendPort;
  final out = args[1] as SendPort;
  final scenario = args[2] as String;
  final client = AgentServicesClient(
    serverPort,
    timeout: const Duration(milliseconds: 500),
  );
  Map<String, Object?> err(Object e) => {
    'errorClass': e.runtimeType.toString(),
    'type': e is RemoteAgentError ? e.type : null,
    'message': e.toString(),
  };
  final messages = [
    UserMessage(
      id: 'u',
      content: 'hi',
      conversationId: 'c',
      timestamp: DateTime.utc(2026),
    ),
  ];
  const config = ModelConfig(localModelId: 'local-model');
  try {
    switch (scenario) {
      case 'secrets':
        out.send({
          'present': await client.read('service_account_1'),
          'missing': await client.read('nope'),
        });
      case 'data':
        final zones = await client.listDnsZones();
        final found = await client.findDnsZones(zoneName: 'example.com');
        final none = await client.findDnsZones(
          zoneName: 'example.com',
          provider: 'route53',
        );
        final byId = await client.serviceAccountById(1);
        final missing = await client.serviceAccountById(999);
        final vultrAll = await client.serviceAccountsByProvider(
          ServiceProvider.vultr,
        );
        final vultrOne = await client.serviceAccountsByProvider(
          ServiceProvider.vultr,
          id: 2,
        );
        out.send({
          'zones': [for (final z in zones) z.zoneName],
          'foundProvider': found.single.provider.name,
          'foundAccount': found.single.serviceAccountId,
          'none': none.length,
          'byId': byId?.name,
          'missing': missing == null,
          'vultrAll': [for (final a in vultrAll) a.id],
          'vultrOne': [for (final a in vultrOne) a.id],
        });
      case 'generate':
        final chunks = await client
            .generate(
              messages,
              config: config,
              tools: const [
                {'name': 't'},
              ],
            )
            .toList();
        out.send({
          'chunks': [for (final c in chunks) c.toWire()],
        });
      case 'cancel':
        final first = await client.generate(messages, config: config).first;
        out.send({'first': first.toWire()});
      case 'streamError':
        try {
          await client.generate(messages, config: config).toList();
          out.send({'ok': true});
        } catch (e) {
          out.send(err(e));
        }
      case 'error':
        try {
          await client.read('boom');
          out.send({'ok': true});
        } catch (e) {
          out.send(err(e));
        }
      case 'stop':
        await client.stop();
        out.send({'ok': true});
      case 'closed':
        final pending = client
            .read('hang')
            .then<Object?>((v) => {'ok': true}, onError: (Object e) => err(e));
        final stream = client
            .generate(messages, config: config)
            .toList()
            .then<Object?>((v) => {'ok': true}, onError: (Object e) => err(e));
        out.send('requested');
        final results = await Future.wait([pending, stream]);
        Object? after;
        try {
          await client.read('service_account_1');
          after = {'ok': true};
        } catch (e) {
          after = err(e);
        }
        out.send({'unary': results[0], 'stream': results[1], 'after': after});
      case 'timeout':
        try {
          await client.read('hang');
          out.send({'ok': true});
        } catch (e) {
          out.send(err(e));
        }
    }
  } finally {
    client.close();
  }
}

class _Fixture {
  _Fixture._(this.database, this.vault, this.llm, this.server);

  static Future<_Fixture> create() async {
    _HangingSecrets.hanging = Completer<void>();
    final database = AppDatabase.forTesting();
    final vault = _MemoryVault();
    final llm = _FakeLocalLlm();
    final server = AgentServicesServer(
      secrets: _HangingSecrets(VaultSecretReader(vault)),
      data: DatabaseToolDataSource(database),
      localLlm: llm,
    );
    return _Fixture._(database, vault, llm, server);
  }

  final AppDatabase database;
  final _MemoryVault vault;
  final _FakeLocalLlm llm;
  final AgentServicesServer server;

  Future<void> dispose() async {
    await server.close();
    await database.close();
  }

  /// Spawns [scenario] and returns its messages.
  Future<StreamQueue> run(String scenario) async {
    final port = ReceivePort();
    await Isolate.spawn(_worker, [server.port, port.sendPort, scenario]);
    return StreamQueue(port);
  }
}

/// Minimal queue over a ReceivePort.
class StreamQueue {
  StreamQueue(this._port) {
    _port.listen((m) {
      if (_waiters.isNotEmpty) {
        _waiters.removeAt(0).complete(m);
      } else {
        _buffer.add(m);
      }
    });
  }

  final ReceivePort _port;
  final _buffer = <Object?>[];
  final _waiters = <Completer<Object?>>[];

  Future<Object?> next() {
    if (_buffer.isNotEmpty) return Future.value(_buffer.removeAt(0));
    final c = Completer<Object?>();
    _waiters.add(c);
    return c.future.timeout(const Duration(seconds: 10));
  }

  void close() => _port.close();
}

void main() {
  late _Fixture f;

  setUp(() async => f = await _Fixture.create());
  tearDown(() => f.dispose());

  test('secrets.read returns vault values through an isolate', () async {
    await f.vault.write(key: 'service_account_1', value: 'sk-1');
    final q = await f.run('secrets');
    expect(await q.next(), {'present': 'sk-1', 'missing': null});
    q.close();
  });

  test('ToolDataSource ops round-trip through an isolate', () async {
    final db = f.database;
    final a1 = await db
        .into(db.serviceAccountTable)
        .insert(
          ServiceAccountTableCompanion.insert(
            provider: ServiceProvider.cloudflare,
            name: 'cf',
          ),
        );
    final a2 = await db
        .into(db.serviceAccountTable)
        .insert(
          ServiceAccountTableCompanion.insert(
            provider: ServiceProvider.vultr,
            name: 'v2',
          ),
        );
    final a3 = await db
        .into(db.serviceAccountTable)
        .insert(
          ServiceAccountTableCompanion.insert(
            provider: ServiceProvider.vultr,
            name: 'v3',
          ),
        );
    expect([a1, a2, a3], [1, 2, 3]);
    await db
        .into(db.dnsZoneTable)
        .insert(
          DnsZoneTableCompanion.insert(
            provider: DnsProvider.cloudflare,
            zoneId: 'z1',
            zoneName: 'example.com',
            serviceAccountId: a1,
          ),
        );
    await db
        .into(db.dnsZoneTable)
        .insert(
          DnsZoneTableCompanion.insert(
            provider: DnsProvider.route53,
            zoneId: 'z2',
            zoneName: 'other.com',
            serviceAccountId: a1,
          ),
        );

    final q = await f.run('data');
    expect(await q.next(), {
      'zones': ['example.com', 'other.com'],
      'foundProvider': 'cloudflare',
      'foundAccount': 1,
      'none': 0,
      'byId': 'cf',
      'missing': true,
      'vultrAll': [2, 3],
      'vultrOne': [2],
    });
    q.close();
  });

  test('localLlm.generate streams chunks and forwards arguments', () async {
    f.llm.chunks = const [
      ChatThinkingChunk('hmm'),
      ChatTextChunk('hello'),
      ChatFunctionCallChunk(
        name: 'lookup',
        args: {
          'q': 'x',
          'n': [1, 2],
        },
        id: 'c1',
        index: 0,
      ),
    ];
    final q = await f.run('generate');
    final reply = (await q.next())! as Map;
    expect([
      for (final c in reply['chunks'] as List)
        chatGenerationChunkFromWire((c as Map).cast()),
    ], f.llm.chunks);
    expect(f.llm.lastMessages!.single.content, 'hi');
    expect(f.llm.lastConfig!.localModelId, 'local-model');
    expect(f.llm.lastTools, [
      {'name': 't'},
    ]);
    q.close();
  });

  test(
    'cancelling the client stream cancels the main-isolate stream',
    () async {
      f.llm.endless = true;
      final q = await f.run('cancel');
      expect(await q.next(), {'first': const ChatTextChunk('tick').toWire()});
      await f.llm.cancelled.future.timeout(const Duration(seconds: 5));
      q.close();
    },
  );

  test('server errors surface as RemoteAgentError with message', () async {
    final q = await f.run('error');
    expect(await q.next(), {
      'errorClass': 'RemoteAgentError',
      'type': 'StateError',
      'message': 'Bad state: vault exploded',
    });
    q.close();
  });

  test('stream errors surface as RemoteAgentError', () async {
    f.llm.error = StateError('model not loaded');
    final q = await f.run('streamError');
    expect(await q.next(), {
      'errorClass': 'RemoteAgentError',
      'type': 'StateError',
      'message': 'Bad state: model not loaded',
    });
    q.close();
  });

  test('localLlm.stop reaches the gateway', () async {
    final q = await f.run('stop');
    expect(await q.next(), {'ok': true});
    expect(f.llm.stops, 1);
    q.close();
  });

  test('closing the server fails in-flight and later calls promptly', () async {
    f.llm.endless = true;
    f.llm.interval = const Duration(seconds: 1);
    final q = await f.run('closed');
    expect(await q.next(), 'requested');
    // Wait until both requests reached the main isolate.
    await f.llm.listened.future.timeout(const Duration(seconds: 5));
    await _HangingSecrets.hanging.future.timeout(const Duration(seconds: 5));
    final sw = Stopwatch()..start();
    await f.server.close();
    final result = (await q.next())! as Map;
    expect(sw.elapsed, lessThan(const Duration(milliseconds: 400)));
    for (final key in ['unary', 'stream', 'after']) {
      expect(result[key], isA<Map>(), reason: key);
      expect((result[key] as Map)['errorClass'], 'RemoteAgentError');
      expect((result[key] as Map)['type'], 'AgentServicesClosed');
    }
    await f.llm.cancelled.future.timeout(const Duration(seconds: 5));
    q.close();
  });

  test('unary calls time out instead of hanging', () async {
    final q = await f.run('timeout');
    final result = (await q.next())! as Map;
    expect(result['errorClass'], 'TimeoutException');
    q.close();
  });

  test('chunk wire codec round-trips every chunk type', () {
    const chunks = <ChatGenerationChunk>[
      ChatTextChunk('a'),
      ChatThinkingChunk('b'),
      ChatFunctionCallChunk(name: 'n', args: {'k': 1}),
    ];
    expect([
      for (final c in chunks) chatGenerationChunkFromWire(c.toWire()),
    ], chunks);
  });

  test(
    'GemmaLocalLlmGateway holds the local model lease while streaming',
    () async {
      final access = LocalModelAccess();
      final gemma = _FakeGemma();
      final gateway = GemmaLocalLlmGateway(gemma, access: access);
      final sub = gateway
          .generate(const [], config: const ModelConfig())
          .listen((_) {});
      await gemma.started.future;
      var acquired = false;
      final other = access.acquire().then((lease) {
        acquired = true;
        return lease;
      });
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(acquired, isFalse);
      await sub.cancel();
      (await other).release();
      expect(acquired, isTrue);
      await gateway.stop();
      expect(gemma.stops, 1);
    },
  );
}

class _HangingSecrets implements SecretReader {
  _HangingSecrets(this._inner);
  final SecretReader _inner;
  static var hanging = Completer<void>();

  @override
  Future<String?> read(String key) {
    if (key == 'boom') throw StateError('vault exploded');
    if (key == 'hang') {
      if (!hanging.isCompleted) hanging.complete();
      return Completer<String?>().future;
    }
    return _inner.read(key);
  }
}

class _FakeLocalLlm implements LocalLlmGateway {
  List<ChatGenerationChunk> chunks = const [];
  bool endless = false;
  Duration interval = const Duration(milliseconds: 10);
  Object? error;
  List<Message>? lastMessages;
  ModelConfig? lastConfig;
  List<Map<String, dynamic>>? lastTools;
  int stops = 0;
  final listened = Completer<void>();
  final cancelled = Completer<void>();

  @override
  Stream<ChatGenerationChunk> generate(
    List<Message> messages, {
    required ModelConfig config,
    List<Map<String, dynamic>> tools = const [],
  }) {
    lastMessages = messages;
    lastConfig = config;
    lastTools = tools;
    late final StreamController<ChatGenerationChunk> c;
    Timer? timer;
    c = StreamController<ChatGenerationChunk>(
      onListen: () {
        if (!listened.isCompleted) listened.complete();
        if (error != null) {
          c.addError(error!);
          c.close();
        } else if (endless) {
          c.add(const ChatTextChunk('tick'));
          timer = Timer.periodic(
            interval,
            (_) => c.add(const ChatTextChunk('tick')),
          );
        } else {
          chunks.forEach(c.add);
          c.close();
        }
      },
      onCancel: () {
        timer?.cancel();
        if (!cancelled.isCompleted) cancelled.complete();
      },
    );
    return c.stream;
  }

  @override
  Future<void> stop() async => stops++;
}

class _FakeGemma implements GemmaRepository {
  final started = Completer<void>();
  int stops = 0;

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages, {
    List<Map<String, dynamic>> tools = const [],
    ModelConfig? config,
  }) async* {
    started.complete();
    yield const ChatTextChunk('x');
    await Completer<void>().future;
  }

  @override
  Future<void> stopGeneration() async => stops++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryVault implements VaultRepository {
  final _values = <String, String>{};

  @override
  Future<bool> containsKey({required String key}) async =>
      _values.containsKey(key);

  @override
  Future<void> delete({required String key}) async => _values.remove(key);

  @override
  Future<void> deleteAll() async => _values.clear();

  @override
  Future<String?> read({required String key}) async => _values[key];

  @override
  Future<Map<String, String>> readAll() async => Map.of(_values);

  @override
  Future<void> write({required String key, required String value}) async =>
      _values[key] = value;
}
