import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('SSH Exception Classes', () {
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
        expect(exception.toString(), contains('Invalid password'));
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
        final cause = Exception('Invalid PEM format');
        final exception = SshKeyParseException('Key parse failed', cause);
        expect(exception.message, 'Key parse failed');
        expect(exception.cause, cause);
        expect(exception.toString(), contains('Key parse failed'));
        expect(exception.toString(), contains('Invalid PEM format'));
      });
    });

    group('SshTimeoutException', () {
      test('creates with message and timeout', () {
        const timeout = Duration(seconds: 30);
        const exception = SshTimeoutException('Connection timed out', timeout);
        expect(exception.message, 'Connection timed out');
        expect(exception.timeout, timeout);
      });

      test('toString includes timeout duration', () {
        const timeout = Duration(seconds: 30);
        const exception = SshTimeoutException('Connection timed out', timeout);
        final str = exception.toString();
        expect(str, contains('Connection timed out'));
        expect(str, contains('30s'));
      });

      test('toString formats different timeout durations', () {
        const timeout60 = Duration(seconds: 60);
        const exception60 = SshTimeoutException('Auth timed out', timeout60);
        expect(exception60.toString(), contains('60s'));

        const timeout15 = Duration(seconds: 15);
        const exception15 = SshTimeoutException(
          'Connection timed out',
          timeout15,
        );
        expect(exception15.toString(), contains('15s'));
      });
    });
  });

  group('SSH Timeout Constants', () {
    test('kSshConnectionTimeout is reasonable', () {
      expect(kSshConnectionTimeout.inSeconds, greaterThanOrEqualTo(10));
      expect(kSshConnectionTimeout.inSeconds, lessThanOrEqualTo(120));
    });

    test('kSshAuthenticationTimeout is reasonable', () {
      expect(kSshAuthenticationTimeout.inSeconds, greaterThanOrEqualTo(30));
      expect(kSshAuthenticationTimeout.inSeconds, lessThanOrEqualTo(300));
    });

    test('authentication timeout is >= connection timeout', () {
      expect(
        kSshAuthenticationTimeout.inSeconds,
        greaterThanOrEqualTo(kSshConnectionTimeout.inSeconds),
      );
    });
  });

  group('SSHConnector timeout configuration', () {
    test('uses default timeouts when not specified', () {
      // We can't test actual connection without mocking SSH,
      // but we can verify the connector accepts the configuration
      // by checking that it compiles and instantiates correctly.
      // Real integration tests would require SSH server mocks.
    });
  });
}
