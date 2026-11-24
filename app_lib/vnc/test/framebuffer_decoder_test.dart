import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:test/test.dart';

/// Helper that feeds a single byte buffer into a [BufferedByteReader].
BufferedByteReader _readerFromBytes(List<int> bytes) {
  final controller = StreamController<Uint8List>();
  final reader = BufferedByteReader(controller.stream);
  controller.add(Uint8List.fromList(bytes));
  unawaited(controller.close());
  return reader;
}

/// Helper to read RGBA pixel at (x, y) from [fb].
List<int> _pixelAt(VncFramebuffer fb, int x, int y) {
  final offset = (y * fb.width + x) * 4;
  return [
    fb.pixels[offset],
    fb.pixels[offset + 1],
    fb.pixels[offset + 2],
    fb.pixels[offset + 3],
  ];
}

/// Encodes a 4-byte wire pixel under [VncPixelFormat.rgba8888] with arbitrary
/// padding byte (to ensure the decoder always forces alpha to 0xFF).
List<int> _wirePixel(int r, int g, int b, [int pad = 0x00]) => [r, g, b, pad];

/// Compresses [payload] using a persistent [RawZLibFilter] deflater with
/// Z_SYNC_FLUSH, returning a ZRLE rectangle body (uint32 length + bytes).
Uint8List _zrleMessage(RawZLibFilter deflater, List<int> payload) {
  final input = Uint8List.fromList(payload);
  deflater.process(input, 0, input.length);
  final compressedBuilder = BytesBuilder(copy: false);
  while (true) {
    final chunk = deflater.processed(flush: true, end: false);
    if (chunk == null) {
      break;
    }
    compressedBuilder.add(chunk);
  }
  final compressed = compressedBuilder.takeBytes();
  final header = ByteData(4)..setUint32(0, compressed.length, Endian.big);
  final out = BytesBuilder(copy: false)
    ..add(header.buffer.asUint8List())
    ..add(compressed);
  return out.takeBytes();
}

void main() {
  group('VncFramebuffer', () {
    test('initializes with opaque black pixels', () {
      final fb = VncFramebuffer(4, 3);
      expect(fb.width, 4);
      expect(fb.height, 3);
      expect(fb.pixels.length, 4 * 3 * 4);
      for (var y = 0; y < 3; y++) {
        for (var x = 0; x < 4; x++) {
          expect(_pixelAt(fb, x, y), [0, 0, 0, 255]);
        }
      }
    });

    test('rejects invalid or excessive dimensions', () {
      expect(() => VncFramebuffer(0, 10), throwsA(isA<VncProtocolException>()));
      expect(() => VncFramebuffer(10, 0), throwsA(isA<VncProtocolException>()));
      expect(
        () => VncFramebuffer(-1, 10),
        throwsA(isA<VncProtocolException>()),
      );
      expect(
        () => VncFramebuffer(16385, 10),
        throwsA(isA<VncProtocolException>()),
      );
      expect(
        () => VncFramebuffer(10, 16385),
        throwsA(isA<VncProtocolException>()),
      );
    });

    test('resize reallocates opaque black pixels and validates bounds', () {
      final fb = VncFramebuffer(2, 2);
      fb.setPixel(0, 0, 10, 20, 30);
      fb.resize(3, 4);
      expect(fb.width, 3);
      expect(fb.height, 4);
      expect(fb.pixels.length, 3 * 4 * 4);
      expect(_pixelAt(fb, 0, 0), [0, 0, 0, 255]);
      expect(() => fb.resize(0, 4), throwsA(isA<VncProtocolException>()));
      expect(() => fb.resize(16385, 1), throwsA(isA<VncProtocolException>()));
    });

    test('setPixel ignores out-of-bounds coordinates', () {
      final fb = VncFramebuffer(2, 2);
      fb.setPixel(-1, 0, 255, 0, 0);
      fb.setPixel(0, -1, 255, 0, 0);
      fb.setPixel(2, 0, 255, 0, 0);
      fb.setPixel(0, 2, 255, 0, 0);
      fb.setPixel(1, 1, 11, 22, 33);
      expect(_pixelAt(fb, 0, 0), [0, 0, 0, 255]);
      expect(_pixelAt(fb, 1, 1), [11, 22, 33, 255]);
    });

    test('fillRect clamps to framebuffer bounds', () {
      final fb = VncFramebuffer(4, 4);
      fb.fillRect(-1, -1, 3, 3, 100, 150, 200);
      expect(_pixelAt(fb, 0, 0), [100, 150, 200, 255]);
      expect(_pixelAt(fb, 1, 1), [100, 150, 200, 255]);
      expect(_pixelAt(fb, 2, 0), [0, 0, 0, 255]);
      expect(_pixelAt(fb, 0, 2), [0, 0, 0, 255]);
    });

    test('snapshot returns an isolated copy', () {
      final fb = VncFramebuffer(2, 2);
      fb.setPixel(0, 0, 1, 2, 3);
      final snap = fb.snapshot();
      fb.setPixel(0, 0, 9, 8, 7);
      expect(snap.sublist(0, 4), [1, 2, 3, 255]);
      expect(_pixelAt(fb, 0, 0), [9, 8, 7, 255]);
    });
  });

  group('RfbRectDecoder - Raw', () {
    test('decodes 2x2 raw rectangle forcing alpha to 0xFF', () async {
      final fb = VncFramebuffer(4, 4);
      final decoder = RfbRectDecoder();
      final bytes = [
        ..._wirePixel(10, 20, 30, 0x00),
        ..._wirePixel(40, 50, 60, 0x12),
        ..._wirePixel(70, 80, 90, 0x00),
        ..._wirePixel(100, 110, 120, 0x7F),
      ];
      final reader = _readerFromBytes(bytes);

      final result = await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 1,
        y: 2,
        width: 2,
        height: 2,
        encoding: RfbEncoding.raw,
      );

      expect(result.pixelsUpdated, isTrue);
      expect(result.resized, isFalse);
      expect(result.isLastRect, isFalse);
      expect(result.cursor, isNull);
      expect(_pixelAt(fb, 1, 2), [10, 20, 30, 255]);
      expect(_pixelAt(fb, 2, 2), [40, 50, 60, 255]);
      expect(_pixelAt(fb, 1, 3), [70, 80, 90, 255]);
      expect(_pixelAt(fb, 2, 3), [100, 110, 120, 255]);
      expect(_pixelAt(fb, 0, 0), [0, 0, 0, 255]);
    });

    test('rejects out-of-bounds raw rectangle', () async {
      final fb = VncFramebuffer(4, 4);
      final decoder = RfbRectDecoder();
      final reader = _readerFromBytes(List.filled(64, 0));

      await expectLater(
        decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 3,
          y: 2,
          width: 2,
          height: 2,
          encoding: RfbEncoding.raw,
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });
  });

  group('RfbRectDecoder - CopyRect', () {
    VncFramebuffer makeGradientFramebuffer() {
      final fb = VncFramebuffer(6, 6);
      for (var y = 0; y < 6; y++) {
        for (var x = 0; x < 6; x++) {
          fb.setPixel(x, y, x * 10, y * 10, (x + y) * 10);
        }
      }
      return fb;
    }

    test('overlapping right-shift on same row preserves pixels', () async {
      final fb = makeGradientFramebuffer();
      final decoder = RfbRectDecoder();
      // Copy (1, 1, 3x2) -> (2, 1) (overlapping same-row right shift)
      final reader = _readerFromBytes([0, 1, 0, 1]);

      final result = await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 2,
        y: 1,
        width: 3,
        height: 2,
        encoding: RfbEncoding.copyRect,
      );

      expect(result.pixelsUpdated, isTrue);
      // Verify shifted pixels match original (1..3, 1..2)
      for (var dy = 0; dy < 2; dy++) {
        for (var dx = 0; dx < 3; dx++) {
          final origX = 1 + dx;
          final origY = 1 + dy;
          expect(_pixelAt(fb, 2 + dx, 1 + dy), [
            origX * 10,
            origY * 10,
            (origX + origY) * 10,
            255,
          ]);
        }
      }
    });

    test('overlapping down-shift preserves pixels', () async {
      final fb = makeGradientFramebuffer();
      final decoder = RfbRectDecoder();
      // Copy (1, 1, 3x3) -> (1, 2) (overlapping vertical down shift)
      final reader = _readerFromBytes([0, 1, 0, 1]);

      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 1,
        y: 2,
        width: 3,
        height: 3,
        encoding: RfbEncoding.copyRect,
      );

      for (var dy = 0; dy < 3; dy++) {
        for (var dx = 0; dx < 3; dx++) {
          final origX = 1 + dx;
          final origY = 1 + dy;
          expect(_pixelAt(fb, 1 + dx, 2 + dy), [
            origX * 10,
            origY * 10,
            (origX + origY) * 10,
            255,
          ]);
        }
      }
    });

    test('overlapping diagonal down-right shift preserves pixels', () async {
      final fb = makeGradientFramebuffer();
      final decoder = RfbRectDecoder();
      // Copy (0, 0, 4x4) -> (1, 1)
      final reader = _readerFromBytes([0, 0, 0, 0]);

      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 1,
        y: 1,
        width: 4,
        height: 4,
        encoding: RfbEncoding.copyRect,
      );

      for (var dy = 0; dy < 4; dy++) {
        for (var dx = 0; dx < 4; dx++) {
          expect(_pixelAt(fb, 1 + dx, 1 + dy), [
            dx * 10,
            dy * 10,
            (dx + dy) * 10,
            255,
          ]);
        }
      }
    });

    test('overlapping left-shift on same row preserves pixels', () async {
      final fb = makeGradientFramebuffer();
      final decoder = RfbRectDecoder();
      // Copy (2, 2, 3x2) -> (1, 2)
      final reader = _readerFromBytes([0, 2, 0, 2]);

      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 1,
        y: 2,
        width: 3,
        height: 2,
        encoding: RfbEncoding.copyRect,
      );

      for (var dy = 0; dy < 2; dy++) {
        for (var dx = 0; dx < 3; dx++) {
          final origX = 2 + dx;
          final origY = 2 + dy;
          expect(_pixelAt(fb, 1 + dx, 2 + dy), [
            origX * 10,
            origY * 10,
            (origX + origY) * 10,
            255,
          ]);
        }
      }
    });

    test('rejects out-of-bounds CopyRect source', () async {
      final fb = VncFramebuffer(4, 4);
      final decoder = RfbRectDecoder();
      // srcX = 3, srcY = 0 with width 2 -> exceeds width 4
      final reader = _readerFromBytes([0, 3, 0, 0]);

      await expectLater(
        decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 2,
          height: 2,
          encoding: RfbEncoding.copyRect,
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });
  });

  group('RfbRectDecoder - Hextile', () {
    test(
      'decodes Raw tile, bg/fg/subrects, coloured subrects, and multi-tile bg/fg persistence',
      () async {
        // 20x20 rect -> 4 tiles:
        // Tile (0,0): 16x16 - BackgroundSpecified(10,20,30) + ForegroundSpecified(200,100,50) + AnySubrects (1 subrect at (2,3) 4x5)
        // Tile (16,0): 4x16 - SubrectsColoured + AnySubrects (inherits bg=(10,20,30), 1 coloured subrect at (1,1) 2x2 with (1,2,3))
        // Tile (0,16): 16x4 - AnySubrects only (inherits bg=(10,20,30) AND fg=(200,100,50), 1 subrect at (0,0) 3x2)
        // Tile (16,16): 4x4 - Raw tile (16 distinct pixels)
        final fb = VncFramebuffer(20, 20);
        final decoder = RfbRectDecoder();

        final tile00 = <int>[
          2 | 4 | 8, // bg + fg + anySubrects
          ..._wirePixel(10, 20, 30),
          ..._wirePixel(200, 100, 50),
          1, // numSubrects
          (2 << 4) | 3, // sx=2, sy=3
          ((4 - 1) << 4) | (5 - 1), // sw=4, sh=5
        ];

        final tile10 = <int>[
          8 | 16, // anySubrects + subrectsColoured (reuse bg)
          1, // numSubrects
          ..._wirePixel(1, 2, 3),
          (1 << 4) | 1, // sx=1, sy=1
          ((2 - 1) << 4) | (2 - 1), // sw=2, sh=2
        ];

        final tile01 = <int>[
          8, // anySubrects only (reuse bg and fg)
          1, // numSubrects
          0x00, // sx=0, sy=0
          ((3 - 1) << 4) | (2 - 1), // sw=3, sh=2
        ];

        final tile11 = <int>[
          1, // Raw
          for (var i = 0; i < 16; i++) ..._wirePixel(i * 10, i * 5, i, 0x00),
        ];

        final reader = _readerFromBytes([
          ...tile00,
          ...tile10,
          ...tile01,
          ...tile11,
        ]);

        final result = await decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 20,
          height: 20,
          encoding: RfbEncoding.hextile,
        );

        expect(result.pixelsUpdated, isTrue);

        // Tile (0,0): background and fg subrect
        expect(_pixelAt(fb, 0, 0), [10, 20, 30, 255]);
        expect(_pixelAt(fb, 2, 3), [200, 100, 50, 255]);
        expect(_pixelAt(fb, 5, 7), [200, 100, 50, 255]);
        expect(_pixelAt(fb, 6, 7), [10, 20, 30, 255]);

        // Tile (16,0): inherited bg + coloured subrect at (17, 1)..(18, 2)
        expect(_pixelAt(fb, 16, 0), [10, 20, 30, 255]);
        expect(_pixelAt(fb, 17, 1), [1, 2, 3, 255]);
        expect(_pixelAt(fb, 18, 2), [1, 2, 3, 255]);
        expect(_pixelAt(fb, 19, 2), [10, 20, 30, 255]);

        // Tile (0,16): inherited bg AND fg subrect at (0, 16)..(2, 17)
        expect(_pixelAt(fb, 0, 16), [200, 100, 50, 255]);
        expect(_pixelAt(fb, 2, 17), [200, 100, 50, 255]);
        expect(_pixelAt(fb, 3, 17), [10, 20, 30, 255]);
        expect(_pixelAt(fb, 0, 18), [10, 20, 30, 255]);

        // Tile (16,16): Raw 4x4 pixels with forced alpha 0xFF
        expect(_pixelAt(fb, 16, 16), [0, 0, 0, 255]);
        expect(_pixelAt(fb, 17, 16), [10, 5, 1, 255]);
        expect(_pixelAt(fb, 19, 19), [150, 75, 15, 255]);
      },
    );

    test('rejects Hextile subrect extending outside tile bounds', () async {
      final fb = VncFramebuffer(4, 4);
      final decoder = RfbRectDecoder();
      final reader = _readerFromBytes([
        2 | 4 | 8,
        ..._wirePixel(0, 0, 0),
        ..._wirePixel(255, 255, 255),
        1,
        (2 << 4) | 0, // sx=2
        ((3 - 1) << 4) | 0, // sw=3 -> 2 + 3 = 5 > tile width 4
      ]);

      await expectLater(
        decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 4,
          height: 4,
          encoding: RfbEncoding.hextile,
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });
  });

  group('RfbRectDecoder - ZRLE', () {
    test('decodes all 5 ZRLE sub-encodings across a single persistent zlib stream', () async {
      final fb = VncFramebuffer(70, 70);
      final decoder = RfbRectDecoder();
      final deflater = RawZLibFilter.deflateFilter();

      // 1. Update 1: Subencoding 0 (Raw) on 2x2 rect at (0, 0)
      final rawPayload = <int>[
        0, // subencoding = Raw
        10, 20, 30,
        40, 50, 60,
        70, 80, 90,
        100, 110, 120,
      ];

      // 2. Update 2: Subencoding 1 (Solid) on 3x2 rect at (4, 0)
      final solidPayload = <int>[
        1, // subencoding = Solid
        200, 150, 100,
      ];

      // 3. Update 3: Subencoding 2 (1-bit packed palette) on 5x2 rect at (0, 4)
      // Non-multiple-of-8 width (5) verifies per-row byte alignment.
      // Row 0 bits: 1,0,1,1,0 (+ 3 zero pad bits) = 0b10110000 = 0xB0
      // Row 1 bits: 0,1,0,0,1 (+ 3 zero pad bits) = 0b01001000 = 0x48
      final packed1BitPayload = <int>[
        2, // paletteSize = 2 (1-bit)
        1, 2, 3, // index 0
        4, 5, 6, // index 1
        0xB0,
        0x48,
      ];

      // 4. Update 4: Subencoding 4 (2-bit packed palette) on 5x2 rect at (10, 4)
      // Width 5 -> 2 bytes per row (4 pixels + 1 pixel + 3 padding slots).
      // Row 0 indices: 0, 1, 2, 3 | 2 -> bytes: 0b00_01_10_11 = 0x1B, 0b10_00_00_00 = 0x80
      // Row 1 indices: 3, 2, 1, 0 | 1 -> bytes: 0b11_10_01_00 = 0xE4, 0b01_00_00_00 = 0x40
      final packed2BitPayload = <int>[
        4, // paletteSize = 4 (2-bit)
        10, 0, 0, // idx 0
        0, 20, 0, // idx 1
        0, 0, 30, // idx 2
        40, 40, 40, // idx 3
        0x1B, 0x80,
        0xE4, 0x40,
      ];

      // 5. Update 5: Subencoding 16 (4-bit packed palette) on 3x2 rect at (20, 4)
      // Width 3 -> 2 bytes per row (2 pixels + 1 pixel + 1 padding nibble).
      // Row 0 indices: 0, 15 | 7 -> 0x0F, 0x70
      // Row 1 indices: 12, 3 | 9 -> 0xC3, 0x90
      final packed4BitPayload = <int>[
        16, // paletteSize = 16 (4-bit)
        for (var i = 0; i < 16; i++) ...[i * 10, i * 11, i * 12],
        0x0F, 0x70,
        0xC3, 0x90,
      ];

      // 6. Update 6: Subencoding 128 (Plain RLE) on a full 64x64 tile at (0, 6)
      // Total pixels = 4096.
      // Run 1: 300 pixels of (11, 22, 33) -> length bytes: [255, 44] (1 + 255 + 44 = 300)
      // Run 2: 3796 pixels of (44, 55, 66) -> 3795 = 14 * 255 + 225 -> fourteen 255s + 225
      final plainRlePayload = <int>[
        128, // Plain RLE
        11, 22, 33,
        255, 44, // 1 + 255 + 44 = 300
        44, 55, 66,
        ...List.filled(14, 255),
        225, // 1 + 14*255 + 225 = 3796
      ];

      // 7. Update 7: Subencoding 131 (Palette RLE, paletteSize = 3) on 6x2 rect at (64, 0)
      // Total pixels = 12:
      // - Single pixel idx 0 (0x00) -> 1 pixel
      // - Run of 5 pixels idx 1 (0x81, 4 -> 1 + 4 = 5) -> 5 pixels
      // - Single pixel idx 2 (0x02) -> 1 pixel
      // - Run of 5 pixels idx 0 (0x80, 4 -> 1 + 4 = 5) -> 5 pixels
      final paletteRlePayload = <int>[
        131, // 128 + 3
        101, 102, 103, // idx 0
        111, 112, 113, // idx 1
        121, 122, 123, // idx 2
        0x00, // single idx 0 (pixel 0)
        0x81, 4, // run of 5 idx 1 (pixels 1..5)
        0x02, // single idx 2 (pixel 6)
        0x80, 4, // run of 5 idx 0 (pixels 7..11)
      ];

      final wire = BytesBuilder(copy: false)
        ..add(_zrleMessage(deflater, rawPayload))
        ..add(_zrleMessage(deflater, solidPayload))
        ..add(_zrleMessage(deflater, packed1BitPayload))
        ..add(_zrleMessage(deflater, packed2BitPayload))
        ..add(_zrleMessage(deflater, packed4BitPayload))
        ..add(_zrleMessage(deflater, plainRlePayload))
        ..add(_zrleMessage(deflater, paletteRlePayload));

      final reader = _readerFromBytes(wire.takeBytes());

      // Decode Update 1: Raw
      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 0,
        y: 0,
        width: 2,
        height: 2,
        encoding: RfbEncoding.zrle,
      );
      expect(_pixelAt(fb, 0, 0), [10, 20, 30, 255]);
      expect(_pixelAt(fb, 1, 0), [40, 50, 60, 255]);
      expect(_pixelAt(fb, 0, 1), [70, 80, 90, 255]);
      expect(_pixelAt(fb, 1, 1), [100, 110, 120, 255]);

      // Decode Update 2: Solid
      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 4,
        y: 0,
        width: 3,
        height: 2,
        encoding: RfbEncoding.zrle,
      );
      for (var y = 0; y < 2; y++) {
        for (var x = 4; x < 7; x++) {
          expect(_pixelAt(fb, x, y), [200, 150, 100, 255]);
        }
      }

      // Decode Update 3: 1-bit packed palette
      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 0,
        y: 4,
        width: 5,
        height: 2,
        encoding: RfbEncoding.zrle,
      );
      const c0 = [1, 2, 3, 255];
      const c1 = [4, 5, 6, 255];
      expect(_pixelAt(fb, 0, 4), c1);
      expect(_pixelAt(fb, 1, 4), c0);
      expect(_pixelAt(fb, 2, 4), c1);
      expect(_pixelAt(fb, 3, 4), c1);
      expect(_pixelAt(fb, 4, 4), c0);
      expect(_pixelAt(fb, 0, 5), c0);
      expect(_pixelAt(fb, 1, 5), c1);
      expect(_pixelAt(fb, 2, 5), c0);
      expect(_pixelAt(fb, 3, 5), c0);
      expect(_pixelAt(fb, 4, 5), c1);

      // Decode Update 4: 2-bit packed palette
      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 10,
        y: 4,
        width: 5,
        height: 2,
        encoding: RfbEncoding.zrle,
      );
      expect(_pixelAt(fb, 10, 4), [10, 0, 0, 255]);
      expect(_pixelAt(fb, 11, 4), [0, 20, 0, 255]);
      expect(_pixelAt(fb, 12, 4), [0, 0, 30, 255]);
      expect(_pixelAt(fb, 13, 4), [40, 40, 40, 255]);
      expect(_pixelAt(fb, 14, 4), [0, 0, 30, 255]);
      expect(_pixelAt(fb, 10, 5), [40, 40, 40, 255]);
      expect(_pixelAt(fb, 11, 5), [0, 0, 30, 255]);
      expect(_pixelAt(fb, 12, 5), [0, 20, 0, 255]);
      expect(_pixelAt(fb, 13, 5), [10, 0, 0, 255]);
      expect(_pixelAt(fb, 14, 5), [0, 20, 0, 255]);

      // Decode Update 5: 4-bit packed palette
      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 20,
        y: 4,
        width: 3,
        height: 2,
        encoding: RfbEncoding.zrle,
      );
      expect(_pixelAt(fb, 20, 4), [0, 0, 0, 255]);
      expect(_pixelAt(fb, 21, 4), [150, 165, 180, 255]);
      expect(_pixelAt(fb, 22, 4), [70, 77, 84, 255]);
      expect(_pixelAt(fb, 20, 5), [120, 132, 144, 255]);
      expect(_pixelAt(fb, 21, 5), [30, 33, 36, 255]);
      expect(_pixelAt(fb, 22, 5), [90, 99, 108, 255]);

      // Decode Update 6: Plain RLE on 64x64 tile (multi-byte run > 255)
      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 0,
        y: 6,
        width: 64,
        height: 64,
        encoding: RfbEncoding.zrle,
      );
      // Pixel index 0 -> (0, 6)
      expect(_pixelAt(fb, 0, 6), [11, 22, 33, 255]);
      // Pixel index 299 -> row 4 (4*64=256), col 43 -> (43, 10)
      expect(_pixelAt(fb, 43, 10), [11, 22, 33, 255]);
      // Pixel index 300 -> row 4, col 44 -> (44, 10)
      expect(_pixelAt(fb, 44, 10), [44, 55, 66, 255]);
      // Last pixel index 4095 -> (63, 69)
      expect(_pixelAt(fb, 63, 69), [44, 55, 66, 255]);

      // Decode Update 7: Palette RLE
      await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 64,
        y: 0,
        width: 6,
        height: 2,
        encoding: RfbEncoding.zrle,
      );
      expect(_pixelAt(fb, 64, 0), [101, 102, 103, 255]);
      for (var col = 1; col <= 5; col++) {
        expect(_pixelAt(fb, 64 + col, 0), [111, 112, 113, 255]);
      }
      expect(_pixelAt(fb, 64, 1), [121, 122, 123, 255]);
      for (var col = 1; col <= 5; col++) {
        expect(_pixelAt(fb, 64 + col, 1), [101, 102, 103, 255]);
      }
    });

    test('rejects invalid ZRLE subencoding 17 and 129', () async {
      for (final badSub in [17, 129]) {
        final fb = VncFramebuffer(4, 4);
        final decoder = RfbRectDecoder();
        final deflater = RawZLibFilter.deflateFilter();
        final reader = _readerFromBytes(_zrleMessage(deflater, [badSub]));

        await expectLater(
          decoder.decodeRectangle(
            reader: reader,
            framebuffer: fb,
            x: 0,
            y: 0,
            width: 4,
            height: 4,
            encoding: RfbEncoding.zrle,
          ),
          throwsA(isA<VncProtocolException>()),
        );
      }
    });

    test('rejects truncated inflated ZRLE data', () async {
      final fb = VncFramebuffer(4, 4);
      final decoder = RfbRectDecoder();
      final deflater = RawZLibFilter.deflateFilter();
      // Raw subencoding for 4x4 expects 48 bytes, only provide 3.
      final reader = _readerFromBytes(_zrleMessage(deflater, [0, 1, 2, 3]));

      await expectLater(
        decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 4,
          height: 4,
          encoding: RfbEncoding.zrle,
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });

    test('rejects corrupt zlib bytes in ZRLE rectangle', () async {
      final fb = VncFramebuffer(4, 4);
      final decoder = RfbRectDecoder();
      final badCompressed = [0xFF, 0xFE, 0xFD, 0xFC];
      final header = ByteData(4)
        ..setUint32(0, badCompressed.length, Endian.big);
      final reader = _readerFromBytes([
        ...header.buffer.asUint8List(),
        ...badCompressed,
      ]);

      await expectLater(
        decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 4,
          height: 4,
          encoding: RfbEncoding.zrle,
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });

    test('decodes multi-tile ZRLE rectangle spanning >64x64', () async {
      final fb = VncFramebuffer(66, 65);
      final decoder = RfbRectDecoder();
      final deflater = RawZLibFilter.deflateFilter();
      // 66x65 -> 2x2 tiles: (0,0 64x64), (64,0 2x64), (0,64 64x1), (64,64 2x1)
      final payload = <int>[
        1, 10, 20, 30, // tile (0,0)
        1, 40, 50, 60, // tile (64,0)
        1, 70, 80, 90, // tile (0,64)
        1, 100, 110, 120, // tile (64,64)
      ];
      final reader = _readerFromBytes(_zrleMessage(deflater, payload));

      final result = await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 0,
        y: 0,
        width: 66,
        height: 65,
        encoding: RfbEncoding.zrle,
      );

      expect(result.pixelsUpdated, isTrue);
      expect(_pixelAt(fb, 63, 63), [10, 20, 30, 255]);
      expect(_pixelAt(fb, 65, 63), [40, 50, 60, 255]);
      expect(_pixelAt(fb, 63, 64), [70, 80, 90, 255]);
      expect(_pixelAt(fb, 65, 64), [100, 110, 120, 255]);
    });

    test('rejects ZRLE RLE run exceeding tile pixel count', () async {
      final fb = VncFramebuffer(2, 2);
      final decoder = RfbRectDecoder();
      final deflater = RawZLibFilter.deflateFilter();
      // 2x2 = 4 pixels, send run of 5 (1 + 4)
      final reader = _readerFromBytes(
        _zrleMessage(deflater, [128, 1, 2, 3, 4]),
      );

      await expectLater(
        decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 2,
          height: 2,
          encoding: RfbEncoding.zrle,
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });

    test('rejects ZRLE packed palette index out of range', () async {
      final fb = VncFramebuffer(2, 1);
      final decoder = RfbRectDecoder();
      final deflater = RawZLibFilter.deflateFilter();
      // paletteSize = 3 (2-bit indices), index 3 (0b11) is out of bounds.
      final reader = _readerFromBytes(
        _zrleMessage(deflater, [
          3,
          1, 2, 3,
          4, 5, 6,
          7, 8, 9,
          0xC0, // first pixel index 3
        ]),
      );

      await expectLater(
        decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 2,
          height: 1,
          encoding: RfbEncoding.zrle,
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });
  });

  group('RfbRectDecoder - Pseudo-Encodings', () {
    test('DesktopSize resizes framebuffer', () async {
      final fb = VncFramebuffer(10, 10);
      final decoder = RfbRectDecoder();
      final reader = _readerFromBytes([]);

      final result = await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 0,
        y: 0,
        width: 32,
        height: 24,
        encoding: RfbEncoding.desktopSize,
      );

      expect(result.resized, isTrue);
      expect(result.pixelsUpdated, isFalse);
      expect(fb.width, 32);
      expect(fb.height, 24);
    });

    test(
      'ExtendedDesktopSize skips screen records and resizes framebuffer',
      () async {
        final fb = VncFramebuffer(10, 10);
        final decoder = RfbRectDecoder();
        // 2 screens: 1 byte numScreens + 3 bytes padding + 2 * 16 bytes screen records
        // followed by a trailing sentinel byte 0xAB to verify exact byte consumption.
        final bytes = <int>[
          2, // numScreens
          0, 0, 0, // padding
          ...List.filled(16, 0x11), // screen 1
          ...List.filled(16, 0x22), // screen 2
          0xAB, // sentinel next byte
        ];
        final reader = _readerFromBytes(bytes);

        final result = await decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 80,
          height: 60,
          encoding: RfbEncoding.extendedDesktopSize,
        );

        expect(result.resized, isTrue);
        expect(fb.width, 80);
        expect(fb.height, 60);
        expect(await reader.readUint8(), 0xAB);
      },
    );

    test(
      'Cursor decodes hotspot and 1-bit MSB-first transparency bitmask',
      () async {
        final fb = VncFramebuffer(10, 10);
        final decoder = RfbRectDecoder();
        // 3x2 cursor with hotspot (1, 2):
        // Pixels: (10,20,30), (40,50,60), (70,80,90)
        //         (100,110,120), (130,140,150), (160,170,180)
        // Bitmask (1 byte per row, MSB-first):
        // Row 0: 1, 0, 1 -> 0b1010_0000 = 0xA0
        // Row 1: 0, 1, 1 -> 0b0110_0000 = 0x60
        final bytes = <int>[
          ..._wirePixel(10, 20, 30, 0x00),
          ..._wirePixel(40, 50, 60, 0xFF),
          ..._wirePixel(70, 80, 90, 0x00),
          ..._wirePixel(100, 110, 120, 0xFF),
          ..._wirePixel(130, 140, 150, 0x00),
          ..._wirePixel(160, 170, 180, 0x00),
          0xA0,
          0x60,
        ];
        final reader = _readerFromBytes(bytes);

        final result = await decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 1,
          y: 2,
          width: 3,
          height: 2,
          encoding: RfbEncoding.cursor,
        );

        expect(result.resized, isFalse);
        expect(result.isLastRect, isFalse);
        expect(result.pixelsUpdated, isFalse);
        final cursor = result.cursor;
        expect(cursor, isNotNull);
        expect(cursor!.width, 3);
        expect(cursor.height, 2);
        expect(cursor.hotspotX, 1);
        expect(cursor.hotspotY, 2);
        expect(cursor.rgbaPixels, [
          10, 20, 30, 255, // row 0 col 0: opaque
          40, 50, 60, 0, // row 0 col 1: transparent
          70, 80, 90, 255, // row 0 col 2: opaque
          100, 110, 120, 0, // row 1 col 0: transparent
          130, 140, 150, 255, // row 1 col 1: opaque
          160, 170, 180, 255, // row 1 col 2: opaque
        ]);
      },
    );

    test('Cursor with zero dimensions returns empty VncCursorData', () async {
      final fb = VncFramebuffer(10, 10);
      final decoder = RfbRectDecoder();
      final reader = _readerFromBytes([]);

      final result = await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 3,
        y: 4,
        width: 0,
        height: 0,
        encoding: RfbEncoding.cursor,
      );

      expect(
        result.cursor,
        VncCursorData(
          width: 0,
          height: 0,
          hotspotX: 3,
          hotspotY: 4,
          rgbaPixels: Uint8List(0),
        ),
      );
    });

    test('LastRect sets isLastRect to true', () async {
      final fb = VncFramebuffer(10, 10);
      final decoder = RfbRectDecoder();
      final reader = _readerFromBytes([]);

      final result = await decoder.decodeRectangle(
        reader: reader,
        framebuffer: fb,
        x: 0,
        y: 0,
        width: 0,
        height: 0,
        encoding: RfbEncoding.lastRect,
      );

      expect(result.isLastRect, isTrue);
      expect(result.resized, isFalse);
      expect(result.pixelsUpdated, isFalse);
      expect(result.cursor, isNull);
    });

    test('unknown encoding throws VncProtocolException', () async {
      final fb = VncFramebuffer(10, 10);
      final decoder = RfbRectDecoder();
      final reader = _readerFromBytes([]);

      await expectLater(
        decoder.decodeRectangle(
          reader: reader,
          framebuffer: fb,
          x: 0,
          y: 0,
          width: 2,
          height: 2,
          encoding: 999,
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });
  });
}
