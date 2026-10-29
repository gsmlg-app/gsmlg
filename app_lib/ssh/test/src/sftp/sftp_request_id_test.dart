import 'package:test/test.dart';
import 'package:app_ssh/src/sftp/sftp_request_id.dart';

void main() {
  group('SftpRequestId', () {
    late SftpRequestId requestId;

    setUp(() {
      requestId = SftpRequestId();
    });

    group('next', () {
      test('first id is 0', () {
        expect(requestId.next, 0);
      });

      test('ids are sequential', () {
        expect(requestId.next, 0);
        expect(requestId.next, 1);
        expect(requestId.next, 2);
        expect(requestId.next, 3);
        expect(requestId.next, 4);
      });

      test('generates many unique ids', () {
        final ids = <int>{};
        for (var i = 0; i < 1000; i++) {
          ids.add(requestId.next);
        }
        expect(ids.length, 1000);
      });

      test('ids are non-negative', () {
        for (var i = 0; i < 100; i++) {
          final id = requestId.next;
          expect(id, greaterThanOrEqualTo(0));
        }
      });
    });

    group('max constant', () {
      test('max is 0xFFFFFFFF', () {
        expect(SftpRequestId.max, 0xFFFFFFFF);
      });

      test('max is 32-bit unsigned int max', () {
        expect(SftpRequestId.max, 4294967295);
      });
    });

    group('independent instances', () {
      test('different instances have independent counters', () {
        final requestId1 = SftpRequestId();
        final requestId2 = SftpRequestId();

        // Both start at 0
        expect(requestId1.next, 0);
        expect(requestId2.next, 0);

        // Each increments independently
        expect(requestId1.next, 1);
        expect(requestId1.next, 2);
        expect(requestId2.next, 1);
      });

      test('creates new instance for each SFTP session', () {
        // Simulate multiple SFTP sessions
        final sessions = <SftpRequestId>[];
        for (var i = 0; i < 5; i++) {
          sessions.add(SftpRequestId());
        }

        // Each session starts at 0
        for (final session in sessions) {
          expect(session.next, 0);
        }
      });
    });

    group('typical usage', () {
      test('generate ids for multiple operations', () {
        // Simulating multiple SFTP operations
        final openId = requestId.next;
        final readId = requestId.next;
        final writeId = requestId.next;
        final closeId = requestId.next;

        expect(openId, 0);
        expect(readId, 1);
        expect(writeId, 2);
        expect(closeId, 3);
      });

      test('id can be used as map key', () {
        final pendingRequests = <int, String>{};

        final id1 = requestId.next;
        final id2 = requestId.next;

        pendingRequests[id1] = 'open';
        pendingRequests[id2] = 'read';

        expect(pendingRequests[id1], 'open');
        expect(pendingRequests[id2], 'read');
      });

      test('concurrent operations can be tracked', () {
        final pending = <int>[];

        // Start multiple operations
        pending.add(requestId.next);
        pending.add(requestId.next);
        pending.add(requestId.next);

        expect(pending, [0, 1, 2]);

        // Complete middle one
        pending.remove(1);
        expect(pending, [0, 2]);

        // Start new operation - gets next id
        pending.add(requestId.next);
        expect(pending, [0, 2, 3]);
      });
    });
  });
}
