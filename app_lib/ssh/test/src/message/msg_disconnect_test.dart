import 'package:test/test.dart';
import 'package:app_ssh/src/message/msg_disconnect.dart';

void main() {
  group('SSHDisconnectReason', () {
    test('has all expected values', () {
      expect(SSHDisconnectReason.values.length, 15);
    });

    test('values are distinct', () {
      final values = SSHDisconnectReason.values.toSet();
      expect(values.length, SSHDisconnectReason.values.length);
    });
  });

  group('SSHDisconnectReasonX', () {
    group('code', () {
      test('hostNotAllowedToConnect is 1', () {
        expect(SSHDisconnectReason.hostNotAllowedToConnect.code, 1);
      });

      test('protocolError is 2', () {
        expect(SSHDisconnectReason.protocolError.code, 2);
      });

      test('keyExchangeFailed is 3', () {
        expect(SSHDisconnectReason.keyExchangeFailed.code, 3);
      });

      test('reserved is 4', () {
        expect(SSHDisconnectReason.reserved.code, 4);
      });

      test('macError is 5', () {
        expect(SSHDisconnectReason.macError.code, 5);
      });

      test('compressionError is 6', () {
        expect(SSHDisconnectReason.compressionError.code, 6);
      });

      test('serviceNotAvailable is 7', () {
        expect(SSHDisconnectReason.serviceNotAvailable.code, 7);
      });

      test('protocolVersionNotSupported is 8', () {
        expect(SSHDisconnectReason.protocolVersionNotSupported.code, 8);
      });

      test('hostKeyNotVerifiable is 9', () {
        expect(SSHDisconnectReason.hostKeyNotVerifiable.code, 9);
      });

      test('connectionLost is 10', () {
        expect(SSHDisconnectReason.connectionLost.code, 10);
      });

      test('byApplication is 11', () {
        expect(SSHDisconnectReason.byApplication.code, 11);
      });

      test('tooManyConnections is 12', () {
        expect(SSHDisconnectReason.tooManyConnections.code, 12);
      });

      test('authCancelledByUser is 13', () {
        expect(SSHDisconnectReason.authCancelledByUser.code, 13);
      });

      test('noMoreAuthMethodsAvailable is 14', () {
        expect(SSHDisconnectReason.noMoreAuthMethodsAvailable.code, 14);
      });

      test('illegalUserName is 15', () {
        expect(SSHDisconnectReason.illegalUserName.code, 15);
      });

      test('all codes are unique', () {
        final codes = SSHDisconnectReason.values.map((r) => r.code).toSet();
        expect(codes.length, SSHDisconnectReason.values.length);
      });

      test('all codes are positive', () {
        for (final reason in SSHDisconnectReason.values) {
          expect(reason.code, greaterThan(0));
        }
      });

      test('codes are sequential from 1 to 15', () {
        final codes = SSHDisconnectReason.values.map((r) => r.code).toList()
          ..sort();
        expect(codes, List.generate(15, (i) => i + 1));
      });
    });

    group('description', () {
      test('hostNotAllowedToConnect has description', () {
        expect(
          SSHDisconnectReason.hostNotAllowedToConnect.description,
          'Host not allowed to connect',
        );
      });

      test('protocolError has description', () {
        expect(
          SSHDisconnectReason.protocolError.description,
          'Protocol error',
        );
      });

      test('keyExchangeFailed has description', () {
        expect(
          SSHDisconnectReason.keyExchangeFailed.description,
          'Key exchange failed',
        );
      });

      test('reserved has description', () {
        expect(SSHDisconnectReason.reserved.description, 'Reserved');
      });

      test('macError has description', () {
        expect(SSHDisconnectReason.macError.description, 'MAC error');
      });

      test('compressionError has description', () {
        expect(
          SSHDisconnectReason.compressionError.description,
          'Compression error',
        );
      });

      test('serviceNotAvailable has description', () {
        expect(
          SSHDisconnectReason.serviceNotAvailable.description,
          'Service not available',
        );
      });

      test('protocolVersionNotSupported has description', () {
        expect(
          SSHDisconnectReason.protocolVersionNotSupported.description,
          'Protocol version not supported',
        );
      });

      test('hostKeyNotVerifiable has description', () {
        expect(
          SSHDisconnectReason.hostKeyNotVerifiable.description,
          'Host key not verifiable',
        );
      });

      test('connectionLost has description', () {
        expect(
          SSHDisconnectReason.connectionLost.description,
          'Connection lost',
        );
      });

      test('byApplication has description', () {
        expect(
          SSHDisconnectReason.byApplication.description,
          'By application',
        );
      });

      test('tooManyConnections has description', () {
        expect(
          SSHDisconnectReason.tooManyConnections.description,
          'Too many connections',
        );
      });

      test('authCancelledByUser has description', () {
        expect(
          SSHDisconnectReason.authCancelledByUser.description,
          'Auth cancelled by user',
        );
      });

      test('noMoreAuthMethodsAvailable has description', () {
        expect(
          SSHDisconnectReason.noMoreAuthMethodsAvailable.description,
          'No more auth methods available',
        );
      });

      test('illegalUserName has description', () {
        expect(
          SSHDisconnectReason.illegalUserName.description,
          'Illegal user name',
        );
      });

      test('all descriptions are non-empty', () {
        for (final reason in SSHDisconnectReason.values) {
          expect(reason.description, isNotEmpty);
        }
      });
    });
  });

  group('SSH_Message_Disconnect', () {
    test('has correct messageId', () {
      expect(SSH_Message_Disconnect.messageId, 1);
    });

    group('constructor', () {
      test('creates message with required fields', () {
        final msg = SSH_Message_Disconnect(
          reasonCode: 11,
          description: 'User requested',
        );
        expect(msg.reasonCode, 11);
        expect(msg.description, 'User requested');
        expect(msg.languageTag, '');
      });

      test('creates message with language tag', () {
        final msg = SSH_Message_Disconnect(
          reasonCode: 11,
          description: 'Test',
          languageTag: 'en-US',
        );
        expect(msg.languageTag, 'en-US');
      });
    });

    group('fromReason constructor', () {
      test('creates from SSHDisconnectReason', () {
        final msg = SSH_Message_Disconnect.fromReason(
          SSHDisconnectReason.byApplication,
        );
        expect(msg.reasonCode, 11);
        expect(msg.description, 'By application');
        expect(msg.languageTag, '');
      });

      test('creates from protocolError', () {
        final msg = SSH_Message_Disconnect.fromReason(
          SSHDisconnectReason.protocolError,
        );
        expect(msg.reasonCode, 2);
        expect(msg.description, 'Protocol error');
      });

      test('creates from connectionLost', () {
        final msg = SSH_Message_Disconnect.fromReason(
          SSHDisconnectReason.connectionLost,
        );
        expect(msg.reasonCode, 10);
        expect(msg.description, 'Connection lost');
      });
    });

    group('encode/decode roundtrip', () {
      test('encodes and decodes basic message', () {
        final original = SSH_Message_Disconnect(
          reasonCode: 11,
          description: 'Test disconnect',
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Disconnect.decode(encoded);

        expect(decoded.reasonCode, original.reasonCode);
        expect(decoded.description, original.description);
        expect(decoded.languageTag, original.languageTag);
      });

      test('encodes and decodes with language tag', () {
        final original = SSH_Message_Disconnect(
          reasonCode: 1,
          description: 'Not allowed',
          languageTag: 'en',
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Disconnect.decode(encoded);

        expect(decoded.reasonCode, 1);
        expect(decoded.description, 'Not allowed');
        expect(decoded.languageTag, 'en');
      });

      test('encodes and decodes from reason', () {
        final original = SSH_Message_Disconnect.fromReason(
          SSHDisconnectReason.keyExchangeFailed,
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Disconnect.decode(encoded);

        expect(decoded.reasonCode, 3);
        expect(decoded.description, 'Key exchange failed');
      });

      test('all disconnect reasons roundtrip', () {
        for (final reason in SSHDisconnectReason.values) {
          final original = SSH_Message_Disconnect.fromReason(reason);
          final encoded = original.encode();
          final decoded = SSH_Message_Disconnect.decode(encoded);

          expect(decoded.reasonCode, reason.code);
          expect(decoded.description, reason.description);
        }
      });
    });

    group('toString', () {
      test('includes all fields', () {
        final msg = SSH_Message_Disconnect(
          reasonCode: 11,
          description: 'Test',
          languageTag: 'en',
        );
        final str = msg.toString();
        expect(str, contains('SSH_Message_Disconnect'));
        expect(str, contains('reasonCode: 11'));
        expect(str, contains('description: Test'));
        expect(str, contains('language: en'));
      });
    });
  });
}
