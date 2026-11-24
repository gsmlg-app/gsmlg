import 'dart:convert';
import 'dart:typed_data';

import '../models/vnc_exceptions.dart';
import '../models/vnc_models.dart';
import '../transport/vnc_transport.dart';
import 'byte_reader.dart';
import 'framebuffer.dart';

/// Post-handshake RFB/VNC message loop and client-to-server wire writers
/// (RFC 6143 §7.5 & §7.6).
class RfbSession {
  RfbSession({
    required VncTransport transport,
    required BufferedByteReader reader,
    required VncFramebuffer framebuffer,
    RfbRectDecoder? decoder,
  }) : _transport = transport,
       _reader = reader,
       _framebuffer = framebuffer,
       _decoder = decoder ?? RfbRectDecoder();

  /// Maximum accepted client or server cut-text payload length (1 MiB).
  static const int maxCutTextLength = 1024 * 1024;

  static const int _msgFramebufferUpdate = 0;
  static const int _msgSetColourMapEntries = 1;
  static const int _msgBell = 2;
  static const int _msgServerCutText = 3;

  static const int _clientMsgFramebufferUpdateRequest = 3;
  static const int _clientMsgKeyEvent = 4;
  static const int _clientMsgPointerEvent = 5;
  static const int _clientMsgClientCutText = 6;

  final VncTransport _transport;
  final BufferedByteReader _reader;
  final VncFramebuffer _framebuffer;
  final RfbRectDecoder _decoder;

  /// Sends a `FramebufferUpdateRequest` (RFC 6143 §7.5.3).
  void requestFramebufferUpdate({
    required bool incremental,
    int x = 0,
    int y = 0,
    int? width,
    int? height,
  }) {
    final reqX = x.clamp(0, 0xFFFF);
    final reqY = y.clamp(0, 0xFFFF);
    final reqWidth = (width ?? _framebuffer.width).clamp(0, 0xFFFF);
    final reqHeight = (height ?? _framebuffer.height).clamp(0, 0xFFFF);

    final bytes = Uint8List(10);
    ByteData.sublistView(bytes)
      ..setUint8(0, _clientMsgFramebufferUpdateRequest)
      ..setUint8(1, incremental ? 1 : 0)
      ..setUint16(2, reqX, Endian.big)
      ..setUint16(4, reqY, Endian.big)
      ..setUint16(6, reqWidth, Endian.big)
      ..setUint16(8, reqHeight, Endian.big);
    _transport.add(bytes);
  }

  /// Sends a `KeyEvent` (RFC 6143 §7.5.4).
  void sendKeyEvent(int keysym, {required bool down}) {
    final bytes = Uint8List(8);
    ByteData.sublistView(bytes)
      ..setUint8(0, _clientMsgKeyEvent)
      ..setUint8(1, down ? 1 : 0)
      ..setUint16(2, 0, Endian.big)
      ..setUint32(4, keysym & 0xFFFFFFFF, Endian.big);
    _transport.add(bytes);
  }

  /// Sends a `PointerEvent` (RFC 6143 §7.5.5), clamping coordinates to the
  /// current framebuffer dimensions.
  void sendPointerEvent(int x, int y, int buttonMask) {
    final maxX = _framebuffer.width > 0 ? _framebuffer.width - 1 : 0;
    final maxY = _framebuffer.height > 0 ? _framebuffer.height - 1 : 0;
    final clampedX = x.clamp(0, maxX);
    final clampedY = y.clamp(0, maxY);

    final bytes = Uint8List(6);
    ByteData.sublistView(bytes)
      ..setUint8(0, _clientMsgPointerEvent)
      ..setUint8(1, buttonMask & 0xFF)
      ..setUint16(2, clampedX, Endian.big)
      ..setUint16(4, clampedY, Endian.big);
    _transport.add(bytes);
  }

  /// Sends a `ClientCutText` message (RFC 6143 §7.5.6) encoded as ISO-8859-1
  /// (Latin-1), replacing non-Latin-1 code units with `?` (`0x3F`) and bounding
  /// the payload to [maxCutTextLength] bytes.
  void sendClientCutText(String text) {
    final length = text.length > maxCutTextLength
        ? maxCutTextLength
        : text.length;
    final bytes = Uint8List(8 + length);
    ByteData.sublistView(bytes)
      ..setUint8(0, _clientMsgClientCutText)
      ..setUint8(1, 0)
      ..setUint8(2, 0)
      ..setUint8(3, 0)
      ..setUint32(4, length, Endian.big);
    for (var i = 0; i < length; i++) {
      final codeUnit = text.codeUnitAt(i);
      bytes[8 + i] = codeUnit <= 0xFF ? codeUnit : 0x3F;
    }
    _transport.add(bytes);
  }

  /// Runs the RFB server-to-client message loop until [shouldStop] returns
  /// `true` or the connection closes/errors.
  Future<void> runMessageLoop({
    void Function()? onFrameUpdated,
    void Function(int width, int height)? onDesktopResized,
    void Function(VncCursorData cursor)? onCursorUpdated,
    void Function(String text)? onServerCutText,
    void Function()? onBell,
    bool Function()? shouldStop,
  }) async {
    requestFramebufferUpdate(incremental: false);

    while (!(shouldStop?.call() ?? false)) {
      final messageType = await _reader.readUint8();
      if (shouldStop?.call() ?? false) {
        break;
      }

      switch (messageType) {
        case _msgFramebufferUpdate:
          await _handleFramebufferUpdate(
            onFrameUpdated: onFrameUpdated,
            onDesktopResized: onDesktopResized,
            onCursorUpdated: onCursorUpdated,
            shouldStop: shouldStop,
          );
        case _msgSetColourMapEntries:
          await _reader.skip(1);
          await _reader.readUint16(); // firstColour
          final numColours = await _reader.readUint16();
          await _reader.skip(numColours * 6);
        case _msgBell:
          onBell?.call();
        case _msgServerCutText:
          await _reader.skip(3);
          final length = await _reader.readUint32();
          if (length > maxCutTextLength) {
            throw VncProtocolException(
              'ServerCutText length $length exceeds limit '
              '($maxCutTextLength bytes)',
            );
          }
          final bytes = await _reader.readBytes(length);
          final text = latin1.decode(bytes, allowInvalid: true);
          onServerCutText?.call(text);
        default:
          throw VncProtocolException(
            'Unknown RFB server message type: $messageType',
          );
      }
    }
  }

  Future<void> _handleFramebufferUpdate({
    void Function()? onFrameUpdated,
    void Function(int width, int height)? onDesktopResized,
    void Function(VncCursorData cursor)? onCursorUpdated,
    bool Function()? shouldStop,
  }) async {
    await _reader.skip(1); // padding
    final numRects = await _reader.readUint16();

    var anyPixels = false;
    var anyResize = false;
    VncCursorData? latestCursor;

    for (var i = 0; i < numRects; i++) {
      final rx = await _reader.readUint16();
      final ry = await _reader.readUint16();
      final rw = await _reader.readUint16();
      final rh = await _reader.readUint16();
      final encoding = await _reader.readInt32();

      final result = await _decoder.decodeRectangle(
        reader: _reader,
        framebuffer: _framebuffer,
        x: rx,
        y: ry,
        width: rw,
        height: rh,
        encoding: encoding,
      );
      if (result.isLastRect) {
        break;
      }
      if (result.resized) {
        anyResize = true;
      }
      if (result.cursor != null) {
        latestCursor = result.cursor;
      }
      if (result.pixelsUpdated) {
        anyPixels = true;
      }
    }

    if (anyResize) {
      onDesktopResized?.call(_framebuffer.width, _framebuffer.height);
    }
    if (latestCursor != null) {
      onCursorUpdated?.call(latestCursor);
    }
    if (anyPixels) {
      onFrameUpdated?.call();
    }

    if (!(shouldStop?.call() ?? false)) {
      requestFramebufferUpdate(incremental: !anyResize);
    }
  }
}
