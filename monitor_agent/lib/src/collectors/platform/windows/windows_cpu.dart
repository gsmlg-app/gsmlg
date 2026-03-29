import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class WindowsCpuCollector extends MetricsCollector<CpuMetrics> {
  @override
  bool get isSupported => Platform.isWindows;

  @override
  Future<CpuMetrics?> collect() async {
    try {
      final result = await runProcess('wmic', [
        'cpu',
        'get',
        'LoadPercentage',
        '/format:csv',
      ]);
      if (result.exitCode != 0) return null;

      final stdout = result.stdout as String;
      final lines = stdout
          .trim()
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (lines.length < 2) return null;

      // CSV format: Node,LoadPercentage
      final dataLine = lines.last.trim();
      final parts = dataLine.split(',');
      if (parts.length < 2) return null;

      final load = double.tryParse(parts.last.trim()) ?? 0;

      return CpuMetrics(usagePercent: load);
    } catch (_) {
      return null;
    }
  }
}
