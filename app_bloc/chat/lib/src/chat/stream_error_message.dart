import 'package:app_chat/chat_models.dart';

final class StreamingAssistantErrorResult {
  const StreamingAssistantErrorResult({
    required this.conversation,
    required this.messageToSave,
  });

  final Conversation conversation;
  final AssistantMessage? messageToSave;
}

StreamingAssistantErrorResult markStreamingAssistantError({
  required Conversation conversation,
  required String streamingMessageId,
  required String error,
  required bool isRemote,
  required DateTime now,
  ChatResponseInfo? responseInfo,
}) {
  AssistantMessage? messageToSave;
  final messages = conversation.messages.map((message) {
    if (message.id != streamingMessageId || message is! AssistantMessage) {
      return message;
    }

    final updated = message.copyWith(
      content: streamErrorMessage(error: error, isRemote: isRemote),
      isStreaming: false,
      tokenCount: _estimateTokenCount(error),
      responseInfo: responseInfo,
    );
    messageToSave = updated;
    return updated;
  }).toList();

  return StreamingAssistantErrorResult(
    conversation: messageToSave == null
        ? conversation
        : conversation.copyWith(messages: messages, updatedAt: now),
    messageToSave: messageToSave,
  );
}

String streamErrorMessage({required String error, required bool isRemote}) {
  final message = _cleanError(error);
  return isRemote ? 'API error: $message' : 'Generation error: $message';
}

String _cleanError(String error) {
  final trimmed = error.trim();
  if (trimmed.isEmpty) return 'Unknown error';
  const prefixes = ['RemoteLlmException: ', 'Exception: '];
  for (final prefix in prefixes) {
    if (trimmed.startsWith(prefix)) {
      return trimmed.substring(prefix.length).trim();
    }
  }
  return trimmed;
}

int _estimateTokenCount(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  return (trimmed.length / 4).ceil();
}
