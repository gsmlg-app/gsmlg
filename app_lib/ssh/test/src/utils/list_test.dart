import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/utils/list.dart';

void main() {
  group('randomBytes', () {
    test('generates correct length', () {
      expect(randomBytes(0).length, 0);
      expect(randomBytes(1).length, 1);
      expect(randomBytes(10).length, 10);
      expect(randomBytes(100).length, 100);
    });

    test('returns Uint8List', () {
      final result = randomBytes(10);
      expect(result, isA<Uint8List>());
    });

    test('generates values in byte range', () {
      final bytes = randomBytes(1000);
      for (final byte in bytes) {
        expect(byte, greaterThanOrEqualTo(0));
        expect(byte, lessThan(256));
      }
    });

    test('generates different results on multiple calls', () {
      // Note: There's a small chance this could fail due to randomness
      // but with 32 bytes, collision is extremely unlikely
      final bytes1 = randomBytes(32);
      final bytes2 = randomBytes(32);

      bool allEqual = true;
      for (int i = 0; i < bytes1.length; i++) {
        if (bytes1[i] != bytes2[i]) {
          allEqual = false;
          break;
        }
      }
      expect(allEqual, isFalse);
    });

    test('handles zero length', () {
      final bytes = randomBytes(0);
      expect(bytes.isEmpty, isTrue);
    });
  });

  group('ListX.equals', () {
    group('with int lists', () {
      test('returns true for identical lists', () {
        final list1 = [1, 2, 3];
        final list2 = [1, 2, 3];
        expect(list1.equals(list2), isTrue);
      });

      test('returns false for different lengths', () {
        final list1 = [1, 2, 3];
        final list2 = [1, 2];
        expect(list1.equals(list2), isFalse);
      });

      test('returns false for different elements', () {
        final list1 = [1, 2, 3];
        final list2 = [1, 2, 4];
        expect(list1.equals(list2), isFalse);
      });

      test('returns true for empty lists', () {
        final list1 = <int>[];
        final list2 = <int>[];
        expect(list1.equals(list2), isTrue);
      });

      test('returns true for single element lists', () {
        final list1 = [42];
        final list2 = [42];
        expect(list1.equals(list2), isTrue);
      });

      test('returns false for same length different order', () {
        final list1 = [1, 2, 3];
        final list2 = [3, 2, 1];
        expect(list1.equals(list2), isFalse);
      });
    });

    group('with String lists', () {
      test('returns true for equal string lists', () {
        final list1 = ['a', 'b', 'c'];
        final list2 = ['a', 'b', 'c'];
        expect(list1.equals(list2), isTrue);
      });

      test('returns false for different string lists', () {
        final list1 = ['a', 'b', 'c'];
        final list2 = ['a', 'b', 'd'];
        expect(list1.equals(list2), isFalse);
      });
    });

    group('with Uint8List', () {
      test('returns true for equal byte arrays', () {
        final list1 = Uint8List.fromList([0x01, 0x02, 0x03]);
        final list2 = Uint8List.fromList([0x01, 0x02, 0x03]);
        expect(list1.equals(list2), isTrue);
      });

      test('returns false for different byte arrays', () {
        final list1 = Uint8List.fromList([0x01, 0x02, 0x03]);
        final list2 = Uint8List.fromList([0x01, 0x02, 0x04]);
        expect(list1.equals(list2), isFalse);
      });

      test('compares with regular List<int>', () {
        final uint8list = Uint8List.fromList([1, 2, 3]);
        final regularList = [1, 2, 3];
        expect(uint8list.equals(regularList), isTrue);
      });
    });

    group('with nullable types', () {
      test('returns true for equal nullable lists', () {
        final list1 = <int?>[1, null, 3];
        final list2 = <int?>[1, null, 3];
        expect(list1.equals(list2), isTrue);
      });

      test('returns false for different null positions', () {
        final list1 = <int?>[1, null, 3];
        final list2 = <int?>[null, 1, 3];
        expect(list1.equals(list2), isFalse);
      });
    });

    group('edge cases', () {
      test('same object reference returns true', () {
        final list = [1, 2, 3];
        expect(list.equals(list), isTrue);
      });

      test('first element different', () {
        final list1 = [1, 2, 3];
        final list2 = [0, 2, 3];
        expect(list1.equals(list2), isFalse);
      });

      test('last element different', () {
        final list1 = [1, 2, 3];
        final list2 = [1, 2, 4];
        expect(list1.equals(list2), isFalse);
      });

      test('middle element different', () {
        final list1 = [1, 2, 3, 4, 5];
        final list2 = [1, 2, 0, 4, 5];
        expect(list1.equals(list2), isFalse);
      });

      test('large equal lists', () {
        final list1 = List.generate(1000, (i) => i);
        final list2 = List.generate(1000, (i) => i);
        expect(list1.equals(list2), isTrue);
      });

      test('large lists with one difference', () {
        final list1 = List.generate(1000, (i) => i);
        final list2 = List.generate(1000, (i) => i == 500 ? 999 : i);
        expect(list1.equals(list2), isFalse);
      });
    });

    group('real-world scenarios', () {
      test('comparing byte buffers for equality', () {
        final buffer1 = Uint8List.fromList([0x00, 0x00, 0x00, 0x05]);
        final buffer2 = Uint8List.fromList([0x00, 0x00, 0x00, 0x05]);
        final buffer3 = Uint8List.fromList([0x00, 0x00, 0x00, 0x06]);

        expect(buffer1.equals(buffer2), isTrue);
        expect(buffer1.equals(buffer3), isFalse);
      });

      test('comparing protocol headers', () {
        final header1 = [0x53, 0x53, 0x48, 0x2D]; // "SSH-"
        final header2 = [0x53, 0x53, 0x48, 0x2D];
        final wrongHeader = [0x48, 0x54, 0x54, 0x50]; // "HTTP"

        expect(header1.equals(header2), isTrue);
        expect(header1.equals(wrongHeader), isFalse);
      });
    });
  });
}
