import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/agents/agent_sessions_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'agents_test_support.dart';

void main() {
  late AppDatabase database;
  late SharedPreferences preferences;
  late ChatSettingsBloc settingsBloc;
  late MockChatBloc chatBloc;

  setUpAll(() {
    registerFallbackValue(const ChatLoadHistory());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting();
    chatBloc = MockChatBloc();
    when(() => chatBloc.state).thenReturn(const ChatState());
  });

  tearDown(() async {
    await settingsBloc.close();
    await database.close();
  });

  Future<void> loadSettings(WidgetTester tester, [AgentDefinition? agent]) =>
      tester.runAsync(() async {
        if (agent != null) await AgentRepository(database).save(agent);
        settingsBloc = ChatSettingsBloc(
          repository: ChatStorageRepository(database),
          preferences: preferences,
          agentRepository: AgentRepository(database),
        );
        final loaded = settingsBloc.stream.firstWhere((s) => s.isLoaded);
        settingsBloc.add(const ChatSettingsLoad());
        await loaded;
      });

  Future<void> pump(WidgetTester tester, String location) => pumpChatRoutes(
    tester,
    location: location,
    settingsBloc: settingsBloc,
    chatBloc: chatBloc,
    preferences: preferences,
  );

  Future<void> save(WidgetTester tester, bool Function() done) async {
    final button = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(button);
    await tester.tap(button);
    for (var i = 0; i < 50 && !done(); i += 1) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('creates an agent with avatar, description and allowed tools', (
    tester,
  ) async {
    await loadSettings(tester);
    await pump(tester, '/chat/agents/new');

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Writer');
    await tester.enterText(find.widgetWithText(TextField, 'Avatar'), '✍️');
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Drafts blog posts',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Instructions'),
      'Write clearly.',
    );

    final allTools = find.widgetWithText(SwitchListTile, 'All tools');
    await tester.ensureVisible(allTools);
    await tester.tap(allTools);
    await tester.pumpAndSettle();
    final whois = find.widgetWithText(CheckboxListTile, 'whois_lookup');
    await tester.ensureVisible(whois);
    await tester.tap(whois);
    await tester.pumpAndSettle();

    await save(tester, () => settingsBloc.state.agents.isNotEmpty);

    final agent = settingsBloc.state.agents.single;
    expect(agent.name, 'Writer');
    expect(agent.avatar, '✍️');
    expect(agent.description, 'Drafts blog posts');
    expect(agent.instructions, 'Write clearly.');
    // Turning "All tools" off starts from every tool; whois was unchecked.
    expect(agent.allowedTools, isNot(contains('whois_lookup')));
    expect(agent.allowedTools, containsAll(['web_fetch', 'ip_geolocation']));
    // Saving a new agent lands on its sessions screen.
    final sessions = tester.widget<AgentSessionsScreen>(
      find.byType(AgentSessionsScreen),
    );
    expect(sessions.agentId, agent.id);
  });

  testWidgets('edits an agent and resets its tools to all tools', (
    tester,
  ) async {
    await loadSettings(
      tester,
      testAgent(
        'a1',
        name: 'Writer',
        avatar: '✍️',
        description: 'Drafts blog posts',
        allowedTools: ['web_fetch'],
      ),
    );
    await pump(tester, '/chat/agents/a1/edit');

    expect(find.widgetWithText(TextField, 'Writer'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Avatar'), '📝');
    await tester.enterText(find.widgetWithText(TextField, 'Description'), '');

    final webFetch = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'web_fetch'),
    );
    expect(webFetch.value, isTrue);
    final allTools = find.widgetWithText(SwitchListTile, 'All tools');
    await tester.ensureVisible(allTools);
    await tester.tap(allTools);
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNothing);

    final thinking = find.widgetWithText(SwitchListTile, 'Thinking');
    await tester.ensureVisible(thinking);
    await tester.tap(thinking);
    await tester.pumpAndSettle();

    await save(tester, () => settingsBloc.state.agents.single.avatar == '📝');

    final agent = settingsBloc.state.agents.single;
    expect(agent.avatar, '📝');
    expect(agent.description, isNull);
    expect(agent.allowedTools, isNull);
    expect(agent.thinkingEnabled, isFalse);
  });

  testWidgets('requires a name before saving', (tester) async {
    await loadSettings(tester);
    await pump(tester, '/chat/agents/new');

    final button = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(settingsBloc.state.agents, isEmpty);
  });
}
