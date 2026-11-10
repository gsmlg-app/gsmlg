import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/agents/agent_editor_screen.dart';
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
          testConversation('c1', agentId: 'a1', title: 'Blog outline'),
          testConversation('c2', agentId: 'a2', title: 'Code review'),
          testConversation('c3', title: 'Legacy chat'),
          testConversation('c4', agentId: 'a1', title: 'Release notes'),
        ],
      ),
    );
  });

  Future<void> pump(WidgetTester tester, String agentId) => pumpChatRoutes(
    tester,
    location: '/chat/agents/$agentId',
    settingsBloc: settingsBloc,
    chatBloc: chatBloc,
    preferences: preferences,
  );

  testWidgets('lists only that agent conversations', (tester) async {
    await pump(tester, 'a1');

    expect(find.text('Writer'), findsWidgets);
    expect(find.text('Drafts blog posts'), findsOneWidget);
    expect(find.text('Blog outline'), findsOneWidget);
    expect(find.text('Release notes'), findsOneWidget);
    expect(find.text('Code review'), findsNothing);
    expect(find.text('Legacy chat'), findsNothing);
    // The agents home below this route loads history as well.
    verify(
      () => chatBloc.add(const ChatLoadHistory()),
    ).called(greaterThanOrEqualTo(1));
  });

  testWidgets('new chat starts a conversation with the agent set', (
    tester,
  ) async {
    // Like ChatBloc, selecting a new conversation before the screen opens.
    when(() => chatBloc.add(any(that: isA<ChatNewConversation>()))).thenAnswer((
      invocation,
    ) {
      final event =
          invocation.positionalArguments.single as ChatNewConversation;
      when(() => chatBloc.state).thenReturn(
        ChatState(
          conversation: testConversation('new', agentId: event.agentId),
        ),
      );
    });
    await pump(tester, 'a1');

    await tester.tap(find.text('New chat'));
    await tester.pump();

    final captured = verify(
      () => chatBloc.add(captureAny(that: isA<ChatNewConversation>())),
    ).captured;
    final event = captured.single as ChatNewConversation;
    final agent = settingsBloc.state.agents.first;
    expect(event.agentId, 'a1');
    expect(event.config, agent.config);
    expect(event.systemPrompt, agent.instructions);
    expect(event.thinkingEnabled, agent.thinkingEnabled);
    expect(find.byType(ChatScreen), findsOneWidget);
  });

  testWidgets('opening a session loads it in the conversation screen', (
    tester,
  ) async {
    await pump(tester, 'a1');

    await tester.tap(find.text('Release notes'));
    await tester.pump();

    final captured = verify(
      () => chatBloc.add(captureAny(that: isA<ChatLoadConversation>())),
    ).captured;
    expect((captured.single as ChatLoadConversation).id, 'c4');
    expect(find.byType(ChatScreen), findsOneWidget);
  });

  testWidgets('edit opens the agent editor', (tester) async {
    await pump(tester, 'a1');

    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit'));
    await tester.pumpAndSettle();

    final editor = tester.widget<AgentEditorScreen>(
      find.byType(AgentEditorScreen),
    );
    expect(editor.agentId, 'a1');
  });

  testWidgets('shows a not-found message for an unknown agent', (tester) async {
    await pump(tester, 'missing');

    expect(find.text('Agent not found'), findsOneWidget);
  });
}
