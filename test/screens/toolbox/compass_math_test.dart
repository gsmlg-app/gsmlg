import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/compass/compass_math.dart';

void main() {
  test('normalizes headings and never displays 360 degrees', () {
    expect(normalizeHeading(-1), 359);
    expect(normalizeHeading(721), 1);
    expect(roundedCompassHeading(359.6), 0);
    expect(roundedCompassHeading(128.4), 128);
  });

  test('eight direction sectors include their lower boundary', () {
    for (final entry in <double, int>{
      0: 0,
      22.49: 0,
      22.5: 1,
      67.5: 2,
      337.5: 0,
      359.6: 0,
      112.5: 3,
      157.5: 4,
      202.5: 5,
      247.5: 6,
      292.5: 7,
    }.entries) {
      expect(compassDirectionIndex(entry.key), entry.value);
    }
  });

  test('crossing north takes the shortest path', () {
    expect(shortestHeadingDelta(359, 0), 1);
    expect(shortestHeadingDelta(0, 359), -1);
    expect(shortestHeadingDelta(10, 350), -20);
    expect(shortestHeadingDelta(350, 10), 20);
  });
}
