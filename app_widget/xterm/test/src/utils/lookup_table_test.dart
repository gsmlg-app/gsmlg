import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/src/utils/lookup_table.dart';

void main() {
  group('FastLookupTable', () {
    group('constructor', () {
      test('creates table from single-entry map', () {
        final table = FastLookupTable<String>({0: 'zero'});
        expect(table[0], 'zero');
        expect(table.maxIndex, 0);
      });

      test('creates table from multi-entry map', () {
        final table = FastLookupTable<String>({
          0: 'zero',
          1: 'one',
          2: 'two',
        });
        expect(table[0], 'zero');
        expect(table[1], 'one');
        expect(table[2], 'two');
        expect(table.maxIndex, 2);
      });

      test('creates table with sparse keys', () {
        final table = FastLookupTable<String>({
          0: 'zero',
          5: 'five',
          10: 'ten',
        });
        expect(table[0], 'zero');
        expect(table[5], 'five');
        expect(table[10], 'ten');
        expect(table.maxIndex, 10);
      });

      test('sets maxIndex to highest key', () {
        final table = FastLookupTable<int>({
          3: 100,
          7: 200,
          15: 300,
        });
        expect(table.maxIndex, 15);
      });

      test('handles non-sequential keys', () {
        final table = FastLookupTable<String>({
          100: 'hundred',
          50: 'fifty',
          75: 'seventy-five',
        });
        expect(table[100], 'hundred');
        expect(table[50], 'fifty');
        expect(table[75], 'seventy-five');
        expect(table.maxIndex, 100);
      });
    });

    group('index operator', () {
      late FastLookupTable<String> table;

      setUp(() {
        table = FastLookupTable<String>({
          0: 'zero',
          2: 'two',
          5: 'five',
        });
      });

      test('returns value for existing key', () {
        expect(table[0], 'zero');
        expect(table[2], 'two');
        expect(table[5], 'five');
      });

      test('returns null for non-existent key within range', () {
        expect(table[1], isNull);
        expect(table[3], isNull);
        expect(table[4], isNull);
      });

      test('returns null for index beyond maxIndex', () {
        expect(table[6], isNull);
        expect(table[10], isNull);
        expect(table[100], isNull);
      });

      test('returns null for very large index', () {
        expect(table[999999], isNull);
      });
    });

    group('maxIndex', () {
      test('returns correct maxIndex for single entry', () {
        final table = FastLookupTable<int>({5: 100});
        expect(table.maxIndex, 5);
      });

      test('returns correct maxIndex for multiple entries', () {
        final table = FastLookupTable<int>({
          1: 10,
          3: 30,
          7: 70,
        });
        expect(table.maxIndex, 7);
      });

      test('returns zero when only key is zero', () {
        final table = FastLookupTable<String>({0: 'only'});
        expect(table.maxIndex, 0);
      });
    });

    group('type handling', () {
      test('works with int values', () {
        final table = FastLookupTable<int>({
          0: 100,
          1: 200,
          2: 300,
        });
        expect(table[0], 100);
        expect(table[1], 200);
        expect(table[2], 300);
      });

      test('works with double values', () {
        final table = FastLookupTable<double>({
          0: 1.5,
          1: 2.5,
          2: 3.5,
        });
        expect(table[0], 1.5);
        expect(table[1], 2.5);
        expect(table[2], 3.5);
      });

      test('works with bool values', () {
        final table = FastLookupTable<bool>({
          0: true,
          1: false,
          2: true,
        });
        expect(table[0], true);
        expect(table[1], false);
        expect(table[2], true);
      });

      test('works with list values', () {
        final table = FastLookupTable<List<int>>({
          0: [1, 2, 3],
          1: [4, 5, 6],
        });
        expect(table[0], [1, 2, 3]);
        expect(table[1], [4, 5, 6]);
      });

      test('works with nullable type', () {
        final table = FastLookupTable<String?>({
          0: 'value',
          1: null,
          2: 'another',
        });
        expect(table[0], 'value');
        expect(table[1], isNull);
        expect(table[2], 'another');
      });
    });

    group('edge cases', () {
      test('handles large sparse table', () {
        final table = FastLookupTable<String>({
          0: 'start',
          1000: 'end',
        });
        expect(table[0], 'start');
        expect(table[500], isNull);
        expect(table[1000], 'end');
        expect(table.maxIndex, 1000);
      });

      test('handles consecutive keys', () {
        final table = FastLookupTable<int>({
          for (final i in List.generate(100, (i) => i)) i: i * 10,
        });
        expect(table[0], 0);
        expect(table[50], 500);
        expect(table[99], 990);
        expect(table.maxIndex, 99);
      });

      test('handles function values', () {
        final table = FastLookupTable<int Function(int)>({
          0: (x) => x * 2,
          1: (x) => x + 10,
        });
        expect(table[0]!(5), 10);
        expect(table[1]!(5), 15);
      });
    });

    group('real-world use cases', () {
      test('character code lookup table', () {
        // Simulating a character classification table
        final table = FastLookupTable<String>({
          65: 'uppercase', // 'A'
          66: 'uppercase', // 'B'
          97: 'lowercase', // 'a'
          98: 'lowercase', // 'b'
          48: 'digit', // '0'
          49: 'digit', // '1'
        });

        expect(table['A'.codeUnitAt(0)], 'uppercase');
        expect(table['a'.codeUnitAt(0)], 'lowercase');
        expect(table['0'.codeUnitAt(0)], 'digit');
        expect(table[' '.codeUnitAt(0)], isNull); // space not in table
      });

      test('escape sequence lookup', () {
        // Simulating terminal escape sequence handling
        final table = FastLookupTable<String>({
          0x1B: 'escape',
          0x0A: 'newline',
          0x0D: 'carriage-return',
          0x09: 'tab',
          0x08: 'backspace',
        });

        expect(table[0x1B], 'escape');
        expect(table[0x0A], 'newline');
        expect(table[0x20], isNull); // space not defined
      });
    });
  });
}
