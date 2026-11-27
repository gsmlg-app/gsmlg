import 'package:equatable/equatable.dart';

/// Active-turn lifecycle phase, modeled after `Sigma.Agent.TurnState`.
enum TurnPhase {
  idle,
  streamingProvider,
  runningTools,
  cancelling,
  completed,
  failed,
  cancelled,
}

/// Pure active-turn lifecycle state.
class TurnState extends Equatable {
  const TurnState({
    this.turnId,
    this.turnIndex = 0,
    this.phase = TurnPhase.idle,
  });

  final String? turnId;
  final int turnIndex;
  final TurnPhase phase;

  static const idle = TurnState();

  bool get isActive => switch (phase) {
    TurnPhase.streamingProvider ||
    TurnPhase.runningTools ||
    TurnPhase.cancelling => true,
    _ => false,
  };

  TurnState start(String turnId, {int turnIndex = 0}) => TurnState(
    turnId: turnId,
    turnIndex: turnIndex,
    phase: TurnPhase.streamingProvider,
  );

  TurnState transition(TurnPhase nextPhase, {int? turnIndex}) => TurnState(
    turnId: turnId,
    turnIndex: turnIndex ?? this.turnIndex,
    phase: nextPhase,
  );

  @override
  List<Object?> get props => [turnId, turnIndex, phase];
}
