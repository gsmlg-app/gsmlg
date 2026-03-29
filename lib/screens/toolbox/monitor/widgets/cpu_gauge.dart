import 'package:flutter/material.dart';
import 'package:monitor_models/monitor_models.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/gauge_painter.dart';

class CpuGauge extends StatelessWidget {
  const CpuGauge({super.key, required this.cpu});

  final CpuMetrics cpu;

  @override
  Widget build(BuildContext context) {
    return RadialGauge(
      percent: cpu.usagePercent,
      label: 'CPU',
      sublabel: cpu.loadAvg.isNotEmpty
          ? 'Load: ${cpu.loadAvg.map((l) => l.toStringAsFixed(2)).join(', ')}'
          : null,
    );
  }
}
