import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class WindowsMemoryCollector extends MetricsCollector<MemoryMetrics> {
  @override
  bool get isSupported => Platform.isWindows;

  @override
  Future<MemoryMetrics?> collect() async {
    try {
      final result = await runProcess('wmic', [
        'os',
        'get',
        'FreePhysicalMemory,TotalVisibleMemorySize',
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

      // CSV: Node,FreePhysicalMemory,TotalVisibleMemorySize
      final parts = lines.last.trim().split(',');
      if (parts.length < 3) return null;

      final freeKb = int.tryParse(parts[1].trim()) ?? 0;
      final totalKb = int.tryParse(parts[2].trim()) ?? 0;

      final totalBytes = totalKb * 1024;
      final usedBytes = (totalKb - freeKb) * 1024;

      return MemoryMetrics(
        usedBytes: usedBytes.clamp(0, totalBytes),
        totalBytes: totalBytes,
      );
    } catch (_) {
      return null;
    }
  }
}
