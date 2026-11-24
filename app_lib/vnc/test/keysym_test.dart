import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:test/test.dart';

void main() {
  group('unicodeToKeysym', () {
    test('maps printable ASCII directly', () {
      expect(unicodeToKeysym('A'.codeUnitAt(0)), 0x0041);
      expect(unicodeToKeysym(' '.codeUnitAt(0)), 0x0020);
      expect(unicodeToKeysym('~'.codeUnitAt(0)), 0x007E);
    });

    test('maps Latin-1 supplement directly', () {
      expect(unicodeToKeysym(0x00A0), 0x00A0);
      expect(unicodeToKeysym(0x00E9), 0x00E9); // é
      expect(unicodeToKeysym(0x00FF), 0x00FF);
    });

    test('maps non-Latin-1 Unicode with 0x01000000 offset', () {
      expect(unicodeToKeysym(0x0100), 0x01000100);
      expect(unicodeToKeysym(0x20AC), 0x010020AC); // €
      expect(unicodeToKeysym(0x4E2D), 0x01004E2D); // 中
      expect(unicodeToKeysym(0x10FFFF), 0x0110FFFF);
    });

    test('returns 0 for control, surrogate, and out-of-range code points', () {
      expect(unicodeToKeysym(-1), 0);
      expect(unicodeToKeysym(0x0000), 0);
      expect(unicodeToKeysym(0x001F), 0);
      expect(unicodeToKeysym(0x007F), 0); // DEL
      expect(unicodeToKeysym(0x0080), 0); // C1 start
      expect(unicodeToKeysym(0x009F), 0); // C1 end
      expect(unicodeToKeysym(0xD800), 0); // High surrogate start
      expect(unicodeToKeysym(0xDBFF), 0); // High surrogate end
      expect(unicodeToKeysym(0xDC00), 0); // Low surrogate start
      expect(unicodeToKeysym(0xDFFF), 0); // Low surrogate end
      expect(unicodeToKeysym(0x110000), 0); // Above Unicode max
    });
  });

  group('VncPixelFormat', () {
    test('rgba8888 matches Flutter RGBA8888 layout', () {
      const fmt = VncPixelFormat.rgba8888;
      expect(fmt.bitsPerPixel, 32);
      expect(fmt.depth, 24);
      expect(fmt.bigEndian, isFalse);
      expect(fmt.trueColor, isTrue);
      expect(fmt.redMax, 255);
      expect(fmt.greenMax, 255);
      expect(fmt.blueMax, 255);
      expect(fmt.redShift, 0);
      expect(fmt.greenShift, 8);
      expect(fmt.blueShift, 16);
      expect(fmt.bytesPerPixel, 4);
    });

    test('round-trips through toBytes and fromBytes', () {
      const fmt = VncPixelFormat.rgba8888;
      final bytes = fmt.toBytes();
      expect(bytes.length, 16);
      expect(VncPixelFormat.fromBytes(bytes), fmt);

      const custom = VncPixelFormat(
        bitsPerPixel: 16,
        depth: 16,
        bigEndian: true,
        trueColor: true,
        redMax: 31,
        greenMax: 63,
        blueMax: 31,
        redShift: 11,
        greenShift: 5,
        blueShift: 0,
      );
      final padded = Uint8List(20);
      padded.setRange(4, 20, custom.toBytes());
      expect(VncPixelFormat.fromBytes(padded, 4), custom);
    });

    test('fromBytes throws RangeError on truncated input', () {
      expect(() => VncPixelFormat.fromBytes(Uint8List(15)), throwsRangeError);
      expect(
        () => VncPixelFormat.fromBytes(Uint8List(16), 1),
        throwsRangeError,
      );
    });
  });

  group('VncCursorData', () {
    test('compares pixel bytes rather than length alone', () {
      final cursorA1 = VncCursorData(
        width: 1,
        height: 1,
        hotspotX: 0,
        hotspotY: 0,
        rgbaPixels: Uint8List.fromList([255, 0, 0, 255]),
      );
      final cursorA2 = VncCursorData(
        width: 1,
        height: 1,
        hotspotX: 0,
        hotspotY: 0,
        rgbaPixels: Uint8List.fromList([255, 0, 0, 255]),
      );
      final cursorB = VncCursorData(
        width: 1,
        height: 1,
        hotspotX: 0,
        hotspotY: 0,
        rgbaPixels: Uint8List.fromList([0, 255, 0, 255]),
      );

      expect(cursorA1, equals(cursorA2));
      expect(cursorA1.hashCode, equals(cursorA2.hashCode));
      expect(cursorA1, isNot(equals(cursorB)));
    });
  });
}
