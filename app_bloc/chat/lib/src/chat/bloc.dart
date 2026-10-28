import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../backplane/bloc.dart';
import 'stream_error_message.dart';

part 'event.dart';
part 'state.dart';

/// Coordinates independent sessions and the single local inference slot.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required GemmaRepository gemmaRepository,
    required RemoteLlmRepository remoteRepository,
    required ChatStorageRepository storageRepository,
    required ToolExecutor toolExecutor,
    SharedPreferences? preferences,
    BackplaneServiceRepository? backplaneService,
    LocalModelAccess? modelAccess,
  })  : _gemmaRepository = gemmaRepository,
        _remoteRepository = remoteRepository,
        _storageRepository = storageRepository,
        _toolExecutor = toolExecutor,
        _preferences = preferences,
        _backplaneService = backplaneService,
        _modelAccess =
            modelAccess ?? LocalModelAccess.forResource(gemmaRepository),
        super(const ChatState()) {
    on<ChatLoadConversation>(_onLoadConversation);
    on<ChatNewConversation>(_onNewConversation);
    on<ChatUpdateDraft>(_onUpdateDraft);
    on<ChatConfigureSession>(_onConfigureSession);
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
    on<_ChatStartLocal>(_onStartLocal);
  }
  final GemmaRepository _gemmaRepository;
  final RemoteLlmRepository _remoteRepository;
  final ChatStorageRepository _storageRepository;
  final ToolExecutor _toolExecutor;
  final SharedPreferences? _preferences;
  final BackplaneServiceRepository? _backplaneService;
  final LocalModelAccess _modelAccess;
  final _uuid = const Uuid();
  final _tasks = <String, _GenerationTask>{};
  final _localQueue = <_GenerationTask>[];
  final _mutating = <String>{};
  final _deferredDeletes = <String>{};
  final _deleted = <String>{};
  String? _localRunId;
  int _sequence = 0;
  int _navigationVersion = 0;
  bool _closing = false;

  bool _isCurrent(_GenerationTask task) =>
      !_closing && !task.cancelled && identical(_tasks[task.id], task);
  _GenerationTask? _taskFor(_ChatRunEvent event, [int? leg]) {
    final task = _tasks[event.conversationId];
    return task == null ||
            !_isCurrent(task) ||
            task.runId != event.runId ||
            task.finishing ||
            (leg != null && task.leg != leg)
        ? null
        : task;
  }

  void _publish(Emitter<ChatState> emit,
      {Map<String, ChatSessionState>? sessions,
      Map<String, ChatDraft>? drafts,
      List<Conversation>? history,
      String? selectId,
      bool clearSelection = false}) {
    if (emit.isDone || _closing) return;
    final next = sessions ?? state.sessions;
    final id = clearSelection ? null : selectId ?? state.conversation?.id;
    final selected = next[id];
    emit(ChatState(
        status: selected?.status ?? ChatStatus.initial,
        conversation: selected?.conversation,
        streamingMessageId: selected?.streamingMessageId,
        errorMessage: selected?.errorMessage,
        conversationHistory: history ?? state.conversationHistory,
        sessions: Map.unmodifiable(next),
        drafts: Map.unmodifiable(drafts ?? state.drafts)));
  }

  void _putSession(ChatSessionState session, Emitter<ChatState> emit,
      {bool select = false,
      bool updateHistory = false,
      Map<String, ChatDraft>? drafts}) {
    final id = session.conversation.id;
    _publish(emit,
        sessions: {...state.sessions, id: session},
        drafts: drafts,
        selectId: select ? id : null,
        history: updateHistory ? _historyWith(session.conversation) : null);
  }

  List<Conversation> _historyWith(Conversation conversation) {
    return [
      ...state.conversationHistory.where((item) => item.id != conversation.id),
      conversation
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _onLoadConversation(
      ChatLoadConversation event, Emitter<ChatState> emit) async {
    final navigation = ++_navigationVersion;
    if (_deleted.contains(event.id)) return;
    final cached = state.sessions[event.id];
    if (cached != null) {
      _putSession(cached.copyWith(hasUnreadResponse: false), emit,
          select: true);
      return;
    }
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      var conversation = await _storageRepository.loadConversation(event.id);
      if (_closing ||
          navigation != _navigationVersion ||
          _deleted.contains(event.id)) {
        return;
      }
      if (conversation == null) {
        emit(state.copyWith(
            status: ChatStatus.error, errorMessage: 'Conversation not found'));
        return;
      }
      var interrupted = false;
      final messages = conversation.messages.map((message) {
        if (message is AssistantMessage && message.isStreaming) {
          interrupted = true;
          return message.copyWith(isStreaming: false);
        }
        return message;
      }).toList();
      if (interrupted) conversation = conversation.copyWith(messages: messages);
      _putSession(
          ChatSessionState(
              conversation: conversation,
              status: interrupted ? ChatStatus.stopped : ChatStatus.ready),
          emit,
          select: true);
    } catch (error) {
      if (navigation != _navigationVersion || _closing) return;
      emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Failed to load conversation: $error'));
    }
  }

  Conversation _newConversation({String? title, String? systemPrompt}) {
    var conversation = Conversation.create(
        id: _uuid.v4(), title: title ?? 'New Chat', systemPrompt: systemPrompt);
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      conversation = conversation.addMessage(SystemMessage(
          id: _uuid.v4(),
          content: systemPrompt,
          conversationId: conversation.id,
          timestamp: DateTime.now()));
    }
    return conversation;
  }

  Future<void> _onNewConversation(
      ChatNewConversation event, Emitter<ChatState> emit) async {
    ++_navigationVersion;
    final conversation =
        _newConversation(title: event.title, systemPrompt: event.systemPrompt);
    _putSession(
        ChatSessionState(
            conversation: conversation,
            config: event.config,
            agentId: event.agentId,
            thinkingEnabled: event.thinkingEnabled,
            systemPrompt: event.systemPrompt),
        emit,
        select: true,
        updateHistory: true);
    try {
      await _storageRepository.saveConversation(conversation);
      for (final message in conversation.messages) {
        if (_deleted.contains(conversation.id)) break;
        await _storageRepository.saveMessage(message);
      }
      if (_deleted.contains(conversation.id)) {
        await _storageRepository.deleteConversation(conversation.id);
      }
    } catch (error) {
      final session = state.sessions[conversation.id];
      if (!_deleted.contains(conversation.id) &&
          session != null &&
          !session.isBusy) {
        _putSession(
            session.copyWith(
                status: ChatStatus.error,
                errorMessage: 'Failed to save conversation: $error'),
            emit);
      }
    }
  }

  void _onUpdateDraft(ChatUpdateDraft event, Emitter<ChatState> emit) {
    final id = event.conversationId ?? state.conversation?.id ?? '';
    if (_deleted.contains(id)) return;
    _publish(emit, drafts: {
      ...state.drafts,
      id: ChatDraft(
          text: event.text,
          selectionBase: event.selectionBase,
          selectionExtent: event.selectionExtent,
          attachments: List.unmodifiable(event.attachments))
    });
  }

  void _onConfigureSession(
      ChatConfigureSession event, Emitter<ChatState> emit) {
    final id = event.conversationId ?? state.conversation?.id;
    final session = state.sessions[id];
    if (session == null || session.isBusy || _deleted.contains(id)) return;
    _putSession(
        session.copyWith(
            config: event.config,
            agentId: event.agentId,
            thinkingEnabled: event.thinkingEnabled,
            systemPrompt: event.systemPrompt,
            clearAgentId: event.agentId == null,
            clearSystemPrompt: event.systemPrompt == null),
        emit);
  }

  _GenerationTask? _reserve(Conversation conversation, Emitter<ChatState> emit,
      {ModelConfig? config, String? agentId}) {
    final id = conversation.id;
    if (_tasks.containsKey(id) ||
        _mutating.contains(id) ||
        _deferredDeletes.contains(id) ||
        _deleted.contains(id)) {
      return null;
    }
    final session =
        state.sessions[id] ?? ChatSessionState(conversation: conversation);
    final task = _GenerationTask(
        id: id,
        runId: _uuid.v4(),
        order: _sequence++,
        thinkingEnabled: session.thinkingEnabled ?? false,
        systemPrompt: session.config == null
            ? conversation.systemPrompt
            : session.systemPrompt,
        conversation: conversation,
        config: config ?? session.config,
        tools: _toolExecutor.openAiToolDefinitions
            .map((tool) =>
                Map<String, dynamic>.from(jsonDecode(jsonEncode(tool)) as Map))
            .toList());
    _tasks[id] = task;
    _putSession(
        session.copyWith(
            status: ChatStatus.preparing,
            clearError: true,
            clearRun: true,
            config: task.config,
            agentId: agentId,
            hasUnreadResponse: false),
        emit,
        updateHistory: true);
    return task;
  }

  Future<void> _onSendMessage(
      ChatSendMessage event, Emitter<ChatState> emit) async {
    if (event.content.trim().isEmpty &&
        event.attachments.isEmpty &&
        event.imageBytes == null &&
        event.audioBytes == null) {
      return;
    }
    final targetId = event.conversationId ?? state.conversation?.id;
    var conversation = state.sessions[targetId]?.conversation;
    if (conversation == null && targetId != null) return;
    if (conversation == null) {
      ++_navigationVersion;
      conversation = _newConversation(
          title: _generateTitle(event.content),
          systemPrompt: event.systemPrompt);
      _putSession(
          ChatSessionState(
              conversation: conversation, systemPrompt: event.systemPrompt),
          emit,
          select: true);
    }
    final task = _reserve(conversation, emit,
        config: event.config, agentId: event.agentId);
    if (task == null) return;
    final submittedDraft = state.drafts[task.id] ?? state.drafts[''];
    try {
      task.config = await _loadEffectiveConfig(task.config);
      if (!_isCurrent(task)) return;
      final error = await _readinessError(task.config!);
      if (!_isCurrent(task)) return;
      if (error != null) {
        await _failPreparation(task, error, emit);
        return;
      }
      _applySystemPrompt(task);
      final user = UserMessage(
          id: _uuid.v4(),
          content: event.content,
          conversationId: task.id,
          timestamp: DateTime.now(),
          imageBytes: event.imageBytes,
          audioBytes: event.audioBytes,
          attachments: event.attachments);
      task.conversation = task.conversation.addMessage(user);
      if (task.conversation.chatMessages.length == 1) {
        task.conversation =
            task.conversation.copyWith(title: _generateTitle(event.content));
      }
      await _write(task, () async {
        for (final id in task.removedSystemIds) {
          if (!_isCurrent(task)) return;
          await _storageRepository.deleteMessage(id);
        }
        await _storageRepository.saveConversation(task.conversation);
        for (final message in task.conversation.messages) {
          if (!_isCurrent(task)) return;
          await _storageRepository.saveMessage(message);
        }
      });
      if (!_isCurrent(task)) return;
      await _prepareAssistant(task, emit);
      if (!_isCurrent(task)) return;
      final drafts = {...state.drafts};
      if ((drafts[task.id] ?? drafts['']) == submittedDraft) {
        drafts.remove(task.id);
        drafts.remove('');
      }
      _publish(emit, drafts: drafts);
      _schedule(task, emit);
    } catch (error) {
      if (_isCurrent(task)) {
        await _failPreparation(task, error.toString(), emit);
      }
    }
  }

  Future<void> _prepareAssistant(
      _GenerationTask task, Emitter<ChatState> emit) async {
    final assistant = AssistantMessage(
        id: _uuid.v4(),
        content: '',
        conversationId: task.id,
        timestamp: DateTime.now(),
        isStreaming: true);
    task.messageId = assistant.id;
    task.contextTokens = _estimateContextTokens(task.conversation.messages);
    task.conversation = task.conversation.addMessage(assistant);
    await _write(task, () => _storageRepository.saveMessage(assistant));
    if (!_isCurrent(task)) return;
    _putSession(
        state.sessions[task.id]!.copyWith(
            conversation: task.conversation,
            config: task.config,
            streamingMessageId: assistant.id),
        emit,
        updateHistory: true);
    task.prepared = true;
  }

  void _applySystemPrompt(_GenerationTask task) {
    final conversation = task.conversation;
    final old = conversation.messages.whereType<SystemMessage>().toList();
    final prompt = task.systemPrompt;
    final unchanged = old.length == 1 && old.single.content == prompt;
    final system = prompt == null || prompt.isEmpty
        ? null
        : unchanged
            ? old.single
            : SystemMessage(
                id: _uuid.v4(),
                content: prompt,
                conversationId: task.id,
                timestamp: DateTime.now());
    task.removedSystemIds.addAll(old
        .where((message) => message.id != system?.id)
        .map((message) => message.id));
    task.conversation = Conversation(
        id: conversation.id,
        title: conversation.title,
        createdAt: conversation.createdAt,
        updatedAt: conversation.updatedAt,
        systemPrompt: prompt,
        messages: [
          if (system != null) system,
          ...conversation.messages.where((message) => message is! SystemMessage)
        ]);
  }

  Future<void> _failPreparation(
      _GenerationTask task, String error, Emitter<ChatState> emit) async {
    if (!_isCurrent(task)) return;
    if (task.messageId != null) {
      await _finish(task, emit, ChatStatus.error, error: error);
      return;
    }
    task.cancelled = true;
    _tasks.remove(task.id);
    final session = state.sessions[task.id];
    if (session != null) {
      _putSession(
          session.copyWith(
              status: ChatStatus.error, errorMessage: error, clearRun: true),
          emit);
    }
    _drainLocalQueue(emit);
  }

  void _schedule(_GenerationTask task, Emitter<ChatState> emit) {
    if (!_isCurrent(task)) return;
    if (task.config!.inferenceMode == ChatInferenceMode.remote) {
      _beginResponseMetrics(task);
      _markRunning(task, emit);
      _startStreaming(task);
      _drainLocalQueue(emit);
    } else {
      _localQueue.add(task);
      _localQueue.sort((a, b) => a.order.compareTo(b.order));
      _refreshQueue(emit);
      _drainLocalQueue(emit);
    }
  }

  void _refreshQueue(Emitter<ChatState> emit) {
    final sessions = {...state.sessions};
    // The promoted head may still be waiting for a model-management lease.
    final waitingHead = _tasks.values.any((task) =>
        task.runId == _localRunId &&
        _isCurrent(task) &&
        !task.stopwatch.isRunning);
    final offset = waitingHead ? 1 : 0;
    for (var i = 0; i < _localQueue.length; i++) {
      final task = _localQueue[i];
      final session = sessions[task.id];
      if (session != null) {
        sessions[task.id] = session.copyWith(
            status: ChatStatus.queued,
            currentActivity: 'Waiting for local model',
            queuePosition: i + 1 + offset);
      }
    }
    _publish(emit, sessions: sessions);
  }

  void _drainLocalQueue(Emitter<ChatState> emit) {
    if (_closing || _localRunId != null || _localQueue.isEmpty) return;
    _localQueue.removeWhere((task) => !_isCurrent(task));
    if (_localQueue.isEmpty) return;
    final next = _localQueue.first;
    if (_tasks.values.any((task) =>
        task.order < next.order &&
        !task.prepared &&
        (task.config == null ||
            task.config!.inferenceMode == ChatInferenceMode.local))) {
      return;
    }
    _localQueue.removeAt(0);
    _localRunId = next.runId;
    _refreshQueue(emit);
    add(_ChatStartLocal(next.id, next.runId));
  }

  Future<void> _onStartLocal(
      _ChatStartLocal event, Emitter<ChatState> emit) async {
    final task = _taskFor(event);
    if (task == null) return;
    task.localPreparation = Completer<void>();
    try {
      task.localLease = await _modelAccess.acquire();
      if (!_isCurrent(task)) return;
      var config = task.config!.withSupportedBackendForCurrentPlatform();
      final modelId = config.localModelId;
      if (modelId != null) {
        final info = GemmaModelInfo.findById(modelId);
        if (info == null) throw StateError('Unknown local model: $modelId');
        final blockReason = info.localInferenceBlockReason;
        if (blockReason != null) throw StateError(blockReason);
        final kvCacheSize = info.maxKvCacheSize;
        if (kvCacheSize != null && config.maxTokens > kvCacheSize) {
          config = config.copyWith(maxTokens: kvCacheSize);
        }
        if (info.requiresCpuBackendOnDesktop) {
          config = config.copyWith(backend: GemmaBackend.cpu);
        }
        task.config = config;
        await _gemmaRepository.activateModel(info);
        if (!_isCurrent(task)) return;
        await _gemmaRepository.loadModel(config,
            supportImage: info.effectiveSupportsMultimodal,
            supportAudio: info.effectiveSupportsAudio,
            isThinking: task.thinkingEnabled && info.effectiveSupportsThinking,
            supportsFunctionCalls: info.effectiveSupportsFunctionCalls);
      }
      task.config = config;
      if (!_isCurrent(task)) return;
      if (!_gemmaRepository.isReady) throw StateError('Model is not loaded');
      _beginResponseMetrics(task);
      _markRunning(task, emit);
      _startStreaming(task);
    } catch (error) {
      task.localPreparation!.complete();
      if (_isCurrent(task)) {
        await _finish(task, emit, ChatStatus.error, error: error.toString());
      }
    } finally {
      if (!task.localPreparation!.isCompleted) {
        task.localPreparation!.complete();
      }
    }
  }

  void _markRunning(_GenerationTask task, Emitter<ChatState> emit) {
    _putSession(
        state.sessions[task.id]!.copyWith(
            status: ChatStatus.streaming,
            clearError: true,
            startedAt: DateTime.now(),
            currentActivity: 'Waiting for response',
            conversation: task.conversation),
        emit);
    if (task.config!.inferenceMode == ChatInferenceMode.local) {
      _refreshQueue(emit);
    }
  }

  void _startStreaming(_GenerationTask task) {
    if (!_isCurrent(task)) return;
    final leg = ++task.leg;
    var sawFunctionCall = false;
    final config = task.config!;
    final stream = config.inferenceMode == ChatInferenceMode.remote
        ? _remoteRepository.generateResponse(task.conversation.messages, config,
            tools: task.tools, generationId: task.runId)
        : _gemmaRepository.generateResponse(task.conversation.messages,
            tools: task.tools, config: config);
    task.subscription = stream.listen((chunk) {
      if (!_isCurrent(task) || task.leg != leg || task.finishing) return;
      switch (chunk) {
        case ChatTextChunk(:final text):
          if (text.isNotEmpty) task.timeToFirstToken ??= task.stopwatch.elapsed;
          add(_ChatStreamToken(task.id, task.runId, leg, text));
        case ChatThinkingChunk(:final content):
          if (content.isNotEmpty) {
            task.timeToFirstToken ??= task.stopwatch.elapsed;
          }
          add(_ChatThinkingToken(task.id, task.runId, leg, content));
        case ChatFunctionCallChunk(:final name, :final args):
          sawFunctionCall = true;
          add(_ChatFunctionCall(task.id, task.runId, leg,
              name: name, args: args));
      }
    }, onDone: () {
      if (!sawFunctionCall && _isCurrent(task)) {
        add(_ChatStreamComplete(task.id, task.runId, leg));
      }
    }, onError: (Object error) {
      if (_isCurrent(task)) {
        add(_ChatStreamError(task.id, task.runId, leg, error.toString()));
      }
    }, cancelOnError: true);
  }

  void _onStreamToken(_ChatStreamToken event, Emitter<ChatState> emit) {
    final task = _taskFor(event, event.leg);
    if (task == null) return;
    _updateStreamingAssistant(
        task, (m) => m.copyWith(content: m.content + event.token));
    _emitTask(task, emit, activity: event.token.isEmpty ? null : 'Generating');
  }

  void _onThinkingToken(_ChatThinkingToken event, Emitter<ChatState> emit) {
    final task = _taskFor(event, event.leg);
    if (task == null) return;
    _updateStreamingAssistant(
        task,
        (m) => m.copyWith(
            thinkingContent: (m.thinkingContent ?? '') + event.content));
    _emitTask(task, emit, activity: event.content.isEmpty ? null : 'Thinking');
  }

  void _onResponseMetricsTick(
      _ChatResponseMetricsTick event, Emitter<ChatState> emit) {
    final task = _taskFor(event);
    if (task == null) return;
    _updateStreamingAssistant(task, (m) => m);
    _emitTask(task, emit);
  }

  Future<void> _onStreamComplete(
      _ChatStreamComplete event, Emitter<ChatState> emit) async {
    final task = _taskFor(event, event.leg);
    if (task == null) return;
    final assistant = task.conversation.messages
        .whereType<AssistantMessage>()
        .where((m) => m.id == task.messageId)
        .firstOrNull;
    final hasContent = assistant != null &&
        (assistant.content.trim().isNotEmpty ||
            (assistant.thinkingContent?.trim().isNotEmpty ?? false));
    await _finish(task, emit, hasContent ? ChatStatus.ready : ChatStatus.error,
        error: hasContent
            ? null
            : 'Model generated an empty response. Try a different model or backend.');
  }

  Future<void> _onStreamError(
      _ChatStreamError event, Emitter<ChatState> emit) async {
    final task = _taskFor(event, event.leg);
    if (task != null) {
      await _finish(task, emit, ChatStatus.error, error: event.error);
    }
  }

  Future<void> _onFunctionCall(
      _ChatFunctionCall event, Emitter<ChatState> emit) async {
    final task = _taskFor(event, event.leg);
    if (task == null || task.executingTool) return;
    task.executingTool = true;
    try {
      if (task.config!.inferenceMode == ChatInferenceMode.remote) {
        await _remoteRepository.stopGeneration(generationId: task.runId);
      }
      await task.subscription?.cancel();
      task.subscription = null;
      if (!_isCurrent(task)) return;
      _emitTask(task, emit, activity: 'Calling tool: ${event.name}');
      final result = await _toolExecutor.execute(event.name, event.args);
      if (!_isCurrent(task) || task.leg != event.leg) return;
      final message = ToolResponseMessage(
          id: _uuid.v4(),
          toolName: event.name,
          content: jsonEncode(result),
          conversationId: task.id,
          timestamp: DateTime.now());
      task.conversation = task.conversation.addMessage(message);
      await _write(task, () => _storageRepository.saveMessage(message));
      if (!_isCurrent(task)) return;
      _emitTask(task, emit, activity: 'Waiting for response');
      task.executingTool = false;
      _startStreaming(task);
    } catch (error) {
      if (_isCurrent(task)) {
        await _finish(task, emit, ChatStatus.error, error: error.toString());
      }
    }
  }

  void _emitTask(_GenerationTask task, Emitter<ChatState> emit,
      {String? activity}) {
    final session = state.sessions[task.id];
    if (session != null && _isCurrent(task)) {
      _putSession(
          session.copyWith(
              conversation: task.conversation, currentActivity: activity),
          emit);
    }
  }

  void _updateStreamingAssistant(_GenerationTask task,
      AssistantMessage Function(AssistantMessage) update) {
    task.conversation = task.conversation.copyWith(
        messages: task.conversation.messages.map((m) {
      if (m is AssistantMessage && m.id == task.messageId) {
        return _withResponseInfo(task, update(m));
      }
      return m;
    }).toList());
  }

  Future<void> _write(_GenerationTask task, Future<void> Function() action) {
    final write = task.pendingWrites.then((_) async {
      if (_isCurrent(task)) await action();
    });
    // Report failure to the caller while leaving a drainable queue for cancellation.
    task.pendingWrites =
        write.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return write;
  }

  Future<void> _finish(
      _GenerationTask task, Emitter<ChatState> emit, ChatStatus status,
      {String? error}) async {
    if (!_isCurrent(task) || task.finishing) return;
    task.finishing = true;
    task.timer?.cancel();
    task.stopwatch.stop();
    if (error != null && task.messageId != null) {
      task.conversation = markStreamingAssistantError(
              conversation: task.conversation,
              streamingMessageId: task.messageId!,
              error: error,
              isRemote: task.config?.inferenceMode == ChatInferenceMode.remote,
              now: DateTime.now(),
              responseInfo: _responseInfoForText(task, error))
          .conversation;
    } else {
      _updateStreamingAssistant(task, (m) => m.copyWith(isStreaming: false));
      task.conversation = task.conversation.copyWith(updatedAt: DateTime.now());
    }
    try {
      await _write(task, () async {
        for (final message in task.conversation.messages) {
          if (!_isCurrent(task)) return;
          await _storageRepository.saveMessage(message);
        }
        if (_isCurrent(task)) {
          await _storageRepository.saveConversation(task.conversation);
        }
      });
    } catch (saveError) {
      error = 'Failed to save response: $saveError';
      status = ChatStatus.error;
    }
    if (!_isCurrent(task)) return;
    await task.localPreparation?.future;
    await task.subscription?.cancel();
    if (!_isCurrent(task)) return;
    task.localLease?.release();
    _tasks.remove(task.id);
    task.cancelled = true;
    task.subscription = null;
    final session = state.sessions[task.id];
    if (session != null) {
      _putSession(
          session.copyWith(
              conversation: task.conversation,
              status: status,
              errorMessage: error,
              clearError: error == null,
              clearRun: true,
              hasUnreadResponse: state.conversation?.id != task.id),
          emit,
          updateHistory: true);
    }
    if (_localRunId == task.runId) _localRunId = null;
    _drainLocalQueue(emit);
  }

  Future<_GenerationTask?> _cancel(String id) async {
    final task = _tasks.remove(id);
    if (task == null) return null;
    task.cancelled = true;
    task.timer?.cancel();
    task.stopwatch.stop();
    _localQueue.remove(task);
    if (task.config?.inferenceMode == ChatInferenceMode.remote) {
      await _remoteRepository.stopGeneration(generationId: task.runId);
    } else if (task.localLease != null) {
      await _gemmaRepository.stopGeneration();
    }
    await task.subscription?.cancel();
    await task.localPreparation?.future;
    await task.pendingWrites;
    task.localLease?.release();
    if (_localRunId == task.runId) _localRunId = null;
    return task;
  }

  Future<void> _onStopGeneration(
      ChatStopGeneration event, Emitter<ChatState> emit) async {
    final id = event.conversationId ?? state.conversation?.id;
    if (id == null || _mutating.contains(id) || !_tasks.containsKey(id)) return;
    _mutating.add(id);
    try {
      final task = await _cancel(id);
      if (task == null || _deleted.contains(id)) return;
      _updateStreamingAssistant(task, (m) => m.copyWith(isStreaming: false));
      task.conversation = task.conversation.copyWith(updatedAt: DateTime.now());
      for (final message in task.conversation.messages) {
        await _storageRepository.saveMessage(message);
      }
      await _storageRepository.saveConversation(task.conversation);
      final session = state.sessions[id];
      if (session != null) {
        _putSession(
            session.copyWith(
                conversation: task.conversation,
                status: ChatStatus.stopped,
                clearRun: true,
                clearError: true),
            emit,
            updateHistory: true);
      }
    } catch (error) {
      final session = state.sessions[id];
      if (session != null) {
        _putSession(
            session.copyWith(
                status: ChatStatus.error,
                errorMessage: 'Failed to stop generation: $error',
                clearRun: true),
            emit);
      }
    } finally {
      _completeMutation(id);
      _refreshQueue(emit);
      _drainLocalQueue(emit);
    }
  }

  Future<void> _onClearConversation(
      ChatClearConversation event, Emitter<ChatState> emit) async {
    final id = event.conversationId ?? state.conversation?.id;
    if (id == null || _mutating.contains(id)) return;
    final session = state.sessions[id];
    if (session == null) return;
    _mutating.add(id);
    try {
      await _cancel(id);
      await _storageRepository.clearConversationMessages(id);
      final conversation = session.conversation
          .copyWith(messages: [], updatedAt: DateTime.now());
      await _storageRepository.saveConversation(conversation);
      _putSession(
          session.copyWith(
              conversation: conversation,
              status: ChatStatus.ready,
              clearRun: true,
              clearError: true,
              hasUnreadResponse: false),
          emit,
          updateHistory: true,
          drafts: {...state.drafts}..remove(id));
    } catch (error) {
      _putSession(
          session.copyWith(
              status: ChatStatus.error,
              errorMessage: 'Failed to clear conversation: $error',
              clearRun: true),
          emit);
    } finally {
      _completeMutation(id);
      _refreshQueue(emit);
      _drainLocalQueue(emit);
    }
  }

  Future<void> _onDeleteConversation(
      ChatDeleteConversation event, Emitter<ChatState> emit) async {
    final id = event.id;
    if (_mutating.contains(id)) {
      _deferredDeletes.add(id);
      return;
    }
    if (_deleted.contains(id) && !state.sessions.containsKey(id)) return;
    _deleted.add(id);
    _mutating.add(id);
    try {
      await _cancel(id);
      await _storageRepository.deleteConversation(id);
      _publish(emit,
          sessions: {...state.sessions}..remove(id),
          drafts: {...state.drafts}..remove(id),
          history:
              state.conversationHistory.where((item) => item.id != id).toList(),
          clearSelection: state.conversation?.id == id);
    } catch (error) {
      _deleted.remove(id);
      final session = state.sessions[id];
      if (session != null) {
        _putSession(
            session.copyWith(
                status: ChatStatus.error,
                errorMessage: 'Failed to delete conversation: $error',
                clearRun: true),
            emit);
      }
    } finally {
      _completeMutation(id);
      _refreshQueue(emit);
      _drainLocalQueue(emit);
    }
  }

  void _completeMutation(String id) {
    _mutating.remove(id);
    if (_deferredDeletes.remove(id) && !_closing) {
      add(ChatDeleteConversation(id: id));
    }
  }

  Future<void> _onLoadHistory(
      ChatLoadHistory event, Emitter<ChatState> emit) async {
    try {
      final stored = await _storageRepository.loadConversations();
      if (_closing) return;
      final merged = {
        for (final item in stored)
          if (!_deleted.contains(item.id)) item.id: item
      };
      for (final session in state.sessions.values) {
        if (!_deleted.contains(session.conversation.id)) {
          merged[session.conversation.id] = session.conversation;
        }
      }
      _publish(emit,
          history: merged.values.toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
    } catch (_) {/* History failure must not overwrite a running session. */}
  }

  Future<void> _onRegenerateResponse(
      ChatRegenerateResponse event, Emitter<ChatState> emit) async {
    final id = event.conversationId ?? state.conversation?.id;
    final session = state.sessions[id];
    if (session == null) return;
    final messages = session.conversation.messages;
    final index = event.messageId == null
        ? messages.lastIndexWhere((m) => m is AssistantMessage)
        : messages.indexWhere(
            (m) => m.id == event.messageId && m is AssistantMessage);
    if (index < 0) return;
    final task = _reserve(session.conversation, emit);
    if (task == null) return;
    await _restartFromPrefix(task,
        retainedMessages: messages.sublist(0, index),
        deleteMessages: messages.sublist(index),
        emit: emit);
  }

  Future<void> _onEditUserMessage(
      ChatEditUserMessage event, Emitter<ChatState> emit) async {
    final id = event.conversationId ?? state.conversation?.id;
    final session = state.sessions[id];
    final content = event.content.trim();
    if (session == null || content.isEmpty) return;
    final messages = session.conversation.messages;
    final index =
        messages.indexWhere((m) => m.id == event.messageId && m is UserMessage);
    if (index < 0) return;
    final task = _reserve(session.conversation, emit);
    if (task == null) return;
    final user = (messages[index] as UserMessage).copyWith(content: content);
    await _restartFromPrefix(task,
        retainedMessages: [...messages.sublist(0, index), user],
        deleteMessages: messages.sublist(index + 1),
        title: messages.indexWhere((m) => m is UserMessage) == index
            ? _generateTitle(content)
            : null,
        emit: emit);
  }

  Future<void> _restartFromPrefix(_GenerationTask task,
      {required List<Message> retainedMessages,
      required List<Message> deleteMessages,
      required Emitter<ChatState> emit,
      String? title}) async {
    try {
      task.config = await _loadEffectiveConfig(task.config);
      if (!_isCurrent(task)) return;
      final error = await _readinessError(task.config!);
      if (!_isCurrent(task)) return;
      if (error != null) {
        await _failPreparation(task, error, emit);
        return;
      }
      task.conversation = task.conversation.copyWith(
          title: title, messages: retainedMessages, updatedAt: DateTime.now());
      _applySystemPrompt(task);
      await _write(task, () async {
        for (final id in task.removedSystemIds) {
          if (!_isCurrent(task)) return;
          await _storageRepository.deleteMessage(id);
        }
        for (final message in deleteMessages) {
          if (!_isCurrent(task)) return;
          await _storageRepository.deleteMessage(message.id);
        }
        for (final message in task.conversation.messages) {
          if (!_isCurrent(task)) return;
          await _storageRepository.saveMessage(message);
        }
        if (_isCurrent(task)) {
          await _storageRepository.saveConversation(task.conversation);
        }
      });
      if (!_isCurrent(task)) return;
      await _prepareAssistant(task, emit);
      if (_isCurrent(task)) _schedule(task, emit);
    } catch (error) {
      if (_isCurrent(task)) {
        await _failPreparation(task, error.toString(), emit);
      }
    }
  }

  void _beginResponseMetrics(_GenerationTask task) {
    task.stopwatch.start();
    task.timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isCurrent(task)) add(_ChatResponseMetricsTick(task.id, task.runId));
    });
  }

  ChatResponseInfo _responseInfoForText(_GenerationTask task, String text) =>
      ChatResponseInfo(
          outputTokens: _estimateTokenCount(text),
          contextTokens: task.contextTokens,
          maxOutputTokens: task.config?.maxTokens,
          duration: task.stopwatch.elapsed,
          timeToFirstToken: task.timeToFirstToken);
  AssistantMessage _withResponseInfo(
      _GenerationTask task, AssistantMessage message) {
    final text = [
      message.content,
      if (message.thinkingContent != null) message.thinkingContent!
    ].where((part) => part.trim().isNotEmpty).join('\n');
    final info = _responseInfoForText(task, text);
    return message.copyWith(tokenCount: info.outputTokens, responseInfo: info);
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
      if (config.managedRemoteId == BackplaneSettings.managedId) {
        final preferences = _preferences;
        final service = _backplaneService;
        if (preferences == null || service == null) {
          return 'Backplane settings are unavailable.';
        }
        try {
          await service
              .tokenFor(BackplaneSettingsBloc.readSettings(preferences));
        } catch (error) {
          return error.toString();
        }
      }
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

    if (config.localModelId == null && !_gemmaRepository.isReady) {
      return 'Model is not loaded';
    }
    return null;
  }

  Future<ModelConfig> _loadEffectiveConfig([ModelConfig? snapshot]) async {
    final config = snapshot ?? await _storageRepository.loadSettings();
    if (config.managedRemoteId == BackplaneSettings.managedId &&
        _preferences != null) {
      return BackplaneSettingsBloc.readSettings(_preferences)
          .modelConfig(config.remoteModel, base: config);
    }
    if (snapshot != null) return config;
    final preferences = _preferences;
    if (preferences == null) return config;
    final activeId = preferences.getString('chat_active_agent_id');
    if (activeId == null) return config;
    final agents = preferences.getStringList('chat_agents') ?? const <String>[];
    for (final raw in agents) {
      try {
        final agent = jsonDecode(raw);
        if (agent is! Map<String, dynamic> || agent['id'] != activeId) continue;
        final agentConfig = agent['config'];
        if (agentConfig is! Map<String, dynamic> ||
            agentConfig['managedRemoteId'] != BackplaneSettings.managedId) {
          return config;
        }
        final model = agentConfig['remoteModel'];
        if (model is! String) return config;
        return BackplaneSettingsBloc.readSettings(preferences)
            .modelConfig(model, base: config);
      } catch (_) {
        continue;
      }
    }
    return config;
  }

  @override
  Future<void> close() async {
    _closing = true;
    for (final task in _tasks.values.toList()) {
      await _cancel(task.id);
    }
    await _remoteRepository.dispose();
    return super.close();
  }
}

class _GenerationTask {
  _GenerationTask(
      {required this.id,
      required this.runId,
      required this.order,
      required this.conversation,
      required this.config,
      required this.tools,
      required this.thinkingEnabled,
      required this.systemPrompt});
  final String id;
  final String runId;
  final int order;
  final bool thinkingEnabled;
  final String? systemPrompt;
  final removedSystemIds = <String>{};
  Completer<void>? localPreparation;
  LocalModelLease? localLease;
  Conversation conversation;
  ModelConfig? config;
  final List<Map<String, dynamic>> tools;
  String? messageId;
  StreamSubscription<ChatGenerationChunk>? subscription;
  Timer? timer;
  final stopwatch = Stopwatch();
  Duration? timeToFirstToken;
  int? contextTokens;
  int leg = 0;
  bool cancelled = false;
  bool finishing = false;
  bool prepared = false;
  bool executingTool = false;
  Future<void> pendingWrites = Future<void>.value();
}
