import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:app_ssh/src/kex/kex_x25519.dart';
import 'package:app_ssh/src/message/msg_kex.dart';
import 'package:app_ssh/src/message/msg_kex_ecdh.dart';
import 'package:app_ssh/src/message/msg_service.dart';
import 'package:app_ssh/src/message/msg_userauth.dart';
import 'package:app_ssh/src/ssh_kex_utils.dart';
import 'package:app_ssh/src/ssh_message.dart';
import 'package:app_ssh/src/ssh_packet.dart';
import 'package:app_ssh/src/utils/cipher_ext.dart';
import 'package:pointycastle/export.dart';
import 'package:test/test.dart';

void main() {
  group('SSHClient host key verification during real key exchange', () {
    late _SshPeer peer;
    late SSHClient client;
    late int passwordRequests;

    SSHClient connect({
      SSHHostkeyVerifyHandler? sha256,
      SSHHostkeyVerifyHandler? md5,
    }) {
      client = SSHClient(
        peer,
        username: 'test',
        algorithms: _SshPeer.algorithms,
        onVerifyHostKeySha256: sha256,
        onVerifyHostKey: md5,
        onPasswordRequest: () {
          passwordRequests++;
          return 'test-password';
        },
        keepAliveInterval: null,
      );
      return client;
    }

    void expectNoAuthentication() {
      expect(peer.clientNewKeys, isFalse);
      expect(peer.serviceRequests, 0);
      expect(peer.authMethods, isEmpty);
      expect(passwordRequests, 0);
    }

    setUp(() {
      peer = _SshPeer();
      passwordRequests = 0;
    });

    tearDown(() async {
      client.close();
      await peer.close();
    });

    test('SHA-256 receives the host key digest before authentication',
        () async {
      var verifications = 0;
      final decision = Completer<bool>();
      final prompted = Completer<void>();
      connect(sha256: (type, digest) {
        verifications++;
        expect(type, 'ssh-ed25519');
        // Independently calculated from the tracked OpenSSH .pub fixture.
        expect(base64.encode(digest),
            '05uKumaBmL4bvejz1K/+08rtuU18KVnsui+E0+WJqaI=');
        prompted.complete();
        return decision.future;
      });

      await prompted.future;
      expectNoAuthentication();
      decision.complete(true);
      await client.authenticated;
      expect(verifications, 1);
      expect(peer.clientNewKeys, isTrue);
      expect(peer.serviceRequests, 1);
      expect(peer.authMethods, ['password']);
      expect(passwordRequests, 1);
    });

    test('SHA-256 takes precedence over legacy MD5', () async {
      var legacyCalls = 0;
      connect(
        sha256: (_, digest) {
          expect(digest, hasLength(32));
          return true;
        },
        md5: (_, __) {
          legacyCalls++;
          return false;
        },
      );
      await client.authenticated;
      expect(legacyCalls, 0);
      expect(passwordRequests, 1);
    });

    test('legacy MD5 still verifies and permits authentication', () async {
      var legacyCalls = 0;
      connect(md5: (type, digest) {
        legacyCalls++;
        expect(type, 'ssh-ed25519');
        expect(digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
            'e8dc99857696de2c46b38fb7870f1a1f');
        return true;
      });
      await client.authenticated;
      expect(legacyCalls, 1);
      expect(passwordRequests, 1);
    });

    for (final legacy in [false, true]) {
      test('${legacy ? 'MD5' : 'SHA-256'} rejection prevents authentication',
          () async {
        connect(
          sha256: legacy ? null : (_, __) => false,
          md5: legacy ? (_, __) => false : null,
        );
        await expectLater(
            client.authenticated, throwsA(isA<SSHHostkeyError>()));
        expect(client.isClosed, isTrue);
        expectNoAuthentication();
      });
    }

    test('asynchronous ordinary error fails closed', () async {
      connect(sha256: (_, __) async {
        await Future<void>.value();
        throw StateError('trust store unavailable');
      });
      await expectLater(
          client.authenticated,
          throwsA(isA<SSHHostkeyError>().having((error) => error.toString(),
              'diagnostic', contains('trust store unavailable'))));
      expect(client.isClosed, isTrue);
      expectNoAuthentication();
    }, timeout: const Timeout(Duration(seconds: 3)));

    test('synchronous ordinary throw fails closed', () async {
      connect(sha256: (_, __) => throw StateError('trust store unavailable'));
      await expectLater(
          client.authenticated,
          throwsA(isA<SSHHostkeyError>().having((error) => error.toString(),
              'diagnostic', contains('trust store unavailable'))));
      expect(client.isClosed, isTrue);
      expectNoAuthentication();
    }, timeout: const Timeout(Duration(seconds: 3)));

    test('host-key failure remains visible to the connection caller', () async {
      connect(sha256: (_, __) {
        throw SSHHostkeyError(
          'SSH host key changed for server.example:22; '
          'saved SHA256:original, received SHA256:changed',
        );
      });
      await expectLater(
        client.authenticated,
        throwsA(isA<SSHHostkeyError>().having(
          (error) => error.toString(),
          'diagnostic',
          contains('SSH host key changed for server.example:22'),
        )),
      );
      expectNoAuthentication();
    });

    test('closing while verification waits never resumes authentication',
        () async {
      final decision = Completer<bool>();
      final prompted = Completer<void>();
      connect(sha256: (_, __) {
        prompted.complete();
        return decision.future;
      });
      await prompted.future;
      final aborted =
          expectLater(client.authenticated, throwsA(isA<SSHAuthAbortError>()));
      client.close();
      await aborted;
      decision.complete(true);
      await Future<void>.delayed(Duration.zero);
      expect(client.isClosed, isTrue);
      expect(peer.writesAfterClose, 0);
      expectNoAuthentication();
    });
  });
}

/// A hermetic SSH peer: real Curve25519/Ed25519 key exchange, AES-CTR packets,
/// HMAC validation, and password authentication, with no network connection.
class _SshPeer implements SSHSocket {
  static const version = 'SSH-2.0-HostKeyRegressionPeer';
  static const algorithms = SSHAlgorithms(
    kex: [SSHKexType.x25519],
    hostkey: [SSHHostkeyType.ed25519],
    cipher: [SSHCipherType.aes128ctr],
    mac: [SSHMacType.hmacSha256],
  );

  final _incoming = StreamController<Uint8List>();
  final _outgoing = StreamController<List<int>>();
  final _closed = Completer<void>();
  final _kex = SSHKexX25519();
  final _hostKey = SSHKeyPair.fromPem(File(
    'test/fixtures/ssh-ed25519/ssh_host_ed25519_key',
  ).readAsStringSync())
      .single;
  late final Uint8List _serverKexInit;
  late String _clientVersion;
  late Uint8List _clientKexInit;
  late BlockCipher _encrypt;
  late BlockCipher _decrypt;
  late Mac _sendMac;
  late Mac _receiveMac;
  var _gotVersion = false;
  var _sendingEncrypted = false;
  var _sendSequence = 0;
  var _receiveSequence = 0;
  var clientNewKeys = false;
  var serviceRequests = 0;
  var writesAfterClose = 0;
  final authMethods = <String>[];

  _SshPeer() {
    _serverKexInit = SSH_Message_KexInit(
      kexAlgorithms: [SSHKexType.x25519.name],
      serverHostKeyAlgorithms: ['ssh-ed25519'],
      encryptionClientToServer: ['aes128-ctr'],
      encryptionServerToClient: ['aes128-ctr'],
      macClientToServer: ['hmac-sha2-256'],
      macServerToClient: ['hmac-sha2-256'],
      compressionClientToServer: ['none'],
      compressionServerToClient: ['none'],
      firstKexPacketFollows: false,
    ).encode();
    _outgoing.stream.listen(_receive);
    _incoming.add(Uint8List.fromList(latin1.encode('$version\r\n')));
    _send(_serverKexInit);
  }

  @override
  Stream<Uint8List> get stream => _incoming.stream;

  @override
  StreamSink<List<int>> get sink => _outgoing.sink;

  @override
  Future<void> get done => _closed.future;

  @override
  Future<void> close() {
    if (!_closed.isCompleted) {
      _closed.complete();
      unawaited(_incoming.close());
      unawaited(_outgoing.close());
    }
    return done;
  }

  @override
  void destroy() => unawaited(close());

  void _receive(List<int> bytes) {
    if (_closed.isCompleted) {
      writesAfterClose++;
      return;
    }
    if (!_gotVersion) {
      _clientVersion = latin1.decode(bytes).trim();
      _gotVersion = true;
      return;
    }
    var packet = Uint8List.fromList(bytes);
    if (clientNewKeys) {
      final encryptedLength = packet.length - 32;
      final actualMac = Uint8List.sublistView(packet, encryptedLength);
      packet = _decrypt
          .processAll(Uint8List.sublistView(packet, 0, encryptedLength));
      expect(actualMac,
          orderedEquals(_mac(_receiveMac, _receiveSequence, packet)));
    }
    _receiveSequence++;
    final payload = Uint8List.sublistView(
      packet,
      5,
      4 + SSHPacket.readPacketLength(packet) - packet[4],
    );
    switch (payload.first) {
      case SSH_Message_KexInit.messageId:
        _clientKexInit = payload;
      case SSH_Message_KexECDH_Init.messageId:
        _replyToKeyExchange(SSH_Message_KexECDH_Init.decode(payload));
      case SSH_Message_NewKeys.messageId:
        clientNewKeys = true;
      case SSH_Message_Service_Request.messageId:
        serviceRequests++;
        final request = SSH_Message_Service_Request.decode(payload);
        expect(request.serviceName, 'ssh-userauth');
        _send(SSH_Message_Service_Accept(request.serviceName).encode());
      case SSH_Message_Userauth_Request.messageId:
        final request = SSH_Message_Userauth_Request.decode(payload);
        authMethods.add(request.methodName);
        if (request.methodName == 'none') {
          _send(
              SSH_Message_Userauth_Failure(methodsLeft: ['password']).encode());
        } else {
          expect(request.methodName, 'password');
          expect(request.password, 'test-password');
          _send(SSH_Message_Userauth_Success().encode());
        }
      default:
        fail('Unexpected client message: ${payload.first}');
    }
  }

  void _replyToKeyExchange(SSH_Message_KexECDH_Init request) {
    final hostKey = _hostKey.toPublicKey().encode();
    final secret = _kex.computeSecret(request.ecdhPublicKey);
    final hash = SSHKexUtils.computeExchangeHash(
      digest: SHA256Digest(),
      clientVersion: _clientVersion,
      serverVersion: version,
      clientKexInit: _clientKexInit,
      serverKexInit: _serverKexInit,
      hostKey: hostKey,
      clientPublicKey: request.ecdhPublicKey,
      serverPublicKey: _kex.publicKey,
      sharedSecret: secret,
    );
    // Write the RFC 5656 wire order explicitly: host key, Q_S, signature.
    final reply = SSHMessageWriter()
      ..writeUint8(31)
      ..writeString(hostKey)
      ..writeString(_kex.publicKey)
      ..writeString(_hostKey.sign(hash).encode());
    _send(reply.takeBytes());
    _send(SSH_Message_NewKeys().encode());

    Uint8List derive(SSHDeriveKeyType type, int size) => SSHKexUtils.deriveKey(
          digest: SHA256Digest(),
          sharedSecret: secret,
          exchangeHash: hash,
          keyType: type,
          sessionId: hash,
          keySize: size,
        );
    _encrypt = SSHCipherType.aes128ctr.createCipher(
      derive(SSHDeriveKeyType.serverKey, 16),
      derive(SSHDeriveKeyType.serverIV, 16),
      forEncryption: true,
    );
    _decrypt = SSHCipherType.aes128ctr.createCipher(
      derive(SSHDeriveKeyType.clientKey, 16),
      derive(SSHDeriveKeyType.clientIV, 16),
      forEncryption: false,
    );
    _sendMac = SSHMacType.hmacSha256
        .createMac(derive(SSHDeriveKeyType.serverMacKey, 32));
    _receiveMac = SSHMacType.hmacSha256
        .createMac(derive(SSHDeriveKeyType.clientMacKey, 32));
    _sendingEncrypted = true;
  }

  void _send(Uint8List payload) {
    final packet = SSHPacket.pack(payload, align: _sendingEncrypted ? 16 : 8);
    _incoming.add(_sendingEncrypted
        ? (BytesBuilder()
              ..add(_encrypt.processAll(packet))
              ..add(_mac(_sendMac, _sendSequence, packet)))
            .takeBytes()
        : packet);
    _sendSequence++;
  }

  Uint8List _mac(Mac mac, int sequence, Uint8List packet) {
    final data = BytesBuilder()
      ..add((ByteData(4)..setUint32(0, sequence)).buffer.asUint8List())
      ..add(packet);
    return mac.process(data.takeBytes());
  }
}
