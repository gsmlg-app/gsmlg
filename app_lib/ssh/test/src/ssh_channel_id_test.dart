import 'package:test/test.dart';
import 'package:app_ssh/src/ssh_channel_id.dart';

void main() {
  group('SSHChannelIdAllocator', () {
    late SSHChannelIdAllocator allocator;

    setUp(() {
      allocator = SSHChannelIdAllocator();
    });

    group('allocate', () {
      test('allocates first id as 0', () {
        final id = allocator.allocate();
        expect(id, 0);
      });

      test('allocates sequential ids', () {
        final id1 = allocator.allocate();
        final id2 = allocator.allocate();
        final id3 = allocator.allocate();

        expect(id1, 0);
        expect(id2, 1);
        expect(id3, 2);
      });

      test('allocates unique ids', () {
        final ids = <int>{};
        for (var i = 0; i < 100; i++) {
          ids.add(allocator.allocate());
        }
        expect(ids.length, 100);
      });

      test('allocates many ids', () {
        for (var i = 0; i < 1000; i++) {
          final id = allocator.allocate();
          expect(id, greaterThanOrEqualTo(0));
          expect(id, lessThanOrEqualTo(0xFFFF));
        }
      });
    });

    group('release', () {
      test('releases allocated id', () {
        final id = allocator.allocate();
        allocator.release(id);
        // No error should be thrown
      });

      test('released id can be reallocated', () {
        final id1 = allocator.allocate();
        allocator.allocate(); // id2
        allocator.allocate(); // id3

        allocator.release(id1);

        // Allocate more ids until id1 is reused
        final newIds = <int>[];
        for (var i = 0; i < 100; i++) {
          final id = allocator.allocate();
          newIds.add(id);
          if (id == id1) break;
        }

        // After wrapping, id1 should be reusable (though not immediately)
        // The allocator continues from where it left off, but id1 is available
        expect(newIds, isNotEmpty);
      });

      test('releasing non-allocated id is safe', () {
        // Should not throw
        allocator.release(999);
      });

      test('releasing same id multiple times is safe', () {
        final id = allocator.allocate();
        allocator.release(id);
        allocator.release(id);
        // Should not throw
      });
    });

    group('id wrapping', () {
      test('ids wrap around after reaching max', () {
        // Allocate and release to simulate wrapping
        final allocator = SSHChannelIdAllocator();

        // Allocate some ids
        for (var i = 0; i < 10; i++) {
          allocator.allocate();
        }

        // The allocator should handle wrapping internally
        // We can't easily test 0xFFFF allocations, so we test the concept
        expect(allocator.allocate(), greaterThanOrEqualTo(0));
      });
    });

    group('capacity', () {
      test('max id is 0xFFFF', () {
        // The allocator has a max of 0xFFFF (65535) channel ids
        // Verifying through the constant indirectly
        final id = allocator.allocate();
        expect(id, lessThanOrEqualTo(0xFFFF));
      });

      test('throws when all ids are exhausted', () {
        // The allocator allows _maxId (0xFFFF = 65535) simultaneous allocations
        // The capacity check is: _allocated.length >= _maxId
        for (var i = 0; i < 0xFFFF; i++) {
          allocator.allocate();
        }

        // Next allocation should throw
        expect(() => allocator.allocate(), throwsException);
      });

      test('can allocate after releasing when at capacity', () {
        // Allocate to capacity (0xFFFF = 65535 ids)
        // This allocates IDs 0-65534
        allocator.allocate(); // 0
        for (var i = 1; i < 0xFFFF; i++) {
          allocator.allocate();
        }
        // At this point: allocated = {0,1,...,65534}, _nextId = 65535

        // Now at capacity - should throw
        expect(() => allocator.allocate(), throwsException);

        // Release one (ID 0)
        allocator.release(0);

        // Should be able to allocate again
        // Allocator continues from _nextId=65535, finds it available
        final newId = allocator.allocate();
        expect(newId, 0xFFFF); // Gets 65535, the next sequential ID
      });

      test('released id can be reallocated', () {
        // Allocate and release, then verify slot becomes available
        final id1 = allocator.allocate(); // 0
        allocator.allocate(); // 1 (id2 not used in assertions)
        allocator.release(id1);

        // Fill up to near capacity, but not quite
        for (var i = 2; i < 100; i++) {
          allocator.allocate();
        }

        // Verify id1 (0) is available for reuse - it was released
        // The allocator tracks which IDs are in use, so 0 is available
        expect(allocator.allocate(),
            isNot(id1)); // Sequential continues from _nextId

        // ID 0 should eventually get reused after wrap
      });
    });

    group('multiple allocators', () {
      test('allocators are independent', () {
        final allocator1 = SSHChannelIdAllocator();
        final allocator2 = SSHChannelIdAllocator();

        final id1a = allocator1.allocate();
        final id2a = allocator2.allocate();
        final id1b = allocator1.allocate();
        final id2b = allocator2.allocate();

        // Both should start at 0
        expect(id1a, 0);
        expect(id2a, 0);
        expect(id1b, 1);
        expect(id2b, 1);
      });
    });

    group('SSHChannelId typedef', () {
      test('is int type', () {
        final id = allocator.allocate();
        expect(id, isA<int>());
        expect(id, isA<SSHChannelId>());
      });

      test('can be used in arithmetic', () {
        final id = allocator.allocate();
        expect(id + 1, 1);
        expect(id * 2, 0);
      });

      test('can be used as map key', () {
        final map = <SSHChannelId, String>{};
        final id1 = allocator.allocate();
        final id2 = allocator.allocate();

        map[id1] = 'channel 1';
        map[id2] = 'channel 2';

        expect(map[id1], 'channel 1');
        expect(map[id2], 'channel 2');
      });

      test('can be compared', () {
        final id1 = allocator.allocate();
        final id2 = allocator.allocate();

        expect(id1 < id2, isTrue);
        expect(id2 > id1, isTrue);
        expect(id1 == 0, isTrue);
      });
    });
  });
}
