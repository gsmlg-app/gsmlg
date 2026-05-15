import 'package:flutter/material.dart';
import 'package:monitor_models/monitor_models.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/gauge_painter.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/memory_gauge.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/sparkline_chart.dart';

class DiskChart extends StatelessWidget {
  const DiskChart({
    super.key,
    required this.disks,
    required this.readHistory,
    required this.writeHistory,
  });

  final List<DiskMetrics> disks;
  final Map<String, RingBuffer<double>> readHistory;
  final Map<String, RingBuffer<double>> writeHistory;

  @override
  Widget build(BuildContext context) {
    if (disks.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disk', style: Theme.of(context).textTheme.titleSmall),
            const Divider(),
            for (final disk in disks) ...[
              Text(disk.device, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              if (disk.totalBytes > 0) ...[
                Row(
                  children: [
                    Text(
                      '${formatBytes(disk.usedBytes)} / ${formatBytes(disk.totalBytes)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    Text(
                      '${disk.usagePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: gaugeColor(
                          disk.usagePercent,
                          context: context,
                        ),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: disk.usagePercent / 100,
                  color: gaugeColor(disk.usagePercent, context: context),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  Text(
                    'R: ${formatBytes(disk.readBytesPerSec)}/s',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  Text(
                    'W: ${formatBytes(disk.writeBytesPerSec)}/s',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              if (readHistory[disk.device] != null)
                SparklineChart(
                  values: readHistory[disk.device]!.items,
                  maxValue: _maxRate(readHistory[disk.device]!.items),
                  color: colorScheme.tertiary,
                  label: 'Read',
                  height: 40,
                ),
              if (writeHistory[disk.device] != null)
                SparklineChart(
                  values: writeHistory[disk.device]!.items,
                  maxValue: _maxRate(writeHistory[disk.device]!.items),
                  color: colorScheme.secondary,
                  label: 'Write',
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
    return max > 0 ? max * 1.2 : 1024;
  }
}
