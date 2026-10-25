import 'dart:math' as math;

import 'package:app_locale/app_locale.dart';
import 'package:app_system_metrics/app_system_metrics.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/sparkline_chart.dart';

class ActivityMonitorDashboard extends StatelessWidget {
  const ActivityMonitorDashboard({
    super.key,
    required this.snapshot,
    required this.history,
    required this.running,
  });

  final ActivitySnapshot snapshot;
  final List<ActivitySnapshot> history;
  final bool running;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final memory = snapshot.memory;
    final disk = snapshot.disk;
    final network = snapshot.network;
    final unavailable = l10n.activityMonitorUnavailable;
    final waiting = l10n.activityMonitorWaiting;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(snapshot.timestamp.toLocal()),
      alwaysUse24HourFormat: true,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 800 ? 2 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${snapshot.model} · ${snapshot.architecture}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Text(
                        running
                            ? l10n.activityMonitorSampling
                            : l10n.activityMonitorPaused,
                      ),
                      Text(l10n.activityMonitorUpdated(time)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Panel(
                    title: l10n.activityMonitorCpu,
                    icon: Icons.memory,
                    children: [
                      Text(snapshot.cpuBrand),
                      _Reading(
                        label: l10n.activityMonitorCpu,
                        value: _percent(snapshot.cpuUsage, waiting),
                      ),
                      _chart(
                        context,
                        (s) => s.cpuUsage,
                        colors.primary,
                        maxValue: 100,
                      ),
                      _cores(context),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: width,
                        child: _Panel(
                          title: l10n.activityMonitorMemory,
                          icon: Icons.storage,
                          children: [
                            _Reading(
                              label: l10n.activityMonitorUsed,
                              value:
                                  '${_bytes(memory.usedBytes, unavailable)} · ${_percent(memory.usage, unavailable)}',
                            ),
                            _chart(
                              context,
                              (s) => s.memory.usage,
                              colors.secondary,
                              maxValue: 100,
                            ),
                            _Reading(
                              label: l10n.activityMonitorTotal,
                              value: _bytes(memory.totalBytes, unavailable),
                            ),
                            _Reading(
                              label: l10n.activityMonitorWired,
                              value: _bytes(memory.wiredBytes, unavailable),
                            ),
                            _Reading(
                              label: l10n.activityMonitorCompressed,
                              value: _bytes(
                                memory.compressedBytes,
                                unavailable,
                              ),
                            ),
                            _Reading(
                              label: l10n.activityMonitorSwap,
                              value:
                                  '${_bytes(memory.swapUsedBytes, unavailable)} / ${_bytes(memory.swapTotalBytes, unavailable)}',
                            ),
                            _Reading(
                              label: l10n.activityMonitorPressure,
                              value: switch (memory.pressure) {
                                1 => l10n.activityMonitorPressureNormal,
                                2 => l10n.activityMonitorPressureWarning,
                                4 => l10n.activityMonitorPressureCritical,
                                _ => unavailable,
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _Panel(
                          title: l10n.activityMonitorDisk,
                          icon: Icons.save_outlined,
                          children: [
                            Text(
                              disk.available
                                  ? disk.devices.join(', ')
                                  : unavailable,
                            ),
                            _Reading(
                              label: l10n.activityMonitorRead,
                              value: _rate(
                                disk.readBytesPerSecond,
                                disk.available ? waiting : unavailable,
                              ),
                            ),
                            _chart(
                              context,
                              (s) => s.disk.readBytesPerSecond,
                              colors.primary,
                            ),
                            _Reading(
                              label: l10n.activityMonitorWrite,
                              value: _rate(
                                disk.writeBytesPerSecond,
                                disk.available ? waiting : unavailable,
                              ),
                            ),
                            _chart(
                              context,
                              (s) => s.disk.writeBytesPerSecond,
                              colors.tertiary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _Panel(
                          title: l10n.activityMonitorNetwork,
                          icon: Icons.network_check,
                          children: [
                            _Reading(
                              label: l10n.activityMonitorReceived,
                              value: _rate(
                                network.receivedBytesPerSecond,
                                network.available ? waiting : unavailable,
                              ),
                            ),
                            _chart(
                              context,
                              (s) => s.network.receivedBytesPerSecond,
                              colors.primary,
                            ),
                            _Reading(
                              label: l10n.activityMonitorSent,
                              value: _rate(
                                network.sentBytesPerSecond,
                                network.available ? waiting : unavailable,
                              ),
                            ),
                            _chart(
                              context,
                              (s) => s.network.sentBytesPerSecond,
                              colors.tertiary,
                            ),
                            for (final interface in network.interfaces)
                              _Reading(
                                label: interface.name,
                                value:
                                    '↓ ${_rate(interface.receivedBytesPerSecond, waiting)}\n↑ ${_rate(interface.sentBytesPerSecond, waiting)}',
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _Panel(
                          title: l10n.activityMonitorGpu,
                          icon: Icons.graphic_eq,
                          children: [
                            if (snapshot.gpus.isEmpty)
                              Text(l10n.activityMonitorGpuUnavailable),
                            for (final gpu in snapshot.gpus)
                              _Reading(
                                label: gpu.name,
                                value: _percent(gpu.usage, unavailable),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _Panel(
                          title: l10n.activityMonitorProcesses,
                          icon: Icons.account_tree_outlined,
                          children: [
                            _Reading(
                              label: l10n.activityMonitorProcessCount,
                              value:
                                  snapshot.processCount?.toString() ??
                                  unavailable,
                            ),
                            _Reading(
                              label: l10n.activityMonitorThreadCount,
                              value:
                                  snapshot.threadCount?.toString() ??
                                  unavailable,
                            ),
                            if (!snapshot.threadCountComplete &&
                                snapshot.threadCount != null)
                              Text(l10n.activityMonitorPartialThreads),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _cores(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final performance = snapshot.cores
        .where((c) => c.type == 'performance')
        .length;
    final efficiency = snapshot.cores
        .where((c) => c.type == 'efficiency')
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (performance + efficiency > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('${performance}P · ${efficiency}E'),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            var p = 0;
            var e = 0;
            final count = math.max(1, (constraints.maxWidth / 170).floor());
            final width = (constraints.maxWidth - (count - 1) * 12) / count;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final core in snapshot.cores)
                  SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(switch (core.type) {
                          'performance' => l10n.activityMonitorPerformanceCore(
                            ++p,
                          ),
                          'efficiency' => l10n.activityMonitorEfficiencyCore(
                            ++e,
                          ),
                          _ => l10n.activityMonitorCore(core.id),
                        }),
                        Text(_percent(core.usage, '—')),
                        const SizedBox(height: 4),
                        if (core.usage != null)
                          LinearProgressIndicator(
                            value: core.usage! / 100,
                            color: core.type == 'efficiency'
                                ? colors.tertiary
                                : colors.primary,
                            backgroundColor: colors.surfaceContainerHighest,
                          )
                        else
                          const SizedBox(height: 4),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _chart(
    BuildContext context,
    double? Function(ActivitySnapshot) select,
    Color color, {
    double? maxValue,
  }) {
    // Keep gaps honest: the chart ends at the current sample and never joins
    // readings across unavailable intervals or counter resets.
    final suffix = <double>[];
    for (final sample in history.reversed) {
      final value = select(sample);
      if (value == null) break;
      suffix.add(value);
    }
    final values = suffix.reversed.toList();
    if (values.length < 2) return const SizedBox(height: 12);
    return Semantics(
      label: context.l10n.activityMonitorHistory,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SparklineChart(
          values: values,
          maxValue: maxValue ?? values.reduce(math.max),
          color: color,
          height: 48,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
}

class _Reading extends StatelessWidget {
  const _Reading({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}

String _percent(double? value, String fallback) =>
    value == null ? fallback : '${value.toStringAsFixed(1)}%';

String _rate(double? value, String fallback) =>
    value == null ? fallback : '${_bytes(value, fallback)}/s';

String _bytes(num? value, String fallback) {
  if (value == null) return fallback;
  var amount = value.toDouble();
  const units = ['B', 'KiB', 'MiB', 'GiB', 'TiB'];
  var unit = 0;
  while (amount >= 1024 && unit < units.length - 1) {
    amount /= 1024;
    unit++;
  }
  return '${amount.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
}
