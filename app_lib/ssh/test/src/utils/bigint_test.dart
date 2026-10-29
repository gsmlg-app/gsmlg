import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/utils/bigint.dart';

void main() {
  group('decodeBigIntWithSign', () {
    group('with sign == 0', () {
      test('returns zero regardless of magnitude', () {
        expect(decodeBigIntWithSign(0, [1, 2, 3]), BigInt.zero);
        expect(decodeBigIntWithSign(0, [255]), BigInt.zero);
        expect(decodeBigIntWithSign(0, [0]), BigInt.zero);
        expect(decodeBigIntWithSign(0, []), BigInt.zero);
      });
    });

    group('with positive sign', () {
      test('decodes single byte', () {
        expect(decodeBigIntWithSign(1, [0]), BigInt.zero);
        expect(decodeBigIntWithSign(1, [1]), BigInt.one);
        expect(decodeBigIntWithSign(1, [255]), BigInt.from(255));
      });

      test('decodes two bytes big-endian', () {
        // 0x0100 = 256
        expect(decodeBigIntWithSign(1, [0x01, 0x00]), BigInt.from(256));
        // 0x0102 = 258
        expect(decodeBigIntWithSign(1, [0x01, 0x02]), BigInt.from(258));
        // 0xFFFF = 65535
        expect(decodeBigIntWithSign(1, [0xFF, 0xFF]), BigInt.from(65535));
      });

      test('decodes four bytes big-endian', () {
        // 0x01020304 = 16909060
        expect(
          decodeBigIntWithSign(1, [0x01, 0x02, 0x03, 0x04]),
          BigInt.from(16909060),
        );
      });

      test('decodes large numbers', () {
        // 256^4 = 4294967296
        expect(
          decodeBigIntWithSign(1, [0x01, 0x00, 0x00, 0x00, 0x00]),
          BigInt.from(4294967296),
        );
      });
    });

    group('with negative sign', () {
      test('decodes negative single byte', () {
        final result = decodeBigIntWithSign(-1, [1]);
        expect(result.isNegative, isTrue);
      });

      test('decodes negative multi-byte', () {
        final result = decodeBigIntWithSign(-1, [0x01, 0x00]);
        expect(result.isNegative, isTrue);
      });
    });

    group('edge cases', () {
      test('empty magnitude with positive sign', () {
        final result = decodeBigIntWithSign(1, []);
        expect(result, BigInt.zero);
      });

      test('single zero byte', () {
        expect(decodeBigIntWithSign(1, [0]), BigInt.zero);
      });

      test('leading zeros do not affect value', () {
        // 0x000001 should equal 1
        expect(
          decodeBigIntWithSign(1, [0x00, 0x00, 0x01]),
          BigInt.from(1),
        );
      });
    });
  });

  group('encodeBigInt', () {
    test('encodes zero', () {
      final result = encodeBigInt(BigInt.zero);
      expect(result, Uint8List.fromList([0]));
    });

    test('encodes one', () {
      final result = encodeBigInt(BigInt.one);
      expect(result, Uint8List.fromList([1]));
    });

    test('encodes 127 (max positive single byte without padding)', () {
      final result = encodeBigInt(BigInt.from(127));
      expect(result, Uint8List.fromList([127]));
    });

    test('encodes 128 (requires padding byte)', () {
      // 128 = 0x80, needs padding because high bit is set
      final result = encodeBigInt(BigInt.from(128));
      expect(result, Uint8List.fromList([0x00, 0x80]));
    });

    test('encodes 255 (requires padding byte)', () {
      // 255 = 0xFF, needs padding
      final result = encodeBigInt(BigInt.from(255));
      expect(result, Uint8List.fromList([0x00, 0xFF]));
    });

    test('encodes 256', () {
      // 256 = 0x0100
      final result = encodeBigInt(BigInt.from(256));
      expect(result, Uint8List.fromList([0x01, 0x00]));
    });

    test('encodes larger numbers', () {
      // 65535 = 0xFFFF, needs padding
      final result = encodeBigInt(BigInt.from(65535));
      expect(result, Uint8List.fromList([0x00, 0xFF, 0xFF]));
    });

    test('encodes power of 256', () {
      // 65536 = 0x010000
      final result = encodeBigInt(BigInt.from(65536));
      expect(result, Uint8List.fromList([0x01, 0x00, 0x00]));
    });

    group('negative numbers', () {
      test('encodes -1', () {
        final result = encodeBigInt(BigInt.from(-1));
        expect(result, Uint8List.fromList([0xFF]));
      });

      test('encodes -128', () {
        final result = encodeBigInt(BigInt.from(-128));
        expect(result, Uint8List.fromList([0x80]));
      });

      test('encodes -129', () {
        final result = encodeBigInt(BigInt.from(-129));
        expect(result, Uint8List.fromList([0xFF, 0x7F]));
      });
    });
  });

  group('encodeBigIntAsUnsigned', () {
    test('encodes zero', () {
      final result = encodeBigIntAsUnsigned(BigInt.zero);
      expect(result, Uint8List.fromList([0]));
    });

    test('encodes one', () {
      final result = encodeBigIntAsUnsigned(BigInt.one);
      expect(result, Uint8List.fromList([1]));
    });

    test('encodes 128 without padding', () {
      final result = encodeBigIntAsUnsigned(BigInt.from(128));
      expect(result, Uint8List.fromList([0x80]));
    });

    test('encodes 255 without padding', () {
      final result = encodeBigIntAsUnsigned(BigInt.from(255));
      expect(result, Uint8List.fromList([0xFF]));
    });

    test('encodes 256', () {
      final result = encodeBigIntAsUnsigned(BigInt.from(256));
      expect(result, Uint8List.fromList([0x01, 0x00]));
    });

    test('encodes 65535', () {
      final result = encodeBigIntAsUnsigned(BigInt.from(65535));
      expect(result, Uint8List.fromList([0xFF, 0xFF]));
    });

    test('encodes large numbers', () {
      // 0x123456789ABCDEF
      final bigNum = BigInt.parse('123456789ABCDEF', radix: 16);
      final result = encodeBigIntAsUnsigned(bigNum);
      expect(result,
          Uint8List.fromList([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF]));
    });
  });

  group('roundtrip tests', () {
    test('encode then decode positive numbers', () {
      final testValues = [
        BigInt.zero,
        BigInt.one,
        BigInt.from(127),
        BigInt.from(128),
        BigInt.from(255),
        BigInt.from(256),
        BigInt.from(65535),
        BigInt.from(65536),
        BigInt.parse('FFFFFFFF', radix: 16),
      ];

      for (final value in testValues) {
        final encoded = encodeBigInt(value);
        final decoded = decodeBigIntWithSign(
          value.isNegative ? -1 : (value == BigInt.zero ? 0 : 1),
          encoded,
        );
        expect(decoded, value, reason: 'Failed for $value');
      }
    });

    test('encode unsigned then decode', () {
      final testValues = [
        BigInt.zero,
        BigInt.one,
        BigInt.from(128),
        BigInt.from(255),
        BigInt.from(256),
        BigInt.from(65535),
      ];

      for (final value in testValues) {
        final encoded = encodeBigIntAsUnsigned(value);
        final decoded = decodeBigIntWithSign(
          value == BigInt.zero ? 0 : 1,
          encoded,
        );
        expect(decoded, value, reason: 'Failed for $value');
      }
    });
  });

  group('real-world scenarios', () {
    test('SSH RSA public exponent encoding', () {
      // Common RSA public exponent: 65537
      final e = BigInt.from(65537);
      final encoded = encodeBigInt(e);
      expect(encoded, Uint8List.fromList([0x01, 0x00, 0x01]));
    });

    test('decoding SSH mpint format', () {
      // SSH mpint for 256 (0x100) would be [0x01, 0x00]
      final decoded = decodeBigIntWithSign(1, [0x01, 0x00]);
      expect(decoded, BigInt.from(256));
    });
  });
}
