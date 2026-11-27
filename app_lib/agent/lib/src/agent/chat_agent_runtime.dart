import 'dart:async';
import 'dart:convert';

import 'package:app_logging/app_logging.dart' show LogCapture;
import 'package:agent_runtime/agent_runtime.dart' as rt;
import 'package:dio/dio.dart';

import '../models/agent_metadata.dart';
import '../models/inference.dart';
import '../models/message.dart' as app_msg;
import '../models/model_config.dart' as app_cfg;
import '../repositories/chat_storage_repository.dart';
import '../repositories/gemma_repository.dart';
import '../repositories/local_model_access.dart';
import '../repositories/remote_llm_repository.dart';
import '../services/agent_session_store.dart';
import '../services/local_llm_gateway.dart';
import '../services/tool_executor.dart';
import 'agent_event.dart';
import 'agent_event_logger.dart';
import 'memory_provider.dart';
import 'plugin_consumer.dart';
import 'repository_agent_llm_client.dart';
import 'shell_service.dart';
import 'skill_registry.dart';
import 'sub_agent_supervisor.dart';
import 'tool_gateway.dart';

/// Hook connecting StatefulAgent lifecycle to the ToolExecutionGateway,
/// agent-owned persistence, and application UI events.
class _AgentGatewayHook extends rt.AgentHook {
  _AgentGatewayHook({
    required this.runId,
    required this.sessionId,
    required this.gateway,
    required this.emit,
    required this.model,
    required this.awaitAcknowledgements,
    required this.onTurnStarted,
    required this.onTurnCompleted,
    required this.hasStore,
  });

  final String runId;
  final String sessionId;
  final ToolExecutionGateway gateway;
  final void Function(ChatAgentEvent event) emit;
  final String model;
  final bool awaitAcknowledgements;
  final void Function(int turnIndex, String messageId) onTurnStarted;
  final Future<app_msg.AssistantMessage> Function(
    int turnIndex,
    String messageId,
    rt.ModelMessage response,
  )
  onTurnCompleted;
  final bool hasStore;
  int _turnIndex = 0;
  String? _currentMessageId;

  String get currentMessageId => _currentMessageId ?? '$runId:turn:$_turnIndex';

  @override
  FutureOr<rt.ToolCallHookResult> beforeToolCall(
    rt.ToolCallHookContext context,
  ) async {
    await gateway.onPreparedCall(runId, sessionId, context.call);
    return rt.ToolCallHookResult.proceed(context.call);
  }

  @override
  FutureOr<rt.ModelCallHookResult> beforeModelCall(
    rt.ModelCallHookContext context,
  ) {
    final messageId = '$runId:turn:$_turnIndex';
    _currentMessageId = messageId;
    onTurnStarted(_turnIndex, messageId);
    emit(
      ModelTurnStartedEvent(
        runId: runId,
        sessionId: sessionId,
        turnIndex: _turnIndex,
        model: model,
        messageId: messageId,
      ),
    );
    return rt.ModelCallHookResult.proceed(request: context.request);
  }

  @override
  FutureOr<rt.ModelResponseHookResult> afterModelCall(
    rt.ModelResponseHookContext context,
  ) async {
    final completedTurn = _turnIndex++;
    final messageId = _currentMessageId ?? '$runId:turn:$completedTurn';
    final assistantMessage = await onTurnCompleted(
      completedTurn,
      messageId,
      context.response,
    );
    final event = ModelTurnCompletedEvent(
      runId: runId,
      sessionId: sessionId,
      turnIndex: completedTurn,
      modelMessage: context.response,
      message: assistantMessage,
      persisted: hasStore,
    );
    emit(event);
    final proceed = rt.ModelResponseHookResult.proceed(context.response);
    if (!awaitAcknowledgements) return proceed;
    // A rejected acknowledgement throws here and fails the run.
    await event.acknowledgement.future;
    return proceed;
  }

  @override
  FutureOr<rt.StatePersistenceHookResult> beforePersistState(
    rt.StatePersistenceHookContext context,
  ) {
    // Never overwrite canonical persisted state with a failed or cancelled turn.
    if (context.runError != null) {
      return rt.StatePersistenceHookResult.skip();
    }
    final sanitized = ChatAgentRuntime.sanitizeLLMMessages(
      context.agent.state.history.messages,
    );
    context.agent.state.history.messages
      ..clear()
      ..addAll(sanitized);
    return rt.StatePersistenceHookResult.proceed();
  }
}

/// Runtime coordinator that owns canonical [rt.AgentState], executes
/// [rt.StatefulAgent] runs, persists state and turn messages via
/// [AgentSessionStore], and emits UI-oriented [ChatAgentEvent]s.
class ChatAgentRuntime {
  ChatAgentRuntime({
    required this.toolExecutor,
    this.remoteRepository,
    this.gemmaRepository,
    this.storageRepository,
    AgentSessionStore? sessionStore,
    this.shellService,
    this.supervisor,
    this.memoryProvider,
    this.skillRegistry,
    this.pluginConsumer,
    this.localLlm,
    LocalModelAccess? localModelAccess,
    this.awaitAcknowledgements = false,
  }) : sessionStore = sessionStore ?? storageRepository,
       _localModelAccess = localModelAccess;

  final ToolExecutor toolExecutor;
  final RemoteLlmRepository? remoteRepository;
  final GemmaRepository? gemmaRepository;
  final ChatStorageRepository? storageRepository;
  final AgentSessionStore? sessionStore;
  final ShellExecutionService? shellService;
  final AgentSupervisor? supervisor;
  final ScopedMemoryProvider? memoryProvider;
  final SkillRegistry? skillRegistry;
  final PluginConsumer? pluginConsumer;

  /// Local generation backend; when set it replaces [gemmaRepository]. In an
  /// agent isolate this is the services bridge, which leases the local model
  /// on the main isolate, so it must not be paired with a [LocalModelAccess].
  final LocalLlmGateway? localLlm;
  final LocalModelAccess? _localModelAccess;

  /// Whether the run waits for each [ModelTurnCompletedEvent] and
  /// [ToolCallCompletedEvent] to be acknowledged before continuing. The
  /// acknowledging side fails the run on rejection (agent isolates).
  final bool awaitAcknowledgements;

  /// Active in-flight persistence write chains keyed by `runId`, so stopping or
  /// deleting a session drains any ongoing DB write before removing storage.
  final Map<String, Future<void>> _pendingWritesByRun = {};

  /// Waits for any in-flight persistence write belonging to [runId] to settle.
  Future<void> drainPendingWrites(String runId) async {
    final pending = _pendingWritesByRun[runId];
    if (pending != null) {
      await pending;
    }
  }

  /// Runs the full model-tool iteration loop for a user turn, persisting agent
  /// state and messages in the agent layer and yielding structured UI events.
  Stream<ChatAgentEvent> runStream({
    required String runId,
    required String sessionId,
    String? generationId,
    required app_cfg.ModelConfig modelConfig,
    required List<app_msg.Message> historyMessages,
    required String userPrompt,
    CancelToken? cancelToken,
    int maxTurns = 25,
    Set<String>? allowedTools,
    void Function()? onFirstToken,
  }) {
    late final StreamController<ChatAgentEvent> eventController;
    _AgentGatewayHook? gatewayHook;
    StreamSubscription<rt.StreamingEvent>? agentSub;
    var cleanedUp = false;

    final effectiveCancelToken = cancelToken ?? CancelToken();
    final effectiveStore = sessionStore;

    // Monotonic microsecond timestamps guarantee exact turn ordering on reload.
    var lastMicros = 0;
    DateTime nextTimestamp() {
      final now = DateTime.now().microsecondsSinceEpoch;
      lastMicros = now > lastMicros ? now : lastMicros + 1;
      return DateTime.fromMicrosecondsSinceEpoch(lastMicros);
    }

    final runStopwatch = Stopwatch()..start();
    Duration? firstTokenElapsed;
    final contextTokens = _estimateContextTokens(historyMessages);

    String? activeTurnMessageId;
    var activeTurnText = StringBuffer();
    var activeTurnThought = StringBuffer();
    var activeTurnPersisted = false;
    var toolSeq = 0;
    Object? persistenceError;
    StackTrace? persistenceStackTrace;

    void recordFirstToken() {
      if (firstTokenElapsed != null) return;
      firstTokenElapsed = runStopwatch.elapsed;
      onFirstToken?.call();
    }

    // Logs the event (never throwing), then forwards it to the controller.
    void emit(ChatAgentEvent event) {
      try {
        final turn = switch (event) {
          ModelTurnStartedEvent(:final turnIndex) ||
          ModelTurnCompletedEvent(:final turnIndex) => turnIndex + 1,
          ToolCallPreparedEvent() ||
          ToolCallStartedEvent() ||
          ToolCallCompletedEvent() => gatewayHook?._turnIndex,
          _ => null,
        };
        final logEvent = agentLogEventFrom(event, turn: turn);
        if (logEvent != null) LogCapture.instance.agent(logEvent);
      } catch (_) {
        // Logging must never affect the run.
      }
      if (!eventController.isClosed) {
        eventController.add(event);
      }
    }

    Future<T> trackWrite<T>(Future<T> Function() action) {
      final prev = _pendingWritesByRun[runId] ?? Future<void>.value();
      final next = prev.then((_) => action());
      _pendingWritesByRun[runId] = next.then<void>(
        (_) {},
        onError: (Object _, StackTrace _) {},
      );
      return next;
    }

    // 1. Setup execution gateway for this run
    final gateway = ToolExecutionGateway(
      toolExecutor: toolExecutor,
      shellService: shellService,
      subAgentSupervisor: supervisor,
      memoryProvider: memoryProvider,
      skillRegistry: skillRegistry,
      allowedTools: allowedTools,
      awaitAcknowledgements: awaitAcknowledgements,
      currentTurn: () => gatewayHook?._turnIndex,
      onEvent: emit,
      persistToolMessage:
          ({
            required receipt,
            required sessionId,
            required callId,
            required toolName,
            required arguments,
          }) async {
            if (effectiveCancelToken.isCancelled) return null;
            final ts = nextTimestamp();
            final rawResult = receipt.result;
            final resultString = rawResult is String
                ? rawResult
                : jsonEncode(rawResult);
            final metadata = AgentMessageMetadata(
              version: 1,
              toolCallId: callId,
              toolName: toolName,
              toolArguments: arguments,
              isError: receipt.isError,
              receiptStatus: receipt.status.name,
              microsecondTimestamp: ts.microsecondsSinceEpoch,
            );
            final toolMessage = app_msg.ToolResponseMessage(
              id: '$runId:tool:${callId}_${toolSeq++}',
              toolName: toolName,
              toolCallId: callId,
              content: resultString,
              isError: receipt.isError,
              conversationId: sessionId,
              timestamp: ts,
              agentMetadata: metadata.encode(),
            );
            if (effectiveStore != null) {
              try {
                await trackWrite(() => effectiveStore.saveMessage(toolMessage));
              } catch (error, stackTrace) {
                persistenceError ??= error;
                persistenceStackTrace ??= stackTrace;
                if (!effectiveCancelToken.isCancelled) {
                  effectiveCancelToken.cancel('Persistence failed: $error');
                }
                rethrow;
              }
            }
            return toolMessage;
          },
    );

    Future<void> cleanup() async {
      if (cleanedUp) return;
      cleanedUp = true;
      runStopwatch.stop();
      if (!effectiveCancelToken.isCancelled) {
        effectiveCancelToken.cancel('Teardown');
      }
      final sub = agentSub;
      agentSub = null;
      if (sub != null) {
        try {
          await sub.cancel();
        } catch (_) {}
      }
      gateway.cleanupRun(runId);
      pluginConsumer?.cleanupRun(runId);
      final pending = _pendingWritesByRun.remove(runId);
      if (pending != null) {
        await pending;
      }
      if (!eventController.isClosed) {
        await eventController.close();
      }
    }

    eventController = StreamController<ChatAgentEvent>(
      sync: true,
      onCancel: cleanup,
    );

    app_msg.ChatResponseInfo buildResponseInfo(String text) =>
        app_msg.ChatResponseInfo(
          outputTokens: _estimateTokenCount(text),
          contextTokens: contextTokens,
          maxOutputTokens: modelConfig.maxTokens,
          duration: runStopwatch.elapsed,
          timeToFirstToken: firstTokenElapsed,
        );

    Future<app_msg.AssistantMessage> persistPartialOnCancel() async {
      final msgId = activeTurnMessageId ?? '$runId:turn:0';
      final text = activeTurnText.toString();
      final thought = activeTurnThought.toString();
      final ts = nextTimestamp();
      final combined = [
        text,
        if (thought.isNotEmpty) thought,
      ].where((p) => p.trim().isNotEmpty).join('\n');
      final responseInfo = buildResponseInfo(combined);
      final partial = app_msg.AssistantMessage(
        id: msgId,
        content: text,
        thinkingContent: thought.isNotEmpty ? thought : null,
        conversationId: sessionId,
        timestamp: ts,
        isStreaming: false,
        completedSuccessfully: false,
        tokenCount: responseInfo.outputTokens,
        responseInfo: responseInfo,
        agentMetadata: AgentMessageMetadata(
          version: 1,
          thought: thought.isNotEmpty ? thought : null,
          microsecondTimestamp: ts.microsecondsSinceEpoch,
        ).encode(),
      );
      activeTurnPersisted = true;
      if (effectiveStore != null) {
        await trackWrite(() => effectiveStore.saveMessage(partial));
      }
      return partial;
    }

    Future<app_msg.AssistantMessage> persistErrorAssistant(Object error) async {
      final msgId = activeTurnMessageId ?? '$runId:turn:0';
      final ts = nextTimestamp();
      final raw = _cleanErrorText(error);
      final isRemote = modelConfig.inferenceMode == ChatInferenceMode.remote;
      final content = isRemote ? 'API error: $raw' : 'Generation error: $raw';
      final responseInfo = buildResponseInfo(raw);
      final errMsg = app_msg.AssistantMessage(
        id: msgId,
        content: content,
        conversationId: sessionId,
        timestamp: ts,
        isStreaming: false,
        completedSuccessfully: false,
        tokenCount: responseInfo.outputTokens,
        responseInfo: responseInfo,
        agentMetadata: AgentMessageMetadata(
          version: 1,
          microsecondTimestamp: ts.microsecondsSinceEpoch,
        ).encode(),
      );
      activeTurnPersisted = true;
      if (effectiveStore != null) {
        try {
          await trackWrite(() => effectiveStore.saveMessage(errMsg));
        } catch (_) {
          // Preserve the original failure even if error persistence fails.
        }
      }
      return errMsg;
    }

    void startAgent({
      required rt.AgentState agentState,
      required List<rt.LLMMessage> inputMessages,
      required List<String> systemPrompts,
      required List<rt.Tool> tools,
    }) {
      // Emit initial run start immediately.
      emit(
        AgentRunStartedEvent(
          runId: runId,
          sessionId: sessionId,
          inputMessages: inputMessages,
        ),
      );

      if (eventController.isClosed || effectiveCancelToken.isCancelled) {
        unawaited(() async {
          if (!eventController.isClosed) {
            try {
              final partial = await persistPartialOnCancel();
              emit(
                AgentRunCancelledEvent(
                  runId: runId,
                  sessionId: sessionId,
                  reason:
                      effectiveCancelToken.cancelError?.toString() ??
                      'Cancelled before start',
                  partialMessage: partial,
                ),
              );
            } catch (saveError, saveSt) {
              emit(
                AgentRunFailedEvent(
                  runId: runId,
                  sessionId: sessionId,
                  error: saveError,
                  stackTrace: saveSt,
                ),
              );
            }
            if (!eventController.isClosed) await eventController.close();
          }
          await cleanup();
        }());
        return;
      }

      // 4. Setup LLM client (all turns flow through AgentRuntime's canonical state)
      final llmClient = RepositoryAgentLlmClient(
        config: modelConfig,
        remoteRepository: remoteRepository,
        gemmaRepository: gemmaRepository,
        localLlm: localLlm,
        localModelAccess: _localModelAccess,
        conversationId: sessionId,
        runId: runId,
        generationId: generationId,
        onFirstToken: recordFirstToken,
      );

      final modelName = modelConfig.inferenceMode == ChatInferenceMode.local
          ? (modelConfig.localModelId ?? modelConfig.modelType.name)
          : modelConfig.remoteModel;

      // 5. Setup hooks with agent-owned turn persistence
      final hook = _AgentGatewayHook(
        runId: runId,
        sessionId: sessionId,
        gateway: gateway,
        emit: emit,
        model: modelName,
        awaitAcknowledgements: awaitAcknowledgements,
        hasStore: effectiveStore != null,
        onTurnStarted: (turnIndex, messageId) {
          activeTurnMessageId = messageId;
          activeTurnText = StringBuffer();
          activeTurnThought = StringBuffer();
          activeTurnPersisted = false;
        },
        onTurnCompleted: (turnIndex, messageId, response) async {
          final ts = nextTimestamp();
          final content = response.textOutput ?? '';
          final thought = response.thought;
          final combined = [
            content,
            if (thought != null && thought.trim().isNotEmpty) thought,
          ].where((p) => p.trim().isNotEmpty).join('\n');
          final responseInfo = buildResponseInfo(combined);
          final metadata = AgentMessageMetadata(
            version: 1,
            toolCalls: response.functionCalls
                .map(
                  (fc) => <String, dynamic>{
                    'id': fc.id,
                    'name': fc.name,
                    'arguments': fc.arguments,
                  },
                )
                .toList(),
            thought: thought,
            thoughtSignature: response.thoughtSignature,
            responseId: response.responseId,
            model: modelName,
            microsecondTimestamp: ts.microsecondsSinceEpoch,
          );
          final assistantMessage = app_msg.AssistantMessage(
            id: messageId,
            content: content,
            thinkingContent: thought,
            conversationId: sessionId,
            timestamp: ts,
            isStreaming: false,
            completedSuccessfully: true,
            tokenCount: responseInfo.outputTokens,
            responseInfo: responseInfo,
            agentMetadata: metadata.encode(),
          );
          if (effectiveStore != null) {
            try {
              await trackWrite(
                () => effectiveStore.saveMessage(assistantMessage),
              );
            } catch (error, stackTrace) {
              persistenceError ??= error;
              persistenceStackTrace ??= stackTrace;
              rethrow;
            }
          }
          activeTurnPersisted = true;
          return assistantMessage;
        },
      );
      gatewayHook = hook;

      // 6. Instantiate AgentRuntime with its persisted AgentState and autoSave
      final agent = rt.AgentRuntime(
        name: 'GSMLG_Agent',
        systemPrompts: systemPrompts,
        client: llmClient,
        modelConfig: rt.ModelConfig(
          model: modelName,
          temperature: modelConfig.temperature,
          maxTokens: modelConfig.maxTokens,
        ),
        tools: tools,
        hooks: [hook],
        state: agentState,
        autoSaveState: effectiveStore == null
            ? null
            : (rt.AgentState state) async {
                await trackWrite(
                  () => effectiveStore.saveAgentState(
                    sessionId,
                    jsonEncode(state.toJson()),
                  ),
                );
              },
      );

      // Pin plugins for this active run if pluginConsumer available
      pluginConsumer?.pinPluginsForRun(runId);

      // Stream agent execution
      final agentStream = agent.runStream(
        inputMessages,
        cancelToken: effectiveCancelToken,
        useStream: true,
        maxTurns: maxTurns,
      );

      agentSub = agentStream.listen(
        (event) {
          switch (event.eventType) {
            case rt.StreamingEventType.modelChunkMessage:
              final data = event.data;
              final rt.ModelMessage? modelMsg = data is rt.ModelMessage
                  ? data
                  : (data is rt.StreamingMessage ? data.modelMessage : null);
              if (modelMsg != null) {
                final text = modelMsg.textOutput;
                final thought = modelMsg.thought;
                if (text != null) activeTurnText.write(text);
                if (thought != null) activeTurnThought.write(thought);
                if ((text != null && text.isNotEmpty) ||
                    (thought != null && thought.isNotEmpty)) {
                  recordFirstToken();
                }
                if (text != null || thought != null) {
                  emit(
                    ModelChunkReceivedEvent(
                      runId: runId,
                      sessionId: sessionId,
                      turnIndex: hook._turnIndex,
                      messageId: hook.currentMessageId,
                      textChunk: text,
                      thoughtChunk: thought,
                      timeToFirstToken: firstTokenElapsed,
                    ),
                  );
                }
              }
            case rt.StreamingEventType.fullModelMessage:
              // Handled by afterModelCall hook
              break;
            case rt.StreamingEventType.functionCallRequest:
              // Handled by beforeToolCall hook
              break;
            case rt.StreamingEventType.functionCallResult:
              // Handled by gateway execution
              break;
            default:
              break;
          }
        },
        onError: (Object err, StackTrace st) async {
          final effectiveErr = persistenceError ?? err;
          final effectiveSt = persistenceStackTrace ?? st;
          final isCancelled =
              persistenceError == null &&
              (effectiveCancelToken.isCancelled ||
                  (err is rt.AgentException &&
                      err.code == rt.AgentExceptionCode.cancelled) ||
                  (err is DioException && err.type == DioExceptionType.cancel));

          if (!eventController.isClosed) {
            if (isCancelled) {
              try {
                final partial = activeTurnPersisted
                    ? null
                    : await persistPartialOnCancel();
                emit(
                  AgentRunCancelledEvent(
                    runId: runId,
                    sessionId: sessionId,
                    reason: err.toString(),
                    partialMessage: partial,
                  ),
                );
              } catch (saveError, saveSt) {
                emit(
                  AgentRunFailedEvent(
                    runId: runId,
                    sessionId: sessionId,
                    error: saveError,
                    stackTrace: saveSt,
                  ),
                );
              }
            } else {
              final errMsg = persistenceError == null
                  ? await persistErrorAssistant(effectiveErr)
                  : null;
              emit(
                AgentRunFailedEvent(
                  runId: runId,
                  sessionId: sessionId,
                  error: effectiveErr,
                  stackTrace: effectiveSt,
                  errorMessage: errMsg,
                ),
              );
            }
            if (!eventController.isClosed) await eventController.close();
          }
          await cleanup();
        },
        onDone: () async {
          if (!eventController.isClosed) {
            emit(
              AgentRunCompletedEvent(
                runId: runId,
                sessionId: sessionId,
                finalResponse: null,
              ),
            );
            await eventController.close();
          }
          await cleanup();
        },
        cancelOnError: true,
      );
    }

    // 2. Discover tools & check if we can start synchronously (no prior turns
    // means no prior AgentState exists to load).
    final tools = gateway.getTools(runId: runId, sessionId: sessionId);
    final split = _splitHistory(historyMessages, userPrompt);

    if (effectiveStore == null || split.priorMessages.isEmpty) {
      final seededHistory = sanitizeLLMMessages(
        _convertHistoryToLLMMessages(split.priorMessages),
      );
      startAgent(
        agentState: rt.AgentState(
          sessionId: sessionId,
          history: rt.AgentMessageHistory(messages: seededHistory),
        ),
        inputMessages: [?split.newUserMessage],
        systemPrompts: split.systemPrompts,
        tools: tools,
      );
    } else {
      unawaited(() async {
        try {
          final prepared = await _prepareAgentStateFromStore(
            sessionId: sessionId,
            split: split,
          );
          startAgent(
            agentState: prepared.agentState,
            inputMessages: prepared.inputMessages,
            systemPrompts: split.systemPrompts,
            tools: tools,
          );
        } catch (err, st) {
          if (!eventController.isClosed) {
            emit(
              AgentRunFailedEvent(
                runId: runId,
                sessionId: sessionId,
                error: persistenceError ?? err,
                stackTrace: persistenceStackTrace ?? st,
              ),
            );
            await eventController.close();
          }
          await cleanup();
        }
      }());
    }

    return eventController.stream;
  }

  ({
    List<app_msg.Message> priorMessages,
    rt.UserMessage? newUserMessage,
    List<String> systemPrompts,
  })
  _splitHistory(List<app_msg.Message> historyMessages, String userPrompt) {
    final systemPrompts = [
      for (final m in historyMessages.whereType<app_msg.SystemMessage>())
        if (m.content.trim().isNotEmpty) m.content,
    ];

    final nonSystem = historyMessages
        .where((m) => m is! app_msg.SystemMessage)
        .toList();
    app_msg.UserMessage? trailingUser;
    List<app_msg.Message> priorMessages = nonSystem;
    if (nonSystem.isNotEmpty && nonSystem.last is app_msg.UserMessage) {
      trailingUser = nonSystem.last as app_msg.UserMessage;
      priorMessages = nonSystem.sublist(0, nonSystem.length - 1);
    }

    final rt.UserMessage? newUserMessage = trailingUser != null
        ? _toDacUserMessage(trailingUser)
        : (userPrompt.isNotEmpty
              ? rt.UserMessage([rt.TextPart(userPrompt)])
              : null);

    return (
      priorMessages: priorMessages,
      newUserMessage: newUserMessage,
      systemPrompts: systemPrompts,
    );
  }

  /// Loads persisted [rt.AgentState] if available, or seeds one cleanly from
  /// [split.priorMessages] (sanitizing any legacy orphaned tool responses or
  /// dangling tool calls).
  Future<({rt.AgentState agentState, List<rt.LLMMessage> inputMessages})>
  _prepareAgentStateFromStore({
    required String sessionId,
    required ({
      List<app_msg.Message> priorMessages,
      rt.UserMessage? newUserMessage,
      List<String> systemPrompts,
    })
    split,
  }) async {
    rt.AgentState? loadedState;
    final store = sessionStore;
    if (store != null) {
      final raw = await store.loadAgentState(sessionId);
      if (raw != null && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            loadedState = rt.AgentState.fromJson(decoded);
          } else if (decoded is Map) {
            loadedState = rt.AgentState.fromJson(
              decoded.cast<String, dynamic>(),
            );
          }
        } catch (_) {
          // Corrupt/incompatible state falls back cleanly to history seeding.
          loadedState = null;
        }
      }
    }

    if (loadedState != null) {
      final sanitized = sanitizeLLMMessages(loadedState.history.messages);
      loadedState.history.messages
        ..clear()
        ..addAll(sanitized);

      final inputMessages = <rt.LLMMessage>[];
      final newUser = split.newUserMessage;
      if (newUser != null &&
          !_sameTrailingUserMessage(loadedState.history.messages, newUser)) {
        inputMessages.add(newUser);
      }
      return (agentState: loadedState, inputMessages: inputMessages);
    }

    final seededHistory = sanitizeLLMMessages(
      _convertHistoryToLLMMessages(split.priorMessages),
    );
    final agentState = rt.AgentState(
      sessionId: sessionId,
      history: rt.AgentMessageHistory(messages: seededHistory),
    );
    return (agentState: agentState, inputMessages: [?split.newUserMessage]);
  }

  static String _cleanErrorText(Object error) {
    final raw = error is rt.AgentException && error.error != null
        ? error.error.toString()
        : (error is rt.AgentException ? error.message : error.toString());
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Unknown error';
    const prefixes = ['RemoteLlmException: ', 'Exception: '];
    for (final prefix in prefixes) {
      if (trimmed.startsWith(prefix)) {
        return trimmed.substring(prefix.length).trim();
      }
    }
    return trimmed;
  }

  bool _sameTrailingUserMessage(
    List<rt.LLMMessage> history,
    rt.UserMessage candidate,
  ) {
    if (history.isEmpty) return false;
    final last = history.last;
    if (last is! rt.UserMessage) return false;
    return jsonEncode(last.toJson()) == jsonEncode(candidate.toJson());
  }

  rt.UserMessage _toDacUserMessage(app_msg.UserMessage msg) {
    final images = msg.inlineImages;
    final text = msg.contentWithAttachments(includeImages: images.isEmpty);
    final parts = <rt.UserContentPart>[
      if (text.isNotEmpty) rt.TextPart(text),
      for (final img in images)
        rt.ImagePart(base64Encode(img.bytes), img.mimeType),
    ];
    return rt.UserMessage(parts.isEmpty ? [rt.TextPart('')] : parts);
  }

  List<rt.LLMMessage> _convertHistoryToLLMMessages(
    List<app_msg.Message> history,
  ) {
    final messages = <rt.LLMMessage>[];

    for (final msg in history) {
      if (msg is app_msg.UserMessage) {
        messages.add(_toDacUserMessage(msg));
      } else if (msg is app_msg.AssistantMessage) {
        if (_isTransientErrorPlaceholder(msg)) continue;
        final metadata = msg.agentMetadata != null
            ? AgentMessageMetadata.decode(msg.agentMetadata!)
            : null;

        final functionCalls =
            metadata?.toolCalls
                .map(
                  (tc) => rt.FunctionCall(
                    id: (tc['id'] as String?) ?? '',
                    name: (tc['name'] as String?) ?? '',
                    arguments: tc['arguments'] is String
                        ? tc['arguments'] as String
                        : jsonEncode(tc['arguments'] ?? {}),
                  ),
                )
                .where((fc) => fc.id.isNotEmpty && fc.name.isNotEmpty)
                .toList() ??
            const <rt.FunctionCall>[];

        if (msg.content.trim().isEmpty &&
            (msg.thinkingContent?.trim().isEmpty ?? true) &&
            functionCalls.isEmpty) {
          continue;
        }

        messages.add(
          rt.ModelMessage(
            textOutput: msg.content.isNotEmpty ? msg.content : null,
            thought: msg.thinkingContent,
            thoughtSignature: metadata?.thoughtSignature,
            functionCalls: functionCalls,
            model: metadata?.model ?? 'assistant',
          ),
        );
      } else if (msg is app_msg.ToolResponseMessage) {
        final callId = msg.toolCallId;
        if (callId == null || callId.isEmpty) continue;
        messages.add(
          rt.FunctionExecutionResultMessage(
            results: [
              rt.FunctionExecutionResult(
                id: callId,
                name: msg.toolName,
                arguments: '',
                isError: msg.isError,
                content: [rt.TextPart(msg.content)],
              ),
            ],
          ),
        );
      }
    }

    return messages;
  }

  static bool _isTransientErrorPlaceholder(app_msg.AssistantMessage msg) {
    if (msg.completedSuccessfully) return false;
    final trimmed = msg.content.trimLeft();
    return trimmed.startsWith('API error:') ||
        trimmed.startsWith('Generation error:');
  }

  /// Ensures strict pairing between `ModelMessage.functionCalls` and
  /// immediately following `FunctionExecutionResultMessage` items.
  ///
  /// - Drops orphaned `FunctionExecutionResultMessage` entries with no
  ///   matching `FunctionCall.id` in the preceding `ModelMessage`.
  /// - Strips unmatched `FunctionCall`s from a `ModelMessage` that were never
  ///   answered by a following tool result (e.g. after a crash or cancel).
  /// - Merges consecutive `FunctionExecutionResultMessage`s belonging to the
  ///   same preceding `ModelMessage` into a single properly paired message.
  static List<rt.LLMMessage> sanitizeLLMMessages(List<rt.LLMMessage> raw) =>
      rt.MessageTransformer.sanitize(raw);

  static int _estimateContextTokens(List<app_msg.Message> messages) {
    var total = 0;
    for (final message in messages) {
      if (message is app_msg.AssistantMessage && message.isStreaming) continue;
      final content = switch (message) {
        final app_msg.UserMessage user => user.contentWithAttachments(),
        final app_msg.ToolResponseMessage tool =>
          'Tool response from ${tool.toolName}:\n${tool.content}',
        _ => message.content,
      };
      total += _estimateTokenCount(content);
    }
    return total;
  }

  static int _estimateTokenCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return (trimmed.length / 4).ceil();
  }
}
