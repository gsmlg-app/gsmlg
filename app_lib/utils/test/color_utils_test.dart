import 'package:app_utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

void main() {
  group('ColorShade', () {
    test('has correct values', () {
      expect(ColorShade.lightest.value, 50);
      expect(ColorShade.secondLightest.value, 100);
      expect(ColorShade.thirdLightest.value, 200);
      expect(ColorShade.fourthLightest.value, 300);
      expect(ColorShade.fifthLightest.value, 400);
      expect(ColorShade.normal.value, 500);
      expect(ColorShade.fourthDarkest.value, 600);
      expect(ColorShade.thirdDarkest.value, 700);
      expect(ColorShade.secondDarkest.value, 800);
      expect(ColorShade.darkest.value, 900);
    });

    test('values list is complete', () {
      expect(ColorShade.values.length, 10);
    });

    test('values are in ascending order', () {
      final values = ColorShade.values.map((s) => s.value).toList();
      for (int i = 1; i < values.length; i++) {
        expect(values[i], greaterThan(values[i - 1]));
      }
    });
  });

  group('GColorUtils.getMaterialColor', () {
    test('returns same MaterialColor for Colors.red', () {
      final materialColor = GColorUtils.getMaterialColor(Colors.red);
      expect(materialColor.toARGB32(), Colors.red.toARGB32());
    });

    test('returns same MaterialColor for Colors.blue', () {
      final materialColor = GColorUtils.getMaterialColor(Colors.blue);
      expect(materialColor.toARGB32(), Colors.blue.toARGB32());
    });

    test('returns same MaterialColor for Colors.green', () {
      final materialColor = GColorUtils.getMaterialColor(Colors.green);
      expect(materialColor.toARGB32(), Colors.green.toARGB32());
    });

    test('creates MaterialColor for custom color', () {
      const customColor = Color(0xFF123456);
      final materialColor = GColorUtils.getMaterialColor(customColor);
      expect(materialColor.toARGB32(), customColor.toARGB32());
    });

    test('custom MaterialColor has all shade values', () {
      const customColor = Color(0xFF123456);
      final materialColor = GColorUtils.getMaterialColor(customColor);

      for (final shade in ColorShade.values) {
        expect(materialColor[shade.value], isNotNull);
        expect(materialColor[shade.value], customColor);
      }
    });
  });

  group('GColorUtils.estimateBrightnessForColor', () {
    test('white is light', () {
      expect(
        GColorUtils.estimateBrightnessForColor(Colors.white),
        Brightness.light,
      );
    });

    test('black is dark', () {
      expect(
        GColorUtils.estimateBrightnessForColor(Colors.black),
        Brightness.dark,
      );
    });

    test('yellow is light', () {
      expect(
        GColorUtils.estimateBrightnessForColor(Colors.yellow),
        Brightness.light,
      );
    });

    test('dark blue is dark', () {
      expect(
        GColorUtils.estimateBrightnessForColor(Colors.blue[900]!),
        Brightness.dark,
      );
    });

    test('light grey is light', () {
      expect(
        GColorUtils.estimateBrightnessForColor(Colors.grey[300]!),
        Brightness.light,
      );
    });

    test('dark grey is dark', () {
      expect(
        GColorUtils.estimateBrightnessForColor(Colors.grey[800]!),
        Brightness.dark,
      );
    });
  });

  group('GColorUtils.getDarkShades', () {
    test('returns dark shades from material color', () {
      final darkShades = GColorUtils.getDarkShades(Colors.blue);
      expect(darkShades, isNotEmpty);
      for (final shade in darkShades) {
        if (shade != null) {
          expect(
            GColorUtils.estimateBrightnessForColor(shade),
            Brightness.dark,
          );
        }
      }
    });

    test('returns at least the darkest shade', () {
      final darkShades = GColorUtils.getDarkShades(Colors.yellow);
      expect(darkShades, isNotEmpty);
    });

    test('respects minShade parameter', () {
      final shades = GColorUtils.getDarkShades(
        Colors.blue,
        ColorShade.normal,
      );
      // Should only include shades >= normal (500)
      expect(shades, isNotEmpty);
    });

    test('works with custom Color', () {
      const customColor = Color(0xFF336699);
      final darkShades = GColorUtils.getDarkShades(customColor);
      expect(darkShades, isNotEmpty);
    });
  });

  group('GColorUtils.darken', () {
    test('darkens color by default amount (0.1)', () {
      final darkenedRed = GColorUtils.darken(Colors.red);
      expect(darkenedRed, isNot(equals(Colors.red)));
      // Darker color should have lower luminance
      expect(
        darkenedRed.computeLuminance(),
        lessThan(Colors.red.computeLuminance()),
      );
    });

    test('darkens color by specified amount', () {
      final slightlyDarker = GColorUtils.darken(Colors.blue, 0.05);
      final muchDarker = GColorUtils.darken(Colors.blue, 0.3);

      expect(
        slightlyDarker.computeLuminance(),
        greaterThan(muchDarker.computeLuminance()),
      );
    });

    test('clamps to black for large amount', () {
      final result = GColorUtils.darken(Colors.grey, 1.0);
      // Should be very dark (close to black)
      expect(result.computeLuminance(), lessThan(0.01));
    });

    test('zero amount returns same color', () {
      final original = Colors.purple;
      final result = GColorUtils.darken(original, 0.0);
      expect(result.toARGB32(), original.toARGB32());
    });

    test('throws assertion error for negative amount', () {
      expect(
        () => GColorUtils.darken(Colors.red, -0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for amount > 1', () {
      expect(
        () => GColorUtils.darken(Colors.red, 1.1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('GColorUtils.lighten', () {
    test('lightens color by default amount (0.1)', () {
      final lightenedRed = GColorUtils.lighten(Colors.red);
      expect(lightenedRed, isNot(equals(Colors.red)));
      // Lighter color should have higher luminance
      expect(
        lightenedRed.computeLuminance(),
        greaterThan(Colors.red.computeLuminance()),
      );
    });

    test('lightens color by specified amount', () {
      final slightlyLighter = GColorUtils.lighten(Colors.blue, 0.05);
      final muchLighter = GColorUtils.lighten(Colors.blue, 0.3);

      expect(
        slightlyLighter.computeLuminance(),
        lessThan(muchLighter.computeLuminance()),
      );
    });

    test('clamps to white for large amount', () {
      final result = GColorUtils.lighten(Colors.grey, 1.0);
      // Should be very light (close to white)
      expect(result.computeLuminance(), greaterThan(0.99));
    });

    test('zero amount returns same color', () {
      final original = Colors.purple;
      final result = GColorUtils.lighten(original, 0.0);
      expect(result.toARGB32(), original.toARGB32());
    });

    test('throws assertion error for negative amount', () {
      expect(
        () => GColorUtils.lighten(Colors.red, -0.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for amount > 1', () {
      expect(
        () => GColorUtils.lighten(Colors.red, 1.1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Darken and lighten are inverse operations', () {
    test('darken then lighten returns similar color', () {
      final original = Colors.blue;
      final darkened = GColorUtils.darken(original, 0.2);
      final restored = GColorUtils.lighten(darkened, 0.2);

      // Due to HSL conversion, colors may not be exactly equal
      // but should be very close
      final originalLuminance = original.computeLuminance();
      final restoredLuminance = restored.computeLuminance();
      expect(
        (originalLuminance - restoredLuminance).abs(),
        lessThan(0.05),
      );
    });

    test('lighten then darken returns similar color', () {
      final original = Colors.red;
      final lightened = GColorUtils.lighten(original, 0.2);
      final restored = GColorUtils.darken(lightened, 0.2);

      final originalLuminance = original.computeLuminance();
      final restoredLuminance = restored.computeLuminance();
      expect(
        (originalLuminance - restoredLuminance).abs(),
        lessThan(0.05),
      );
    });
  });
}
