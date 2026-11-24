import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:test/test.dart';

class _InMemoryVncPipe implements VncTransport {
  final StreamController<Uint8List> _serverToClient =
      StreamController<Uint8List>();
  final StreamController<Uint8List> _clientToServer =
      StreamController<Uint8List>();
  final Completer<void> _doneCompleter = Completer<void>();

  late final BufferedByteReader serverReader = BufferedByteReader(
    _clientToServer.stream,
  );
  late final BufferedByteReader clientReader = BufferedByteReader(
    _serverToClient.stream,
  );

  bool _closed = false;

  void serverSend(List<int> bytes) {
    if (!_serverToClient.isClosed) {
      _serverToClient.add(Uint8List.fromList(bytes));
    }
  }

  void serverSendAscii(String text) => serverSend(ascii.encode(text));

  void serverSendUint8(int value) => serverSend([value & 0xFF]);

  void serverSendUint16(int value) {
    final bd = ByteData(2)..setUint16(0, value, Endian.big);
    serverSend(bd.buffer.asUint8List());
  }

  void serverSendUint32(int value) {
    final bd = ByteData(4)..setUint32(0, value, Endian.big);
    serverSend(bd.buffer.asUint8List());
  }

  void serverSendReason(String reason) {
    final bytes = utf8.encode(reason);
    serverSendUint32(bytes.length);
    serverSend(bytes);
  }

  void serverSendServerInit({
    required int width,
    required int height,
    required String name,
    VncPixelFormat pixelFormat = VncPixelFormat.rgba8888,
  }) {
    final nameBytes = utf8.encode(name);
    final header = ByteData(4)
      ..setUint16(0, width, Endian.big)
      ..setUint16(2, height, Endian.big);
    final nameLen = ByteData(4)..setUint32(0, nameBytes.length, Endian.big);
    final packet = BytesBuilder(copy: false)
      ..add(header.buffer.asUint8List())
      ..add(pixelFormat.toBytes())
      ..add(nameLen.buffer.asUint8List())
      ..add(nameBytes);
    serverSend(packet.takeBytes());
  }

  Future<void> dispose() async {
    await clientReader.dispose();
    await serverReader.dispose();
    await close();
  }

  @override
  Stream<Uint8List> get stream => _serverToClient.stream;

  @override
  void add(Uint8List data) {
    if (_closed) {
      throw StateError('Transport is closed');
    }
    _clientToServer.add(Uint8List.fromList(data));
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
    if (!_serverToClient.isClosed) {
      await _serverToClient.close();
    }
    if (!_clientToServer.isClosed) {
      await _clientToServer.close();
    }
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }
}

Uint8List _hexToBytes(String hex) {
  final clean = hex.replaceAll(RegExp(r'\s+'), '');
  final out = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
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

Future<void> _verifyInitialSetMessages(
  BufferedByteReader serverReader, {
  List<int> expectedEncodings = RfbEncoding.defaultEncodings,
}) async {
  // SetPixelFormat: 20 bytes [0, 0, 0, 0, ...rgba8888]
  final setPixelFormat = await serverReader.readBytes(20);
  expect(setPixelFormat.sublist(0, 4), [0, 0, 0, 0]);
  expect(
    setPixelFormat.sublist(4, 20),
    equals(VncPixelFormat.rgba8888.toBytes()),
  );

  // SetEncodings: [2, 0, countHi, countLo, ...int32BE(enc)]
  final setEncodingsHeader = await serverReader.readBytes(4);
  expect(setEncodingsHeader[0], 2);
  expect(setEncodingsHeader[1], 0);
  final count = (setEncodingsHeader[2] << 8) | setEncodingsHeader[3];
  expect(count, expectedEncodings.length);

  final actualEncodings = <int>[];
  for (var i = 0; i < count; i++) {
    actualEncodings.add(await serverReader.readInt32());
  }
  expect(actualEncodings, equals(expectedEncodings));
}

void main() {
  group('RfbEncoding and RfbSecurityType constants', () {
    test('define expected RFC 6143 and Apple ARD wire values', () {
      expect(RfbEncoding.raw, 0);
      expect(RfbEncoding.copyRect, 1);
      expect(RfbEncoding.hextile, 5);
      expect(RfbEncoding.zrle, 16);
      expect(RfbEncoding.desktopSize, -223);
      expect(RfbEncoding.lastRect, -224);
      expect(RfbEncoding.cursor, -239);
      expect(RfbEncoding.extendedDesktopSize, -308);
      expect(RfbEncoding.defaultEncodings, [
        RfbEncoding.zrle,
        RfbEncoding.copyRect,
        RfbEncoding.hextile,
        RfbEncoding.raw,
        RfbEncoding.desktopSize,
        RfbEncoding.extendedDesktopSize,
        RfbEncoding.cursor,
        RfbEncoding.lastRect,
      ]);

      expect(RfbSecurityType.invalid, 0);
      expect(RfbSecurityType.none, 1);
      expect(RfbSecurityType.vncAuth, 2);
      expect(RfbSecurityType.appleArd, 30);
    });
  });

  group('RfbHandshake', () {
    test(
      'completes macOS RFB 003.889 handshake with Apple ARD Type 30 DH auth',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        const generator = 2;
        final keyLength = _oakleyPrime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(_oakleyPrime128);
        final serverPriv = BigInt.parse(
          '123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0',
          radix: 16,
        );
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          BigInt.from(generator).modPow(serverPriv, prime),
          keyLength,
        );

        String? decryptedUser;
        String? decryptedPass;
        String? clientBanner;
        int? selectedType;
        int? sharedFlag;

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.889\n');
          clientBanner = ascii.decode(await pipe.serverReader.readBytes(12));

          // Offered security types typical of macOS Screen Sharing
          pipe.serverSend([4, 30, 33, 35, 36]);
          selectedType = await pipe.serverReader.readUint8();

          // ARD challenge: generator (u16), keyLength (u16), prime, serverPub
          pipe.serverSendUint16(generator);
          pipe.serverSendUint16(keyLength);
          pipe.serverSend(_oakleyPrime128);
          pipe.serverSend(serverPubBytes);

          // Client sends 128B encryptedCredentials + keyLength clientPubKey
          final encryptedCreds = await pipe.serverReader.readBytes(128);
          final clientPubBytes = await pipe.serverReader.readBytes(keyLength);

          final clientPub = ArdAuthCrypto.bytesToBigInt(clientPubBytes);
          final sharedBytes = ArdAuthCrypto.bigIntToFixedBytes(
            clientPub.modPow(serverPriv, prime),
            keyLength,
          );
          final aesKey = Uint8List.fromList(md5.convert(sharedBytes).bytes);
          final plaintext = _aesEcbDecrypt(encryptedCreds, aesKey);
          decryptedUser = _readNullTerminatedUtf8(plaintext, 0, 64);
          decryptedPass = _readNullTerminatedUtf8(plaintext, 64, 64);

          // SecurityResult = OK
          pipe.serverSendUint32(0);

          // ClientInit
          sharedFlag = await pipe.serverReader.readUint8();

          // ServerInit
          pipe.serverSendServerInit(
            width: 1920,
            height: 1080,
            name: 'Mac Studio',
          );

          await _verifyInitialSetMessages(pipe.serverReader);
        }();

        const config = VncConnectionConfig(
          host: 'mac-studio.local',
          credentials: VncCredentials(
            username: 'mac-admin',
            password: 's3cr3t-password!',
          ),
        );

        final info = await RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: config,
        );
        await serverTask;

        expect(clientBanner, 'RFB 003.008\n');
        expect(selectedType, RfbSecurityType.appleArd);
        expect(decryptedUser, 'mac-admin');
        expect(decryptedPass, 's3cr3t-password!');
        expect(sharedFlag, 1);
        expect(
          info,
          const VncDesktopInfo(
            name: 'Mac Studio',
            width: 1920,
            height: 1080,
            protocolVersion: 'RFB 003.889',
            securityType: RfbSecurityType.appleArd,
          ),
        );
      },
    );

    test(
      'completes RFB 003.008 handshake with Type 2 VNC Auth DES challenge-response',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final challenge = _hexToBytes('00112233445566778899AABBCCDDEEFF');
        final expectedDesResponse = VncDes.encryptChallenge(
          challenge,
          'vnc-pass',
        );

        String? clientBanner;
        int? selectedType;
        Uint8List? receivedDesResponse;
        int? sharedFlag;

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.008\n');
          clientBanner = ascii.decode(await pipe.serverReader.readBytes(12));

          // Auto preference prefers Type 2 over Type 1
          pipe.serverSend([2, 1, 2]);
          selectedType = await pipe.serverReader.readUint8();

          pipe.serverSend(challenge);
          receivedDesResponse = await pipe.serverReader.readBytes(16);

          pipe.serverSendUint32(0);

          sharedFlag = await pipe.serverReader.readUint8();
          pipe.serverSendServerInit(
            width: 1280,
            height: 720,
            name: 'Ubuntu Desktop',
          );

          await _verifyInitialSetMessages(pipe.serverReader);
        }();

        const config = VncConnectionConfig(
          host: '192.168.1.50',
          sharedDesktop: false,
          credentials: VncCredentials(password: 'vnc-pass'),
        );

        final info = await RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: config,
        );
        await serverTask;

        expect(clientBanner, 'RFB 003.008\n');
        expect(selectedType, RfbSecurityType.vncAuth);
        expect(receivedDesResponse, equals(expectedDesResponse));
        expect(sharedFlag, 0);
        expect(
          info,
          const VncDesktopInfo(
            name: 'Ubuntu Desktop',
            width: 1280,
            height: 720,
            protocolVersion: 'RFB 003.008',
            securityType: RfbSecurityType.vncAuth,
          ),
        );
      },
    );

    test(
      'completes RFB 003.003 handshake with Type 1 None skipping SecurityResult',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        String? clientBanner;
        int? sharedFlag;

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.003\n');
          clientBanner = ascii.decode(await pipe.serverReader.readBytes(12));

          // RFB 3.3 sends uint32 security type directly; client sends NO
          // security type byte and server sends NO SecurityResult for Type 1.
          pipe.serverSendUint32(RfbSecurityType.none);

          sharedFlag = await pipe.serverReader.readUint8();
          pipe.serverSendServerInit(
            width: 800,
            height: 600,
            name: 'Legacy VNC',
          );

          await _verifyInitialSetMessages(pipe.serverReader);
        }();

        final info = await RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: const VncConnectionConfig(host: '10.0.0.2'),
        );
        await serverTask;

        expect(clientBanner, 'RFB 003.003\n');
        expect(sharedFlag, 1);
        expect(
          info,
          const VncDesktopInfo(
            name: 'Legacy VNC',
            width: 800,
            height: 600,
            protocolVersion: 'RFB 003.003',
            securityType: RfbSecurityType.none,
          ),
        );
      },
    );

    test(
      'completes RFB 003.007 handshake with Type 1 None skipping SecurityResult',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        String? clientBanner;
        int? selectedType;

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.007\n');
          clientBanner = ascii.decode(await pipe.serverReader.readBytes(12));

          pipe.serverSend([1, RfbSecurityType.none]);
          selectedType = await pipe.serverReader.readUint8();

          // No SecurityResult in 3.7 for Type 1; client immediately sends ClientInit.
          expect(await pipe.serverReader.readUint8(), 1);
          pipe.serverSendServerInit(width: 640, height: 480, name: 'RFB 3.7');
          await _verifyInitialSetMessages(pipe.serverReader);
        }();

        final info = await RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: const VncConnectionConfig(host: '10.0.0.7'),
        );
        await serverTask;

        expect(clientBanner, 'RFB 003.007\n');
        expect(selectedType, RfbSecurityType.none);
        expect(info.protocolVersion, 'RFB 003.007');
        expect(info.securityType, RfbSecurityType.none);
      },
    );

    test(
      'requests deferred credentials via onCredentialsRequired for Type 30',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        const generator = 2;
        final keyLength = _oakleyPrime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(_oakleyPrime128);
        final serverPriv = BigInt.from(987654321);
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          BigInt.from(generator).modPow(serverPriv, prime),
          keyLength,
        );

        String? decryptedUser;
        String? decryptedPass;

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.889\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.appleArd]);
          expect(await pipe.serverReader.readUint8(), RfbSecurityType.appleArd);

          pipe.serverSendUint16(generator);
          pipe.serverSendUint16(keyLength);
          pipe.serverSend(_oakleyPrime128);
          pipe.serverSend(serverPubBytes);

          final encryptedCreds = await pipe.serverReader.readBytes(128);
          final clientPubBytes = await pipe.serverReader.readBytes(keyLength);
          final sharedBytes = ArdAuthCrypto.bigIntToFixedBytes(
            ArdAuthCrypto.bytesToBigInt(
              clientPubBytes,
            ).modPow(serverPriv, prime),
            keyLength,
          );
          final aesKey = Uint8List.fromList(md5.convert(sharedBytes).bytes);
          final plaintext = _aesEcbDecrypt(encryptedCreds, aesKey);
          decryptedUser = _readNullTerminatedUtf8(plaintext, 0, 64);
          decryptedPass = _readNullTerminatedUtf8(plaintext, 64, 64);

          pipe.serverSendUint32(0);
          await pipe.serverReader.readUint8();
          pipe.serverSendServerInit(width: 1440, height: 900, name: 'MacBook');
          await _verifyInitialSetMessages(pipe.serverReader);
        }();

        int? callbackSecurityType;
        bool? callbackRequiresUsername;

        final info = await RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: const VncConnectionConfig(host: 'macbook.local'),
          onCredentialsRequired:
              ({
                required int securityType,
                required bool requiresUsername,
              }) async {
                callbackSecurityType = securityType;
                callbackRequiresUsername = requiresUsername;
                return const VncCredentials(
                  username: 'deferred-user',
                  password: 'deferred-pass',
                );
              },
        );
        await serverTask;

        expect(callbackSecurityType, RfbSecurityType.appleArd);
        expect(callbackRequiresUsername, isTrue);
        expect(decryptedUser, 'deferred-user');
        expect(decryptedPass, 'deferred-pass');
        expect(info.name, 'MacBook');
      },
    );

    test(
      'requests deferred credentials via onCredentialsRequired for Type 2',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final challenge = _hexToBytes('FFEEDDCCBBAA99887766554433221100');
        final expectedResponse = VncDes.encryptChallenge(challenge, 'prompted');

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.008\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.vncAuth]);
          expect(await pipe.serverReader.readUint8(), RfbSecurityType.vncAuth);

          pipe.serverSend(challenge);
          final response = await pipe.serverReader.readBytes(16);
          expect(response, equals(expectedResponse));

          pipe.serverSendUint32(0);
          await pipe.serverReader.readUint8();
          pipe.serverSendServerInit(width: 1024, height: 768, name: 'VNC Box');
          await _verifyInitialSetMessages(pipe.serverReader);
        }();

        int? callbackSecurityType;
        bool? callbackRequiresUsername;

        final info = await RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: const VncConnectionConfig(host: 'vnc-box.local'),
          onCredentialsRequired:
              ({
                required int securityType,
                required bool requiresUsername,
              }) async {
                callbackSecurityType = securityType;
                callbackRequiresUsername = requiresUsername;
                return const VncCredentials(password: 'prompted');
              },
        );
        await serverTask;

        expect(callbackSecurityType, RfbSecurityType.vncAuth);
        expect(callbackRequiresUsername, isFalse);
        expect(info.name, 'VNC Box');
      },
    );

    test(
      'throws VncAuthenticationException when deferred credentials return null for Type 30',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        const generator = 2;
        final keyLength = _oakleyPrime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(_oakleyPrime128);
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          BigInt.from(generator).modPow(BigInt.from(42), prime),
          keyLength,
        );

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.889\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.appleArd]);
          await pipe.serverReader.readUint8();
          pipe.serverSendUint16(generator);
          pipe.serverSendUint16(keyLength);
          pipe.serverSend(_oakleyPrime128);
          pipe.serverSend(serverPubBytes);
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(host: 'mac.local'),
            onCredentialsRequired:
                ({
                  required int securityType,
                  required bool requiresUsername,
                }) async => null,
          ),
          throwsA(isA<VncAuthenticationException>()),
        );
        await serverTask;
      },
    );

    test(
      'throws VncAuthenticationException when deferred credentials return null for Type 2',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.008\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.vncAuth]);
          await pipe.serverReader.readUint8();
          pipe.serverSend(Uint8List(16));
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(host: 'vnc.local'),
            onCredentialsRequired:
                ({
                  required int securityType,
                  required bool requiresUsername,
                }) async => null,
          ),
          throwsA(isA<VncAuthenticationException>()),
        );
        await serverTask;
      },
    );

    test(
      'throws VncUnsupportedSecurityTypeException when only unsupported types [35, 36] are offered',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.889\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([2, 35, 36]);
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(host: 'mac.local'),
          ),
          throwsA(
            isA<VncUnsupportedSecurityTypeException>().having(
              (e) => e.offeredTypes,
              'offeredTypes',
              [35, 36],
            ),
          ),
        );
        await serverTask;
      },
    );

    test(
      'throws VncUnsupportedSecurityTypeException when explicit authPreference is not offered',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.008\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([2, 1, 2]);
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(
              host: 'server.local',
              authPreference: VncAuthPreference.appleArd,
            ),
          ),
          throwsA(
            isA<VncUnsupportedSecurityTypeException>().having(
              (e) => e.offeredTypes,
              'offeredTypes',
              [1, 2],
            ),
          ),
        );
        await serverTask;
      },
    );

    test(
      'throws VncAuthenticationException containing server reason when SecurityResult is non-zero in 3.8',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.008\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.vncAuth]);
          await pipe.serverReader.readUint8();
          pipe.serverSend(Uint8List(16));
          await pipe.serverReader.readBytes(16);
          pipe.serverSendUint32(1);
          pipe.serverSendReason('Authentication failed');
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(
              host: 'vnc.local',
              credentials: VncCredentials(password: 'wrong'),
            ),
          ),
          throwsA(
            isA<VncAuthenticationException>().having(
              (e) => e.message,
              'message',
              contains('Authentication failed'),
            ),
          ),
        );
        await serverTask;
      },
    );

    test(
      'throws VncConnectionException with server reason when 3.8 security type count is 0',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.008\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSendUint8(0);
          pipe.serverSendReason('Too many connections');
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(host: 'vnc.local'),
          ),
          throwsA(
            isA<VncConnectionException>().having(
              (e) => e.message,
              'message',
              contains('Too many connections'),
            ),
          ),
        );
        await serverTask;
      },
    );

    test(
      'throws VncConnectionException with server reason when 3.3 security type is 0',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.003\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSendUint32(0);
          pipe.serverSendReason('Connection rejected');
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(host: 'vnc.local'),
          ),
          throwsA(
            isA<VncConnectionException>().having(
              (e) => e.message,
              'message',
              contains('Connection rejected'),
            ),
          ),
        );
        await serverTask;
      },
    );

    test('throws VncProtocolException on invalid server banner', () async {
      final pipe = _InMemoryVncPipe();
      addTearDown(pipe.dispose);

      pipe.serverSendAscii('HTTP/1.1 200');

      await expectLater(
        RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: const VncConnectionConfig(host: 'not-vnc.local'),
        ),
        throwsA(isA<VncProtocolException>()),
      );
    });

    test(
      'throws VncProtocolException on unsupported RFB version (< 3.3)',
      () async {
        for (final banner in ['RFB 002.008\n', 'RFB 003.002\n']) {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          pipe.serverSendAscii(banner);

          await expectLater(
            RfbHandshake.perform(
              transport: pipe,
              reader: pipe.clientReader,
              config: const VncConnectionConfig(host: 'old-vnc.local'),
            ),
            throwsA(isA<VncProtocolException>()),
          );
        }
      },
    );

    test(
      'throws VncProtocolException on invalid ARD keyLength or DH parameters',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.889\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.appleArd]);
          await pipe.serverReader.readUint8();
          pipe.serverSendUint16(2);
          pipe.serverSendUint16(2048); // exceeds max 1024
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(
              host: 'mac.local',
              credentials: VncCredentials(username: 'u', password: 'p'),
            ),
          ),
          throwsA(isA<VncProtocolException>()),
        );
        await serverTask;
      },
    );

    test(
      'rejects malformed ARD DH parameters before invoking onCredentialsRequired',
      () async {
        final badCases = [
          (
            label: 'prime <= 3',
            generator: 2,
            prime: [0, 0, 0, 3],
            serverPub: [0, 0, 0, 2],
          ),
          (
            label: 'generator < 2',
            generator: 1,
            prime: [0, 0, 0, 23],
            serverPub: [0, 0, 0, 5],
          ),
          (
            label: 'generator >= prime',
            generator: 23,
            prime: [0, 0, 0, 23],
            serverPub: [0, 0, 0, 5],
          ),
          (
            label: 'serverPub < 2',
            generator: 5,
            prime: [0, 0, 0, 23],
            serverPub: [0, 0, 0, 1],
          ),
          (
            label: 'serverPub > prime - 2',
            generator: 5,
            prime: [0, 0, 0, 23],
            serverPub: [0, 0, 0, 22],
          ),
        ];

        for (final testCase in badCases) {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.889\n');
            await pipe.serverReader.readBytes(12);
            pipe.serverSend([1, RfbSecurityType.appleArd]);
            await pipe.serverReader.readUint8();
            pipe.serverSendUint16(testCase.generator);
            pipe.serverSendUint16(4);
            pipe.serverSend(testCase.prime);
            pipe.serverSend(testCase.serverPub);
          }();

          var credentialPromptCalled = false;
          await expectLater(
            RfbHandshake.perform(
              transport: pipe,
              reader: pipe.clientReader,
              config: const VncConnectionConfig(host: 'mac.local'),
              onCredentialsRequired:
                  ({
                    required int securityType,
                    required bool requiresUsername,
                  }) async {
                    credentialPromptCalled = true;
                    return const VncCredentials(username: 'u', password: 'p');
                  },
            ),
            throwsA(isA<VncProtocolException>()),
            reason: 'Expected VncProtocolException for ${testCase.label}',
          );
          expect(
            credentialPromptCalled,
            isFalse,
            reason: 'Should not prompt for credentials on ${testCase.label}',
          );
          await serverTask;
        }
      },
    );

    test('throws ArgumentError when encodings length exceeds 65535', () async {
      final pipe = _InMemoryVncPipe();
      addTearDown(pipe.dispose);

      await expectLater(
        RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: const VncConnectionConfig(host: 'vnc.local'),
          encodings: List<int>.filled(65536, RfbEncoding.raw),
        ),
        throwsArgumentError,
      );
    });

    test(
      'snapshots encodings at entry so caller mutations during handshake have no effect',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final mutableEncodings = <int>[RfbEncoding.zrle, RfbEncoding.raw];

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.008\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.none]);
          await pipe.serverReader.readUint8();
          // Mutate caller list mid-handshake before ServerInit completes.
          mutableEncodings.add(RfbEncoding.hextile);
          pipe.serverSendUint32(0);
          await pipe.serverReader.readUint8();
          pipe.serverSendServerInit(width: 800, height: 600, name: 'Snapshot');
          await _verifyInitialSetMessages(
            pipe.serverReader,
            expectedEncodings: const [RfbEncoding.zrle, RfbEncoding.raw],
          );
        }();

        await RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: const VncConnectionConfig(host: 'vnc.local'),
          encodings: mutableEncodings,
        );
        await serverTask;
      },
    );

    test(
      'rejects empty Type 2 password consistently in both config and callback',
      () async {
        // Case 1: Empty password in config with no callback
        {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.008\n');
            await pipe.serverReader.readBytes(12);
            pipe.serverSend([1, RfbSecurityType.vncAuth]);
            await pipe.serverReader.readUint8();
            pipe.serverSend(Uint8List(16));
          }();

          await expectLater(
            RfbHandshake.perform(
              transport: pipe,
              reader: pipe.clientReader,
              config: const VncConnectionConfig(
                host: 'vnc.local',
                credentials: VncCredentials(password: ''),
              ),
            ),
            throwsA(isA<VncAuthenticationException>()),
          );
          await serverTask;
        }

        // Case 2: Empty password returned by onCredentialsRequired callback
        {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.008\n');
            await pipe.serverReader.readBytes(12);
            pipe.serverSend([1, RfbSecurityType.vncAuth]);
            await pipe.serverReader.readUint8();
            pipe.serverSend(Uint8List(16));
          }();

          await expectLater(
            RfbHandshake.perform(
              transport: pipe,
              reader: pipe.clientReader,
              config: const VncConnectionConfig(host: 'vnc.local'),
              onCredentialsRequired:
                  ({
                    required int securityType,
                    required bool requiresUsername,
                  }) async => const VncCredentials(password: ''),
            ),
            throwsA(isA<VncAuthenticationException>()),
          );
          await serverTask;
        }
      },
    );

    test(
      'preserves pre-configured username for Type 30 when callback supplies only password',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        const generator = 2;
        final keyLength = _oakleyPrime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(_oakleyPrime128);
        final serverPriv = BigInt.from(246813579);
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          BigInt.from(generator).modPow(serverPriv, prime),
          keyLength,
        );

        String? decryptedUser;
        String? decryptedPass;

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.889\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.appleArd]);
          await pipe.serverReader.readUint8();
          pipe.serverSendUint16(generator);
          pipe.serverSendUint16(keyLength);
          pipe.serverSend(_oakleyPrime128);
          pipe.serverSend(serverPubBytes);

          final encryptedCreds = await pipe.serverReader.readBytes(128);
          final clientPubBytes = await pipe.serverReader.readBytes(keyLength);
          final sharedBytes = ArdAuthCrypto.bigIntToFixedBytes(
            ArdAuthCrypto.bytesToBigInt(
              clientPubBytes,
            ).modPow(serverPriv, prime),
            keyLength,
          );
          final aesKey = Uint8List.fromList(md5.convert(sharedBytes).bytes);
          final plaintext = _aesEcbDecrypt(encryptedCreds, aesKey);
          decryptedUser = _readNullTerminatedUtf8(plaintext, 0, 64);
          decryptedPass = _readNullTerminatedUtf8(plaintext, 64, 64);

          pipe.serverSendUint32(0);
          await pipe.serverReader.readUint8();
          pipe.serverSendServerInit(width: 1280, height: 800, name: 'iMac');
          await _verifyInitialSetMessages(pipe.serverReader);
        }();

        final info = await RfbHandshake.perform(
          transport: pipe,
          reader: pipe.clientReader,
          config: const VncConnectionConfig(
            host: 'imac.local',
            credentials: VncCredentials(username: 'saved-mac-user'),
          ),
          onCredentialsRequired:
              ({
                required int securityType,
                required bool requiresUsername,
              }) async => const VncCredentials(password: 'prompted-only-pass'),
        );
        await serverTask;

        expect(decryptedUser, 'saved-mac-user');
        expect(decryptedPass, 'prompted-only-pass');
        expect(info.name, 'iMac');
      },
    );

    test(
      'decodes malformed UTF-8 in reason string and desktop name without throwing FormatException',
      () async {
        // Malformed UTF-8 in SecurityResult failure reason
        {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.008\n');
            await pipe.serverReader.readBytes(12);
            pipe.serverSend([1, RfbSecurityType.none]);
            await pipe.serverReader.readUint8();
            pipe.serverSendUint32(1);
            // Invalid UTF-8 bytes 0xFF, 0xFE surrounded by ASCII
            final badReason = Uint8List.fromList([
              0x42,
              0x61,
              0x64,
              0x20,
              0xFF,
              0xFE,
            ]);
            pipe.serverSendUint32(badReason.length);
            pipe.serverSend(badReason);
          }();

          await expectLater(
            RfbHandshake.perform(
              transport: pipe,
              reader: pipe.clientReader,
              config: const VncConnectionConfig(host: 'vnc.local'),
            ),
            throwsA(
              isA<VncAuthenticationException>().having(
                (e) => e.message,
                'message',
                contains('Bad '),
              ),
            ),
          );
          await serverTask;
        }

        // Malformed UTF-8 in ServerInit desktop name
        {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.008\n');
            await pipe.serverReader.readBytes(12);
            pipe.serverSend([1, RfbSecurityType.none]);
            await pipe.serverReader.readUint8();
            pipe.serverSendUint32(0);
            await pipe.serverReader.readUint8();

            final badName = Uint8List.fromList([0x4D, 0x61, 0x63, 0xFF, 0xFE]);
            final header = ByteData(4)
              ..setUint16(0, 800, Endian.big)
              ..setUint16(2, 600, Endian.big);
            final nameLen = ByteData(4)
              ..setUint32(0, badName.length, Endian.big);
            final packet = BytesBuilder(copy: false)
              ..add(header.buffer.asUint8List())
              ..add(VncPixelFormat.rgba8888.toBytes())
              ..add(nameLen.buffer.asUint8List())
              ..add(badName);
            pipe.serverSend(packet.takeBytes());

            await _verifyInitialSetMessages(pipe.serverReader);
          }();

          final info = await RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(host: 'vnc.local'),
          );
          await serverTask;

          expect(info.name, startsWith('Mac'));
          expect(info.name, contains('\uFFFD'));
        }
      },
    );

    test(
      'throws VncProtocolException on oversized reason string or desktop name (> 65536 bytes)',
      () async {
        // Oversized reason string
        {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.008\n');
            await pipe.serverReader.readBytes(12);
            pipe.serverSendUint8(0);
            pipe.serverSendUint32(65537);
          }();

          await expectLater(
            RfbHandshake.perform(
              transport: pipe,
              reader: pipe.clientReader,
              config: const VncConnectionConfig(host: 'vnc.local'),
            ),
            throwsA(isA<VncProtocolException>()),
          );
          await serverTask;
        }

        // Oversized desktop name
        {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.008\n');
            await pipe.serverReader.readBytes(12);
            pipe.serverSend([1, RfbSecurityType.none]);
            await pipe.serverReader.readUint8();
            pipe.serverSendUint32(0);
            await pipe.serverReader.readUint8();

            final header = ByteData(4)
              ..setUint16(0, 800, Endian.big)
              ..setUint16(2, 600, Endian.big);
            final nameLen = ByteData(4)..setUint32(0, 65537, Endian.big);
            final packet = BytesBuilder(copy: false)
              ..add(header.buffer.asUint8List())
              ..add(VncPixelFormat.rgba8888.toBytes())
              ..add(nameLen.buffer.asUint8List());
            pipe.serverSend(packet.takeBytes());
          }();

          await expectLater(
            RfbHandshake.perform(
              transport: pipe,
              reader: pipe.clientReader,
              config: const VncConnectionConfig(host: 'vnc.local'),
            ),
            throwsA(isA<VncProtocolException>()),
          );
          await serverTask;
        }
      },
    );

    test(
      'reads SecurityResult for RFB 003.889 with Type 1 None (OK and failure)',
      () async {
        // Success path
        {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.889\n');
            expect(
              ascii.decode(await pipe.serverReader.readBytes(12)),
              'RFB 003.008\n',
            );
            pipe.serverSend([1, RfbSecurityType.none]);
            expect(await pipe.serverReader.readUint8(), RfbSecurityType.none);
            pipe.serverSendUint32(0);
            expect(await pipe.serverReader.readUint8(), 1);
            pipe.serverSendServerInit(
              width: 1024,
              height: 768,
              name: 'Mac No-Auth',
            );
            await _verifyInitialSetMessages(pipe.serverReader);
          }();

          final info = await RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(host: 'mac.local'),
          );
          await serverTask;

          expect(info.protocolVersion, 'RFB 003.889');
          expect(info.securityType, RfbSecurityType.none);
        }

        // Failure path (SecurityResult = 1 + reason)
        {
          final pipe = _InMemoryVncPipe();
          addTearDown(pipe.dispose);

          final serverTask = () async {
            pipe.serverSendAscii('RFB 003.889\n');
            await pipe.serverReader.readBytes(12);
            pipe.serverSend([1, RfbSecurityType.none]);
            await pipe.serverReader.readUint8();
            pipe.serverSendUint32(1);
            pipe.serverSendReason('Screen Sharing disabled');
          }();

          await expectLater(
            RfbHandshake.perform(
              transport: pipe,
              reader: pipe.clientReader,
              config: const VncConnectionConfig(host: 'mac.local'),
            ),
            throwsA(
              isA<VncAuthenticationException>().having(
                (e) => e.message,
                'message',
                contains('Screen Sharing disabled'),
              ),
            ),
          );
          await serverTask;
        }
      },
    );

    test(
      'throws VncAuthenticationException on RFB 003.007 auth failure without reading a reason string',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.007\n');
          expect(
            ascii.decode(await pipe.serverReader.readBytes(12)),
            'RFB 003.007\n',
          );
          pipe.serverSend([1, RfbSecurityType.vncAuth]);
          expect(await pipe.serverReader.readUint8(), RfbSecurityType.vncAuth);
          pipe.serverSend(Uint8List(16));
          await pipe.serverReader.readBytes(16);
          // RFB 3.7 sends only the 4-byte SecurityResult (no reason string) and closes.
          pipe.serverSendUint32(1);
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(
              host: 'vnc37.local',
              credentials: VncCredentials(password: 'wrong'),
            ),
          ),
          throwsA(isA<VncAuthenticationException>()),
        );
        await serverTask;
      },
    );

    test(
      'throws VncProtocolException when ServerInit reports zero desktop dimensions',
      () async {
        final pipe = _InMemoryVncPipe();
        addTearDown(pipe.dispose);

        final serverTask = () async {
          pipe.serverSendAscii('RFB 003.008\n');
          await pipe.serverReader.readBytes(12);
          pipe.serverSend([1, RfbSecurityType.none]);
          await pipe.serverReader.readUint8();
          pipe.serverSendUint32(0);
          await pipe.serverReader.readUint8();
          pipe.serverSendServerInit(width: 0, height: 1080, name: 'Broken');
        }();

        await expectLater(
          RfbHandshake.perform(
            transport: pipe,
            reader: pipe.clientReader,
            config: const VncConnectionConfig(host: 'broken.local'),
          ),
          throwsA(isA<VncProtocolException>()),
        );
        await serverTask;
      },
    );
  });
}
