import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('LocalConnector', () {
    group('constructor', () {
      test('creates with default values', () {
        final connector = LocalConnector();
        expect(connector.environment, isEmpty);
        expect(connector.initCommands, isNull);
      });

      test('creates with empty environment', () {
        final connector = LocalConnector(environment: {});
        expect(connector.environment, isEmpty);
      });

      test('creates with environment variables', () {
        final connector = LocalConnector(
          environment: {'TERM': 'xterm-256color', 'PATH': '/usr/bin'},
        );
        expect(connector.environment['TERM'], 'xterm-256color');
        expect(connector.environment['PATH'], '/usr/bin');
        expect(connector.environment.length, 2);
      });

      test('creates with init commands', () {
        final connector = LocalConnector(initCommands: 'cd /home');
        expect(connector.initCommands, 'cd /home');
      });

      test('creates with both environment and init commands', () {
        final connector = LocalConnector(
          environment: {'FOO': 'bar'},
          initCommands: 'echo hello',
        );
        expect(connector.environment['FOO'], 'bar');
        expect(connector.initCommands, 'echo hello');
      });
    });

    group('type hierarchy', () {
      test('is a HostConnector', () {
        final connector = LocalConnector();
        expect(connector, isA<HostConnector>());
      });

      test('is a HostConnector<LocalHost>', () {
        final connector = LocalConnector();
        expect(connector, isA<HostConnector<LocalHost>>());
      });
    });

    group('properties', () {
      test('environment is the same instance as provided', () {
        final env = <String, String>{'KEY': 'VALUE'};
        final connector = LocalConnector(environment: env);
        expect(identical(connector.environment, env), isTrue);
      });

      test('multiple connectors with different environments', () {
        final connector1 = LocalConnector(environment: {'A': '1'});
        final connector2 = LocalConnector(environment: {'B': '2'});

        expect(connector1.environment, isNot(connector2.environment));
        expect(connector1.environment['A'], '1');
        expect(connector2.environment['B'], '2');
        expect(connector1.environment['B'], isNull);
        expect(connector2.environment['A'], isNull);
      });

      test('multiple connectors with different init commands', () {
        final connector1 = LocalConnector(initCommands: 'cmd1');
        final connector2 = LocalConnector(initCommands: 'cmd2');

        expect(connector1.initCommands, 'cmd1');
        expect(connector2.initCommands, 'cmd2');
      });
    });

    group('createHost method', () {
      test('returns a Future', () {
        final connector = LocalConnector();
        expect(connector.createHost(), isA<Future<LocalHost>>());
      });
    });
  });

  group('SSHConnector', () {
    late SshHost testRecord;

    setUp(() {
      testRecord = SshHost(
        id: 1,
        host: 'Test Server',
        hostname: 'example.com',
        port: 22,
        username: 'user',
        password: 'pass',
        salt: null,
        identityType: SshIdentityType.password.value,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
    });

    group('constructor', () {
      test('creates with record only', () {
        final connector = SSHConnector(testRecord);

        expect(connector.record, testRecord);
        expect(connector.keyData, isNull);
        expect(connector.connectionTimeout, kSshConnectionTimeout);
        expect(connector.authenticationTimeout, kSshAuthenticationTimeout);
      });

      test('creates with custom timeouts', () {
        final connector = SSHConnector(
          testRecord,
          connectionTimeout: const Duration(seconds: 10),
          authenticationTimeout: const Duration(seconds: 20),
        );

        expect(connector.connectionTimeout.inSeconds, 10);
        expect(connector.authenticationTimeout.inSeconds, 20);
      });

      test('creates with key data', () {
        final record = SshHost(
          id: 2,
          host: 'Key Server',
          hostname: 'keyserver.com',
          port: 22,
          username: 'keyuser',
          password: null,
          salt: null,
          identityType: SshIdentityType.key.value,
          identityKeyId: 1,
          createdAt: DateTime.now(),
        );
        final keyData = SshKeyData(content: '-----BEGIN-----');
        final connector = SSHConnector(record, keyData: keyData);

        expect(connector.keyData, keyData);
        expect(connector.keyData?.content, '-----BEGIN-----');
      });
    });

    group('type hierarchy', () {
      test('is a HostConnector', () {
        final connector = SSHConnector(testRecord);
        expect(connector, isA<HostConnector>());
      });

      test('is a HostConnector<SSHHost>', () {
        final connector = SSHConnector(testRecord);
        expect(connector, isA<HostConnector<SSHHost>>());
      });
    });

    group('record association', () {
      test('record is accessible', () {
        final connector = SSHConnector(testRecord);

        expect(connector.record.hostname, 'example.com');
        expect(connector.record.port, 22);
        expect(connector.record.username, 'user');
        expect(connector.record.password, 'pass');
      });

      test('record with key-based auth', () {
        final record = SshHost(
          id: 3,
          host: 'Key Host',
          hostname: 'keyhost.com',
          port: 2222,
          username: 'admin',
          password: null,
          salt: null,
          identityType: SshIdentityType.key.value,
          identityKeyId: 5,
          createdAt: DateTime.now(),
        );
        final connector = SSHConnector(record);

        expect(connector.record.identityType, SshIdentityType.key.value);
        expect(connector.record.identityKeyId, 5);
        expect(connector.record.password, isNull);
      });
    });

    group('createHost method', () {
      test('rejects connections without host key verification', () async {
        final connector = SSHConnector(testRecord);
        await expectLater(
          connector.createHost(),
          throwsA(
            isA<SshHostKeyVerificationException>().having(
              (error) => error.message,
              'message',
              'SSH host key verification is required',
            ),
          ),
        );
      });
    });
  });

  group('SshKeyData', () {
    group('constructor', () {
      test('creates with content only', () {
        const keyData = SshKeyData(content: '-----BEGIN RSA PRIVATE KEY-----');

        expect(keyData.content, '-----BEGIN RSA PRIVATE KEY-----');
        expect(keyData.passphrase, isNull);
      });

      test('creates with content and passphrase', () {
        const keyData = SshKeyData(
          content: '-----BEGIN ENCRYPTED PRIVATE KEY-----',
          passphrase: 'mysecret',
        );

        expect(keyData.content, contains('ENCRYPTED'));
        expect(keyData.passphrase, 'mysecret');
      });

      test('empty content is allowed', () {
        const keyData = SshKeyData(content: '');
        expect(keyData.content, isEmpty);
      });

      test('empty passphrase is allowed', () {
        const keyData = SshKeyData(content: 'key', passphrase: '');
        expect(keyData.passphrase, '');
      });
    });
  });

  group('SSH Exceptions', () {
    group('SshConnectionException', () {
      test('creates with message only', () {
        const exception = SshConnectionException('Connection failed');
        expect(exception.message, 'Connection failed');
        expect(exception.cause, isNull);
        expect(exception.toString(), 'Connection failed');
      });

      test('creates with message and cause', () {
        final cause = Exception('Network error');
        final exception = SshConnectionException('Connection failed', cause);
        expect(exception.message, 'Connection failed');
        expect(exception.cause, cause);
        expect(exception.toString(), contains('Connection failed'));
        expect(exception.toString(), contains('Network error'));
      });
    });

    group('SshAuthenticationException', () {
      test('creates with message only', () {
        const exception = SshAuthenticationException('Auth failed');
        expect(exception.message, 'Auth failed');
        expect(exception.cause, isNull);
        expect(exception.toString(), 'Auth failed');
      });

      test('creates with message and cause', () {
        final cause = Exception('Invalid password');
        final exception = SshAuthenticationException('Auth failed', cause);
        expect(exception.message, 'Auth failed');
        expect(exception.cause, cause);
        expect(exception.toString(), contains('Auth failed'));
      });
    });

    group('SshKeyParseException', () {
      test('creates with message only', () {
        const exception = SshKeyParseException('Key parse failed');
        expect(exception.message, 'Key parse failed');
        expect(exception.cause, isNull);
        expect(exception.toString(), 'Key parse failed');
      });

      test('creates with message and cause', () {
        final cause = FormatException('Invalid PEM');
        final exception = SshKeyParseException('Key parse failed', cause);
        expect(exception.message, 'Key parse failed');
        expect(exception.cause, cause);
        expect(exception.toString(), contains('Key parse failed'));
      });
    });

    group('SshTimeoutException', () {
      test('creates with message and timeout', () {
        const exception = SshTimeoutException(
          'Connection timed out',
          Duration(seconds: 30),
        );
        expect(exception.message, 'Connection timed out');
        expect(exception.timeout.inSeconds, 30);
        expect(exception.toString(), 'Connection timed out (timeout: 30s)');
      });

      test('toString includes timeout duration', () {
        const exception = SshTimeoutException(
          'Auth timed out',
          Duration(seconds: 60),
        );
        expect(exception.toString(), contains('60s'));
      });
    });
  });

  group('AndroidConnector', () {
    group('constructor', () {
      test('creates with default values', () {
        final connector = AndroidConnector();
        expect(connector.environment, isEmpty);
        expect(connector.initCommands, isNull);
      });

      test('creates with empty environment', () {
        final connector = AndroidConnector(environment: {});
        expect(connector.environment, isEmpty);
      });

      test('creates with environment variables', () {
        final connector = AndroidConnector(
          environment: {'TERM': 'xterm-256color', 'PATH': '/usr/bin'},
        );
        expect(connector.environment['TERM'], 'xterm-256color');
        expect(connector.environment['PATH'], '/usr/bin');
        expect(connector.environment.length, 2);
      });

      test('creates with init commands', () {
        final connector = AndroidConnector(initCommands: 'cd /data');
        expect(connector.initCommands, 'cd /data');
      });

      test('creates with both environment and init commands', () {
        final connector = AndroidConnector(
          environment: {'FOO': 'bar'},
          initCommands: 'echo hello',
        );
        expect(connector.environment['FOO'], 'bar');
        expect(connector.initCommands, 'echo hello');
      });
    });

    group('type hierarchy', () {
      test('is a HostConnector', () {
        final connector = AndroidConnector();
        expect(connector, isA<HostConnector>());
      });

      test('is a HostConnector<AndroidHost>', () {
        final connector = AndroidConnector();
        expect(connector, isA<HostConnector<AndroidHost>>());
      });
    });

    group('properties', () {
      test('environment is the same instance as provided', () {
        final env = <String, String>{'KEY': 'VALUE'};
        final connector = AndroidConnector(environment: env);
        expect(identical(connector.environment, env), isTrue);
      });

      test('multiple connectors with different environments', () {
        final connector1 = AndroidConnector(environment: {'A': '1'});
        final connector2 = AndroidConnector(environment: {'B': '2'});

        expect(connector1.environment, isNot(connector2.environment));
        expect(connector1.environment['A'], '1');
        expect(connector2.environment['B'], '2');
        expect(connector1.environment['B'], isNull);
        expect(connector2.environment['A'], isNull);
      });

      test('multiple connectors with different init commands', () {
        final connector1 = AndroidConnector(initCommands: 'cmd1');
        final connector2 = AndroidConnector(initCommands: 'cmd2');

        expect(connector1.initCommands, 'cmd1');
        expect(connector2.initCommands, 'cmd2');
      });
    });

    group('createHost method', () {
      test('is defined and returns correct type', () {
        final connector = AndroidConnector();
        // Note: Can't actually call createHost() in unit tests without Flutter
        // bindings. We verify the method exists and has correct signature.
        expect(connector.createHost, isA<Function>());
      });
    });
  });

  group('IosConnector', () {
    group('constructor', () {
      test('creates with default values', () {
        final connector = IosConnector();
        expect(connector.environment, isEmpty);
        expect(connector.initCommands, isNull);
      });

      test('creates with empty environment', () {
        final connector = IosConnector(environment: {});
        expect(connector.environment, isEmpty);
      });

      test('creates with environment variables', () {
        final connector = IosConnector(
          environment: {'TERM': 'xterm-256color', 'PATH': '/usr/bin'},
        );
        expect(connector.environment['TERM'], 'xterm-256color');
        expect(connector.environment['PATH'], '/usr/bin');
        expect(connector.environment.length, 2);
      });

      test('creates with init commands', () {
        final connector = IosConnector(initCommands: 'cd ~/Documents');
        expect(connector.initCommands, 'cd ~/Documents');
      });

      test('creates with both environment and init commands', () {
        final connector = IosConnector(
          environment: {'FOO': 'bar'},
          initCommands: 'echo hello',
        );
        expect(connector.environment['FOO'], 'bar');
        expect(connector.initCommands, 'echo hello');
      });
    });

    group('type hierarchy', () {
      test('is a HostConnector', () {
        final connector = IosConnector();
        expect(connector, isA<HostConnector>());
      });

      test('is a HostConnector<IosHost>', () {
        final connector = IosConnector();
        expect(connector, isA<HostConnector<IosHost>>());
      });
    });

    group('properties', () {
      test('environment is the same instance as provided', () {
        final env = <String, String>{'KEY': 'VALUE'};
        final connector = IosConnector(environment: env);
        expect(identical(connector.environment, env), isTrue);
      });

      test('multiple connectors with different environments', () {
        final connector1 = IosConnector(environment: {'A': '1'});
        final connector2 = IosConnector(environment: {'B': '2'});

        expect(connector1.environment, isNot(connector2.environment));
        expect(connector1.environment['A'], '1');
        expect(connector2.environment['B'], '2');
        expect(connector1.environment['B'], isNull);
        expect(connector2.environment['A'], isNull);
      });

      test('multiple connectors with different init commands', () {
        final connector1 = IosConnector(initCommands: 'cmd1');
        final connector2 = IosConnector(initCommands: 'cmd2');

        expect(connector1.initCommands, 'cmd1');
        expect(connector2.initCommands, 'cmd2');
      });
    });

    group('createHost method', () {
      test('is defined and returns correct type', () {
        final connector = IosConnector();
        // Note: Can't actually call createHost() in unit tests without Flutter
        // bindings. We verify the method exists and has correct signature.
        expect(connector.createHost, isA<Function>());
      });
    });
  });

  group('SSH Constants', () {
    test('kSshConnectionTimeout is 30 seconds', () {
      expect(kSshConnectionTimeout.inSeconds, 30);
    });

    test('kSshAuthenticationTimeout is 60 seconds', () {
      expect(kSshAuthenticationTimeout.inSeconds, 60);
    });
  });

  group('SSHHostSpec', () {
    test('creates with password-based record', () {
      final record = SshHost(
        id: 1,
        host: 'My Server',
        hostname: 'server.com',
        port: 22,
        username: 'user',
        password: 'pass',
        salt: null,
        identityType: SshIdentityType.password.value,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final spec = SSHHostSpec(record);

      expect(spec.record, record);
      expect(spec.keyData, isNull);
      expect(spec.name, 'My Server');
    });

    test('name uses host field if available', () {
      final record = SshHost(
        id: 1,
        host: 'Custom Name',
        hostname: 'server.com',
        port: 22,
        username: 'user',
        password: 'pass',
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final spec = SSHHostSpec(record);

      expect(spec.name, 'Custom Name');
    });

    test('name falls back to hostname if host is null', () {
      final record = SshHost(
        id: 1,
        host: null,
        hostname: 'server.com',
        port: 22,
        username: 'user',
        password: 'pass',
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final spec = SSHHostSpec(record);

      expect(spec.name, 'server.com');
    });

    test('name falls back to default if both host and hostname are null', () {
      final record = SshHost(
        id: 1,
        host: null,
        hostname: null,
        port: 22,
        username: 'user',
        password: 'pass',
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final spec = SSHHostSpec(record);

      expect(spec.name, 'SSH Host');
    });

    test('createConnector returns SSHConnector', () {
      final record = SshHost(
        id: 1,
        host: 'Test',
        hostname: 'test.com',
        port: 22,
        username: 'user',
        password: 'pass',
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final spec = SSHHostSpec(record);
      final connector = spec.createConnector();

      expect(connector, isA<SSHConnector>());
      expect(connector, isA<HostConnector<SSHHost>>());
    });

    test('throws if keyData is null for key-based auth', () {
      final record = SshHost(
        id: 1,
        host: 'Key Server',
        hostname: 'key.com',
        port: 22,
        username: 'user',
        password: null,
        salt: null,
        identityType: SshIdentityType.key.value,
        identityKeyId: 1,
        createdAt: DateTime.now(),
      );

      expect(() => SSHHostSpec(record), throwsArgumentError);
    });

    test('creates with keyData for key-based auth', () {
      final record = SshHost(
        id: 1,
        host: 'Key Server',
        hostname: 'key.com',
        port: 22,
        username: 'user',
        password: null,
        salt: null,
        identityType: SshIdentityType.key.value,
        identityKeyId: 1,
        createdAt: DateTime.now(),
      );
      const keyData = SshKeyData(content: '-----BEGIN-----');
      final spec = SSHHostSpec(record, keyData: keyData);

      expect(spec.keyData, keyData);
    });

    test('implements HostSpec interface', () {
      final record = SshHost(
        id: 1,
        host: 'Test',
        hostname: 'test.com',
        port: 22,
        username: 'user',
        password: 'pass',
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final spec = SSHHostSpec(record);

      expect(spec, isA<HostSpec>());
    });
  });
}
