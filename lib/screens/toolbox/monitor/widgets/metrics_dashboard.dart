import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:monitor_bloc/monitor_bloc.dart';
import 'package:monitor_models/monitor_models.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/cpu_gauge.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/cpu_per_core_chart.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/disk_chart.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/gpu_card.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/memory_gauge.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/network_chart.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/sparkline_chart.dart';

class MetricsDashboard extends StatelessWidget {
  const MetricsDashboard({
    super.key,
    required this.host,
    this.cpuHistory,
    this.memoryHistory,
    this.rxHistory = const <String, RingBuffer<double>>{},
    this.txHistory = const <String, RingBuffer<double>>{},
    this.readHistory = const <String, RingBuffer<double>>{},
    this.writeHistory = const <String, RingBuffer<double>>{},
  });

  final MonitorHost host;
  final RingBuffer<double>? cpuHistory;
  final RingBuffer<double>? memoryHistory;
  final Map<String, RingBuffer<double>> rxHistory;
  final Map<String, RingBuffer<double>> txHistory;
  final Map<String, RingBuffer<double>> readHistory;
  final Map<String, RingBuffer<double>> writeHistory;

  @override
  Widget build(BuildContext context) {
    final metrics = host.metrics;
    final hostInfo = host.hostInfo;
    final dmColors = Theme.of(context).extension<DmColorExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final cpuItems = cpuHistory?.items ?? const [];
    final memoryItems = memoryHistory?.items ?? const [];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // ... (rest of the widget remains largely the same, but using cpuItems and memoryItems)
        // CPU sparkline
        if (cpuItems.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CPU History',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  SparklineChart(
                    values: cpuItems,
                    maxValue: 100,
                    color: dmColors.success,
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
        // ...
        // Memory sparkline
        if (memoryItems.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Memory History',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  SparklineChart(
                    values: memoryItems,
                    maxValue: 100,
                    color: colorScheme.secondary,
                    height: 60,
                  ),
                  // ...
                ],
              ),
            ),
          ),
        // ...
        // Network
        if (metrics != null && metrics.networks.isNotEmpty)
          NetworkChart(
            networks: metrics.networks,
            rxHistory: rxHistory,
            txHistory: txHistory,
          ),

        // Disk
        if (metrics != null && metrics.disks.isNotEmpty)
          DiskChart(
            disks: metrics.disks,
            readHistory: readHistory,
            writeHistory: writeHistory,
          ),
        // ...
      ],
    );
  }
}
