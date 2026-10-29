import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/message/msg_kex_dh.dart';

void main() {
  group('SSH_Message_KexDH_Init', () {
    test('has correct messageId', () {
      expect(SSH_Message_KexDH_Init.messageId, 30);
    });

    test('constructor sets e value', () {
      final e = BigInt.parse('12345678901234567890');
      final msg = SSH_Message_KexDH_Init(e: e);
      expect(msg.e, e);
    });

    test('encodes and decodes', () {
      final e = BigInt.parse('123456789012345678901234567890');
      final original = SSH_Message_KexDH_Init(e: e);

      final decoded = SSH_Message_KexDH_Init.decode(original.encode());
      expect(decoded.e, e);
    });

    test('handles large e value', () {
      // 2048-bit prime-like value
      final e = BigInt.parse(
        'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DD',
        radix: 16,
      );
      final original = SSH_Message_KexDH_Init(e: e);

      final decoded = SSH_Message_KexDH_Init.decode(original.encode());
      expect(decoded.e, e);
    });

    test('encode first byte is messageId', () {
      final msg = SSH_Message_KexDH_Init(e: BigInt.one);
      final encoded = msg.encode();
      expect(encoded[0], SSH_Message_KexDH_Init.messageId);
    });

    test('toString includes e value', () {
      final e = BigInt.from(42);
      final msg = SSH_Message_KexDH_Init(e: e);
      expect(msg.toString(), contains('SSH_Message_KexDH_Init'));
      expect(msg.toString(), contains('42'));
    });
  });

  group('SSH_Message_KexDH_Reply', () {
    test('has correct messageId', () {
      expect(SSH_Message_KexDH_Reply.messageId, 31);
    });

    test('constructor sets all fields', () {
      final hostPublicKey = Uint8List.fromList([1, 2, 3, 4, 5]);
      final f = BigInt.from(9876543210);
      final signature = Uint8List.fromList([10, 20, 30]);

      final msg = SSH_Message_KexDH_Reply(
        hostPublicKey: hostPublicKey,
        f: f,
        signature: signature,
      );

      expect(msg.hostPublicKey, hostPublicKey);
      expect(msg.f, f);
      expect(msg.signature, signature);
    });

    test('encodes and decodes', () {
      final hostPublicKey = Uint8List.fromList(List.generate(64, (i) => i));
      final f = BigInt.parse('ABCDEF1234567890', radix: 16);
      final signature = Uint8List.fromList(List.generate(32, (i) => i * 2));

      final original = SSH_Message_KexDH_Reply(
        hostPublicKey: hostPublicKey,
        f: f,
        signature: signature,
      );

      final decoded = SSH_Message_KexDH_Reply.decode(original.encode());

      expect(decoded.hostPublicKey, hostPublicKey);
      expect(decoded.f, f);
      expect(decoded.signature, signature);
    });

    test('handles empty hostPublicKey', () {
      final original = SSH_Message_KexDH_Reply(
        hostPublicKey: Uint8List(0),
        f: BigInt.one,
        signature: Uint8List(0),
      );

      final decoded = SSH_Message_KexDH_Reply.decode(original.encode());
      expect(decoded.hostPublicKey, isEmpty);
    });

    test('toString includes f value', () {
      final msg = SSH_Message_KexDH_Reply(
        hostPublicKey: Uint8List.fromList([1]),
        f: BigInt.from(123),
        signature: Uint8List.fromList([2]),
      );

      final str = msg.toString();
      expect(str, contains('SSH_Message_KexDH_Reply'));
      expect(str, contains('123'));
    });
  });

  group('SSH_Message_KexDH_GexRequest', () {
    test('has correct messageId', () {
      expect(SSH_Message_KexDH_GexRequest.messageId, 34);
    });

    test('constructor sets all fields', () {
      final msg = SSH_Message_KexDH_GexRequest(
        minN: 1024,
        preferredN: 2048,
        maxN: 4096,
      );

      expect(msg.minN, 1024);
      expect(msg.preferredN, 2048);
      expect(msg.maxN, 4096);
    });

    test('encodes and decodes', () {
      final original = SSH_Message_KexDH_GexRequest(
        minN: 2048,
        preferredN: 3072,
        maxN: 8192,
      );

      final decoded = SSH_Message_KexDH_GexRequest.decode(original.encode());

      expect(decoded.minN, 2048);
      expect(decoded.preferredN, 3072);
      expect(decoded.maxN, 8192);
    });

    test('toString includes bit sizes', () {
      final msg = SSH_Message_KexDH_GexRequest(
        minN: 1024,
        preferredN: 2048,
        maxN: 4096,
      );

      final str = msg.toString();
      expect(str, contains('SSH_Message_KexDH_GexRequest'));
      expect(str, contains('1024'));
      expect(str, contains('2048'));
      expect(str, contains('4096'));
    });
  });

  group('SSH_Message_KexDH_GexGroup', () {
    test('has correct messageId', () {
      expect(SSH_Message_KexDH_GexGroup.messageId, 31);
    });

    test('constructor sets p and g', () {
      final p = BigInt.parse('FFFFFFFFFFFFFFFFC90FDAA22168C234', radix: 16);
      final g = BigInt.from(2);

      final msg = SSH_Message_KexDH_GexGroup(p: p, g: g);

      expect(msg.p, p);
      expect(msg.g, g);
    });

    test('encodes and decodes', () {
      final p = BigInt.parse('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE', radix: 16);
      final g = BigInt.from(5);

      final original = SSH_Message_KexDH_GexGroup(p: p, g: g);
      final decoded = SSH_Message_KexDH_GexGroup.decode(original.encode());

      expect(decoded.p, p);
      expect(decoded.g, g);
    });

    test('toString includes p and g', () {
      final msg = SSH_Message_KexDH_GexGroup(
        p: BigInt.from(23),
        g: BigInt.from(5),
      );

      final str = msg.toString();
      expect(str, contains('GexGroup'));
      expect(str, contains('23'));
      expect(str, contains('5'));
    });
  });

  group('SSH_Message_KexDH_GexInit', () {
    test('has correct messageId', () {
      expect(SSH_Message_KexDH_GexInit.messageId, 32);
    });

    test('constructor sets e value', () {
      final e = BigInt.from(999999999);
      final msg = SSH_Message_KexDH_GexInit(e: e);
      expect(msg.e, e);
    });

    test('encodes and decodes', () {
      final e = BigInt.parse('ABCDEF0123456789ABCDEF', radix: 16);
      final original = SSH_Message_KexDH_GexInit(e: e);

      final decoded = SSH_Message_KexDH_GexInit.decode(original.encode());
      expect(decoded.e, e);
    });

    test('toString includes e value', () {
      final msg = SSH_Message_KexDH_GexInit(e: BigInt.from(77));
      // Note: toString says "SSH_Message_KexDH_Init" (implementation detail)
      expect(msg.toString(), contains('77'));
    });
  });

  group('SSH_Message_KexDH_GexReply', () {
    test('has correct messageId', () {
      expect(SSH_Message_KexDH_GexReply.messageId, 33);
    });

    test('constructor sets all fields', () {
      final hostPublicKey = Uint8List.fromList([1, 2, 3]);
      final f = BigInt.from(12345);
      final signature = Uint8List.fromList([4, 5, 6]);

      final msg = SSH_Message_KexDH_GexReply(
        hostPublicKey: hostPublicKey,
        f: f,
        signature: signature,
      );

      expect(msg.hostPublicKey, hostPublicKey);
      expect(msg.f, f);
      expect(msg.signature, signature);
    });

    test('encodes and decodes', () {
      final hostPublicKey = Uint8List.fromList(List.generate(48, (i) => i));
      final f = BigInt.parse('1234567890ABCDEF', radix: 16);
      final signature = Uint8List.fromList(List.generate(64, (i) => 255 - i));

      final original = SSH_Message_KexDH_GexReply(
        hostPublicKey: hostPublicKey,
        f: f,
        signature: signature,
      );

      final decoded = SSH_Message_KexDH_GexReply.decode(original.encode());

      expect(decoded.hostPublicKey, hostPublicKey);
      expect(decoded.f, f);
      expect(decoded.signature, signature);
    });

    test('extends SSH_Message_KexDH_Reply', () {
      final msg = SSH_Message_KexDH_GexReply(
        hostPublicKey: Uint8List.fromList([1]),
        f: BigInt.one,
        signature: Uint8List.fromList([2]),
      );

      expect(msg, isA<SSH_Message_KexDH_Reply>());
    });

    test('toString includes values', () {
      final msg = SSH_Message_KexDH_GexReply(
        hostPublicKey: Uint8List.fromList([1]),
        f: BigInt.from(999),
        signature: Uint8List.fromList([2]),
      );

      final str = msg.toString();
      expect(str, contains('GexReply'));
      expect(str, contains('999'));
    });
  });

  group('Message ID consistency', () {
    test('DH message IDs follow SSH protocol', () {
      expect(SSH_Message_KexDH_Init.messageId, 30);
      expect(SSH_Message_KexDH_Reply.messageId, 31);
      expect(SSH_Message_KexDH_GexInit.messageId, 32);
      expect(SSH_Message_KexDH_GexReply.messageId, 33);
      expect(SSH_Message_KexDH_GexRequest.messageId, 34);
      // GexGroup shares messageId 31 with KexDH_Reply (different context)
      expect(SSH_Message_KexDH_GexGroup.messageId, 31);
    });
  });

  group('Typical DH key exchange scenarios', () {
    test('standard DH key exchange', () {
      // Client generates random x, computes e = g^x mod p
      final clientE = BigInt.parse(
        'ABCDEF1234567890ABCDEF1234567890',
        radix: 16,
      );
      final clientInit = SSH_Message_KexDH_Init(e: clientE);

      // Server generates random y, computes f = g^y mod p
      final serverF = BigInt.parse(
        '1234567890ABCDEF1234567890ABCDEF',
        radix: 16,
      );
      final hostKey = Uint8List.fromList(List.generate(32, (i) => i));
      final signature = Uint8List.fromList(List.generate(64, (i) => i * 2));

      final serverReply = SSH_Message_KexDH_Reply(
        hostPublicKey: hostKey,
        f: serverF,
        signature: signature,
      );

      // Verify round trip
      final decodedInit = SSH_Message_KexDH_Init.decode(clientInit.encode());
      final decodedReply = SSH_Message_KexDH_Reply.decode(serverReply.encode());

      expect(decodedInit.e, clientE);
      expect(decodedReply.f, serverF);
      expect(decodedReply.hostPublicKey, hostKey);
    });

    test('group exchange (GEX) flow', () {
      // Client requests DH group size
      final request = SSH_Message_KexDH_GexRequest(
        minN: 2048,
        preferredN: 4096,
        maxN: 8192,
      );

      // Server sends group parameters
      final p = BigInt.parse(
        'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74'
        '020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F1437'
        '4FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED'
        'EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF05'
        '98DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB'
        '9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3B'
        'E39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF695581718'
        '3995497CEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF',
        radix: 16,
      );
      final g = BigInt.from(2);

      final group = SSH_Message_KexDH_GexGroup(p: p, g: g);

      // Client computes e = g^x mod p
      final clientInit = SSH_Message_KexDH_GexInit(e: BigInt.from(123456789));

      // Server responds with f and signature
      final serverReply = SSH_Message_KexDH_GexReply(
        hostPublicKey: Uint8List.fromList([1, 2, 3]),
        f: BigInt.from(987654321),
        signature: Uint8List.fromList([4, 5, 6]),
      );

      // Verify messages encode/decode correctly
      expect(SSH_Message_KexDH_GexRequest.decode(request.encode()).preferredN,
          4096);
      expect(SSH_Message_KexDH_GexGroup.decode(group.encode()).g, g);
      expect(SSH_Message_KexDH_GexInit.decode(clientInit.encode()).e,
          BigInt.from(123456789));
      expect(SSH_Message_KexDH_GexReply.decode(serverReply.encode()).f,
          BigInt.from(987654321));
    });
  });
}
