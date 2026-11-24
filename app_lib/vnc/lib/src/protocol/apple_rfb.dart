import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../models/vnc_exceptions.dart';
import '../models/vnc_models.dart';
import 'rfb_encodings.dart';

/// Apple RFB `003.889` encoding and pseudo-encoding identifiers.
abstract final class AppleRfbEncoding {
  static const int zlib = 6;
  static const int cursorPos = 0x44c;
  static const int displayInfo = 0x44d;
  static const int rekey = 0x44f;
  static const int cursorImage = 0x450;
  static const int displayLayout = 0x451;
  static const int vendorKeysyms = 0x453;
  static const int keyboardSource = 0x455;

  /// Default preferred encodings advertised to macOS Screen Sharing over
  /// `RFB 003.889`.
  ///
  /// Listing `ZRLE` without `zlib` instructs macOS to send `ZRLE`, which
  /// [RfbRectDecoder] decodes natively, while advertising both [displayInfo]
  /// and [displayLayout] instructs macOS to emit `AppleDisplayLayout` (`0x451`).
  static const List<int> defaultEncodings = [
    RfbEncoding.raw,
    cursorPos,
    displayInfo,
    rekey,
    cursorImage,
    displayLayout,
    vendorKeysyms,
    keyboardSource,
    RfbEncoding.desktopSize,
    RfbEncoding.lastRect,
    RfbEncoding.zrle,
  ];
}

/// Wire builders for Apple RFB `003.889` client-to-server control messages.
abstract final class AppleRfbMessages {
  /// `ViewerInfo` (`0x21`): 66-byte numeric viewer identification and server
  /// capability bitmap measured against macOS 26 Screen Sharing.
  static Uint8List viewerInfo() {
    final msg = Uint8List(66);
    ByteData.sublistView(msg)
      ..setUint8(0, 0x21)
      ..setUint16(2, 62, Endian.big)
      ..setUint16(4, 1, Endian.big) // generic viewer
      ..setUint32(6, 2, Endian.big) // Screen Sharing
      ..setUint32(10, 6, Endian.big) // app major
      ..setUint32(14, 1, Endian.big) // app minor
      // bytes 18..21 = app patch (0)
      ..setUint32(22, 26, Endian.big) // OS major
      ..setUint32(26, 6, Endian.big) // OS minor
      ..setUint32(30, 2, Endian.big); // OS patch
    msg[34] = 0xb0;
    msg[36] = 0x0c;
    msg[37] = 0x03;
    msg[38] = 0x90;
    msg[44] = 0x40;
    return msg;
  }

  /// `SetMode(control)` (`0x0a`): requests an interactive controlling session.
  static Uint8List setModeControl() =>
      Uint8List.fromList(const [0x0a, 0x00, 0x00, 0x01]);

  /// `SetEncryption(command = 1)` (`0x12`): requests AES-128 record layer
  /// activation (triggers server `0x44f` rekey rectangle).
  static Uint8List setEncryptionStart() => Uint8List.fromList(const [
    0x12,
    0x00,
    0x00,
    0x01,
    0x00,
    0x01,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
  ]);

  /// `SetEncryption(command = 2, argument = 1)` (`0x12`): instructs the Mac to
  /// decrypt incoming client records after the rekey.
  static Uint8List enableInboundRecordDecryption() => Uint8List.fromList(const [
    0x12,
    0x00,
    0x00,
    0x02,
    0x00,
    0x01,
    0x00,
    0x00,
  ]);

  /// `SetDisplay` (`0x0d`): selects a single physical display by [displayId],
  /// or `null` to combine all displays into one framebuffer.
  static Uint8List setDisplay(int? displayId) {
    if (displayId == null) {
      return Uint8List.fromList(const [
        0x0d,
        0x01,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
      ]);
    }
    return Uint8List.fromList([
      0x0d,
      0x00,
      0x00,
      0x00,
      (displayId >> 24) & 0xFF,
      (displayId >> 16) & 0xFF,
      (displayId >> 8) & 0xFF,
      displayId & 0xFF,
    ]);
  }

  /// `AutoFrameBufferUpdate` (`0x09`): arms macOS server-driven updates over
  /// `(0, 0, width, height)` paced at [intervalUs] microseconds.
  static Uint8List autoFramebufferUpdate({
    required int intervalUs,
    required int width,
    required int height,
  }) {
    final msg = Uint8List(16);
    ByteData.sublistView(msg)
      ..setUint8(0, 0x09)
      ..setUint8(1, 0x00)
      ..setUint16(2, 1, Endian.big)
      ..setUint32(4, intervalUs & 0xFFFFFFFF, Endian.big)
      ..setUint16(8, 0, Endian.big)
      ..setUint16(10, 0, Endian.big)
      ..setUint16(12, width.clamp(0, 0xFFFF), Endian.big)
      ..setUint16(14, height.clamp(0, 0xFFFF), Endian.big);
    return msg;
  }
}

/// Parsed macOS `AppleDisplayLayout` (`0x451`) payload.
@immutable
class AppleDisplayLayout {
  const AppleDisplayLayout({
    required this.backingWidth,
    required this.backingHeight,
    required this.currentDisplayId,
    required this.displays,
  });

  static const int _headerLength = 0x14;
  static const int _recordLength = 0x38;
  static const int _maxDisplays = 25;
  static const int _combinedSentinel = 0xFFFFFFFF;
  static const int _flagInMirrorSet = 0x02;

  /// Active framebuffer width in pixels.
  final int backingWidth;

  /// Active framebuffer height in pixels.
  final int backingHeight;

  /// Selected display ID, or `null` when the server is streaming all displays
  /// combined (`0xFFFFFFFF`).
  final int? currentDisplayId;

  /// Deduplicated physical/virtual displays reported by macOS.
  final List<VncScreenInfo> displays;

  /// Parses an `AppleDisplayLayout` payload (the bytes following the leading
  /// `u16` length prefix).
  static AppleDisplayLayout parse(Uint8List payload) {
    if (payload.length < _headerLength) {
      throw VncProtocolException(
        'AppleDisplayLayout payload too short: ${payload.length} bytes',
      );
    }

    final bd = ByteData.sublistView(payload);
    final backingWidth = bd.getUint16(0x06, Endian.big);
    final backingHeight = bd.getUint16(0x08, Endian.big);
    if (backingWidth <= 0 || backingHeight <= 0) {
      throw VncProtocolException(
        'Invalid AppleDisplayLayout framebuffer size: '
        '${backingWidth}x$backingHeight',
      );
    }

    final rawCurrent = bd.getUint32(0x0a, Endian.big);
    final currentDisplayId = rawCurrent == _combinedSentinel
        ? null
        : rawCurrent;

    final count = bd.getUint16(0x12, Endian.big);
    if (count < 1 || count > _maxDisplays) {
      throw VncProtocolException(
        'Invalid AppleDisplayLayout display count: $count',
      );
    }

    final requiredLength = _headerLength + count * _recordLength;
    if (payload.length < requiredLength) {
      throw VncProtocolException(
        'AppleDisplayLayout truncated: expected at least $requiredLength bytes '
        'for $count display(s), got ${payload.length}',
      );
    }

    final displays = <VncScreenInfo>[];
    final seenOrigins = <(int, int)>{};

    for (var i = 0; i < count; i++) {
      final base = _headerLength + i * _recordLength;
      final id = bd.getUint32(base + 0x10, Endian.big);
      final flags = bd.getUint32(base + 0x24, Endian.big);

      final originKey = (
        bd.getUint16(base + 0x14, Endian.big),
        bd.getUint16(base + 0x16, Endian.big),
      );
      if ((flags & _flagInMirrorSet) != 0 && seenOrigins.contains(originKey)) {
        continue;
      }

      final logicalTop = bd.getInt16(base + 0x14, Endian.big);
      final logicalLeft = bd.getInt16(base + 0x16, Endian.big);
      final logicalBottom = bd.getInt16(base + 0x18, Endian.big);
      final logicalRight = bd.getInt16(base + 0x1a, Endian.big);

      final backingTop = bd.getInt16(base + 0x1c, Endian.big);
      final backingLeft = bd.getInt16(base + 0x1e, Endian.big);
      final backingBottom = bd.getInt16(base + 0x20, Endian.big);
      final backingRight = bd.getInt16(base + 0x22, Endian.big);

      final logicalW = logicalRight - logicalLeft;
      final logicalH = logicalBottom - logicalTop;
      if (logicalW <= 0 || logicalH <= 0) {
        continue;
      }

      final rawBw = backingRight - backingLeft;
      final rawBh = backingBottom - backingTop;
      final bw = rawBw > 0 ? rawBw : logicalW;
      final bh = rawBh > 0 ? rawBh : logicalH;

      seenOrigins.add(originKey);
      displays.add(
        VncScreenInfo(
          id: id,
          x: backingLeft,
          y: backingTop,
          width: bw,
          height: bh,
          flags: flags,
        ),
      );
    }

    if (displays.isEmpty) {
      throw const VncProtocolException(
        'AppleDisplayLayout contained no usable displays',
      );
    }

    return AppleDisplayLayout(
      backingWidth: backingWidth,
      backingHeight: backingHeight,
      currentDisplayId: currentDisplayId,
      displays: List<VncScreenInfo>.unmodifiable(displays),
    );
  }
}

/// Caches macOS `AppleCursorImage` (`0x450`) cursor shapes by server-assigned
/// cache ID.
///
/// Each stored cursor is an independent zlib stream containing `w * h * 4`
/// BGRA bytes followed by a separate `w * h` alpha plane. A zero-length payload
/// selects a previously cached shape by ID.
class AppleCursorCache {
  /// Maximum cursor width or height accepted in pixels.
  static const int maxCursorDimension = 512;

  /// Maximum compressed cursor payload size accepted (4 MiB).
  static const int maxCompressedBytes = 4 * 1024 * 1024;

  final Map<int, VncCursorData> _shapes = <int, VncCursorData>{};

  /// Processes a single `AppleCursorImage` (`0x450`) rectangle.
  ///
  /// Returns the decoded or cached [VncCursorData], or `null` if [id] is not
  /// cached or if the compressed cursor image is malformed.
  VncCursorData? accept({
    required int id,
    required int hotspotX,
    required int hotspotY,
    required int width,
    required int height,
    required Uint8List deflated,
  }) {
    if (deflated.isEmpty) {
      return _shapes[id];
    }

    if (width <= 0 ||
        height <= 0 ||
        width > maxCursorDimension ||
        height > maxCursorDimension) {
      return null;
    }

    final pixels = width * height;
    final expectedLength = pixels * 5;

    final List<int> inflated;
    try {
      inflated = ZLibDecoder().convert(deflated);
    } catch (_) {
      return null;
    }

    if (inflated.length != expectedLength) {
      return null;
    }

    final rgba = Uint8List(pixels * 4);
    final alphaBase = pixels * 4;
    for (var i = 0; i < pixels; i++) {
      final p = i * 4;
      rgba[p] = inflated[p + 2]; // R
      rgba[p + 1] = inflated[p + 1]; // G
      rgba[p + 2] = inflated[p]; // B
      rgba[p + 3] = inflated[alphaBase + i]; // A
    }

    final cursor = VncCursorData(
      width: width,
      height: height,
      hotspotX: hotspotX,
      hotspotY: hotspotY,
      rgbaPixels: rgba,
    );
    _shapes[id] = cursor;
    return cursor;
  }
}
