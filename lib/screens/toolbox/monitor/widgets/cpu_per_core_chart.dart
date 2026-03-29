import 'package:data_visualization/data_visualization.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/gauge_painter.dart';

class CpuPerCoreChart extends StatelessWidget {
  const CpuPerCoreChart({super.key, required this.perCore});

  final List<double> perCore;

  @override
  Widget build(BuildContext context) {
    if (perCore.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: perCore.length * 28.0 + 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final band = scaleBand<int>(
            domain: List.generate(perCore.length, (i) => i),
            range: [0, perCore.length * 28.0],
            paddingInner: 0.2,
            paddingOuter: 0.1,
          );
          final xScale = scaleLinear(
            domain: [0, 100],
            range: [0, width - 60], // leave room for label
            clamp: true,
          );

          return CustomPaint(
            painter: _CoreBarPainter(
              perCore: perCore,
              band: band,
              xScale: xScale,
              textColor: Theme.of(context).colorScheme.onSurface,
              bgColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          );
        },
      ),
    );
  }
}

class _CoreBarPainter extends CustomPainter {
  _CoreBarPainter({
    required this.perCore,
    required this.band,
    required this.xScale,
    required this.textColor,
    required this.bgColor,
  });

  final List<double> perCore;
  final BandScale<int> band;
  final LinearScale xScale;
  final Color textColor;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = bgColor;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < perCore.length; i++) {
      final y = band(i);
      final h = band.bandwidth;
      final barWidth = xScale(perCore[i]).toDouble();

      // Background bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(50, y, size.width - 60, h),
          const Radius.circular(3),
        ),
        bgPaint,
      );

      // Value bar
      if (barWidth > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(50, y, barWidth, h),
            const Radius.circular(3),
          ),
          Paint()..color = gaugeColor(perCore[i]),
        );
      }

      // Label
      textPainter
        ..text = TextSpan(
          text: 'C$i',
          style: TextStyle(color: textColor, fontSize: 11),
        )
        ..layout();
      textPainter.paint(canvas, Offset(4, y + (h - textPainter.height) / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _CoreBarPainter old) => old.perCore != perCore;
}
