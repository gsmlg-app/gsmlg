import 'package:flutter_test/flutter_test.dart';
import 'package:file_manager_plugin/file_manager_plugin.dart';

void main() {
  group('NavigationStack', () {
    late NavigationStack<String> stack;

    setUp(() {
      stack = NavigationStack<String>();
    });

    group('initial state', () {
      test('current is null when empty', () {
        expect(stack.current, isNull);
      });

      test('canGoBack is false when empty', () {
        expect(stack.canGoBack, isFalse);
      });

      test('canGoForward is false when empty', () {
        expect(stack.canGoForward, isFalse);
      });
    });

    group('push', () {
      test('sets current to pushed item', () {
        stack.push('/home');
        expect(stack.current, '/home');
      });

      test('multiple pushes updates current', () {
        stack.push('/home');
        stack.push('/documents');
        stack.push('/photos');

        expect(stack.current, '/photos');
      });

      test('enables canGoBack after multiple pushes', () {
        stack.push('/home');
        expect(stack.canGoBack, isFalse);

        stack.push('/documents');
        expect(stack.canGoBack, isTrue);
      });

      test('canGoForward is false after push', () {
        stack.push('/home');
        stack.push('/documents');

        expect(stack.canGoForward, isFalse);
      });

      test('notifies listeners', () {
        var notifyCount = 0;
        stack.addListener(() => notifyCount++);

        stack.push('/home');

        expect(notifyCount, 1);
      });

      test('calls onNavigate callback', () {
        String? navigatedTo;
        final stackWithCallback = NavigationStack<String>(
          onNavigate: (item) => navigatedTo = item,
        );

        stackWithCallback.push('/home');

        expect(navigatedTo, '/home');
      });

      test('clears forward history when pushing from middle', () {
        stack.push('/a');
        stack.push('/b');
        stack.push('/c');
        stack.back(); // At /b
        stack.back(); // At /a

        stack.push('/d'); // Should clear /b and /c

        expect(stack.current, '/d');
        expect(stack.canGoForward, isFalse);
        expect(stack.canGoBack, isTrue);

        stack.back();
        expect(stack.current, '/a');
      });
    });

    group('back', () {
      test('moves to previous item', () {
        stack.push('/home');
        stack.push('/documents');

        stack.back();

        expect(stack.current, '/home');
      });

      test('enables canGoForward', () {
        stack.push('/home');
        stack.push('/documents');
        stack.back();

        expect(stack.canGoForward, isTrue);
      });

      test('disables canGoBack when at first item', () {
        stack.push('/home');
        stack.push('/documents');
        stack.back();

        expect(stack.canGoBack, isFalse);
      });

      test('does nothing when at first item', () {
        stack.push('/home');
        stack.back();
        stack.back();
        stack.back();

        expect(stack.current, '/home');
      });

      test('notifies listeners', () {
        stack.push('/home');
        stack.push('/documents');

        var notifyCount = 0;
        stack.addListener(() => notifyCount++);

        stack.back();

        expect(notifyCount, 1);
      });

      test('does not notify when cannot go back', () {
        stack.push('/home');

        var notifyCount = 0;
        stack.addListener(() => notifyCount++);

        stack.back();

        expect(notifyCount, 0);
      });

      test('calls onNavigate callback', () {
        String? navigatedTo;
        final stackWithCallback = NavigationStack<String>(
          onNavigate: (item) => navigatedTo = item,
        );

        stackWithCallback.push('/home');
        stackWithCallback.push('/documents');
        stackWithCallback.back();

        expect(navigatedTo, '/home');
      });
    });

    group('forward', () {
      test('moves to next item after back', () {
        stack.push('/home');
        stack.push('/documents');
        stack.back();

        stack.forward();

        expect(stack.current, '/documents');
      });

      test('enables canGoBack', () {
        stack.push('/home');
        stack.push('/documents');
        stack.back();
        stack.forward();

        expect(stack.canGoBack, isTrue);
      });

      test('disables canGoForward when at end', () {
        stack.push('/home');
        stack.push('/documents');
        stack.back();
        stack.forward();

        expect(stack.canGoForward, isFalse);
      });

      test('does nothing when at end', () {
        stack.push('/home');
        stack.push('/documents');
        stack.forward();
        stack.forward();
        stack.forward();

        expect(stack.current, '/documents');
      });

      test('notifies listeners', () {
        stack.push('/home');
        stack.push('/documents');
        stack.back();

        var notifyCount = 0;
        stack.addListener(() => notifyCount++);

        stack.forward();

        expect(notifyCount, 1);
      });

      test('does not notify when cannot go forward', () {
        stack.push('/home');

        var notifyCount = 0;
        stack.addListener(() => notifyCount++);

        stack.forward();

        expect(notifyCount, 0);
      });

      test('calls onNavigate callback', () {
        String? navigatedTo;
        final stackWithCallback = NavigationStack<String>(
          onNavigate: (item) => navigatedTo = item,
        );

        stackWithCallback.push('/home');
        stackWithCallback.push('/documents');
        stackWithCallback.back();
        stackWithCallback.forward();

        expect(navigatedTo, '/documents');
      });
    });

    group('complex navigation', () {
      test('back and forward multiple times', () {
        stack.push('/a');
        stack.push('/b');
        stack.push('/c');
        stack.push('/d');

        stack.back();
        expect(stack.current, '/c');

        stack.back();
        expect(stack.current, '/b');

        stack.forward();
        expect(stack.current, '/c');

        stack.back();
        stack.back();
        expect(stack.current, '/a');

        stack.forward();
        stack.forward();
        stack.forward();
        expect(stack.current, '/d');
      });

      test('push clears forward history', () {
        stack.push('/a');
        stack.push('/b');
        stack.push('/c');

        stack.back();
        stack.back();
        expect(stack.current, '/a');

        stack.push('/new');
        expect(stack.current, '/new');
        expect(stack.canGoForward, isFalse);

        stack.back();
        expect(stack.current, '/a');

        stack.forward();
        expect(stack.current, '/new');
      });

      test('works with non-string types', () {
        final intStack = NavigationStack<int>();

        intStack.push(1);
        intStack.push(2);
        intStack.push(3);

        expect(intStack.current, 3);

        intStack.back();
        expect(intStack.current, 2);

        intStack.forward();
        expect(intStack.current, 3);
      });
    });
  });
}
