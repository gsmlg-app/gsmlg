part of 'bloc.dart';

@immutable
sealed class VultrState extends Equatable {
  const VultrState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
final class VultrInitial extends VultrState {
  const VultrInitial();
}

/// Loading state
final class VultrLoading extends VultrState {
  const VultrLoading();
}

/// Successfully loaded with instances list
final class VultrLoaded extends VultrState {
  const VultrLoaded({
    required this.instances,
    required this.apiKey,
    this.refreshing = false,
    this.actionInstanceId,
    this.error,
  });

  final List<InstanceGet> instances;
  final String apiKey;
  final bool refreshing;
  final String? actionInstanceId;
  final String? error;

  @override
  List<Object?> get props => [
    instances,
    apiKey,
    refreshing,
    actionInstanceId,
    error,
  ];
}

/// Not connected (no API key stored)
final class VultrDisconnected extends VultrState {
  const VultrDisconnected();
}

/// Error state
final class VultrError extends VultrState {
  const VultrError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
