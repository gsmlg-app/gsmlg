import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/delta_tracker.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class MacosNetworkCollector extends MetricsCollector<List<NetworkMetrics>> {
  final _rxTracker = DeltaTracker<String>();
  final _txTracker = DeltaTracker<String>();

  @override
  bool get isSupported => Platform.isMacOS;

  @override
  Future<List<NetworkMetrics>?> collect() async {
    try {
      final result = await runProcess('netstat', ['-ibnd']);
      if (result.exitCode != 0) return null;

      final stdout = result.stdout as String;
      final lines = stdout.split('\n');

      final rxCurrent = <String, int>{};
      final txCurrent = <String, int>{};

      for (final line in lines.skip(1)) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 10) continue;

        final iface = parts[0];
        // Skip loopback and link-level duplicates
        if (iface.startsWith('lo')) continue;

        // netstat -ibnd columns: Name Mtu Network Address Ipkts Ierrs Ibytes Opkts Oerrs Obytes
        // Only take the first occurrence of each interface (link-level line has '<Link>')
        if (!parts[2].contains('Link')) continue;

        final ibytes = int.tryParse(parts[6]);
        final obytes = int.tryParse(parts[9]);
        if (ibytes == null || obytes == null) continue;

        // Aggregate if interface already seen (shouldn't happen with Link filter)
        rxCurrent[iface] = (rxCurrent[iface] ?? 0) + ibytes;
        txCurrent[iface] = (txCurrent[iface] ?? 0) + obytes;
      }

      final rxRates = _rxTracker.computeRates(rxCurrent);
      final txRates = _txTracker.computeRates(txCurrent);

      if (rxRates == null || txRates == null) return null;

      final metrics = <NetworkMetrics>[];
      for (final iface in rxRates.keys) {
        metrics.add(NetworkMetrics(
          interface_: iface,
          rxBytesPerSec: rxRates[iface] ?? 0,
          txBytesPerSec: txRates[iface] ?? 0,
        ));
      }

      return metrics.isEmpty ? null : metrics;
    } catch (_) {
      return null;
    }
  }
}
