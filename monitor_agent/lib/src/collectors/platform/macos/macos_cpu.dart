import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class MacosCpuCollector extends MetricsCollector<CpuMetrics> {
  @override
  bool get isSupported => Platform.isMacOS;

  @override
  Future<CpuMetrics?> collect() async {
    try {
      // top -l 2: first sample is since boot, second is current interval
      final result = await runProcess('top', ['-l', '2', '-n', '0', '-s', '0']);
      if (result.exitCode != 0) return null;

      final stdout = result.stdout as String;
      final lines = stdout.split('\n');

      // Find the LAST "CPU usage:" line (the current interval sample)
      String? cpuLine;
      for (final line in lines.reversed) {
        if (line.startsWith('CPU usage:')) {
          cpuLine = line;
          break;
        }
      }

      if (cpuLine == null) return null;

      // "CPU usage: 5.55% user, 11.11% sys, 83.33% idle"
      final userMatch = RegExp(r'([\d.]+)%\s+user').firstMatch(cpuLine);
      final sysMatch = RegExp(r'([\d.]+)%\s+sys').firstMatch(cpuLine);

      final user = double.tryParse(userMatch?.group(1) ?? '') ?? 0;
      final sys = double.tryParse(sysMatch?.group(1) ?? '') ?? 0;
      final usage = user + sys;

      // Load average from sysctl
      final loadResult = await runProcess('sysctl', ['-n', 'vm.loadavg']);
      final loadAvg = <double>[];
      if (loadResult.exitCode == 0) {
        // Output: "{ 1.23 2.34 3.45 }"
        final loadStr = (loadResult.stdout as String).trim();
        final nums = RegExp(r'[\d.]+').allMatches(loadStr);
        for (final m in nums.take(3)) {
          loadAvg.add(double.parse(m.group(0)!));
        }
      }

      // Per-core not available from top; return empty
      return CpuMetrics(
        usagePercent: double.parse(usage.toStringAsFixed(1)),
        loadAvg: loadAvg,
      );
    } catch (_) {
      return null;
    }
  }
}
