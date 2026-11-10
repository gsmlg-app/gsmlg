import 'package:app_agent/app_agent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';

import '../agents/agents_test_support.dart';

/// `b2` is ready to send (local endpoint); the active `a1` has no endpoint.
final _reviewer = AgentDefinition(
  id: 'b2',
  name: 'Reviewer',
  config: const ModelConfig(
    inferenceMode: ChatInferenceMode.remote,
    remoteBaseUrl: 'http://localhost:8000/v1',
    remoteModel: 'review-model',
  ),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  Future<RealChatHarness> harness(WidgetTester tester) =>
      RealChatHarness.create(
        tester,
        agents: [_reviewer],
        conversations: [
          testConversation('c2', agentId: 'b2', title: 'Review thread'),
        ],
      );

  ChatInputBar inputBar(WidgetTester tester) =>
      tester.widget<ChatInputBar>(find.byType(ChatInputBar));

  testWidgets('opening another agent\'s session makes its owner active', (
    tester,
  ) async {
    final h = await harness(tester);
    expect(h.settingsBloc.state.activeAgentId, 'a1');

    await h.pump(tester, '/chat/conversation?id=c2');
    await h.settle(
      tester,
      () =>
          h.chatBloc.state.conversation?.id == 'c2' &&
          h.settingsBloc.state.activeAgentId == 'b2',
    );
    await h.settle(tester, () => false);

    expect(find.byType(ChatScreen), findsOneWidget);
    expect(h.chatBloc.state.conversation?.id, 'c2');
    expect(h.settingsBloc.state.activeAgentId, 'b2');
    expect(inputBar(tester).selectedAgentId, 'b2');
    expect(inputBar(tester).selectedAgentName, 'Reviewer');
    expect(inputBar(tester).enabled, isTrue);
  });

  testWidgets('opening a session from the agent sessions screen makes its '
      'owner active', (tester) async {
    final h = await harness(tester);
    await h.pump(tester, '/chat/agents/b2');
    await h.settle(
      tester,
      () => find.text('Review thread').evaluate().isNotEmpty,
    );

    await tester.tap(find.text('Review thread'));
    await tester.pump();
    await h.settle(
      tester,
      () =>
          h.chatBloc.state.conversation?.id == 'c2' &&
          h.settingsBloc.state.activeAgentId == 'b2',
    );
    await h.settle(tester, () => false);

    expect(h.settingsBloc.state.activeAgentId, 'b2');
    expect(inputBar(tester).selectedAgentName, 'Reviewer');
    expect(inputBar(tester).enabled, isTrue);
  });
}
