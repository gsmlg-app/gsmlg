import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class LinuxMemoryCollector extends MetricsCollector<MemoryMetrics> {
  @override
  bool get isSupported => Platform.isLinux;

  @override
  Future<MemoryMetrics?> collect() async {
    try {
      final content = await readFileAsync('/proc/meminfo');
      final lines = content.split('\n');

      final values = <String, int>{};
      for (final line in lines) {
        final match = RegExp(r'^(\S+):\s+(\d+)\s+kB').firstMatch(line);
        if (match != null) {
          values[match.group(1)!] =
              int.parse(match.group(2)!) * 1024; // kB to bytes
        }
      }

      final total = values['MemTotal'] ?? 0;
      final free = values['MemFree'] ?? 0;
      final buffers = values['Buffers'] ?? 0;
      final cached = values['Cached'] ?? 0;
      final sReclaimable = values['SReclaimable'] ?? 0;
      final used = total - free - buffers - cached - sReclaimable;

      return MemoryMetrics(
        usedBytes: used.clamp(0, total),
        totalBytes: total,
        swapUsedBytes: (values['SwapTotal'] ?? 0) - (values['SwapFree'] ?? 0),
        swapTotalBytes: values['SwapTotal'] ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}
