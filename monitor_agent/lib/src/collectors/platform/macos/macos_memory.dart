import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class MacosMemoryCollector extends MetricsCollector<MemoryMetrics> {
  @override
  bool get isSupported => Platform.isMacOS;

  @override
  Future<MemoryMetrics?> collect() async {
    try {
      // Total physical memory
      final memResult = await runProcess('sysctl', ['-n', 'hw.memsize']);
      if (memResult.exitCode != 0) return null;
      final totalBytes = int.parse((memResult.stdout as String).trim());

      // vm_stat for page statistics
      final vmResult = await runProcess('vm_stat', []);
      if (vmResult.exitCode != 0) return null;

      final vmOutput = vmResult.stdout as String;
      final lines = vmOutput.split('\n');

      // First line has page size: "Mach Virtual Memory Statistics: (page size of 16384 bytes)"
      final pageSizeMatch = RegExp(
        r'page size of (\d+)',
      ).firstMatch(lines.first);
      final pageSize = int.parse(pageSizeMatch?.group(1) ?? '16384');

      int getPages(String key) {
        for (final line in lines) {
          if (line.startsWith(key)) {
            final match = RegExp(r'(\d+)').firstMatch(line.split(':').last);
            return int.parse(match?.group(1) ?? '0');
          }
        }
        return 0;
      }

      final free = getPages('Pages free');
      final speculative = getPages('Pages speculative');
      final purgeable = getPages('Pages purgeable');

      // Used = total - (free + speculative + purgeable) * pageSize
      // This is an approximation; macOS memory accounting is complex
      final freeBytes = (free + speculative + purgeable) * pageSize;
      final usedBytes = (totalBytes - freeBytes).clamp(0, totalBytes);

      // Swap from sysctl
      final swapResult = await runProcess('sysctl', ['-n', 'vm.swapusage']);
      int swapUsed = 0;
      int swapTotal = 0;
      if (swapResult.exitCode == 0) {
        final swapStr = swapResult.stdout as String;
        // "total = 2048.00M  used = 512.00M  free = 1536.00M ..."
        final totalMatch = RegExp(r'total\s*=\s*([\d.]+)M').firstMatch(swapStr);
        final usedMatch = RegExp(r'used\s*=\s*([\d.]+)M').firstMatch(swapStr);
        if (totalMatch != null) {
          swapTotal = (double.parse(totalMatch.group(1)!) * 1024 * 1024)
              .round();
        }
        if (usedMatch != null) {
          swapUsed = (double.parse(usedMatch.group(1)!) * 1024 * 1024).round();
        }
      }

      return MemoryMetrics(
        usedBytes: usedBytes,
        totalBytes: totalBytes,
        swapUsedBytes: swapUsed,
        swapTotalBytes: swapTotal,
      );
    } catch (_) {
      return null;
    }
  }
}
