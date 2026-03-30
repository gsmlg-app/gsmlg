part of 'bloc.dart';

@immutable
sealed class VultrEvent extends Equatable {
  const VultrEvent();

  @override
  List<Object?> get props => [];
}

/// Select a Vultr service account and load its instances.
final class VultrSelectAccount extends VultrEvent {
  const VultrSelectAccount({required this.accountId});

  final int accountId;

  @override
  List<Object?> get props => [accountId];
}

/// Refresh the instances list.
final class VultrRefresh extends VultrEvent {
  const VultrRefresh();
}

/// Start a server instance.
final class VultrStartInstance extends VultrEvent {
  const VultrStartInstance({required this.instanceId});

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Stop (halt) a server instance.
final class VultrStopInstance extends VultrEvent {
  const VultrStopInstance({required this.instanceId});

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Reboot a server instance.
final class VultrRebootInstance extends VultrEvent {
  const VultrRebootInstance({required this.instanceId});

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}
