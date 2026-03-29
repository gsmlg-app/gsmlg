import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class WindowsGpuCollector extends MetricsCollector<List<GpuMetrics>> {
  @override
  bool get isSupported => Platform.isWindows;

  @override
  Future<List<GpuMetrics>?> collect() async {
    // Try nvidia-smi first
    return await _collectNvidiaSmi() ?? await _collectPowerShell();
  }

  Future<List<GpuMetrics>?> _collectNvidiaSmi() async {
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
          memoryUsedBytes: int.parse(parts[3]) * 1024 * 1024,
          memoryTotalBytes: int.parse(parts[4]) * 1024 * 1024,
          temperatureCelsius: double.tryParse(parts[5]),
        ));
      }

      return gpus.isEmpty ? null : gpus;
    } catch (_) {
      return null;
    }
  }

  Future<List<GpuMetrics>?> _collectPowerShell() async {
    try {
      final result = await runProcess('powershell', [
        '-NoProfile',
        '-Command',
        'Get-CimInstance Win32_VideoController | Select-Object Name,AdapterRAM | ConvertTo-Csv -NoTypeInformation',
      ]);
      if (result.exitCode != 0) return null;

      final stdout = result.stdout as String;
      final lines = stdout.trim().split('\n');
      if (lines.length < 2) return null;

      final gpus = <GpuMetrics>[];
      for (var i = 1; i < lines.length; i++) {
        final parts = lines[i].split(',').map((s) => s.replaceAll('"', '').trim()).toList();
        if (parts.isEmpty) continue;

        final name = parts[0];
        final vram = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

        gpus.add(GpuMetrics(
          index: i - 1,
          name: name,
          usagePercent: 0,
          memoryUsedBytes: 0,
          memoryTotalBytes: vram,
        ));
      }

      return gpus.isEmpty ? null : gpus;
    } catch (_) {
      return null;
    }
  }
}
