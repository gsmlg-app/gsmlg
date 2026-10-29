import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:app_ssh/src/message/msg_request.dart';

void main() {
  group('SSH_Message_Global_Request', () {
    test('has correct messageId', () {
      expect(SSH_Message_Global_Request.messageId, 80);
    });

    group('constructor', () {
      test('creates basic request', () {
        final msg = SSH_Message_Global_Request(
          requestName: 'test-request',
          wantReply: true,
        );
        expect(msg.requestName, 'test-request');
        expect(msg.wantReply, true);
        expect(msg.bindAddress, isNull);
        expect(msg.bindPort, isNull);
      });

      test('creates request with wantReply false', () {
        final msg = SSH_Message_Global_Request(
          requestName: 'no-reply',
          wantReply: false,
        );
        expect(msg.wantReply, false);
      });
    });

    group('tcpipForward factory', () {
      test('creates tcpip-forward request', () {
        final msg = SSH_Message_Global_Request.tcpipForward('0.0.0.0', 8080);

        expect(msg.requestName, 'tcpip-forward');
        expect(msg.wantReply, true);
        expect(msg.bindAddress, '0.0.0.0');
        expect(msg.bindPort, 8080);
      });

      test('creates with localhost', () {
        final msg = SSH_Message_Global_Request.tcpipForward('127.0.0.1', 3000);

        expect(msg.bindAddress, '127.0.0.1');
        expect(msg.bindPort, 3000);
      });

      test('creates with port 0 for dynamic', () {
        final msg = SSH_Message_Global_Request.tcpipForward('0.0.0.0', 0);
        expect(msg.bindPort, 0);
      });
    });

    group('cancelTcpipForward factory', () {
      test('creates cancel request', () {
        final msg = SSH_Message_Global_Request.cancelTcpipForward(
          bindAddress: '0.0.0.0',
          bindPort: 8080,
        );

        expect(msg.requestName, 'cancel-tcpip-forward');
        expect(msg.wantReply, true);
        expect(msg.bindAddress, '0.0.0.0');
        expect(msg.bindPort, 8080);
      });
    });

    group('keepAlive factory', () {
      test('creates keepalive request', () {
        final msg = SSH_Message_Global_Request.keepAlive();

        expect(msg.requestName, 'keepalive@openssh.com');
        expect(msg.wantReply, true);
        expect(msg.bindAddress, isNull);
        expect(msg.bindPort, isNull);
      });
    });

    group('encode/decode roundtrip', () {
      test('encodes and decodes tcpip-forward', () {
        final original =
            SSH_Message_Global_Request.tcpipForward('192.168.1.1', 22);
        final encoded = original.encode();
        final decoded = SSH_Message_Global_Request.decode(encoded);

        expect(decoded.requestName, 'tcpip-forward');
        expect(decoded.wantReply, true);
        expect(decoded.bindAddress, '192.168.1.1');
        expect(decoded.bindPort, 22);
      });

      test('encodes and decodes cancel-tcpip-forward', () {
        final original = SSH_Message_Global_Request.cancelTcpipForward(
          bindAddress: '10.0.0.1',
          bindPort: 443,
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Global_Request.decode(encoded);

        expect(decoded.requestName, 'cancel-tcpip-forward');
        expect(decoded.bindAddress, '10.0.0.1');
        expect(decoded.bindPort, 443);
      });

      test('encodes and decodes keepalive', () {
        final original = SSH_Message_Global_Request.keepAlive();
        final encoded = original.encode();
        final decoded = SSH_Message_Global_Request.decode(encoded);

        expect(decoded.requestName, 'keepalive@openssh.com');
        expect(decoded.wantReply, true);
      });

      test('encodes and decodes unknown request', () {
        final original = SSH_Message_Global_Request(
          requestName: 'unknown-request',
          wantReply: false,
        );
        final encoded = original.encode();
        final decoded = SSH_Message_Global_Request.decode(encoded);

        expect(decoded.requestName, 'unknown-request');
        expect(decoded.wantReply, false);
      });
    });

    group('encode', () {
      test('first byte is message id', () {
        final msg = SSH_Message_Global_Request.keepAlive();
        final encoded = msg.encode();
        expect(encoded[0], SSH_Message_Global_Request.messageId);
      });
    });

    group('toString', () {
      test('tcpip-forward includes bind info', () {
        final msg = SSH_Message_Global_Request.tcpipForward('0.0.0.0', 8080);
        final str = msg.toString();
        expect(str, contains('SSH_Message_Global_Request'));
        expect(str, contains('tcpip-forward'));
        expect(str, contains('0.0.0.0'));
        expect(str, contains('8080'));
      });

      test('keepalive toString', () {
        final msg = SSH_Message_Global_Request.keepAlive();
        final str = msg.toString();
        expect(str, contains('keepalive@openssh.com'));
      });
    });
  });

  group('SSH_Message_Request_Success', () {
    test('has correct messageId', () {
      expect(SSH_Message_Request_Success.messageId, 81);
    });

    group('constructor', () {
      test('creates with data', () {
        final data = Uint8List.fromList([1, 2, 3, 4]);
        final msg = SSH_Message_Request_Success(data);
        expect(msg.requestData, [1, 2, 3, 4]);
      });

      test('creates with empty data', () {
        final msg = SSH_Message_Request_Success(Uint8List(0));
        expect(msg.requestData.isEmpty, true);
      });
    });

    group('encode/decode roundtrip', () {
      test('encodes and decodes with data', () {
        final original =
            SSH_Message_Request_Success(Uint8List.fromList([10, 20, 30]));
        final encoded = original.encode();
        final decoded = SSH_Message_Request_Success.decode(encoded);

        expect(decoded.requestData, [10, 20, 30]);
      });

      test('encodes and decodes empty', () {
        final original = SSH_Message_Request_Success(Uint8List(0));
        final encoded = original.encode();
        final decoded = SSH_Message_Request_Success.decode(encoded);

        expect(decoded.requestData.isEmpty, true);
      });

      test('encodes and decodes port data for tcpip-forward', () {
        // When server binds dynamic port, it returns the port in requestData
        // Port is 4 bytes big-endian
        final portData = Uint8List(4);
        ByteData.view(portData.buffer).setUint32(0, 12345, Endian.big);

        final original = SSH_Message_Request_Success(portData);
        final encoded = original.encode();
        final decoded = SSH_Message_Request_Success.decode(encoded);

        // Create ByteData from the decoded data using sublistView to handle offset
        final port =
            ByteData.sublistView(decoded.requestData).getUint32(0, Endian.big);
        expect(port, 12345);
      });
    });

    group('encode', () {
      test('first byte is message id', () {
        final msg = SSH_Message_Request_Success(Uint8List(0));
        final encoded = msg.encode();
        expect(encoded[0], SSH_Message_Request_Success.messageId);
      });
    });

    group('toString', () {
      test('includes hex data', () {
        final msg =
            SSH_Message_Request_Success(Uint8List.fromList([0xAB, 0xCD]));
        final str = msg.toString();
        expect(str, contains('SSH_Message_Request_Success'));
        expect(str.toLowerCase(), contains('abcd'));
      });
    });
  });

  group('SSH_Message_Request_Failure', () {
    test('has correct messageId', () {
      expect(SSH_Message_Request_Failure.messageId, 82);
    });

    group('constructor', () {
      test('creates empty failure message', () {
        final msg = SSH_Message_Request_Failure();
        expect(msg, isNotNull);
      });
    });

    group('encode/decode roundtrip', () {
      test('encodes and decodes', () {
        final original = SSH_Message_Request_Failure();
        final encoded = original.encode();
        final decoded = SSH_Message_Request_Failure.decode(encoded);

        expect(decoded, isA<SSH_Message_Request_Failure>());
      });
    });

    group('encode', () {
      test('first byte is message id', () {
        final msg = SSH_Message_Request_Failure();
        final encoded = msg.encode();
        expect(encoded[0], SSH_Message_Request_Failure.messageId);
      });

      test('minimal encoding (just message id)', () {
        final msg = SSH_Message_Request_Failure();
        final encoded = msg.encode();
        // Should only contain message id
        expect(encoded.length, 1);
      });
    });

    group('toString', () {
      test('has proper format', () {
        final msg = SSH_Message_Request_Failure();
        expect(msg.toString(), 'SSH_Message_Request_Failure()');
      });
    });
  });

  group('Request/Response message pairs', () {
    test('message ids are sequential', () {
      expect(SSH_Message_Global_Request.messageId, 80);
      expect(SSH_Message_Request_Success.messageId, 81);
      expect(SSH_Message_Request_Failure.messageId, 82);
    });

    test('typical port forwarding flow', () {
      // Client requests port forwarding
      final request = SSH_Message_Global_Request.tcpipForward('0.0.0.0', 0);
      expect(request.wantReply, true);

      // Server responds with success and assigned port
      final portData = Uint8List(4);
      ByteData.view(portData.buffer).setUint32(0, 54321, Endian.big);
      final success = SSH_Message_Request_Success(portData);

      final assignedPort =
          ByteData.view(success.requestData.buffer).getUint32(0, Endian.big);
      expect(assignedPort, 54321);
    });

    test('failed request flow', () {
      // Client requests something unsupported
      final request = SSH_Message_Global_Request(
        requestName: 'unsupported-feature',
        wantReply: true,
      );
      expect(request.wantReply, true);

      // Server responds with failure
      final failure = SSH_Message_Request_Failure();
      expect(failure.encode().length, 1);
    });
  });
}
