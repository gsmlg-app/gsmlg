part of 'bloc.dart';

@immutable
sealed class VultrEvent extends Equatable {
  const VultrEvent();

  @override
  List<Object?> get props => [];
}

/// Load Vultr instances from stored API key
final class VultrLoad extends VultrEvent {
  const VultrLoad();
}

/// Connect with an API key
final class VultrConnect extends VultrEvent {
  const VultrConnect({required this.apiKey});

  final String apiKey;

  @override
  List<Object?> get props => [apiKey];
}

/// Disconnect and remove API key
final class VultrDisconnect extends VultrEvent {
  const VultrDisconnect();
}

/// Refresh the instances list
final class VultrRefresh extends VultrEvent {
  const VultrRefresh();
}

/// Start a server instance
final class VultrStartInstance extends VultrEvent {
  const VultrStartInstance({required this.instanceId});

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Stop (halt) a server instance
final class VultrStopInstance extends VultrEvent {
  const VultrStopInstance({required this.instanceId});

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}

/// Reboot a server instance
final class VultrRebootInstance extends VultrEvent {
  const VultrRebootInstance({required this.instanceId});

  final String instanceId;

  @override
  List<Object?> get props => [instanceId];
}
