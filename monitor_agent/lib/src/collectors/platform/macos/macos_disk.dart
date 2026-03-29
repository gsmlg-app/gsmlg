import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class MacosDiskCollector extends MetricsCollector<List<DiskMetrics>> {

  @override
  bool get isSupported => Platform.isMacOS;

  @override
  Future<List<DiskMetrics>?> collect() async {
    try {
      // Use iostat for IO stats
      final ioResult =
          await runProcess('iostat', ['-d', '-c', '2', '-w', '1']);
      final ioOutput = ioResult.stdout as String;

      // iostat -d -c 2 outputs two samples. We want the second set.
      // Format: device KB/t tps MB/s
      // Parse the last set of device lines
      final ioLines = ioOutput.split('\n');
      final deviceIo = <String, ({double mbsRead, double mbsWrite})>{};

      // Find the last header line "KB/t" and take lines after it
      var lastHeaderIdx = -1;
      for (var i = ioLines.length - 1; i >= 0; i--) {
        if (ioLines[i].contains('KB/t')) {
          lastHeaderIdx = i;
          break;
        }
      }

      if (lastHeaderIdx >= 0) {
        for (var i = lastHeaderIdx + 1; i < ioLines.length; i++) {
          final parts = ioLines[i].trim().split(RegExp(r'\s+'));
          if (parts.length < 3) continue;
          // Simple approach: column 2 is MB/s (combined read+write from iostat)
          // iostat on macOS doesn't separate read/write in default mode
          // Use -I flag alternative or just report combined
          final mbps = double.tryParse(parts[2]) ?? 0;
          deviceIo['disk$i'] = (mbsRead: mbps / 2, mbsWrite: mbps / 2);
        }
      }

      // Use df for capacity
      final dfResult = await runProcess('df', ['-k']);
      if (dfResult.exitCode != 0) return null;

      final dfLines = (dfResult.stdout as String).split('\n').skip(1);
      final metrics = <DiskMetrics>[];

      for (final line in dfLines) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 6) continue;

        final source = parts[0];
        // Only track real devices
        if (!source.startsWith('/dev/')) continue;
        // Skip devfs, etc.
        if (source == '/dev') continue;

        final device = source.replaceFirst('/dev/', '');
        final totalKb = int.tryParse(parts[1]) ?? 0;
        final usedKb = int.tryParse(parts[2]) ?? 0;

        metrics.add(DiskMetrics(
          device: device,
          readBytesPerSec: 0, // Updated via delta tracking if we add diskutil
          writeBytesPerSec: 0,
          usedBytes: usedKb * 1024,
          totalBytes: totalKb * 1024,
        ));
      }

      return metrics.isEmpty ? null : metrics;
    } catch (_) {
      return null;
    }
  }
}
