import 'package:app_agent/app_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';

import '../agents/agents_test_support.dart';

/// Remote agent `b2` owns `c2`; the active agent `a1` is local, so the screen
/// first renders with `a1`'s settings and then follows the owner.
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

  String fieldText(WidgetTester tester) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byType(ChatInputBar),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;

  Future<void> typeLikeKeyboard(
    WidgetTester tester,
    String text, {
    bool composing = false,
  }) async {
    // Same channel the iOS keyboard uses: the engine pushes the new editing
    // value to the attached client.
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
        composing: composing
            ? TextRange(start: 0, end: text.length)
            : TextRange.empty,
      ),
    );
    await tester.pump();
  }

  testWidgets('first keystroke in an owned session is not duplicated', (
    tester,
  ) async {
    final h = await harness(tester);
    await h.pump(tester, '/chat/conversation?id=c2');
    await h.settle(tester, () => h.chatBloc.state.conversation?.id == 'c2');

    await tester.showKeyboard(
      find.descendant(
        of: find.byType(ChatInputBar),
        matching: find.byType(EditableText),
      ),
    );
    final stateBefore = tester.state(find.byType(ChatInputBar));

    await typeLikeKeyboard(tester, 'a');
    await h.settle(tester, () => false);

    expect(
      tester.state(find.byType(ChatInputBar)),
      same(stateBefore),
      reason: 'the input bar must not be rebuilt from scratch while typing',
    );
    expect(fieldText(tester), 'a');
    expect(h.chatBloc.state.drafts['c2']?.text, 'a');

    await typeLikeKeyboard(tester, 'ab');
    await h.settle(tester, () => false);
    expect(fieldText(tester), 'ab');
  });

  testWidgets('composing (IME marked) text survives the draft echo', (
    tester,
  ) async {
    final h = await harness(tester);
    await h.pump(tester, '/chat/conversation?id=c2');
    await h.settle(tester, () => h.chatBloc.state.conversation?.id == 'c2');
    final field = find.descendant(
      of: find.byType(ChatInputBar),
      matching: find.byType(EditableText),
    );
    await tester.showKeyboard(field);

    await typeLikeKeyboard(tester, 'a', composing: true);
    await h.settle(tester, () => false);

    final value = tester.widget<EditableText>(field).controller.value;
    expect(value.text, 'a');
    expect(
      value.composing,
      const TextRange(start: 0, end: 1),
      reason: 'the draft echo must not clear the IME composing range',
    );
    // Every value pushed back to the platform while composing restarts IME
    // composition on iOS; the echo must not push one.
    final log = tester.testTextInput.log
        .where((c) => c.method == 'TextInput.setEditingState')
        .map((c) => (c.arguments as Map)['text'])
        .toList();
    expect(log.where((t) => t == 'a').length, lessThanOrEqualTo(1));
  });

  testWidgets(
    'draft echo keeps the IME composing range when the platform selection '
    'carries a different affinity',
    (tester) async {
      final h = await harness(tester);
      await h.pump(tester, '/chat/conversation?id=c2');
      await h.settle(tester, () => h.chatBloc.state.conversation?.id == 'c2');
      final field = find.descendant(
        of: find.byType(ChatInputBar),
        matching: find.byType(EditableText),
      );
      await tester.showKeyboard(field);
      tester.testTextInput.log.clear();

      // iOS Pinyin marked text: the engine reports an upstream-affinity caret,
      // which the draft (offsets only) cannot reproduce.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'a',
          selection: TextSelection.collapsed(
            offset: 1,
            affinity: TextAffinity.upstream,
          ),
          composing: TextRange(start: 0, end: 1),
        ),
      );
      await tester.pump();
      // Wait until the ChatBloc echo has rebuilt the input bar.
      await h.settle(
        tester,
        () =>
            tester
                .widget<ChatInputBar>(find.byType(ChatInputBar))
                .draft
                ?.text ==
            'a',
      );

      final value = tester.widget<EditableText>(field).controller.value;
      expect(value.text, 'a');
      expect(
        value.composing,
        const TextRange(start: 0, end: 1),
        reason: 'echoing an unchanged draft must not end IME composition',
      );
      expect(
        tester.testTextInput.log.where(
          (c) => c.method == 'TextInput.setEditingState',
        ),
        isEmpty,
        reason: 'pushing a value back mid-composition makes iOS re-insert it',
      );
    },
  );

  testWidgets('typing right after "New chat" keeps exactly what was typed', (
    tester,
  ) async {
    final h = await harness(tester);
    await h.pump(tester, '/chat/agents/b2');
    await h.settle(tester, () => find.text('New chat').evaluate().isNotEmpty);

    await tester.tap(find.text('New chat'));
    await tester.pump();
    await tester.pump();
    final field = find.descendant(
      of: find.byType(ChatInputBar),
      matching: find.byType(EditableText),
    );
    expect(field, findsOneWidget);
    await tester.showKeyboard(field);
    tester.testTextInput.log.clear();

    // First keystroke arrives before the new conversation is selected.
    await typeLikeKeyboard(tester, 'a', composing: true);
    await h.settle(tester, () => false);

    final value = tester.widget<EditableText>(field).controller.value;
    expect(value.text, 'a');
    expect(value.composing, const TextRange(start: 0, end: 1));
    expect(h.chatBloc.state.conversation?.agentId, 'b2');
  });
}
