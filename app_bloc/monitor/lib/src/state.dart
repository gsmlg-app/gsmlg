part of 'bloc.dart';

/// Represents a monitored host and its current state.
@immutable
final class MonitorHost extends Equatable {
  MonitorHost({
    required this.id,
    required this.ip,
    required this.port,
    required this.status,
    this.hostInfo,
    this.metrics,
    this.label,
    this.isManual = true,
    this.trustStatus = TrustStatus.unknown,
    this.certFingerprint,
    this.versionWarning = false,
    this.interval = 3,
    RingBuffer<double>? cpuHistory,
    RingBuffer<double>? memoryHistory,
    Map<String, RingBuffer<double>>? rxHistory,
    Map<String, RingBuffer<double>>? txHistory,
    Map<String, RingBuffer<double>>? readHistory,
    Map<String, RingBuffer<double>>? writeHistory,
  })  : cpuHistory = cpuHistory ?? RingBuffer<double>(),
        memoryHistory = memoryHistory ?? RingBuffer<double>(),
        rxHistory = rxHistory ?? const {},
        txHistory = txHistory ?? const {},
        readHistory = readHistory ?? const {},
        writeHistory = writeHistory ?? const {};

  final String id;
  final String ip;
  final int port;
  final ConnectionStatus status;
  final HostInfo? hostInfo;
  final SystemMetrics? metrics;
  final String? label;
  final bool isManual;
  final TrustStatus trustStatus;
  final String? certFingerprint;
  final bool versionWarning;
  final int interval;

  final RingBuffer<double> cpuHistory;
  final RingBuffer<double> memoryHistory;
  final Map<String, RingBuffer<double>> rxHistory;
  final Map<String, RingBuffer<double>> txHistory;
  final Map<String, RingBuffer<double>> readHistory;
  final Map<String, RingBuffer<double>> writeHistory;

  String get displayName => label ?? hostInfo?.hostname ?? '$ip:$port';

  MonitorHost copyWith({
    ConnectionStatus? status,
    HostInfo? hostInfo,
    SystemMetrics? metrics,
    String? label,
    TrustStatus? trustStatus,
    String? certFingerprint,
    bool? versionWarning,
    int? interval,
    RingBuffer<double>? cpuHistory,
    RingBuffer<double>? memoryHistory,
    Map<String, RingBuffer<double>>? rxHistory,
    Map<String, RingBuffer<double>>? txHistory,
    Map<String, RingBuffer<double>>? readHistory,
    Map<String, RingBuffer<double>>? writeHistory,
  }) =>
      MonitorHost(
        id: id,
        ip: ip,
        port: port,
        status: status ?? this.status,
        hostInfo: hostInfo ?? this.hostInfo,
        metrics: metrics ?? this.metrics,
        label: label ?? this.label,
        isManual: isManual,
        trustStatus: trustStatus ?? this.trustStatus,
        certFingerprint: certFingerprint ?? this.certFingerprint,
        versionWarning: versionWarning ?? this.versionWarning,
        interval: interval ?? this.interval,
        cpuHistory: cpuHistory ?? this.cpuHistory,
        memoryHistory: memoryHistory ?? this.memoryHistory,
        rxHistory: rxHistory ?? this.rxHistory,
        txHistory: txHistory ?? this.txHistory,
        readHistory: readHistory ?? this.readHistory,
        writeHistory: writeHistory ?? this.writeHistory,
      );

  @override
  List<Object?> get props => [
        id,
        ip,
        port,
        status,
        hostInfo,
        metrics,
        label,
        isManual,
        trustStatus,
        certFingerprint,
        versionWarning,
        interval,
        cpuHistory,
        memoryHistory,
        rxHistory,
        txHistory,
        readHistory,
        writeHistory,
      ];
}

@immutable
sealed class MonitorState extends Equatable {
  const MonitorState();
}

final class MonitorInitial extends MonitorState {
  const MonitorInitial();

  @override
  List<Object?> get props => [];
}

final class MonitorLoaded extends MonitorState {
  const MonitorLoaded({this.hosts = const {}, this.selectedHostId});

  final Map<String, MonitorHost> hosts;
  final String? selectedHostId;

  MonitorHost? get selectedHost =>
      selectedHostId != null ? hosts[selectedHostId] : null;

  @override
  List<Object?> get props => [hosts, selectedHostId];
}
