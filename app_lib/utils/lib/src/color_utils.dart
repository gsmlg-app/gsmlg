import 'package:flutter/material.dart';

enum ColorShade {
  lightest(50),
  secondLightest(100),
  thirdLightest(200),
  fourthLightest(300),
  fifthLightest(400),
  normal(500),
  fourthDarkest(600),
  thirdDarkest(700),
  secondDarkest(800),
  darkest(900);

  const ColorShade(this.value);

  final int value;
}

class GColorUtils {
  static MaterialColor getMaterialColor(Color color) {
    return Colors.primaries.firstWhere(
      (c) => c.toARGB32() == color.toARGB32(),
      orElse: () => MaterialColor(
        color.toARGB32(),
        <int, Color>{
          ColorShade.lightest.value: color,
          ColorShade.secondLightest.value: color,
          ColorShade.thirdLightest.value: color,
          ColorShade.fourthLightest.value: color,
          ColorShade.fifthLightest.value: color,
          ColorShade.normal.value: color,
          ColorShade.fourthDarkest.value: color,
          ColorShade.thirdDarkest.value: color,
          ColorShade.secondDarkest.value: color,
          ColorShade.darkest.value: color,
        },
      ),
    );
  }

  /// Determines whether the given [Color] is [Brightness.light] or
  /// [Brightness.dark].
  /// Copied from [ThemeData.estimateBrightnessForColor(color)]
  /// change [kThreshold] from 0.15 to 0.45 to accept more color
  /// with [Brightness.dark]
  static Brightness estimateBrightnessForColor(Color color) {
    final relativeLuminance = color.computeLuminance();
    const kThreshold = 0.45;
    if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold) {
      return Brightness.light;
    }
    return Brightness.dark;
  }

  /// get the dark shades version of current color,
  static List<Color?> getDarkShades(
    Color color, [
    ColorShade minShade = ColorShade.fifthLightest,
  ]) {
    final materialColor =
        color is MaterialColor ? color : getMaterialColor(color);
    final darkShades = <Color>[];

    for (final shade in ColorShade.values) {
      if (shade.value < minShade.value) continue;

      final colorShade = materialColor[shade.value]!;
      if (estimateBrightnessForColor(colorShade) == Brightness.dark) {
        darkShades.add(colorShade);
      }
    }

    return darkShades.isNotEmpty
        ? darkShades
        : [materialColor[ColorShade.darkest.value]];
  }

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
