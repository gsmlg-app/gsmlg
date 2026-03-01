import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for managing chat conversations with streaming support.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required GemmaRepository gemmaRepository,
    required ChatStorageRepository storageRepository,
  })  : _gemmaRepository = gemmaRepository,
        _storageRepository = storageRepository,
        super(const ChatState()) {
    on<ChatLoadConversation>(_onLoadConversation);
    on<ChatNewConversation>(_onNewConversation);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatStopGeneration>(_onStopGeneration);
    on<ChatClearConversation>(_onClearConversation);
    on<ChatRegenerateResponse>(_onRegenerateResponse);
    on<ChatDeleteConversation>(_onDeleteConversation);
    on<ChatLoadHistory>(_onLoadHistory);
    on<_ChatStreamToken>(_onStreamToken);
    on<_ChatStreamComplete>(_onStreamComplete);
    on<_ChatStreamError>(_onStreamError);
  }

  final GemmaRepository _gemmaRepository;
  final ChatStorageRepository _storageRepository;
  StreamSubscription<String>? _streamSubscription;
  final _uuid = const Uuid();

  Future<void> _onLoadConversation(
    ChatLoadConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final conversation = await _storageRepository.loadConversation(event.id);
      if (conversation != null) {
        emit(state.copyWith(
          status: ChatStatus.ready,
          conversation: conversation,
        ));
      } else {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Conversation not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Failed to load conversation: $e',
      ));
    }
  }

  Future<void> _onNewConversation(
    ChatNewConversation event,
    Emitter<ChatState> emit,
  ) async {
    final conversation = Conversation.create(
      id: _uuid.v4(),
      title: event.title ?? 'New Chat',
      systemPrompt: event.systemPrompt,
    );

    // If system prompt is provided, add it as a system message
    final messages = <Message>[];
    if (event.systemPrompt != null && event.systemPrompt!.isNotEmpty) {
      messages.add(SystemMessage(
        id: _uuid.v4(),
        content: event.systemPrompt!,
        conversationId: conversation.id,
        timestamp: DateTime.now(),
      ));
    }

    final updatedConversation = conversation.copyWith(messages: messages);

    // Save to database
    await _storageRepository.saveConversation(updatedConversation);
    for (final message in messages) {
      await _storageRepository.saveMessage(message);
    }

    emit(state.copyWith(
      status: ChatStatus.ready,
      conversation: updatedConversation,
    ));
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (!_gemmaRepository.isReady) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Model is not loaded',
      ));
      return;
    }

    // Auto-create conversation if none exists
    var conversation = state.conversation;
    if (conversation == null) {
      conversation = Conversation.create(
        id: _uuid.v4(),
        title: _generateTitle(event.content),
        systemPrompt: event.systemPrompt,
      );

      final messages = <Message>[];
      if (event.systemPrompt != null && event.systemPrompt!.isNotEmpty) {
        messages.add(SystemMessage(
          id: _uuid.v4(),
          content: event.systemPrompt!,
          conversationId: conversation.id,
          timestamp: DateTime.now(),
        ));
      }

      conversation = conversation.copyWith(messages: messages);
      await _storageRepository.saveConversation(conversation);
      for (final message in messages) {
        await _storageRepository.saveMessage(message);
      }
    }

    // Create user message
    final userMessage = UserMessage(
      id: _uuid.v4(),
      content: event.content,
      conversationId: conversation.id,
      timestamp: DateTime.now(),
    );

    // Add user message to conversation
    var updatedConversation = conversation.addMessage(userMessage);

    // Update title if this is the first user message
    if (updatedConversation.chatMessages.length == 1) {
      final title = _generateTitle(event.content);
      updatedConversation = updatedConversation.copyWith(title: title);
    }

    // Save user message
    await _storageRepository.saveMessage(userMessage);
    await _storageRepository.saveConversation(updatedConversation);

    // Create placeholder assistant message
    final assistantMessage = AssistantMessage(
      id: _uuid.v4(),
      content: '',
      conversationId: conversation.id,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    updatedConversation = updatedConversation.addMessage(assistantMessage);

    emit(state.copyWith(
      status: ChatStatus.streaming,
      conversation: updatedConversation,
      streamingMessageId: assistantMessage.id,
    ));

    // Start streaming response
    _startStreaming(updatedConversation.messages);
  }

  void _startStreaming(List<Message> messages) {
    _streamSubscription?.cancel();
    _streamSubscription = _gemmaRepository
        .generateResponse(messages)
        .listen(
          (token) => add(_ChatStreamToken(token)),
          onDone: () => add(const _ChatStreamComplete()),
          onError: (error) => add(_ChatStreamError(error.toString())),
          cancelOnError: true,
        );
  }

  Future<void> _onStopGeneration(
    ChatStopGeneration event,
    Emitter<ChatState> emit,
  ) async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    await _gemmaRepository.stopGeneration();

    if (state.conversation != null && state.streamingMessageId != null) {
      // Mark the streaming message as complete
      final messages = state.conversation!.messages.map((m) {
        if (m.id == state.streamingMessageId && m is AssistantMessage) {
          final updated = m.copyWith(isStreaming: false);
          // Save the partial message
          _storageRepository.saveMessage(updated);
          return updated;
        }
        return m;
      }).toList();

      emit(state.copyWith(
        status: ChatStatus.stopped,
        conversation: state.conversation!.copyWith(messages: messages),
        clearStreamingMessageId: true,
      ));
    }
  }

  Future<void> _onClearConversation(
    ChatClearConversation event,
    Emitter<ChatState> emit,
  ) async {
    if (state.conversation == null) return;

    await _storageRepository.clearConversationMessages(state.conversation!.id);

    final clearedConversation = state.conversation!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    await _storageRepository.saveConversation(clearedConversation);

    emit(state.copyWith(
      status: ChatStatus.ready,
      conversation: clearedConversation,
    ));
  }

  Future<void> _onRegenerateResponse(
    ChatRegenerateResponse event,
    Emitter<ChatState> emit,
  ) async {
    if (state.conversation == null) return;
    if (!_gemmaRepository.isReady) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Model is not loaded',
      ));
      return;
    }

    final messages = state.conversation!.messages;
    if (messages.isEmpty) return;

    // Find and remove the last assistant message
    final lastAssistantIndex = messages.lastIndexWhere((m) => m is AssistantMessage);
    if (lastAssistantIndex == -1) return;

    final lastAssistant = messages[lastAssistantIndex];
    await _storageRepository.deleteMessage(lastAssistant.id);

    final updatedMessages = List<Message>.from(messages)..removeAt(lastAssistantIndex);

    // Create new streaming assistant message
    final newAssistantMessage = AssistantMessage(
      id: _uuid.v4(),
      content: '',
      conversationId: state.conversation!.id,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    final finalMessages = [...updatedMessages, newAssistantMessage];

    emit(state.copyWith(
      status: ChatStatus.streaming,
      conversation: state.conversation!.copyWith(messages: finalMessages),
      streamingMessageId: newAssistantMessage.id,
    ));

    // Start streaming response with messages up to (but not including) the new assistant message
    _startStreaming(updatedMessages);
  }

  Future<void> _onDeleteConversation(
    ChatDeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    await _storageRepository.deleteConversation(event.id);

    // If the deleted conversation is the current one, clear it
    if (state.conversation?.id == event.id) {
      emit(state.copyWith(
        status: ChatStatus.initial,
        clearConversation: true,
      ));
    }

    // Refresh history
    add(const ChatLoadHistory());
  }

  Future<void> _onLoadHistory(
    ChatLoadHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final conversations = await _storageRepository.loadConversations();
      emit(state.copyWith(conversationHistory: conversations));
    } catch (e) {
      // History loading failure is not critical
    }
  }

  void _onStreamToken(
    _ChatStreamToken event,
    Emitter<ChatState> emit,
  ) {
    if (state.conversation == null || state.streamingMessageId == null) return;

    final messages = state.conversation!.messages.map((m) {
      if (m.id == state.streamingMessageId && m is AssistantMessage) {
        return m.copyWith(content: m.content + event.token);
      }
      return m;
    }).toList();

    emit(state.copyWith(
      conversation: state.conversation!.copyWith(messages: messages),
    ));
  }

  Future<void> _onStreamComplete(
    _ChatStreamComplete event,
    Emitter<ChatState> emit,
  ) async {
    _streamSubscription = null;

    if (state.conversation == null || state.streamingMessageId == null) return;

    final messages = state.conversation!.messages.map((m) {
      if (m.id == state.streamingMessageId && m is AssistantMessage) {
        final completed = m.copyWith(isStreaming: false);
        // Save the completed message
        _storageRepository.saveMessage(completed);
        return completed;
      }
      return m;
    }).toList();

    emit(state.copyWith(
      status: ChatStatus.ready,
      conversation: state.conversation!.copyWith(messages: messages),
      clearStreamingMessageId: true,
    ));
  }

  void _onStreamError(
    _ChatStreamError event,
    Emitter<ChatState> emit,
  ) {
    _streamSubscription = null;

    emit(state.copyWith(
      status: ChatStatus.error,
      errorMessage: event.error,
      clearStreamingMessageId: true,
    ));
  }

  String _generateTitle(String firstMessage) {
    // Generate a title from the first message
    final trimmed = firstMessage.trim();
    if (trimmed.length <= 30) return trimmed;
    return '${trimmed.substring(0, 27)}...';
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    return super.close();
  }
}
