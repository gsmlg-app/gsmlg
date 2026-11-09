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

  Map<String, Object?> toJson() => {
        if (conversationId != null) 'conversation_id': conversationId,
        if (runId != null) 'run_id': runId,
        if (parentRunId != null) 'parent_run_id': parentRunId,
        if (generationId != null) 'generation_id': generationId,
        if (toolCallId != null) 'tool_call_id': toolCallId,
        if (turn != null) 'turn': turn,
      };
}
