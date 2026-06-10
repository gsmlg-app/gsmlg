part of 'bloc.dart';

@immutable
sealed class MonitorEvent {
  const MonitorEvent();
}

final class MonitorConnectHost extends MonitorEvent {
  const MonitorConnectHost({required this.hostId});
  final String hostId;
}

final class MonitorDisconnectHost extends MonitorEvent {
  const MonitorDisconnectHost({required this.hostId});
  final String hostId;
}

final class MonitorDisconnectAllHosts extends MonitorEvent {
  const MonitorDisconnectAllHosts();
}

final class MonitorAddManualHost extends MonitorEvent {
  const MonitorAddManualHost({required this.ip, required this.port});
  final String ip;
  final int port;
}

final class MonitorRemoveHost extends MonitorEvent {
  const MonitorRemoveHost({required this.hostId});
  final String hostId;
}

final class MonitorDiscoverHosts extends MonitorEvent {
  const MonitorDiscoverHosts();
}

final class MonitorTrustHost extends MonitorEvent {
  const MonitorTrustHost({required this.hostId});
  final String hostId;
}

final class MonitorRejectHost extends MonitorEvent {
  const MonitorRejectHost({required this.hostId});
  final String hostId;
}

final class MonitorSetInterval extends MonitorEvent {
  const MonitorSetInterval({required this.hostId, required this.seconds});
  final String hostId;
  final int seconds;
}

final class MonitorPingHost extends MonitorEvent {
  const MonitorPingHost({required this.hostId});
  final String hostId;
}

// Internal events
final class _MonitorMetricsReceived extends MonitorEvent {
  const _MonitorMetricsReceived({required this.hostId, required this.metrics});
  final String hostId;
  final SystemMetrics metrics;
}

final class _MonitorConnectionStatusChanged extends MonitorEvent {
  const _MonitorConnectionStatusChanged({
    required this.hostId,
    required this.status,
    this.error,
  });
  final String hostId;
  final ConnectionStatus status;
  final Object? error;
}

final class _MonitorHostInfoReceived extends MonitorEvent {
  const _MonitorHostInfoReceived({
    required this.hostId,
    required this.hostInfo,
  });
  final String hostId;
  final HostInfo hostInfo;
}

final class _MonitorHostDiscovered extends MonitorEvent {
  const _MonitorHostDiscovered({required this.host});
  final DiscoveredHost host;
}

final class _MonitorCertificateReceived extends MonitorEvent {
  const _MonitorCertificateReceived({
    required this.hostId,
    required this.fingerprint,
  });
  final String hostId;
  final String fingerprint;
}
