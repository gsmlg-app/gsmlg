import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' show CancelToken, DioException, DioExceptionType;

import 'event.dart';
import 'exception.dart';
import 'hook.dart';
import 'message.dart';
import 'message_transformer.dart';
import 'provider.dart';
import 'state.dart';
import 'tool.dart';
import 'turn_state.dart';

/// Core agent execution loop inspired by `Sigma.Agent`.
///
/// Responsibilities:
/// - Owns and mutates [state] (`AgentState`) across model and tool turns.
/// - Drives an explicit [TurnState] lifecycle (`streamingProvider` ->
///   `runningTools` -> `completed` / `failed` / `cancelled`).
/// - Applies [MessageTransformer.sanitize] before every provider call and
///   before persisting state so orphaned tool outputs or unanswered calls can
///   never reach providers.
/// - Persists [state] via [autoSaveState] at safe turn boundaries.
class AgentRuntime {
  AgentRuntime({
    required this.name,
    required this.client,
    required this.modelConfig,
    required this.state,
    this.systemPrompts = const [],
    this.tools = const [],
    this.toolChoice,
    this.hooks = const [],
    this.autoSaveState,
    this.maxTurns = 20,
  });

  final String name;
  final LLMClient client;
  final ModelConfig modelConfig;
  final AgentState state;
  final List<String> systemPrompts;
  final List<Tool> tools;
  final ToolChoice? toolChoice;
  final List<AgentHook> hooks;
  final FutureOr<void> Function(AgentState state)? autoSaveState;
  final int maxTurns;

  TurnState _turnState = TurnState.idle;
  TurnState get turnState => _turnState;

  /// Runs the model-tool iteration loop for [inputMessages], streaming
  /// [StreamingEvent]s and persisting [state] at turn boundaries.
  Stream<StreamingEvent> runStream(
    List<LLMMessage> inputMessages, {
    CancelToken? cancelToken,
    bool useStream = true,
    int? maxTurns,
  }) {
    late final StreamController<StreamingEvent> controller;
    StreamSubscription<StreamingMessage>? providerSub;
    var subscriberCancelled = false;

    void emit(StreamingEvent event) {
      if (!subscriberCancelled && !controller.isClosed) {
        controller.add(event);
      }
    }

    controller = StreamController<StreamingEvent>(
      sync: true,
      onCancel: () async {
        subscriberCancelled = true;
        final sub = providerSub;
        providerSub = null;
        if (sub != null) {
          try {
            await sub.cancel();
          } catch (_) {}
        }
      },
    );

    Future<void> execute() async {
      final limit = maxTurns ?? this.maxTurns;
      AgentException? runError;
      state.isRunning = true;
      state.lastError = null;
      state.currentLoopCount = 0;

      if (inputMessages.isNotEmpty) {
        state.history.messages.addAll(inputMessages);
      }

      try {
        var turnIndex = 0;
        while (true) {
          if (subscriberCancelled) return;
          _checkCancelled(cancelToken);
          if (state.currentLoopCount >= limit) {
            throw AgentException(
              AgentExceptionCode.loopDetection,
              'Maximum turns reached ($limit). Possible infinite loop.',
            );
          }

          _turnState = _turnState.start(
            '${state.sessionId}:turn:$turnIndex',
            turnIndex: turnIndex,
          );
          emit(
            StreamingEvent(
              eventType: StreamingEventType.turnStateChanged,
              turnState: _turnState,
            ),
          );

          // Project canonical history into sanitized provider context.
          final providerMessages = _buildProviderMessages();
          var request = ModelCallRequest(
            messages: providerMessages,
            tools: tools,
            modelConfig: modelConfig,
            toolChoice: toolChoice,
          );

          for (final hook in hooks) {
            final res = hook.beforeModelCall(
              ModelCallHookContext(
                agent: this,
                turnIndex: turnIndex,
                request: request,
              ),
            );
            final decision = res is Future<ModelCallHookResult>
                ? await res
                : res;
            if (decision.action == HookAction.abort) {
              throw AgentException(
                AgentExceptionCode.hookAborted,
                decision.reason ?? 'Model call aborted by hook',
                error: decision.error,
              );
            }
            if (decision.request != null) {
              request = decision.request!;
            }
          }

          if (subscriberCancelled) return;
          _checkCancelled(cancelToken);

          ModelMessage fullMessage;
          if (useStream) {
            final acc = _ModelTurnAccumulator(model: request.modelConfig.model);
            final stream = await client.stream(
              request.messages,
              tools: request.tools.isEmpty ? null : request.tools,
              toolChoice: request.toolChoice,
              modelConfig: request.modelConfig,
              cancelToken: cancelToken,
            );
            final done = Completer<void>();
            providerSub = stream.listen(
              (frame) {
                if (subscriberCancelled) return;
                if (cancelToken?.isCancelled ?? false) {
                  if (!done.isCompleted) {
                    done.completeError(
                      AgentException(
                        AgentExceptionCode.cancelled,
                        'Agent cancelled by user',
                        error: cancelToken?.cancelError,
                      ),
                    );
                  }
                  return;
                }
                final chunk = frame.modelMessage;
                if (chunk == null) return;
                acc.add(chunk);
                if ((chunk.textOutput?.isNotEmpty ?? false) ||
                    (chunk.thought?.isNotEmpty ?? false)) {
                  emit(
                    StreamingEvent(
                      eventType: StreamingEventType.modelChunkMessage,
                      data: chunk,
                      turnState: _turnState,
                    ),
                  );
                }
              },
              onError: (Object err, StackTrace st) {
                if (!done.isCompleted) done.completeError(err, st);
              },
              onDone: () {
                if (!done.isCompleted) done.complete();
              },
              cancelOnError: true,
            );
            try {
              await done.future;
            } finally {
              final sub = providerSub;
              providerSub = null;
              if (sub != null) {
                try {
                  await sub.cancel();
                } catch (_) {}
              }
            }
            if (subscriberCancelled) return;
            _checkCancelled(cancelToken);
            fullMessage = acc.build();
          } else {
            fullMessage = await client.generate(
              request.messages,
              tools: request.tools.isEmpty ? null : request.tools,
              toolChoice: request.toolChoice,
              modelConfig: request.modelConfig,
              cancelToken: cancelToken,
            );
          }

          state.currentLoopCount++;
          state.totalLoopCount++;
          if (fullMessage.usage != null) {
            state.usages.add(fullMessage.usage!);
          }

          for (final hook in hooks) {
            final decision = await hook.afterModelCall(
              ModelResponseHookContext(
                agent: this,
                turnIndex: turnIndex,
                response: fullMessage,
              ),
            );
            if (decision.action == HookAction.abort) {
              throw AgentException(
                AgentExceptionCode.hookAborted,
                decision.reason ?? 'Model response aborted by hook',
                error: decision.error,
              );
            }
            if (decision.response != null) {
              fullMessage = decision.response!;
            }
          }

          emit(
            StreamingEvent(
              eventType: StreamingEventType.fullModelMessage,
              data: fullMessage,
              turnState: _turnState,
            ),
          );

          final calls = fullMessage.functionCalls;
          if (calls.isEmpty) {
            state.history.messages.add(fullMessage);
            _turnState = _turnState.transition(TurnPhase.completed);
            emit(
              StreamingEvent(
                eventType: StreamingEventType.turnStateChanged,
                turnState: _turnState,
              ),
            );
            break;
          }

          // Tool execution phase.
          _turnState = _turnState.transition(TurnPhase.runningTools);
          emit(
            StreamingEvent(
              eventType: StreamingEventType.turnStateChanged,
              turnState: _turnState,
            ),
          );
          emit(
            StreamingEvent(
              eventType: StreamingEventType.functionCallRequest,
              data: calls,
              turnState: _turnState,
            ),
          );

          final preparedCalls = <FunctionCall>[];
          for (final call in calls) {
            var effectiveCall = call;
            for (final hook in hooks) {
              final decision = await hook.beforeToolCall(
                ToolCallHookContext(
                  agent: this,
                  turnIndex: turnIndex,
                  call: effectiveCall,
                ),
              );
              if (decision.action == HookAction.abort) {
                throw AgentException(
                  AgentExceptionCode.hookAborted,
                  decision.reason ?? 'Tool call aborted by hook',
                  error: decision.error,
                );
              }
              if (decision.call != null) {
                effectiveCall = decision.call!;
              }
            }
            preparedCalls.add(effectiveCall);
          }

          final batchId = '${state.sessionId}:batch:$turnIndex';
          final toolResultMessage = await _executeToolBatch(
            preparedCalls,
            batchId: batchId,
            cancelToken: cancelToken,
          );

          emit(
            StreamingEvent(
              eventType: StreamingEventType.functionCallResult,
              data: toolResultMessage,
              turnState: _turnState,
            ),
          );

          // Append paired assistant call + tool results atomically into state.
          state.history.messages.addAll([fullMessage, toolResultMessage]);
          await _persistState('afterToolCall');

          if (subscriberCancelled) return;
          _checkCancelled(cancelToken);
          turnIndex++;
        }
      } on AgentException catch (e, st) {
        runError = e;
        state.lastError = e.error?.toString() ?? e.message;
        _turnState = _turnState.transition(
          e.code == AgentExceptionCode.cancelled
              ? TurnPhase.cancelled
              : TurnPhase.failed,
        );
        if (!subscriberCancelled && !controller.isClosed) {
          controller.addError(e, st);
        }
      } on DioException catch (e, st) {
        final cancelled =
            (cancelToken?.isCancelled ?? false) ||
            e.type == DioExceptionType.cancel;
        runError = AgentException(
          cancelled ? AgentExceptionCode.cancelled : AgentExceptionCode.unknown,
          cancelled ? 'Agent cancelled by user' : 'Agent run failed: $e',
          error: e,
          stackTrace: st,
        );
        state.lastError = e.message ?? e.toString();
        _turnState = _turnState.transition(
          cancelled ? TurnPhase.cancelled : TurnPhase.failed,
        );
        if (!subscriberCancelled && !controller.isClosed) {
          controller.addError(runError, st);
        }
      } catch (e, st) {
        final cancelled = cancelToken?.isCancelled ?? false;
        runError = AgentException(
          cancelled ? AgentExceptionCode.cancelled : AgentExceptionCode.unknown,
          cancelled ? 'Agent cancelled by user' : 'Agent run failed',
          error: e,
          stackTrace: st,
        );
        state.lastError = e.toString();
        _turnState = _turnState.transition(
          cancelled ? TurnPhase.cancelled : TurnPhase.failed,
        );
        if (!subscriberCancelled && !controller.isClosed) {
          controller.addError(runError, st);
        }
      } finally {
        state.isRunning = false;
        try {
          await _persistState('finally', runError: runError);
        } catch (e, st) {
          if (runError == null &&
              !subscriberCancelled &&
              !controller.isClosed) {
            controller.addError(e, st);
          }
        }
        if (!controller.isClosed) {
          await controller.close();
        }
      }
    }

    unawaited(execute());
    return controller.stream;
  }

  List<LLMMessage> _buildProviderMessages() {
    final sanitized = MessageTransformer.sanitize(state.history.messages);
    return [
      for (final prompt in systemPrompts)
        if (prompt.trim().isNotEmpty) SystemMessage(prompt),
      ...sanitized,
    ];
  }

  Future<FunctionExecutionResultMessage> _executeToolBatch(
    List<FunctionCall> calls, {
    required String batchId,
    required CancelToken? cancelToken,
  }) async {
    final toolsByName = {for (final t in tools) t.name: t};
    final toolContext = AgentCallToolContext(
      state: state,
      agent: this,
      batchCallId: batchId,
      cancelToken: cancelToken,
    );

    final results = await runZoned(
      () => Future.wait([
        for (final call in calls)
          _executeSingleTool(call, toolsByName[call.name], cancelToken),
      ]),
      zoneValues: {AgentCallToolContext.zoneKey: toolContext},
    );

    return FunctionExecutionResultMessage(
      results: results,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<FunctionExecutionResult> _executeSingleTool(
    FunctionCall call,
    Tool? tool,
    CancelToken? cancelToken,
  ) async {
    _checkCancelled(cancelToken);
    if (tool == null) {
      return FunctionExecutionResult(
        id: call.id,
        name: call.name,
        arguments: call.arguments,
        isError: true,
        content: [TextPart('Unknown tool: ${call.name}')],
      );
    }

    Map<String, dynamic> args;
    try {
      final decoded = call.arguments.trim().isEmpty
          ? const <String, dynamic>{}
          : jsonDecode(call.arguments);
      if (decoded is Map<String, dynamic>) {
        args = decoded;
      } else if (decoded is Map) {
        args = decoded.cast<String, dynamic>();
      } else {
        args = {'value': decoded};
      }
    } catch (_) {
      args = {'raw': call.arguments};
    }

    final raw = await tool.executable(args);
    if (raw is AgentToolResult) {
      return FunctionExecutionResult(
        id: call.id,
        name: call.name,
        arguments: call.arguments,
        isError: raw.isError,
        content: raw.toContentParts(),
      );
    }
    final text = raw is String ? raw : jsonEncode(raw);
    return FunctionExecutionResult(
      id: call.id,
      name: call.name,
      arguments: call.arguments,
      isError: false,
      content: [TextPart(text)],
    );
  }

  Future<void> _persistState(String reason, {AgentException? runError}) async {
    final context = StatePersistenceHookContext(
      this,
      reason: reason,
      runError: runError,
    );
    for (final hook in hooks) {
      final decision = await hook.beforePersistState(context);
      switch (decision.action) {
        case StatePersistenceHookAction.skip:
          return;
        case StatePersistenceHookAction.abort:
          throw AgentException(
            AgentExceptionCode.persistenceError,
            decision.reason ?? 'State persistence aborted by hook',
            error: decision.error,
          );
        case StatePersistenceHookAction.proceed:
          break;
      }
    }

    // Always sanitize before persisting canonical state.
    final sanitized = MessageTransformer.sanitize(state.history.messages);
    state.history.messages
      ..clear()
      ..addAll(sanitized);

    if (autoSaveState != null) {
      await autoSaveState!(state);
    }

    for (final hook in hooks) {
      await hook.afterPersistState(context);
    }
  }

  void _checkCancelled(CancelToken? cancelToken) {
    if (cancelToken?.isCancelled ?? false) {
      throw AgentException(
        AgentExceptionCode.cancelled,
        'Agent cancelled by user',
        error: cancelToken?.cancelError,
      );
    }
  }
}

class _ModelTurnAccumulator {
  _ModelTurnAccumulator({required this.model});

  final String model;
  final _text = StringBuffer();
  final _thought = StringBuffer();
  final _calls = <FunctionCall>[];
  String? _thoughtSignature;
  String? _responseId;
  String? _stopReason;
  ModelUsage? _usage;

  void add(ModelMessage chunk) {
    if (chunk.textOutput != null) _text.write(chunk.textOutput);
    if (chunk.thought != null) _thought.write(chunk.thought);
    if (chunk.functionCalls.isNotEmpty) _calls.addAll(chunk.functionCalls);
    if (chunk.thoughtSignature != null) {
      _thoughtSignature = chunk.thoughtSignature;
    }
    if (chunk.responseId != null) _responseId = chunk.responseId;
    if (chunk.stopReason != null) _stopReason = chunk.stopReason;
    if (chunk.usage != null) _usage = chunk.usage;
  }

  ModelMessage build() {
    final text = _text.toString();
    final thought = _thought.toString();
    return ModelMessage(
      model: model,
      textOutput: text.isNotEmpty ? text : null,
      thought: thought.isNotEmpty ? thought : null,
      thoughtSignature: _thoughtSignature,
      functionCalls: List<FunctionCall>.unmodifiable(_calls),
      responseId: _responseId,
      stopReason: _stopReason ?? (_calls.isNotEmpty ? 'tool_calls' : 'stop'),
      usage: _usage,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
