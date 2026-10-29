import 'package:test/test.dart';
import 'package:xterm/xterm.dart';

void main() {
  group('CellOffset', () {
    group('construction', () {
      test('stores x and y coordinates', () {
        final offset = CellOffset(5, 10);
        expect(offset.x, equals(5));
        expect(offset.y, equals(10));
      });

      test('can be constructed with zero coordinates', () {
        final offset = CellOffset(0, 0);
        expect(offset.x, equals(0));
        expect(offset.y, equals(0));
      });

      test('can be const constructed', () {
        const offset = CellOffset(3, 7);
        expect(offset.x, equals(3));
        expect(offset.y, equals(7));
      });
    });

    group('isEqual()', () {
      test('returns true for same coordinates', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 10);
        expect(a.isEqual(b), isTrue);
      });

      test('returns false for different x', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(6, 10);
        expect(a.isEqual(b), isFalse);
      });

      test('returns false for different y', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 11);
        expect(a.isEqual(b), isFalse);
      });
    });

    group('isBefore()', () {
      test('returns true when y is less', () {
        final a = CellOffset(10, 5);
        final b = CellOffset(0, 10);
        expect(a.isBefore(b), isTrue);
      });

      test('returns true when same y but x is less', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(10, 10);
        expect(a.isBefore(b), isTrue);
      });

      test('returns false when equal', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 10);
        expect(a.isBefore(b), isFalse);
      });

      test('returns false when after', () {
        final a = CellOffset(10, 10);
        final b = CellOffset(5, 10);
        expect(a.isBefore(b), isFalse);
      });
    });

    group('isAfter()', () {
      test('returns true when y is greater', () {
        final a = CellOffset(0, 15);
        final b = CellOffset(10, 10);
        expect(a.isAfter(b), isTrue);
      });

      test('returns true when same y but x is greater', () {
        final a = CellOffset(15, 10);
        final b = CellOffset(10, 10);
        expect(a.isAfter(b), isTrue);
      });

      test('returns false when equal', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 10);
        expect(a.isAfter(b), isFalse);
      });

      test('returns false when before', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(10, 10);
        expect(a.isAfter(b), isFalse);
      });
    });

    group('isBeforeOrSame()', () {
      test('returns true when before', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(10, 10);
        expect(a.isBeforeOrSame(b), isTrue);
      });

      test('returns true when equal', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 10);
        expect(a.isBeforeOrSame(b), isTrue);
      });

      test('returns false when after', () {
        final a = CellOffset(15, 10);
        final b = CellOffset(10, 10);
        expect(a.isBeforeOrSame(b), isFalse);
      });
    });

    group('isAfterOrSame()', () {
      test('returns true when after', () {
        final a = CellOffset(15, 10);
        final b = CellOffset(10, 10);
        expect(a.isAfterOrSame(b), isTrue);
      });

      test('returns true when equal', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 10);
        expect(a.isAfterOrSame(b), isTrue);
      });

      test('returns false when before', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(10, 10);
        expect(a.isAfterOrSame(b), isFalse);
      });
    });

    group('isAtSameRow()', () {
      test('returns true when same y', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(15, 10);
        expect(a.isAtSameRow(b), isTrue);
      });

      test('returns false when different y', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 11);
        expect(a.isAtSameRow(b), isFalse);
      });
    });

    group('isAtSameColumn()', () {
      test('returns true when same x', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 20);
        expect(a.isAtSameColumn(b), isTrue);
      });

      test('returns false when different x', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(6, 10);
        expect(a.isAtSameColumn(b), isFalse);
      });
    });

    group('toString()', () {
      test('returns formatted string', () {
        final offset = CellOffset(5, 10);
        expect(offset.toString(), equals('CellOffset(5, 10)'));
      });

      test('handles zero coordinates', () {
        final offset = CellOffset(0, 0);
        expect(offset.toString(), equals('CellOffset(0, 0)'));
      });
    });

    group('equality', () {
      test('== returns true for equal offsets', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 10);
        expect(a == b, isTrue);
      });

      test('== returns false for different offsets', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(6, 10);
        expect(a == b, isFalse);
      });

      test('hashCode is same for equal offsets', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(5, 10);
        expect(a.hashCode, equals(b.hashCode));
      });

      test('hashCode differs for different offsets', () {
        final a = CellOffset(5, 10);
        final b = CellOffset(6, 10);
        expect(a.hashCode, isNot(equals(b.hashCode)));
      });
    });
  });

  group('BufferSegment', () {
    group('isWithin() multi-line range', () {
      test('isWithin() works', () {
        final segments = BufferRangeLine(CellOffset(10, 10), CellOffset(10, 12))
            .toSegments()
            .toList();

        expect(segments[0].start, equals(10));
        expect(segments[0].end, null);
        expect(segments[0].isWithin(CellOffset(10, 10)), isTrue);
        expect(segments[0].isWithin(CellOffset(11, 10)), isTrue);
        expect(segments[0].isWithin(CellOffset(100, 10)), isTrue);
        expect(segments[0].isWithin(CellOffset(9, 10)), isFalse);

        expect(segments[1].start, null);
        expect(segments[1].end, null);
        expect(segments[1].isWithin(CellOffset(10, 11)), isTrue);
        expect(segments[1].isWithin(CellOffset(11, 11)), isTrue);
        expect(segments[1].isWithin(CellOffset(100, 11)), isTrue);
        expect(segments[1].isWithin(CellOffset(0, 11)), isTrue);

        expect(segments[2].start, null);
        expect(segments[2].end, 10);
        expect(segments[2].isWithin(CellOffset(0, 12)), isTrue);
        expect(segments[2].isWithin(CellOffset(10, 12)), isTrue);
        expect(segments[2].isWithin(CellOffset(11, 12)), isFalse);
      });
    });

    group('isWithin() single line', () {
      test('returns true for positions in range', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 10))
            .toSegments()
            .toList();

        expect(segments.length, equals(1));
        expect(segments[0].isWithin(CellOffset(5, 10)), isTrue);
        expect(segments[0].isWithin(CellOffset(10, 10)), isTrue);
        expect(segments[0].isWithin(CellOffset(15, 10)), isTrue);
      });

      test('returns false for positions outside range', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 10))
            .toSegments()
            .toList();

        expect(segments[0].isWithin(CellOffset(4, 10)), isFalse);
        expect(segments[0].isWithin(CellOffset(16, 10)), isFalse);
      });

      test('returns false for wrong line', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 10))
            .toSegments()
            .toList();

        expect(segments[0].isWithin(CellOffset(10, 9)), isFalse);
        expect(segments[0].isWithin(CellOffset(10, 11)), isFalse);
      });
    });

    group('segment properties', () {
      test('first segment has start set', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(10, 12))
            .toSegments()
            .toList();

        expect(segments[0].start, equals(5));
      });

      test('last segment has end set', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12))
            .toSegments()
            .toList();

        expect(segments.last.end, equals(15));
      });

      test('middle segments have null start and end', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12))
            .toSegments()
            .toList();

        expect(segments[1].start, isNull);
        expect(segments[1].end, isNull);
      });

      test('single line segment has both start and end', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 10))
            .toSegments()
            .toList();

        expect(segments[0].start, equals(5));
        expect(segments[0].end, equals(15));
      });
    });

    group('toString()', () {
      test('formats segment correctly with start and end', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 10))
            .toSegments()
            .toList();

        expect(segments[0].toString(), equals('Segment(10, 5 -> 15)'));
      });

      test('formats segment correctly with null start', () {
        final segments = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12))
            .toSegments()
            .toList();

        expect(segments[1].toString(), equals('Segment(11, start -> end)'));
      });
    });

    group('equality', () {
      test('segments from same range are equal', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 10));
        final segments1 = range.toSegments().toList();
        final segments2 = range.toSegments().toList();

        expect(segments1[0] == segments2[0], isTrue);
      });

      test('hashCode is consistent', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 10));
        final segments1 = range.toSegments().toList();
        final segments2 = range.toSegments().toList();

        expect(segments1[0].hashCode, equals(segments2[0].hashCode));
      });
    });
  });

  group('BufferRangeLine', () {
    group('construction', () {
      test('stores begin and end', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(range.begin, equals(CellOffset(5, 10)));
        expect(range.end, equals(CellOffset(15, 12)));
      });
    });

    group('isNormalized', () {
      test('returns true when begin is before end', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(range.isNormalized, isTrue);
      });

      test('returns true when begin equals end', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(5, 10));
        expect(range.isNormalized, isTrue);
      });

      test('returns false when begin is after end', () {
        final range = BufferRangeLine(CellOffset(15, 12), CellOffset(5, 10));
        expect(range.isNormalized, isFalse);
      });
    });

    group('isCollapsed', () {
      test('returns true when begin equals end', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(5, 10));
        expect(range.isCollapsed, isTrue);
      });

      test('returns false when begin differs from end', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(6, 10));
        expect(range.isCollapsed, isFalse);
      });
    });

    group('contains()', () {
      test('returns true for position in range', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(range.contains(CellOffset(10, 11)), isTrue);
      });

      test('returns true for begin position', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(range.contains(CellOffset(5, 10)), isTrue);
      });

      test('returns true for end position', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(range.contains(CellOffset(15, 12)), isTrue);
      });

      test('returns false for position before range', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(range.contains(CellOffset(4, 10)), isFalse);
      });

      test('returns false for position after range', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(range.contains(CellOffset(16, 12)), isFalse);
      });
    });

    group('toSegments()', () {
      test('produces correct number of segments', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        final segments = range.toSegments().toList();
        expect(segments.length, equals(3)); // 3 lines: 10, 11, 12
      });

      test('single line produces one segment', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 10));
        final segments = range.toSegments().toList();
        expect(segments.length, equals(1));
      });
    });

    group('toString()', () {
      test('returns formatted string', () {
        final range = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(range.toString(),
            equals('Line Range(CellOffset(5, 10), CellOffset(15, 12))'));
      });
    });

    group('equality', () {
      test('ranges with same begin and end are equal', () {
        final a = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        final b = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(a == b, isTrue);
      });

      test('ranges with different begin are not equal', () {
        final a = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        final b = BufferRangeLine(CellOffset(6, 10), CellOffset(15, 12));
        expect(a == b, isFalse);
      });

      test('hashCode is consistent', () {
        final a = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        final b = BufferRangeLine(CellOffset(5, 10), CellOffset(15, 12));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
