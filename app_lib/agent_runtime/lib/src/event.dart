import 'turn_state.dart';

/// Normalized runtime event categories emitted by `AgentRuntime.runStream`
/// (modeled after `Sigma.Agent.Event`).
enum StreamingEventType {
  turnStateChanged,
  modelChunkMessage,
  fullModelMessage,
  functionCallRequest,
  functionCallResult,
}

/// Event yielded by `AgentRuntime.runStream`.
class StreamingEvent {
  const StreamingEvent({required this.eventType, this.data, this.turnState});

  final StreamingEventType eventType;
  final dynamic data;
  final TurnState? turnState;
}
