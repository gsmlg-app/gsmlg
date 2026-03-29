import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monitor_models/src/protocol.dart';

@immutable
final class GpuMetrics extends Equatable {
  const GpuMetrics({
    required this.index,
    required this.name,
    required this.usagePercent,
    required this.memoryUsedBytes,
    required this.memoryTotalBytes,
    this.temperatureCelsius,
  });

  final int index;
  final String name;
  final double usagePercent;
  final int memoryUsedBytes;
  final int memoryTotalBytes;
  final double? temperatureCelsius;

  double get memoryUsagePercent =>
      memoryTotalBytes > 0 ? (memoryUsedBytes / memoryTotalBytes) * 100 : 0;

  factory GpuMetrics.fromJson(Map<String, dynamic> json) => GpuMetrics(
    index: json[Protocol.gpuIndex] as int,
    name: json[Protocol.gpuName] as String,
    usagePercent: (json[Protocol.usagePercent] as num).toDouble(),
    memoryUsedBytes: json[Protocol.memoryUsedBytes] as int,
    memoryTotalBytes: json[Protocol.memoryTotalBytes] as int,
    temperatureCelsius: (json[Protocol.temperatureCelsius] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    Protocol.gpuIndex: index,
    Protocol.gpuName: name,
    Protocol.usagePercent: usagePercent,
    Protocol.memoryUsedBytes: memoryUsedBytes,
    Protocol.memoryTotalBytes: memoryTotalBytes,
    if (temperatureCelsius != null)
      Protocol.temperatureCelsius: temperatureCelsius,
  };

  @override
  List<Object?> get props => [
    index,
    name,
    usagePercent,
    memoryUsedBytes,
    memoryTotalBytes,
    temperatureCelsius,
  ];
}
