import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/agents/agent_editor_screen.dart';
import 'package:gsmlg/screens/agents/agent_sessions_screen.dart';
import 'package:gsmlg/screens/agents/agents_screen.dart';
import 'package:gsmlg/screens/chat/chat_history_screen.dart';
import 'package:gsmlg/screens/chat/chat_routes.dart';
import 'package:gsmlg/screens/home/home_routes.dart';
import 'package:gsmlg/screens/home/home_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../agents/agents_test_support.dart';

void main() {
  late MockChatSettingsBloc settingsBloc;
  late MockChatBloc chatBloc;
  late MockGemmaModelBloc gemmaBloc;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    settingsBloc = MockChatSettingsBloc();
    chatBloc = MockChatBloc();
    gemmaBloc = MockGemmaModelBloc();
    when(() => settingsBloc.state).thenReturn(
      ChatSettingsState(
        status: ChatSettingsStatus.loaded,
        agents: [testAgent('writer', name: 'Writer')],
      ),
    );
    when(() => chatBloc.state).thenReturn(
      ChatState(
        conversationHistory: [
          testConversation('owned', agentId: 'writer', title: 'Owned chat'),
          testConversation('legacy', title: 'Legacy chat'),
        ],
      ),
    );
    when(() => gemmaBloc.state).thenReturn(const GemmaModelState());
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(800, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: HomeScreen.path,
      routes: [homeRoutes(), chatRoutes()],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      RepositoryProvider<SharedPreferences>.value(
        value: preferences,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ChatSettingsBloc>.value(value: settingsBloc),
            BlocProvider<ChatBloc>.value(value: chatBloc),
            BlocProvider<GemmaModelBloc>.value(value: gemmaBloc),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HomeScreen', () {
    testWidgets('renders the agents landing page', (tester) async {
      await pump(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AgentsScreen), findsOneWidget);
      expect(find.text('Writer'), findsOneWidget);
      expect(find.text('New agent'), findsOneWidget);
    });

    testWidgets('loads agent settings and conversation history', (
      tester,
    ) async {
      await pump(tester);

      verify(() => settingsBloc.add(const ChatSettingsLoad())).called(1);
      verify(() => chatBloc.add(const ChatLoadHistory())).called(1);
    });

    testWidgets('selects the Home navigation destination', (tester) async {
      await pump(tester);

      final scaffold = tester.widget<AppAdaptiveScaffold>(
        find.byType(AppAdaptiveScaffold),
      );
      expect(scaffold.selectedIndex, 0);
    });

    testWidgets('new agent card opens the editor from Home', (tester) async {
      await pump(tester);
      await tester.tap(find.text('New agent'));
      await tester.pumpAndSettle();

      expect(find.byType(AgentEditorScreen), findsOneWidget);
    });

    testWidgets('agent card opens its sessions from Home', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Writer'));
      await tester.pumpAndSettle();

      final sessions = tester.widget<AgentSessionsScreen>(
        find.byType(AgentSessionsScreen),
      );
      expect(sessions.agentId, 'writer');
    });

    testWidgets('history action opens conversation history from Home', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(ChatHistoryScreen), findsOneWidget);
    });

    testWidgets('shows unowned conversations below the agent cards', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Other chats'), findsOneWidget);
      expect(find.text('Legacy chat'), findsOneWidget);
      expect(find.text('Owned chat'), findsNothing);
    });

    testWidgets('keeps agent controls visible in landscape', (tester) async {
      await pump(tester, size: const Size(1200, 800));

      expect(find.text('Writer'), findsOneWidget);
      expect(find.text('New agent'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
