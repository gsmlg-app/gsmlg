import 'package:data_visualization/data_visualization.dart' hide Curve;
import 'package:flutter/material.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.values,
    required this.maxValue,
    required this.color,
    this.fillColor,
    this.height = 60,
    this.width = double.infinity,
    this.strokeWidth = 2.0,
    this.label,
  });

  final List<double> values;
  final double maxValue;
  final Color color;
  final Color? fillColor;
  final double height;
  final double width;
  final double strokeWidth;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(height: height, width: width);
    }

    return SizedBox(
      height: height,
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final yScale = scaleLinear(
            domain: [0, maxValue > 0 ? maxValue : 1],
            range: [h - 2, 2],
            clamp: true,
          );
          final xStep = values.length > 1 ? w / (values.length - 1) : w;

          final points = <Point>[
            for (var i = 0; i < values.length; i++)
              Point(i * xStep, yScale(values[i]).toDouble()),
          ];

          final effectiveFill = fillColor ?? color.withValues(alpha: 0.15);
          final curve = curveMonotoneX();

          return Stack(
            children: [
              if (points.length > 1)
                AreaPath(
                  points: points,
                  baseline: h,
                  curve: curve,
                  color: effectiveFill,
                ),
              if (points.length > 1)
                LinePath(
                  points: points,
                  curve: curve,
                  color: color,
                  strokeWidth: strokeWidth,
                ),
              if (label != null)
                Positioned(
                  top: 2,
                  left: 4,
                  child: Text(
                    label!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: color),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
