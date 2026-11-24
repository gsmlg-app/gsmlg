import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../models/vnc_exceptions.dart';
import '../models/vnc_models.dart';
import 'apple_rfb.dart';
import 'byte_reader.dart';
import 'rfb_encodings.dart';

/// RGBA8888 software framebuffer for an RFB/VNC session.
///
/// Pixels are stored in tightly-packed row-major RGBA order (`[R, G, B, A]`),
/// with the alpha channel forced to `0xFF` so unpainted and decoded regions
/// are always opaque.
class VncFramebuffer {
  VncFramebuffer(int width, int height) {
    _allocate(width, height);
  }

  /// Maximum allowed framebuffer width or height (in pixels) to prevent
  /// excessive allocations from malformed or malicious server messages.
  static const int maxDimension = 16384;

  late int _width;
  late int _height;
  late Uint8List _pixels;

  int get width => _width;
  int get height => _height;
  Uint8List get pixels => _pixels;

  void _allocate(int width, int height) {
    if (width <= 0 ||
        height <= 0 ||
        width > maxDimension ||
        height > maxDimension) {
      throw VncProtocolException(
        'Invalid framebuffer dimensions: ${width}x$height '
        '(must be within 1..$maxDimension)',
      );
    }
    final pixels = Uint8List(width * height * 4);
    for (var i = 3; i < pixels.length; i += 4) {
      pixels[i] = 0xFF;
    }
    _width = width;
    _height = height;
    _pixels = pixels;
  }

  /// Resizes the framebuffer to [newWidth] × [newHeight], clearing its
  /// contents to opaque black.
  void resize(int newWidth, int newHeight) {
    _allocate(newWidth, newHeight);
  }

  /// Sets a single pixel at ([x], [y]) to opaque RGB `([r], [g], [b], 0xFF)`.
  ///
  /// Out-of-bounds coordinates are ignored.
  void setPixel(int x, int y, int r, int g, int b) {
    if (x < 0 || y < 0 || x >= _width || y >= _height) {
      return;
    }
    final offset = (y * _width + x) * 4;
    _pixels[offset] = r;
    _pixels[offset + 1] = g;
    _pixels[offset + 2] = b;
    _pixels[offset + 3] = 0xFF;
  }

  /// Fills the rectangle `([x], [y], [w], [h])` with opaque RGB `([r], [g], [b], 0xFF)`,
  /// clamping to the framebuffer bounds.
  void fillRect(int x, int y, int w, int h, int r, int g, int b) {
    if (w <= 0 || h <= 0) {
      return;
    }
    final x0 = x < 0 ? 0 : x;
    final y0 = y < 0 ? 0 : y;
    final x1 = (x + w) > _width ? _width : (x + w);
    final y1 = (y + h) > _height ? _height : (y + h);
    if (x0 >= x1 || y0 >= y1) {
      return;
    }

    final spanWidth = x1 - x0;
    final rowBytes = spanWidth * 4;
    final firstRowOffset = (y0 * _width + x0) * 4;

    var offset = firstRowOffset;
    for (var col = 0; col < spanWidth; col++) {
      _pixels[offset] = r;
      _pixels[offset + 1] = g;
      _pixels[offset + 2] = b;
      _pixels[offset + 3] = 0xFF;
      offset += 4;
    }

    final stride = _width * 4;
    var dstOffset = firstRowOffset + stride;
    for (var row = y0 + 1; row < y1; row++) {
      _pixels.setRange(
        dstOffset,
        dstOffset + rowBytes,
        _pixels,
        firstRowOffset,
      );
      dstOffset += stride;
    }
  }

  /// Copies a rectangle of size `[w] × [h]` from `([srcX], [srcY])` to
  /// `([dstX], [dstY])` safely even when source and destination overlap.
  ///
  /// Throws [VncProtocolException] if either rectangle exceeds framebuffer
  /// bounds or has negative dimensions.
  void copyRect(int srcX, int srcY, int dstX, int dstY, int w, int h) {
    if (w < 0 || h < 0) {
      throw VncProtocolException('Invalid CopyRect dimensions: ${w}x$h');
    }
    if (srcX < 0 ||
        srcY < 0 ||
        srcX + w > _width ||
        srcY + h > _height ||
        dstX < 0 ||
        dstY < 0 ||
        dstX + w > _width ||
        dstY + h > _height) {
      throw VncProtocolException(
        'CopyRect src=($srcX,$srcY) dst=($dstX,$dstY) size=${w}x$h '
        'exceeds framebuffer bounds (${_width}x$_height)',
      );
    }
    if (w == 0 || h == 0 || (srcX == dstX && srcY == dstY)) {
      return;
    }

    final stride = _width * 4;
    final rowBytes = w * 4;

    if (dstY > srcY) {
      for (var row = h - 1; row >= 0; row--) {
        final srcOffset = (srcY + row) * stride + srcX * 4;
        final dstOffset = (dstY + row) * stride + dstX * 4;
        _pixels.setRange(dstOffset, dstOffset + rowBytes, _pixels, srcOffset);
      }
    } else if (dstY < srcY) {
      for (var row = 0; row < h; row++) {
        final srcOffset = (srcY + row) * stride + srcX * 4;
        final dstOffset = (dstY + row) * stride + dstX * 4;
        _pixels.setRange(dstOffset, dstOffset + rowBytes, _pixels, srcOffset);
      }
    } else {
      // Same vertical rows: copy through a row buffer so horizontal overlaps
      // (both left- and right-shifts) never corrupt unread source pixels.
      final rowBuf = Uint8List(rowBytes);
      for (var row = 0; row < h; row++) {
        final srcOffset = (srcY + row) * stride + srcX * 4;
        final dstOffset = (dstY + row) * stride + dstX * 4;
        rowBuf.setRange(0, rowBytes, _pixels, srcOffset);
        _pixels.setRange(dstOffset, dstOffset + rowBytes, rowBuf);
      }
    }
  }

  /// Returns an isolated copy of the RGBA pixel buffer suitable for transfer
  /// across isolates or submission to UI image decoding.
  Uint8List snapshot() => Uint8List.fromList(_pixels);
}

/// Outcome of decoding a single RFB framebuffer update rectangle.
@immutable
class RfbRectDecodeResult {
  const RfbRectDecodeResult({
    this.resized = false,
    this.isLastRect = false,
    this.cursor,
    this.pixelsUpdated = false,
    this.screens,
    this.hasCurrentDisplayId = false,
    this.currentDisplayId,
  });

  final bool resized;
  final bool isLastRect;
  final VncCursorData? cursor;
  final bool pixelsUpdated;
  final List<VncScreenInfo>? screens;

  /// Whether this rectangle carried an authoritative Apple display selection
  /// (allowing `null` = All Displays to be distinguished from non-layout updates).
  final bool hasCurrentDisplayId;

  /// Active macOS display ID, or `null` for All Displays when
  /// [hasCurrentDisplayId] is `true`.
  final int? currentDisplayId;
}

/// Decodes RFB framebuffer update rectangles assuming the negotiated
/// [VncPixelFormat.rgba8888] wire format (32-bit, depth 24, little-endian,
/// R/G/B shifts 0/8/16; 3-byte `[R, G, B]` CPIXEL for ZRLE).
class RfbRectDecoder {
  RfbRectDecoder({this.isApple889 = false});

  /// Maximum accepted compressed ZRLE rectangle payload (64 MiB).
  static const int maxZrleCompressedBytes = 64 * 1024 * 1024;

  /// Maximum accepted inflated ZRLE rectangle payload (256 MiB).
  static const int maxZrleInflatedBytes = 256 * 1024 * 1024;

  /// Whether Apple RFB `003.889` pseudo-encodings (`0x44c`..`0x455`) are active.
  final bool isApple889;

  /// Single persistent zlib inflate stream required across all ZRLE rectangles
  /// for the lifetime of an RFB session (RFC 6143 §7.7.6).
  final RawZLibFilter _zrleInflater = RawZLibFilter.inflateFilter();

  final AppleCursorCache _appleCursorCache = AppleCursorCache();

  /// Decodes a single rectangle header payload from [reader] and applies it to
  /// [framebuffer].
  Future<RfbRectDecodeResult> decodeRectangle({
    required BufferedByteReader reader,
    required VncFramebuffer framebuffer,
    required int x,
    required int y,
    required int width,
    required int height,
    required int encoding,
  }) async {
    switch (encoding) {
      case RfbEncoding.raw:
        return _decodeRaw(reader, framebuffer, x, y, width, height);
      case RfbEncoding.copyRect:
        return _decodeCopyRect(reader, framebuffer, x, y, width, height);
      case RfbEncoding.hextile:
        return _decodeHextile(reader, framebuffer, x, y, width, height);
      case RfbEncoding.zrle:
        return _decodeZrle(reader, framebuffer, x, y, width, height);
      case RfbEncoding.desktopSize:
        framebuffer.resize(width, height);
        return const RfbRectDecodeResult(resized: true);
      case RfbEncoding.extendedDesktopSize:
        return _decodeExtendedDesktopSize(reader, framebuffer, width, height);
      case RfbEncoding.cursor:
        return _decodeCursor(reader, x, y, width, height);
      case RfbEncoding.lastRect:
        return const RfbRectDecodeResult(isLastRect: true);
      case AppleRfbEncoding.displayLayout when isApple889:
        return _decodeAppleDisplayLayout(reader, framebuffer);
      case AppleRfbEncoding.cursorImage when isApple889:
        return _decodeAppleCursorImage(reader, x, y, width, height);
      case AppleRfbEncoding.cursorPos when isApple889:
        return const RfbRectDecodeResult();
      case AppleRfbEncoding.displayInfo when isApple889:
        final head = await reader.readBytes(10);
        final count = (head[8] << 8) | head[9];
        await reader.skip(count * 0x1c);
        return const RfbRectDecodeResult();
      case AppleRfbEncoding.vendorKeysyms when isApple889:
      case AppleRfbEncoding.keyboardSource when isApple889:
        final len = await reader.readUint16();
        await reader.skip(len);
        return const RfbRectDecodeResult();
      case AppleRfbEncoding.rekey when isApple889:
        throw const VncProtocolException('Unexpected mid-session Apple rekey');
      default:
        throw VncProtocolException('Unsupported RFB encoding: $encoding');
    }
  }

  Future<RfbRectDecodeResult> _decodeAppleDisplayLayout(
    BufferedByteReader reader,
    VncFramebuffer framebuffer,
  ) async {
    final len = await reader.readUint16();
    final payload = await reader.readBytes(len);
    final layout = AppleDisplayLayout.parse(payload);
    framebuffer.resize(layout.backingWidth, layout.backingHeight);
    return RfbRectDecodeResult(
      resized: true,
      screens: layout.displays,
      hasCurrentDisplayId: true,
      currentDisplayId: layout.currentDisplayId,
    );
  }

  Future<RfbRectDecodeResult> _decodeAppleCursorImage(
    BufferedByteReader reader,
    int hotspotX,
    int hotspotY,
    int width,
    int height,
  ) async {
    final id = await reader.readUint32();
    final len = await reader.readUint32();
    if (len > AppleCursorCache.maxCompressedBytes) {
      throw VncProtocolException(
        'Apple cursor image payload $len exceeds limit '
        '(${AppleCursorCache.maxCompressedBytes} bytes)',
      );
    }
    final deflated = await reader.readBytes(len);
    final cursor = _appleCursorCache.accept(
      id: id,
      hotspotX: hotspotX,
      hotspotY: hotspotY,
      width: width,
      height: height,
      deflated: deflated,
    );
    return RfbRectDecodeResult(cursor: cursor);
  }

  void _validateRectBounds(
    VncFramebuffer framebuffer,
    int x,
    int y,
    int width,
    int height,
  ) {
    if (x < 0 ||
        y < 0 ||
        width < 0 ||
        height < 0 ||
        x + width > framebuffer.width ||
        y + height > framebuffer.height) {
      throw VncProtocolException(
        'Rectangle ($x, $y, ${width}x$height) exceeds framebuffer '
        'bounds (${framebuffer.width}x${framebuffer.height})',
      );
    }
  }

  Future<RfbRectDecodeResult> _decodeRaw(
    BufferedByteReader reader,
    VncFramebuffer framebuffer,
    int x,
    int y,
    int width,
    int height,
  ) async {
    _validateRectBounds(framebuffer, x, y, width, height);
    if (width == 0 || height == 0) {
      return const RfbRectDecodeResult();
    }

    final data = await reader.readBytes(width * height * 4);
    _blitWireRgba(framebuffer, x, y, width, height, data);
    return const RfbRectDecodeResult(pixelsUpdated: true);
  }

  void _blitWireRgba(
    VncFramebuffer framebuffer,
    int x,
    int y,
    int width,
    int height,
    Uint8List data,
  ) {
    final fbPixels = framebuffer.pixels;
    final fbWidth = framebuffer.width;
    var srcIdx = 0;
    for (var row = 0; row < height; row++) {
      var dstIdx = ((y + row) * fbWidth + x) * 4;
      for (var col = 0; col < width; col++) {
        fbPixels[dstIdx] = data[srcIdx];
        fbPixels[dstIdx + 1] = data[srcIdx + 1];
        fbPixels[dstIdx + 2] = data[srcIdx + 2];
        fbPixels[dstIdx + 3] = 0xFF;
        srcIdx += 4;
        dstIdx += 4;
      }
    }
  }

  Future<RfbRectDecodeResult> _decodeCopyRect(
    BufferedByteReader reader,
    VncFramebuffer framebuffer,
    int x,
    int y,
    int width,
    int height,
  ) async {
    _validateRectBounds(framebuffer, x, y, width, height);
    final srcX = await reader.readUint16();
    final srcY = await reader.readUint16();
    framebuffer.copyRect(srcX, srcY, x, y, width, height);
    return RfbRectDecodeResult(pixelsUpdated: width > 0 && height > 0);
  }

  Future<RfbRectDecodeResult> _decodeHextile(
    BufferedByteReader reader,
    VncFramebuffer framebuffer,
    int x,
    int y,
    int width,
    int height,
  ) async {
    _validateRectBounds(framebuffer, x, y, width, height);
    if (width == 0 || height == 0) {
      return const RfbRectDecodeResult();
    }

    var bgR = 0;
    var bgG = 0;
    var bgB = 0;
    var fgR = 0;
    var fgG = 0;
    var fgB = 0;

    final endY = y + height;
    final endX = x + width;

    for (var ty = y; ty < endY; ty += 16) {
      final th = math.min(16, endY - ty);
      for (var tx = x; tx < endX; tx += 16) {
        final tw = math.min(16, endX - tx);
        final mask = await reader.readUint8();

        if ((mask & 1) != 0) {
          // Raw tile
          final rawBytes = await reader.readBytes(tw * th * 4);
          _blitWireRgba(framebuffer, tx, ty, tw, th, rawBytes);
          continue;
        }

        if ((mask & 2) != 0) {
          // BackgroundSpecified
          final bg = await reader.readBytes(4);
          bgR = bg[0];
          bgG = bg[1];
          bgB = bg[2];
        }
        framebuffer.fillRect(tx, ty, tw, th, bgR, bgG, bgB);

        if ((mask & 4) != 0) {
          // ForegroundSpecified
          final fg = await reader.readBytes(4);
          fgR = fg[0];
          fgG = fg[1];
          fgB = fg[2];
        }

        if ((mask & 8) != 0) {
          // AnySubrects
          final numSubrects = await reader.readUint8();
          final subrectsColoured = (mask & 16) != 0;
          final entryBytes = subrectsColoured ? 6 : 2;
          final subrectBytes = await reader.readBytes(numSubrects * entryBytes);
          var off = 0;
          for (var i = 0; i < numSubrects; i++) {
            int srR;
            int srG;
            int srB;
            if (subrectsColoured) {
              srR = subrectBytes[off];
              srG = subrectBytes[off + 1];
              srB = subrectBytes[off + 2];
              off += 4;
            } else {
              srR = fgR;
              srG = fgG;
              srB = fgB;
            }
            final xy = subrectBytes[off++];
            final wh = subrectBytes[off++];
            final sx = xy >> 4;
            final sy = xy & 0x0F;
            final sw = (wh >> 4) + 1;
            final sh = (wh & 0x0F) + 1;
            if (sx + sw > tw || sy + sh > th) {
              throw VncProtocolException(
                'Hextile subrect ($sx, $sy, ${sw}x$sh) exceeds tile '
                'bounds (${tw}x$th)',
              );
            }
            framebuffer.fillRect(tx + sx, ty + sy, sw, sh, srR, srG, srB);
          }
        }
      }
    }

    return const RfbRectDecodeResult(pixelsUpdated: true);
  }

  Future<RfbRectDecodeResult> _decodeZrle(
    BufferedByteReader reader,
    VncFramebuffer framebuffer,
    int x,
    int y,
    int width,
    int height,
  ) async {
    _validateRectBounds(framebuffer, x, y, width, height);
    final compressedLength = await reader.readUint32();
    if (compressedLength > maxZrleCompressedBytes) {
      throw VncProtocolException(
        'ZRLE compressed length $compressedLength exceeds limit '
        '($maxZrleCompressedBytes bytes)',
      );
    }

    final compressed = await reader.readBytes(compressedLength);
    final inflated = _inflateZrle(compressed);

    if (width == 0 || height == 0) {
      return const RfbRectDecodeResult();
    }

    final cursor = _ByteCursor(inflated);
    final fbPixels = framebuffer.pixels;
    final fbWidth = framebuffer.width;
    final endY = y + height;
    final endX = x + width;

    for (var ty = y; ty < endY; ty += 64) {
      final th = math.min(64, endY - ty);
      for (var tx = x; tx < endX; tx += 64) {
        final tw = math.min(64, endX - tx);
        final subencoding = cursor.nextByte();

        if (subencoding == 0) {
          // Raw CPIXELs (3 bytes each: R, G, B)
          cursor.ensureRemaining(tw * th * 3);
          for (var row = 0; row < th; row++) {
            var dstIdx = ((ty + row) * fbWidth + tx) * 4;
            for (var col = 0; col < tw; col++) {
              fbPixels[dstIdx] = cursor.nextByteUnchecked();
              fbPixels[dstIdx + 1] = cursor.nextByteUnchecked();
              fbPixels[dstIdx + 2] = cursor.nextByteUnchecked();
              fbPixels[dstIdx + 3] = 0xFF;
              dstIdx += 4;
            }
          }
        } else if (subencoding == 1) {
          // Solid tile
          cursor.ensureRemaining(3);
          final r = cursor.nextByteUnchecked();
          final g = cursor.nextByteUnchecked();
          final b = cursor.nextByteUnchecked();
          framebuffer.fillRect(tx, ty, tw, th, r, g, b);
        } else if (subencoding >= 2 && subencoding <= 16) {
          // Packed palette
          final paletteSize = subencoding;
          cursor.ensureRemaining(paletteSize * 3);
          final paletteOffset = cursor.offset;
          cursor.advance(paletteSize * 3);

          final bitsPerIndex = paletteSize == 2
              ? 1
              : paletteSize <= 4
              ? 2
              : 4;
          final pixelsPerByte = 8 ~/ bitsPerIndex;
          final rowBytes = (tw + pixelsPerByte - 1) ~/ pixelsPerByte;
          final indexMask = (1 << bitsPerIndex) - 1;
          cursor.ensureRemaining(rowBytes * th);

          for (var row = 0; row < th; row++) {
            final rowBase = ((ty + row) * fbWidth + tx) * 4;
            for (var col = 0; col < tw;) {
              final packed = cursor.nextByteUnchecked();
              for (
                var shift = 8 - bitsPerIndex;
                shift >= 0 && col < tw;
                shift -= bitsPerIndex, col++
              ) {
                final idx = (packed >> shift) & indexMask;
                if (idx >= paletteSize) {
                  throw VncProtocolException(
                    'ZRLE packed palette index $idx out of range '
                    '(palette size $paletteSize)',
                  );
                }
                final pOff = paletteOffset + idx * 3;
                final dstIdx = rowBase + col * 4;
                fbPixels[dstIdx] = inflated[pOff];
                fbPixels[dstIdx + 1] = inflated[pOff + 1];
                fbPixels[dstIdx + 2] = inflated[pOff + 2];
                fbPixels[dstIdx + 3] = 0xFF;
              }
            }
          }
        } else if (subencoding == 128) {
          // Plain RLE
          final tilePixels = tw * th;
          var written = 0;
          var px = 0;
          var py = 0;
          while (written < tilePixels) {
            cursor.ensureRemaining(3);
            final r = cursor.nextByteUnchecked();
            final g = cursor.nextByteUnchecked();
            final b = cursor.nextByteUnchecked();
            final runLength = _readZrleRunLength(cursor, tilePixels - written);
            for (var i = 0; i < runLength; i++) {
              final dstIdx = ((ty + py) * fbWidth + tx + px) * 4;
              fbPixels[dstIdx] = r;
              fbPixels[dstIdx + 1] = g;
              fbPixels[dstIdx + 2] = b;
              fbPixels[dstIdx + 3] = 0xFF;
              px++;
              if (px == tw) {
                px = 0;
                py++;
              }
            }
            written += runLength;
          }
        } else if (subencoding >= 130 && subencoding <= 255) {
          // Palette RLE
          final paletteSize = subencoding - 128;
          cursor.ensureRemaining(paletteSize * 3);
          final paletteOffset = cursor.offset;
          cursor.advance(paletteSize * 3);

          final tilePixels = tw * th;
          var written = 0;
          var px = 0;
          var py = 0;
          while (written < tilePixels) {
            final idxByte = cursor.nextByte();
            final int idx;
            final int runLength;
            if ((idxByte & 0x80) == 0) {
              idx = idxByte;
              runLength = 1;
            } else {
              idx = idxByte & 0x7F;
              runLength = _readZrleRunLength(cursor, tilePixels - written);
            }
            if (idx >= paletteSize) {
              throw VncProtocolException(
                'ZRLE palette RLE index $idx out of range '
                '(palette size $paletteSize)',
              );
            }
            final pOff = paletteOffset + idx * 3;
            final r = inflated[pOff];
            final g = inflated[pOff + 1];
            final b = inflated[pOff + 2];
            for (var i = 0; i < runLength; i++) {
              final dstIdx = ((ty + py) * fbWidth + tx + px) * 4;
              fbPixels[dstIdx] = r;
              fbPixels[dstIdx + 1] = g;
              fbPixels[dstIdx + 2] = b;
              fbPixels[dstIdx + 3] = 0xFF;
              px++;
              if (px == tw) {
                px = 0;
                py++;
              }
            }
            written += runLength;
          }
        } else {
          throw VncProtocolException(
            'Unsupported ZRLE subencoding: $subencoding',
          );
        }
      }
    }

    return const RfbRectDecodeResult(pixelsUpdated: true);
  }

  Uint8List _inflateZrle(Uint8List compressed) {
    try {
      if (compressed.isNotEmpty) {
        _zrleInflater.process(compressed, 0, compressed.length);
      }
      final builder = BytesBuilder(copy: false);
      while (true) {
        final chunk = _zrleInflater.processed(flush: false, end: false);
        if (chunk == null) {
          break;
        }
        if (builder.length + chunk.length > maxZrleInflatedBytes) {
          throw VncProtocolException(
            'ZRLE inflated payload exceeds maximum allowed size '
            '($maxZrleInflatedBytes bytes)',
          );
        }
        builder.add(chunk);
      }
      return builder.takeBytes();
    } on VncProtocolException {
      rethrow;
    } catch (e) {
      throw VncProtocolException('Failed to inflate ZRLE stream', e);
    }
  }

  int _readZrleRunLength(_ByteCursor cursor, int maxRemaining) {
    var length = 1;
    while (true) {
      final byte = cursor.nextByte();
      length += byte;
      if (length > maxRemaining) {
        throw VncProtocolException(
          'ZRLE RLE run length $length exceeds remaining tile pixels '
          '($maxRemaining)',
        );
      }
      if (byte != 255) {
        return length;
      }
    }
  }

  Future<RfbRectDecodeResult> _decodeExtendedDesktopSize(
    BufferedByteReader reader,
    VncFramebuffer framebuffer,
    int width,
    int height,
  ) async {
    final numScreens = await reader.readUint8();
    await reader.skip(3); // padding
    final screens = <VncScreenInfo>[];
    for (var i = 0; i < numScreens; i++) {
      final id = await reader.readUint32();
      final sx = await reader.readUint16();
      final sy = await reader.readUint16();
      final sw = await reader.readUint16();
      final sh = await reader.readUint16();
      final flags = await reader.readUint32();
      if (sw > 0 && sh > 0) {
        screens.add(
          VncScreenInfo(
            id: id,
            x: sx,
            y: sy,
            width: sw,
            height: sh,
            flags: flags,
          ),
        );
      }
    }
    final resized = width > 0 && height > 0;
    if (resized) {
      framebuffer.resize(width, height);
    }
    return RfbRectDecodeResult(
      resized: resized,
      screens: List<VncScreenInfo>.unmodifiable(screens),
    );
  }

  Future<RfbRectDecodeResult> _decodeCursor(
    BufferedByteReader reader,
    int hotspotX,
    int hotspotY,
    int width,
    int height,
  ) async {
    if (width < 0 ||
        height < 0 ||
        width > VncFramebuffer.maxDimension ||
        height > VncFramebuffer.maxDimension) {
      throw VncProtocolException('Invalid cursor dimensions: ${width}x$height');
    }
    if (width == 0 || height == 0) {
      return RfbRectDecodeResult(
        cursor: VncCursorData(
          width: 0,
          height: 0,
          hotspotX: hotspotX,
          hotspotY: hotspotY,
          rgbaPixels: Uint8List(0),
        ),
      );
    }

    final pixelBytes = await reader.readBytes(width * height * 4);
    final maskRowBytes = (width + 7) ~/ 8;
    final maskBytes = await reader.readBytes(maskRowBytes * height);

    final rgba = Uint8List(width * height * 4);
    for (var cy = 0; cy < height; cy++) {
      final maskRowOffset = cy * maskRowBytes;
      for (var cx = 0; cx < width; cx++) {
        final pxOffset = (cy * width + cx) * 4;
        final isOpaque =
            (maskBytes[maskRowOffset + (cx >> 3)] & (0x80 >> (cx & 7))) != 0;
        rgba[pxOffset] = pixelBytes[pxOffset];
        rgba[pxOffset + 1] = pixelBytes[pxOffset + 1];
        rgba[pxOffset + 2] = pixelBytes[pxOffset + 2];
        rgba[pxOffset + 3] = isOpaque ? 0xFF : 0x00;
      }
    }

    return RfbRectDecodeResult(
      cursor: VncCursorData(
        width: width,
        height: height,
        hotspotX: hotspotX,
        hotspotY: hotspotY,
        rgbaPixels: rgba,
      ),
    );
  }
}

class _ByteCursor {
  _ByteCursor(this._data);

  final Uint8List _data;
  int _offset = 0;

  int get offset => _offset;

  int nextByte() {
    if (_offset >= _data.length) {
      throw const VncProtocolException('Truncated ZRLE stream');
    }
    return _data[_offset++];
  }

  int nextByteUnchecked() => _data[_offset++];

  void ensureRemaining(int count) {
    final remaining = _data.length - _offset;
    if (count > remaining) {
      throw VncProtocolException(
        'Truncated ZRLE stream: expected $count bytes, '
        'only $remaining remaining',
      );
    }
  }

  void advance(int count) {
    _offset += count;
  }
}
