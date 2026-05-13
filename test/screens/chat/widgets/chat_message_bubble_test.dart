import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_message_bubble.dart';

void main() {
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
          body: ChatMessageBubble(
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
          body: ChatMessageBubble(
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
          body: ChatMessageBubble(
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

  testWidgets('renders assistant markdown instead of raw markdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageBubble(
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
          body: ChatMessageBubble(
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
          body: ChatMessageBubble(
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

    await tester.tap(
      find.byKey(const ValueKey('chat.tool_call.toggle.web_search')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('chat.tool_call.output.web_search')),
      findsOneWidget,
    );
    expect(find.textContaining('"answer"'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('chat.tool_call.toggle.web_search')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('chat.tool_call.output.web_search')),
      findsNothing,
    );
  });

  testWidgets('renders an animated typing indicator while generating', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageBubble(
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
          body: ChatMessageBubble(
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
