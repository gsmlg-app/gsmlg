import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_message_list.dart';

void main() {
  testWidgets('renders a gap between visible chat messages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatMessageList(
            messages: [
              SystemMessage(
                id: 'system',
                content: 'system prompt',
                conversationId: 'conversation',
                timestamp: DateTime(2026),
              ),
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
          ),
        ),
      ),
    );

    final gap = tester.widget<SizedBox>(
      find.byKey(const ValueKey('chat_message_gap_0')),
    );

    expect(gap.height, chatMessageGap);
    expect(find.byKey(const ValueKey('chat_message_gap_1')), findsNothing);
  });

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
                  outputTokens: 24,
                  contextTokens: 128,
                  maxOutputTokens: 2048,
                  duration: Duration(seconds: 2),
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
    expect(find.text('12.0 t/s'), findsOneWidget);
    expect(find.text('Context size'), findsOneWidget);
    expect(find.text('128 tokens'), findsOneWidget);
    expect(find.text('Output tokens'), findsOneWidget);
    expect(find.text('24 tokens'), findsOneWidget);
  });

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
}
