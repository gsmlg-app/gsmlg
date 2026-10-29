import 'package:test/test.dart';
import 'package:app_ssh/src/ssh_errors.dart';

void main() {
  group('SSHError', () {
    test('is abstract interface', () {
      // SSHError is abstract, verify subtypes implement it
      expect(SSHInternalError('test'), isA<SSHError>());
      expect(SSHHandshakeError('test'), isA<SSHError>());
      expect(SSHAuthFailError('test'), isA<SSHError>());
    });
  });

  group('SSHInternalError', () {
    test('stores error object', () {
      final error = SSHInternalError('something went wrong');
      expect(error.error, 'something went wrong');
    });

    test('stores exception as error', () {
      final exception = Exception('test');
      final error = SSHInternalError(exception);
      expect(error.error, exception);
    });

    test('implements SSHError', () {
      final error = SSHInternalError('test');
      expect(error, isA<SSHError>());
    });

    test('toString includes error', () {
      final error = SSHInternalError('internal bug');
      expect(error.toString(), contains('SSHInternalError'));
      expect(error.toString(), contains('internal bug'));
    });
  });

  group('SSHHandshakeError', () {
    test('stores message', () {
      final error = SSHHandshakeError('handshake failed');
      expect(error.message, 'handshake failed');
    });

    test('implements SSHError', () {
      final error = SSHHandshakeError('test');
      expect(error, isA<SSHError>());
    });

    test('toString includes message', () {
      final error = SSHHandshakeError('version mismatch');
      expect(error.toString(), contains('SSHHandshakeError'));
      expect(error.toString(), contains('version mismatch'));
    });
  });

  group('SSHAuthError', () {
    test('SSHAuthFailError implements SSHAuthError', () {
      final error = SSHAuthFailError('auth failed');
      expect(error, isA<SSHAuthError>());
    });

    test('SSHAuthAbortError implements SSHAuthError', () {
      final error = SSHAuthAbortError('auth aborted');
      expect(error, isA<SSHAuthError>());
    });
  });

  group('SSHAuthFailError', () {
    test('stores message', () {
      final error = SSHAuthFailError('all methods failed');
      expect(error.message, 'all methods failed');
    });

    test('implements SSHError and SSHAuthError', () {
      final error = SSHAuthFailError('test');
      expect(error, isA<SSHError>());
      expect(error, isA<SSHAuthError>());
    });

    test('toString includes message', () {
      final error = SSHAuthFailError('invalid password');
      expect(error.toString(), contains('SSHAuthFailError'));
      expect(error.toString(), contains('invalid password'));
    });
  });

  group('SSHAuthAbortError', () {
    test('stores message', () {
      final error = SSHAuthAbortError('connection lost');
      expect(error.message, 'connection lost');
    });

    test('implements SSHError and SSHAuthError', () {
      final error = SSHAuthAbortError('test');
      expect(error, isA<SSHError>());
      expect(error, isA<SSHAuthError>());
    });

    test('toString includes message', () {
      final error = SSHAuthAbortError('timeout');
      expect(error.toString(), contains('SSHAuthAbortError'));
      expect(error.toString(), contains('timeout'));
    });
  });

  group('SSHPacketError', () {
    test('stores message', () {
      final error = SSHPacketError('malformed packet');
      expect(error.message, 'malformed packet');
    });

    test('implements SSHError', () {
      final error = SSHPacketError('test');
      expect(error, isA<SSHError>());
    });

    test('toString includes message', () {
      final error = SSHPacketError('invalid length');
      expect(error.toString(), contains('SSHPacketError'));
      expect(error.toString(), contains('invalid length'));
    });
  });

  group('SSHStateError', () {
    test('stores message', () {
      final error = SSHStateError('unexpected packet');
      expect(error.message, 'unexpected packet');
    });

    test('implements SSHError', () {
      final error = SSHStateError('test');
      expect(error, isA<SSHError>());
    });

    test('toString includes message', () {
      final error = SSHStateError('invalid state');
      expect(error.toString(), contains('SSHStateError'));
      expect(error.toString(), contains('invalid state'));
    });
  });

  group('SSHKeyDecodeError', () {
    test('stores message', () {
      final error = SSHKeyDecodeError('invalid key format');
      expect(error.message, 'invalid key format');
    });

    test('stores optional error', () {
      final cause = Exception('parsing failed');
      final error = SSHKeyDecodeError('decode failed', cause);
      expect(error.message, 'decode failed');
      expect(error.error, cause);
    });

    test('error is null by default', () {
      final error = SSHKeyDecodeError('test');
      expect(error.error, isNull);
    });

    test('implements SSHError', () {
      final error = SSHKeyDecodeError('test');
      expect(error, isA<SSHError>());
    });

    test('toString includes message and error', () {
      final cause = Exception('test');
      final error = SSHKeyDecodeError('decode failed', cause);
      final str = error.toString();
      expect(str, contains('SSHKeyDecodeError'));
      expect(str, contains('decode failed'));
      expect(str, contains('test'));
    });
  });

  group('SSHKeyDecryptError', () {
    test('extends SSHKeyDecodeError', () {
      final error = SSHKeyDecryptError('decrypt failed');
      expect(error, isA<SSHKeyDecodeError>());
    });

    test('stores message', () {
      final error = SSHKeyDecryptError('wrong passphrase');
      expect(error.message, 'wrong passphrase');
    });

    test('stores optional error', () {
      final cause = Exception('decryption failed');
      final error = SSHKeyDecryptError('decrypt failed', cause);
      expect(error.error, cause);
    });

    test('implements SSHError', () {
      final error = SSHKeyDecryptError('test');
      expect(error, isA<SSHError>());
    });
  });

  group('SSHChannelOpenError', () {
    test('stores code and description', () {
      final error = SSHChannelOpenError(1, 'administratively prohibited');
      expect(error.code, 1);
      expect(error.description, 'administratively prohibited');
    });

    test('implements SSHError', () {
      final error = SSHChannelOpenError(1, 'test');
      expect(error, isA<SSHError>());
    });

    test('toString includes code and description', () {
      final error = SSHChannelOpenError(2, 'connect failed');
      final str = error.toString();
      expect(str, contains('SSHChannelOpenError'));
      expect(str, contains('2'));
      expect(str, contains('connect failed'));
    });
  });

  group('SSHChannelRequestError', () {
    test('stores message', () {
      final error = SSHChannelRequestError('request denied');
      expect(error.message, 'request denied');
    });

    test('implements SSHError', () {
      final error = SSHChannelRequestError('test');
      expect(error, isA<SSHError>());
    });

    test('toString includes message', () {
      final error = SSHChannelRequestError('pty request failed');
      expect(error.toString(), contains('SSHChannelRequestError'));
      expect(error.toString(), contains('pty request failed'));
    });
  });

  group('SSHHostkeyError', () {
    test('stores message', () {
      final error = SSHHostkeyError('key verification failed');
      expect(error.message, 'key verification failed');
    });

    test('implements SSHError', () {
      final error = SSHHostkeyError('test');
      expect(error, isA<SSHError>());
    });

    test('toString includes message', () {
      final error = SSHHostkeyError('unknown host');
      expect(error.toString(), contains('SSHHostkeyError'));
      expect(error.toString(), contains('unknown host'));
    });
  });

  group('SSHSocketError', () {
    test('stores error object', () {
      final error = SSHSocketError('connection refused');
      expect(error.error, 'connection refused');
    });

    test('stores exception as error', () {
      final exception = Exception('socket error');
      final error = SSHSocketError(exception);
      expect(error.error, exception);
    });

    test('implements SSHError', () {
      final error = SSHSocketError('test');
      expect(error, isA<SSHError>());
    });

    test('toString includes error', () {
      final error = SSHSocketError('ECONNREFUSED');
      expect(error.toString(), 'SSHSocketError(ECONNREFUSED)');
    });
  });

  group('error hierarchy', () {
    test('all error types implement SSHError', () {
      final errors = <SSHError>[
        SSHInternalError('test'),
        SSHHandshakeError('test'),
        SSHAuthFailError('test'),
        SSHAuthAbortError('test'),
        SSHPacketError('test'),
        SSHStateError('test'),
        SSHKeyDecodeError('test'),
        SSHKeyDecryptError('test'),
        SSHChannelOpenError(1, 'test'),
        SSHChannelRequestError('test'),
        SSHHostkeyError('test'),
        SSHSocketError('test'),
      ];

      for (final error in errors) {
        expect(error, isA<SSHError>());
      }
    });

    test('auth errors form a hierarchy', () {
      final authFail = SSHAuthFailError('test');
      final authAbort = SSHAuthAbortError('test');

      expect(authFail, isA<SSHAuthError>());
      expect(authAbort, isA<SSHAuthError>());
      expect(authFail, isA<SSHError>());
      expect(authAbort, isA<SSHError>());
    });

    test('key errors form a hierarchy', () {
      final decode = SSHKeyDecodeError('test');
      final decrypt = SSHKeyDecryptError('test');

      expect(decode, isA<SSHError>());
      expect(decrypt, isA<SSHKeyDecodeError>());
      expect(decrypt, isA<SSHError>());
    });
  });
}
