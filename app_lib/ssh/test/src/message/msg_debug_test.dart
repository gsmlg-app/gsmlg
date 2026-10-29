import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/message/msg_debug.dart';

void main() {
  group('SSH_Message_Debug', () {
    test('has correct messageId', () {
      expect(SSH_Message_Debug.messageId, 4);
    });

    group('constructor', () {
      test('creates message with all fields', () {
        final msg = SSH_Message_Debug(
          alwaysDisplay: true,
          message: Uint8List.fromList([0x48, 0x69]),
          language: Uint8List.fromList([0x65, 0x6e]),
        );
        expect(msg.alwaysDisplay, true);
        expect(msg.message, [0x48, 0x69]);
        expect(msg.language, [0x65, 0x6e]);
      });

      test('creates message with alwaysDisplay false', () {
        final msg = SSH_Message_Debug(
          alwaysDisplay: false,
          message: Uint8List(0),
          language: Uint8List(0),
        );
        expect(msg.alwaysDisplay, false);
      });

      test('creates message with empty fields', () {
        final msg = SSH_Message_Debug(
          alwaysDisplay: false,
          message: Uint8List(0),
          language: Uint8List(0),
        );
        expect(msg.message.isEmpty, true);
        expect(msg.language.isEmpty, true);
      });
    });

    group('encode/decode roundtrip', () {
      test('encodes and decodes basic message', () {
        final original = SSH_Message_Debug(
          alwaysDisplay: true,
          message: Uint8List.fromList('Debug message'.codeUnits),
          language: Uint8List.fromList('en'.codeUnits),
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Debug.decode(encoded);

        expect(decoded.alwaysDisplay, original.alwaysDisplay);
        expect(decoded.message, original.message);
        expect(decoded.language, original.language);
      });

      test('encodes and decodes with alwaysDisplay false', () {
        final original = SSH_Message_Debug(
          alwaysDisplay: false,
          message: Uint8List.fromList('Info'.codeUnits),
          language: Uint8List(0),
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Debug.decode(encoded);

        expect(decoded.alwaysDisplay, false);
        expect(decoded.message, original.message);
      });

      test('encodes and decodes empty message', () {
        final original = SSH_Message_Debug(
          alwaysDisplay: true,
          message: Uint8List(0),
          language: Uint8List(0),
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Debug.decode(encoded);

        expect(decoded.alwaysDisplay, true);
        expect(decoded.message.isEmpty, true);
        expect(decoded.language.isEmpty, true);
      });

      test('encodes and decodes long message', () {
        final longMessage = List.generate(1000, (i) => i % 256);
        final original = SSH_Message_Debug(
          alwaysDisplay: true,
          message: Uint8List.fromList(longMessage),
          language: Uint8List.fromList('en-US'.codeUnits),
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Debug.decode(encoded);

        expect(decoded.message.length, 1000);
        expect(decoded.message, original.message);
      });
    });

    group('encode', () {
      test('first byte is message id', () {
        final msg = SSH_Message_Debug(
          alwaysDisplay: true,
          message: Uint8List(0),
          language: Uint8List(0),
        );
        final encoded = msg.encode();
        expect(encoded[0], SSH_Message_Debug.messageId);
      });

      test('produces valid bytes', () {
        final msg = SSH_Message_Debug(
          alwaysDisplay: true,
          message: Uint8List.fromList([0x41, 0x42, 0x43]),
          language: Uint8List.fromList([0x65, 0x6e]),
        );
        final encoded = msg.encode();

        expect(encoded, isA<Uint8List>());
        expect(encoded.isNotEmpty, true);
        expect(encoded.length, greaterThan(1));
      });
    });

    group('toString', () {
      test('includes all fields', () {
        final msg = SSH_Message_Debug(
          alwaysDisplay: true,
          message: Uint8List.fromList([0x41]),
          language: Uint8List.fromList([0x42]),
        );
        final str = msg.toString();
        expect(str, contains('SSH_Message_Debug'));
        expect(str, contains('alwaysDisplay: true'));
        expect(str, contains('message:'));
        expect(str, contains('language:'));
      });
    });

    group('typical usage', () {
      test('debug message from server', () {
        // Simulate server sending debug info
        final debugMsg = SSH_Message_Debug(
          alwaysDisplay: false,
          message: Uint8List.fromList('Authentication succeeded'.codeUnits),
          language: Uint8List(0),
        );

        expect(debugMsg.alwaysDisplay, false);
        expect(
            String.fromCharCodes(debugMsg.message), 'Authentication succeeded');
      });

      test('critical debug message', () {
        // alwaysDisplay = true means client should show regardless of settings
        final criticalMsg = SSH_Message_Debug(
          alwaysDisplay: true,
          message: Uint8List.fromList('Server shutting down'.codeUnits),
          language: Uint8List.fromList('en'.codeUnits),
        );

        expect(criticalMsg.alwaysDisplay, true);
      });
    });
  });
}
