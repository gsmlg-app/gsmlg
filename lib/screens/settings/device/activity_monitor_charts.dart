import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_visualization/duskmoon_visualization_compat.dart'
    hide Curve;
import 'package:flutter/material.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/sparkline_chart.dart';

/// A grid and shared scale for a single, stacked, or mirrored history.
class ActivityHistoryChart extends StatelessWidget {
  const ActivityHistoryChart({
    super.key,
    required this.values,
    required this.color,
    this.secondaryValues = const [],
    this.secondaryColor,
    this.maxValue = 100,
    this.mirrored = false,
    this.stepped = false,
    this.height = 96,
  });

  final List<double> values;
  final List<double> secondaryValues;
  final Color color;
  final Color? secondaryColor;
  final double maxValue;
  final bool mirrored;
  final bool stepped;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.activityMonitorHistory,
      child: SizedBox(
        height: height,
        child: ClipRect(
          child: ColoredBox(
            color: colors.surfaceContainerLowest,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: List.generate(
                    4,
                    (_) => Expanded(
                      child: Row(
                        children: List.generate(
                          10,
                          (_) => Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: colors.outlineVariant.withValues(
                                      alpha: .25,
                                    ),
                                  ),
                                  right: BorderSide(
                                    color: colors.outlineVariant.withValues(
                                      alpha: .25,
                                    ),
                                  ),
                                ),
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (values.length < 2)
                  Center(
                    child: Text(
                      context.l10n.activityMonitorWaiting,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else if (!stepped && secondaryValues.length != values.length)
                  SparklineChart(
                    values: values,
                    maxValue: maxValue,
                    color: color,
                    height: height,
                    strokeWidth: 1.25,
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final h = constraints.maxHeight;
                      final w = constraints.maxWidth;
                      final baseline = mirrored ? h / 2 : h - 2;
                      final amplitude = mirrored ? h / 2 - 2 : h - 4;
                      final maximum = maxValue > 0 ? maxValue : 1;
                      final hasSecondary =
                          secondaryValues.length == values.length;
                      List<Point> points(
                        List<double> data, {
                        bool below = false,
                      }) => [
                        for (var i = 0; i < data.length; i++)
                          Point(
                            i * w / (data.length - 1),
                            baseline +
                                (below ? 1 : -1) *
                                    data[i].clamp(0, maximum) /
                                    maximum *
                                    amplitude,
                          ),
                      ];
                      final primary = points(values);
                      final secondary = hasSecondary
                          ? points(secondaryValues, below: mirrored)
                          : <Point>[];
                      final curve = stepped
                          ? curveStepAfter()
                          : curveMonotoneX();
                      final otherColor = secondaryColor ?? colors.error;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          AreaPath(
                            points: primary,
                            baseline: baseline,
                            bottomPoints: mirrored || !hasSecondary
                                ? null
                                : secondary,
                            curve: curve,
                            color: color.withValues(alpha: .35),
                          ),
                          if (hasSecondary)
                            AreaPath(
                              points: secondary,
                              baseline: baseline,
                              curve: curve,
                              color: otherColor.withValues(alpha: .35),
                            ),
                          LinePath(
                            points: primary,
                            curve: curve,
                            color: color,
                            strokeWidth: 1.25,
                          ),
                          if (hasSecondary)
                            LinePath(
                              points: secondary,
                              curve: curve,
                              color: otherColor,
                              strokeWidth: 1.25,
                            ),
                          if (mirrored)
                            Align(
                              alignment: Alignment.center,
                              child: Divider(height: 1, color: colors.outline),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityCoreMeter extends StatelessWidget {
  const ActivityCoreMeter({
    super.key,
    required this.label,
    required this.usage,
    required this.color,
    this.compact = false,
  });
  final String label;
  final double? usage;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final value = usage;
    final segments = compact ? 12 : 24;
    return Semantics(
      label: label,
      value: value == null
          ? context.l10n.activityMonitorUnavailable
          : '${value.toStringAsFixed(1)}%',
      child: SizedBox(
        width: 48,
        child: Column(
          children: [
            Text(
              value == null
                  ? '—'
                  : '${value.toStringAsFixed(compact ? 0 : 1)}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(height: compact ? 3 : 8),
            SizedBox(
              width: compact ? 24 : 28,
              height: compact ? 32 : 150,
              child: Column(
                children: List.generate(segments, (index) {
                  final filled =
                      value != null &&
                      (segments - index) <=
                          (value.clamp(0, 100) / 100 * segments).ceil();
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: compact ? 1 : 2),
                      decoration: BoxDecoration(
                        color: filled
                            ? color
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        border: compact
                            ? null
                            : Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: compact ? 3 : 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
