import 'package:app_agent/app_agent.dart';
import 'package:app_locale/app_locale.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
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
