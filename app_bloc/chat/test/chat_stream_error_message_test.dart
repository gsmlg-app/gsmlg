import 'package:app_chat/chat_models.dart';
import 'package:chat_bloc/src/chat/stream_error_message.dart';
import 'package:test/test.dart';

void main() {
  test('marks a streaming assistant API error as a visible message', () {
    final now = DateTime(2026, 5, 14, 10, 30);
    final conversation = Conversation(
      id: 'conversation',
      title: 'Remote chat',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      messages: [
        UserMessage(
          id: 'user',
          content: 'hello',
          conversationId: 'conversation',
          timestamp: DateTime(2026),
        ),
        AssistantMessage(
          id: 'assistant',
          content: '',
          conversationId: 'conversation',
          timestamp: DateTime(2026),
          isStreaming: true,
        ),
      ],
    );

    final result = markStreamingAssistantError(
      conversation: conversation,
      streamingMessageId: 'assistant',
      error: 'bad api key',
      isRemote: true,
      now: now,
    );

    expect(result.conversation.updatedAt, now);
    expect(result.messageToSave, isNotNull);
    expect(result.messageToSave!.content, 'API error: bad api key');
    expect(result.messageToSave!.isStreaming, isFalse);
    expect(
      result.conversation.messages.whereType<AssistantMessage>().single,
      result.messageToSave,
    );
  });
}
