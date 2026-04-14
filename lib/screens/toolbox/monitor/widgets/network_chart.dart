import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:monitor_models/monitor_models.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/memory_gauge.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/sparkline_chart.dart';

class NetworkChart extends StatelessWidget {
  const NetworkChart({
    super.key,
    required this.networks,
    required this.rxHistory,
    required this.txHistory,
  });

  final List<NetworkMetrics> networks;
  final Map<String, List<double>> rxHistory;
  final Map<String, List<double>> txHistory;

  @override
  Widget build(BuildContext context) {
    if (networks.isEmpty) return const SizedBox.shrink();

    final dmColors = Theme.of(context).extension<DmColorExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network', style: Theme.of(context).textTheme.titleSmall),
            const Divider(),
            for (final net in networks) ...[
              Text(
                net.interface_,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'RX: ${formatBytes(net.rxBytesPerSec)}/s',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  Text(
                    'TX: ${formatBytes(net.txBytesPerSec)}/s',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              if (rxHistory[net.interface_] != null)
                SparklineChart(
                  values: rxHistory[net.interface_]!,
                  maxValue: _maxRate(rxHistory[net.interface_]!),
                  color: dmColors.info,
                  label: 'RX',
                  height: 40,
                ),
              if (txHistory[net.interface_] != null)
                SparklineChart(
                  values: txHistory[net.interface_]!,
                  maxValue: _maxRate(txHistory[net.interface_]!),
                  color: colorScheme.tertiary,
                  label: 'TX',
                  height: 40,
                ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  double _maxRate(List<double> values) {
    if (values.isEmpty) return 1;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max > 0 ? max * 1.2 : 1024; // 20% headroom
  }
}
