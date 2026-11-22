import 'dart:async';

import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_agent_repository.dart';

class _FakeKeepAlive implements AgentKeepAlive {
  final activeRunCounts = <int>[];

  @override
  Future<void> onActiveRunsChanged(int activeRuns) async {
    activeRunCounts.add(activeRuns);
  }
}

class _ScriptedAgentRunner implements AgentRunner {
  final controllers = <String, StreamController<ChatAgentEvent>>{};

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
    final controller = StreamController<ChatAgentEvent>();
    controllers[runId] = controller;
    return controller.stream;
  }

  @override
  Future<void> stop(String runId) async {
    await controllers.remove(runId)?.close();
  }
}

class _FakeRemoteLlmRepository extends RemoteLlmRepository {
  _FakeRemoteLlmRepository() : super(secrets: _NoSecrets());

  @override
  Future<bool> isReady(ModelConfig config) async => true;
}

class _NoSecrets implements SecretReader {
  @override
  Future<String?> read(String key) async => 'dummy-key';
}

void main() {
  test(
    'ChatBloc tracks tool & sub-agent activities and coordinates AgentKeepAlive',
    () async {
      final db = AppDatabase.forTesting();
      final storage = ChatStorageRepository(db);
      final agents = FakeAgentRepository();
      final runner = _ScriptedAgentRunner();
      final keepAlive = _FakeKeepAlive();
      final bloc = ChatBloc(
        gemmaRepository: GemmaRepository(),
        remoteRepository: _FakeRemoteLlmRepository(),
        storageRepository: storage,
        toolExecutor: ToolExecutor(),
        agentRepository: agents,
        agentRunner: runner,
        keepAlive: keepAlive,
      );
      addTearDown(() async {
        await bloc.close();
        await db.close();
      });

      const remoteConfig = ModelConfig(
        inferenceMode: ChatInferenceMode.remote,
        remoteAccountId: 0,
        remoteBaseUrl: 'http://127.0.0.1:11434/v1',
        remoteModel: 'test-model',
      );

      bloc.add(const ChatNewConversation(config: remoteConfig));
      await bloc.stream.firstWhere((s) => s.conversation != null);
      final convId = bloc.state.conversation!.id;

      bloc.add(ChatSendMessage(
        conversationId: convId,
        config: remoteConfig,
        content: 'Check status with a sub-agent',
      ));

      await bloc.stream.firstWhere((s) => runner.controllers.isNotEmpty);
      expect(keepAlive.activeRunCounts, contains(1));

      final runId = runner.controllers.keys.single;
      final ctrl = runner.controllers[runId]!;

      ctrl.add(ToolCallStartedEvent(
        runId: runId,
        sessionId: convId,
        callId: 'c1',
        toolName: 'memory_search',
        arguments: '{"query":"dns"}',
      ));
      await bloc.stream.firstWhere(
        (s) => (s.sessionFor(convId)?.toolActivities.length ?? 0) == 1,
      );
      expect(bloc.state.sessionFor(convId)!.toolActivities.single.status,
          'running');

      ctrl.add(SubAgentUpdatedEvent(
        runId: runId,
        sessionId: convId,
        taskId: 'sub_1',
        parentRunId: runId,
        childRunId: 'run_sub_1',
        workerName: 'researcher',
        goal: 'Inspect DNS records',
        status: 'running',
        depth: 1,
      ));
      await bloc.stream.firstWhere(
        (s) => (s.sessionFor(convId)?.subAgents.length ?? 0) == 1,
      );
      expect(bloc.state.sessionFor(convId)!.subAgents.single.workerName,
          'researcher');

      final toolEvent = ToolCallCompletedEvent(
        runId: runId,
        sessionId: convId,
        callId: 'c1',
        toolName: 'memory_search',
        arguments: '{"query":"dns"}',
        receipt: ToolInvocationReceipt(
          runId: runId,
          callId: 'c1',
          invocationId: 'c1',
          toolName: 'memory_search',
          arguments: '{"query":"dns"}',
          status: InvocationStatus.succeeded,
          isError: false,
          result: const {'total': 1},
          timestamp: DateTime.now(),
          backend: 'memory',
          durationMs: 12,
        ),
      );
      ctrl.add(toolEvent);
      await toolEvent.acknowledgement.future;

      ctrl.add(SubAgentUpdatedEvent(
        runId: runId,
        sessionId: convId,
        taskId: 'sub_1',
        parentRunId: runId,
        childRunId: 'run_sub_1',
        workerName: 'researcher',
        goal: 'Inspect DNS records',
        status: 'succeeded',
        depth: 1,
        summary: 'All healthy',
        durationMs: 250,
      ));

      ctrl.add(ModelChunkReceivedEvent(
        runId: runId,
        sessionId: convId,
        turnIndex: 0,
        textChunk: 'Everything looks healthy.',
      ));
      ctrl.add(AgentRunCompletedEvent(
        runId: runId,
        sessionId: convId,
        finalResponse: null,
      ));
      await ctrl.close();

      await bloc.stream.firstWhere(
        (s) => s.sessionFor(convId)?.status == ChatStatus.ready,
      );

      final session = bloc.state.sessionFor(convId)!;
      expect(session.toolActivities.single.status, 'succeeded');
      expect(session.toolActivities.single.durationMs, 12);
      expect(session.subAgents.single.status, 'succeeded');
      expect(session.subAgents.single.summary, 'All healthy');
      expect(keepAlive.activeRunCounts.last, 0);
    },
  );
}
