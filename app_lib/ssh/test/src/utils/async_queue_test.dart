import 'dart:async';

import 'package:test/test.dart';
import 'package:app_ssh/src/utils/async_queue.dart';

void main() {
  group('AsyncQueue', () {
    late AsyncQueue<int> queue;

    setUp(() {
      queue = AsyncQueue<int>();
    });

    group('constructor', () {
      test('starts with length 0', () {
        expect(queue.length, 0);
      });

      test('starts with no waiters', () {
        expect(queue.hasWaiters, isFalse);
      });
    });

    group('add', () {
      test('adds item to queue when no waiters', () {
        queue.add(1);
        // Item should be in queue
        expect(queue.next, 1);
      });

      test('adds multiple items in order', () {
        queue.add(1);
        queue.add(2);
        queue.add(3);

        expect(queue.next, 1);
        expect(queue.next, 2);
        expect(queue.next, 3);
      });
    });

    group('next', () {
      test('returns item immediately when available', () {
        queue.add(42);
        final result = queue.next;
        expect(result, 42);
      });

      test('returns future when no items available', () {
        final result = queue.next;
        expect(result, isA<Future<int>>());
      });

      test('future completes when item is added', () async {
        final future = queue.next as Future<int>;
        queue.add(99);
        final result = await future;
        expect(result, 99);
      });

      test('maintains FIFO order', () {
        queue.add(1);
        queue.add(2);
        queue.add(3);

        expect(queue.next, 1);
        expect(queue.next, 2);
        expect(queue.next, 3);
      });

      test('removes item from queue when returned', () {
        queue.add(1);
        queue.next;
        // Queue should be empty now, next should return a future
        expect(queue.next, isA<Future<int>>());
      });
    });

    group('length', () {
      test('returns number of waiters', () {
        // No waiters initially
        expect(queue.length, 0);

        // Add a waiter
        queue.next; // This creates a waiter
        expect(queue.length, 1);

        // Add another waiter
        queue.next;
        expect(queue.length, 2);
      });

      test('decreases when waiter is satisfied', () async {
        final future1 = queue.next as Future<int>;
        final future2 = queue.next as Future<int>;
        expect(queue.length, 2);

        queue.add(1);
        await future1;
        expect(queue.length, 1);

        queue.add(2);
        await future2;
        expect(queue.length, 0);
      });
    });

    group('hasWaiters', () {
      test('returns false when no waiters', () {
        expect(queue.hasWaiters, isFalse);
      });

      test('returns true when has waiters', () {
        queue.next; // Creates a waiter
        expect(queue.hasWaiters, isTrue);
      });

      test('returns false after waiters are satisfied', () async {
        final future = queue.next as Future<int>;
        expect(queue.hasWaiters, isTrue);

        queue.add(1);
        await future;
        expect(queue.hasWaiters, isFalse);
      });
    });

    group('concurrent scenarios', () {
      test('multiple waiters are satisfied in order', () async {
        final results = <int>[];

        // Create multiple waiters
        final future1 = (queue.next as Future<int>).then((v) {
          results.add(v);
          return v;
        });
        final future2 = (queue.next as Future<int>).then((v) {
          results.add(v);
          return v;
        });
        final future3 = (queue.next as Future<int>).then((v) {
          results.add(v);
          return v;
        });

        // Add items
        queue.add(1);
        queue.add(2);
        queue.add(3);

        // Wait for all
        await Future.wait([future1, future2, future3]);

        expect(results, [1, 2, 3]);
      });

      test('mixed add and next operations', () async {
        // Add some items first
        queue.add(1);
        queue.add(2);

        // Get them
        expect(queue.next, 1);
        expect(queue.next, 2);

        // Now queue is empty, create a waiter
        final future = queue.next as Future<int>;

        // Add more
        queue.add(3);

        expect(await future, 3);
      });

      test('items added before waiters go to queue', () {
        queue.add(10);
        queue.add(20);
        queue.add(30);

        // Now get them - should return immediately, not futures
        expect(queue.next, 10);
        expect(queue.next, 20);
        expect(queue.next, 30);
      });
    });

    group('type handling', () {
      test('works with String type', () async {
        final stringQueue = AsyncQueue<String>();

        stringQueue.add('hello');
        stringQueue.add('world');

        expect(stringQueue.next, 'hello');
        expect(stringQueue.next, 'world');
      });

      test('works with nullable type', () async {
        final nullableQueue = AsyncQueue<int?>();

        nullableQueue.add(null);
        nullableQueue.add(42);

        expect(nullableQueue.next, isNull);
        expect(nullableQueue.next, 42);
      });

      test('works with complex objects', () {
        final objectQueue = AsyncQueue<List<int>>();

        objectQueue.add([1, 2, 3]);
        objectQueue.add([4, 5, 6]);

        expect(objectQueue.next, [1, 2, 3]);
        expect(objectQueue.next, [4, 5, 6]);
      });
    });

    group('edge cases', () {
      test('handles single add-get cycle', () {
        queue.add(1);
        expect(queue.next, 1);
      });

      test('handles alternating add-get', () async {
        queue.add(1);
        expect(queue.next, 1);

        final future = queue.next as Future<int>;
        queue.add(2);
        expect(await future, 2);

        queue.add(3);
        expect(queue.next, 3);
      });

      test('waiter created, then multiple items added', () async {
        final future = queue.next as Future<int>;

        queue.add(100);
        queue.add(200);
        queue.add(300);

        // First waiter gets first item
        expect(await future, 100);

        // Remaining items are in queue
        expect(queue.next, 200);
        expect(queue.next, 300);
      });
    });
  });
}
