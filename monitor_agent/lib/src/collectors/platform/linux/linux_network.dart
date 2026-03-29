import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/delta_tracker.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class LinuxNetworkCollector extends MetricsCollector<List<NetworkMetrics>> {
  final _rxTracker = DeltaTracker<String>();
  final _txTracker = DeltaTracker<String>();

  @override
  bool get isSupported => Platform.isLinux;

  @override
  Future<List<NetworkMetrics>?> collect() async {
    try {
      final content = await readFileAsync('/proc/net/dev');
      final lines = content.split('\n');

      final rxCurrent = <String, int>{};
      final txCurrent = <String, int>{};

      for (final line in lines.skip(2)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        final colonIdx = trimmed.indexOf(':');
        if (colonIdx < 0) continue;

        final iface = trimmed.substring(0, colonIdx).trim();
        // Skip loopback
        if (iface == 'lo') continue;

        final parts = trimmed
            .substring(colonIdx + 1)
            .trim()
            .split(RegExp(r'\s+'));
        if (parts.length < 10) continue;

        rxCurrent[iface] = int.parse(parts[0]); // rx bytes
        txCurrent[iface] = int.parse(parts[8]); // tx bytes
      }

      final rxRates = _rxTracker.computeRates(rxCurrent);
      final txRates = _txTracker.computeRates(txCurrent);

      if (rxRates == null || txRates == null) return null;

      final metrics = <NetworkMetrics>[];
      for (final iface in rxRates.keys) {
        metrics.add(
          NetworkMetrics(
            interface_: iface,
            rxBytesPerSec: rxRates[iface] ?? 0,
            txBytesPerSec: txRates[iface] ?? 0,
          ),
        );
      }

      return metrics.isEmpty ? null : metrics;
    } catch (_) {
      return null;
    }
  }
}
