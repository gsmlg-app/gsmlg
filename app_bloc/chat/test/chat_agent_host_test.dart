import 'dart:async';

import 'package:app_agent/app_agent.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:dart_agent_core/dart_agent_core.dart' as core;
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_agent_repository.dart';

const _remoteConfig = ModelConfig(
    inferenceMode: ChatInferenceMode.remote,
    remoteBaseUrl: 'http://localhost:8000/v1',
    remoteModel: 'model');

void main() {
  test('runs go through the AgentRunner with the owning agent id', () async {
    final f = _Fixture(agents: [
      AgentDefinition(
          id: 'x',
          name: 'X',
          config: _remoteConfig,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026)),
    ]);
    addTearDown(f.close);
    await f.storage
        .saveConversation(Conversation.create(id: 'a', agentId: 'x'));
    await f.start('a');
    expect(f.runner.runs['a']!.agentId, 'x');

    await f.start('b', config: _remoteConfig);
    expect(f.runner.runs['b']!.agentId, ChatBloc.unownedAgentId);
  });

  test('both acknowledgements complete only after persistence', () async {
    final f = _Fixture();
    addTearDown(f.close);
    await f.start('a', config: _remoteConfig);
    final run = f.runner.runs['a']!;
    run.add(ModelChunkReceivedEvent(
        runId: run.runId, sessionId: 'a', turnIndex: 0, textChunk: 'hi'));

    final turn = ModelTurnCompletedEvent(
        runId: run.runId,
        sessionId: 'a',
        turnIndex: 0,
        modelMessage: core.ModelMessage(
            model: 'm', textOutput: 'hi there', timestamp: 1));
    f.storage.blockAssistant = Completer<void>();
    run.add(turn);
    await _flush();
    expect(turn.acknowledgement.isCompleted, isFalse,
        reason: 'ack waits for the assistant write');
    f.storage.blockAssistant!.complete();
    await turn.acknowledgement.future.timeout(const Duration(seconds: 5));
    expect(
        f.storage.messages.values.whereType<AssistantMessage>().single.content,
        'hi there');

    final tool = ToolCallCompletedEvent(
      runId: run.runId,
      sessionId: 'a',
      callId: 'c1',
      toolName: 'domain_list_zones',
      arguments: '{}',
      receipt: ToolInvocationReceipt(
          runId: run.runId,
          callId: 'c1',
          invocationId: 'i1',
          toolName: 'domain_list_zones',
          arguments: '{}',
          status: InvocationStatus.succeeded,
          result: const {'zones': []},
          timestamp: DateTime.utc(2026)),
    );
    f.storage.blockTool = Completer<void>();
    run.add(tool);
    await _flush();
    expect(tool.acknowledgement.isCompleted, isFalse);
    f.storage.blockTool!.complete();
    await tool.acknowledgement.future.timeout(const Duration(seconds: 5));
    expect(
        f.storage.messages.values
            .whereType<ToolResponseMessage>()
            .single
            .toolCallId,
        'c1');
  });

  test('a failed write rejects the acknowledgement and fails the session',
      () async {
    final f = _Fixture();
    addTearDown(f.close);
    await f.start('a', config: _remoteConfig);
    final run = f.runner.runs['a']!;
    f.storage.failTool = true;
    final tool = ToolCallCompletedEvent(
      runId: run.runId,
      sessionId: 'a',
      callId: 'c1',
      toolName: 't',
      arguments: '{}',
      receipt: ToolInvocationReceipt(
          runId: run.runId,
          callId: 'c1',
          invocationId: 'i1',
          toolName: 't',
          arguments: '{}',
          status: InvocationStatus.succeeded,
          timestamp: DateTime.utc(2026)),
    );
    final failed =
        _wait(f.bloc, (s) => s.sessionFor('a')?.status == ChatStatus.error);
    run.add(tool);
    await expectLater(tool.acknowledgement.future, throwsA(anything));
    await failed;
    expect(f.bloc.state.sessionFor('a')!.errorMessage, contains('disk full'));
  });

  test('stop calls runner.stop(runId) and persists the partial as stopped',
      () async {
    final f = _Fixture();
    addTearDown(f.close);
    await f.start('a', config: _remoteConfig);
    final run = f.runner.runs['a']!;
    run.add(ModelChunkReceivedEvent(
        runId: run.runId, sessionId: 'a', turnIndex: 0, textChunk: 'part'));
    await _flush();
    await f.sendAndWait(const ChatStopGeneration(conversationId: 'a'),
        (s) => s.sessionFor('a')?.status == ChatStatus.stopped);
    expect(f.runner.stopped, [run.runId]);
    final saved =
        f.storage.messages.values.whereType<AssistantMessage>().single;
    expect(saved.content, 'part');
    expect(saved.isStreaming, isFalse);
    expect(saved.completedSuccessfully, isFalse);
  });

  test('an agent isolate failure surfaces as a session error', () async {
    final f = _Fixture();
    addTearDown(f.close);
    await f.start('a', config: _remoteConfig);
    final run = f.runner.runs['a']!;
    final failed =
        _wait(f.bloc, (s) => s.sessionFor('a')?.status == ChatStatus.error);
    run.add(AgentRunFailedEvent(
        runId: run.runId,
        sessionId: 'a',
        error: const RemoteAgentError(
            type: agentIsolateLostErrorType,
            message: 'Agent isolate agent:default lost: crashed')));
    await failed;
    expect(f.bloc.state.sessionFor('a')!.errorMessage, contains('lost'));
  });

  test('an unavailable host fails the run with a visible error', () async {
    final f = _Fixture();
    addTearDown(f.close);
    f.runner.throwOnStart = StateError('isolate hub unavailable');
    await f.start('a', config: _remoteConfig, expected: ChatStatus.error);
    expect(f.bloc.state.sessionFor('a')!.errorMessage,
        contains('isolate hub unavailable'));
  });

  test('local runs keep the FIFO lease for the whole run', () async {
    final f = _Fixture();
    addTearDown(f.close);
    await f.start('a');
    await f.start('b', expected: ChatStatus.queued);
    expect(f.runner.order, ['a']);
    final run = f.runner.runs['a']!;
    // A tool round-trip inside the run does not release the slot.
    run.add(ModelChunkReceivedEvent(
        runId: run.runId, sessionId: 'a', turnIndex: 0, textChunk: 'ok'));
    await _flush();
    expect(f.runner.order, ['a']);
    final bStarted =
        _wait(f.bloc, (s) => s.sessionFor('b')?.isStreaming ?? false);
    run.add(AgentRunCompletedEvent(
        runId: run.runId, sessionId: 'a', finalResponse: null));
    await bStarted;
    expect(f.runner.order, ['a', 'b']);
  });
}

class _Run {
  _Run(this.agentId, this.runId);
  final String agentId;
  final String runId;
  final controller = StreamController<ChatAgentEvent>();
  void add(ChatAgentEvent event) => controller.add(event);
}

class _Runner implements AgentRunner {
  final runs = <String, _Run>{};
  final order = <String>[];
  final stopped = <String>[];
  Object? throwOnStart;

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
    final error = throwOnStart;
    if (error != null) throw error;
    final run = runs[sessionId] = _Run(agentId, runId);
    order.add(sessionId);
    return run.controller.stream;
  }

  @override
  Future<void> stop(String runId) async => stopped.add(runId);

  Future<void> close() async {
    for (final run in runs.values) {
      await run.controller.close();
    }
  }
}

class _Fixture {
  _Fixture({List<AgentDefinition> agents = const []}) {
    bloc = ChatBloc(
      gemmaRepository: local,
      remoteRepository: remote,
      storageRepository: storage,
      agentRepository: FakeAgentRepository(agents),
      toolExecutor: ToolExecutor(),
      agentRunner: runner,
    );
  }
  final storage = _Storage();
  final local = _Local();
  final remote = _Remote();
  final runner = _Runner();
  late final ChatBloc bloc;

  Future<void> start(String id,
      {ModelConfig? config, ChatStatus expected = ChatStatus.streaming}) async {
    if (!storage.conversations.containsKey(id)) {
      await storage.saveConversation(Conversation.create(id: id));
    }
    await sendAndWait(
        ChatLoadConversation(id: id), (s) => s.conversation?.id == id);
    await sendAndWait(
        ChatSendMessage(
            conversationId: id, content: 'hello $id', config: config),
        (s) => s.sessionFor(id)?.status == expected);
  }

  Future<void> sendAndWait(
      ChatEvent event, bool Function(ChatState) predicate) async {
    final result = _wait(bloc, predicate);
    bloc.add(event);
    await result;
  }

  Future<void> close() async {
    await bloc.close();
    await runner.close();
  }
}

class _Remote implements RemoteLlmRepository {
  @override
  Future<bool> isReady(ModelConfig config) async => true;
  @override
  Future<void> stopGeneration({String? generationId}) async {}
  @override
  Future<void> dispose() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Local extends GemmaRepository {
  @override
  bool get isReady => true;
  @override
  Future<void> stopGeneration() async {}
  @override
  Future<void> dispose() async {}
}

class _Storage implements ChatStorageRepository {
  final conversations = <String, Conversation>{};
  final messages = <String, Message>{};
  Completer<void>? blockAssistant;
  Completer<void>? blockTool;
  bool failTool = false;

  @override
  Future<ModelConfig> loadSettings() async => ModelConfig.defaultConfig;
  @override
  Future<void> saveConversation(Conversation conversation) async {
    conversations[conversation.id] = conversation.copyWith(messages: const []);
  }

  @override
  Future<void> saveMessage(Message message) async {
    if (message is AssistantMessage && message.agentMetadata != null) {
      await blockAssistant?.future;
    }
    if (message is ToolResponseMessage) {
      if (failTool) throw StateError('disk full');
      await blockTool?.future;
    }
    messages[message.id] = message;
  }

  @override
  Future<List<Message>> loadMessages(String id) async =>
      messages.values.where((message) => message.conversationId == id).toList();
  @override
  Future<Conversation?> loadConversation(String id) async =>
      conversations[id]?.copyWith(messages: await loadMessages(id));
  @override
  Future<List<Conversation>> loadConversations({String? agentId}) async =>
      conversations.values.toList();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ChatState> _wait(ChatBloc bloc, bool Function(ChatState) predicate) =>
    bloc.stream.firstWhere(predicate).timeout(const Duration(seconds: 5));
Future<void> _flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
