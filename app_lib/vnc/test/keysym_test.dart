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
      expect(unicodeToKeysym(0x00E9), 0x00E9); // é
    });

    test('maps non-Latin-1 Unicode with 0x01000000 offset', () {
      expect(unicodeToKeysym(0x20AC), 0x010020AC); // €
      expect(unicodeToKeysym(0x4E2D), 0x01004E2D); // 中
    });

    test('returns 0 for control characters without direct mapping', () {
      expect(unicodeToKeysym(0x0000), 0);
      expect(unicodeToKeysym(0x001F), 0);
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
  });
}
