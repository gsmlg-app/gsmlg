import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class WindowsDiskCollector extends MetricsCollector<List<DiskMetrics>> {
  @override
  bool get isSupported => Platform.isWindows;

  @override
  Future<List<DiskMetrics>?> collect() async {
    try {
      final result = await runProcess('wmic', [
        'logicaldisk',
        'where',
        'DriveType=3',
        'get',
        'DeviceID,FreeSpace,Size',
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

      final metrics = <DiskMetrics>[];
      for (var i = 1; i < lines.length; i++) {
        final parts = lines[i].trim().split(',');
        if (parts.length < 4) continue;

        final device = parts[1].trim();
        final freeSpace = int.tryParse(parts[2].trim()) ?? 0;
        final totalSize = int.tryParse(parts[3].trim()) ?? 0;

        if (totalSize == 0) continue;

        metrics.add(
          DiskMetrics(
            device: device,
            readBytesPerSec: 0, // wmic doesn't provide IO rates
            writeBytesPerSec: 0,
            usedBytes: totalSize - freeSpace,
            totalBytes: totalSize,
          ),
        );
      }

      return metrics.isEmpty ? null : metrics;
    } catch (_) {
      return null;
    }
  }
}
