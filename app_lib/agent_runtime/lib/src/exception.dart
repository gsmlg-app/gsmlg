/// Reason an agent run failed or stopped.
enum AgentExceptionCode {
  unknown,
  cancelled,
  loopDetection,
  maxTurnsExceeded,
  providerError,
  persistenceError,
  hookAborted,
}

/// Typed exception surfaced by `AgentRuntime` runs.
class AgentException implements Exception {
  const AgentException(this.code, this.message, {this.error, this.stackTrace});

  final AgentExceptionCode code;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() {
    if (error != null) {
      return 'AgentException(code: $code, message: $message, error: $error)';
    }
    return 'AgentException(code: $code, message: $message)';
  }
}
