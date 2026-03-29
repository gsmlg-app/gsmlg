import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class LinuxCpuCollector extends MetricsCollector<CpuMetrics> {
  List<int>? _prevTotal;
  List<int>? _prevIdle;

  @override
  bool get isSupported => Platform.isLinux;

  @override
  Future<CpuMetrics?> collect() async {
    try {
      final content = await readFileAsync('/proc/stat');
      final lines = content.split('\n');

      final cpuLines = lines.where((l) => l.startsWith('cpu')).toList();
      if (cpuLines.isEmpty) return null;

      final totals = <int>[];
      final idles = <int>[];

      for (final line in cpuLines) {
        final parts = line.split(RegExp(r'\s+')).skip(1).toList();
        if (parts.length < 4) continue;
        final values = parts.map(int.parse).toList();
        final total = values.fold(0, (a, b) => a + b);
        final idle = values[3]; // idle is 4th field
        totals.add(total);
        idles.add(idle);
      }

      if (_prevTotal == null || _prevTotal!.length != totals.length) {
        _prevTotal = totals;
        _prevIdle = idles;
        return const CpuMetrics(usagePercent: 0);
      }

      final perCore = <double>[];
      for (var i = 1; i < totals.length; i++) {
        final dTotal = totals[i] - _prevTotal![i];
        final dIdle = idles[i] - _prevIdle![i];
        final usage = dTotal > 0 ? ((dTotal - dIdle) / dTotal) * 100 : 0.0;
        perCore.add(double.parse(usage.toStringAsFixed(1)));
      }

      // Aggregate from first line (cpu)
      final dTotal = totals[0] - _prevTotal![0];
      final dIdle = idles[0] - _prevIdle![0];
      final aggregate = dTotal > 0 ? ((dTotal - dIdle) / dTotal) * 100 : 0.0;

      _prevTotal = totals;
      _prevIdle = idles;

      // Load average
      final loadAvgContent = await readFileAsync('/proc/loadavg');
      final loadParts = loadAvgContent.trim().split(' ');
      final loadAvg = loadParts.take(3).map(double.parse).toList();

      return CpuMetrics(
        usagePercent: double.parse(aggregate.toStringAsFixed(1)),
        perCore: perCore,
        loadAvg: loadAvg,
      );
    } catch (_) {
      return null;
    }
  }
}
