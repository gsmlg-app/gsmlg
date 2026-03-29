import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monitor_models/src/protocol.dart';

@immutable
final class DiskMetrics extends Equatable {
  const DiskMetrics({
    required this.device,
    required this.readBytesPerSec,
    required this.writeBytesPerSec,
    required this.usedBytes,
    required this.totalBytes,
  });

  final String device;
  final int readBytesPerSec;
  final int writeBytesPerSec;
  final int usedBytes;
  final int totalBytes;

  double get usagePercent =>
      totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0;

  factory DiskMetrics.fromJson(Map<String, dynamic> json) => DiskMetrics(
    device: json[Protocol.device] as String,
    readBytesPerSec: json[Protocol.readBytesPerSec] as int,
    writeBytesPerSec: json[Protocol.writeBytesPerSec] as int,
    usedBytes: json[Protocol.usedBytes] as int,
    totalBytes: json[Protocol.totalBytes] as int,
  );

  Map<String, dynamic> toJson() => {
    Protocol.device: device,
    Protocol.readBytesPerSec: readBytesPerSec,
    Protocol.writeBytesPerSec: writeBytesPerSec,
    Protocol.usedBytes: usedBytes,
    Protocol.totalBytes: totalBytes,
  };

  @override
  List<Object?> get props => [
    device,
    readBytesPerSec,
    writeBytesPerSec,
    usedBytes,
    totalBytes,
  ];
}
