import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class MacosGpuCollector extends MetricsCollector<List<GpuMetrics>> {
  @override
  bool get isSupported => Platform.isMacOS;

  @override
  Future<List<GpuMetrics>?> collect() async {
    try {
      return await _collectFromIoreg() ?? await _collectFromSystemProfiler();
    } catch (_) {
      return null;
    }
  }

  Future<List<GpuMetrics>?> _collectFromIoreg() async {
    final result = await runProcess('ioreg', ['-rc', 'IOAccelerator']);
    if (result.exitCode != 0) return null;

    final stdout = result.stdout as String;
    if (stdout.trim().isEmpty) return null;

    final gpus = <GpuMetrics>[];
    var index = 0;

    // Parse ioreg output for GPU utilization and memory
    // Look for "Device Utilization %" and "VRAM,totalMB" properties
    final blocks = stdout.split('+-o ');
    for (final block in blocks) {
      if (block.trim().isEmpty) continue;

      String? name;
      double usage = 0;
      int vramTotal = 0;
      int vramUsed = 0;

      // Extract GPU name from the first line
      final nameMatch = RegExp(r'^(\S+)').firstMatch(block.trim());
      if (nameMatch != null) {
        name = nameMatch.group(1)!.replaceAll('<', '').replaceAll('>', '');
      }

      // "Device Utilization %" = <number>
      final utilMatch = RegExp(
        r'"Device Utilization %"\s*=\s*(\d+)',
      ).firstMatch(block);
      if (utilMatch != null) {
        usage = double.parse(utilMatch.group(1)!);
      }

      // "VRAM,totalMB" = <number>
      final vramTotalMatch = RegExp(
        r'"VRAM,totalMB"\s*=\s*(\d+)',
      ).firstMatch(block);
      if (vramTotalMatch != null) {
        vramTotal = int.parse(vramTotalMatch.group(1)!) * 1024 * 1024;
      }

      // "VRAM,freeBytes" or similar
      final vramFreeMatch = RegExp(
        r'"vramFreeBytes"\s*=\s*(\d+)',
      ).firstMatch(block);
      if (vramFreeMatch != null && vramTotal > 0) {
        vramUsed = vramTotal - int.parse(vramFreeMatch.group(1)!);
      }

      if (name != null && name != 'IOAccelerator') {
        gpus.add(
          GpuMetrics(
            index: index++,
            name: name,
            usagePercent: usage,
            memoryUsedBytes: vramUsed.clamp(0, vramTotal),
            memoryTotalBytes: vramTotal,
          ),
        );
      }
    }

    return gpus.isEmpty ? null : gpus;
  }

  Future<List<GpuMetrics>?> _collectFromSystemProfiler() async {
    final result = await runProcess('system_profiler', [
      'SPDisplaysDataType',
      '-detailLevel',
      'mini',
    ]);
    if (result.exitCode != 0) return null;

    final stdout = result.stdout as String;
    final gpus = <GpuMetrics>[];
    var index = 0;

    // Simple parse: look for "Chipset Model:" lines
    for (final line in stdout.split('\n')) {
      final match = RegExp(r'Chipset Model:\s*(.+)').firstMatch(line);
      if (match != null) {
        final name = match.group(1)!.trim();
        // VRAM line may follow
        gpus.add(
          GpuMetrics(
            index: index++,
            name: name,
            usagePercent: 0, // Not available from system_profiler
            memoryUsedBytes: 0,
            memoryTotalBytes: 0,
          ),
        );
      }
    }

    return gpus.isEmpty ? null : gpus;
  }
}
