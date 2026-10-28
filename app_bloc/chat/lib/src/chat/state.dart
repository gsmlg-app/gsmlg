part of 'bloc.dart';

/// Loading belongs to the selected view; generation phases belong to a session.
enum ChatStatus {
  initial,
  loading,
  ready,
  preparing,
  queued,
  streaming,
  stopped,
  error
}

/// In-memory input state, retained when the chat page is not mounted.
class ChatDraft extends Equatable {
  const ChatDraft(
      {this.text = '',
      this.selectionBase = -1,
      this.selectionExtent = -1,
      this.attachments = const []});
  final String text;
  final int selectionBase;
  final int selectionExtent;
  final List<ChatAttachment> attachments;
  bool get isEmpty => text.isEmpty && attachments.isEmpty;
  @override
  List<Object?> get props =>
      [text, selectionBase, selectionExtent, attachments];
}

/// Immutable display state for one conversation. Resource handles stay in Bloc.
class ChatSessionState extends Equatable {
  const ChatSessionState(
      {required this.conversation,
      this.status = ChatStatus.ready,
      this.streamingMessageId,
      this.errorMessage,
      this.config,
      this.agentId,
      this.thinkingEnabled,
      this.systemPrompt,
      this.hasUnreadResponse = false,
      this.startedAt,
      this.currentActivity,
      this.queuePosition});
  final Conversation conversation;
  final ChatStatus status;
  final String? streamingMessageId;
  final String? errorMessage;
  final ModelConfig? config;
  final String? agentId;
  final bool? thinkingEnabled;
  final String? systemPrompt;
  final bool hasUnreadResponse;
  final DateTime? startedAt;
  final String? currentActivity;
  final int? queuePosition;
  bool get isStreaming => status == ChatStatus.streaming;
  bool get isBusy =>
      isStreaming ||
      status == ChatStatus.queued ||
      status == ChatStatus.preparing;
  ChatSessionState copyWith(
          {Conversation? conversation,
          ChatStatus? status,
          String? streamingMessageId,
          String? errorMessage,
          ModelConfig? config,
          String? agentId,
          bool? thinkingEnabled,
          String? systemPrompt,
          bool? hasUnreadResponse,
          DateTime? startedAt,
          String? currentActivity,
          int? queuePosition,
          bool clearRun = false,
          bool clearError = false,
          bool clearAgentId = false,
          bool clearSystemPrompt = false}) =>
      ChatSessionState(
          conversation: conversation ?? this.conversation,
          status: status ?? this.status,
          streamingMessageId:
              clearRun ? null : streamingMessageId ?? this.streamingMessageId,
          errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
          config: config ?? this.config,
          agentId: clearAgentId ? null : agentId ?? this.agentId,
          thinkingEnabled: thinkingEnabled ?? this.thinkingEnabled,
          systemPrompt:
              clearSystemPrompt ? null : systemPrompt ?? this.systemPrompt,
          hasUnreadResponse: hasUnreadResponse ?? this.hasUnreadResponse,
          startedAt: clearRun ? null : startedAt ?? this.startedAt,
          currentActivity:
              clearRun ? null : currentActivity ?? this.currentActivity,
          queuePosition: clearRun ? null : queuePosition ?? this.queuePosition);
  @override
  List<Object?> get props => [
        conversation,
        status,
        streamingMessageId,
        errorMessage,
        config,
        agentId,
        thinkingEnabled,
        systemPrompt,
        hasUnreadResponse,
        startedAt,
        currentActivity,
        queuePosition
      ];
}

/// Session registry plus a compatibility projection of the selected conversation.
class ChatState extends Equatable {
  const ChatState(
      {this.status = ChatStatus.initial,
      this.conversation,
      this.conversationHistory = const [],
      this.streamingMessageId,
      this.errorMessage,
      this.sessions = const {},
      this.drafts = const {}});
  final ChatStatus status;
  final Conversation? conversation;
  final List<Conversation> conversationHistory;
  final String? streamingMessageId;
  final String? errorMessage;
  final Map<String, ChatSessionState> sessions;
  final Map<String, ChatDraft> drafts;
  String? get selectedConversationId => conversation?.id;
  ChatSessionState? sessionFor(String id) => sessions[id];
  ChatSessionState? get currentSession => sessions[selectedConversationId];
  ChatDraft get currentDraft =>
      drafts[selectedConversationId ?? ''] ?? const ChatDraft();
  int get runningCount => sessions.values.where((s) => s.isStreaming).length;
  int get queuedCount =>
      sessions.values.where((s) => s.status == ChatStatus.queued).length;
  bool get isStreaming => status == ChatStatus.streaming;
  bool get isBusy =>
      isStreaming ||
      status == ChatStatus.queued ||
      status == ChatStatus.preparing;
  bool get canSendMessage =>
      status == ChatStatus.initial ||
      status == ChatStatus.ready ||
      status == ChatStatus.stopped ||
      status == ChatStatus.error;
  bool get hasConversation => conversation != null;
  List<Message> get messages => conversation?.messages ?? [];
  @override
  List<Object?> get props => [
        status,
        conversation,
        conversationHistory,
        streamingMessageId,
        errorMessage,
        sessions,
        drafts
      ];
  ChatState copyWith(
          {ChatStatus? status,
          Conversation? conversation,
          List<Conversation>? conversationHistory,
          String? streamingMessageId,
          bool clearStreamingMessageId = false,
          String? errorMessage,
          bool clearErrorMessage = false,
          bool clearConversation = false,
          Map<String, ChatSessionState>? sessions,
          Map<String, ChatDraft>? drafts}) =>
      ChatState(
          status: status ?? this.status,
          conversation:
              clearConversation ? null : conversation ?? this.conversation,
          conversationHistory: conversationHistory ?? this.conversationHistory,
          streamingMessageId: clearStreamingMessageId
              ? null
              : streamingMessageId ?? this.streamingMessageId,
          errorMessage:
              clearErrorMessage ? null : errorMessage ?? this.errorMessage,
          sessions: sessions ?? this.sessions,
          drafts: drafts ?? this.drafts);
}
