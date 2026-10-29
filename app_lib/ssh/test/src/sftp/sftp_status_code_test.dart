import 'package:test/test.dart';
import 'package:app_ssh/src/sftp/sftp_status_code.dart';

void main() {
  group('SftpStatusCode', () {
    test('ok is 0', () {
      expect(SftpStatusCode.ok, 0);
    });

    test('eof is 1', () {
      expect(SftpStatusCode.eof, 1);
    });

    test('noSuchFile is 2', () {
      expect(SftpStatusCode.noSuchFile, 2);
    });

    test('permissionDenied is 3', () {
      expect(SftpStatusCode.permissionDenied, 3);
    });

    test('failure is 4', () {
      expect(SftpStatusCode.failure, 4);
    });

    test('badMessage is 5', () {
      expect(SftpStatusCode.badMessage, 5);
    });

    test('noConnection is 6', () {
      expect(SftpStatusCode.noConnection, 6);
    });

    test('connectionLost is 7', () {
      expect(SftpStatusCode.connectionLost, 7);
    });

    test('opUnsupported is 8', () {
      expect(SftpStatusCode.opUnsupported, 8);
    });

    group('status code ranges', () {
      test('all codes are unique', () {
        final codes = [
          SftpStatusCode.ok,
          SftpStatusCode.eof,
          SftpStatusCode.noSuchFile,
          SftpStatusCode.permissionDenied,
          SftpStatusCode.failure,
          SftpStatusCode.badMessage,
          SftpStatusCode.noConnection,
          SftpStatusCode.connectionLost,
          SftpStatusCode.opUnsupported,
        ];
        expect(codes.toSet().length, codes.length);
      });

      test('all codes are non-negative', () {
        final codes = [
          SftpStatusCode.ok,
          SftpStatusCode.eof,
          SftpStatusCode.noSuchFile,
          SftpStatusCode.permissionDenied,
          SftpStatusCode.failure,
          SftpStatusCode.badMessage,
          SftpStatusCode.noConnection,
          SftpStatusCode.connectionLost,
          SftpStatusCode.opUnsupported,
        ];
        for (final code in codes) {
          expect(code, greaterThanOrEqualTo(0));
        }
      });

      test('success code is 0', () {
        expect(SftpStatusCode.ok, 0);
      });

      test('error codes are non-zero', () {
        expect(SftpStatusCode.eof, isNot(0));
        expect(SftpStatusCode.noSuchFile, isNot(0));
        expect(SftpStatusCode.permissionDenied, isNot(0));
        expect(SftpStatusCode.failure, isNot(0));
        expect(SftpStatusCode.badMessage, isNot(0));
        expect(SftpStatusCode.noConnection, isNot(0));
        expect(SftpStatusCode.connectionLost, isNot(0));
        expect(SftpStatusCode.opUnsupported, isNot(0));
      });
    });

    group('status code categories', () {
      test('client-only pseudo-errors', () {
        // These can only be generated locally by the client
        final clientOnly = [
          SftpStatusCode.noConnection,
          SftpStatusCode.connectionLost,
        ];
        // They should be in the upper range
        for (final code in clientOnly) {
          expect(code, greaterThanOrEqualTo(6));
        }
      });

      test('server-returnable errors', () {
        // These can be returned by the server
        final serverErrors = [
          SftpStatusCode.ok,
          SftpStatusCode.eof,
          SftpStatusCode.noSuchFile,
          SftpStatusCode.permissionDenied,
          SftpStatusCode.failure,
          SftpStatusCode.badMessage,
          SftpStatusCode.opUnsupported,
        ];
        // They should all be defined
        for (final code in serverErrors) {
          expect(code, isNotNull);
        }
      });
    });

    group('real-world scenarios', () {
      test('checking for success', () {
        final status = SftpStatusCode.ok;
        expect(status == SftpStatusCode.ok, isTrue);
      });

      test('checking for end of file', () {
        final status = SftpStatusCode.eof;
        expect(status == SftpStatusCode.eof, isTrue);
      });

      test('checking for file not found', () {
        final status = SftpStatusCode.noSuchFile;
        expect(status == SftpStatusCode.noSuchFile, isTrue);
      });

      test('checking for permission error', () {
        final status = SftpStatusCode.permissionDenied;
        expect(status == SftpStatusCode.permissionDenied, isTrue);
      });

      test('error code can be used in switch', () {
        final status = SftpStatusCode.failure;
        String message;
        switch (status) {
          case SftpStatusCode.ok:
            message = 'success';
          case SftpStatusCode.eof:
            message = 'end of file';
          case SftpStatusCode.noSuchFile:
            message = 'no such file';
          case SftpStatusCode.permissionDenied:
            message = 'permission denied';
          case SftpStatusCode.failure:
            message = 'general failure';
          default:
            message = 'unknown';
        }
        expect(message, 'general failure');
      });
    });
  });
}
