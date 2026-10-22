import 'package:app_chat/app_chat.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_message_list.dart';

void main() {
  final timestamp = DateTime(2026);

  testWidgets('uses native chat navigation without a second input', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chatMessageListApp(
        isStreaming: false,
        messages: [
          SystemMessage(
            id: 'system',
            content: 'hidden prompt',
            conversationId: 'conversation',
            timestamp: timestamp,
          ),
          UserMessage(
            id: 'user',
            content: 'hello',
            conversationId: 'conversation',
            timestamp: timestamp,
          ),
          AssistantMessage(
            id: 'assistant',
            content: 'hi',
            conversationId: 'conversation',
            timestamp: timestamp,
          ),
        ],
      ),
    );
    expect(find.byType(DmChatView), findsOneWidget);
    expect(find.byType(DmChatInput), findsNothing);
    expect(find.textContaining('hidden prompt'), findsNothing);
    expect(find.byKey(const ValueKey('chat-navigation-user')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('chat-navigation-assistant')),
      findsNothing,
    );
    final view = tester.widget<DmChatView>(find.byType(DmChatView));
    expect(view.theme!.rowSpacing, chatMessageGap);
    expect(
      view.messages.first.blocks.whereType<DmChatTextBlock>().single.text,
      'hello',
    );
  });

  testWidgets('navigation reaches an unbuilt turn in variable-height history', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chatMessageListApp(
        isStreaming: false,
        messages: [
          for (var index = 0; index < 24; index++) ...[
            UserMessage(
              id: 'user-$index',
              content: 'Prompt $index',
              conversationId: 'conversation',
              timestamp: timestamp,
            ),
            AssistantMessage(
              id: 'assistant-$index',
              content: List.filled(
                index % 3 == 0 ? 30 : 4,
                'Answer $index.',
              ).join('\n\n'),
              conversationId: 'conversation',
              timestamp: timestamp,
            ),
          ],
        ],
      ),
    );
    await tester.pumpAndSettle();
    // The reversed list starts with the newest turn; the target is not mounted.
    expect(find.byKey(const ValueKey('user-3')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('chat-navigation-user-3')));
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final target = find.byKey(const ValueKey('user-3'));
    expect(target, findsOneWidget);
    final viewport = tester.getRect(find.byType(DmChatView));
    expect(tester.getRect(target).overlaps(viewport), isTrue);
  });

  testWidgets('touch navigation previews a moving candidate until release', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chatMessageListApp(
        isStreaming: false,
        messages: _navigationMessages(timestamp),
      ),
    );
    await tester.pumpAndSettle();
    final position = _chatMessageListPosition(tester);
    final initialOffset = position.pixels;
    final first = find.byKey(const ValueKey('chat-navigation-user-4'));
    final last = find.byKey(const ValueKey('chat-navigation-user-8'));
    final gesture = await tester.startGesture(tester.getCenter(first));
    await tester.pump();

    expect(_navigationMarkerWidth(tester, first), 20);
    expect(position.pixels, initialOffset);

    await gesture.moveTo(tester.getCenter(last));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_navigationMarkerWidth(tester, first), 8);
    expect(_navigationMarkerWidth(tester, last), 20);
    expect(position.pixels, initialOffset);

    await gesture.up();
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(initialOffset));
    final target = find.byKey(const ValueKey('user-8'));
    expect(target, findsOneWidget);
    expect(
      tester.getRect(target).overlaps(tester.getRect(find.byType(DmChatView))),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cancelling touch navigation clears the candidate without a jump',
    (tester) async {
      await tester.pumpWidget(
        _chatMessageListApp(
          isStreaming: false,
          messages: _navigationMessages(timestamp),
        ),
      );
      await tester.pumpAndSettle();
      final position = _chatMessageListPosition(tester);
      final initialOffset = position.pixels;
      final marker = find.byKey(const ValueKey('chat-navigation-user-4'));
      final gesture = await tester.startGesture(tester.getCenter(marker));
      await tester.pump();
      expect(_navigationMarkerWidth(tester, marker), 20);

      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(_navigationMarkerWidth(tester, marker), 8);
      expect(position.pixels, initialOffset);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows copy, edit, and regenerate actions for messages', (
    tester,
  ) async {
    var editedMessageId = '';
    var editedContent = '';
    var regeneratedMessageId = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            messages: [
              UserMessage(
                id: 'user',
                content: 'hello',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
              ),
              AssistantMessage(
                id: 'assistant',
                content: 'hi',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
              ),
            ],
            onEditUserMessage: (message, content) {
              editedMessageId = message.id;
              editedContent = content;
            },
            onRegenerateResponse: (message) {
              regeneratedMessageId = message.id;
            },
          ),
        ),
      ),
    );

    expect(find.byTooltip('Copy message'), findsNWidgets(2));
    expect(find.byTooltip('Edit message'), findsOneWidget);
    expect(find.byTooltip('Regenerate response'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit message'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'edited hello');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(editedMessageId, 'user');
    expect(editedContent, 'edited hello');

    await tester.tap(find.byTooltip('Regenerate response'));
    await tester.pump();

    expect(regeneratedMessageId, 'assistant');
  });

  testWidgets('shows response info for assistant messages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            messages: [
              AssistantMessage(
                id: 'assistant',
                content: 'hi',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
                responseInfo: const ChatResponseInfo(
                  outputTokens: 42,
                  contextTokens: 128,
                  maxOutputTokens: 2048,
                  duration: Duration(seconds: 2),
                  timeToFirstToken: Duration(milliseconds: 500),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byTooltip('Response info'), findsOneWidget);

    await tester.tap(find.byTooltip('Response info'));
    await tester.pumpAndSettle();

    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('28.0 t/s'), findsOneWidget);
    expect(find.text('TTFT'), findsOneWidget);
    expect(find.text('500ms'), findsOneWidget);
    expect(find.text('Context size'), findsOneWidget);
    expect(find.text('128 tokens'), findsOneWidget);
    expect(find.text('Output tokens'), findsOneWidget);
    expect(find.text('42 tokens'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('2.0s'), findsOneWidget);
  });

  testWidgets('shows an unavailable TTFT without changing legacy speed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            messages: [
              AssistantMessage(
                id: 'assistant',
                content: 'hi',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
                responseInfo: const ChatResponseInfo(
                  outputTokens: 24,
                  duration: Duration(seconds: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Response info'));
    await tester.pumpAndSettle();

    expect(find.text('12.0 t/s'), findsOneWidget);
    expect(find.text('TTFT'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  for (final timeToFirstToken in [
    const Duration(milliseconds: 1200),
    Duration.zero,
  ]) {
    testWidgets(
      'formats ${timeToFirstToken == Duration.zero ? 'zero' : 'long'} TTFT value',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatMessageList(
                messages: [
                  AssistantMessage(
                    id: 'assistant',
                    content: 'hi',
                    conversationId: 'conversation',
                    timestamp: DateTime(2026),
                    responseInfo: ChatResponseInfo(
                      outputTokens: 24,
                      duration: const Duration(seconds: 2),
                      timeToFirstToken: timeToFirstToken,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.byTooltip('Response info'));
        await tester.pumpAndSettle();

        expect(find.text('TTFT'), findsOneWidget);
        expect(
          find.text(timeToFirstToken == Duration.zero ? '0ms' : '1.2s'),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets('renders tool responses before assistant output', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            messages: [
              AssistantMessage(
                id: 'assistant',
                content: 'final answer',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
              ),
              ToolResponseMessage(
                id: 'tool',
                toolName: 'web_search',
                content: '{"ok":true}',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
              ),
            ],
          ),
        ),
      ),
    );

    final toolTop = tester.getTopLeft(find.text('web_search')).dy;
    final assistantTop = tester
        .getTopLeft(find.textContaining('final answer'))
        .dy;

    expect(toolTop, lessThan(assistantTop));
  });

  testWidgets('shows live response speed while assistant is streaming', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            isStreaming: true,
            messages: [
              AssistantMessage(
                id: 'assistant',
                content: 'streaming response',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
                isStreaming: true,
                responseInfo: const ChatResponseInfo(
                  outputTokens: 24,
                  duration: Duration(seconds: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('12.0 t/s'), findsOneWidget);
  });

  testWidgets('does not follow streaming output after the user scrolls up', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chatMessageListApp(
        isStreaming: true,
        messages: _streamingMessages(
          timestamp: timestamp,
          assistantContent: 'Initial streaming response.',
        ),
      ),
    );

    final position = _chatMessageListPosition(tester);
    position.jumpTo(position.minScrollExtent);
    await tester.pump();
    position.jumpTo(position.minScrollExtent + 160);
    await tester.pump();

    final scrolledUpOffset = position.pixels;

    await tester.pumpWidget(
      _chatMessageListApp(
        isStreaming: true,
        messages: _streamingMessages(
          timestamp: timestamp,
          assistantContent:
              'Initial streaming response.\n\n${List.filled(8, 'New generated text.').join('\n')}',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(position.pixels, scrolledUpOffset);
    expect(position.pixels, greaterThan(position.minScrollExtent));
  });

  testWidgets('follows streaming output after the user scrolls back to bottom', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chatMessageListApp(
        isStreaming: true,
        messages: _streamingMessages(
          timestamp: timestamp,
          assistantContent: 'Initial streaming response.',
        ),
      ),
    );

    final position = _chatMessageListPosition(tester);
    position.jumpTo(position.minScrollExtent);
    await tester.pump();

    await tester.pumpWidget(
      _chatMessageListApp(
        isStreaming: true,
        messages: _streamingMessages(
          timestamp: timestamp,
          assistantContent:
              'Initial streaming response.\n\n${List.filled(8, 'New generated text.').join('\n')}',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(position.pixels, position.minScrollExtent);
  });
}

Widget _chatMessageListApp({
  required List<Message> messages,
  required bool isStreaming,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 420,
        child: ChatMessageList(messages: messages, isStreaming: isStreaming),
      ),
    ),
  );
}

List<Message> _navigationMessages(DateTime timestamp) => [
  for (var index = 0; index < 24; index++) ...[
    UserMessage(
      id: 'user-$index',
      content: 'Prompt $index',
      conversationId: 'conversation',
      timestamp: timestamp,
    ),
    AssistantMessage(
      id: 'assistant-$index',
      content: List.filled(8, 'Answer $index.').join('\n\n'),
      conversationId: 'conversation',
      timestamp: timestamp,
    ),
  ],
];

double _navigationMarkerWidth(WidgetTester tester, Finder marker) => tester
    .widget<AnimatedContainer>(
      find.descendant(of: marker, matching: find.byType(AnimatedContainer)),
    )
    .constraints!
    .maxWidth;

List<Message> _streamingMessages({
  required DateTime timestamp,
  required String assistantContent,
}) {
  return [
    for (var index = 0; index < 16; index++)
      UserMessage(
        id: 'user-$index',
        content: 'Earlier message $index\nwith enough text to take space.',
        conversationId: 'conversation',
        timestamp: timestamp,
      ),
    AssistantMessage(
      id: 'assistant-streaming',
      content: assistantContent,
      conversationId: 'conversation',
      timestamp: timestamp,
      isStreaming: true,
    ),
  ];
}

ScrollPosition _chatMessageListPosition(WidgetTester tester) {
  final states = tester.stateList<ScrollableState>(
    find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.controller != null,
    ),
  );
  return states
      .singleWhere((state) => state.position.maxScrollExtent > 0)
      .position;
}
