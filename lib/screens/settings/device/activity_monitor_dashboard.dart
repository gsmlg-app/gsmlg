import 'dart:math' as math;

import 'package:app_locale/app_locale.dart';
import 'package:app_system_metrics/app_system_metrics.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';

import 'activity_monitor_charts.dart';

class ActivityMonitorDashboard extends StatefulWidget {
  const ActivityMonitorDashboard({
    super.key,
    required this.snapshot,
    required this.history,
    required this.running,
    this.onToggleSampling,
    this.samplingPaused = false,
  });

  final ActivitySnapshot snapshot;
  final List<ActivitySnapshot> history;
  final bool running;
  final VoidCallback? onToggleSampling;
  final bool samplingPaused;

  @override
  State<ActivityMonitorDashboard> createState() =>
      _ActivityMonitorDashboardState();
}

class _ActivityMonitorDashboardState extends State<ActivityMonitorDashboard> {
  bool _diskOperations = false;
  bool _networkPackets = false;
  ActivitySnapshot get snapshot => widget.snapshot;
  List<ActivitySnapshot> get history => widget.history;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<DmColorExtension>();
    final user = semantic?.success ?? colors.primary;
    final io = semantic?.info ?? colors.tertiary;
    final system = colors.error;
    final warning = semantic?.warning ?? colors.secondary;
    final unavailable = l10n.activityMonitorUnavailable;
    final memory = snapshot.memory;
    final disk = snapshot.disk;
    final network = snapshot.network;
    final performance = snapshot.cores
        .where((c) => c.type == 'performance')
        .length;
    final efficiency = snapshot.cores
        .where((c) => c.type == 'efficiency')
        .length;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(snapshot.timestamp.toLocal()),
      alwaysUse24HourFormat: true,
    );
    final pressure = switch (memory.pressure) {
      1 => l10n.activityMonitorPressureNormal,
      2 => l10n.activityMonitorPressureWarning,
      4 => l10n.activityMonitorPressureCritical,
      _ => unavailable,
    };
    final pressureColor = switch (memory.pressure) {
      2 => warning,
      4 => system,
      _ => user,
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1540),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final largeText = MediaQuery.textScalerOf(context).scale(14) > 21;
              final columns = width >= 860 && !largeText ? 2 : 1;
              final coreColumns = width >= 1100 && !largeText
                  ? 3
                  : width >= 680 && !largeText
                  ? 2
                  : 1;
              final summaryColumns = width >= 1000 && !largeText
                  ? 4
                  : width >= 420 && !largeText
                  ? 2
                  : 1;
              Widget pair(Widget first, Widget second) => Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  for (final child in [first, second])
                    SizedBox(
                      width: (width - (columns - 1) * 20) / columns,
                      child: child,
                    ),
                ],
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.activityMonitorTelemetry.toUpperCase(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: user,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.activityMonitorThisDevice,
                            style: theme.textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.model} · ${snapshot.architecture}',
                            style: _numeric(context),
                          ),
                          Text(
                            snapshot.cpuBrand,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _Legend(
                                label: widget.running
                                    ? l10n.activityMonitorSampling
                                    : l10n.activityMonitorPaused,
                                color: widget.running
                                    ? user
                                    : colors.onSurfaceVariant,
                              ),
                              if (widget.onToggleSampling != null)
                                DmButton(
                                  variant: DmButtonVariant.outlined,
                                  onPressed: widget.onToggleSampling,
                                  child: Text(
                                    widget.samplingPaused
                                        ? l10n.activityMonitorResume
                                        : l10n.activityMonitorPause,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.activityMonitorUpdated(time),
                            style: _numeric(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Wrap(
                      children: [
                        for (final item in <(String, String, String)>[
                          (
                            l10n.activityMonitorCpu,
                            _percent(snapshot.cpuUsage, unavailable),
                            '0–100%',
                          ),
                          (
                            l10n.activityMonitorMemory,
                            _bytes(memory.usedBytes, unavailable),
                            '/ ${_bytes(memory.totalBytes, unavailable)}',
                          ),
                          (
                            l10n.activityMonitorLogicalCores,
                            snapshot.cores.length.toString(),
                            performance + efficiency > 0
                                ? '$performance'
                                      'P · $efficiency'
                                      'E'
                                : '',
                          ),
                          (
                            l10n.activityMonitorSamples,
                            history.length.toString(),
                            '1 Hz',
                          ),
                        ])
                          SizedBox(
                            width: width / summaryColumns - 1,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.$1,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.$2,
                                    style: _numeric(context, size: 30),
                                  ),
                                  Text(item.$3, style: _numeric(context)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Panel(
                    title: l10n.activityMonitorCpuHistory,
                    trailing: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _Legend(label: l10n.activityMonitorUser, color: user),
                        _Legend(
                          label: l10n.activityMonitorSystem,
                          color: system,
                        ),
                        Text('0–100%', style: _numeric(context)),
                      ],
                    ),
                    padding: EdgeInsets.zero,
                    children: [
                      LayoutBuilder(
                        builder: (context, grid) => Wrap(
                          children: [
                            for (final core in snapshot.cores)
                              Container(
                                key: ValueKey('core-history-${core.id}'),
                                width: grid.maxWidth / coreColumns,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerLowest,
                                  border: Border.all(
                                    color: colors.outlineVariant,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _Reading(
                                      label: _coreName(context, core),
                                      value: _percent(core.usage, '—'),
                                      color: core.type == 'efficiency'
                                          ? user
                                          : io,
                                    ),
                                    const SizedBox(height: 8),
                                    _chart(
                                      (s) => s.cores
                                          .where((c) => c.id == core.id)
                                          .singleOrNull
                                          ?.usage,
                                      user,
                                      secondary: core.systemUsage == null
                                          ? null
                                          : (s) => s.cores
                                                .where((c) => c.id == core.id)
                                                .singleOrNull
                                                ?.systemUsage,
                                      secondaryColor: system,
                                      maxValue: 100,
                                      height: 82,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      spacing: 12,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          '${l10n.activityMonitorUser} ${_percent(core.userUsage, '—')}',
                                          style: _numeric(context),
                                        ),
                                        Text(
                                          '${l10n.activityMonitorSystem} ${_percent(core.systemUsage, '—')}',
                                          style: _numeric(context),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: _timeline(context, count: history.length),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  pair(
                    _Panel(
                      title: l10n.activityMonitorCoreLoad,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 20,
                          children: [
                            for (final core in snapshot.cores)
                              ActivityCoreMeter(
                                label: _coreShort(core),
                                usage: core.usage,
                                color: core.type == 'efficiency' ? user : io,
                              ),
                          ],
                        ),
                      ],
                    ),
                    _Panel(
                      key: const ValueKey('gpu-panel'),
                      title: l10n.activityMonitorGpuHistory,
                      children: [
                        if (snapshot.gpus.isEmpty)
                          Text(l10n.activityMonitorGpuUnavailable),
                        for (final (index, gpu) in snapshot.gpus.indexed) ...[
                          _Reading(
                            label: gpu.name,
                            value: _percent(gpu.usage, unavailable),
                            color: io,
                          ),
                          const SizedBox(height: 12),
                          _chart(
                            (s) => s.gpus
                                .where((g) => g.name == gpu.name)
                                .singleOrNull
                                ?.usage,
                            io,
                            maxValue: 100,
                            height: 150,
                            key: ValueKey('gpu-history-$index-${gpu.name}'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _timeline(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  pair(
                    _Panel(
                      title: l10n.activityMonitorMemory,
                      trailing: Text(
                        pressure,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: pressureColor,
                        ),
                      ),
                      children: [
                        Text(
                          l10n.activityMonitorPressure,
                          style: _numeric(context),
                        ),
                        const SizedBox(height: 12),
                        _chart(
                          (s) => switch (s.memory.pressure) {
                            1 => 1,
                            2 => 2,
                            4 => 3,
                            _ => null,
                          },
                          pressureColor,
                          maxValue: 3,
                          height: 90,
                          stepped: true,
                          key: const ValueKey('memory-pressure-history'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.activityMonitorPressureNormal} / ${l10n.activityMonitorPressureWarning} / ${l10n.activityMonitorPressureCritical}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        _facts([
                          (
                            l10n.activityMonitorTotal,
                            _bytes(memory.totalBytes, unavailable),
                          ),
                          (
                            l10n.activityMonitorUsed,
                            _bytes(memory.usedBytes, unavailable),
                          ),
                          (
                            l10n.activityMonitorAppMemory,
                            _bytes(memory.appBytes, unavailable),
                          ),
                          (
                            l10n.activityMonitorWired,
                            _bytes(memory.wiredBytes, unavailable),
                          ),
                          (
                            l10n.activityMonitorCompressed,
                            _bytes(memory.compressedBytes, unavailable),
                          ),
                          (
                            l10n.activityMonitorCachedFiles,
                            _bytes(memory.cachedBytes, unavailable),
                          ),
                          (
                            l10n.activityMonitorSwapUsed,
                            _bytes(memory.swapUsedBytes, unavailable),
                          ),
                          (
                            l10n.activityMonitorSwapTotal,
                            _bytes(memory.swapTotalBytes, unavailable),
                          ),
                        ]),
                      ],
                    ),
                    _Panel(
                      title: l10n.activityMonitorCpu,
                      children: [
                        _chart(
                          (s) => s.cpuUsage,
                          user,
                          secondary: snapshot.cpuSystemUsage == null
                              ? null
                              : (s) => s.cpuSystemUsage,
                          secondaryColor: system,
                          maxValue: 100,
                          height: 140,
                          key: const ValueKey('cpu-total-history'),
                        ),
                        const SizedBox(height: 20),
                        _facts([
                          (
                            l10n.activityMonitorSystem,
                            _percent(snapshot.cpuSystemUsage, unavailable),
                          ),
                          (
                            l10n.activityMonitorUser,
                            _percent(snapshot.cpuUserUsage, unavailable),
                          ),
                          (
                            l10n.activityMonitorIdle,
                            _percent(
                              snapshot.cpuUsage == null
                                  ? null
                                  : 100 - snapshot.cpuUsage!,
                              unavailable,
                            ),
                          ),
                          (
                            l10n.activityMonitorProcessCount,
                            snapshot.processCount?.toString() ?? unavailable,
                          ),
                          (
                            l10n.activityMonitorThreadCount,
                            snapshot.threadCount?.toString() ?? unavailable,
                          ),
                        ]),
                        if (!snapshot.threadCountComplete &&
                            snapshot.threadCount != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              l10n.activityMonitorPartialThreads,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  pair(
                    _Panel(
                      title: l10n.activityMonitorDisk,
                      trailing: _units(
                        l10n.activityMonitorBytes,
                        l10n.activityMonitorOperations,
                        _diskOperations,
                        (value) => setState(() => _diskOperations = value),
                      ),
                      children: [
                        _ioLegend(
                          context,
                          l10n.activityMonitorRead,
                          l10n.activityMonitorWrite,
                          io,
                          system,
                        ),
                        const SizedBox(height: 12),
                        _chart(
                          (s) => _diskOperations
                              ? s.disk.readOperationsPerSecond
                              : s.disk.readBytesPerSecond,
                          io,
                          secondary: (s) => _diskOperations
                              ? s.disk.writeOperationsPerSecond
                              : s.disk.writeBytesPerSecond,
                          secondaryColor: system,
                          mirrored: true,
                          height: 125,
                          key: const ValueKey('disk-history'),
                        ),
                        const SizedBox(height: 20),
                        _facts([
                          (
                            '${l10n.activityMonitorRead} · ${l10n.activityMonitorOperations}',
                            disk.readOperations?.toString() ?? unavailable,
                          ),
                          (
                            '${l10n.activityMonitorWrite} · ${l10n.activityMonitorOperations}',
                            disk.writeOperations?.toString() ?? unavailable,
                          ),
                          (
                            '${l10n.activityMonitorRead} / s',
                            _countRate(
                              disk.readOperationsPerSecond,
                              unavailable,
                            ),
                          ),
                          (
                            '${l10n.activityMonitorWrite} / s',
                            _countRate(
                              disk.writeOperationsPerSecond,
                              unavailable,
                            ),
                          ),
                          (
                            '${l10n.activityMonitorRead} · ${l10n.activityMonitorCumulative}',
                            _bytes(disk.readBytes, unavailable),
                          ),
                          (
                            '${l10n.activityMonitorWrite} · ${l10n.activityMonitorCumulative}',
                            _bytes(disk.writeBytes, unavailable),
                          ),
                          (
                            '${l10n.activityMonitorRead} · ${l10n.activityMonitorRate}',
                            _rate(disk.readBytesPerSecond, unavailable),
                          ),
                          (
                            '${l10n.activityMonitorWrite} · ${l10n.activityMonitorRate}',
                            _rate(disk.writeBytesPerSecond, unavailable),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Text(
                          disk.available
                              ? disk.devices.join(', ')
                              : unavailable,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    _Panel(
                      title: l10n.activityMonitorNetwork,
                      trailing: _units(
                        l10n.activityMonitorBytes,
                        l10n.activityMonitorPackets,
                        _networkPackets,
                        (value) => setState(() => _networkPackets = value),
                      ),
                      children: [
                        _ioLegend(
                          context,
                          l10n.activityMonitorReceived,
                          l10n.activityMonitorSent,
                          io,
                          system,
                        ),
                        const SizedBox(height: 12),
                        _chart(
                          (s) => _networkPackets
                              ? s.network.receivedPacketsPerSecond
                              : s.network.receivedBytesPerSecond,
                          io,
                          secondary: (s) => _networkPackets
                              ? s.network.sentPacketsPerSecond
                              : s.network.sentBytesPerSecond,
                          secondaryColor: system,
                          mirrored: true,
                          height: 125,
                          key: const ValueKey('network-history'),
                        ),
                        const SizedBox(height: 20),
                        _facts([
                          (
                            '${l10n.activityMonitorReceived} · ${l10n.activityMonitorPackets}',
                            network.receivedPackets?.toString() ?? unavailable,
                          ),
                          (
                            '${l10n.activityMonitorSent} · ${l10n.activityMonitorPackets}',
                            network.sentPackets?.toString() ?? unavailable,
                          ),
                          (
                            '${l10n.activityMonitorReceived} / s',
                            _countRate(
                              network.receivedPacketsPerSecond,
                              unavailable,
                            ),
                          ),
                          (
                            '${l10n.activityMonitorSent} / s',
                            _countRate(
                              network.sentPacketsPerSecond,
                              unavailable,
                            ),
                          ),
                          (
                            '${l10n.activityMonitorReceived} · ${l10n.activityMonitorCumulative}',
                            _bytes(network.receivedBytes, unavailable),
                          ),
                          (
                            '${l10n.activityMonitorSent} · ${l10n.activityMonitorCumulative}',
                            _bytes(network.sentBytes, unavailable),
                          ),
                          (
                            '${l10n.activityMonitorReceived} · ${l10n.activityMonitorRate}',
                            _rate(network.receivedBytesPerSecond, unavailable),
                          ),
                          (
                            '${l10n.activityMonitorSent} · ${l10n.activityMonitorRate}',
                            _rate(network.sentBytesPerSecond, unavailable),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Text(
                          network.interfaces.map((i) => i.name).join(', '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: ExpansionTile(
                      title: Text(l10n.activityMonitorDataSources),
                      initiallyExpanded: true,
                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.activityMonitorDataNotes),
                        const SizedBox(height: 12),
                        Text(l10n.activityMonitorMemoryNotes),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _chart(
    double? Function(ActivitySnapshot) select,
    Color color, {
    double? Function(ActivitySnapshot)? secondary,
    Color? secondaryColor,
    double? maxValue,
    double height = 96,
    bool mirrored = false,
    bool stepped = false,
    Key? key,
  }) {
    final first = <double>[];
    final second = <double>[];
    for (final sample in history.reversed) {
      final value = select(sample);
      final other = secondary?.call(sample);
      if (value == null || (secondary != null && other == null)) break;
      first.add(value);
      if (other != null) second.add(other);
    }
    return ActivityHistoryChart(
      key: key,
      values: first.reversed.toList(),
      secondaryValues: second.reversed.toList(),
      color: color,
      secondaryColor: secondaryColor,
      height: height,
      mirrored: mirrored,
      stepped: stepped,
      maxValue: maxValue ?? [...first, ...second, 1.0].reduce(math.max),
    );
  }

  Widget _facts(List<(String, String)> readings) => LayoutBuilder(
    builder: (context, constraints) {
      final two =
          constraints.maxWidth >= 480 &&
          MediaQuery.textScalerOf(context).scale(14) <= 21;
      return Wrap(
        spacing: 20,
        children: [
          for (final reading in readings)
            SizedBox(
              width: two
                  ? (constraints.maxWidth - 20) / 2
                  : constraints.maxWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _Reading(label: reading.$1, value: reading.$2),
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _units(
    String first,
    String second,
    bool selected,
    ValueChanged<bool> onChanged,
  ) => Wrap(
    children: [
      for (final entry in [(false, first), (true, second)])
        Semantics(
          selected: selected == entry.$1,
          child: DmButton(
            variant: selected == entry.$1
                ? DmButtonVariant.tonal
                : DmButtonVariant.text,
            onPressed: () => onChanged(entry.$1),
            child: Text(entry.$2),
          ),
        ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
  });
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              ?trailing,
            ],
          ),
        ),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    ),
  );
}

class _Reading extends StatelessWidget {
  const _Reading({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(label)),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: _numeric(context)?.copyWith(color: color),
        ),
      ),
    ],
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 8, color: color),
      const SizedBox(width: 6),
      Flexible(
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
    ],
  );
}

Widget _ioLegend(
  BuildContext context,
  String first,
  String second,
  Color a,
  Color b,
) => Wrap(
  spacing: 20,
  runSpacing: 8,
  children: [
    _Legend(label: '↑ $first', color: a),
    _Legend(label: '↓ $second', color: b),
  ],
);

Widget _timeline(BuildContext context, {int? count}) => Wrap(
  alignment: WrapAlignment.spaceBetween,
  spacing: 12,
  runSpacing: 4,
  children: [
    Text(context.l10n.activityMonitorEarlier, style: _numeric(context)),
    if (count != null)
      Text(
        context.l10n.activityMonitorHistoryWindow(count),
        style: _numeric(context),
      ),
    Text(context.l10n.activityMonitorNow, style: _numeric(context)),
  ],
);

String _coreName(BuildContext context, ActivityCpuCore core) =>
    switch (core.type) {
      'performance' => context.l10n.activityMonitorPerformanceCore(core.id),
      'efficiency' => context.l10n.activityMonitorEfficiencyCore(core.id),
      _ => context.l10n.activityMonitorCore(core.id),
    };
String _coreShort(ActivityCpuCore core) => switch (core.type) {
  'performance' => 'P${core.id}',
  'efficiency' => 'E${core.id}',
  _ => core.id.toString(),
};
TextStyle? _numeric(BuildContext context, {double? size}) =>
    Theme.of(context).textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      fontSize: size,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
String _percent(double? value, String fallback) =>
    value == null ? fallback : '${value.toStringAsFixed(1)}%';
String _countRate(double? value, String fallback) =>
    value == null ? fallback : '${value.toStringAsFixed(1)}/s';
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
