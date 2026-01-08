import 'dart:ui';

import 'package:flutter/material.dart';

/// A container widget that applies a glass/frosted glass effect to its child.
///
/// Uses [BackdropFilter] with blur to create a glassmorphism effect.
class GlassContainer extends StatelessWidget {
  /// The child widget to display with the glass effect.
  final Widget child;

  /// The blur intensity. Higher values create more blur.
  /// Defaults to 5.0.
  final double blur;

  /// The opacity of the white overlay. Values between 0.0 and 1.0.
  /// Defaults to 0.5.
  final double opacity;

  /// Optional border radius for the glass effect.
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 5.0,
    this.opacity = 0.5,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: opacity),
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
