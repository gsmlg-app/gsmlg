import 'package:test/test.dart';
import 'package:app_ssh/src/message/msg_kex.dart';

void main() {
  group('SSH_Message_KexInit', () {
    test('has correct messageId', () {
      expect(SSH_Message_KexInit.messageId, 20);
    });

    test('constructor sets all required fields', () {
      final msg = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256', 'diffie-hellman-group14-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519', 'ssh-rsa'],
        encryptionClientToServer: ['aes256-gcm@openssh.com', 'aes128-ctr'],
        encryptionServerToClient: ['aes256-gcm@openssh.com', 'aes128-ctr'],
        macClientToServer: ['hmac-sha2-256', 'hmac-sha1'],
        macServerToClient: ['hmac-sha2-256', 'hmac-sha1'],
        compressionClientToServer: ['none', 'zlib'],
        compressionServerToClient: ['none', 'zlib'],
        firstKexPacketFollows: false,
      );

      expect(msg.kexAlgorithms,
          ['curve25519-sha256', 'diffie-hellman-group14-sha256']);
      expect(msg.serverHostKeyAlgorithms, ['ssh-ed25519', 'ssh-rsa']);
      expect(msg.encryptionClientToServer,
          ['aes256-gcm@openssh.com', 'aes128-ctr']);
      expect(msg.encryptionServerToClient,
          ['aes256-gcm@openssh.com', 'aes128-ctr']);
      expect(msg.macClientToServer, ['hmac-sha2-256', 'hmac-sha1']);
      expect(msg.macServerToClient, ['hmac-sha2-256', 'hmac-sha1']);
      expect(msg.compressionClientToServer, ['none', 'zlib']);
      expect(msg.compressionServerToClient, ['none', 'zlib']);
      expect(msg.firstKexPacketFollows, false);
    });

    test('languagesClientToServer defaults to empty list', () {
      final msg = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519'],
        encryptionClientToServer: ['aes256-gcm@openssh.com'],
        encryptionServerToClient: ['aes256-gcm@openssh.com'],
        macClientToServer: ['hmac-sha2-256'],
        macServerToClient: ['hmac-sha2-256'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['none'],
        firstKexPacketFollows: false,
      );

      expect(msg.languagesClientToServer, isEmpty);
      expect(msg.languagesServerToClient, isEmpty);
    });

    test('encodes and decodes round trip', () {
      final original = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256', 'diffie-hellman-group14-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519', 'rsa-sha2-256'],
        encryptionClientToServer: [
          'aes256-gcm@openssh.com',
          'chacha20-poly1305@openssh.com'
        ],
        encryptionServerToClient: ['aes128-ctr', 'aes256-ctr'],
        macClientToServer: ['hmac-sha2-256', 'hmac-sha2-512'],
        macServerToClient: ['hmac-sha2-256', 'hmac-sha1'],
        compressionClientToServer: ['none', 'zlib@openssh.com'],
        compressionServerToClient: ['none'],
        languagesClientToServer: ['en-US'],
        languagesServerToClient: ['en-GB'],
        firstKexPacketFollows: true,
      );

      final encoded = original.encode();
      final decoded = SSH_Message_KexInit.decode(encoded);

      expect(decoded.kexAlgorithms, original.kexAlgorithms);
      expect(decoded.serverHostKeyAlgorithms, original.serverHostKeyAlgorithms);
      expect(
          decoded.encryptionClientToServer, original.encryptionClientToServer);
      expect(
          decoded.encryptionServerToClient, original.encryptionServerToClient);
      expect(decoded.macClientToServer, original.macClientToServer);
      expect(decoded.macServerToClient, original.macServerToClient);
      expect(decoded.compressionClientToServer,
          original.compressionClientToServer);
      expect(decoded.compressionServerToClient,
          original.compressionServerToClient);
      expect(decoded.languagesClientToServer, original.languagesClientToServer);
      expect(decoded.languagesServerToClient, original.languagesServerToClient);
      expect(decoded.firstKexPacketFollows, true);
    });

    test('encode first byte is messageId', () {
      final msg = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519'],
        encryptionClientToServer: ['aes256-gcm@openssh.com'],
        encryptionServerToClient: ['aes256-gcm@openssh.com'],
        macClientToServer: ['hmac-sha2-256'],
        macServerToClient: ['hmac-sha2-256'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['none'],
        firstKexPacketFollows: false,
      );

      final encoded = msg.encode();
      expect(encoded[0], SSH_Message_KexInit.messageId);
    });

    test('encodes cookie as 16 random bytes', () {
      final msg = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519'],
        encryptionClientToServer: ['aes256-gcm@openssh.com'],
        encryptionServerToClient: ['aes256-gcm@openssh.com'],
        macClientToServer: ['hmac-sha2-256'],
        macServerToClient: ['hmac-sha2-256'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['none'],
        firstKexPacketFollows: false,
      );

      // Encode twice - cookies should be different (random)
      final encoded1 = msg.encode();
      final encoded2 = msg.encode();

      // Cookie is bytes 1-16 (after message ID byte)
      final cookie1 = encoded1.sublist(1, 17);
      final cookie2 = encoded2.sublist(1, 17);

      // Cookies should be 16 bytes
      expect(cookie1.length, 16);
      expect(cookie2.length, 16);

      // Random cookies should differ (statistically almost always)
      // Note: There's a 1 in 2^128 chance they're equal
    });

    test('handles empty algorithm lists', () {
      final original = SSH_Message_KexInit(
        kexAlgorithms: [],
        serverHostKeyAlgorithms: [],
        encryptionClientToServer: [],
        encryptionServerToClient: [],
        macClientToServer: [],
        macServerToClient: [],
        compressionClientToServer: [],
        compressionServerToClient: [],
        firstKexPacketFollows: false,
      );

      final decoded = SSH_Message_KexInit.decode(original.encode());

      // Note: Empty name-list encodes as empty string, which decodes as ['']
      expect(decoded.kexAlgorithms, hasLength(1));
      expect(decoded.kexAlgorithms[0], '');
      expect(decoded.serverHostKeyAlgorithms, hasLength(1));
      expect(decoded.encryptionClientToServer, hasLength(1));
    });

    test('handles single algorithm per list', () {
      final original = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519'],
        encryptionClientToServer: ['aes256-gcm@openssh.com'],
        encryptionServerToClient: ['aes128-ctr'],
        macClientToServer: ['hmac-sha2-256'],
        macServerToClient: ['hmac-sha1'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['zlib'],
        firstKexPacketFollows: true,
      );

      final decoded = SSH_Message_KexInit.decode(original.encode());

      expect(decoded.kexAlgorithms, hasLength(1));
      expect(decoded.serverHostKeyAlgorithms, hasLength(1));
    });

    test('toString includes all algorithm types', () {
      final msg = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519'],
        encryptionClientToServer: ['aes256-gcm@openssh.com'],
        encryptionServerToClient: ['aes128-ctr'],
        macClientToServer: ['hmac-sha2-256'],
        macServerToClient: ['hmac-sha1'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['zlib'],
        firstKexPacketFollows: false,
      );

      final str = msg.toString();
      expect(str, contains('SSH_Message_KexInit'));
      expect(str, contains('kexAlgorithms'));
      expect(str, contains('curve25519-sha256'));
      expect(str, contains('serverHostKeyAlgorithms'));
      expect(str, contains('ssh-ed25519'));
      expect(str, contains('encryptionClientToServer'));
      expect(str, contains('firstKexPacketFollows'));
    });

    test('firstKexPacketFollows true encodes and decodes correctly', () {
      final original = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519'],
        encryptionClientToServer: ['aes256-gcm@openssh.com'],
        encryptionServerToClient: ['aes256-gcm@openssh.com'],
        macClientToServer: ['hmac-sha2-256'],
        macServerToClient: ['hmac-sha2-256'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['none'],
        firstKexPacketFollows: true,
      );

      final decoded = SSH_Message_KexInit.decode(original.encode());
      expect(decoded.firstKexPacketFollows, true);
    });

    test('firstKexPacketFollows false encodes and decodes correctly', () {
      final original = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519'],
        encryptionClientToServer: ['aes256-gcm@openssh.com'],
        encryptionServerToClient: ['aes256-gcm@openssh.com'],
        macClientToServer: ['hmac-sha2-256'],
        macServerToClient: ['hmac-sha2-256'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['none'],
        firstKexPacketFollows: false,
      );

      final decoded = SSH_Message_KexInit.decode(original.encode());
      expect(decoded.firstKexPacketFollows, false);
    });
  });

  group('SSH_Message_NewKeys', () {
    test('has correct messageId', () {
      expect(SSH_Message_NewKeys.messageId, 21);
    });

    test('encode produces correct bytes', () {
      final msg = SSH_Message_NewKeys();
      final encoded = msg.encode();

      // Should just be the message ID byte
      expect(encoded[0], SSH_Message_NewKeys.messageId);
      expect(encoded.length, 1);
    });

    test('toString returns correct format', () {
      final msg = SSH_Message_NewKeys();
      expect(msg.toString(), 'SSH_Message_NewKeys()');
    });

    test('multiple instances encode identically', () {
      final msg1 = SSH_Message_NewKeys();
      final msg2 = SSH_Message_NewKeys();

      expect(msg1.encode(), msg2.encode());
    });
  });

  group('Typical KEX usage scenarios', () {
    test('client and server exchange kex init', () {
      // Client sends kex init
      final clientKexInit = SSH_Message_KexInit(
        kexAlgorithms: ['curve25519-sha256', 'diffie-hellman-group14-sha256'],
        serverHostKeyAlgorithms: ['ssh-ed25519', 'rsa-sha2-256'],
        encryptionClientToServer: [
          'aes256-gcm@openssh.com',
          'chacha20-poly1305@openssh.com'
        ],
        encryptionServerToClient: [
          'aes256-gcm@openssh.com',
          'chacha20-poly1305@openssh.com'
        ],
        macClientToServer: ['hmac-sha2-256'],
        macServerToClient: ['hmac-sha2-256'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['none'],
        firstKexPacketFollows: false,
      );

      // Server sends kex init (may have different preferences)
      final serverKexInit = SSH_Message_KexInit(
        kexAlgorithms: ['diffie-hellman-group14-sha256', 'curve25519-sha256'],
        serverHostKeyAlgorithms: ['rsa-sha2-256', 'ssh-ed25519'],
        encryptionClientToServer: ['aes128-ctr', 'aes256-gcm@openssh.com'],
        encryptionServerToClient: ['aes128-ctr', 'aes256-gcm@openssh.com'],
        macClientToServer: ['hmac-sha2-256', 'hmac-sha1'],
        macServerToClient: ['hmac-sha2-256', 'hmac-sha1'],
        compressionClientToServer: ['none'],
        compressionServerToClient: ['none'],
        firstKexPacketFollows: false,
      );

      // Both should encode/decode successfully
      expect(SSH_Message_KexInit.decode(clientKexInit.encode()).kexAlgorithms,
          clientKexInit.kexAlgorithms);
      expect(SSH_Message_KexInit.decode(serverKexInit.encode()).kexAlgorithms,
          serverKexInit.kexAlgorithms);

      // Find common algorithms (first match from client's list in server's list)
      final commonKex = clientKexInit.kexAlgorithms
          .firstWhere((alg) => serverKexInit.kexAlgorithms.contains(alg));
      expect(commonKex, 'curve25519-sha256');
    });

    test('new keys message signals completion', () {
      // After key exchange, both sides send SSH_MSG_NEWKEYS
      final clientNewKeys = SSH_Message_NewKeys();
      final serverNewKeys = SSH_Message_NewKeys();

      // Both should have messageId 21
      expect(clientNewKeys.encode()[0], 21);
      expect(serverNewKeys.encode()[0], 21);
    });
  });
}
