import 'dart:async';
import 'dart:convert';
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

String _bytesToHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

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

void main() {
  group('BufferedByteReader', () {
    test(
      'reads integers and byte slices across arbitrary chunk boundaries',
      () async {
        final controller = StreamController<Uint8List>();
        final reader = BufferedByteReader(controller.stream);

        // Push bytes split awkwardly across chunks:
        // uint8: 0xAB
        // uint16 BE: 0x1234
        // uint32 BE: 0xDEADBEEF
        // int32 BE: -223 (0xFFFFFF21) -> RFB DesktopSize pseudo-encoding
        // skip 3 bytes: 0x11, 0x22, 0x33
        // readBytes(4): [0xCA, 0xFE, 0xBA, 0xBE]
        controller.add(Uint8List.fromList([0xAB, 0x12]));
        controller.add(Uint8List.fromList([0x34, 0xDE, 0xAD]));
        controller.add(Uint8List.fromList([0xBE]));
        controller.add(Uint8List.fromList([0xEF, 0xFF, 0xFF]));
        controller.add(Uint8List.fromList([0xFF, 0x21, 0x11, 0x22]));
        controller.add(Uint8List.fromList([0x33, 0xCA]));
        controller.add(Uint8List.fromList([0xFE, 0xBA, 0xBE]));
        await controller.close();

        expect(await reader.readUint8(), 0xAB);
        expect(await reader.readUint16(), 0x1234);
        expect(await reader.readUint32(), 0xDEADBEEF);
        expect(await reader.readInt32(), -223);
        await reader.skip(3);
        expect(
          await reader.readBytes(4),
          Uint8List.fromList([0xCA, 0xFE, 0xBA, 0xBE]),
        );
        expect(await reader.readBytes(0), isEmpty);
        await reader.skip(0);

        await reader.dispose();
      },
    );

    test(
      'waits for asynchronous chunks that arrive after read starts',
      () async {
        final controller = StreamController<Uint8List>();
        final reader = BufferedByteReader(controller.stream);

        final future = reader.readInt32();
        controller.add(Uint8List.fromList([0x80, 0x00]));
        await Future<void>.delayed(Duration.zero);
        controller.add(Uint8List.fromList([0x00, 0x00]));

        expect(await future, -2147483648);
        await reader.dispose();
        await controller.close();
      },
    );

    test(
      'throws ArgumentError on negative count for readBytes and skip',
      () async {
        final controller = StreamController<Uint8List>();
        final reader = BufferedByteReader(controller.stream);

        await expectLater(reader.readBytes(-1), throwsArgumentError);
        await expectLater(reader.skip(-5), throwsArgumentError);

        await reader.dispose();
        await controller.close();
      },
    );

    test('throws StateError on concurrent pending reads', () async {
      final controller = StreamController<Uint8List>();
      final reader = BufferedByteReader(controller.stream);

      final firstRead = reader.readBytes(4);
      await expectLater(reader.readBytes(2), throwsStateError);

      controller.add(Uint8List.fromList([1, 2, 3, 4]));
      expect(await firstRead, Uint8List.fromList([1, 2, 3, 4]));

      await reader.dispose();
      await controller.close();
    });

    test(
      'throws VncConnectionException on EOF with insufficient bytes',
      () async {
        final controller = StreamController<Uint8List>();
        final reader = BufferedByteReader(controller.stream);

        controller.add(Uint8List.fromList([0x01, 0x02]));
        await controller.close();

        await expectLater(
          reader.readBytes(4),
          throwsA(isA<VncConnectionException>()),
        );
        await reader.dispose();
      },
    );

    test(
      'throws VncConnectionException when stream closes while waiting',
      () async {
        final controller = StreamController<Uint8List>();
        final reader = BufferedByteReader(controller.stream);

        final pending = reader.readUint32();
        controller.add(Uint8List.fromList([0x01, 0x02]));
        await controller.close();

        await expectLater(pending, throwsA(isA<VncConnectionException>()));
        await reader.dispose();
      },
    );

    test('throws VncConnectionException when stream emits an error', () async {
      final controller = StreamController<Uint8List>();
      final reader = BufferedByteReader(controller.stream);

      final pending = reader.readUint16();
      controller.addError(StateError('socket reset'));

      await expectLater(pending, throwsA(isA<VncConnectionException>()));
      await reader.dispose();
      await controller.close();
    });

    test('dispose fails pending read with VncConnectionException', () async {
      final controller = StreamController<Uint8List>();
      final reader = BufferedByteReader(controller.stream);

      final pending = reader.readUint16();
      final expectation = expectLater(
        pending,
        throwsA(isA<VncConnectionException>()),
      );
      await reader.dispose();

      await expectation;
      await controller.close();
    });
  });

  group('VncDes', () {
    test('reverseBits reverses bit order of an 8-bit byte', () {
      expect(VncDes.reverseBits(0x00), 0x00);
      expect(VncDes.reverseBits(0xFF), 0xFF);
      expect(VncDes.reverseBits(0x01), 0x80);
      expect(VncDes.reverseBits(0x80), 0x01);
      expect(VncDes.reverseBits(0xF0), 0x0F);
      expect(VncDes.reverseBits(0x0F), 0xF0);
      expect(VncDes.reverseBits(0xAA), 0x55);
      expect(VncDes.reverseBits(0x55), 0xAA);
      expect(VncDes.reverseBits(0xB4), 0x2D);
    });

    test('encryptBlock matches FIPS 46-3 / NIST DES-ECB test vectors', () {
      // Classic FIPS / Grabbe vector
      expect(
        _bytesToHex(
          VncDes.encryptBlock(
            _hexToBytes('0123456789ABCDEF'),
            _hexToBytes('133457799BBCDFF1'),
          ),
        ),
        '85E813540F0AB405',
      );

      // Equal key and plaintext vector
      expect(
        _bytesToHex(
          VncDes.encryptBlock(
            _hexToBytes('0123456789ABCDEF'),
            _hexToBytes('0123456789ABCDEF'),
          ),
        ),
        '56CC09E7CFDC4CEF',
      );

      // NIST "Now is t" vector
      expect(
        _bytesToHex(
          VncDes.encryptBlock(
            _hexToBytes('4E6F772069732074'),
            _hexToBytes('0123456789ABCDEF'),
          ),
        ),
        '3FA40E8A984D4815',
      );

      // MSB bit 63 set in both key and plaintext (verifies unsigned right shift >>>)
      expect(
        _bytesToHex(
          VncDes.encryptBlock(
            _hexToBytes('FEDCBA9876543210'),
            _hexToBytes('FEDCBA9876543210'),
          ),
        ),
        'A933F6183023B310',
      );

      // NIST SP 800-17 vector with MSB bit 63 set
      expect(
        _bytesToHex(
          VncDes.encryptBlock(
            _hexToBytes('95F8A5E5DD31D900'),
            _hexToBytes('8001010101010101'),
          ),
        ),
        '9E98757B1B604E9D',
      );
    });

    test('encryptBlock validates 8-byte block and key lengths', () {
      expect(
        () => VncDes.encryptBlock(Uint8List(7), Uint8List(8)),
        throwsArgumentError,
      );
      expect(
        () => VncDes.encryptBlock(Uint8List(8), Uint8List(9)),
        throwsArgumentError,
      );
    });

    test(
      'encryptChallenge matches RFB VNC Auth, is deterministic, and truncates at 8 bytes',
      () {
        final challenge = _hexToBytes('00112233445566778899AABBCCDDEEFF');

        final response = VncDes.encryptChallenge(challenge, 'secret');
        expect(response.length, 16);
        expect(_bytesToHex(response), 'F19B50471F60F42298E5C0147DB50E1E');

        // Determinism
        expect(VncDes.encryptChallenge(challenge, 'secret'), equals(response));

        // 8-byte password truncation per RFC 6143
        final exact8 = VncDes.encryptChallenge(challenge, '12345678');
        final longer = VncDes.encryptChallenge(
          challenge,
          '12345678extra-ignored',
        );
        expect(longer, equals(exact8));

        // Challenge length validation
        expect(
          () => VncDes.encryptChallenge(Uint8List(15), 'secret'),
          throwsArgumentError,
        );
      },
    );
  });

  group('ArdAuthCrypto', () {
    // 128-byte (1024-bit) RFC 2409 Oakley Group 2 safe prime
    final prime128 = _hexToBytes(
      'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD1'
      '29024E088A67CC74020BBEA63B139B22514A08798E3404DD'
      'EF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245'
      'E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED'
      'EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381'
      'FFFFFFFFFFFFFFFF',
    );

    test('bytesToBigInt and bigIntToFixedBytes round-trip unsigned values', () {
      final bytes = Uint8List.fromList([0x80, 0x00, 0x01, 0xFF]);
      final value = ArdAuthCrypto.bytesToBigInt(bytes);
      expect(value, BigInt.parse('800001FF', radix: 16));
      expect(ArdAuthCrypto.bigIntToFixedBytes(value, 4), equals(bytes));
      expect(
        ArdAuthCrypto.bigIntToFixedBytes(value, 6),
        Uint8List.fromList([0x00, 0x00, 0x80, 0x00, 0x01, 0xFF]),
      );
      expect(ArdAuthCrypto.bigIntToFixedBytes(BigInt.zero, 4), Uint8List(4));
    });

    test(
      'deterministic DH exchange allows server to derive MD5 AES-128 key and decrypt credentials',
      () {
        const generator = 2;
        final keyLength = prime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(prime128);

        final serverPriv = BigInt.parse(
          '123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0',
          radix: 16,
        );
        final clientPriv = BigInt.parse(
          'FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210',
          radix: 16,
        );

        final serverPub = BigInt.from(generator).modPow(serverPriv, prime);
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          serverPub,
          keyLength,
        );

        final response = ArdAuthCrypto.buildResponse(
          generator: generator,
          keyLength: keyLength,
          primeBytes: prime128,
          serverPublicKeyBytes: serverPubBytes,
          username: 'mac-admin',
          password: 's3cr3t-password!',
          clientPrivateKeyOverride: clientPriv,
        );

        expect(response.clientPublicKey.length, keyLength);
        expect(response.encryptedCredentials.length, 128);

        // Server derives shared secret from clientPublicKey
        final clientPub = ArdAuthCrypto.bytesToBigInt(response.clientPublicKey);
        expect(clientPub, BigInt.from(generator).modPow(clientPriv, prime));

        final serverShared = clientPub.modPow(serverPriv, prime);
        final serverSharedBytes = ArdAuthCrypto.bigIntToFixedBytes(
          serverShared,
          keyLength,
        );
        final aesKey = Uint8List.fromList(md5.convert(serverSharedBytes).bytes);

        final plaintext = _aesEcbDecrypt(response.encryptedCredentials, aesKey);
        expect(_readNullTerminatedUtf8(plaintext, 0, 64), 'mac-admin');
        expect(_readNullTerminatedUtf8(plaintext, 64, 64), 's3cr3t-password!');
      },
    );

    test(
      'safely truncates >63-byte ASCII and multi-byte UTF-8 credentials with null termination',
      () {
        const generator = 2;
        final keyLength = prime128.length;
        final prime = ArdAuthCrypto.bytesToBigInt(prime128);
        final serverPriv = BigInt.from(123456789);
        final serverPubBytes = ArdAuthCrypto.bigIntToFixedBytes(
          BigInt.from(generator).modPow(serverPriv, prime),
          keyLength,
        );

        // 25 CJK characters = 75 UTF-8 bytes (> 63 bytes; 21 chars = 63 bytes exact,
        // and with a 1-byte prefix 'a' + 21 CJK chars = 64 bytes so byte 63 splits a 3-byte char!)
        final longUtf8User =
            'a${'中' * 25}'; // 1 + 75 bytes -> must truncate cleanly at 1 + 20*3 = 61 bytes
        final longAsciiPass =
            'p' * 80; // 80 bytes -> must truncate to 63 bytes + 0x00 at byte 63

        final response = ArdAuthCrypto.buildResponse(
          generator: generator,
          keyLength: keyLength,
          primeBytes: prime128,
          serverPublicKeyBytes: serverPubBytes,
          username: longUtf8User,
          password: longAsciiPass,
        );

        final clientPub = ArdAuthCrypto.bytesToBigInt(response.clientPublicKey);
        final serverSharedBytes = ArdAuthCrypto.bigIntToFixedBytes(
          clientPub.modPow(serverPriv, prime),
          keyLength,
        );
        final aesKey = Uint8List.fromList(md5.convert(serverSharedBytes).bytes);
        final plaintext = _aesEcbDecrypt(response.encryptedCredentials, aesKey);

        final decodedUser = _readNullTerminatedUtf8(plaintext, 0, 64);
        final decodedPass = _readNullTerminatedUtf8(plaintext, 64, 64);

        expect(decodedUser, 'a${'中' * 20}');
        expect(utf8.encode(decodedUser).length, lessThanOrEqualTo(63));
        expect(plaintext[utf8.encode(decodedUser).length], 0);

        expect(decodedPass, 'p' * 63);
        expect(plaintext[64 + 63], 0);
      },
    );

    test(
      'validates keyLength, primeBytes, serverPublicKeyBytes, and prime > 1',
      () {
        expect(
          () => ArdAuthCrypto.buildResponse(
            generator: 2,
            keyLength: 0,
            primeBytes: Uint8List(0),
            serverPublicKeyBytes: Uint8List(0),
            username: 'u',
            password: 'p',
          ),
          throwsArgumentError,
        );
        expect(
          () => ArdAuthCrypto.buildResponse(
            generator: 2,
            keyLength: 4,
            primeBytes: Uint8List(3),
            serverPublicKeyBytes: Uint8List(4),
            username: 'u',
            password: 'p',
          ),
          throwsArgumentError,
        );
        expect(
          () => ArdAuthCrypto.buildResponse(
            generator: 2,
            keyLength: 4,
            primeBytes: Uint8List.fromList([0, 0, 0, 1]),
            serverPublicKeyBytes: Uint8List(4),
            username: 'u',
            password: 'p',
          ),
          throwsArgumentError,
        );
      },
    );
  });
}
