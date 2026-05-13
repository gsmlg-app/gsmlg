import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
    required RemoteLlmRepository remoteRepository,
    required ChatStorageRepository storageRepository,
    required ToolExecutor toolExecutor,
  })  : _gemmaRepository = gemmaRepository,
        _remoteRepository = remoteRepository,
        _storageRepository = storageRepository,
        _toolExecutor = toolExecutor,
        super(const ChatState()) {
    on<ChatLoadConversation>(_onLoadConversation);
    on<ChatNewConversation>(_onNewConversation);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatStopGeneration>(_onStopGeneration);
    on<ChatClearConversation>(_onClearConversation);
    on<ChatRegenerateResponse>(_onRegenerateResponse);
    on<ChatEditUserMessage>(_onEditUserMessage);
    on<ChatDeleteConversation>(_onDeleteConversation);
    on<ChatLoadHistory>(_onLoadHistory);
    on<_ChatStreamToken>(_onStreamToken);
    on<_ChatThinkingToken>(_onThinkingToken);
    on<_ChatResponseMetricsTick>(_onResponseMetricsTick);
    on<_ChatStreamComplete>(_onStreamComplete);
    on<_ChatStreamError>(_onStreamError);
    on<_ChatFunctionCall>(_onFunctionCall);
  }

  final GemmaRepository _gemmaRepository;
  final RemoteLlmRepository _remoteRepository;
  final ChatStorageRepository _storageRepository;
  final ToolExecutor _toolExecutor;
  StreamSubscription<ChatGenerationChunk>? _streamSubscription;
  Conversation? _streamingConversation;
  String? _streamingMessageId;
  Timer? _responseMetricsTimer;
  ModelConfig? _activeConfig;
  DateTime? _responseStartedAt;
  int? _responseContextTokens;
  int? _responseMaxOutputTokens;
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
          status: _statusForVisibleConversation(),
          conversation: _conversationForDisplay(conversation),
          streamingMessageId: _streamingMessageId,
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
      status: _statusForVisibleConversation(),
      conversation: updatedConversation,
      streamingMessageId: _streamingMessageId,
    ));
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final config = await _storageRepository.loadSettings();
    final readinessError = await _readinessError(config);
    if (readinessError != null) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: readinessError,
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
      imageBytes: event.imageBytes,
      audioBytes: event.audioBytes,
      attachments: event.attachments,
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
    _streamingConversation = updatedConversation;
    _streamingMessageId = assistantMessage.id;

    emit(state.copyWith(
      status: ChatStatus.streaming,
      conversation: updatedConversation,
      streamingMessageId: _streamingMessageId,
    ));

    // Start streaming response
    _beginResponseMetrics(updatedConversation.messages, config);
    _startStreaming(updatedConversation.messages, config);
  }

  void _startStreaming(List<Message> messages, ModelConfig config) {
    _activeConfig = config;
    _streamSubscription?.cancel();
    var sawFunctionCall = false;
    final tools = _toolExecutor.openAiToolDefinitions;
    final stream = config.inferenceMode == ChatInferenceMode.remote
        ? _remoteRepository.generateResponse(
            messages,
            config,
            tools: tools,
          )
        : _gemmaRepository.generateResponse(
            messages,
            tools: tools,
            config: config,
          );
    _streamSubscription = stream.listen(
      (chunk) {
        switch (chunk) {
          case ChatTextChunk(:final text):
            add(_ChatStreamToken(text));
          case ChatThinkingChunk(:final content):
            add(_ChatThinkingToken(content));
          case ChatFunctionCallChunk(:final name, :final args):
            sawFunctionCall = true;
            add(_ChatFunctionCall(name: name, args: args));
        }
      },
      onDone: () {
        if (!sawFunctionCall) add(const _ChatStreamComplete());
      },
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

    final config = _activeConfig ?? await _storageRepository.loadSettings();
    if (config.inferenceMode == ChatInferenceMode.remote) {
      await _remoteRepository.stopGeneration();
    } else {
      await _gemmaRepository.stopGeneration();
    }

    final streamingConversation = _streamingConversation;
    final streamingMessageId = _streamingMessageId;
    if (streamingConversation != null && streamingMessageId != null) {
      // Mark the streaming message as complete
      AssistantMessage? messageToSave;
      final messages = streamingConversation.messages.map((m) {
        if (m.id == streamingMessageId && m is AssistantMessage) {
          final updated = _completeAssistantMessage(m);
          messageToSave = updated;
          return updated;
        }
        return m;
      }).toList();
      final stoppedConversation = streamingConversation.copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
      );
      _streamingConversation = stoppedConversation;
      final savedMessage = messageToSave;
      if (savedMessage != null) {
        await _storageRepository.saveMessage(savedMessage);
      }

      final visibleConversation =
          state.conversation?.id == stoppedConversation.id
              ? stoppedConversation
              : state.conversation;
      _clearActiveStream();
      emit(state.copyWith(
        status: ChatStatus.stopped,
        conversation: visibleConversation,
        clearStreamingMessageId: true,
      ));
    }
    _clearResponseMetrics();
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
    final config = await _storageRepository.loadSettings();
    final readinessError = await _readinessError(config);
    if (readinessError != null) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: readinessError,
      ));
      return;
    }

    final messages = state.conversation!.messages;
    if (messages.isEmpty) return;

    final assistantIndex = event.messageId == null
        ? messages.lastIndexWhere((m) => m is AssistantMessage)
        : messages.indexWhere(
            (m) => m.id == event.messageId && m is AssistantMessage,
          );
    if (assistantIndex == -1) return;

    await _restartFromPrefix(
      retainedMessages: messages.sublist(0, assistantIndex),
      deleteMessages: messages.sublist(assistantIndex),
      config: config,
      emit: emit,
    );
  }

  Future<void> _onEditUserMessage(
    ChatEditUserMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state.conversation == null) return;
    final content = event.content.trim();
    if (content.isEmpty) return;

    final config = await _storageRepository.loadSettings();
    final readinessError = await _readinessError(config);
    if (readinessError != null) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: readinessError,
      ));
      return;
    }

    final messages = state.conversation!.messages;
    final userIndex = messages.indexWhere(
      (m) => m.id == event.messageId && m is UserMessage,
    );
    if (userIndex == -1) return;

    final userMessage = messages[userIndex] as UserMessage;
    final updatedUserMessage = userMessage.copyWith(content: content);
    await _storageRepository.saveMessage(updatedUserMessage);

    final retainedMessages = [
      ...messages.sublist(0, userIndex),
      updatedUserMessage,
    ];
    var title = state.conversation!.title;
    final firstUserIndex = messages.indexWhere((m) => m is UserMessage);
    if (firstUserIndex == userIndex) {
      title = _generateTitle(content);
    }

    await _restartFromPrefix(
      retainedMessages: retainedMessages,
      deleteMessages: messages.sublist(userIndex + 1),
      config: config,
      emit: emit,
      title: title,
    );
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

  Future<void> _restartFromPrefix({
    required List<Message> retainedMessages,
    required List<Message> deleteMessages,
    required ModelConfig config,
    required Emitter<ChatState> emit,
    String? title,
  }) async {
    final conversation = state.conversation;
    if (conversation == null) return;

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    for (final message in deleteMessages) {
      await _storageRepository.deleteMessage(message.id);
    }

    final trimmedConversation = conversation.copyWith(
      title: title,
      messages: retainedMessages,
      updatedAt: DateTime.now(),
    );
    await _storageRepository.saveConversation(trimmedConversation);

    final newAssistantMessage = AssistantMessage(
      id: _uuid.v4(),
      content: '',
      conversationId: conversation.id,
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    final streamingConversation = trimmedConversation.copyWith(
      messages: [...retainedMessages, newAssistantMessage],
    );
    _streamingConversation = streamingConversation;
    _streamingMessageId = newAssistantMessage.id;

    emit(state.copyWith(
      status: ChatStatus.streaming,
      conversation: streamingConversation,
      streamingMessageId: _streamingMessageId,
      clearErrorMessage: true,
    ));

    _beginResponseMetrics(retainedMessages, config);
    _startStreaming(retainedMessages, config);
  }

  void _onStreamToken(
    _ChatStreamToken event,
    Emitter<ChatState> emit,
  ) {
    final didUpdate = _updateStreamingAssistant(
      (message) => _withResponseInfo(
        message.copyWith(content: message.content + event.token),
      ),
    );
    if (!didUpdate) return;
    _emitStreamingConversationIfVisible(emit);
  }

  void _onThinkingToken(
    _ChatThinkingToken event,
    Emitter<ChatState> emit,
  ) {
    final didUpdate = _updateStreamingAssistant(
      (message) => _withResponseInfo(
        message.copyWith(
          thinkingContent: (message.thinkingContent ?? '') + event.content,
        ),
      ),
    );
    if (!didUpdate) return;
    _emitStreamingConversationIfVisible(emit);
  }

  void _onResponseMetricsTick(
    _ChatResponseMetricsTick event,
    Emitter<ChatState> emit,
  ) {
    if (_responseStartedAt == null) return;
    final didUpdate = _updateStreamingAssistant(_withResponseInfo);
    if (!didUpdate) return;
    _emitStreamingConversationIfVisible(emit);
  }

  Future<void> _onStreamComplete(
    _ChatStreamComplete event,
    Emitter<ChatState> emit,
  ) async {
    _streamSubscription = null;

    final streamingConversation = _streamingConversation;
    final streamingMessageId = _streamingMessageId;
    if (streamingConversation == null || streamingMessageId == null) return;

    // Check if the assistant message is empty (0 tokens generated)
    final streamingMsg = streamingConversation.messages
        .whereType<AssistantMessage>()
        .where((m) => m.id == streamingMessageId)
        .firstOrNull;
    final hasContent = streamingMsg != null &&
        (streamingMsg.content.trim().isNotEmpty ||
            (streamingMsg.thinkingContent?.trim().isNotEmpty ?? false));

    if (!hasContent) {
      // Model returned empty response — report error instead of saving blank
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Model generated an empty response. Try switching to CPU '
            'backend in settings, or select a different model.',
        clearStreamingMessageId: true,
      ));
      _clearActiveStream();
      _clearResponseMetrics();
      return;
    }

    AssistantMessage? messageToSave;
    final messages = streamingConversation.messages.map((m) {
      if (m.id == streamingMessageId && m is AssistantMessage) {
        final completed = _completeAssistantMessage(m);
        messageToSave = completed;
        return completed;
      }
      return m;
    }).toList();
    final completedConversation = streamingConversation.copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
    );
    _streamingConversation = completedConversation;
    final savedMessage = messageToSave;
    if (savedMessage != null) {
      await _storageRepository.saveMessage(savedMessage);
    }

    final visibleConversation =
        state.conversation?.id == completedConversation.id
            ? completedConversation
            : state.conversation;
    _clearActiveStream();
    emit(state.copyWith(
      status: ChatStatus.ready,
      conversation: visibleConversation,
      clearStreamingMessageId: true,
    ));
    _clearResponseMetrics();
  }

  Future<void> _onFunctionCall(
    _ChatFunctionCall event,
    Emitter<ChatState> emit,
  ) async {
    // Pause generation while executing the tool
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    final streamingConversation = _streamingConversation;
    final streamingMessageId = _streamingMessageId;
    if (streamingConversation == null || streamingMessageId == null) return;

    // Execute the tool
    final result = await _toolExecutor.execute(event.name, event.args);

    // Create a ToolResponseMessage
    final toolMsg = ToolResponseMessage(
      id: _uuid.v4(),
      toolName: event.name,
      content: jsonEncode(result),
      conversationId: streamingConversation.id,
      timestamp: DateTime.now(),
    );

    // Add tool response to conversation
    final updatedConversation = streamingConversation.addMessage(toolMsg);
    await _storageRepository.saveMessage(toolMsg);

    _streamingConversation = updatedConversation;

    _emitStreamingConversationIfVisible(emit);

    // Resume generation — feed all messages (including tool response) back
    final config = _activeConfig ?? await _storageRepository.loadSettings();
    _startStreaming(updatedConversation.messages, config);
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
    _clearActiveStream();
    _clearResponseMetrics();
  }

  ChatStatus _statusForVisibleConversation() {
    return _streamingConversation == null
        ? ChatStatus.ready
        : ChatStatus.streaming;
  }

  Conversation _conversationForDisplay(Conversation conversation) {
    final streamingConversation = _streamingConversation;
    if (streamingConversation != null &&
        streamingConversation.id == conversation.id) {
      return streamingConversation;
    }
    return conversation;
  }

  bool _updateStreamingAssistant(
    AssistantMessage Function(AssistantMessage message) update,
  ) {
    final streamingConversation = _streamingConversation;
    final streamingMessageId = _streamingMessageId;
    if (streamingConversation == null || streamingMessageId == null) {
      return false;
    }

    var didUpdate = false;
    final messages = streamingConversation.messages.map((message) {
      if (message.id == streamingMessageId && message is AssistantMessage) {
        didUpdate = true;
        return update(message);
      }
      return message;
    }).toList();

    if (!didUpdate) return false;
    _streamingConversation = streamingConversation.copyWith(messages: messages);
    return true;
  }

  void _emitStreamingConversationIfVisible(Emitter<ChatState> emit) {
    final streamingConversation = _streamingConversation;
    if (streamingConversation == null) return;

    emit(
      state.copyWith(
        status: ChatStatus.streaming,
        conversation: state.conversation?.id == streamingConversation.id
            ? streamingConversation
            : state.conversation,
        streamingMessageId: _streamingMessageId,
      ),
    );
  }

  void _clearActiveStream() {
    _streamingConversation = null;
    _streamingMessageId = null;
  }

  void _beginResponseMetrics(
      List<Message> contextMessages, ModelConfig config) {
    _responseMetricsTimer?.cancel();
    _responseStartedAt = DateTime.now();
    _responseContextTokens = _estimateContextTokens(contextMessages);
    _responseMaxOutputTokens = config.maxTokens;
    _responseMetricsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const _ChatResponseMetricsTick());
    });
  }

  AssistantMessage _completeAssistantMessage(AssistantMessage message) {
    return _withResponseInfo(message).copyWith(isStreaming: false);
  }

  AssistantMessage _withResponseInfo(AssistantMessage message) {
    final responseText = [
      message.content,
      if (message.thinkingContent != null) message.thinkingContent!,
    ].where((part) => part.trim().isNotEmpty).join('\n');
    final outputTokens = _estimateTokenCount(responseText);
    final startedAt = _responseStartedAt ?? message.timestamp;
    final responseInfo = ChatResponseInfo(
      outputTokens: outputTokens,
      contextTokens: _responseContextTokens,
      maxOutputTokens: _responseMaxOutputTokens,
      duration: DateTime.now().difference(startedAt),
    );

    return message.copyWith(
        tokenCount: outputTokens, responseInfo: responseInfo);
  }

  void _clearResponseMetrics() {
    _responseMetricsTimer?.cancel();
    _responseMetricsTimer = null;
    _responseStartedAt = null;
    _responseContextTokens = null;
    _responseMaxOutputTokens = null;
  }

  int _estimateContextTokens(List<Message> messages) {
    var total = 0;
    for (final message in messages) {
      if (message is AssistantMessage && message.isStreaming) continue;
      final content = switch (message) {
        final UserMessage user => user.contentWithAttachments(),
        final ToolResponseMessage tool =>
          'Tool response from ${tool.toolName}:\n${tool.content}',
        _ => message.content,
      };
      total += _estimateTokenCount(content);
    }
    return total;
  }

  int _estimateTokenCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return (trimmed.length / 4).ceil();
  }

  String _generateTitle(String firstMessage) {
    // Generate a title from the first message
    final trimmed = firstMessage.trim();
    if (trimmed.length <= 30) return trimmed;
    return '${trimmed.substring(0, 27)}...';
  }

  Future<String?> _readinessError(ModelConfig config) async {
    if (config.inferenceMode == ChatInferenceMode.remote) {
      final errors = config.validate();
      if (errors.isNotEmpty) return errors.join(', ');
      if (!config.isRemoteConfigured) {
        return 'Remote LLM is not configured';
      }
      if (!await _remoteRepository.isReady(config)) {
        return 'The selected remote LLM account is missing an API key.';
      }
      return null;
    }

    if (!_gemmaRepository.isReady) return 'Model is not loaded';
    return null;
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    _responseMetricsTimer?.cancel();
    await _remoteRepository.dispose();
    return super.close();
  }
}
