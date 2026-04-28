import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_message_bubble.dart';

void main() {
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
