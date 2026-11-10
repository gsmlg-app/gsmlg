import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/chat/chat_routes.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockChatBloc extends MockBloc<ChatEvent, ChatState> implements ChatBloc {}

class MockGemmaModelBloc extends MockBloc<GemmaModelEvent, GemmaModelState>
    implements GemmaModelBloc {}

class MockChatSettingsBloc
    extends MockBloc<ChatSettingsEvent, ChatSettingsState>
    implements ChatSettingsBloc {}

AgentDefinition testAgent(
  String id, {
  String? name,
  String? avatar,
  String? description,
  List<String>? allowedTools,
}) => AgentDefinition(
  id: id,
  name: name ?? 'Agent $id',
  avatar: avatar,
  description: description,
  instructions: 'You are $id',
  config: const ModelConfig(
    inferenceMode: ChatInferenceMode.remote,
    remoteModel: 'test-model',
  ),
  thinkingEnabled: true,
  allowedTools: allowedTools,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Conversation testConversation(String id, {String? agentId, String? title}) =>
    Conversation(
      id: id,
      title: title ?? 'Conversation $id',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2, 10, 30),
      agentId: agentId,
    );

/// Pumps the real chat route tree at [location].
Future<GoRouter> pumpChatRoutes(
  WidgetTester tester, {
  required String location,
  required ChatSettingsBloc settingsBloc,
  required ChatBloc chatBloc,
  required SharedPreferences preferences,
  ToolExecutor? toolExecutor,
  GemmaModelBloc? gemmaModelBloc,
  bool settle = true,
}) async {
  final gemma = gemmaModelBloc ?? MockGemmaModelBloc();
  if (gemmaModelBloc == null) {
    when(() => gemma.state).thenReturn(const GemmaModelState());
  }
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(initialLocation: location, routes: [chatRoutes()]);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>.value(value: preferences),
        RepositoryProvider<ToolExecutor>.value(
          value: toolExecutor ?? ToolExecutor(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ChatSettingsBloc>.value(value: settingsBloc),
          BlocProvider<ChatBloc>.value(value: chatBloc),
          BlocProvider<GemmaModelBloc>.value(value: gemma),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          routerConfig: router,
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return router;
}

/// A real [ChatBloc] and [ChatSettingsBloc] over an in-memory database with
/// active agent `a1` and its stored conversation `c1` ("Release notes").
class RealChatHarness {
  RealChatHarness._(
    this.preferences,
    this.settingsBloc,
    this.chatBloc,
    this.tools,
  );

  final SharedPreferences preferences;
  final ChatSettingsBloc settingsBloc;
  final ChatBloc chatBloc;
  final ToolExecutor tools;

  static Future<RealChatHarness> create(WidgetTester tester) async {
    // The conversation input bar creates an audio recorder.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'),
      (_) async => null,
    );
    SharedPreferences.setMockInitialValues({'chat_active_agent_id': 'a1'});
    final preferences = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting();
    final storage = ChatStorageRepository(database);
    final agents = AgentRepository(database);
    final tools = ToolExecutor();
    final harness = await tester.runAsync(() async {
      await agents.save(testAgent('a1', name: 'Writer'));
      await storage.saveConversation(
        testConversation('c1', agentId: 'a1', title: 'Release notes'),
      );
      final settingsBloc = ChatSettingsBloc(
        repository: storage,
        preferences: preferences,
        agentRepository: agents,
      );
      final loaded = settingsBloc.stream.firstWhere((s) => s.isLoaded);
      settingsBloc.add(const ChatSettingsLoad());
      await loaded;
      final chatBloc = ChatBloc(
        gemmaRepository: GemmaRepository(),
        remoteRepository: _IdleRemote(),
        storageRepository: storage,
        toolExecutor: tools,
        agentRepository: agents,
        agentRunner: InProcessAgentRunner(
          ChatAgentRuntime(
            toolExecutor: tools,
            remoteRepository: _IdleRemote(),
            gemmaRepository: GemmaRepository(),
            storageRepository: storage,
          ),
        ),
      );
      return RealChatHarness._(preferences, settingsBloc, chatBloc, tools);
    });
    addTearDown(() async {
      await tester.runAsync(() async {
        await harness!.chatBloc.close();
        await harness.settingsBloc.close();
        await database.close();
      });
    });
    return harness!;
  }

  Future<GoRouter> pump(WidgetTester tester, String location) => pumpChatRoutes(
    tester,
    location: location,
    settingsBloc: settingsBloc,
    chatBloc: chatBloc,
    preferences: preferences,
    toolExecutor: tools,
    settle: false,
  );

  Future<void> settle(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 100 && !done(); i += 1) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
  }
}

/// Remote model that accepts runs and answers with nothing.
class _IdleRemote implements RemoteLlmRepository {
  @override
  Future<bool> isReady(ModelConfig config) async => true;

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
    String? generationId,
    LogContext? logContext,
  }) => const Stream.empty();

  @override
  Future<void> stopGeneration({String? generationId}) async {}

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
