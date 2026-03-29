import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monitor_models/src/cpu_metrics.dart';
import 'package:monitor_models/src/disk_metrics.dart';
import 'package:monitor_models/src/gpu_metrics.dart';
import 'package:monitor_models/src/host_info.dart';
import 'package:monitor_models/src/memory_metrics.dart';
import 'package:monitor_models/src/network_metrics.dart';
import 'package:monitor_models/src/protocol.dart';

enum MonitorMessageType {
  hostInfo,
  metrics,
  ping,
  pong,
  setInterval;

  static MonitorMessageType fromString(String value) => switch (value) {
        Protocol.hostInfo => MonitorMessageType.hostInfo,
        Protocol.metrics => MonitorMessageType.metrics,
        Protocol.ping => MonitorMessageType.ping,
        Protocol.pong => MonitorMessageType.pong,
        Protocol.setInterval => MonitorMessageType.setInterval,
        _ => throw ArgumentError('Unknown message type: $value'),
      };

  String toJsonString() => switch (this) {
        MonitorMessageType.hostInfo => Protocol.hostInfo,
        MonitorMessageType.metrics => Protocol.metrics,
        MonitorMessageType.ping => Protocol.ping,
        MonitorMessageType.pong => Protocol.pong,
        MonitorMessageType.setInterval => Protocol.setInterval,
      };
}

@immutable
final class SystemMetrics extends Equatable {
  const SystemMetrics({
    this.cpu,
    this.memory,
    this.gpus = const [],
    this.networks = const [],
    this.disks = const [],
  });

  final CpuMetrics? cpu;
  final MemoryMetrics? memory;
  final List<GpuMetrics> gpus;
  final List<NetworkMetrics> networks;
  final List<DiskMetrics> disks;

  factory SystemMetrics.fromJson(Map<String, dynamic> json) => SystemMetrics(
        cpu: json[Protocol.cpu] != null
            ? CpuMetrics.fromJson(json[Protocol.cpu] as Map<String, dynamic>)
            : null,
        memory: json[Protocol.memory] != null
            ? MemoryMetrics.fromJson(
                json[Protocol.memory] as Map<String, dynamic>)
            : null,
        gpus: (json[Protocol.gpu] as List<dynamic>?)
                ?.map((e) => GpuMetrics.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        networks: (json[Protocol.network] as List<dynamic>?)
                ?.map(
                    (e) => NetworkMetrics.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        disks: (json[Protocol.disk] as List<dynamic>?)
                ?.map((e) => DiskMetrics.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        if (cpu != null) Protocol.cpu: cpu!.toJson(),
        if (memory != null) Protocol.memory: memory!.toJson(),
        Protocol.gpu: gpus.map((g) => g.toJson()).toList(),
        Protocol.network: networks.map((n) => n.toJson()).toList(),
        Protocol.disk: disks.map((d) => d.toJson()).toList(),
      };

  @override
  List<Object?> get props => [cpu, memory, gpus, networks, disks];
}

@immutable
final class MonitorMessage extends Equatable {
  const MonitorMessage({
    required this.type,
    required this.payload,
  });

  final MonitorMessageType type;
  final Map<String, dynamic> payload;

  factory MonitorMessage.fromJson(Map<String, dynamic> json) => MonitorMessage(
        type: MonitorMessageType.fromString(json[Protocol.type] as String),
        payload: json[Protocol.payload] as Map<String, dynamic>? ?? const {},
      );

  Map<String, dynamic> toJson() => {
        Protocol.type: type.toJsonString(),
        Protocol.payload: payload,
      };

  HostInfo get hostInfo => HostInfo.fromJson(payload);
  SystemMetrics get systemMetrics => SystemMetrics.fromJson(payload);

  @override
  List<Object?> get props => [type, payload];
}
