import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/src/core/buffer/cell_offset.dart';

void main() {
  group('CellOffset', () {
    group('constructor', () {
      test('creates offset with x and y', () {
        const offset = CellOffset(10, 20);
        expect(offset.x, 10);
        expect(offset.y, 20);
      });

      test('creates offset with zero values', () {
        const offset = CellOffset(0, 0);
        expect(offset.x, 0);
        expect(offset.y, 0);
      });

      test('creates offset with negative values', () {
        const offset = CellOffset(-5, -10);
        expect(offset.x, -5);
        expect(offset.y, -10);
      });

      test('creates offset with large values', () {
        const offset = CellOffset(10000, 50000);
        expect(offset.x, 10000);
        expect(offset.y, 50000);
      });

      test('is const constructible', () {
        // Verify const works
        const offset1 = CellOffset(1, 2);
        const offset2 = CellOffset(1, 2);
        expect(identical(offset1, offset2), isTrue);
      });
    });

    group('isEqual', () {
      test('returns true for same coordinates', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(5, 10);
        expect(offset1.isEqual(offset2), isTrue);
      });

      test('returns false for different x', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(6, 10);
        expect(offset1.isEqual(offset2), isFalse);
      });

      test('returns false for different y', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(5, 11);
        expect(offset1.isEqual(offset2), isFalse);
      });

      test('returns false for completely different coordinates', () {
        const offset1 = CellOffset(0, 0);
        const offset2 = CellOffset(100, 100);
        expect(offset1.isEqual(offset2), isFalse);
      });
    });

    group('isBefore', () {
      test('returns true when y is smaller', () {
        const offset1 = CellOffset(50, 5);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBefore(offset2), isTrue);
      });

      test('returns true when same y but x is smaller', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBefore(offset2), isTrue);
      });

      test('returns false when y is larger', () {
        const offset1 = CellOffset(5, 15);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBefore(offset2), isFalse);
      });

      test('returns false when same y but x is larger', () {
        const offset1 = CellOffset(15, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBefore(offset2), isFalse);
      });

      test('returns false when equal', () {
        const offset1 = CellOffset(10, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBefore(offset2), isFalse);
      });
    });

    group('isAfter', () {
      test('returns true when y is larger', () {
        const offset1 = CellOffset(5, 15);
        const offset2 = CellOffset(50, 10);
        expect(offset1.isAfter(offset2), isTrue);
      });

      test('returns true when same y but x is larger', () {
        const offset1 = CellOffset(15, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAfter(offset2), isTrue);
      });

      test('returns false when y is smaller', () {
        const offset1 = CellOffset(50, 5);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAfter(offset2), isFalse);
      });

      test('returns false when same y but x is smaller', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAfter(offset2), isFalse);
      });

      test('returns false when equal', () {
        const offset1 = CellOffset(10, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAfter(offset2), isFalse);
      });
    });

    group('isBeforeOrSame', () {
      test('returns true when before', () {
        const offset1 = CellOffset(5, 5);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBeforeOrSame(offset2), isTrue);
      });

      test('returns true when equal', () {
        const offset1 = CellOffset(10, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBeforeOrSame(offset2), isTrue);
      });

      test('returns false when after', () {
        const offset1 = CellOffset(15, 15);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBeforeOrSame(offset2), isFalse);
      });

      test('returns true when same row but x is less or equal', () {
        const offset1 = CellOffset(10, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isBeforeOrSame(offset2), isTrue);

        const offset3 = CellOffset(5, 10);
        expect(offset3.isBeforeOrSame(offset2), isTrue);
      });
    });

    group('isAfterOrSame', () {
      test('returns true when after', () {
        const offset1 = CellOffset(15, 15);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAfterOrSame(offset2), isTrue);
      });

      test('returns true when equal', () {
        const offset1 = CellOffset(10, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAfterOrSame(offset2), isTrue);
      });

      test('returns false when before', () {
        const offset1 = CellOffset(5, 5);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAfterOrSame(offset2), isFalse);
      });

      test('returns true when same row but x is greater or equal', () {
        const offset1 = CellOffset(10, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAfterOrSame(offset2), isTrue);

        const offset3 = CellOffset(15, 10);
        expect(offset3.isAfterOrSame(offset2), isTrue);
      });
    });

    group('isAtSameRow', () {
      test('returns true when y is same', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(100, 10);
        expect(offset1.isAtSameRow(offset2), isTrue);
      });

      test('returns false when y is different', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(5, 11);
        expect(offset1.isAtSameRow(offset2), isFalse);
      });

      test('returns true when exactly same position', () {
        const offset1 = CellOffset(10, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAtSameRow(offset2), isTrue);
      });
    });

    group('isAtSameColumn', () {
      test('returns true when x is same', () {
        const offset1 = CellOffset(10, 5);
        const offset2 = CellOffset(10, 100);
        expect(offset1.isAtSameColumn(offset2), isTrue);
      });

      test('returns false when x is different', () {
        const offset1 = CellOffset(10, 5);
        const offset2 = CellOffset(11, 5);
        expect(offset1.isAtSameColumn(offset2), isFalse);
      });

      test('returns true when exactly same position', () {
        const offset1 = CellOffset(10, 10);
        const offset2 = CellOffset(10, 10);
        expect(offset1.isAtSameColumn(offset2), isTrue);
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        const offset = CellOffset(5, 10);
        expect(offset.toString(), 'CellOffset(5, 10)');
      });

      test('handles zero values', () {
        const offset = CellOffset(0, 0);
        expect(offset.toString(), 'CellOffset(0, 0)');
      });

      test('handles negative values', () {
        const offset = CellOffset(-5, -10);
        expect(offset.toString(), 'CellOffset(-5, -10)');
      });
    });

    group('equality', () {
      test('== returns true for same coordinates', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(5, 10);
        expect(offset1 == offset2, isTrue);
      });

      test('== returns false for different coordinates', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(5, 11);
        expect(offset1 == offset2, isFalse);
      });

      test('== returns false for non-CellOffset', () {
        const offset = CellOffset(5, 10);
        // Using dynamic to test runtime behavior with different types
        final dynamic stringValue = 'not a cell offset';
        final dynamic intValue = 5;
        final dynamic nullValue = null;
        expect(offset == stringValue, isFalse);
        expect(offset == intValue, isFalse);
        expect(offset == nullValue, isFalse);
      });

      test('identical returns true for same const instance', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(5, 10);
        expect(identical(offset1, offset2), isTrue);
      });
    });

    group('hashCode', () {
      test('same for equal offsets', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(5, 10);
        expect(offset1.hashCode, offset2.hashCode);
      });

      test('typically different for different offsets', () {
        const offset1 = CellOffset(5, 10);
        const offset2 = CellOffset(15, 20);
        // Note: hash collisions are possible; using values that are unlikely to collide
        expect(offset1.hashCode, isNot(offset2.hashCode));
      });

      test('works in Set', () {
        // Test that duplicates are correctly handled when using addAll
        final set = <CellOffset>{};
        set.addAll([
          const CellOffset(0, 0),
          const CellOffset(1, 1),
          const CellOffset(0, 0), // duplicate - will be deduplicated by addAll
        ]);
        expect(set.length, 2);
      });

      test('works as Map key', () {
        final map = <CellOffset, String>{
          const CellOffset(0, 0): 'origin',
          const CellOffset(1, 1): 'diagonal',
        };
        expect(map[const CellOffset(0, 0)], 'origin');
        expect(map[const CellOffset(1, 1)], 'diagonal');
        expect(map[const CellOffset(2, 2)], isNull);
      });
    });

    group('ordering consistency', () {
      test('isBefore and isAfter are inverses', () {
        const offset1 = CellOffset(5, 5);
        const offset2 = CellOffset(10, 10);

        expect(offset1.isBefore(offset2), isTrue);
        expect(offset2.isAfter(offset1), isTrue);
        expect(offset1.isAfter(offset2), isFalse);
        expect(offset2.isBefore(offset1), isFalse);
      });

      test('exactly one of isBefore, isAfter, isEqual is true', () {
        const offsets = [
          CellOffset(0, 0),
          CellOffset(5, 0),
          CellOffset(0, 5),
          CellOffset(5, 5),
        ];

        for (final a in offsets) {
          for (final b in offsets) {
            final before = a.isBefore(b);
            final after = a.isAfter(b);
            final equal = a.isEqual(b);

            // Exactly one should be true
            final trueCount = [before, after, equal].where((b) => b).length;
            expect(trueCount, 1, reason: 'For $a vs $b');
          }
        }
      });

      test('isBeforeOrSame == isBefore || isEqual', () {
        const offset1 = CellOffset(5, 5);
        const offset2 = CellOffset(10, 10);
        const offset3 = CellOffset(5, 5);

        expect(
          offset1.isBeforeOrSame(offset2),
          offset1.isBefore(offset2) || offset1.isEqual(offset2),
        );
        expect(
          offset1.isBeforeOrSame(offset3),
          offset1.isBefore(offset3) || offset1.isEqual(offset3),
        );
      });

      test('isAfterOrSame == isAfter || isEqual', () {
        const offset1 = CellOffset(5, 5);
        const offset2 = CellOffset(10, 10);
        const offset3 = CellOffset(5, 5);

        expect(
          offset2.isAfterOrSame(offset1),
          offset2.isAfter(offset1) || offset2.isEqual(offset1),
        );
        expect(
          offset1.isAfterOrSame(offset3),
          offset1.isAfter(offset3) || offset1.isEqual(offset3),
        );
      });
    });

    group('real-world scenarios', () {
      test('cursor position comparison', () {
        // Simulating cursor at row 5, column 10
        const cursor = CellOffset(10, 5);
        // Selection start at row 3, column 5
        const selectionStart = CellOffset(5, 3);
        // Selection end at row 7, column 15
        const selectionEnd = CellOffset(15, 7);

        // Cursor is after selection start
        expect(cursor.isAfter(selectionStart), isTrue);
        // Cursor is before selection end
        expect(cursor.isBefore(selectionEnd), isTrue);
        // Cursor is on a different row than start
        expect(cursor.isAtSameRow(selectionStart), isFalse);
      });

      test('line wrapping detection', () {
        // End of line at column 80
        const lineEnd = CellOffset(80, 10);
        // Next character position
        const nextChar = CellOffset(0, 11);

        // Next char is on a different row
        expect(lineEnd.isAtSameRow(nextChar), isFalse);
        // Next char is after line end (row-wise)
        expect(nextChar.isAfter(lineEnd), isTrue);
      });
    });
  });
}
