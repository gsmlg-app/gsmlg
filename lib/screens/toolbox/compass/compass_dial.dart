import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'compass_math.dart';

/// A compass rose rotating underneath the fixed screen-top marker.
class CompassDial extends StatefulWidget {
  const CompassDial({
    super.key,
    required this.heading,
    required this.directions,
  });

  final double? heading;

  /// Localized north, east, south and west labels, in that order.
  final List<String> directions;

  @override
  State<CompassDial> createState() => _CompassDialState();
}

class _CompassDialState extends State<CompassDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  Animation<double> _angle = const AlwaysStoppedAnimation(0);
  bool _hasHeading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateHeading();
  }

  @override
  void didUpdateWidget(CompassDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.heading != oldWidget.heading) _updateHeading();
  }

  void _updateHeading() {
    final heading = widget.heading;
    if (heading == null) {
      _controller.stop();
      _hasHeading = false;
      return;
    }
    final current = _angle.value;
    _controller.stop();
    if (!_hasHeading || MediaQuery.disableAnimationsOf(context)) {
      _angle = AlwaysStoppedAnimation(heading);
    } else {
      _angle = Tween<double>(
        begin: current,
        end: current + shortestHeadingDelta(current, heading),
      ).animate(_controller);
      _controller.forward(from: 0);
    }
    _hasHeading = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = math.min(360.0, constraints.maxWidth);
        return ExcludeSemantics(
          child: SizedBox.square(
            dimension: diameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => RotationTransition(
                    turns: AlwaysStoppedAnimation(-_angle.value / 360),
                    child: child,
                  ),
                  child: CustomPaint(
                    size: Size.square(diameter),
                    painter: _CompassRosePainter(
                      colors: theme.colorScheme,
                      labelStyle: theme.textTheme.titleMedium!,
                      textScaler: MediaQuery.textScalerOf(context),
                      directions: widget.directions,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                Icon(Icons.add, size: 24, color: theme.colorScheme.outline),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  const _CompassRosePainter({
    required this.colors,
    required this.labelStyle,
    required this.textScaler,
    required this.directions,
  });

  final ColorScheme colors;
  final TextStyle labelStyle;
  final TextScaler textScaler;
  final List<String> directions;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 18;
    final paint = Paint()
      ..color = colors.outlineVariant
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);
    for (var degrees = 0; degrees < 360; degrees += 5) {
      final angle = degrees * math.pi / 180 - math.pi / 2;
      final major = degrees % 30 == 0;
      final vector = Offset(math.cos(angle), math.sin(angle));
      paint
        ..color = degrees == 0 ? colors.error : colors.outline
        ..strokeWidth = major ? 2 : 1;
      canvas.drawLine(
        center + vector * radius,
        center + vector * (radius - (major ? 16 : 8)),
        paint,
      );
    }
    for (var index = 0; index < 4; index++) {
      final angle = index * math.pi / 2 - math.pi / 2;
      final text = TextPainter(
        text: TextSpan(
          text: directions[index],
          style: labelStyle.copyWith(
            color: index == 0 ? colors.error : colors.onSurface,
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      final labelCenter =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius - 42);
      final scale = math.min(1.0, size.shortestSide / 3 / text.width);
      canvas.save();
      canvas.translate(labelCenter.dx, labelCenter.dy);
      canvas.scale(scale);
      text.paint(canvas, Offset(-text.width / 2, -text.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CompassRosePainter oldDelegate) =>
      colors != oldDelegate.colors ||
      labelStyle != oldDelegate.labelStyle ||
      textScaler != oldDelegate.textScaler ||
      directions != oldDelegate.directions;
}
