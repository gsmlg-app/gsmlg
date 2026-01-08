import 'package:flutter/material.dart';

/// Default gap value used for grid spacing and border radius.
const double kDefaultGridGap = 16.0;

/// A stylized grid tile widget with elevation, customizable colors,
/// and tap/long-press interactions.
///
/// Commonly used in grid layouts for displaying interactive cards.
class AppGridTile extends StatelessWidget {
  /// The child widget to display inside the tile.
  final Widget child;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Background color of the tile.
  /// Defaults to the theme's tertiary container color.
  final Color? color;

  /// Shadow color of the tile.
  /// Defaults to the theme's onTertiaryContainer color.
  final Color? shadowColor;

  /// Text color for the default text style.
  /// Defaults to the theme's onTertiaryContainer color.
  final Color? textColor;

  /// The gap/spacing value used for elevation and border radius.
  /// Defaults to [kDefaultGridGap].
  final double gridGap;

  const AppGridTile({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.shadowColor,
    this.textColor,
    this.gridGap = kDefaultGridGap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PhysicalModel(
      elevation: gridGap / 4,
      borderRadius: BorderRadius.circular(gridGap),
      color: color ?? colorScheme.tertiaryContainer,
      shadowColor: shadowColor ?? colorScheme.onTertiaryContainer,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(gridGap),
          splashColor: colorScheme.tertiary,
          onTap: onTap != null
              ? () async {
                  await Future.delayed(const Duration(milliseconds: 83));
                  onTap?.call();
                }
              : null,
          onLongPress: onLongPress != null
              ? () async {
                  await Future.delayed(const Duration(milliseconds: 83));
                  onLongPress?.call();
                }
              : null,
          child: Container(
            alignment: Alignment.center,
            child: DefaultTextStyle(
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge!.copyWith(
                color: textColor ?? colorScheme.onTertiaryContainer,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
