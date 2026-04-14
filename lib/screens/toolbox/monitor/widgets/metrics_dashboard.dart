import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:monitor_bloc/monitor_bloc.dart';
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
    required this.cpuHistory,
    required this.memoryHistory,
    required this.rxHistory,
    required this.txHistory,
    required this.readHistory,
    required this.writeHistory,
  });

  final MonitorHost host;
  final List<double> cpuHistory;
  final List<double> memoryHistory;
  final Map<String, List<double>> rxHistory;
  final Map<String, List<double>> txHistory;
  final Map<String, List<double>> readHistory;
  final Map<String, List<double>> writeHistory;

  @override
  Widget build(BuildContext context) {
    final metrics = host.metrics;
    final hostInfo = host.hostInfo;
    final dmColors = Theme.of(context).extension<DmColorExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Host info
        if (hostInfo != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.computer, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hostInfo.hostname,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${hostInfo.os} ${hostInfo.osVersion} • ${hostInfo.cpuCores} cores • v${hostInfo.agentVersion}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),

        // CPU + Memory gauges side by side
        if (metrics?.cpu != null || metrics?.memory != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (metrics?.cpu != null) CpuGauge(cpu: metrics!.cpu!),
              if (metrics?.memory != null)
                MemoryGauge(memory: metrics!.memory!),
            ],
          ),
        const SizedBox(height: 8),

        // CPU sparkline
        if (cpuHistory.isNotEmpty)
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
                    values: cpuHistory,
                    maxValue: 100,
                    color: dmColors.success,
                    height: 60,
                  ),
                ],
              ),
            ),
          ),

        // Per-core breakdown
        if (metrics?.cpu != null && metrics!.cpu!.perCore.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Per Core',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  CpuPerCoreChart(perCore: metrics.cpu!.perCore),
                ],
              ),
            ),
          ),

        // Memory sparkline
        if (memoryHistory.isNotEmpty)
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
                    values: memoryHistory,
                    maxValue: 100,
                    color: colorScheme.secondary,
                    height: 60,
                  ),
                  if (metrics?.memory != null &&
                      metrics!.memory!.swapTotalBytes > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Swap: ${formatBytes(metrics.memory!.swapUsedBytes)} / ${formatBytes(metrics.memory!.swapTotalBytes)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                ],
              ),
            ),
          ),

        // GPU cards
        if (metrics != null)
          for (final gpu in metrics.gpus) GpuCard(gpu: gpu),

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

        // Waiting state
        if (metrics == null)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Waiting for metrics...')),
            ),
          ),
      ],
    );
  }
}
