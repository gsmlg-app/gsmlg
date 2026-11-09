import 'dart:convert';

import 'package:app_logging/app_logging.dart';

import 'agent_event.dart';
import 'agent_invocation.dart';

/// Maps a [ChatAgentEvent] to a persistable [AgentLogEvent].
///
/// Returns `null` for events that are not logged (streaming chunks).
/// [turn] is the 1-based model turn the event belongs to, matching the
/// `turn` of the LLM HTTP exchange logged for the same run.
AgentLogEvent? agentLogEventFrom(ChatAgentEvent e, {int? turn}) {
  LogContext ctx({String? toolCallId}) => LogContext(
    conversationId: e.sessionId,
    runId: e.runId,
    turn: turn,
    toolCallId: toolCallId,
  );
  final ts = DateTime.now();

  switch (e) {
    case ModelChunkReceivedEvent():
      return null;
    case AgentRunStartedEvent(:final inputMessages):
      return AgentLogEvent(
        ts: ts,
        eventType: 'agent_run_started',
        context: ctx(),
        summary: 'run started',
        payload: {'input_message_count': inputMessages.length},
      );
    case ModelTurnStartedEvent(:final turnIndex, :final model):
      return AgentLogEvent(
        ts: ts,
        eventType: 'model_turn_started',
        context: ctx(),
        summary: 'turn ${turnIndex + 1} started ($model)',
        payload: {'turn_index': turnIndex, 'model': model},
      );
    case ModelTurnCompletedEvent(:final turnIndex, :final modelMessage):
      return AgentLogEvent(
        ts: ts,
        eventType: 'model_turn_completed',
        context: ctx(),
        summary: 'turn ${turnIndex + 1} completed',
        payload: {
          'turn_index': turnIndex,
          'text_output': modelMessage.textOutput,
          'thought': modelMessage.thought,
          'function_calls': [
            for (final fc in modelMessage.functionCalls)
              {'id': fc.id, 'name': fc.name, 'arguments': fc.arguments},
          ],
        },
      );
    case ToolCallPreparedEvent(
      :final callId,
      :final toolName,
      :final arguments,
    ):
      return AgentLogEvent(
        ts: ts,
        eventType: 'tool_call_prepared',
        context: ctx(toolCallId: callId),
        toolName: toolName,
        summary: 'tool $toolName prepared',
        payload: {'arguments': arguments},
      );
    case ToolCallStartedEvent(:final callId, :final toolName, :final arguments):
      return AgentLogEvent(
        ts: ts,
        eventType: 'tool_call_started',
        context: ctx(toolCallId: callId),
        toolName: toolName,
        summary: 'tool $toolName started',
        payload: {'arguments': arguments},
      );
    case ToolCallCompletedEvent(
      :final callId,
      :final toolName,
      :final arguments,
      :final receipt,
    ):
      final cancelled = receipt.status == InvocationStatus.cancelled;
      final detail = receipt.errorType == null
          ? '${receipt.result}'
          : '${receipt.errorType}: ${receipt.result}';
      return AgentLogEvent(
        ts: ts,
        eventType: 'tool_call_completed',
        context: ctx(toolCallId: callId),
        toolName: toolName,
        backend: receipt.backend,
        level: receipt.isError ? (cancelled ? 'WARNING' : 'SEVERE') : 'INFO',
        isError: receipt.isError,
        durationMs: receipt.durationMs,
        summary: _oneLine(
          receipt.isError
              ? 'tool $toolName → ${cancelled ? 'cancelled' : 'error'}: $detail'
              : 'tool $toolName → ok',
        ),
        payload: {
          'arguments': arguments,
          'result': _jsonSafe(receipt.result),
          'status': receipt.status.name,
          'invocation_id': receipt.invocationId,
          if (receipt.errorType != null) 'error_type': receipt.errorType,
          if (receipt.stackTrace != null) 'stack_trace': receipt.stackTrace,
        },
      );
    case AgentRunCompletedEvent(:final finalResponse):
      return AgentLogEvent(
        ts: ts,
        eventType: 'agent_run_completed',
        context: ctx(),
        summary: 'run completed',
        payload: {'has_final_response': finalResponse != null},
      );
    case AgentRunFailedEvent(:final error, :final stackTrace):
      return AgentLogEvent(
        ts: ts,
        eventType: 'agent_run_failed',
        context: ctx(),
        level: 'SEVERE',
        isError: true,
        summary: _oneLine('run failed: $error'),
        payload: {
          'error': error.toString(),
          'error_type': error.runtimeType.toString(),
          if (stackTrace != null) 'stack_trace': stackTrace.toString(),
        },
      );
    case AgentRunCancelledEvent(:final reason):
      return AgentLogEvent(
        ts: ts,
        eventType: 'agent_run_cancelled',
        context: ctx(),
        level: 'WARNING',
        summary: _oneLine('run cancelled: $reason'),
        payload: {'reason': reason},
      );
  }
}

String _oneLine(String s) {
  final line = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return line.length <= 200 ? line : '${line.substring(0, 197)}...';
}

Object? _jsonSafe(Object? v) {
  try {
    return jsonDecode(jsonEncode(v, toEncodable: (o) => o.toString()));
  } catch (_) {
    return v.toString();
  }
}
