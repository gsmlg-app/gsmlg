import 'dart:async';

import 'package:dio/dio.dart' show CancelToken;

import '../models/message.dart';
import '../models/model_config.dart';
import 'agent_event.dart';
import 'chat_agent_runtime.dart';

/// Runs agent turns and streams their events.
///
/// Implemented in-process by [InProcessAgentRunner] and across isolates by
/// `AgentHost`. Consumers acknowledge [ModelTurnCompletedEvent] and
/// [ToolCallCompletedEvent] once persisted.
abstract interface class AgentRunner {
  Stream<ChatAgentEvent> runStream({
    required String agentId,
    required String runId,
    required String sessionId,
    String? generationId,
    required ModelConfig modelConfig,
    required List<Message> historyMessages,
    required String userPrompt,
    CancelToken? cancelToken,
    int maxTurns = 25,
    Set<String>? allowedTools,
    void Function()? onFirstToken,
  });

  /// Cancels run [runId]; its stream ends with [AgentRunCancelledEvent].
  Future<void> stop(String runId);
}

/// [AgentRunner] over an in-process [ChatAgentRuntime]; [agentId] is unused.
class InProcessAgentRunner implements AgentRunner {
  InProcessAgentRunner(this.runtime);

  final ChatAgentRuntime runtime;
  final _tokens = <String, CancelToken>{};

  @override
  Stream<ChatAgentEvent> runStream({
    required String agentId,
    required String runId,
    required String sessionId,
    String? generationId,
    required ModelConfig modelConfig,
    required List<Message> historyMessages,
    required String userPrompt,
    CancelToken? cancelToken,
    int maxTurns = 25,
    Set<String>? allowedTools,
    void Function()? onFirstToken,
  }) {
    final token = cancelToken ?? CancelToken();
    _tokens[runId] = token;
    return runtime
        .runStream(
          runId: runId,
          sessionId: sessionId,
          generationId: generationId,
          modelConfig: modelConfig,
          historyMessages: historyMessages,
          userPrompt: userPrompt,
          cancelToken: token,
          maxTurns: maxTurns,
          allowedTools: allowedTools,
          onFirstToken: onFirstToken,
        )
        .transform(
          StreamTransformer<ChatAgentEvent, ChatAgentEvent>.fromHandlers(
            handleDone: (sink) {
              if (identical(_tokens[runId], token)) _tokens.remove(runId);
              sink.close();
            },
          ),
        );
  }

  @override
  Future<void> stop(String runId) async {
    final token = _tokens.remove(runId);
    if (token != null && !token.isCancelled) token.cancel('Stopped by user');
  }
}
