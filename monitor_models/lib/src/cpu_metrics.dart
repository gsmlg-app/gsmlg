import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:monitor_models/src/protocol.dart';

@immutable
final class CpuMetrics extends Equatable {
  const CpuMetrics({
    required this.usagePercent,
    this.perCore = const [],
    this.loadAvg = const [],
  });

  final double usagePercent;
  final List<double> perCore;
  final List<double> loadAvg;

  factory CpuMetrics.fromJson(Map<String, dynamic> json) => CpuMetrics(
    usagePercent: (json[Protocol.usagePercent] as num).toDouble(),
    perCore:
        (json[Protocol.perCore] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    loadAvg:
        (json[Protocol.loadAvg] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    Protocol.usagePercent: usagePercent,
    Protocol.perCore: perCore,
    Protocol.loadAvg: loadAvg,
  };

  @override
  List<Object?> get props => [usagePercent, perCore, loadAvg];
}
