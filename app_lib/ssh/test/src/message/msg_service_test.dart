import 'package:test/test.dart';
import 'package:app_ssh/src/message/msg_service.dart';

void main() {
  group('SSH_Message_Service_Request', () {
    test('has correct messageId', () {
      expect(SSH_Message_Service_Request.messageId, 5);
    });

    group('constructor', () {
      test('creates message with service name', () {
        final msg = SSH_Message_Service_Request('ssh-userauth');
        expect(msg.serviceName, 'ssh-userauth');
      });

      test('creates message with ssh-connection', () {
        final msg = SSH_Message_Service_Request('ssh-connection');
        expect(msg.serviceName, 'ssh-connection');
      });
    });

    group('encode/decode roundtrip', () {
      test('encodes and decodes ssh-userauth', () {
        final original = SSH_Message_Service_Request('ssh-userauth');
        final encoded = original.encode();
        final decoded = SSH_Message_Service_Request.decode(encoded);

        expect(decoded.serviceName, 'ssh-userauth');
      });

      test('encodes and decodes ssh-connection', () {
        final original = SSH_Message_Service_Request('ssh-connection');
        final encoded = original.encode();
        final decoded = SSH_Message_Service_Request.decode(encoded);

        expect(decoded.serviceName, 'ssh-connection');
      });

      test('encodes and decodes custom service', () {
        final original = SSH_Message_Service_Request('my-custom-service');
        final encoded = original.encode();
        final decoded = SSH_Message_Service_Request.decode(encoded);

        expect(decoded.serviceName, 'my-custom-service');
      });
    });

    group('encode', () {
      test('first byte is message id', () {
        final msg = SSH_Message_Service_Request('ssh-userauth');
        final encoded = msg.encode();
        expect(encoded[0], SSH_Message_Service_Request.messageId);
      });
    });

    group('toString', () {
      test('includes service name', () {
        final msg = SSH_Message_Service_Request('ssh-userauth');
        final str = msg.toString();
        expect(str, contains('SSH_Message_Service_Request'));
        expect(str, contains('ssh-userauth'));
      });
    });

    group('typical usage', () {
      test('request authentication service', () {
        final request = SSH_Message_Service_Request('ssh-userauth');
        expect(request.serviceName, 'ssh-userauth');
      });

      test('request connection service after auth', () {
        final request = SSH_Message_Service_Request('ssh-connection');
        expect(request.serviceName, 'ssh-connection');
      });
    });
  });

  group('SSH_Message_Service_Accept', () {
    test('has correct messageId', () {
      expect(SSH_Message_Service_Accept.messageId, 6);
    });

    group('constructor', () {
      test('creates message with service name', () {
        final msg = SSH_Message_Service_Accept('ssh-userauth');
        expect(msg.serviceName, 'ssh-userauth');
      });

      test('creates message with ssh-connection', () {
        final msg = SSH_Message_Service_Accept('ssh-connection');
        expect(msg.serviceName, 'ssh-connection');
      });
    });

    group('encode/decode roundtrip', () {
      test('encodes and decodes ssh-userauth', () {
        final original = SSH_Message_Service_Accept('ssh-userauth');
        final encoded = original.encode();
        final decoded = SSH_Message_Service_Accept.decode(encoded);

        expect(decoded.serviceName, 'ssh-userauth');
      });

      test('encodes and decodes ssh-connection', () {
        final original = SSH_Message_Service_Accept('ssh-connection');
        final encoded = original.encode();
        final decoded = SSH_Message_Service_Accept.decode(encoded);

        expect(decoded.serviceName, 'ssh-connection');
      });

      test('encodes and decodes custom service', () {
        final original = SSH_Message_Service_Accept('custom-service');
        final encoded = original.encode();
        final decoded = SSH_Message_Service_Accept.decode(encoded);

        expect(decoded.serviceName, 'custom-service');
      });
    });

    group('encode', () {
      test('first byte is message id', () {
        final msg = SSH_Message_Service_Accept('ssh-userauth');
        final encoded = msg.encode();
        expect(encoded[0], SSH_Message_Service_Accept.messageId);
      });
    });

    group('toString', () {
      test('includes service name', () {
        final msg = SSH_Message_Service_Accept('ssh-connection');
        final str = msg.toString();
        expect(str, contains('SSH_Message_Service_Accept'));
        expect(str, contains('ssh-connection'));
      });
    });
  });

  group('Service message pairs', () {
    test('request and accept have different message ids', () {
      expect(SSH_Message_Service_Request.messageId,
          isNot(SSH_Message_Service_Accept.messageId));
    });

    test('request is 5, accept is 6', () {
      expect(SSH_Message_Service_Request.messageId, 5);
      expect(SSH_Message_Service_Accept.messageId, 6);
    });

    test('typical service negotiation flow', () {
      // Client requests authentication service
      final request = SSH_Message_Service_Request('ssh-userauth');

      // Server accepts
      final accept = SSH_Message_Service_Accept('ssh-userauth');

      // Both have same service name
      expect(request.serviceName, accept.serviceName);
    });
  });
}
