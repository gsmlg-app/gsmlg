import 'dart:async' as async;

/// Correlation identifiers attached to a captured record.
class LogContext {
  const LogContext({
    this.conversationId,
    this.runId,
    this.parentRunId,
    this.generationId,
    this.toolCallId,
    this.turn,
  });

  final String? conversationId, runId, parentRunId, generationId, toolCallId;
  final int? turn;

  static final _zoneKey = Object();

  /// The context installed by the innermost enclosing [runZoned], if any.
  /// Capture clients use it when a request carries no explicit context.
  static LogContext? get current {
    final v = async.Zone.current[_zoneKey];
    return v is LogContext ? v : null;
  }

  /// Runs [body] in a zone where [current] returns [context].
  static R runZoned<R>(LogContext context, R Function() body) =>
      async.runZoned(body, zoneValues: {_zoneKey: context});

  Map<String, Object?> toJson() => {
        if (conversationId != null) 'conversation_id': conversationId,
        if (runId != null) 'run_id': runId,
        if (parentRunId != null) 'parent_run_id': parentRunId,
        if (generationId != null) 'generation_id': generationId,
        if (toolCallId != null) 'tool_call_id': toolCallId,
        if (turn != null) 'turn': turn,
      };
}
