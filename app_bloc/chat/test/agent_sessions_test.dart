import 'dart:async';
import 'dart:convert';

import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _remoteConfig = ModelConfig(
  inferenceMode: ChatInferenceMode.remote,
  remoteBaseUrl: 'http://localhost:8000/v1',
  remoteModel: 'agent-model',
  temperature: 0.42,
);

AgentDefinition _agent(String id, {List<String>? tools}) => AgentDefinition(
      id: id,
      name: 'Agent $id',
      instructions: 'You are $id',
      config: _remoteConfig,
      thinkingEnabled: true,
      allowedTools: tools,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
    );

void main() {
  late AppDatabase db;
  late AgentRepository agents;
  late ChatStorageRepository storage;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting();
    agents = AgentRepository(db);
    storage = ChatStorageRepository(db);
  });
  tearDown(() => db.close());

  group('ChatSettingsBloc agents', () {
    ChatSettingsBloc settings() => ChatSettingsBloc(
          repository: storage,
          preferences: preferences,
          agentRepository: agents,
        );

    Future<ChatSettingsBloc> loaded() async {
      final bloc = settings();
      final ready = bloc.stream.firstWhere((s) => s.isLoaded);
      bloc.add(const ChatSettingsLoad());
      await ready;
      return bloc;
    }

    test('saving an agent persists it via the repository', () async {
      final bloc = await loaded();
      addTearDown(bloc.close);
      final saved = bloc.stream.firstWhere((s) => s.agents.length == 1);
      bloc.add(const ChatSettingsSaveAgent(
        id: 'a1',
        name: 'Writer',
        instructions: 'Write well',
        avatar: '✍️',
        description: 'Writes',
        config: _remoteConfig,
        thinkingEnabled: true,
        allowedTools: ['shell'],
      ));
      await saved;

      final stored = await agents.get('a1');
      expect(stored, isNotNull);
      expect(stored!.name, 'Writer');
      expect(stored.instructions, 'Write well');
      expect(stored.avatar, '✍️');
      expect(stored.description, 'Writes');
      expect(stored.config, _remoteConfig);
      expect(stored.thinkingEnabled, isTrue);
      expect(stored.allowedTools, ['shell']);
      expect(preferences.getStringList('chat_agents'), isNull);
      expect(bloc.state.activeAgent, stored);
      expect(bloc.state.defaultSystemPrompt, 'Write well');

      // A fresh bloc reads the agent back from the database.
      final reloaded = await loaded();
      addTearDown(reloaded.close);
      expect(reloaded.state.agents, [stored]);
      expect(reloaded.state.activeAgentId, 'a1');
      expect(reloaded.state.config, _remoteConfig);
    });

    test('updating config and deleting go through the repository', () async {
      await agents.save(_agent('a1'));
      await preferences.setString('chat_active_agent_id', 'a1');
      final bloc = await loaded();
      addTearDown(bloc.close);
      expect(bloc.state.activeAgentId, 'a1');
      expect(bloc.state.defaultSystemPrompt, 'You are a1');

      const updated = ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteBaseUrl: 'http://localhost:8000/v1',
          remoteModel: 'other');
      final changed = bloc.stream.firstWhere((s) => s.config == updated);
      bloc.add(const ChatSettingsUpdateConfig(config: updated));
      await changed;
      expect((await agents.get('a1'))!.config, updated);

      final deleted = bloc.stream.firstWhere((s) => s.agents.isEmpty);
      bloc.add(const ChatSettingsDeleteAgent(id: 'a1'));
      await deleted;
      expect(await agents.get('a1'), isNull);
    });

    test('empty avatar and description clear them; null keeps them', () async {
      final bloc = await loaded();
      addTearDown(bloc.close);
      var saved = bloc.stream.firstWhere((s) => s.agents.length == 1);
      bloc.add(const ChatSettingsSaveAgent(
        id: 'a1',
        name: 'Writer',
        avatar: '✍️',
        description: 'Writes',
      ));
      await saved;

      saved = bloc.stream.firstWhere((s) => s.agents.single.name == 'Author');
      bloc.add(const ChatSettingsSaveAgent(id: 'a1', name: 'Author'));
      await saved;
      expect(bloc.state.agents.single.avatar, '✍️');
      expect(bloc.state.agents.single.description, 'Writes');

      saved = bloc.stream.firstWhere((s) => s.agents.single.avatar == null);
      bloc.add(const ChatSettingsSaveAgent(
        id: 'a1',
        name: 'Author',
        avatar: ' ',
        description: '',
      ));
      await saved;
      final stored = await agents.get('a1');
      expect(stored!.avatar, isNull);
      expect(stored.description, isNull);
    });

    test('load imports legacy chat_agents once', () async {
      await preferences.setStringList('chat_agents', [
        jsonEncode({
          'id': 'legacy',
          'name': 'Legacy',
          'systemPrompt': 'old prompt',
          'thinkingEnabled': true,
        }),
      ]);
      await preferences.setString('chat_active_agent_id', 'legacy');
      final bloc = await loaded();
      addTearDown(bloc.close);
      expect(bloc.state.agents.map((a) => a.id), ['legacy']);
      expect(bloc.state.activeAgent!.instructions, 'old prompt');
      expect(bloc.state.defaultSystemPrompt, 'old prompt');
      expect((await agents.get('legacy'))!.name, 'Legacy');
    });
  });

  group('ChatBloc sessions belong to agents', () {
    late _Runtime runtime;
    late _Remote remote;
    late _Gemma gemma;

    setUp(() {
      runtime = _Runtime();
      remote = _Remote();
      gemma = _Gemma();
    });

    ChatBloc chat() {
      final bloc = ChatBloc(
        gemmaRepository: gemma,
        remoteRepository: remote,
        storageRepository: storage,
        toolExecutor: ToolExecutor(),
        agentRepository: agents,
        agentRunner: InProcessAgentRunner(runtime),
        preferences: preferences,
      );
      addTearDown(bloc.close);
      return bloc;
    }

    test('a new session records agentId and reload restores the agent',
        () async {
      await agents.save(_agent('x'));
      final bloc = chat();
      final created = bloc.stream.firstWhere((s) => s.conversation != null);
      bloc.add(const ChatNewConversation(
          agentId: 'x',
          config: _remoteConfig,
          thinkingEnabled: true,
          systemPrompt: 'You are x'));
      final id = (await created).conversation!.id;
      expect(bloc.state.conversation!.agentId, 'x');
      // Wait for persistence.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect((await storage.loadConversation(id))!.agentId, 'x');
      expect((await storage.loadConversations(agentId: 'x')).map((c) => c.id),
          [id]);

      final fresh = chat();
      final loaded = fresh.stream.firstWhere((s) => s.conversation?.id == id);
      fresh.add(ChatLoadConversation(id: id));
      await loaded;
      final session = fresh.state.sessionFor(id)!;
      expect(session.agentId, 'x');
      expect(session.config, _remoteConfig);
      expect(session.thinkingEnabled, isTrue);
      expect(session.systemPrompt, 'You are x');
    });

    test('reload of a conversation whose agent was deleted keeps defaults',
        () async {
      await storage
          .saveConversation(Conversation.create(id: 'c1', agentId: 'gone'));
      final bloc = chat();
      final loaded = bloc.stream.firstWhere((s) => s.conversation?.id == 'c1');
      bloc.add(const ChatLoadConversation(id: 'c1'));
      await loaded;
      final session = bloc.state.sessionFor('c1')!;
      expect(session.config, isNull);
      expect(session.agentId, isNull);
      expect(session.conversation.agentId, 'gone');
    });

    test("the agent's allowedTools reach runStream", () async {
      await agents.save(_agent('x', tools: ['shell', 'web_fetch']));
      final bloc = chat();
      final streaming =
          bloc.stream.firstWhere((s) => s.status == ChatStatus.streaming);
      bloc.add(const ChatSendMessage(
          content: 'hi', config: _remoteConfig, agentId: 'x'));
      await streaming;
      expect(runtime.calls, 1);
      expect(runtime.allowedTools, {'shell', 'web_fetch'});
      final id = bloc.state.conversation!.id;
      expect(bloc.state.conversation!.agentId, 'x');
      expect((await storage.loadConversation(id))!.agentId, 'x');
    });

    Future<String> newConversation(ChatBloc bloc, String agentId) async {
      final before = bloc.state.conversation?.id;
      final created = bloc.stream.firstWhere(
          (s) => s.conversation != null && s.conversation!.id != before);
      bloc.add(ChatNewConversation(
          agentId: agentId, config: _remoteConfig, systemPrompt: 'ui'));
      final id = (await created).conversation!.id;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return id;
    }

    Future<void> sendAndStop(ChatBloc bloc, String id, String agentId) async {
      final streaming = bloc.stream
          .firstWhere((s) => s.sessionFor(id)?.status == ChatStatus.streaming);
      bloc.add(ChatSendMessage(
          conversationId: id,
          content: 'hi',
          config: _remoteConfig,
          agentId: agentId));
      await streaming;
      final stopped = bloc.stream
          .firstWhere((s) => s.sessionFor(id)?.status == ChatStatus.stopped);
      bloc.add(ChatStopGeneration(conversationId: id));
      await stopped;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    const otherConfig = ModelConfig(
        inferenceMode: ChatInferenceMode.remote,
        remoteBaseUrl: 'http://localhost:9000/v1',
        remoteModel: 'other-model');

    test('a run with another active agent keeps the owner and uses its setup',
        () async {
      await agents.save(_agent('x', tools: ['shell']));
      await agents.save(_agent('y', tools: ['web_fetch'])
          .copyWith(config: otherConfig, instructions: 'You are y'));
      final bloc = chat();
      final id = await newConversation(bloc, 'x');

      await sendAndStop(bloc, id, 'y');

      expect((await storage.loadConversation(id))!.agentId, 'x');
      expect(bloc.state.sessionFor(id)!.agentId, 'x');
      expect(runtime.allowedTools, {'shell'});
      expect(runtime.modelConfig!.remoteModel, 'agent-model');
      expect(runtime.history.whereType<SystemMessage>().map((m) => m.content),
          ['You are x']);

      // Regenerate (restart path) also runs as the owner.
      runtime.allowedTools = null;
      final restarted = bloc.stream
          .firstWhere((s) => s.sessionFor(id)?.status == ChatStatus.streaming);
      bloc.add(ChatRegenerateResponse(conversationId: id));
      await restarted;
      expect(runtime.calls, 2);
      expect(runtime.allowedTools, {'shell'});
      expect(runtime.modelConfig!.remoteModel, 'agent-model');
    });

    test('a legacy unowned conversation is claimed once by its first run',
        () async {
      await agents.save(_agent('x', tools: ['shell']));
      await agents.save(_agent('y', tools: ['web_fetch']));
      await storage.saveConversation(Conversation.create(id: 'legacy'));
      final bloc = chat();
      final loaded =
          bloc.stream.firstWhere((s) => s.conversation?.id == 'legacy');
      bloc.add(const ChatLoadConversation(id: 'legacy'));
      await loaded;

      await sendAndStop(bloc, 'legacy', 'x');
      expect((await storage.loadConversation('legacy'))!.agentId, 'x');

      await sendAndStop(bloc, 'legacy', 'y');
      expect((await storage.loadConversation('legacy'))!.agentId, 'x');
      expect(runtime.allowedTools, {'shell'});
    });

    test('selecting another agent in an owned conversation starts a new one',
        () async {
      final x = _agent('x');
      final y = _agent('y').copyWith(config: otherConfig);
      await agents.save(x);
      await agents.save(y);
      final bloc = chat();
      final owned = await newConversation(bloc, 'x');

      // Re-selecting the owner configures the same conversation.
      bloc.add(ChatSelectAgent(agent: x));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.conversation!.id, owned);

      final switched =
          bloc.stream.firstWhere((s) => s.conversation?.id != owned);
      bloc.add(ChatSelectAgent(agent: y));
      final next = (await switched).conversation!;
      expect(next.agentId, 'y');
      expect(bloc.state.sessionFor(next.id)!.config, otherConfig);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect((await storage.loadConversation(next.id))!.agentId, 'y');
      expect((await storage.loadConversation(owned))!.agentId, 'x');
    });

    test('an agent without a tool list allows all tools', () async {
      await agents.save(_agent('y'));
      final bloc = chat();
      final streaming =
          bloc.stream.firstWhere((s) => s.status == ChatStatus.streaming);
      bloc.add(const ChatSendMessage(
          content: 'hi', config: _remoteConfig, agentId: 'y'));
      await streaming;
      expect(runtime.calls, 1);
      expect(runtime.allowedTools, isNull);
    });
  });
}

class _Runtime implements ChatAgentRuntime {
  int calls = 0;
  Set<String>? allowedTools;
  ModelConfig? modelConfig;
  List<Message> history = const [];
  final _controllers = <StreamController<ChatAgentEvent>>[];

  @override
  Stream<ChatAgentEvent> runStream({
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
    calls++;
    this.allowedTools = allowedTools;
    this.modelConfig = modelConfig;
    history = historyMessages;
    final controller = StreamController<ChatAgentEvent>();
    _controllers.add(controller);
    return controller.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

class _Gemma extends GemmaRepository {
  @override
  bool get isReady => true;
}
