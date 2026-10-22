import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:gsmlg/screens/chat/widgets/chat_message_bubble.dart';
import 'package:gsmlg/screens/chat/widgets/chat_message_list.dart';

void main() {
  test('maps native blocks with sanitized text and optional thinking', () {
    final message = AssistantMessage(
      id: 'assistant',
      content: '<think>tagged thought</think>> **web_search** executed\nAnswer',
      thinkingContent: 'structured thought',
      conversationId: 'conversation',
      timestamp: DateTime(2026),
    );
    final visible = toDmChatMessage(message);
    expect(visible.blocks.whereType<DmChatThinkingBlock>(), isEmpty);
    expect(visible.blocks.whereType<DmChatTextBlock>().single.text, 'Answer');
    final expanded = toDmChatMessage(message, showThinking: true);
    expect(
      expanded.blocks.whereType<DmChatThinkingBlock>().single.text,
      'structured thought\ntagged thought',
    );
  });

  test('keeps tool logs literal even when they contain markdown fences', () {
    final mapped = toDmChatMessage(
      ToolResponseMessage(
        id: 'tool',
        toolName: 'logs',
        content: '## log\n**literal** <tag>\n```console\nentry\n```',
        conversationId: 'conversation',
        timestamp: DateTime(2026),
      ),
    );
    final tool = mapped.blocks.single as DmChatToolCallBlock;
    expect(
      tool.output,
      '````text\n## log\n**literal** <tag>\n```console\nentry\n```\n````',
    );
  });

  testWidgets('updates streaming assistant content without build-time errors', (
    tester,
  ) async {
    FlutterErrorDetails? flutterError;
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      flutterError = details;
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    Widget buildBubble(String content) {
      return MaterialApp(
        home: Scaffold(
          body: _messageList(
            showThinking: true,
            message: AssistantMessage(
              id: 'assistant',
              content: content,
              conversationId: 'conversation',
              timestamp: DateTime(2026),
              isStreaming: true,
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildBubble('<think>planning'));
    await tester.pumpWidget(buildBubble('<think>planning</think>final'));
    await tester.pump();

    expect(flutterError, isNull);
    expect(find.textContaining('final'), findsOneWidget);
  });

  testWidgets('rebuilds complete assistant content without build-time errors', (
    tester,
  ) async {
    FlutterErrorDetails? flutterError;
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      flutterError = details;
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    Widget buildBubble() {
      return MaterialApp(
        home: Scaffold(
          body: _messageList(
            message: AssistantMessage(
              id: 'assistant',
              content: 'final answer',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildBubble());
    await tester.pumpWidget(buildBubble());
    await tester.pump();

    expect(flutterError, isNull);
    expect(find.textContaining('final answer'), findsOneWidget);
  });

  testWidgets('renders tagged thinking content as a thinking block', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _messageList(
            showThinking: true,
            message: AssistantMessage(
              id: 'assistant',
              content: '<think>planning</think>final answer',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('<think>'), findsNothing);
    expect(find.textContaining('</think>'), findsNothing);
    expect(find.textContaining('final answer'), findsOneWidget);
  });

  testWidgets('thinking remains hidden unless enabled and can be expanded', (
    tester,
  ) async {
    final message = AssistantMessage(
      id: 'assistant',
      content: '<think>private planning</think>final answer',
      conversationId: 'conversation',
      timestamp: DateTime(2026),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: _messageList(message: message)),
      ),
    );
    expect(find.byType(DmChatThinkingBlockView), findsNothing);
    expect(find.textContaining('private planning'), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _messageList(message: message, showThinking: true),
        ),
      ),
    );
    expect(find.byType(DmChatThinkingBlockView), findsOneWidget);
    await tester.tap(find.byType(DmChatThinkingBlockView));
    await tester.pumpAndSettle();
    expect(find.textContaining('private planning'), findsOneWidget);
  });

  testWidgets('renders assistant markdown instead of raw markdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _messageList(
            message: AssistantMessage(
              id: 'assistant',
              content: '### Heading\n\nThis is **bold** text',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Heading'), findsOneWidget);
    expect(find.textContaining('bold'), findsOneWidget);
    expect(find.textContaining('**bold**'), findsNothing);
  });

  testWidgets('strips persisted tool execution markers from assistant text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _messageList(
            message: AssistantMessage(
              id: 'assistant',
              content: '> **web_search** executed\n\nFinal **answer**',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('web_search'), findsNothing);
    expect(find.textContaining('Final'), findsOneWidget);
  });

  testWidgets('renders tool responses collapsed and toggles details', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _messageList(
            message: ToolResponseMessage(
              id: 'tool',
              toolName: 'web_search',
              content: '{"answer":"42"}',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
            ),
          ),
        ),
      ),
    );

    expect(find.text('web_search'), findsOneWidget);
    expect(find.textContaining('"answer"'), findsNothing);

    await tester.tap(find.text('web_search'));
    await tester.pumpAndSettle();

    expect(find.textContaining('"answer"'), findsOneWidget);

    await tester.tap(find.text('web_search'));
    await tester.pumpAndSettle();

    expect(find.text('Output'), findsNothing);
  });

  testWidgets('renders an animated typing indicator while generating', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _messageList(
            showTypingIndicator: true,
            message: AssistantMessage(
              id: 'assistant',
              content: '',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
              isStreaming: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat.typing_dots')), findsOneWidget);
    expect(find.text('...'), findsNothing);
  });

  testWidgets('renders user file attachments in the sent message bubble', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _messageList(
            message: UserMessage(
              id: 'user',
              content: 'please read this',
              conversationId: 'conversation',
              timestamp: DateTime(2026),
              attachments: const [
                ChatAttachment(
                  id: 'file-1',
                  name: 'notes.txt',
                  sizeBytes: 16,
                  mimeType: 'text/plain',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('notes.txt'), findsOneWidget);
    expect(find.textContaining('please read this'), findsOneWidget);
  });
}

Widget _messageList({
  required Message message,
  bool showThinking = false,
  bool showTypingIndicator = false,
}) => ChatMessageList(
  messages: [message],
  showThinking: showThinking,
  isStreaming:
      showTypingIndicator || message is AssistantMessage && message.isStreaming,
);
