import 'dart:async';

import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart'
    show DnsZoneTableData, ServiceAccountTableData, ServiceProvider;
import 'package:flutter_test/flutter_test.dart';

class _EmptySecrets implements SecretReader {
  @override
  Future<String?> read(String key) async => null;
}

class _EmptyData implements ToolDataSource {
  @override
  Future<List<DnsZoneTableData>> findDnsZones({
    int? localZoneId,
    String? zoneId,
    String? zoneName,
    String? provider,
  }) async => const [];

  @override
  Future<List<DnsZoneTableData>> listDnsZones() async => const [];

  @override
  Future<ServiceAccountTableData?> serviceAccountById(int id) async => null;

  @override
  Future<List<ServiceAccountTableData>> serviceAccountsByProvider(
    ServiceProvider provider, {
    int? id,
  }) async => const [];
}

class _ControlledLocalLlm implements LocalLlmGateway {
  final controllers = <String, StreamController<ChatGenerationChunk>>{};
  final cancelledRunIds = <String>[];
  final startedRunIds = <String>[];

  @override
  Stream<ChatGenerationChunk> generate(
    List<Message> messages, {
    required ModelConfig config,
    List<Map<String, dynamic>> tools = const [],
    String? runId,
  }) {
    final key = runId ?? 'anon_${controllers.length}';
    final controller = StreamController<ChatGenerationChunk>(
      onListen: () => startedRunIds.add(key),
      onCancel: () => cancelledRunIds.add(key),
    );
    controllers[key] = controller;
    return controller.stream;
  }

  @override
  Future<void> stop() async {}
}

void main() {
  group('AgentServicesServer run-scoped cancellation & memory bridge', () {
    test(
      'cancelStreamsForRuns only cancels matching runId and preserves healthy run',
      () async {
        final llm = _ControlledLocalLlm();
        final server = AgentServicesServer(
          secrets: _EmptySecrets(),
          data: _EmptyData(),
          localLlm: llm,
        );
        final client = AgentServicesClient(server.port);
        addTearDown(() async {
          client.close();
          await server.close();
        });

        final chunks1 = <ChatGenerationChunk>[];
        final chunks2 = <ChatGenerationChunk>[];
        final done1 = Completer<void>();
        final done2 = Completer<void>();

        final sub1 = client
            .generate(
              const [],
              config: ModelConfig.defaultConfig,
              runId: 'run-lost',
            )
            .listen(
              chunks1.add,
              onDone: done1.complete,
              onError: (_) {
                if (!done1.isCompleted) done1.complete();
              },
            );
        final sub2 = client
            .generate(
              const [],
              config: ModelConfig.defaultConfig,
              runId: 'run-healthy',
            )
            .listen(chunks2.add, onDone: done2.complete);
        addTearDown(() async {
          await sub1.cancel();
          await sub2.cancel();
        });

        // Wait until run-lost starts (run-healthy is queued behind it in FIFO order).
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(llm.startedRunIds, ['run-lost']);

        // Cancelling only run-lost releases the permit so run-healthy starts and completes!
        await server.cancelStreamsForRuns({'run-lost'});
        expect(llm.cancelledRunIds, ['run-lost']);

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(llm.startedRunIds, ['run-lost', 'run-healthy']);
        expect(llm.cancelledRunIds, ['run-lost']);

        llm.controllers['run-healthy']!.add(const ChatTextChunk('hello'));
        await llm.controllers['run-healthy']!.close();
        await done2.future.timeout(const Duration(seconds: 2));

        expect(chunks2.whereType<ChatTextChunk>().map((c) => c.text), [
          'hello',
        ]);
      },
    );

    test('bridges persistent memory operations over services port', () async {
      final memory = ScopedMemoryProvider();
      final server = AgentServicesServer(
        secrets: _EmptySecrets(),
        data: _EmptyData(),
        localLlm: _ControlledLocalLlm(),
        memory: memory,
      );
      final client = AgentServicesClient(server.port);
      addTearDown(() async {
        client.close();
        await server.close();
      });

      final remoteMemory = ScopedMemoryProvider(
        remoteGateway: client,
        defaultAgentId: 'agent-mobile',
      );

      final stored = await remoteMemory.executeTool(
        toolName: 'memory_store',
        arguments: {
          'content': 'Deploy target is Pixel 9 Pro',
          'scope': 'agent:agent-mobile',
          'provenance': 'user_fact',
        },
        sessionId: 'sess-1',
      );
      expect(stored['status'], 'stored');

      final found = await remoteMemory.executeTool(
        toolName: 'memory_search',
        arguments: {'query': 'Pixel'},
        sessionId: 'sess-2',
      );
      expect((found['results'] as List).length, 1);
      expect(
        (found['results'] as List).first['content'],
        contains('Pixel 9 Pro'),
      );
    });

    test('SubAgentUpdatedEvent round-trips across wire codec', () {
      const event = SubAgentUpdatedEvent(
        runId: 'run-1',
        sessionId: 'sess-1',
        taskId: 'sub_1',
        parentRunId: 'run-1',
        childRunId: 'run_sub_1',
        workerName: 'researcher',
        goal: 'Check DNS records',
        status: 'succeeded',
        depth: 1,
        summary: 'All A records healthy',
        durationMs: 420,
      );
      final wire = agentEventToWire(event);
      final decoded = agentEventFromWire(wire);
      expect(decoded, equals(event));
    });

    test(
      'AgentSupervisor wakes wait_agent immediately on parent cancellation',
      () async {
        final neverFinishes = Completer<dynamic>();
        final updates = <String>[];
        final supervisor = AgentSupervisor(
          onTaskUpdated: (task, {durationMs}) => updates.add(task.status),
          childRunner:
              ({
                required String childRunId,
                required String role,
                required String prompt,
                required Set<String>? allowedTools,
                required CancelToken cancelToken,
                required TreeBudget budget,
                required int depth,
              }) => neverFinishes.future,
        );

        final cancelToken = CancelToken();
        final spawned = await supervisor.executeTool(
          toolName: 'spawn_agent',
          arguments: {'name': 'worker', 'goal': 'long task'},
          parentRunId: 'run-root',
          sessionId: 'sess-1',
          cancelToken: cancelToken,
        );
        final taskId = spawned['taskId'] as String;

        final sw = Stopwatch()..start();
        Future<void>.delayed(
          const Duration(milliseconds: 40),
          () => cancelToken.cancel('User stopped'),
        );
        final result = await supervisor.executeTool(
          toolName: 'wait_agent',
          arguments: {'taskId': taskId, 'timeout': 30000},
          parentRunId: 'run-root',
          sessionId: 'sess-1',
          cancelToken: cancelToken,
        );
        sw.stop();

        expect(sw.elapsedMilliseconds, lessThan(2000));
        expect(result['status'], 'cancelled');
        expect(updates, containsAll(['spawned', 'running', 'cancelled']));
      },
    );
  });
}
