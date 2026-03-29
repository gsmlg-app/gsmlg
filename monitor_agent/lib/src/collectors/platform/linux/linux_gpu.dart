import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class LinuxGpuCollector extends MetricsCollector<List<GpuMetrics>> {
  @override
  bool get isSupported => Platform.isLinux;

  @override
  Future<List<GpuMetrics>?> collect() async {
    try {
      final result = await runProcess('nvidia-smi', [
        '--query-gpu=index,name,utilization.gpu,memory.used,memory.total,temperature.gpu',
        '--format=csv,noheader,nounits',
      ]);

      if (result.exitCode != 0) return null;

      final stdout = result.stdout as String;
      final gpus = <GpuMetrics>[];

      for (final line in stdout.trim().split('\n')) {
        if (line.trim().isEmpty) continue;
        final parts = line.split(',').map((s) => s.trim()).toList();
        if (parts.length < 6) continue;

        gpus.add(GpuMetrics(
          index: int.parse(parts[0]),
          name: parts[1],
          usagePercent: double.parse(parts[2]),
          memoryUsedBytes: int.parse(parts[3]) * 1024 * 1024, // MiB to bytes
          memoryTotalBytes: int.parse(parts[4]) * 1024 * 1024,
          temperatureCelsius: double.tryParse(parts[5]),
        ));
      }

      return gpus.isEmpty ? null : gpus;
    } catch (_) {
      return null;
    }
  }
}
