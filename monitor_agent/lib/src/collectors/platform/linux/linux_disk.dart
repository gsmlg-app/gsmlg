import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/delta_tracker.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class LinuxDiskCollector extends MetricsCollector<List<DiskMetrics>> {
  final _readTracker = DeltaTracker<String>();
  final _writeTracker = DeltaTracker<String>();

  @override
  bool get isSupported => Platform.isLinux;

  @override
  Future<List<DiskMetrics>?> collect() async {
    try {
      // Parse /proc/diskstats for IO counters
      final diskstats = await readFileAsync('/proc/diskstats');
      final readCurrent = <String, int>{};
      final writeCurrent = <String, int>{};
      final deviceNames = <String>{};

      for (final line in diskstats.split('\n')) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 14) continue;

        final device = parts[2];
        // Only track real block devices (sd*, nvme*, vd*), skip partitions with digits at end
        // unless they are nvme partitions (nvme0n1p1)
        if (!device.startsWith('sd') &&
            !device.startsWith('nvme') &&
            !device.startsWith('vd')) {
          continue;
        }
        // Skip partitions: sda1, vdb2, etc. Keep sda, nvme0n1
        if (RegExp(r'^(sd|vd)[a-z]\d').hasMatch(device)) continue;
        if (RegExp(r'p\d+$').hasMatch(device) && device.startsWith('nvme')) continue;

        deviceNames.add(device);
        // Fields: sectors read (index 5), sectors written (index 9)
        // Each sector = 512 bytes
        readCurrent[device] = int.parse(parts[5]) * 512;
        writeCurrent[device] = int.parse(parts[9]) * 512;
      }

      final readRates = _readTracker.computeRates(readCurrent);
      final writeRates = _writeTracker.computeRates(writeCurrent);

      // Parse df for capacity
      final dfResult = await runProcess('df', ['-B1', '--output=source,used,size']);
      final dfLines = (dfResult.stdout as String).split('\n').skip(1);

      final capacityMap = <String, ({int used, int total})>{};
      for (final line in dfLines) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 3) continue;
        final source = parts[0];
        // Match /dev/sda, /dev/nvme0n1, etc.
        for (final dev in deviceNames) {
          if (source.contains(dev)) {
            final used = int.tryParse(parts[1]) ?? 0;
            final total = int.tryParse(parts[2]) ?? 0;
            capacityMap[dev] = (used: used, total: total);
            break;
          }
        }
      }

      final metrics = <DiskMetrics>[];
      for (final device in deviceNames) {
        final cap = capacityMap[device];
        metrics.add(DiskMetrics(
          device: device,
          readBytesPerSec: readRates?[device] ?? 0,
          writeBytesPerSec: writeRates?[device] ?? 0,
          usedBytes: cap?.used ?? 0,
          totalBytes: cap?.total ?? 0,
        ));
      }

      return metrics.isEmpty ? null : metrics;
    } catch (_) {
      return null;
    }
  }
}
