import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monitor_models/src/protocol.dart';

@immutable
final class GpuInfo extends Equatable {
  const GpuInfo({
    required this.index,
    required this.name,
    required this.memoryTotalBytes,
  });

  final int index;
  final String name;
  final int memoryTotalBytes;

  factory GpuInfo.fromJson(Map<String, dynamic> json) => GpuInfo(
        index: json[Protocol.gpuIndex] as int,
        name: json[Protocol.gpuName] as String,
        memoryTotalBytes: json[Protocol.gpuMemoryTotal] as int,
      );

  Map<String, dynamic> toJson() => {
        Protocol.gpuIndex: index,
        Protocol.gpuName: name,
        Protocol.gpuMemoryTotal: memoryTotalBytes,
      };

  @override
  List<Object?> get props => [index, name, memoryTotalBytes];
}

@immutable
final class HostInfo extends Equatable {
  const HostInfo({
    required this.hostname,
    required this.os,
    required this.osVersion,
    required this.cpuModel,
    required this.cpuCores,
    required this.totalMemory,
    required this.agentVersion,
    this.gpus = const [],
  });

  final String hostname;
  final String os;
  final String osVersion;
  final String cpuModel;
  final int cpuCores;
  final int totalMemory;
  final String agentVersion;
  final List<GpuInfo> gpus;

  factory HostInfo.fromJson(Map<String, dynamic> json) => HostInfo(
        hostname: json[Protocol.hostname] as String,
        os: json[Protocol.os] as String,
        osVersion: json[Protocol.osVersion] as String,
        cpuModel: json[Protocol.cpuModel] as String,
        cpuCores: json[Protocol.cpuCores] as int,
        totalMemory: json[Protocol.totalMemory] as int,
        agentVersion: json[Protocol.agentVersion] as String,
        gpus: (json[Protocol.gpus] as List<dynamic>?)
                ?.map(
                    (e) => GpuInfo.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        Protocol.hostname: hostname,
        Protocol.os: os,
        Protocol.osVersion: osVersion,
        Protocol.cpuModel: cpuModel,
        Protocol.cpuCores: cpuCores,
        Protocol.totalMemory: totalMemory,
        Protocol.agentVersion: agentVersion,
        Protocol.gpus: gpus.map((g) => g.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        hostname,
        os,
        osVersion,
        cpuModel,
        cpuCores,
        totalMemory,
        agentVersion,
        gpus,
      ];
}
