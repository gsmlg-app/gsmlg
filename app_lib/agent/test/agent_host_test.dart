import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';

/// Fake OpenAI-compatible streaming endpoint on loopback.
///
/// `tool` mode: the first request answers with a `domain_list_zones` tool
/// call, a request carrying the tool result answers with text. `hang` mode
/// streams one chunk and never finishes.
class _FakeLlm {
  late final HttpServer _server;
  String mode = 'tool';
  final requests = <Map<String, Object?>>[];
  final authHeaders = <String?>[];
  final aborted = Completer<void>();

  String get baseUrl => 'http://127.0.0.1:${_server.port}/v1';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen(_handle);
  }

  Future<void> close() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final body = await utf8.decoder.bind(request).join();
    requests.add((jsonDecode(body) as Map).cast<String, Object?>());
    authHeaders.add(request.headers.value('authorization'));
    final res = request.response
      ..bufferOutput = false
      ..statusCode = 200
      ..headers.contentType = ContentType('text', 'event-stream');
    void data(Object json) => res.write('data: ${jsonEncode(json)}\n\n');

    if (mode == 'hang') {
      data({
        'choices': [
          {
            'delta': {'content': 'partial'},
          },
        ],
      });
      await res.flush();
      // Never completes. SSE comment heartbeats surface a client abort.
      final heartbeat = Timer.periodic(const Duration(milliseconds: 100), (_) {
        try {
          res.write(': ping\n\n');
        } catch (_) {}
      });
      unawaited(
        res.done.then((_) {}, onError: (_) {}).whenComplete(() {
          heartbeat.cancel();
          if (!aborted.isCompleted) aborted.complete();
        }),
      );
      return;
    }

    final hasToolResult = body.contains('"role":"tool"');
    if (!hasToolResult) {
      data({
        'choices': [
          {
            'delta': {
              'tool_calls': [
                {
                  'index': 0,
                  'id': 'call_1',
                  'type': 'function',
                  'function': {'name': 'domain_list_zones', 'arguments': '{}'},
                },
              ],
            },
          },
        ],
      });
      data({
        'choices': [
          {'delta': {}, 'finish_reason': 'tool_calls'},
        ],
      });
    } else {
      data({
        'choices': [
          {
            'delta': {'content': 'done'},
          },
        ],
      });
      data({
        'choices': [
          {'delta': {}, 'finish_reason': 'stop'},
        ],
      });
    }
    res.write('data: [DONE]\n\n');
    await res.close();
  }
}

class _Secrets implements SecretReader {
  final reads = <String>[];

  @override
  Future<String?> read(String key) async {
    reads.add(key);
    return key == RemoteLlmRepository.accountSecretKey(7) ? 'sk-main' : null;
  }
}

class _Data implements ToolDataSource {
  @override
  Future<List<DnsZoneTableData>> listDnsZones() async => const [];

  @override
  Future<List<DnsZoneTableData>> findDnsZones({
    int? localZoneId,
    String? zoneId,
    String? zoneName,
    String? provider,
  }) async => const [];

  @override
  Future<ServiceAccountTableData?> serviceAccountById(int id) async => null;

  @override
  Future<List<ServiceAccountTableData>> serviceAccountsByProvider(
    ServiceProvider provider, {
    int? id,
  }) async => const [];
}

class _NoLocal implements LocalLlmGateway {
  @override
  Stream<ChatGenerationChunk> generate(
    List<Message> messages, {
    ModelConfig? config,
    List<Map<String, dynamic>> tools = const [],
  }) => Stream.error(StateError('no local model'));

  @override
  Future<void> stop() async {}
}

/// Local model that streams one chunk and never finishes.
class _HangingLocal implements LocalLlmGateway {
  final started = Completer<void>();
  final cancelled = Completer<void>();

  @override
  Stream<ChatGenerationChunk> generate(
    List<Message> messages, {
    ModelConfig? config,
    List<Map<String, dynamic>> tools = const [],
  }) {
    late final StreamController<ChatGenerationChunk> controller;
    controller = StreamController(
      onListen: () {
        controller.add(const ChatTextChunk('partial'));
        if (!started.isCompleted) started.complete();
      },
      onCancel: () {
        if (!cancelled.isCompleted) cancelled.complete();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> stop() async {}
}

void main() {
  late IsolateHub hub;
  late AgentServicesServer services;
  late _FakeLlm llm;
  late _Secrets secrets;
  late AgentHost host;
  var runCounter = 0;

  AgentHost newHost({
    Duration idleTimeout = const Duration(minutes: 10),
    Duration ackTimeout = const Duration(seconds: 90),
    SendPort? logIngest,
    Stream<SendPort?>? logIngestChanges,
  }) => AgentHost(
    hub: hub,
    services: services,
    logIngest: logIngest,
    logIngestChanges: logIngestChanges,
    ackTimeout: ackTimeout,
    secrets: secrets,
    loadDefinition: (id) async => AgentDefinition(
      id: id,
      name: 'Agent $id',
      config: const ModelConfig(),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    idleTimeout: idleTimeout,
    startTimeout: const Duration(seconds: 5),
  );

  setUp(() async {
    hub = IsolateHub();
    await hub.start();
    services = AgentServicesServer(
      secrets: _Secrets(),
      data: _Data(),
      localLlm: _NoLocal(),
    );
    llm = _FakeLlm();
    await llm.start();
    secrets = _Secrets();
    host = newHost();
  });

  tearDown(() async {
    await host.dispose();
    await hub.stop(timeout: const Duration(seconds: 2));
    services.close();
    await llm.close();
  });

  Stream<ChatAgentEvent> run({String agentId = 'a', String? runId}) {
    final id = runId ?? 'run-${++runCounter}';
    return host.runStream(
      agentId: agentId,
      runId: id,
      sessionId: 'session-1',
      generationId: id,
      modelConfig: ModelConfig(
        inferenceMode: ChatInferenceMode.remote,
        remoteBaseUrl: llm.baseUrl,
        remoteModel: 'fake-model',
        remoteAccountId: 7,
      ),
      historyMessages: [
        UserMessage(
          id: 'u1',
          content: 'list my zones',
          conversationId: 'session-1',
          timestamp: DateTime.utc(2026),
        ),
      ],
      userPrompt: 'list my zones',
      maxTurns: 5,
    );
  }

  test(
    'streams events in order and waits for each ack before continuing',
    () async {
      final types = <Type>[];
      final done = Completer<void>();
      var toolStartedBeforeTurnAck = false;
      var requestsBeforeToolAck = -1;
      var turnAcked = false;

      run().listen((event) {
        types.add(event.runtimeType);
        switch (event) {
          case ModelTurnCompletedEvent(:final turnIndex):
            if (turnIndex == 0) {
              // Hold the ack; the worker must not reach the tool meanwhile.
              Timer(const Duration(milliseconds: 400), () {
                turnAcked = true;
                event.acknowledge();
              });
            } else {
              event.acknowledge();
            }
          case ToolCallStartedEvent():
            if (!turnAcked) toolStartedBeforeTurnAck = true;
          case ToolCallCompletedEvent():
            Timer(const Duration(milliseconds: 400), () {
              requestsBeforeToolAck = llm.requests.length;
              event.acknowledge();
            });
          default:
        }
      }, onDone: done.complete);

      await done.future.timeout(const Duration(seconds: 20));

      expect(toolStartedBeforeTurnAck, isFalse);
      expect(
        requestsBeforeToolAck,
        1,
        reason: 'the second model turn waits for the tool receipt ack',
      );
      expect(llm.requests, hasLength(2));
      expect(types.first, AgentRunStartedEvent);
      expect(types.last, AgentRunCompletedEvent);
      final order = [
        ModelTurnStartedEvent,
        ModelTurnCompletedEvent,
        ToolCallStartedEvent,
        ToolCallCompletedEvent,
        ModelTurnStartedEvent,
        ModelTurnCompletedEvent,
        AgentRunCompletedEvent,
      ];
      var i = 0;
      for (final t in types) {
        if (i < order.length && t == order[i]) i++;
      }
      expect(i, order.length, reason: 'got $types');
      // The API key is resolved on the main isolate and used by the worker.
      expect(secrets.reads, [RemoteLlmRepository.accountSecretKey(7)]);
      expect(llm.authHeaders.first, 'Bearer sk-main');
      expect(hub.getByName('agent:a'), isNotNull);
    },
  );

  for (final rejected in [ModelTurnCompletedEvent, ToolCallCompletedEvent]) {
    test('a rejected $rejected ack fails the run', () async {
      final events = <ChatAgentEvent>[];
      await for (final event in run().timeout(const Duration(seconds: 20))) {
        events.add(event);
        switch (event) {
          case ModelTurnCompletedEvent():
            rejected == ModelTurnCompletedEvent
                ? event.reject(StateError('disk full'))
                : event.acknowledge();
          case ToolCallCompletedEvent():
            rejected == ToolCallCompletedEvent
                ? event.reject(StateError('disk full'))
                : event.acknowledge();
          default:
        }
      }
      final last = events.last;
      expect(last, isA<AgentRunFailedEvent>());
      expect(
        (last as AgentRunFailedEvent).error.toString(),
        contains('disk full'),
      );
      expect(llm.requests, hasLength(1));
      if (rejected == ModelTurnCompletedEvent) {
        expect(events.whereType<ToolCallStartedEvent>(), isEmpty);
      }
    });
  }

  test(
    'killing the worker mid-run fails the run and the next run respawns',
    () async {
      llm.mode = 'hang';
      final events = <ChatAgentEvent>[];
      final firstChunk = Completer<void>();
      final done = Completer<void>();
      run().listen((event) {
        events.add(event);
        if (event is ModelChunkReceivedEvent && !firstChunk.isCompleted) {
          firstChunk.complete();
        }
      }, onDone: done.complete);

      await firstChunk.future.timeout(const Duration(seconds: 10));
      final worker = hub.getByName('agent:a')!;
      final sw = Stopwatch()..start();
      await worker.kill(graceful: false);
      await done.future.timeout(const Duration(seconds: 5));
      expect(sw.elapsed, lessThan(const Duration(seconds: 5)));
      final failed = events.last as AgentRunFailedEvent;
      expect(failed.error, isA<RemoteAgentError>());
      expect((failed.error as RemoteAgentError).type, 'AgentIsolateLost');

      llm.mode = 'tool';
      final next = await run()
          .map((e) {
            if (e is ModelTurnCompletedEvent) e.acknowledge();
            if (e is ToolCallCompletedEvent) e.acknowledge();
            return e;
          })
          .last
          .timeout(const Duration(seconds: 20));
      expect(next, isA<AgentRunCompletedEvent>());
      expect(hub.getByName('agent:a')!.id, isNot(worker.id));
    },
  );

  test(
    'a local run lost with its worker cancels the bridged generation',
    () async {
      await host.dispose();
      await services.close();
      final local = _HangingLocal();
      services = AgentServicesServer(
        secrets: _Secrets(),
        data: _Data(),
        localLlm: local,
      );
      host = newHost();
      final events = <ChatAgentEvent>[];
      final done = Completer<void>();
      host
          .runStream(
            agentId: 'a',
            runId: 'local-1',
            sessionId: 'session-1',
            modelConfig: const ModelConfig(),
            historyMessages: [
              UserMessage(
                id: 'u1',
                content: 'hi',
                conversationId: 'session-1',
                timestamp: DateTime.utc(2026),
              ),
            ],
            userPrompt: 'hi',
          )
          .listen(events.add, onDone: done.complete);

      await local.started.future.timeout(const Duration(seconds: 10));
      await hub.getByName('agent:a')!.kill(graceful: false);
      await done.future.timeout(const Duration(seconds: 5));
      expect(
        ((events.last as AgentRunFailedEvent).error as RemoteAgentError).type,
        agentIsolateLostErrorType,
      );
      await local.cancelled.future.timeout(const Duration(seconds: 2));
    },
  );

  test('idle timeout stops the worker; the next run respawns it', () async {
    await host.dispose();
    host = newHost(idleTimeout: const Duration(milliseconds: 300));

    Future<ChatAgentEvent> complete() => run()
        .map((e) {
          if (e is ModelTurnCompletedEvent) e.acknowledge();
          if (e is ToolCallCompletedEvent) e.acknowledge();
          return e;
        })
        .last
        .timeout(const Duration(seconds: 20));

    expect(await complete(), isA<AgentRunCompletedEvent>());
    expect(hub.getByName('agent:a'), isNotNull);
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (hub.getByName('agent:a') != null &&
        DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(hub.getByName('agent:a'), isNull);
    expect(hub.lookupNode('/agents/agent:a'), isNull);

    expect(await complete(), isA<AgentRunCompletedEvent>());
  });

  test('stop(runId) ends the run as cancelled', () async {
    llm.mode = 'hang';
    final events = <ChatAgentEvent>[];
    final firstChunk = Completer<void>();
    final done = Completer<void>();
    run(runId: 'stop-me').listen((event) {
      events.add(event);
      if (event is ModelChunkReceivedEvent && !firstChunk.isCompleted) {
        firstChunk.complete();
      }
    }, onDone: done.complete);

    await firstChunk.future.timeout(const Duration(seconds: 10));
    await host.stop('stop-me');
    await done.future.timeout(const Duration(seconds: 5));
    expect(events.last, isA<AgentRunCancelledEvent>());
    await llm.aborted.future.timeout(const Duration(seconds: 5));
    // The worker stays up for later runs.
    expect(hub.getByName('agent:a'), isNotNull);
  });

  test(
    'an ack that never arrives fails the run (AcknowledgementTimeout)',
    () async {
      await host.dispose();
      host = newHost(ackTimeout: const Duration(milliseconds: 300));
      final events = await run().toList().timeout(const Duration(seconds: 20));
      final failed = events.last as AgentRunFailedEvent;
      expect((failed.error as RemoteAgentError).type, 'AcknowledgementTimeout');
      expect(llm.requests, hasLength(1));
      expect(events.whereType<ToolCallStartedEvent>(), isEmpty);
    },
  );

  test('a supervisor-restarted worker gets the current log port', () async {
    final first = ReceivePort();
    final second = ReceivePort();
    addTearDown(first.close);
    addTearDown(second.close);
    final firstMessages = <Map>[];
    final secondMessages = <Map>[];
    first.listen((m) => firstMessages.add(m as Map));
    second.listen((m) => secondMessages.add(m as Map));
    final changes = StreamController<SendPort?>();
    addTearDown(changes.close);
    await host.dispose();
    host = newHost(logIngest: first.sendPort, logIngestChanges: changes.stream);

    Future<ChatAgentEvent> complete() => run()
        .map((e) {
          if (e is ModelTurnCompletedEvent) e.acknowledge();
          if (e is ToolCallCompletedEvent) e.acknowledge();
          return e;
        })
        .last
        .timeout(const Duration(seconds: 20));

    Future<void> until(String what, bool Function() condition) async {
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (!condition() && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(condition(), isTrue, reason: what);
    }

    expect(await complete(), isA<AgentRunCompletedEvent>());
    final worker = hub.getByName('agent:a')!;
    changes.add(second.sendPort);
    await until(
      'live worker switched ports',
      () => secondMessages.any(
        (m) => '${m['message']}'.contains('Log ingest port changed'),
      ),
    );

    // A supervisor restart reuses the original spawn config (first port).
    await hub.restartNode('/agents/agent:a');
    await until('worker restarted', () {
      final next = hub.getByName('agent:a');
      return next != null &&
          next.id != worker.id &&
          next.state == IsolateState.running;
    });
    final apiBefore = secondMessages.where((m) => m['k'] == 'api').length;
    final firstBefore = firstMessages.length;
    expect(await complete(), isA<AgentRunCompletedEvent>());
    await until(
      'restarted worker logs to the current port',
      () => secondMessages.where((m) => m['k'] == 'api').length > apiBefore,
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(firstMessages.length, firstBefore);
  });

  test('live and new workers follow log ingest port changes', () async {
    final first = ReceivePort();
    final second = ReceivePort();
    addTearDown(first.close);
    addTearDown(second.close);
    final firstMessages = <Map>[];
    final secondMessages = <Map>[];
    first.listen((m) => firstMessages.add(m as Map));
    second.listen((m) => secondMessages.add(m as Map));
    final changes = StreamController<SendPort?>();
    addTearDown(changes.close);
    await host.dispose();
    host = newHost(logIngest: first.sendPort, logIngestChanges: changes.stream);

    Future<ChatAgentEvent> complete({String agentId = 'a'}) =>
        run(agentId: agentId)
            .map((e) {
              if (e is ModelTurnCompletedEvent) e.acknowledge();
              if (e is ToolCallCompletedEvent) e.acknowledge();
              return e;
            })
            .last
            .timeout(const Duration(seconds: 20));

    Future<void> until(bool Function() condition) async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!condition() && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(condition(), isTrue);
    }

    expect(await complete(), isA<AgentRunCompletedEvent>());
    await until(() => firstMessages.any((m) => m['k'] == 'api'));

    changes.add(second.sendPort);
    // Logger.root (IsolateLogBridge) follows the new port.
    await until(
      () => secondMessages.any(
        (m) => '${m['message']}'.contains('Log ingest port changed'),
      ),
    );
    final before = firstMessages.length;

    expect(await complete(), isA<AgentRunCompletedEvent>());
    await until(() => secondMessages.any((m) => m['k'] == 'api'));
    // A worker spawned after the change uses the current port.
    final apiBefore = secondMessages.where((m) => m['k'] == 'api').length;
    expect(await complete(agentId: 'b'), isA<AgentRunCompletedEvent>());
    await until(
      () => secondMessages.where((m) => m['k'] == 'api').length > apiBefore,
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(firstMessages.length, before);
  });
}
