import 'package:flutter/material.dart';

/// A button widget with a neon glow effect using gradient and box shadow.
///
/// Creates a visually striking button with a glowing appearance based on
/// the theme's secondary color.
class NeonButton extends StatelessWidget {
  /// The text to display on the button.
  final String text;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Vertical padding inside the button.
  /// Defaults to 16.0.
  final double verticalPadding;

  /// Horizontal padding inside the button.
  /// Defaults to 24.0.
  final double horizontalPadding;

  /// Border radius of the button.
  /// Defaults to 10.0.
  final double borderRadius;

  /// The blur radius of the glow effect.
  /// Defaults to 20.0.
  final double glowBlurRadius;

  /// The spread radius of the glow effect.
  /// Defaults to 5.0.
  final double glowSpreadRadius;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.verticalPadding = 16.0,
    this.horizontalPadding = 24.0,
    this.borderRadius = 10.0,
    this.glowBlurRadius = 20.0,
    this.glowSpreadRadius = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = colorScheme.secondary;

    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withValues(alpha: 0.5),
            blurRadius: glowBlurRadius,
            spreadRadius: glowSpreadRadius,
          ),
        ],
        gradient: LinearGradient(
          colors: [
            secondaryColor.withValues(alpha: 0.3),
            secondaryColor.withValues(alpha: 0.15),
            secondaryColor.withValues(alpha: 0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }
}
