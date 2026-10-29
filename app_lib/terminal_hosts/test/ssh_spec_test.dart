import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('SSHHostSpec', () {
    late SshHost testHostPassword;
    late SshHost testHostKey;

    setUp(() {
      testHostPassword = SshHost(
        id: 1,
        host: 'My Server',
        hostname: 'example.com',
        port: 22,
        username: 'user',
        password: 'pass123',
        identityType: SshIdentityType.password.value,
      );

      testHostKey = SshHost(
        id: 2,
        host: 'Key Server',
        hostname: 'keyserver.example.com',
        port: 2222,
        username: 'keyuser',
        identityType: SshIdentityType.key.value,
        identityKeyId: 10,
      );
    });

    test('name returns host when available', () {
      final spec = SSHHostSpec(testHostPassword);
      expect(spec.name, equals('My Server'));
    });

    test('name falls back to hostname when host is null', () {
      final hostNoName = SshHost(
        id: 3,
        hostname: 'fallback.example.com',
        port: 22,
        username: 'test',
      );
      final spec = SSHHostSpec(hostNoName);
      expect(spec.name, equals('fallback.example.com'));
    });

    test('name returns "SSH Host" when host and hostname are null', () {
      final hostMinimal = SshHost(id: 4, port: 22, username: 'test');
      final spec = SSHHostSpec(hostMinimal);
      expect(spec.name, equals('SSH Host'));
    });

    test('createConnector returns SSHConnector', () {
      final spec = SSHHostSpec(testHostPassword);
      final connector = spec.createConnector();

      expect(connector, isA<SSHConnector>());
    });

    test('passes keyData to connector when provided', () {
      const keyData = SshKeyData(content: 'test-key-content');
      final spec = SSHHostSpec(testHostKey, keyData: keyData);

      expect(spec.keyData, equals(keyData));
      expect(spec.record.identityType, equals(SshIdentityType.key.value));
    });

    test('connector receives keyData from spec', () {
      const keyData = SshKeyData(content: 'test-key-content');
      final spec = SSHHostSpec(testHostKey, keyData: keyData);
      final connector = spec.createConnector() as SSHConnector;

      expect(connector.keyData, isNotNull);
      expect(connector.keyData!.content, equals('test-key-content'));
    });

    test('connector has null keyData when not provided', () {
      final spec = SSHHostSpec(testHostPassword);
      final connector = spec.createConnector() as SSHConnector;

      expect(connector.keyData, isNull);
    });

    test('spec holds reference to original record', () {
      final spec = SSHHostSpec(testHostPassword);

      expect(spec.record.id, equals(1));
      expect(spec.record.hostname, equals('example.com'));
      expect(spec.record.port, equals(22));
      expect(spec.record.username, equals('user'));
    });

    test('throws ArgumentError when keyData is null for key identity type', () {
      expect(
        () => SSHHostSpec(testHostKey),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('keyData is required'),
          ),
        ),
      );
    });

    test('allows null keyData for password identity type', () {
      // Should not throw
      final spec = SSHHostSpec(testHostPassword);
      expect(spec.keyData, isNull);
    });

    test(
      'allows null keyData when identityType is not set (defaults to password)',
      () {
        final hostNoIdentity = SshHost(
          id: 5,
          hostname: 'noidentity.example.com',
          port: 22,
          username: 'test',
        );
        // Should not throw since default identity type is not key
        final spec = SSHHostSpec(hostNoIdentity);
        expect(spec.keyData, isNull);
      },
    );
  });

  group('SSHConnector', () {
    test('stores record reference', () {
      final host = SshHost(
        id: 1,
        hostname: 'test.example.com',
        port: 22,
        username: 'testuser',
        password: 'testpass',
        identityType: SshIdentityType.password.value,
      );

      final connector = SSHConnector(host);

      expect(connector.record, equals(host));
      expect(connector.keyData, isNull);
    });

    test('stores keyData when provided', () {
      final host = SshHost(
        id: 2,
        hostname: 'key.example.com',
        port: 22,
        username: 'keyuser',
        identityType: SshIdentityType.key.value,
        identityKeyId: 5,
      );

      const keyData = SshKeyData(
        content:
            '-----BEGIN RSA PRIVATE KEY-----\ntest\n-----END RSA PRIVATE KEY-----',
        passphrase: 'keypass',
      );

      final connector = SSHConnector(host, keyData: keyData);

      expect(connector.record, equals(host));
      expect(connector.keyData, equals(keyData));
      expect(connector.keyData!.content, contains('BEGIN RSA'));
      expect(connector.keyData!.passphrase, equals('keypass'));
    });

    test(
      'createHost throws SshConnectionException when hostname is null',
      () async {
        final host = SshHost(
          id: 1,
          port: 22,
          username: 'testuser',
          identityType: SshIdentityType.password.value,
        );

        final connector = SSHConnector(host);

        expect(
          () => connector.createHost(),
          throwsA(
            isA<SshConnectionException>().having(
              (e) => e.message,
              'message',
              contains('Hostname is required'),
            ),
          ),
        );
      },
    );

    test(
      'createHost throws SshConnectionException when hostname is empty',
      () async {
        final host = SshHost(
          id: 1,
          hostname: '',
          port: 22,
          username: 'testuser',
          identityType: SshIdentityType.password.value,
        );

        final connector = SSHConnector(host);

        expect(
          () => connector.createHost(),
          throwsA(
            isA<SshConnectionException>().having(
              (e) => e.message,
              'message',
              contains('Hostname is required'),
            ),
          ),
        );
      },
    );

    test(
      'createHost throws SshConnectionException when port is invalid',
      () async {
        final host = SshHost(
          id: 1,
          hostname: 'example.com',
          port: 0,
          username: 'testuser',
          identityType: SshIdentityType.password.value,
        );

        final connector = SSHConnector(host);

        expect(
          () => connector.createHost(),
          throwsA(
            isA<SshConnectionException>().having(
              (e) => e.message,
              'message',
              contains('Invalid port number'),
            ),
          ),
        );
      },
    );

    test(
      'createHost throws SshAuthenticationException when username is null',
      () async {
        final host = SshHost(
          id: 1,
          hostname: 'example.com',
          port: 22,
          identityType: SshIdentityType.password.value,
        );

        final connector = SSHConnector(host);

        expect(
          () => connector.createHost(),
          throwsA(
            isA<SshAuthenticationException>().having(
              (e) => e.message,
              'message',
              contains('Username is required'),
            ),
          ),
        );
      },
    );

    // Note: Tests for key parsing and network connection errors require mocking
    // SSHSocket.connect which is not feasible in unit tests. These validations
    // are verified by integration tests.
  });

  group('SSH Exceptions', () {
    test('SshConnectionException toString includes message', () {
      const exception = SshConnectionException('Connection failed');
      expect(exception.toString(), equals('Connection failed'));
    });

    test('SshConnectionException toString includes cause', () {
      final exception = SshConnectionException(
        'Connection failed',
        Exception('Network error'),
      );
      expect(exception.toString(), contains('Connection failed'));
      expect(exception.toString(), contains('Network error'));
    });

    test('SshAuthenticationException toString includes message', () {
      const exception = SshAuthenticationException('Auth failed');
      expect(exception.toString(), equals('Auth failed'));
    });

    test('SshKeyParseException toString includes message', () {
      const exception = SshKeyParseException('Invalid key');
      expect(exception.toString(), equals('Invalid key'));
    });
  });
}
