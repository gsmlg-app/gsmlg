import 'package:flutter/material.dart';
import 'package:monitor_models/monitor_models.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/gauge_painter.dart';

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
}

class MemoryGauge extends StatelessWidget {
  const MemoryGauge({super.key, required this.memory});

  final MemoryMetrics memory;

  @override
  Widget build(BuildContext context) {
    return RadialGauge(
      percent: memory.usagePercent,
      label: 'Memory',
      sublabel:
          '${formatBytes(memory.usedBytes)} / ${formatBytes(memory.totalBytes)}',
    );
  }
}
