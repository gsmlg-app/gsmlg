import 'dart:io';

import 'package:monitor_models/monitor_models.dart';
import 'package:monitor_agent/src/collectors/collector.dart';
import 'package:monitor_agent/src/utils/delta_tracker.dart';
import 'package:monitor_agent/src/utils/process_runner.dart';

class WindowsNetworkCollector extends MetricsCollector<List<NetworkMetrics>> {
  final _rxTracker = DeltaTracker<String>();
  final _txTracker = DeltaTracker<String>();

  @override
  bool get isSupported => Platform.isWindows;

  @override
  Future<List<NetworkMetrics>?> collect() async {
    try {
      final result = await runProcess('powershell', [
        '-NoProfile',
        '-Command',
        'Get-NetAdapterStatistics | Select-Object Name,ReceivedBytes,SentBytes | ConvertTo-Csv -NoTypeInformation',
      ]);
      if (result.exitCode != 0) return null;

      final stdout = result.stdout as String;
      final lines = stdout.trim().split('\n');
      if (lines.length < 2) return null;

      final rxCurrent = <String, int>{};
      final txCurrent = <String, int>{};

      for (var i = 1; i < lines.length; i++) {
        final parts = lines[i]
            .split(',')
            .map((s) => s.replaceAll('"', '').trim())
            .toList();
        if (parts.length < 3) continue;

        final name = parts[0];
        final rx = int.tryParse(parts[1]) ?? 0;
        final tx = int.tryParse(parts[2]) ?? 0;

        rxCurrent[name] = rx;
        txCurrent[name] = tx;
      }

      final rxRates = _rxTracker.computeRates(rxCurrent);
      final txRates = _txTracker.computeRates(txCurrent);

      if (rxRates == null || txRates == null) return null;

      final metrics = <NetworkMetrics>[];
      for (final name in rxRates.keys) {
        metrics.add(
          NetworkMetrics(
            interface_: name,
            rxBytesPerSec: rxRates[name] ?? 0,
            txBytesPerSec: txRates[name] ?? 0,
          ),
        );
      }

      return metrics.isEmpty ? null : metrics;
    } catch (_) {
      return null;
    }
  }
}
