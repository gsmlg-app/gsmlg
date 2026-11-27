import 'dart:async';
import 'dart:isolate';

import 'package:agent_runtime/agent_runtime.dart'
    show LLMMessage, ModelMessage, ModelUsage;

import '../agent/agent_event.dart';
import '../models/message.dart' as app;
import '../models/model_config.dart';
import '../models/wire_codecs.dart';

/// An error that happened in another isolate, reconstructed from strings.
class RemoteAgentError implements Exception {
  const RemoteAgentError({required this.type, required this.message});

  /// `runtimeType` of the original error.
  final String type;
  final String message;

  @override
  String toString() => message;
}

Map<String, Object?> _asMap(Object? v) => (v as Map).cast<String, Object?>();

Map<String, dynamic> _json(Object? v) => Map<String, dynamic>.from(v as Map);

/// Encodes [e] as a plain map. [ackId] is attached to events that carry an
/// acknowledgement; the receiver replies with a [RunAck] using that id.
Map<String, Object?> agentEventToWire(ChatAgentEvent e, {String? ackId}) {
  final base = <String, Object?>{'runId': e.runId, 'sessionId': e.sessionId};
  return switch (e) {
    final AgentRunStartedEvent e => {
      ...base,
      'type': 'runStarted',
      'inputMessages': [for (final m in e.inputMessages) m.toJson()],
    },
    final ModelTurnStartedEvent e => {
      ...base,
      'type': 'turnStarted',
      'turnIndex': e.turnIndex,
      'model': e.model,
      if (e.messageId != null) 'messageId': e.messageId,
    },
    final ModelChunkReceivedEvent e => {
      ...base,
      'type': 'chunk',
      'turnIndex': e.turnIndex,
      if (e.messageId != null) 'messageId': e.messageId,
      'textChunk': e.textChunk,
      'thoughtChunk': e.thoughtChunk,
      'isFirstToken': e.isFirstToken,
      if (e.timeToFirstToken != null)
        'timeToFirstTokenUs': e.timeToFirstToken!.inMicroseconds,
    },
    final ModelTurnCompletedEvent e => {
      ...base,
      'type': 'turnCompleted',
      'turnIndex': e.turnIndex,
      'modelMessage': e.modelMessage.toJson(),
      if (e.message != null) 'message': e.message!.toWire(),
      'persisted': e.persisted,
      'ackId': ackId,
    },
    final ToolCallPreparedEvent e => {
      ...base,
      'type': 'toolPrepared',
      'callId': e.callId,
      'toolName': e.toolName,
      'arguments': e.arguments,
    },
    final ToolCallStartedEvent e => {
      ...base,
      'type': 'toolStarted',
      'callId': e.callId,
      'toolName': e.toolName,
      'arguments': e.arguments,
    },
    final ToolCallCompletedEvent e => {
      ...base,
      'type': 'toolCompleted',
      'callId': e.callId,
      'toolName': e.toolName,
      'arguments': e.arguments,
      'receipt': e.receipt.toWire(),
      if (e.message != null) 'message': e.message!.toWire(),
      'persisted': e.persisted,
      'ackId': ackId,
    },
    final AgentRunCompletedEvent e => {
      ...base,
      'type': 'runCompleted',
      'finalResponse': e.finalResponse?.toJson(),
      'usage': e.usage?.toJson(),
    },
    final AgentRunFailedEvent e => {
      ...base,
      'type': 'runFailed',
      if (e.errorMessage != null) 'errorMessage': e.errorMessage!.toWire(),
      'error': {
        'type': switch (e.error) {
          final RemoteAgentError r => r.type,
          final other => other.runtimeType.toString(),
        },
        'message': e.error.toString(),
        'stackTrace': e.stackTrace?.toString(),
      },
    },
    final AgentRunCancelledEvent e => {
      ...base,
      'type': 'runCancelled',
      'reason': e.reason,
      if (e.partialMessage != null)
        'partialMessage': e.partialMessage!.toWire(),
    },
    final SubAgentUpdatedEvent e => {
      ...base,
      'type': 'subAgentUpdated',
      'taskId': e.taskId,
      'parentRunId': e.parentRunId,
      'childRunId': e.childRunId,
      'workerName': e.workerName,
      'goal': e.goal,
      'status': e.status,
      'depth': e.depth,
      'summary': e.summary,
      'error': e.error,
      'durationMs': e.durationMs,
    },
  };
}

/// Decodes [agentEventToWire] output. [acknowledgement] is attached to
/// events that carry one; completers never cross isolates.
ChatAgentEvent agentEventFromWire(
  Map<String, Object?> m, {
  Completer<void>? acknowledgement,
}) {
  final runId = m['runId'] as String;
  final sessionId = m['sessionId'] as String;
  return switch (m['type']) {
    'runStarted' => AgentRunStartedEvent(
      runId: runId,
      sessionId: sessionId,
      inputMessages: [
        for (final j in (m['inputMessages'] as List))
          LLMMessage.fromJson(_json(j)),
      ],
    ),
    'turnStarted' => ModelTurnStartedEvent(
      runId: runId,
      sessionId: sessionId,
      turnIndex: m['turnIndex'] as int,
      model: m['model'] as String,
      messageId: m['messageId'] as String?,
    ),
    'chunk' => ModelChunkReceivedEvent(
      runId: runId,
      sessionId: sessionId,
      turnIndex: m['turnIndex'] as int,
      messageId: m['messageId'] as String?,
      textChunk: m['textChunk'] as String?,
      thoughtChunk: m['thoughtChunk'] as String?,
      isFirstToken: m['isFirstToken'] as bool? ?? false,
      timeToFirstToken: m['timeToFirstTokenUs'] is int
          ? Duration(microseconds: m['timeToFirstTokenUs'] as int)
          : null,
    ),
    'turnCompleted' => ModelTurnCompletedEvent(
      runId: runId,
      sessionId: sessionId,
      turnIndex: m['turnIndex'] as int,
      modelMessage: ModelMessage.fromJson(_json(m['modelMessage'])),
      message: m['message'] == null
          ? null
          : messageFromWire(_asMap(m['message'])) as app.AssistantMessage,
      persisted: m['persisted'] as bool? ?? false,
      acknowledgement: acknowledgement,
    ),
    'toolPrepared' => ToolCallPreparedEvent(
      runId: runId,
      sessionId: sessionId,
      callId: m['callId'] as String,
      toolName: m['toolName'] as String,
      arguments: m['arguments'] as String,
    ),
    'toolStarted' => ToolCallStartedEvent(
      runId: runId,
      sessionId: sessionId,
      callId: m['callId'] as String,
      toolName: m['toolName'] as String,
      arguments: m['arguments'] as String,
    ),
    'toolCompleted' => ToolCallCompletedEvent(
      runId: runId,
      sessionId: sessionId,
      callId: m['callId'] as String,
      toolName: m['toolName'] as String,
      arguments: m['arguments'] as String,
      receipt: toolInvocationReceiptFromWire(_asMap(m['receipt'])),
      message: m['message'] == null
          ? null
          : messageFromWire(_asMap(m['message'])) as app.ToolResponseMessage,
      persisted: m['persisted'] as bool? ?? false,
      acknowledgement: acknowledgement,
    ),
    'runCompleted' => AgentRunCompletedEvent(
      runId: runId,
      sessionId: sessionId,
      finalResponse: m['finalResponse'] == null
          ? null
          : ModelMessage.fromJson(_json(m['finalResponse'])),
      usage: m['usage'] == null ? null : ModelUsage.fromJson(_json(m['usage'])),
    ),
    'runFailed' => () {
      final err = _asMap(m['error']);
      final trace = err['stackTrace'] as String?;
      return AgentRunFailedEvent(
        runId: runId,
        sessionId: sessionId,
        error: RemoteAgentError(
          type: err['type'] as String,
          message: err['message'] as String,
        ),
        stackTrace: trace == null ? null : StackTrace.fromString(trace),
        errorMessage: m['errorMessage'] == null
            ? null
            : messageFromWire(_asMap(m['errorMessage']))
                  as app.AssistantMessage,
      );
    }(),
    'runCancelled' => AgentRunCancelledEvent(
      runId: runId,
      sessionId: sessionId,
      reason: m['reason'] as String,
      partialMessage: m['partialMessage'] == null
          ? null
          : messageFromWire(_asMap(m['partialMessage']))
                as app.AssistantMessage,
    ),
    'subAgentUpdated' => SubAgentUpdatedEvent(
      runId: runId,
      sessionId: sessionId,
      taskId: m['taskId'] as String,
      parentRunId: m['parentRunId'] as String,
      childRunId: m['childRunId'] as String,
      workerName: m['workerName'] as String,
      goal: m['goal'] as String,
      status: m['status'] as String,
      depth: m['depth'] as int,
      summary: m['summary'] as String?,
      error: m['error'] as String?,
      durationMs: m['durationMs'] as int?,
    ),
    final t => throw ArgumentError('Unknown agent event type: $t'),
  };
}

/// Main -> agent isolate: start a run. Events flow back over [eventsPort].
class StartRun {
  const StartRun({
    this.agentId,
    required this.runId,
    required this.sessionId,
    required this.generationId,
    required this.history,
    required this.userPrompt,
    required this.modelConfig,
    this.apiKey,
    required this.allowedTools,
    required this.maxTurns,
    required this.mcpProfiles,
    required this.eventsPort,
  });

  factory StartRun.fromWire(Map<String, Object?> m) => StartRun(
    agentId: m['agentId'] as String?,
    runId: m['runId'] as String,
    sessionId: m['sessionId'] as String,
    generationId: m['generationId'] as String,
    history: [
      for (final h in (m['history'] as List)) messageFromWire(_asMap(h)),
    ],
    userPrompt: messageFromWire(_asMap(m['userPrompt'])) as app.UserMessage,
    modelConfig: modelConfigFromWire(_asMap(m['modelConfig'])),
    apiKey: m['apiKey'] as String?,
    allowedTools: (m['allowedTools'] as List?)?.cast<String>(),
    maxTurns: m['maxTurns'] as int,
    mcpProfiles: (m['mcpProfiles'] as List).cast<String>(),
    eventsPort: m['eventsPort'] as SendPort,
  );

  final String? agentId;
  final String runId;
  final String sessionId;
  final String generationId;
  final List<app.Message> history;
  final app.UserMessage userPrompt;
  final ModelConfig modelConfig;

  /// Resolved on the main isolate; never logged.
  final String? apiKey;

  /// Null means all tools.
  final List<String>? allowedTools;
  final int maxTurns;
  final List<String> mcpProfiles;
  final SendPort eventsPort;

  Map<String, Object?> toWire() => {
    if (agentId != null) 'agentId': agentId,
    'runId': runId,
    'sessionId': sessionId,
    'generationId': generationId,
    'history': [for (final h in history) h.toWire()],
    'userPrompt': userPrompt.toWire(),
    'modelConfig': modelConfig.toWire(),
    'apiKey': apiKey,
    'allowedTools': allowedTools,
    'maxTurns': maxTurns,
    'mcpProfiles': mcpProfiles,
    'eventsPort': eventsPort,
  };
}

/// Main -> agent isolate: persistence acknowledgement for an event.
class RunAck {
  const RunAck({
    required this.runId,
    required this.ackId,
    required this.ok,
    this.error,
  });

  factory RunAck.fromWire(Map<String, Object?> m) => RunAck(
    runId: m['runId'] as String,
    ackId: m['ackId'] as String,
    ok: m['ok'] as bool,
    error: m['error'] as String?,
  );

  final String runId;
  final String ackId;
  final bool ok;
  final String? error;

  Map<String, Object?> toWire() => {
    'runId': runId,
    'ackId': ackId,
    'ok': ok,
    'error': error,
  };
}

/// Main -> agent isolate: cancel a run.
class CancelRun {
  const CancelRun({required this.runId});

  factory CancelRun.fromWire(Map<String, Object?> m) =>
      CancelRun(runId: m['runId'] as String);

  final String runId;

  Map<String, Object?> toWire() => {'runId': runId};
}
