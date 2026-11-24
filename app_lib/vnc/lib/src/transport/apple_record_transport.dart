import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart' show KeyParameter;
import 'package:pointycastle/block/aes.dart';

import '../models/vnc_exceptions.dart';
import '../protocol/byte_reader.dart';
import 'vnc_transport.dart';

/// Apple RFB `003.889` AES-128-CBC encrypted record-layer transport.
///
/// Each record has the wire format:
/// ```text
/// u16 ciphertext_len || AES-128-CBC(u16 body_len || body || zero_filler || sha1_trailer)
/// ```
/// where `sha1_trailer = SHA1(u32_be(seq) || u16 body_len || body || zero_filler)`.
///
/// Outbound and inbound directions each maintain an independent persistent
/// AES-128-CBC chaining block and 32-bit sequence counter for the entire
/// session.
class AppleRecordVncTransport implements VncTransport {
  AppleRecordVncTransport({
    required VncTransport inner,
    required BufferedByteReader innerReader,
    required Uint8List key,
    required Uint8List iv,
  }) : _inner = inner,
       _innerReader = innerReader {
    if (key.length != blockSize) {
      throw ArgumentError.value(
        key.length,
        'key',
        'Apple record key must be $blockSize bytes',
      );
    }
    if (iv.length != blockSize) {
      throw ArgumentError.value(
        iv.length,
        'iv',
        'Apple record IV must be $blockSize bytes',
      );
    }

    final keyCopy = Uint8List.fromList(key);
    try {
      _encEngine = AESEngine()..init(true, KeyParameter(keyCopy));
      _decEngine = AESEngine()..init(false, KeyParameter(keyCopy));
    } finally {
      keyCopy.fillRange(0, keyCopy.length, 0);
    }

    _encChain = Uint8List.fromList(iv);
    _decChain = Uint8List.fromList(iv);

    _controller = StreamController<Uint8List>(
      onListen: _startReadLoop,
      onCancel: () {
        unawaited(close());
      },
    );
  }

  /// AES block size in bytes.
  static const int blockSize = 16;

  /// Length of the SHA-1 integrity trailer in bytes.
  static const int trailerLength = 20;

  /// Length of the `u16 body_len` field inside each record's plaintext.
  static const int bodyLenFieldLength = 2;

  /// Length of the `0x44f` rekey rectangle body (`u32 generation` + wrapped
  /// 16-byte key + wrapped 16-byte IV).
  static const int rekeyLength = 36;

  /// Smallest legal ciphertext record size (`2 + 0 + 10 filler + 20 trailer`).
  static const int minCiphertextLength = 32;

  /// Largest legal ciphertext record size representable as a whole multiple of
  /// [blockSize] in a `u16`.
  static const int maxCiphertextLength = 65520;

  /// Largest plaintext payload carried by a single record.
  static const int maxBodyLength =
      maxCiphertextLength - bodyLenFieldLength - trailerLength;

  final VncTransport _inner;
  final BufferedByteReader _innerReader;
  late final AESEngine _encEngine;
  late final AESEngine _decEngine;
  late final Uint8List _encChain;
  late final Uint8List _decChain;

  int _encSeq = 0;
  int _decSeq = 0;

  final Completer<void> _doneCompleter = Completer<void>();
  late final StreamController<Uint8List> _controller;
  bool _readLoopStarted = false;
  bool _closing = false;
  Future<void>? _closeFuture;

  /// Unwraps the 36-byte `0x44f` rekey rectangle body using [wrapKey16] in
  /// AES-128-ECB mode.
  static ({int generation, Uint8List key, Uint8List iv}) unwrapRekey(
    Uint8List wrapKey16,
    Uint8List rekeyBody36,
  ) {
    if (wrapKey16.length != blockSize) {
      throw ArgumentError.value(
        wrapKey16.length,
        'wrapKey16',
        'Wrap key must be $blockSize bytes',
      );
    }
    if (rekeyBody36.length != rekeyLength) {
      throw ArgumentError.value(
        rekeyBody36.length,
        'rekeyBody36',
        'Rekey body must be $rekeyLength bytes',
      );
    }

    final generation = ByteData.sublistView(
      rekeyBody36,
      0,
      4,
    ).getUint32(0, Endian.big);
    final aes = AESEngine()..init(false, KeyParameter(wrapKey16));
    final key = Uint8List(blockSize);
    final iv = Uint8List(blockSize);
    aes.processBlock(rekeyBody36, 4, key, 0);
    aes.processBlock(rekeyBody36, 4 + blockSize, iv, 0);
    return (generation: generation, key: key, iv: iv);
  }

  static Uint8List _computeTrailer(int seq, Uint8List covered) {
    final sink = _DigestSink();
    final input = sha1.startChunkedConversion(sink);
    final seqBytes = Uint8List(4);
    ByteData.sublistView(seqBytes).setUint32(0, seq, Endian.big);
    input.add(seqBytes);
    input.add(covered);
    input.close();
    return Uint8List.fromList(sink.value!.bytes);
  }

  void _completeDone() {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  void _startReadLoop() {
    if (_readLoopStarted) {
      return;
    }
    _readLoopStarted = true;
    unawaited(_runReadLoop());
  }

  Future<void> _runReadLoop() async {
    final blockBuf = Uint8List(blockSize);
    final savedCt = Uint8List(blockSize);
    try {
      while (!_closing && !_controller.isClosed) {
        final Uint8List lenBytes;
        try {
          lenBytes = await _innerReader.readBytes(2);
        } on VncConnectionException catch (e, st) {
          if (_closing || _controller.isClosed) {
            break;
          }
          if (e.cause != null) {
            _controller.addError(e, st);
            break;
          }
          if (e.message.contains('only 0 of 2')) {
            // Clean EOF between records.
            break;
          }
          _controller.addError(
            VncProtocolException(
              'Connection closed inside Apple record header',
              e,
            ),
            st,
          );
          break;
        }

        final ctLen = (lenBytes[0] << 8) | lenBytes[1];
        if (ctLen < minCiphertextLength || ctLen % blockSize != 0) {
          throw VncProtocolException(
            'Invalid Apple record ciphertext length: $ctLen',
          );
        }

        final Uint8List buf;
        try {
          buf = await _innerReader.readBytes(ctLen);
        } on VncConnectionException catch (e, st) {
          if (!_closing && !_controller.isClosed) {
            _controller.addError(e, st);
          }
          break;
        }

        // CBC-decrypt in-place, advancing the persistent receive chain.
        for (var pos = 0; pos < ctLen; pos += blockSize) {
          savedCt.setRange(0, blockSize, buf, pos);
          _decEngine.processBlock(buf, pos, blockBuf, 0);
          for (var j = 0; j < blockSize; j++) {
            buf[pos + j] = blockBuf[j] ^ _decChain[j];
          }
          _decChain.setRange(0, blockSize, savedCt, 0);
        }

        final coveredLen = ctLen - trailerLength;
        final expectedTrailer = _computeTrailer(
          _decSeq,
          Uint8List.sublistView(buf, 0, coveredLen),
        );
        _decSeq = (_decSeq + 1) & 0xFFFFFFFF;

        var diff = 0;
        for (var i = 0; i < trailerLength; i++) {
          diff |= buf[coveredLen + i] ^ expectedTrailer[i];
        }
        if (diff != 0) {
          throw const VncProtocolException(
            'Apple record integrity check failed',
          );
        }

        final bodyLen = (buf[0] << 8) | buf[1];
        if (bodyLen > ctLen - bodyLenFieldLength - trailerLength) {
          throw VncProtocolException(
            'Apple record body length $bodyLen exceeds ciphertext size $ctLen',
          );
        }

        if (bodyLen > 0 && !_controller.isClosed) {
          _controller.add(buf.sublist(2, 2 + bodyLen));
        }
      }
    } catch (e, st) {
      if (!_closing && !_controller.isClosed) {
        _controller.addError(e, st);
      }
    } finally {
      blockBuf.fillRange(0, blockBuf.length, 0);
      savedCt.fillRange(0, savedCt.length, 0);
      _decChain.fillRange(0, _decChain.length, 0);
      if (!_controller.isClosed) {
        unawaited(_controller.close());
      }
      _completeDone();
    }
  }

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  void add(Uint8List data) {
    if (_closeFuture != null) {
      throw StateError('Transport is closed');
    }
    if (data.isEmpty) {
      return;
    }

    final blockBuf = Uint8List(blockSize);
    try {
      for (var offset = 0; offset < data.length; offset += maxBodyLength) {
        final chunkLen = math.min(maxBodyLength, data.length - offset);
        final fillerLen =
            (blockSize -
                ((bodyLenFieldLength + chunkLen + trailerLength) % blockSize)) %
            blockSize;
        final coveredLen = bodyLenFieldLength + chunkLen + fillerLen;
        final ctLen = coveredLen + trailerLength;

        final wire = Uint8List(2 + ctLen);
        wire[0] = (ctLen >> 8) & 0xFF;
        wire[1] = ctLen & 0xFF;
        wire[2] = (chunkLen >> 8) & 0xFF;
        wire[3] = chunkLen & 0xFF;
        wire.setRange(4, 4 + chunkLen, data, offset);

        final trailer = _computeTrailer(
          _encSeq,
          Uint8List.sublistView(wire, 2, 2 + coveredLen),
        );
        _encSeq = (_encSeq + 1) & 0xFFFFFFFF;
        wire.setRange(2 + coveredLen, 2 + ctLen, trailer);

        for (var pos = 2; pos < 2 + ctLen; pos += blockSize) {
          for (var j = 0; j < blockSize; j++) {
            blockBuf[j] = wire[pos + j] ^ _encChain[j];
          }
          _encEngine.processBlock(blockBuf, 0, wire, pos);
          _encChain.setRange(0, blockSize, wire, pos);
        }

        _inner.add(wire);
      }
    } finally {
      blockBuf.fillRange(0, blockBuf.length, 0);
    }
  }

  @override
  Future<void> flush() => _inner.flush();

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> close() => _closeFuture ??= _closeInternal();

  Future<void> _closeInternal() async {
    _closing = true;
    try {
      await _innerReader.dispose();
    } catch (_) {
      // Suppress reader disposal errors on teardown.
    }
    try {
      await _inner.close();
    } catch (_) {
      // Suppress underlying transport close errors on teardown.
    } finally {
      _encChain.fillRange(0, _encChain.length, 0);
      if (!_controller.isClosed) {
        unawaited(_controller.close());
      }
      _completeDone();
    }
  }
}

class _DigestSink implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) {
    value = data;
  }

  @override
  void close() {}
}
