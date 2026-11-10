import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/agents/agent_editor_screen.dart';
import 'package:gsmlg/screens/agents/agent_sessions_screen.dart';
import 'package:gsmlg/screens/agents/agents_screen.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'agents_test_support.dart';

void main() {
  late MockChatSettingsBloc settingsBloc;
  late MockChatBloc chatBloc;
  late SharedPreferences preferences;

  setUpAll(() {
    registerFallbackValue(const ChatLoadHistory());
    registerFallbackValue(const ChatSettingsLoad());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    settingsBloc = MockChatSettingsBloc();
    chatBloc = MockChatBloc();
    when(() => settingsBloc.state).thenReturn(
      ChatSettingsState(
        status: ChatSettingsStatus.loaded,
        agents: [
          testAgent(
            'a1',
            name: 'Writer',
            avatar: '✍️',
            description: 'Drafts blog posts',
          ),
          testAgent('a2', name: 'Reviewer'),
        ],
      ),
    );
    when(() => chatBloc.state).thenReturn(
      ChatState(
        conversationHistory: [
          testConversation('c1', agentId: 'a1', title: 'Owned chat'),
          testConversation('c2', title: 'Legacy chat'),
          testConversation('c3', agentId: 'gone', title: 'Orphaned chat'),
        ],
      ),
    );
  });

  Future<void> pump(WidgetTester tester) => pumpChatRoutes(
    tester,
    location: AgentsScreen.path,
    settingsBloc: settingsBloc,
    chatBloc: chatBloc,
    preferences: preferences,
  );

  testWidgets('lists agents from the bloc as cards', (tester) async {
    await pump(tester);

    expect(find.byType(AgentsScreen), findsOneWidget);
    expect(find.text('Writer'), findsOneWidget);
    expect(find.text('✍️'), findsOneWidget);
    expect(find.text('Drafts blog posts'), findsOneWidget);
    expect(find.text('Reviewer'), findsOneWidget);
    expect(find.text('New agent'), findsOneWidget);
    verify(() => settingsBloc.add(const ChatSettingsLoad())).called(1);
    verify(() => chatBloc.add(const ChatLoadHistory())).called(1);
  });

  testWidgets('new agent card opens the editor', (tester) async {
    await pump(tester);

    await tester.tap(find.text('New agent'));
    await tester.pumpAndSettle();

    expect(find.byType(AgentEditorScreen), findsOneWidget);
  });

  testWidgets('card menu opens the editor for that agent', (tester) async {
    await pump(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('agent-card-a1')),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final editor = tester.widget<AgentEditorScreen>(
      find.byType(AgentEditorScreen),
    );
    expect(editor.agentId, 'a1');
  });

  testWidgets('card menu delete asks for confirmation', (tester) async {
    await pump(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('agent-card-a2')),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verifyNever(
      () => settingsBloc.add(any(that: isA<ChatSettingsDeleteAgent>())),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => settingsBloc.add(captureAny(that: isA<ChatSettingsDeleteAgent>())),
    ).captured;
    expect((captured.single as ChatSettingsDeleteAgent).id, 'a2');
  });

  testWidgets('tapping a card opens that agent sessions', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Writer'));
    await tester.pumpAndSettle();

    final sessions = tester.widget<AgentSessionsScreen>(
      find.byType(AgentSessionsScreen),
    );
    expect(sessions.agentId, 'a1');
  });

  testWidgets('unowned and orphaned chats stay reachable under Other chats', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Other chats'), findsOneWidget);
    expect(find.text('Legacy chat'), findsOneWidget);
    expect(find.text('Orphaned chat'), findsOneWidget);
    expect(find.text('Owned chat'), findsNothing);

    await tester.tap(find.text('Legacy chat'));
    await tester.pump();

    final loaded = verify(
      () => chatBloc.add(captureAny(that: isA<ChatLoadConversation>())),
    ).captured;
    expect((loaded.single as ChatLoadConversation).id, 'c2');
    expect(find.byType(ChatScreen), findsOneWidget);
  });
}
