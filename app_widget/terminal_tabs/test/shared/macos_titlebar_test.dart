import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shared/macos_titlebar.dart';

void main() {
  group('MacosTitlebar Constants', () {
    test('kMacosTitlebarHeight is 28.0', () {
      expect(kMacosTitlebarHeight, equals(28.0));
    });

    test('kMacosTitlebarHeight is a double', () {
      expect(kMacosTitlebarHeight, isA<double>());
    });

    test('kMacosTitlebarHeight is positive', () {
      expect(kMacosTitlebarHeight, greaterThan(0));
    });
  });

  group('MacosTitlebar', () {
    test('is a StatefulWidget', () {
      const titlebar = MacosTitlebar(color: Color(0xFF000000));
      expect(titlebar, isA<StatefulWidget>());
    });

    test('stores color property', () {
      const color = Color(0xFFFF0000);
      const titlebar = MacosTitlebar(color: color);
      expect(titlebar.color, equals(color));
    });

    test('can be const constructed', () {
      const titlebar = MacosTitlebar(color: Color(0xFF00FF00));
      expect(titlebar, isNotNull);
    });

    test('can have a key', () {
      final key = UniqueKey();
      final titlebar = MacosTitlebar(key: key, color: const Color(0xFF0000FF));
      expect(titlebar.key, equals(key));
    });
  });

  group('MacosTitlebar documentation', () {
    test('height constant matches typical macOS titlebar height', () {
      // macOS titlebars are typically 28 pixels
      // This ensures consistency with native macOS apps
      expect(kMacosTitlebarHeight, equals(28.0));
    });
  });
}
