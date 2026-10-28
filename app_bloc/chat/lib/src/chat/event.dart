part of 'bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

final class ChatLoadConversation extends ChatEvent {
  const ChatLoadConversation({required this.id});
  final String id;
}

final class ChatNewConversation extends ChatEvent {
  const ChatNewConversation(
      {this.title,
      this.systemPrompt,
      this.config,
      this.agentId,
      this.thinkingEnabled});
  final String? title;
  final String? systemPrompt;
  final ModelConfig? config;
  final String? agentId;
  final bool? thinkingEnabled;
}

final class ChatUpdateDraft extends ChatEvent {
  const ChatUpdateDraft(
      {this.conversationId,
      required this.text,
      this.selectionBase = -1,
      this.selectionExtent = -1,
      this.attachments = const []});
  final String? conversationId;
  final String text;
  final int selectionBase;
  final int selectionExtent;
  final List<ChatAttachment> attachments;
}

final class ChatConfigureSession extends ChatEvent {
  const ChatConfigureSession(
      {this.conversationId,
      required this.config,
      this.agentId,
      this.thinkingEnabled,
      this.systemPrompt});
  final String? conversationId;
  final ModelConfig config;
  final String? agentId;
  final bool? thinkingEnabled;
  final String? systemPrompt;
}

final class ChatSendMessage extends ChatEvent {
  const ChatSendMessage(
      {required this.content,
      this.conversationId,
      this.config,
      this.agentId,
      this.systemPrompt,
      this.imageBytes,
      this.audioBytes,
      this.attachments = const []});
  final String content;
  final String? conversationId;
  final ModelConfig? config;
  final String? agentId;
  final String? systemPrompt;
  final Uint8List? imageBytes;
  final Uint8List? audioBytes;
  final List<ChatAttachment> attachments;
}

final class ChatStopGeneration extends ChatEvent {
  const ChatStopGeneration({this.conversationId});
  final String? conversationId;
}

final class ChatClearConversation extends ChatEvent {
  const ChatClearConversation({this.conversationId});
  final String? conversationId;
}

final class ChatRegenerateResponse extends ChatEvent {
  const ChatRegenerateResponse({this.messageId, this.conversationId});
  final String? messageId;
  final String? conversationId;
}

final class ChatEditUserMessage extends ChatEvent {
  const ChatEditUserMessage(
      {required this.messageId, required this.content, this.conversationId});
  final String messageId;
  final String content;
  final String? conversationId;
}

final class ChatDeleteConversation extends ChatEvent {
  const ChatDeleteConversation({required this.id});
  final String id;
}

final class ChatLoadHistory extends ChatEvent {
  const ChatLoadHistory();
}

sealed class _ChatRunEvent extends ChatEvent {
  const _ChatRunEvent(this.conversationId, this.runId);
  final String conversationId;
  final String runId;
}

final class _ChatStreamToken extends _ChatRunEvent {
  const _ChatStreamToken(
      super.conversationId, super.runId, this.leg, this.token);
  final int leg;
  final String token;
}

final class _ChatThinkingToken extends _ChatRunEvent {
  const _ChatThinkingToken(
      super.conversationId, super.runId, this.leg, this.content);
  final int leg;
  final String content;
}

final class _ChatResponseMetricsTick extends _ChatRunEvent {
  const _ChatResponseMetricsTick(super.conversationId, super.runId);
}

final class _ChatStreamComplete extends _ChatRunEvent {
  const _ChatStreamComplete(super.conversationId, super.runId, this.leg);
  final int leg;
}

final class _ChatStreamError extends _ChatRunEvent {
  const _ChatStreamError(
      super.conversationId, super.runId, this.leg, this.error);
  final int leg;
  final String error;
}

final class _ChatFunctionCall extends _ChatRunEvent {
  const _ChatFunctionCall(super.conversationId, super.runId, this.leg,
      {required this.name, required this.args});
  final int leg;
  final String name;
  final Map<String, dynamic> args;
}

final class _ChatStartLocal extends _ChatRunEvent {
  const _ChatStartLocal(super.conversationId, super.runId);
}

final class ChatRenameConversation extends ChatEvent {
  const ChatRenameConversation({required this.id, required this.title});
  final String id;
  final String title;
}

final class _ChatTitleReady extends ChatEvent {
  const _ChatTitleReady(this.id);
  final String id;
}
