import 'dart:async';
import 'dart:convert';

import 'package:app_logging/app_logging.dart' show LogCapture;
import 'package:dart_agent_core/dart_agent_core.dart' as dac;
import 'package:dio/dio.dart';

import '../models/agent_metadata.dart';
import '../models/inference.dart';
import '../models/message.dart' as app_msg;
import '../models/model_config.dart' as app_cfg;
import '../repositories/chat_storage_repository.dart';
import '../repositories/gemma_repository.dart';
import '../repositories/local_model_access.dart';
import '../repositories/remote_llm_repository.dart';
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

/// Hook connecting StatefulAgent lifecycle to the ToolExecutionGateway and application events.
class _AgentGatewayHook extends dac.AgentHook {
  _AgentGatewayHook({
    required this.runId,
    required this.sessionId,
    required this.gateway,
    required this.emit,
    required this.model,
  });

  final String runId;
  final String sessionId;
  final ToolExecutionGateway gateway;
  final void Function(ChatAgentEvent event) emit;
  final String model;
  int _turnIndex = 0;

  @override
  FutureOr<dac.ToolCallHookResult> beforeToolCall(
    dac.ToolCallHookContext context,
  ) async {
    await gateway.onPreparedCall(runId, sessionId, context.call);
    return dac.ToolCallHookResult.proceed(context.call);
  }

  @override
  FutureOr<dac.ModelCallHookResult> beforeModelCall(
    dac.ModelCallHookContext context,
  ) {
    emit(
      ModelTurnStartedEvent(
        runId: runId,
        sessionId: sessionId,
        turnIndex: _turnIndex,
        model: model,
      ),
    );
    return dac.ModelCallHookResult.proceed(request: context.request);
  }

  @override
  FutureOr<dac.ModelResponseHookResult> afterModelCall(
    dac.ModelResponseHookContext context,
  ) {
    emit(
      ModelTurnCompletedEvent(
        runId: runId,
        sessionId: sessionId,
        turnIndex: _turnIndex++,
        modelMessage: context.response,
      ),
    );
    return dac.ModelResponseHookResult.proceed(context.response);
  }
}

/// Runtime coordinator that instantiates and executes a fresh StatefulAgent per run.
class ChatAgentRuntime {
  ChatAgentRuntime({
    required this.toolExecutor,
    this.remoteRepository,
    this.gemmaRepository,
    this.storageRepository,
    this.shellService,
    this.supervisor,
    this.memoryProvider,
    this.skillRegistry,
    this.pluginConsumer,
    LocalModelAccess? localModelAccess,
  }) : _localModelAccess = localModelAccess;

  final ToolExecutor toolExecutor;
  final RemoteLlmRepository? remoteRepository;
  final GemmaRepository? gemmaRepository;
  final ChatStorageRepository? storageRepository;
  final ShellExecutionService? shellService;
  final AgentSupervisor? supervisor;
  final ScopedMemoryProvider? memoryProvider;
  final SkillRegistry? skillRegistry;
  final PluginConsumer? pluginConsumer;
  final LocalModelAccess? _localModelAccess;

  /// Runs the full model-tool iteration loop for a user turn, yielding structured events.
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

    // 1. Setup execution gateway for this run
    final gateway = ToolExecutionGateway(
      toolExecutor: toolExecutor,
      shellService: shellService,
      subAgentSupervisor: supervisor,
      memoryProvider: memoryProvider,
      skillRegistry: skillRegistry,
      allowedTools: allowedTools,
      onEvent: emit,
      onReceipt: (receipt) async {
        // Automatically persist receipt if storageRepository is available
        if (storageRepository != null) {
          // Journal receipt via metadata or storage
        }
      },
    );

    Future<void> cleanup() async {
      if (cancelToken != null && !cancelToken.isCancelled) {
        cancelToken.cancel('Teardown');
      }
      gateway.cleanupRun(runId);
      pluginConsumer?.cleanupRun(runId);
      if (!eventController.isClosed) {
        await eventController.close();
      }
    }

    eventController = StreamController<ChatAgentEvent>(
      sync: true,
      onCancel: cleanup,
    );

    // 2. Discover tools
    final tools = gateway.getTools(runId: runId, sessionId: sessionId);
    final openAiTools = tools
        .map(
          (t) => {
            'type': 'function',
            'function': {
              'name': t.name,
              'description': t.description,
              'parameters': t.parameters,
            },
          },
        )
        .toList(growable: false);

    // 3. Setup LLM client with primed first turn
    final llmClient = RepositoryAgentLlmClient(
      config: modelConfig,
      remoteRepository: remoteRepository,
      gemmaRepository: gemmaRepository,
      localModelAccess: _localModelAccess,
      conversationId: sessionId,
      runId: runId,
      generationId: generationId,
      onFirstToken: onFirstToken,
      initialMessages: historyMessages,
      initialTools: openAiTools,
    );

    final modelName = modelConfig.inferenceMode == ChatInferenceMode.local
        ? (modelConfig.localModelId ?? modelConfig.modelType.name)
        : modelConfig.remoteModel;

    // 4. Setup hooks
    final hook = _AgentGatewayHook(
      runId: runId,
      sessionId: sessionId,
      gateway: gateway,
      emit: emit,
      model: modelName,
    );
    gatewayHook = hook;

    // 5. Instantiate fresh StatefulAgent
    final agent = dac.StatefulAgent(
      name: 'GSMLG_Agent',
      client: llmClient,
      modelConfig: dac.ModelConfig(
        model: modelName,
        temperature: modelConfig.temperature,
        maxTokens: modelConfig.maxTokens,
      ),
      tools: tools,
      hooks: [hook],
      state: dac.AgentState(sessionId: sessionId),
      disableSubAgents:
          true, // We use AgentSupervisor delegation instead of generic cloning
    );

    // 6. Convert conversation history to dart_agent_core LLMMessages
    final inputMessages = _convertHistoryToLLMMessages(
      historyMessages,
      userPrompt,
    );

    // Pin plugins for this active run if pluginConsumer available
    pluginConsumer?.pinPluginsForRun(runId);

    // Emit initial run start
    emit(
      AgentRunStartedEvent(
        runId: runId,
        sessionId: sessionId,
        inputMessages: inputMessages,
      ),
    );

    // Stream agent execution
    final agentStream = agent
        .runStream(
          inputMessages,
          cancelToken: cancelToken,
          useStream: true,
          maxTurns: maxTurns,
        )
        .handleError((err, st) {
          final isCancelled =
              (cancelToken?.isCancelled ?? false) ||
              (err is dac.AgentException &&
                  err.code == dac.AgentExceptionCode.cancelled) ||
              (err is DioException && err.type == DioExceptionType.cancel);

          if (!eventController.isClosed) {
            if (isCancelled) {
              emit(
                AgentRunCancelledEvent(
                  runId: runId,
                  sessionId: sessionId,
                  reason: err.toString(),
                ),
              );
            } else {
              emit(
                AgentRunFailedEvent(
                  runId: runId,
                  sessionId: sessionId,
                  error: err,
                  stackTrace: st,
                ),
              );
            }
            eventController.close();
          }
          cleanup();
        });

    agentStream.listen(
      (event) {
        switch (event.eventType) {
          case dac.StreamingEventType.modelChunkMessage:
            final data = event.data;
            final dac.ModelMessage? modelMsg = data is dac.ModelMessage
                ? data
                : (data is dac.StreamingMessage ? data.modelMessage : null);
            if (modelMsg != null) {
              final text = modelMsg.textOutput;
              final thought = modelMsg.thought;
              if (text != null || thought != null) {
                emit(
                  ModelChunkReceivedEvent(
                    runId: runId,
                    sessionId: sessionId,
                    turnIndex: hook._turnIndex,
                    textChunk: text,
                    thoughtChunk: thought,
                  ),
                );
              }
            }
          case dac.StreamingEventType.fullModelMessage:
            // Handled by afterModelCall hook
            break;
          case dac.StreamingEventType.functionCallRequest:
            // Handled by beforeToolCall hook
            break;
          case dac.StreamingEventType.functionCallResult:
            // Handled by gateway execution
            break;
          default:
            break;
        }
      },
      onError: (err, st) {
        // Handled by handleError above
      },
      onDone: () {
        if (!eventController.isClosed) {
          emit(
            AgentRunCompletedEvent(
              runId: runId,
              sessionId: sessionId,
              finalResponse: null,
            ),
          );
          eventController.close();
        }
        cleanup();
      },
      cancelOnError: true,
    );

    return eventController.stream;
  }

  List<dac.LLMMessage> _convertHistoryToLLMMessages(
    List<app_msg.Message> history,
    String newUserPrompt,
  ) {
    final messages = <dac.LLMMessage>[];

    for (final msg in history) {
      if (msg is app_msg.UserMessage) {
        messages.add(dac.UserMessage([dac.TextPart(msg.content)]));
      } else if (msg is app_msg.AssistantMessage) {
        final metadata = msg.agentMetadata != null
            ? AgentMessageMetadata.decode(msg.agentMetadata!)
            : null;

        final functionCalls =
            metadata?.toolCalls
                .map(
                  (tc) => dac.FunctionCall(
                    id: (tc['id'] as String?) ?? 'call_unknown',
                    name: (tc['name'] as String?) ?? '',
                    arguments: tc['arguments'] is String
                        ? tc['arguments'] as String
                        : jsonEncode(tc['arguments'] ?? {}),
                  ),
                )
                .toList() ??
            const <dac.FunctionCall>[];

        messages.add(
          dac.ModelMessage(
            textOutput: msg.content.isNotEmpty ? msg.content : null,
            thought: msg.thinkingContent,
            thoughtSignature: metadata?.thoughtSignature,
            functionCalls: functionCalls,
            model: 'assistant',
          ),
        );
      } else if (msg is app_msg.ToolResponseMessage) {
        messages.add(
          dac.FunctionExecutionResultMessage(
            results: [
              dac.FunctionExecutionResult(
                id: msg.toolCallId ?? 'call_unknown',
                name: msg.toolName,
                arguments: '',
                isError: msg.isError,
                content: [dac.TextPart(msg.content)],
              ),
            ],
          ),
        );
      }
    }

    if (newUserPrompt.isNotEmpty) {
      final lastMsg = history.lastOrNull;
      final alreadyPresent =
          lastMsg is app_msg.UserMessage && lastMsg.content == newUserPrompt;
      if (!alreadyPresent) {
        messages.add(dac.UserMessage([dac.TextPart(newUserPrompt)]));
      }
    }

    return messages;
  }
}
