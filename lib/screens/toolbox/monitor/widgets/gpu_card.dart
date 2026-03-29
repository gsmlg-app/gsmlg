import 'package:flutter/material.dart';
import 'package:monitor_models/monitor_models.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/gauge_painter.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/memory_gauge.dart';

class GpuCard extends StatelessWidget {
  const GpuCard({super.key, required this.gpu});

  final GpuMetrics gpu;

  @override
  Widget build(BuildContext context) {
    final tempColor = switch (gpu.temperatureCelsius) {
      null => null,
      < 60 => Colors.green,
      < 80 => Colors.orange,
      _ => Colors.red,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gpu.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (gpu.temperatureCelsius != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tempColor?.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${gpu.temperatureCelsius!.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        color: tempColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RadialGauge(percent: gpu.usagePercent, label: 'GPU', size: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VRAM',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: gpu.memoryUsagePercent / 100,
                        color: gaugeColor(gpu.memoryUsagePercent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatBytes(gpu.memoryUsedBytes)} / ${formatBytes(gpu.memoryTotalBytes)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
