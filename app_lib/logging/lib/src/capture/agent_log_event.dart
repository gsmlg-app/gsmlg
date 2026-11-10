import 'api_exchange_record.dart' show formatLogTimestamp;
import 'log_context.dart';

class AgentLogEvent {
  const AgentLogEvent({
    required this.ts,
    required this.eventType,
    this.context = const LogContext(),
    this.toolName,
    this.backend,
    this.requestId,
    this.level = 'INFO',
    this.isError = false,
    this.durationMs,
    this.summary = '',
    this.payload,
  });

  /// Inverse of [toJson]; the context is read from the flattened keys.
  factory AgentLogEvent.fromJson(Map<String, Object?> json) => AgentLogEvent(
        ts: DateTime.parse(json['ts']! as String),
        eventType: json['event_type']! as String,
        context: LogContext.fromJson(json),
        toolName: json['tool_name'] as String?,
        backend: json['backend'] as String?,
        requestId: json['request_id'] as String?,
        level: json['level'] as String? ?? 'INFO',
        isError: json['is_error'] as bool? ?? false,
        durationMs: (json['duration_ms'] as num?)?.toInt(),
        summary: json['summary'] as String? ?? '',
        payload: (json['payload'] as Map?)?.cast<String, Object?>(),
      );

  final DateTime ts;
  final String eventType;
  final LogContext context;
  final String? toolName, backend, requestId;

  /// Must be an uppercase package:logging name (INFO, CONFIG, WARNING, SEVERE,
  /// SHOUT, FINE, FINER, FINEST); the UI level filter matches these.
  final String level;
  final bool isError;
  final int? durationMs;
  final String summary;
  final Map<String, Object?>? payload;

  Map<String, Object?> toJson() => {
        'ts': formatLogTimestamp(ts),
        'event_type': eventType,
        if (context.conversationId != null)
          'conversation_id': context.conversationId,
        if (context.runId != null) 'run_id': context.runId,
        if (context.parentRunId != null) 'parent_run_id': context.parentRunId,
        if (context.turn != null) 'turn': context.turn,
        if (context.toolCallId != null) 'tool_call_id': context.toolCallId,
        if (toolName != null) 'tool_name': toolName,
        if (backend != null) 'backend': backend,
        if (requestId != null) 'request_id': requestId,
        'level': level,
        'is_error': isError,
        if (durationMs != null) 'duration_ms': durationMs,
        'summary': summary,
        if (payload != null) 'payload': payload,
      };
}
