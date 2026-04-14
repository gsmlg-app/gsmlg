import 'dart:math' as math;
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:duskmoon_visualization/duskmoon_visualization_compat.dart';
import 'package:flutter/material.dart';

/// Computes a gauge gradient color from [lowColor] through [midColor] to
/// [highColor] based on [percent] (0-100).
Color gaugeColorFromTokens(
  double percent, {
  required Color lowColor,
  required Color midColor,
  required Color highColor,
}) {
  if (percent < 60) {
    return Color.lerp(lowColor, midColor, percent / 60)!;
  }
  if (percent < 80) {
    return Color.lerp(midColor, highColor, (percent - 60) / 20)!;
  }
  return highColor;
}

/// Convenience wrapper that resolves gauge colors from the current theme.
Color gaugeColor(double percent, {required BuildContext context}) {
  final dmColors = Theme.of(context).extension<DmColorExtension>()!;
  final colorScheme = Theme.of(context).colorScheme;
  return gaugeColorFromTokens(
    percent,
    lowColor: dmColors.success,
    midColor: dmColors.warning,
    highColor: colorScheme.error,
  );
}

class RadialGauge extends StatelessWidget {
  const RadialGauge({
    super.key,
    required this.percent,
    required this.label,
    this.sublabel,
    this.size = 120,
  });

  final double percent;
  final String label;
  final String? sublabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0.0, 100.0);
    final color = gaugeColor(clampedPercent, context: context);
    final outerRadius = size / 2;
    final innerRadius = outerRadius * 0.75;

    // Arc angles: sweep 270 degrees (from 135° to 405°)
    const startAngle = 135 * math.pi / 180;
    const totalSweep = 270 * math.pi / 180;
    final valueAngle = startAngle + (totalSweep * clampedPercent / 100);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background arc
          Arc(
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            startAngle: startAngle,
            endAngle: startAngle + totalSweep,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          // Value arc
          if (clampedPercent > 0)
            Arc(
              outerRadius: outerRadius,
              innerRadius: innerRadius,
              startAngle: startAngle,
              endAngle: valueAngle,
              color: color,
            ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${clampedPercent.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
