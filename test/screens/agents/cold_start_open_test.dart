import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';

import 'agents_test_support.dart';

/// Conversation-screen entry with a real ChatBloc and in-memory database,
/// right after launch (nothing selected yet).
void main() {
  testWidgets('cold start: opening a session shows it in the conversation', (
    tester,
  ) async {
    final h = await RealChatHarness.create(tester);
    await h.pump(tester, '/chat/agents/a1');
    await h.settle(
      tester,
      () => find.text('Release notes').evaluate().isNotEmpty,
    );
    expect(h.chatBloc.state.conversation, isNull);

    await tester.tap(find.text('Release notes'));
    // Build the conversation screen before storage answers the load, as on
    // a cold start.
    await tester.pump();
    await h.settle(tester, () => h.chatBloc.state.conversation?.id == 'c1');
    // Let any competing "nothing selected" start run too.
    await h.settle(tester, () => false);

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(h.chatBloc.state.conversation?.id, 'c1');
    expect(h.chatBloc.state.conversation?.agentId, 'a1');
    expect(h.chatBloc.state.conversationHistory.map((c) => c.id), ['c1']);
  });

  testWidgets('opening the conversation screen with nothing selected starts '
      'a conversation with the active agent', (tester) async {
    final h = await RealChatHarness.create(tester);
    await h.pump(tester, '/chat/conversation');
    await h.settle(tester, () => h.chatBloc.state.conversation != null);

    final conversation = h.chatBloc.state.conversation!;
    expect(conversation.agentId, 'a1');
    final session = h.chatBloc.state.sessionFor(conversation.id)!;
    expect(session.agentId, 'a1');
    expect(session.config, testAgent('a1').config);
    expect(session.systemPrompt, testAgent('a1').instructions);
  });
}
