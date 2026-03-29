import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monitor_models/src/protocol.dart';

@immutable
final class MemoryMetrics extends Equatable {
  const MemoryMetrics({
    required this.usedBytes,
    required this.totalBytes,
    this.swapUsedBytes = 0,
    this.swapTotalBytes = 0,
  });

  final int usedBytes;
  final int totalBytes;
  final int swapUsedBytes;
  final int swapTotalBytes;

  double get usagePercent =>
      totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0;

  double get swapUsagePercent =>
      swapTotalBytes > 0 ? (swapUsedBytes / swapTotalBytes) * 100 : 0;

  factory MemoryMetrics.fromJson(Map<String, dynamic> json) => MemoryMetrics(
        usedBytes: json[Protocol.usedBytes] as int,
        totalBytes: json[Protocol.totalBytes] as int,
        swapUsedBytes: (json[Protocol.swapUsedBytes] as int?) ?? 0,
        swapTotalBytes: (json[Protocol.swapTotalBytes] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        Protocol.usedBytes: usedBytes,
        Protocol.totalBytes: totalBytes,
        Protocol.swapUsedBytes: swapUsedBytes,
        Protocol.swapTotalBytes: swapTotalBytes,
      };

  @override
  List<Object?> get props => [usedBytes, totalBytes, swapUsedBytes, swapTotalBytes];
}
