part of 'bloc.dart';

@immutable
sealed class VultrState extends Equatable {
  const VultrState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no account selected yet.
final class VultrInitial extends VultrState {
  const VultrInitial();
}

/// Loading state.
final class VultrLoading extends VultrState {
  const VultrLoading();
}

/// Successfully loaded with instances list.
final class VultrLoaded extends VultrState {
  const VultrLoaded({
    required this.instances,
    required this.accountId,
    this.refreshing = false,
    this.actionInstanceId,
    this.error,
  });

  final List<InstanceGet> instances;
  final int accountId;
  final bool refreshing;
  final String? actionInstanceId;
  final String? error;

  @override
  List<Object?> get props => [
    instances,
    accountId,
    refreshing,
    actionInstanceId,
    error,
  ];
}

/// Error state.
final class VultrError extends VultrState {
  const VultrError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
