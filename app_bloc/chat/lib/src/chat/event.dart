part of 'bloc.dart';

/// Events for the ChatBloc.
sealed class ChatEvent {
  const ChatEvent();
}

/// Load an existing conversation by ID.
final class ChatLoadConversation extends ChatEvent {
  const ChatLoadConversation({required this.id});

  final String id;
}

/// Create a new conversation.
final class ChatNewConversation extends ChatEvent {
  const ChatNewConversation({this.title, this.systemPrompt});

  final String? title;
  final String? systemPrompt;
}

/// Send a message and generate a response.
///
/// If no conversation exists, one will be auto-created.
/// [systemPrompt] is used only when auto-creating the conversation.
/// [imageBytes] is optional image data for multimodal models.
/// [attachments] carries files selected from the chat input.
final class ChatSendMessage extends ChatEvent {
  const ChatSendMessage({
    required this.content,
    this.systemPrompt,
    this.imageBytes,
    this.audioBytes,
    this.attachments = const [],
  });

  final String content;
  final String? systemPrompt;
  final Uint8List? imageBytes;
  final Uint8List? audioBytes;
  final List<ChatAttachment> attachments;
}

/// Stop the current response generation.
final class ChatStopGeneration extends ChatEvent {
  const ChatStopGeneration();
}

/// Clear all messages in the current conversation.
final class ChatClearConversation extends ChatEvent {
  const ChatClearConversation();
}

/// Regenerate the last assistant response.
final class ChatRegenerateResponse extends ChatEvent {
  const ChatRegenerateResponse();
}

/// Delete a conversation by ID.
final class ChatDeleteConversation extends ChatEvent {
  const ChatDeleteConversation({required this.id});

  final String id;
}

/// Load conversation history.
final class ChatLoadHistory extends ChatEvent {
  const ChatLoadHistory();
}

/// Internal event for streaming tokens.
final class _ChatStreamToken extends ChatEvent {
  const _ChatStreamToken(this.token);

  final String token;
}

/// Internal event for thinking/reasoning tokens.
final class _ChatThinkingToken extends ChatEvent {
  const _ChatThinkingToken(this.content);

  final String content;
}

/// Internal event for stream completion.
final class _ChatStreamComplete extends ChatEvent {
  const _ChatStreamComplete();
}

/// Internal event for stream errors.
final class _ChatStreamError extends ChatEvent {
  const _ChatStreamError(this.error);

  final String error;
}

/// Internal event when the model requests a function call.
final class _ChatFunctionCall extends ChatEvent {
  const _ChatFunctionCall({required this.name, required this.args});

  final String name;
  final Map<String, dynamic> args;
}
