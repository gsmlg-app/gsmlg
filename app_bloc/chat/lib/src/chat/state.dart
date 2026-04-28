part of 'bloc.dart';

/// Status of the chat.
enum ChatStatus {
  /// Initial state, no conversation loaded.
  initial,

  /// Loading a conversation.
  loading,

  /// Ready to send/receive messages.
  ready,

  /// Currently streaming a response.
  streaming,

  /// Generation was stopped by user.
  stopped,

  /// An error occurred.
  error,
}

/// State for the ChatBloc.
class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.conversation,
    this.conversationHistory = const [],
    this.streamingMessageId,
    this.errorMessage,
  });

  /// Current status of the chat.
  final ChatStatus status;

  /// The current conversation.
  final Conversation? conversation;

  /// List of all conversations for history display.
  final List<Conversation> conversationHistory;

  /// ID of the message currently being streamed.
  final String? streamingMessageId;

  /// Error message if status is error.
  final String? errorMessage;

  @override
  List<Object?> get props => [
        status,
        conversation,
        conversationHistory,
        streamingMessageId,
        errorMessage,
      ];

  /// Whether the chat is currently streaming a response.
  bool get isStreaming => status == ChatStatus.streaming;

  /// Whether the chat is ready to send messages.
  bool get canSendMessage =>
      status == ChatStatus.initial ||
      status == ChatStatus.ready ||
      status == ChatStatus.stopped ||
      status == ChatStatus.error;

  /// Whether there is an active conversation.
  bool get hasConversation => conversation != null;

  /// The messages in the current conversation.
  List<Message> get messages => conversation?.messages ?? [];

  ChatState copyWith({
    ChatStatus? status,
    Conversation? conversation,
    List<Conversation>? conversationHistory,
    String? streamingMessageId,
    bool clearStreamingMessageId = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearConversation = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversation:
          clearConversation ? null : (conversation ?? this.conversation),
      conversationHistory: conversationHistory ?? this.conversationHistory,
      streamingMessageId: clearStreamingMessageId
          ? null
          : (streamingMessageId ?? this.streamingMessageId),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
