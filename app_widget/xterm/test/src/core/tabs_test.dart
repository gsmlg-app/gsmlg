import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/src/core/tabs.dart';

void main() {
  group('TabStops', () {
    group('construction', () {
      test('has default tab stops after created', () {
        final tabStops = TabStops();

        expect(tabStops.isSetAt(0), true);
        expect(tabStops.isSetAt(1), false);
        expect(tabStops.isSetAt(7), false);
        expect(tabStops.isSetAt(8), true);
        expect(tabStops.isSetAt(9), false);
        expect(tabStops.isSetAt(15), false);
        expect(tabStops.isSetAt(16), true);
      });

      test('has default tab stops at 8 column intervals', () {
        final tabStops = TabStops();

        // Check first several default tab stops
        expect(tabStops.isSetAt(0), true);
        expect(tabStops.isSetAt(8), true);
        expect(tabStops.isSetAt(16), true);
        expect(tabStops.isSetAt(24), true);
        expect(tabStops.isSetAt(32), true);
        expect(tabStops.isSetAt(40), true);
      });

      test('positions between tab stops are not set', () {
        final tabStops = TabStops();

        for (int i = 1; i < 8; i++) {
          expect(tabStops.isSetAt(i), false);
        }
        for (int i = 9; i < 16; i++) {
          expect(tabStops.isSetAt(i), false);
        }
      });
    });

    group('isSetAt()', () {
      test('returns true for positions with tab stops', () {
        final tabStops = TabStops();
        expect(tabStops.isSetAt(0), true);
        expect(tabStops.isSetAt(8), true);
        expect(tabStops.isSetAt(16), true);
      });

      test('returns false for positions without tab stops', () {
        final tabStops = TabStops();
        expect(tabStops.isSetAt(1), false);
        expect(tabStops.isSetAt(5), false);
        expect(tabStops.isSetAt(10), false);
      });
    });

    group('setAt()', () {
      test('sets a tab stop at the specified index', () {
        final tabStops = TabStops();
        expect(tabStops.isSetAt(5), false);

        tabStops.setAt(5);
        expect(tabStops.isSetAt(5), true);
      });

      test('setting an already set tab stop does nothing', () {
        final tabStops = TabStops();
        expect(tabStops.isSetAt(0), true);

        tabStops.setAt(0);
        expect(tabStops.isSetAt(0), true);
      });

      test('can set multiple custom tab stops', () {
        final tabStops = TabStops();

        tabStops.setAt(3);
        tabStops.setAt(7);
        tabStops.setAt(11);

        expect(tabStops.isSetAt(3), true);
        expect(tabStops.isSetAt(7), true);
        expect(tabStops.isSetAt(11), true);
      });
    });

    group('clearAt()', () {
      test('clears a tab stop at the specified index', () {
        final tabStops = TabStops();
        expect(tabStops.isSetAt(8), true);

        tabStops.clearAt(8);
        expect(tabStops.isSetAt(8), false);
      });

      test('clearing an already cleared position does nothing', () {
        final tabStops = TabStops();
        expect(tabStops.isSetAt(5), false);

        tabStops.clearAt(5);
        expect(tabStops.isSetAt(5), false);
      });

      test('can clear the first tab stop', () {
        final tabStops = TabStops();
        expect(tabStops.isSetAt(0), true);

        tabStops.clearAt(0);
        expect(tabStops.isSetAt(0), false);
      });
    });

    group('clearAll()', () {
      test('clears all tab stops', () {
        final tabStops = TabStops();

        tabStops.clearAll();

        expect(tabStops.isSetAt(0), false);
        expect(tabStops.isSetAt(8), false);
        expect(tabStops.isSetAt(16), false);
        expect(tabStops.isSetAt(24), false);
      });

      test('clearAll then setAt works correctly', () {
        final tabStops = TabStops();

        tabStops.clearAll();
        tabStops.setAt(5);

        expect(tabStops.isSetAt(0), false);
        expect(tabStops.isSetAt(5), true);
        expect(tabStops.isSetAt(8), false);
      });
    });

    group('reset()', () {
      test('resets tab stops to default 8 column intervals', () {
        final tabStops = TabStops();

        // Modify tab stops
        tabStops.clearAt(8);
        tabStops.setAt(5);

        // Reset to defaults
        tabStops.reset();

        // Check defaults are restored
        expect(tabStops.isSetAt(0), true);
        expect(tabStops.isSetAt(5), false);
        expect(tabStops.isSetAt(8), true);
        expect(tabStops.isSetAt(16), true);
      });

      test('reset after clearAll restores defaults', () {
        final tabStops = TabStops();

        tabStops.clearAll();
        expect(tabStops.isSetAt(0), false);
        expect(tabStops.isSetAt(8), false);

        tabStops.reset();
        expect(tabStops.isSetAt(0), true);
        expect(tabStops.isSetAt(8), true);
      });
    });

    group('find()', () {
      test('includes start', () {
        final tabStops = TabStops();
        expect(tabStops.find(0, 10), 0);
      });

      test('excludes end', () {
        final tabStops = TabStops();
        expect(tabStops.find(0, 8), 0);
        expect(tabStops.find(1, 9), 8);
      });

      test('returns null when no tab stop in range', () {
        final tabStops = TabStops();
        expect(tabStops.find(1, 8), null);
        expect(tabStops.find(9, 16), null);
      });

      test('returns null when start >= end', () {
        final tabStops = TabStops();
        expect(tabStops.find(10, 10), null);
        expect(tabStops.find(10, 5), null);
      });

      test('finds tab stop at start of range', () {
        final tabStops = TabStops();
        expect(tabStops.find(8, 20), 8);
      });

      test('finds first tab stop in larger range', () {
        final tabStops = TabStops();
        expect(tabStops.find(0, 100), 0);
        expect(tabStops.find(1, 100), 8);
        expect(tabStops.find(9, 100), 16);
      });

      test('finds custom tab stop', () {
        final tabStops = TabStops();
        tabStops.setAt(5);

        expect(tabStops.find(1, 10), 5);
      });

      test('returns null after clearAll', () {
        final tabStops = TabStops();
        tabStops.clearAll();

        expect(tabStops.find(0, 100), null);
      });
    });

    group('edge cases', () {
      test('handles high column indices', () {
        final tabStops = TabStops();

        // Tab stops should exist at high intervals
        expect(tabStops.isSetAt(80), true);
        expect(tabStops.isSetAt(160), true);
        expect(tabStops.isSetAt(800), true);
      });

      test('can set and clear tab stop at position 0', () {
        final tabStops = TabStops();

        tabStops.clearAt(0);
        expect(tabStops.isSetAt(0), false);

        tabStops.setAt(0);
        expect(tabStops.isSetAt(0), true);
      });
    });
  });
}
