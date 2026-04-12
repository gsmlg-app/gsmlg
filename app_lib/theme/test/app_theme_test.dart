import 'package:app_theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DmThemeData.themes has at least one entry', () {
    final themes = DmThemeData.themes;
    expect(themes.isNotEmpty, true);
    expect(themes.first.name, isNotEmpty);
  });

  test('Each theme entry has light and dark ThemeData', () {
    for (final entry in DmThemeData.themes) {
      expect(entry.light, isNotNull);
      expect(entry.dark, isNotNull);
    }
  });
}
