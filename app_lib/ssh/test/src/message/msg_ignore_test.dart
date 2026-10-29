import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/message/msg_ignore.dart';

void main() {
  group('SSH_Message_Ignore', () {
    test('has correct messageId', () {
      expect(SSH_Message_Ignore.messageId, 2);
    });

    group('constructor', () {
      test('creates message with data', () {
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final msg = SSH_Message_Ignore(data);
        expect(msg.data, [1, 2, 3, 4, 5]);
      });

      test('creates message with empty data', () {
        final msg = SSH_Message_Ignore(Uint8List(0));
        expect(msg.data.isEmpty, true);
      });
    });

    group('empty constructor', () {
      test('creates message with no data', () {
        final msg = SSH_Message_Ignore.empty();
        expect(msg.data.isEmpty, true);
        expect(msg.data.length, 0);
      });
    });

    group('encode/decode roundtrip', () {
      test('encodes and decodes basic message', () {
        final original = SSH_Message_Ignore(Uint8List.fromList([10, 20, 30]));
        final encoded = original.encode();
        final decoded = SSH_Message_Ignore.decode(encoded);

        expect(decoded.data, original.data);
      });

      test('encodes and decodes empty message', () {
        final original = SSH_Message_Ignore.empty();
        final encoded = original.encode();
        final decoded = SSH_Message_Ignore.decode(encoded);

        expect(decoded.data.isEmpty, true);
      });

      test('encodes and decodes large data', () {
        final largeData =
            Uint8List.fromList(List.generate(10000, (i) => i % 256));
        final original = SSH_Message_Ignore(largeData);
        final encoded = original.encode();
        final decoded = SSH_Message_Ignore.decode(encoded);

        expect(decoded.data.length, 10000);
        expect(decoded.data, original.data);
      });

      test('encodes and decodes random data', () {
        final randomData = Uint8List.fromList([
          0xFF,
          0x00,
          0xAB,
          0xCD,
          0xEF,
          0x12,
          0x34,
          0x56,
          0x78,
          0x9A,
        ]);
        final original = SSH_Message_Ignore(randomData);
        final encoded = original.encode();
        final decoded = SSH_Message_Ignore.decode(encoded);

        expect(decoded.data, original.data);
      });
    });

    group('encode', () {
      test('first byte is message id', () {
        final msg = SSH_Message_Ignore(Uint8List.fromList([1, 2, 3]));
        final encoded = msg.encode();
        expect(encoded[0], SSH_Message_Ignore.messageId);
      });

      test('produces valid bytes', () {
        final msg = SSH_Message_Ignore(Uint8List.fromList([1, 2, 3]));
        final encoded = msg.encode();

        expect(encoded, isA<Uint8List>());
        expect(encoded.isNotEmpty, true);
      });

      test('empty produces minimal output', () {
        final msg = SSH_Message_Ignore.empty();
        final encoded = msg.encode();

        // Should have: messageId (1) + length prefix (4) + data (0)
        expect(encoded.isNotEmpty, true);
        expect(encoded[0], SSH_Message_Ignore.messageId);
      });
    });

    group('toString', () {
      test('includes data', () {
        final msg = SSH_Message_Ignore(Uint8List.fromList([1, 2, 3]));
        final str = msg.toString();
        expect(str, contains('SSH_Message_Ignore'));
        expect(str, contains('data:'));
      });

      test('empty message toString', () {
        final msg = SSH_Message_Ignore.empty();
        final str = msg.toString();
        expect(str, contains('SSH_Message_Ignore'));
      });
    });

    group('typical usage', () {
      test('keepalive padding', () {
        // SSH_MSG_IGNORE is often used for keepalive or padding
        final keepalive = SSH_Message_Ignore.empty();
        expect(keepalive.data.isEmpty, true);
      });

      test('traffic analysis resistance', () {
        // Can send random data to obscure real traffic patterns
        final padding = SSH_Message_Ignore(Uint8List.fromList(
          List.generate(100, (i) => i % 256),
        ));
        expect(padding.data.length, 100);
      });

      test('interoperability test data', () {
        // Test that message survives encode/decode
        final testData = SSH_Message_Ignore(Uint8List.fromList(
          'SSH ignore test message'.codeUnits,
        ));
        final roundtrip = SSH_Message_Ignore.decode(testData.encode());
        expect(
          String.fromCharCodes(roundtrip.data),
          'SSH ignore test message',
        );
      });
    });

    group('data variations', () {
      test('single byte', () {
        final msg = SSH_Message_Ignore(Uint8List.fromList([42]));
        final decoded = SSH_Message_Ignore.decode(msg.encode());
        expect(decoded.data, [42]);
      });

      test('all zeros', () {
        final msg = SSH_Message_Ignore(Uint8List(100));
        final decoded = SSH_Message_Ignore.decode(msg.encode());
        expect(decoded.data.every((b) => b == 0), true);
      });

      test('all ones (0xFF)', () {
        final msg = SSH_Message_Ignore(Uint8List.fromList(
          List.filled(50, 0xFF),
        ));
        final decoded = SSH_Message_Ignore.decode(msg.encode());
        expect(decoded.data.every((b) => b == 0xFF), true);
      });

      test('binary data with null bytes', () {
        final msg = SSH_Message_Ignore(Uint8List.fromList([
          0x00,
          0x01,
          0x00,
          0x02,
          0x00,
          0x03,
        ]));
        final decoded = SSH_Message_Ignore.decode(msg.encode());
        expect(decoded.data, [0x00, 0x01, 0x00, 0x02, 0x00, 0x03]);
      });
    });
  });
}
