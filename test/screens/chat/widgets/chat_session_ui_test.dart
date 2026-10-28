import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';
import 'package:gsmlg/screens/chat/widgets/chat_session_status.dart';

void main() {
  testWidgets('draft echo preserves the Android IME composing range', (
    tester,
  ) async {
    var draft = const ChatDraft();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (_, setState) => ChatInputBar(
              conversationId: 'a',
              draft: draft,
              onDraftChanged: (_, value) => setState(() => draft = value),
              onSend: (_, {imageBytes, audioBytes, attachments}) {},
              onStop: () {},
            ),
          ),
        ),
      ),
    );
    await tester.showKeyboard(find.byType(EditableText));
    const composing = TextEditingValue(
      text: 'ni',
      selection: TextSelection.collapsed(offset: 2),
      composing: TextRange(start: 0, end: 2),
    );
    tester.testTextInput.updateEditingValue(composing);
    await tester.pump();
    final controller = tester
        .widget<DmChatInput>(find.byType(DmChatInput))
        .controller!;
    expect(controller.value, composing);
    expect(draft.text, 'ni');
  });

  testWidgets('switching sessions restores text, selection and attachments', (
    tester,
  ) async {
    var selected = 'a';
    final drafts = <String, ChatDraft>{
      'a': const ChatDraft(
        text: 'draft a',
        selectionBase: 2,
        selectionExtent: 4,
        attachments: [ChatAttachment(id: 'a-file', name: 'a.txt')],
      ),
      'b': const ChatDraft(
        text: 'draft b',
        selectionBase: 7,
        selectionExtent: 7,
      ),
    };
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return ChatInputBar(
                conversationId: selected,
                draft: drafts[selected],
                onDraftChanged: (id, draft) =>
                    setState(() => drafts[id!] = draft),
                onSend: (_, {imageBytes, audioBytes, attachments}) {},
                onStop: () {},
              );
            },
          ),
        ),
      ),
    );
    DmChatInput input() => tester.widget<DmChatInput>(find.byType(DmChatInput));
    expect(input().controller!.text, 'draft a');
    expect(
      input().controller!.selection,
      const TextSelection(baseOffset: 2, extentOffset: 4),
    );
    expect(find.text('a.txt'), findsOneWidget);
    rebuild(() => selected = 'b');
    await tester.pump();
    expect(input().controller!.text, 'draft b');
    expect(find.text('a.txt'), findsNothing);
    await tester.enterText(find.byType(EditableText), 'updated b');
    await tester.pump();
    rebuild(() => selected = 'a');
    await tester.pump();
    expect(input().controller!.text, 'draft a');
    expect(find.text('a.txt'), findsOneWidget);
    expect(drafts['b']!.text, 'updated b');
  });

  testWidgets(
    'failed preparation keeps draft; accepted submission clears only its session',
    (tester) async {
      var draft = const ChatDraft(
        text: 'keep until accepted',
        selectionBase: 19,
        selectionExtent: 19,
      );
      late StateSetter rebuild;
      var submissions = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return ChatInputBar(
                  conversationId: 'a',
                  draft: draft,
                  onDraftChanged: (_, value) => setState(() => draft = value),
                  onSend: (_, {imageBytes, audioBytes, attachments}) =>
                      submissions++,
                  onStop: () {},
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();
      expect(submissions, 1);
      expect(draft.text, 'keep until accepted');
      expect(
        tester.widget<DmChatInput>(find.byType(DmChatInput)).controller!.text,
        draft.text,
      );
      rebuild(() => draft = const ChatDraft());
      await tester.pump();
      expect(
        tester.widget<DmChatInput>(find.byType(DmChatInput)).controller!.text,
        isEmpty,
      );
    },
  );

  testWidgets('busy session permits editing the next draft and stopping', (
    tester,
  ) async {
    var draft = const ChatDraft();
    var stopped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (_, setState) => ChatInputBar(
              conversationId: 'a',
              draft: draft,
              isStreaming: true,
              onDraftChanged: (_, value) => setState(() => draft = value),
              onSend: (_, {imageBytes, audioBytes, attachments}) =>
                  fail('must not send'),
              onStop: () => stopped = true,
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(EditableText), 'next message');
    await tester.pump();
    expect(draft.text, 'next message');
    await tester.tap(find.byTooltip('Stop'));
    expect(stopped, isTrue);
  });

  testWidgets(
    'session row shows running, queue, failure, unread and draft states',
    (tester) async {
      final conversation = Conversation.create(id: 'a', title: 'A');
      Future<void> show(ChatSessionState session, {bool draft = false}) =>
          tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ChatSessionStatus(session: session, hasDraft: draft),
              ),
            ),
          );
      await show(
        ChatSessionState(
          conversation: conversation,
          status: ChatStatus.streaming,
          startedAt: DateTime.now(),
          currentActivity: 'Calling search',
        ),
        draft: true,
      );
      expect(find.textContaining('Running'), findsOneWidget);
      expect(find.text('Calling search'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      await show(
        ChatSessionState(
          conversation: conversation,
          status: ChatStatus.queued,
          queuePosition: 2,
        ),
      );
      expect(find.text('Queued · 2'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await show(
        ChatSessionState(conversation: conversation, status: ChatStatus.error),
      );
      expect(find.text('Failed'), findsOneWidget);
      await show(
        ChatSessionState(conversation: conversation, hasUnreadResponse: true),
      );
      expect(find.text('New reply'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
