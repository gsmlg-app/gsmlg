import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:test/test.dart';

Uint8List _hexToBytes(String hex) {
  final clean = hex.replaceAll(RegExp(r'\s+'), '');
  final out = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

Uint8List _aesEcbEncrypt(Uint8List plaintext, Uint8List key) {
  final engine = AESEngine()..init(true, KeyParameter(key));
  final out = Uint8List(plaintext.length);
  for (var offset = 0; offset < plaintext.length; offset += 16) {
    engine.processBlock(plaintext, offset, out, offset);
  }
  return out;
}

Uint8List _aesEcbDecrypt(Uint8List ciphertext, Uint8List key) {
  final engine = AESEngine()..init(false, KeyParameter(key));
  final out = Uint8List(ciphertext.length);
  for (var offset = 0; offset < ciphertext.length; offset += 16) {
    engine.processBlock(ciphertext, offset, out, offset);
  }
  return out;
}

String _readNullTerminatedUtf8(Uint8List block, int start, int length) {
  var end = start;
  final limit = start + length;
  while (end < limit && block[end] != 0) {
    end++;
  }
  return utf8.decode(block.sublist(start, end));
}

// 128-byte (1024-bit) RFC 2409 Oakley Group 2 safe prime
final Uint8List _oakleyPrime128 = _hexToBytes(
  'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD1'
  '29024E088A67CC74020BBEA63B139B22514A08798E3404DD'
  'EF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245'
  'E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED'
  'EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381'
  'FFFFFFFFFFFFFFFF',
);

/// Paired in-memory [VncTransport] endpoints for testing record-layer round-trips.
class _PairedInMemoryTransport {
  final StreamController<Uint8List> _aToB = StreamController<Uint8List>();
  final StreamController<Uint8List> _bToA = StreamController<Uint8List>();

  late final _EndpointTransport a = _EndpointTransport(_bToA.stream, _aToB);
  late final _EndpointTransport b = _EndpointTransport(_aToB.stream, _bToA);

  /// Injects raw wire bytes directly from B toward A (for tampering tests).
  void injectRawToA(Uint8List wireBytes) {
    _bToA.add(wireBytes);
  }

  Future<void> dispose() async {
    await a.close();
    await b.close();
  }
}

class _EndpointTransport implements VncTransport {
  _EndpointTransport(this._inStream, this._outSink);

  final Stream<Uint8List> _inStream;
  final StreamController<Uint8List> _outSink;
  final Completer<void> _doneCompleter = Completer<void>();
  bool _closed = false;

  @override
  Stream<Uint8List> get stream => _inStream;

  @override
  void add(Uint8List data) {
    if (_closed) {
      throw StateError('Transport is closed');
    }
    _outSink.add(Uint8List.fromList(data));
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    if (!_outSink.isClosed) {
      unawaited(_outSink.close());
    }
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }
}

/// Socket-backed [VncTransport] wrapper used by mock TCP servers in tests so
/// the server side can also wrap its socket in [AppleRecordVncTransport].
class _SocketTransport implements VncTransport {
  _SocketTransport(this._socket);

  final Socket _socket;
  final Completer<void> _doneCompleter = Completer<void>();
  bool _closed = false;

  @override
  Stream<Uint8List> get stream => _socket;

  @override
  void add(Uint8List data) {
    if (_closed) {
      throw StateError('Transport is closed');
    }
    _socket.add(data);
  }

  @override
  Future<void> flush() => _socket.flush();

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    try {
      await _socket.close();
    } catch (_) {}
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }
}

class _TestDisplayRecord {
  const _TestDisplayRecord({
    required this.id,
    required this.logicalTop,
    required this.logicalLeft,
    required this.logicalBottom,
    required this.logicalRight,
    required this.backingTop,
    required this.backingLeft,
    required this.backingBottom,
    required this.backingRight,
    this.flags = 0,
  });

  final int id;
  final int logicalTop;
  final int logicalLeft;
  final int logicalBottom;
  final int logicalRight;
  final int backingTop;
  final int backingLeft;
  final int backingBottom;
  final int backingRight;
  final int flags;
}

Uint8List _buildAppleDisplayLayoutPayload({
  required int backingWidth,
  required int backingHeight,
  required int? currentDisplayId,
  required List<_TestDisplayRecord> records,
}) {
  final payload = Uint8List(0x14 + records.length * 0x38);
  final bd = ByteData.sublistView(payload)
    ..setUint16(0x00, 5, Endian.big) // version
    ..setUint16(0x02, 0, Endian.big)
    ..setUint16(0x04, 0, Endian.big)
    ..setUint16(0x06, backingWidth, Endian.big)
    ..setUint16(0x08, backingHeight, Endian.big)
    ..setUint32(0x0a, currentDisplayId ?? 0xFFFFFFFF, Endian.big)
    ..setUint32(0x0e, 0x04, Endian.big)
    ..setUint16(0x12, records.length, Endian.big);

  for (var i = 0; i < records.length; i++) {
    final rec = records[i];
    final base = 0x14 + i * 0x38;
    bd
      ..setFloat64(base + 0x00, 2.0, Endian.big)
      ..setFloat64(base + 0x08, 1.0, Endian.big)
      ..setUint32(base + 0x10, rec.id, Endian.big)
      ..setInt16(base + 0x14, rec.logicalTop, Endian.big)
      ..setInt16(base + 0x16, rec.logicalLeft, Endian.big)
      ..setInt16(base + 0x18, rec.logicalBottom, Endian.big)
      ..setInt16(base + 0x1a, rec.logicalRight, Endian.big)
      ..setInt16(base + 0x1c, rec.backingTop, Endian.big)
      ..setInt16(base + 0x1e, rec.backingLeft, Endian.big)
      ..setInt16(base + 0x20, rec.backingBottom, Endian.big)
      ..setInt16(base + 0x22, rec.backingRight, Endian.big)
      ..setUint32(base + 0x24, rec.flags, Endian.big);
    payload.setRange(
      base + 0x28,
      base + 0x38,
      VncPixelFormat.rgba8888.toBytes(),
    );
  }
  return payload;
}

Uint8List _buildExtendedServerInit({
  required int width,
  required int height,
  required String name,
}) {
  final header22 = Uint8List(22);
  // Server flags: control allowed + extended ServerInit.
  ByteData.sublistView(header22).setUint32(2, 0x12, Endian.big);
  // Capability bitmap bytes observed on macOS 26.
  header22.setRange(6, 11, const [0xbf, 0xf6, 0xe7, 0x2f, 0xec]);

  final nameBytes = utf8.encode(name);
  final fullNameField = Uint8List(22 + nameBytes.length)
    ..setRange(0, 22, header22)
    ..setRange(22, 22 + nameBytes.length, nameBytes);

  final dims = ByteData(4)
    ..setUint16(0, width, Endian.big)
    ..setUint16(2, height, Endian.big);
  final nameLen = ByteData(4)..setUint32(0, fullNameField.length, Endian.big);

  final builder = BytesBuilder(copy: false)
    ..add(dims.buffer.asUint8List())
    ..add(VncPixelFormat.rgba8888.toBytes())
    ..add(nameLen.buffer.asUint8List())
    ..add(fullNameField);
  return builder.takeBytes();
}

Uint8List _buildAppleDisplayLayoutUpdate(Uint8List layoutPayload) {
  final update = BytesBuilder(copy: false);
  final hdr = ByteData(16)
    ..setUint8(0, 0) // FramebufferUpdate
    ..setUint8(1, 0)
    ..setUint16(2, 1, Endian.big) // 1 rect
    ..setUint16(4, 0, Endian.big)
    ..setUint16(6, 0, Endian.big)
    ..setUint16(8, 0, Endian.big)
    ..setUint16(10, 0, Endian.big)
    ..setInt32(12, AppleRfbEncoding.displayLayout, Endian.big);
  final len = ByteData(2)..setUint16(0, layoutPayload.length, Endian.big);
  update
    ..add(hdr.buffer.asUint8List())
    ..add(len.buffer.asUint8List())
    ..add(layoutPayload);
  return update.takeBytes();
}

void main() {
  group('AppleRecordVncTransport', () {
    test('unwrapRekey recovers generation, key, and iv via AES-128-ECB', () {
      final wrapKey = _hexToBytes('00112233445566778899AABBCCDDEEFF');
      final sessionKey = _hexToBytes('0102030405060708090A0B0C0D0E0F10');
      final sessionIv = _hexToBytes('F0E0D0C0B0A090807060504030201000');

      final wrappedKey = _aesEcbEncrypt(sessionKey, wrapKey);
      final wrappedIv = _aesEcbEncrypt(sessionIv, wrapKey);

      final rekeyBody = Uint8List(36);
      ByteData.sublistView(rekeyBody).setUint32(0, 7, Endian.big);
      rekeyBody.setRange(4, 20, wrappedKey);
      rekeyBody.setRange(20, 36, wrappedIv);

      final unwrapped = AppleRecordVncTransport.unwrapRekey(wrapKey, rekeyBody);
      expect(unwrapped.generation, 7);
      expect(unwrapped.key, equals(sessionKey));
      expect(unwrapped.iv, equals(sessionIv));
    });

    test(
      'round-trips multiple records with persistent CBC chaining, incrementing seq, and >65498B splitting',
      () async {
        final pair = _PairedInMemoryTransport();
        addTearDown(pair.dispose);

        final key = _hexToBytes('102132435465768798A9BACBDCEDFE0F');
        final iv = _hexToBytes('AABBCCDDEEFF00112233445566778899');

        final readerA = BufferedByteReader(pair.a.stream);
        final readerB = BufferedByteReader(pair.b.stream);

        final recA = AppleRecordVncTransport(
          inner: pair.a,
          innerReader: readerA,
          key: key,
          iv: iv,
        );
        final recB = AppleRecordVncTransport(
          inner: pair.b,
          innerReader: readerB,
          key: key,
          iv: iv,
        );
        addTearDown(recA.close);
        addTearDown(recB.close);

        final plainReaderA = BufferedByteReader(recA.stream);
        final plainReaderB = BufferedByteReader(recB.stream);
        addTearDown(plainReaderA.dispose);
        addTearDown(plainReaderB.dispose);

        // Send 3 separate small messages A -> B (tests persistent CBC chaining + seq 0,1,2)
        final msg1 = Uint8List.fromList(utf8.encode('hello apple 889'));
        final msg2 = Uint8List.fromList(utf8.encode('hello apple 889'));
        final msg3 = Uint8List.fromList([0x0d, 0x00, 0x00, 0x00, 1, 2, 3, 4]);
        recA.add(msg1);
        recA.add(msg2);
        recA.add(msg3);

        expect(await plainReaderB.readBytes(msg1.length), equals(msg1));
        expect(await plainReaderB.readBytes(msg2.length), equals(msg2));
        expect(await plainReaderB.readBytes(msg3.length), equals(msg3));

        // Send a payload exceeding MAX_BODY (65498 bytes) in the reverse direction B -> A.
        final huge = Uint8List(AppleRecordVncTransport.maxBodyLength + 12345);
        for (var i = 0; i < huge.length; i++) {
          huge[i] = (i * 31 + 7) & 0xFF;
        }
        recB.add(huge);

        final receivedHuge = await plainReaderA.readBytes(huge.length);
        expect(receivedHuge, equals(huge));

        // Follow up with another message to confirm chaining stayed in sync after split.
        final tail = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]);
        recB.add(tail);
        expect(await plainReaderA.readBytes(tail.length), equals(tail));
      },
    );

    test(
      'rejects tampered ciphertext with VncProtocolException integrity error',
      () async {
        final pair = _PairedInMemoryTransport();
        addTearDown(pair.dispose);

        final key = _hexToBytes('0102030405060708090A0B0C0D0E0F10');
        final iv = _hexToBytes('11223344556677889900AABBCCDDEEFF');

        final capturedWire = Completer<Uint8List>();
        final wireSub = pair.b.stream.listen((chunk) {
          if (!capturedWire.isCompleted) {
            capturedWire.complete(Uint8List.fromList(chunk));
          }
        });
        addTearDown(wireSub.cancel);

        // Encrypt one record using recA -> capture wire bytes from pair.b.stream.
        final readerA = BufferedByteReader(pair.a.stream);
        final recA = AppleRecordVncTransport(
          inner: pair.a,
          innerReader: readerA,
          key: key,
          iv: iv,
        );
        addTearDown(recA.close);

        recA.add(Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]));
        final wire = await capturedWire.future;

        // Flip a bit in the ciphertext payload (after the 2-byte length prefix).
        wire[4] ^= 0x80;

        // Feed tampered record to a fresh receiver transport.
        final tamperPair = _PairedInMemoryTransport();
        addTearDown(tamperPair.dispose);
        final tamperReader = BufferedByteReader(tamperPair.a.stream);
        final receiver = AppleRecordVncTransport(
          inner: tamperPair.a,
          innerReader: tamperReader,
          key: key,
          iv: iv,
        );
        addTearDown(receiver.close);

        final errorCompleter = Completer<Object>();
        final recvSub = receiver.stream.listen(
          (_) {},
          onError: (Object err) {
            if (!errorCompleter.isCompleted) {
              errorCompleter.complete(err);
            }
          },
        );
        addTearDown(recvSub.cancel);

        tamperPair.injectRawToA(wire);

        final err = await errorCompleter.future.timeout(
          const Duration(seconds: 2),
        );
        expect(
          err,
          isA<VncProtocolException>().having(
            (e) => e.message,
            'message',
            contains('integrity'),
          ),
        );
      },
    );
  });

  group('AppleRfbMessages & AppleDisplayLayout & AppleCursorCache', () {
    test('setDisplay encodes exact 8-byte wire vectors', () {
      expect(
        AppleRfbMessages.setDisplay(0x2b004501),
        equals([0x0d, 0x00, 0x00, 0x00, 0x2b, 0x00, 0x45, 0x01]),
      );
      expect(
        AppleRfbMessages.setDisplay(null),
        equals([0x0d, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
      );
    });

    test('viewerInfo and prelude control messages match macOS 26 vectors', () {
      final vi = AppleRfbMessages.viewerInfo();
      expect(vi.length, 66);
      expect(vi[0], 0x21);
      expect((vi[2] << 8) | vi[3], 62);
      expect((vi[4] << 8) | vi[5], 1);
      expect(ByteData.sublistView(vi, 6, 10).getUint32(0), 2);
      expect(ByteData.sublistView(vi, 10, 14).getUint32(0), 6);
      expect(ByteData.sublistView(vi, 14, 18).getUint32(0), 1);
      expect(ByteData.sublistView(vi, 18, 22).getUint32(0), 0);
      expect(ByteData.sublistView(vi, 22, 26).getUint32(0), 26);
      expect(ByteData.sublistView(vi, 26, 30).getUint32(0), 6);
      expect(ByteData.sublistView(vi, 30, 34).getUint32(0), 2);
      expect(vi[34], 0xb0);
      expect(vi[36], 0x0c);
      expect(vi[37], 0x03);
      expect(vi[38], 0x90);
      expect(vi[44], 0x40);

      expect(AppleRfbMessages.setModeControl(), equals([0x0a, 0, 0, 1]));
      expect(
        AppleRfbMessages.setEncryptionStart(),
        equals([
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
        ]),
      );
      expect(
        AppleRfbMessages.enableInboundRecordDecryption(),
        equals([0x12, 0x00, 0x00, 0x02, 0x00, 0x01, 0x00, 0x00]),
      );
      expect(
        AppleRfbMessages.autoFramebufferUpdate(
          intervalUs: 33333,
          width: 3840,
          height: 2160,
        ),
        equals([
          0x09,
          0x00,
          0x00,
          0x01,
          0x00,
          0x00,
          0x82,
          0x35, // 33333
          0x00,
          0x00,
          0x00,
          0x00,
          0x0F,
          0x00, // 3840
          0x08,
          0x70, // 2160
        ]),
      );
    });

    test(
      'AppleDisplayLayout.parse parses 3 physical displays, deduplicates mirror copy, and handles 0xFFFFFFFF vs specific ID',
      () {
        final records = [
          // 1. Built-in Retina (main + mirrored primary at origin (0, 0))
          const _TestDisplayRecord(
            id: 1,
            logicalTop: 0,
            logicalLeft: 0,
            logicalBottom: 900,
            logicalRight: 1440,
            backingTop: 0,
            backingLeft: 0,
            backingBottom: 1800,
            backingRight: 2880,
            flags: 0x03, // main | inMirrorSet
          ),
          // Mirrored duplicate sharing origin (0, 0) -> MUST be deduped!
          const _TestDisplayRecord(
            id: 99,
            logicalTop: 0,
            logicalLeft: 0,
            logicalBottom: 900,
            logicalRight: 1440,
            backingTop: 0,
            backingLeft: 0,
            backingBottom: 1800,
            backingRight: 2880,
            flags: 0x02, // inMirrorSet
          ),
          // 2. 4K Landscape to the right
          const _TestDisplayRecord(
            id: 2,
            logicalTop: 0,
            logicalLeft: 1440,
            logicalBottom: 1080,
            logicalRight: 3360,
            backingTop: 0,
            backingLeft: 2880,
            backingBottom: 2160,
            backingRight: 6720,
            flags: 0x00,
          ),
          // 3. 4K Portrait to the right of 4K Landscape
          const _TestDisplayRecord(
            id: 3,
            logicalTop: 0,
            logicalLeft: 3360,
            logicalBottom: 1920,
            logicalRight: 4440,
            backingTop: 0,
            backingLeft: 6720,
            backingBottom: 3840,
            backingRight: 8880,
            flags: 0x00,
          ),
        ];

        final allPayload = _buildAppleDisplayLayoutPayload(
          backingWidth: 8880,
          backingHeight: 3840,
          currentDisplayId: null,
          records: records,
        );
        final allLayout = AppleDisplayLayout.parse(allPayload);
        expect(allLayout.backingWidth, 8880);
        expect(allLayout.backingHeight, 3840);
        expect(allLayout.currentDisplayId, isNull);
        expect(
          allLayout.displays,
          equals(const [
            VncScreenInfo(
              id: 1,
              x: 0,
              y: 0,
              width: 2880,
              height: 1800,
              flags: 0x03,
            ),
            VncScreenInfo(
              id: 2,
              x: 2880,
              y: 0,
              width: 3840,
              height: 2160,
              flags: 0x00,
            ),
            VncScreenInfo(
              id: 3,
              x: 6720,
              y: 0,
              width: 2160,
              height: 3840,
              flags: 0x00,
            ),
          ]),
        );

        final singlePayload = _buildAppleDisplayLayoutPayload(
          backingWidth: 3840,
          backingHeight: 2160,
          currentDisplayId: 2,
          records: records,
        );
        final singleLayout = AppleDisplayLayout.parse(singlePayload);
        expect(singleLayout.backingWidth, 3840);
        expect(singleLayout.backingHeight, 2160);
        expect(singleLayout.currentDisplayId, 2);
        expect(singleLayout.displays, hasLength(3));
      },
    );

    test(
      'AppleCursorCache decodes BGRA + alpha plane, caches by ID, and safely ignores malformed payloads',
      () {
        final cache = AppleCursorCache();

        // Unknown ID select returns null.
        expect(
          cache.accept(
            id: 42,
            hotspotX: 0,
            hotspotY: 0,
            width: 0,
            height: 0,
            deflated: Uint8List(0),
          ),
          isNull,
        );

        // 2x1 cursor: pixel0 BGRA=(0x30, 0x20, 0x10, 0x00) alpha=0x80
        //             pixel1 BGRA=(0x60, 0x50, 0x40, 0x00) alpha=0xFF
        final raw = Uint8List.fromList([
          0x30, 0x20, 0x10, 0x00, // px0 BGRA
          0x60, 0x50, 0x40, 0x00, // px1 BGRA
          0x80, 0xFF, // separate alpha plane
        ]);
        final deflated = Uint8List.fromList(ZLibEncoder().convert(raw));

        final stored = cache.accept(
          id: 7,
          hotspotX: 1,
          hotspotY: 0,
          width: 2,
          height: 1,
          deflated: deflated,
        );
        expect(stored, isNotNull);
        expect(stored!.width, 2);
        expect(stored.height, 1);
        expect(stored.hotspotX, 1);
        expect(stored.hotspotY, 0);
        expect(
          stored.rgbaPixels,
          equals([0x10, 0x20, 0x30, 0x80, 0x40, 0x50, 0x60, 0xFF]),
        );

        // Select cached ID 7 with empty deflated bytes.
        final selected = cache.accept(
          id: 7,
          hotspotX: 0,
          hotspotY: 0,
          width: 0,
          height: 0,
          deflated: Uint8List(0),
        );
        expect(selected, equals(stored));

        // Corrupt zlib stream returns null without throwing.
        expect(
          cache.accept(
            id: 8,
            hotspotX: 0,
            hotspotY: 0,
            width: 2,
            height: 1,
            deflated: Uint8List.fromList([0xFF, 0xFE, 0xFD]),
          ),
          isNull,
        );
      },
    );
  });

  group('RFB 003.889 handshake & full macOS 26 loopback session', () {
    test(
      'full loopback macOS 26 RFB 003.889 session: ARD Type 30, 0x81 extended ServerInit, Rekey, encrypted record layer, 3-display 0x451 layout, SetDisplay(2), frame update, cursor cache, and right-click bit swap',
      () async {
        final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(server.close);

        const generator = 2;
        final keyLength = _oakleyPrime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(_oakleyPrime128);
        final serverPriv = BigInt.parse(
          'ABCDEF0123456789ABCDEF0123456789',
          radix: 16,
        );
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          BigInt.from(generator).modPow(serverPriv, prime),
          keyLength,
        );

        final sessionKey = _hexToBytes('2233445566778899AABBCCDDEEFF0011');
        final sessionIv = _hexToBytes('99887766554433221100FFEEDDCCBBAA');

        final serverClientBanner = Completer<String>();
        final serverClientInit = Completer<int>();
        final serverSetDisplayMsg = Completer<Uint8List>();
        final serverPostSetDisplayRefresh = Completer<Uint8List>();
        final serverRightClickMsg = Completer<Uint8List>();
        final serverMiddleClickMsg = Completer<Uint8List>();
        final serverAutoUpdates = <Uint8List>[];

        final threeDisplays = const [
          _TestDisplayRecord(
            id: 1,
            logicalTop: 0,
            logicalLeft: 0,
            logicalBottom: 900,
            logicalRight: 1440,
            backingTop: 0,
            backingLeft: 0,
            backingBottom: 1800,
            backingRight: 2880,
            flags: 0x01,
          ),
          _TestDisplayRecord(
            id: 2,
            logicalTop: 0,
            logicalLeft: 1440,
            logicalBottom: 1080,
            logicalRight: 3360,
            backingTop: 0,
            backingLeft: 2880,
            backingBottom: 2160,
            backingRight: 6720,
            flags: 0x00,
          ),
          _TestDisplayRecord(
            id: 3,
            logicalTop: 0,
            logicalLeft: 3360,
            logicalBottom: 1920,
            logicalRight: 4440,
            backingTop: 0,
            backingLeft: 6720,
            backingBottom: 3840,
            backingRight: 8880,
            flags: 0x00,
          ),
        ];

        late StreamSubscription<Socket> serverSub;
        serverSub = server.listen((socket) async {
          final rawTransport = _SocketTransport(socket);
          final rawReader = BufferedByteReader(rawTransport.stream);
          AppleRecordVncTransport? serverRecordTransport;
          BufferedByteReader? encReader;
          try {
            // 1. Version negotiation: RFB 003.889 <-> RFB 003.889
            rawTransport.add(Uint8List.fromList(ascii.encode('RFB 003.889\n')));
            await rawTransport.flush();
            final clientBanner = ascii.decode(await rawReader.readBytes(12));
            serverClientBanner.complete(clientBanner);

            // 2. Security types: macOS 26 offers [30, 33, 36, 35]
            rawTransport.add(Uint8List.fromList([4, 30, 33, 36, 35]));
            await rawTransport.flush();
            expect(await rawReader.readUint8(), RfbSecurityType.appleArd);

            // 3. ARD DH challenge
            final dhHdr = ByteData(4)
              ..setUint16(0, generator, Endian.big)
              ..setUint16(2, keyLength, Endian.big);
            rawTransport.add(dhHdr.buffer.asUint8List());
            rawTransport.add(_oakleyPrime128);
            rawTransport.add(serverPubBytes);
            await rawTransport.flush();

            final encCreds = await rawReader.readBytes(128);
            final clientPubBytes = await rawReader.readBytes(keyLength);
            final sharedBytes = ArdAuthCrypto.bigIntToFixedBytes(
              ArdAuthCrypto.bytesToBigInt(
                clientPubBytes,
              ).modPow(serverPriv, prime),
              keyLength,
            );
            final wrapKey = Uint8List.fromList(md5.convert(sharedBytes).bytes);
            final decryptedCreds = _aesEcbDecrypt(encCreds, wrapKey);
            expect(_readNullTerminatedUtf8(decryptedCreds, 0, 64), 'mac-admin');
            expect(_readNullTerminatedUtf8(decryptedCreds, 64, 64), 'secret26');

            // SecurityResult = OK (0)
            rawTransport.add(Uint8List(4));
            await rawTransport.flush();

            // 4. ClientInit = 0x81 & extended ServerInit
            final initByte = await rawReader.readUint8();
            serverClientInit.complete(initByte);
            rawTransport.add(
              _buildExtendedServerInit(
                width: 8880,
                height: 3840,
                name: 'Mac Studio',
              ),
            );
            await rawTransport.flush();

            // 5. Cleartext prelude: ViewerInfo (66B), SetMode (4B),
            // SetEncryption cmd 1 (12B), SetEncryption cmd 2 (8B)
            expect(
              await rawReader.readBytes(66),
              equals(AppleRfbMessages.viewerInfo()),
            );
            expect(
              await rawReader.readBytes(4),
              equals(AppleRfbMessages.setModeControl()),
            );
            expect(
              await rawReader.readBytes(12),
              equals(AppleRfbMessages.setEncryptionStart()),
            );
            expect(
              await rawReader.readBytes(8),
              equals(AppleRfbMessages.enableInboundRecordDecryption()),
            );

            // Send cleartext MiscStatus (0x14) before Rekey to verify skipping.
            rawTransport.add(
              Uint8List.fromList([0x14, 0x00, 0x00, 0x04, 0x00, 0x01, 0, 4]),
            );

            // Send cleartext Rekey (0x44f) rectangle.
            final rekeyRect = BytesBuilder(copy: false);
            final rekeyHdr = ByteData(16)
              ..setUint8(0, 0) // FramebufferUpdate
              ..setUint8(1, 0)
              ..setUint16(2, 1, Endian.big)
              ..setUint16(4, 0, Endian.big)
              ..setUint16(6, 0, Endian.big)
              ..setUint16(8, 0, Endian.big)
              ..setUint16(10, 0, Endian.big)
              ..setInt32(12, AppleRfbEncoding.rekey, Endian.big);
            final genBytes = ByteData(4)..setUint32(0, 1, Endian.big);
            rekeyRect
              ..add(rekeyHdr.buffer.asUint8List())
              ..add(genBytes.buffer.asUint8List())
              ..add(_aesEcbEncrypt(sessionKey, wrapKey))
              ..add(_aesEcbEncrypt(sessionIv, wrapKey));
            rawTransport.add(rekeyRect.takeBytes());
            await rawTransport.flush();

            // 6. Switch server side to encrypted record layer!
            serverRecordTransport = AppleRecordVncTransport(
              inner: rawTransport,
              innerReader: rawReader,
              key: sessionKey,
              iv: sessionIv,
            );
            encReader = BufferedByteReader(serverRecordTransport.stream);

            // Receive encrypted SetPixelFormat (20B) + SetEncodings.
            final spf = await encReader.readBytes(20);
            expect(spf.sublist(0, 4), equals([0, 0, 0, 0]));
            expect(
              spf.sublist(4, 20),
              equals(VncPixelFormat.rgba8888.toBytes()),
            );

            final seHdr = await encReader.readBytes(4);
            expect(seHdr[0], 2);
            final encCount = (seHdr[2] << 8) | seHdr[3];
            final clientEncodings = <int>[];
            for (var i = 0; i < encCount; i++) {
              clientEncodings.add(await encReader.readInt32());
            }
            expect(clientEncodings, equals(AppleRfbEncoding.defaultEncodings));

            // Receive initial FramebufferUpdateRequest (10B).
            final initFbReq = await encReader.readBytes(10);
            expect(initFbReq[0], 3);
            expect(initFbReq[1], 0);

            // Send encrypted MiscStatus (0x14), metadata encodings, cursor store,
            // and 3-display AppleDisplayLayout (current: 0xFFFFFFFF = All).
            serverRecordTransport.add(
              Uint8List.fromList([0x14, 0x00, 0x00, 0x04, 0x00, 0x01, 0, 4]),
            );

            final initialLayout = _buildAppleDisplayLayoutPayload(
              backingWidth: 8880,
              backingHeight: 3840,
              currentDisplayId: null,
              records: threeDisplays,
            );
            serverRecordTransport.add(
              _buildAppleDisplayLayoutUpdate(initialLayout),
            );
            await serverRecordTransport.flush();

            // Read encrypted client messages until SetDisplay(2), right-click,
            // and middle-click have all arrived.
            while (!serverSetDisplayMsg.isCompleted ||
                !serverRightClickMsg.isCompleted ||
                !serverMiddleClickMsg.isCompleted) {
              final msgType = await encReader.readUint8();
              switch (msgType) {
                case 3: // FramebufferUpdateRequest
                  final rest = await encReader.readBytes(9);
                  if (serverSetDisplayMsg.isCompleted &&
                      !serverPostSetDisplayRefresh.isCompleted) {
                    serverPostSetDisplayRefresh.complete(
                      Uint8List.fromList([3, ...rest]),
                    );
                  }
                case 5: // PointerEvent
                  final rest = await encReader.readBytes(5);
                  final full = Uint8List.fromList([5, ...rest]);
                  if (!serverRightClickMsg.isCompleted) {
                    serverRightClickMsg.complete(full);
                  } else if (!serverMiddleClickMsg.isCompleted) {
                    serverMiddleClickMsg.complete(full);
                  }
                case 0x09: // AutoFrameBufferUpdate
                  final rest = await encReader.readBytes(15);
                  serverAutoUpdates.add(Uint8List.fromList([0x09, ...rest]));
                case 0x0d: // SetDisplay
                  final rest = await encReader.readBytes(7);
                  final full = Uint8List.fromList([0x0d, ...rest]);
                  if (!serverSetDisplayMsg.isCompleted) {
                    serverSetDisplayMsg.complete(full);
                  }

                  // Reply with new AppleDisplayLayout (current: 2, 3840x2160)
                  // followed by a 4x4 Raw frame at (0, 0).
                  final display2Layout = _buildAppleDisplayLayoutPayload(
                    backingWidth: 3840,
                    backingHeight: 2160,
                    currentDisplayId: 2,
                    records: threeDisplays,
                  );
                  serverRecordTransport.add(
                    _buildAppleDisplayLayoutUpdate(display2Layout),
                  );

                  final frameUpdate = BytesBuilder(copy: false);
                  final fHdr = ByteData(16)
                    ..setUint8(0, 0)
                    ..setUint8(1, 0)
                    ..setUint16(2, 1, Endian.big)
                    ..setUint16(4, 0, Endian.big)
                    ..setUint16(6, 0, Endian.big)
                    ..setUint16(8, 4, Endian.big)
                    ..setUint16(10, 4, Endian.big)
                    ..setInt32(12, RfbEncoding.raw, Endian.big);
                  frameUpdate.add(fHdr.buffer.asUint8List());
                  for (var i = 0; i < 16; i++) {
                    frameUpdate.add([0xAA, 0xBB, 0xCC, 0x00]);
                  }
                  serverRecordTransport.add(frameUpdate.takeBytes());
                  await serverRecordTransport.flush();
                default:
                  fail(
                    'Unexpected encrypted client message: 0x${msgType.toRadixString(16)}',
                  );
              }
            }
          } catch (_) {
            // Expected once client disconnects.
          } finally {
            await encReader?.dispose();
            await serverRecordTransport?.close();
            if (serverRecordTransport == null) {
              await rawReader.dispose();
              await rawTransport.close();
            }
          }
        });
        addTearDown(() => serverSub.cancel());

        final client = VncIsolateClient(minFrameInterval: Duration.zero);
        addTearDown(client.disconnect);

        final connectedCompleter = Completer<VncConnectedEvent>();
        final firstLayoutCompleter = Completer<VncResizedEvent>();
        final secondLayoutCompleter = Completer<VncResizedEvent>();
        final frameCompleter = Completer<VncFrameEvent>();

        final sub = client.events.listen((event) {
          if (event is VncConnectedEvent && !connectedCompleter.isCompleted) {
            connectedCompleter.complete(event);
          } else if (event is VncResizedEvent) {
            if (!firstLayoutCompleter.isCompleted) {
              firstLayoutCompleter.complete(event);
            } else if (!secondLayoutCompleter.isCompleted) {
              secondLayoutCompleter.complete(event);
            }
          } else if (event is VncFrameEvent && !frameCompleter.isCompleted) {
            frameCompleter.complete(event);
          }
        });
        addTearDown(sub.cancel);

        await client.connect(
          VncConnectionConfig(
            host: InternetAddress.loopbackIPv4.address,
            port: server.port,
            credentials: const VncCredentials(
              username: 'mac-admin',
              password: 'secret26',
            ),
          ),
        );

        final connected = await connectedCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(
          await serverClientBanner.future.timeout(const Duration(seconds: 5)),
          'RFB 003.889\n',
        );
        expect(
          await serverClientInit.future.timeout(const Duration(seconds: 5)),
          0x81,
        );
        expect(
          connected.desktopInfo,
          const VncDesktopInfo(
            name: 'Mac Studio',
            width: 8880,
            height: 3840,
            protocolVersion: 'RFB 003.889',
            securityType: RfbSecurityType.appleArd,
            isApple889: true,
          ),
        );

        // Verify initial 3-display AppleDisplayLayout.
        final firstLayout = await firstLayoutCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(firstLayout.width, 8880);
        expect(firstLayout.height, 3840);
        expect(firstLayout.hasCurrentDisplayId, isTrue);
        expect(firstLayout.currentDisplayId, isNull);
        expect(firstLayout.screens, hasLength(3));
        expect(firstLayout.screens.map((s) => s.id), equals([1, 2, 3]));

        // Switch to Display 2 over encrypted SetDisplay(2).
        client.selectDisplay(2);

        expect(
          await serverSetDisplayMsg.future.timeout(const Duration(seconds: 5)),
          equals([0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02]),
        );
        // Verify non-incremental FramebufferUpdateRequest queued directly
        // behind SetDisplay (macOS 26 quiet-display repaint fix).
        final postSwitchRefresh = await serverPostSetDisplayRefresh.future
            .timeout(const Duration(seconds: 5));
        expect(postSwitchRefresh[0], 3);
        expect(postSwitchRefresh[1], 0);

        final secondLayout = await secondLayoutCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(secondLayout.width, 3840);
        expect(secondLayout.height, 2160);
        expect(secondLayout.hasCurrentDisplayId, isTrue);
        expect(secondLayout.currentDisplayId, 2);

        final frameEvent = await frameCompleter.future.timeout(
          const Duration(seconds: 5),
        );
        expect(frameEvent.frame.width, 3840);
        expect(frameEvent.frame.height, 2160);
        expect(
          frameEvent.frame.rgbaPixels.sublist(0, 4),
          equals([0xAA, 0xBB, 0xCC, 0xFF]),
        );

        // Verify macOS 003.889 right-click (bit 2 -> bit 1) and middle-click
        // (bit 1 -> bit 2) button mask swap!
        client.sendPointerEvent(100, 200, 0x04); // RFB right-click -> 0x02
        client.sendPointerEvent(120, 220, 0x02); // RFB middle-click -> 0x04

        expect(
          await serverRightClickMsg.future.timeout(const Duration(seconds: 5)),
          equals([5, 0x02, 0x00, 100, 0x00, 200]),
        );
        expect(
          await serverMiddleClickMsg.future.timeout(const Duration(seconds: 5)),
          equals([5, 0x04, 0x00, 120, 0x00, 220]),
        );
        expect(serverAutoUpdates, isNotEmpty);
        // Standard Screen Sharing arms AutoFrameBufferUpdate with intervalUs=0.
        expect(
          ByteData.sublistView(serverAutoUpdates.first, 4, 8).getUint32(0),
          0,
        );

        await client.disconnect().timeout(const Duration(seconds: 5));
      },
    );

    test(
      'RFB 003.889 ARD authentication refusal reads 4-byte SecurityResult alone without hanging for a 3.8 reason string',
      () async {
        final pair = _PairedInMemoryTransport();
        addTearDown(pair.dispose);

        const generator = 2;
        final keyLength = _oakleyPrime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(_oakleyPrime128);
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          BigInt.from(generator).modPow(BigInt.from(12345), prime),
          keyLength,
        );

        final serverReader = BufferedByteReader(pair.b.stream);
        final clientReader = BufferedByteReader(pair.a.stream);
        addTearDown(serverReader.dispose);
        addTearDown(clientReader.dispose);

        final serverTask = () async {
          pair.b.add(Uint8List.fromList(ascii.encode('RFB 003.889\n')));
          expect(
            ascii.decode(await serverReader.readBytes(12)),
            'RFB 003.889\n',
          );

          pair.b.add(Uint8List.fromList([1, RfbSecurityType.appleArd]));
          expect(await serverReader.readUint8(), RfbSecurityType.appleArd);

          final hdr = ByteData(4)
            ..setUint16(0, generator, Endian.big)
            ..setUint16(2, keyLength, Endian.big);
          pair.b.add(hdr.buffer.asUint8List());
          pair.b.add(_oakleyPrime128);
          pair.b.add(serverPubBytes);

          await serverReader.readBytes(128 + keyLength);
          // macOS 003.889 sends ONLY the 4-byte status word (1) and leaves the socket open.
          pair.b.add(Uint8List.fromList([0, 0, 0, 1]));
        }();

        await expectLater(
          RfbHandshake.performSession(
            transport: pair.a,
            reader: clientReader,
            config: const VncConnectionConfig(
              host: 'mac.local',
              credentials: VncCredentials(username: 'user', password: 'wrong'),
            ),
          ).timeout(const Duration(seconds: 2)),
          throwsA(isA<VncAuthenticationException>()),
        );
        await serverTask;
      },
    );

    test(
      'downgrades to RFB 003.008 when authPreference explicitly requests vncPassword against an RFB 003.889 server',
      () async {
        final pair = _PairedInMemoryTransport();
        addTearDown(pair.dispose);

        final serverReader = BufferedByteReader(pair.b.stream);
        final clientReader = BufferedByteReader(pair.a.stream);
        addTearDown(serverReader.dispose);
        addTearDown(clientReader.dispose);

        final challenge = _hexToBytes('00112233445566778899AABBCCDDEEFF');

        final serverTask = () async {
          pair.b.add(Uint8List.fromList(ascii.encode('RFB 003.889\n')));
          expect(
            ascii.decode(await serverReader.readBytes(12)),
            'RFB 003.008\n',
          );
          pair.b.add(Uint8List.fromList([2, 30, 2]));
          expect(await serverReader.readUint8(), RfbSecurityType.vncAuth);
          pair.b.add(challenge);
          final resp = await serverReader.readBytes(16);
          expect(resp, equals(VncDes.encryptChallenge(challenge, 'pw')));
          pair.b.add(Uint8List(4)); // OK
          expect(await serverReader.readUint8(), 1); // standard ClientInit
          final nameBytes = utf8.encode('Legacy Mac');
          final hdr = ByteData(4)
            ..setUint16(0, 1280, Endian.big)
            ..setUint16(2, 720, Endian.big);
          final nameLen = ByteData(4)
            ..setUint32(0, nameBytes.length, Endian.big);
          pair.b.add(
            (BytesBuilder(copy: false)
                  ..add(hdr.buffer.asUint8List())
                  ..add(VncPixelFormat.rgba8888.toBytes())
                  ..add(nameLen.buffer.asUint8List())
                  ..add(nameBytes))
                .takeBytes(),
          );
          // Drain SetPixelFormat + SetEncodings
          await serverReader.readBytes(20);
          final seHdr = await serverReader.readBytes(4);
          await serverReader.readBytes(((seHdr[2] << 8) | seHdr[3]) * 4);
        }();

        final result = await RfbHandshake.performSession(
          transport: pair.a,
          reader: clientReader,
          config: const VncConnectionConfig(
            host: 'mac.local',
            authPreference: VncAuthPreference.vncPassword,
            credentials: VncCredentials(password: 'pw'),
          ),
        );
        await serverTask;

        expect(result.desktopInfo.isApple889, isFalse);
        expect(result.desktopInfo.securityType, RfbSecurityType.vncAuth);
        expect(result.transport, same(pair.a));
      },
    );
  });
}
