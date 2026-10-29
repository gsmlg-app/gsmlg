import 'package:test/test.dart';
import 'package:app_ssh/src/sftp/sftp_errors.dart';

void main() {
  group('SftpError', () {
    test('stores message', () {
      final error = SftpError('test error');
      expect(error.message, 'test error');
    });

    test('toString includes message', () {
      final error = SftpError('file not found');
      expect(error.toString(), 'SftpError: file not found');
    });

    test('stores empty message', () {
      final error = SftpError('');
      expect(error.message, '');
      expect(error.toString(), 'SftpError: ');
    });
  });

  group('SftpAbortError', () {
    test('stores message', () {
      final error = SftpAbortError('operation aborted');
      expect(error.message, 'operation aborted');
    });

    test('implements SftpError', () {
      final error = SftpAbortError('test');
      expect(error, isA<SftpError>());
    });

    test('toString includes message', () {
      final error = SftpAbortError('connection closed');
      expect(error.toString(), 'SftpAbortError: connection closed');
    });
  });

  group('SftpStatusError', () {
    test('stores code and message', () {
      final error = SftpStatusError(2, 'no such file');
      expect(error.code, 2);
      expect(error.message, 'no such file');
    });

    test('implements SftpError', () {
      final error = SftpStatusError(1, 'test');
      expect(error, isA<SftpError>());
    });

    test('toString includes code and message', () {
      final error = SftpStatusError(3, 'permission denied');
      expect(error.toString(), 'SftpStatusError: permission denied(code 3)');
    });

    test('code 0 represents success', () {
      final error = SftpStatusError(0, 'ok');
      expect(error.code, 0);
      expect(error.toString(), 'SftpStatusError: ok(code 0)');
    });

    test('different status codes', () {
      final error1 = SftpStatusError(1, 'EOF');
      final error2 = SftpStatusError(2, 'No such file');
      final error3 = SftpStatusError(3, 'Permission denied');
      final error4 = SftpStatusError(4, 'Failure');

      expect(error1.code, 1);
      expect(error2.code, 2);
      expect(error3.code, 3);
      expect(error4.code, 4);
    });
  });

  group('SftpExtensionError', () {
    test('is abstract interface', () {
      // Verify subtypes implement it
      expect(SftpExtensionUnsupportedError('test'), isA<SftpExtensionError>());
      expect(
        SftpExtensionVersionMismatchError('test', '1.0'),
        isA<SftpExtensionError>(),
      );
    });
  });

  group('SftpExtensionUnsupportedError', () {
    test('stores extension name', () {
      final error = SftpExtensionUnsupportedError('statvfs@openssh.com');
      expect(error.extension, 'statvfs@openssh.com');
    });

    test('message includes extension name', () {
      final error = SftpExtensionUnsupportedError('posix-rename@openssh.com');
      expect(error.message,
          'Extension "posix-rename@openssh.com" is not supported');
    });

    test('implements SftpError', () {
      final error = SftpExtensionUnsupportedError('test');
      expect(error, isA<SftpError>());
    });

    test('implements SftpExtensionError', () {
      final error = SftpExtensionUnsupportedError('test');
      expect(error, isA<SftpExtensionError>());
    });

    test('toString includes message', () {
      final error = SftpExtensionUnsupportedError('hardlink@openssh.com');
      expect(
        error.toString(),
        'SftpExtensionUnsupportedError: Extension "hardlink@openssh.com" is not supported',
      );
    });
  });

  group('SftpExtensionVersionMismatchError', () {
    test('stores extension and version', () {
      final error =
          SftpExtensionVersionMismatchError('fsync@openssh.com', '2.0');
      expect(error.extension, 'fsync@openssh.com');
      expect(error.version, '2.0');
    });

    test('message includes extension and version', () {
      final error =
          SftpExtensionVersionMismatchError('statvfs@openssh.com', '1.5');
      expect(
        error.message,
        'Extension "statvfs@openssh.com" of version 1.5 is not supported',
      );
    });

    test('implements SftpError', () {
      final error = SftpExtensionVersionMismatchError('test', '1.0');
      expect(error, isA<SftpError>());
    });

    test('implements SftpExtensionError', () {
      final error = SftpExtensionVersionMismatchError('test', '1.0');
      expect(error, isA<SftpExtensionError>());
    });

    test('toString includes message', () {
      final error =
          SftpExtensionVersionMismatchError('limits@openssh.com', '3.0');
      expect(
        error.toString(),
        'SftpExtensionVersionMismatchError: Extension "limits@openssh.com" of version 3.0 is not supported',
      );
    });

    test('handles various version formats', () {
      final error1 = SftpExtensionVersionMismatchError('ext', '1');
      final error2 = SftpExtensionVersionMismatchError('ext', '1.0.0');
      final error3 = SftpExtensionVersionMismatchError('ext', 'v2.1-beta');

      expect(error1.version, '1');
      expect(error2.version, '1.0.0');
      expect(error3.version, 'v2.1-beta');
    });
  });

  group('error hierarchy', () {
    test('all error types implement SftpError', () {
      final errors = <SftpError>[
        SftpError('base'),
        SftpAbortError('abort'),
        SftpStatusError(1, 'status'),
        SftpExtensionUnsupportedError('ext'),
        SftpExtensionVersionMismatchError('ext', '1.0'),
      ];

      for (final error in errors) {
        expect(error, isA<SftpError>());
        expect(error.message, isNotEmpty);
        expect(error.toString(), isNotEmpty);
      }
    });

    test('extension errors form a hierarchy', () {
      final unsupported = SftpExtensionUnsupportedError('test');
      final versionMismatch = SftpExtensionVersionMismatchError('test', '1.0');

      expect(unsupported, isA<SftpExtensionError>());
      expect(versionMismatch, isA<SftpExtensionError>());
      expect(unsupported, isA<SftpError>());
      expect(versionMismatch, isA<SftpError>());
    });
  });
}
