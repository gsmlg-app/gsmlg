import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/utils/int.dart';

void main() {
  group('IntX', () {
    group('toUint32', () {
      test('converts zero', () {
        expect(0.toUint32(), Uint8List.fromList([0x00, 0x00, 0x00, 0x00]));
      });

      test('converts 1 with big endian (default)', () {
        expect(1.toUint32(), Uint8List.fromList([0x00, 0x00, 0x00, 0x01]));
      });

      test('converts 1 with little endian', () {
        expect(
          1.toUint32(Endian.little),
          Uint8List.fromList([0x01, 0x00, 0x00, 0x00]),
        );
      });

      test('converts 256 with big endian', () {
        expect(256.toUint32(), Uint8List.fromList([0x00, 0x00, 0x01, 0x00]));
      });

      test('converts 256 with little endian', () {
        expect(
          256.toUint32(Endian.little),
          Uint8List.fromList([0x00, 0x01, 0x00, 0x00]),
        );
      });

      test('converts max uint32', () {
        const maxUint32 = 0xFFFFFFFF;
        expect(
          maxUint32.toUint32(),
          Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF]),
        );
      });

      test('converts 0x12345678 with big endian', () {
        expect(
          0x12345678.toUint32(),
          Uint8List.fromList([0x12, 0x34, 0x56, 0x78]),
        );
      });

      test('converts 0x12345678 with little endian', () {
        expect(
          0x12345678.toUint32(Endian.little),
          Uint8List.fromList([0x78, 0x56, 0x34, 0x12]),
        );
      });

      test('result has length 4', () {
        expect(42.toUint32().length, 4);
        expect(0.toUint32().length, 4);
        expect(0xFFFFFFFF.toUint32().length, 4);
      });
    });

    group('toUint64', () {
      test('converts zero', () {
        expect(
          0.toUint64(),
          Uint8List.fromList([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
        );
      });

      test('converts 1 with big endian (default)', () {
        expect(
          1.toUint64(),
          Uint8List.fromList([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]),
        );
      });

      test('converts 1 with little endian', () {
        expect(
          1.toUint64(Endian.little),
          Uint8List.fromList([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
        );
      });

      test('converts large number with big endian', () {
        // 0x123456789ABCDEF0
        const large = 0x123456789ABCDEF0;
        expect(
          large.toUint64(),
          Uint8List.fromList([0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0]),
        );
      });

      test('converts large number with little endian', () {
        const large = 0x123456789ABCDEF0;
        expect(
          large.toUint64(Endian.little),
          Uint8List.fromList([0xF0, 0xDE, 0xBC, 0x9A, 0x78, 0x56, 0x34, 0x12]),
        );
      });

      test('result has length 8', () {
        expect(42.toUint64().length, 8);
        expect(0.toUint64().length, 8);
      });
    });

    group('toOctal', () {
      test('converts 0', () {
        expect(0.toOctal(), '0');
      });

      test('converts 1', () {
        expect(1.toOctal(), '1');
      });

      test('converts 7', () {
        expect(7.toOctal(), '7');
      });

      test('converts 8', () {
        expect(8.toOctal(), '10');
      });

      test('converts 64', () {
        // 64 = 8^2 = 100 in octal
        expect(64.toOctal(), '100');
      });

      test('converts 511', () {
        // 511 = 7*64 + 7*8 + 7 = 777 in octal
        expect(511.toOctal(), '777');
      });

      test('converts 438', () {
        // 438 = 6*64 + 6*8 + 6 = 666 in octal (common unix permission)
        expect(438.toOctal(), '666');
      });

      test('converts 493', () {
        // 493 = 7*64 + 5*8 + 5 = 755 in octal (common unix permission)
        expect(493.toOctal(), '755');
      });

      test('converts 420', () {
        // 420 = 6*64 + 4*8 + 4 = 644 in octal
        expect(420.toOctal(), '644');
      });
    });

    group('toColonHex', () {
      test('converts 0', () {
        expect(0.toColonHex(), ':00:00:00:00');
      });

      test('converts 1', () {
        expect(1.toColonHex(), ':00:00:00:01');
      });

      test('converts 255', () {
        expect(255.toColonHex(), ':00:00:00:ff');
      });

      test('converts 256', () {
        expect(256.toColonHex(), ':00:00:01:00');
      });

      test('converts 0x12345678', () {
        expect(0x12345678.toColonHex(), ':12:34:56:78');
      });

      test('converts 0xAABBCCDD', () {
        expect(0xAABBCCDD.toColonHex(), ':aa:bb:cc:dd');
      });

      test('converts max uint32 with colon format', () {
        expect(0xFFFFFFFF.toColonHex(), ':ff:ff:ff:ff');
      });
    });

    group('roundtrip tests', () {
      test('toUint32 can be read back', () {
        final values = [0, 1, 42, 256, 65535, 0x12345678, 0xFFFFFFFF];
        for (final value in values) {
          final bytes = value.toUint32(Endian.big);
          final byteData = ByteData.sublistView(bytes);
          final result = byteData.getUint32(0, Endian.big);
          expect(result, value);
        }
      });

      test('toUint32 little endian roundtrip', () {
        final values = [0, 1, 256, 0x12345678];
        for (final value in values) {
          final bytes = value.toUint32(Endian.little);
          final byteData = ByteData.sublistView(bytes);
          final result = byteData.getUint32(0, Endian.little);
          expect(result, value);
        }
      });

      test('toUint64 can be read back', () {
        final values = [0, 1, 42, 0x123456789ABCDEF0];
        for (final value in values) {
          final bytes = value.toUint64(Endian.big);
          final byteData = ByteData.sublistView(bytes);
          final result = byteData.getUint64(0, Endian.big);
          expect(result, value);
        }
      });
    });
  });
}
