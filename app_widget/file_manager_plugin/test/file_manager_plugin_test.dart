import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_manager_plugin/file_manager_plugin.dart';
import 'package:terminal_core/terminal_core.dart';

void main() {
  group('FileManagerPlugin', () {
    late FileManagerPlugin plugin;

    setUp(() {
      plugin = FileManagerPlugin();
    });

    group('construction', () {
      test('can be instantiated', () {
        expect(plugin, isA<FileManagerPlugin>());
      });

      test('implements Plugin mixin', () {
        expect(plugin, isA<Plugin>());
      });

      test('has currentPath ValueNotifier', () {
        expect(plugin.currentPath, isA<ValueNotifier<String?>>());
      });

      test('currentPath is initially null', () {
        expect(plugin.currentPath.value, isNull);
      });

      test('has files ValueNotifier', () {
        expect(plugin.files, isA<ValueNotifier<List<FileSystemEntity>>>());
      });

      test('files is initially empty', () {
        expect(plugin.files.value, isEmpty);
      });

      test('has navigationStack', () {
        expect(plugin.navigationStack, isA<NavigationStack<String>>());
      });
    });

    group('currentDirectory', () {
      test('returns null when currentPath is null', () {
        expect(plugin.currentPath.value, isNull);
        expect(plugin.currentDirectory, isNull);
      });
    });

    group('breadcrumbs', () {
      test('returns empty list when currentPath is null', () {
        expect(plugin.breadcrumbs, isEmpty);
      });
    });

    group('canGoUp', () {
      test('returns false when breadcrumbs is empty', () {
        expect(plugin.canGoUp, isFalse);
      });
    });

    group('didMounted', () {
      test('sets title to Files', () {
        plugin.didMounted();
        expect(plugin.title.value, 'Files');
      });
    });

    group('homePath', () {
      test('is initially null', () {
        expect(plugin.homePath, isNull);
      });
    });
  });

  group('FileListToolbar', () {
    late FileManagerPlugin plugin;

    setUp(() {
      plugin = FileManagerPlugin();
    });

    testWidgets('can be constructed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      expect(find.byType(FileListToolbar), findsOneWidget);
    });

    testWidgets('is StatelessWidget', (tester) async {
      expect(FileListToolbar(FileManagerPlugin()), isA<StatelessWidget>());
    });

    testWidgets('accepts key parameter', (tester) async {
      const key = Key('test-toolbar');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin, key: key),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('contains back button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      // Look for back arrow icon
      expect(find.byIcon(Icons.adaptive.arrow_back), findsOneWidget);
    });

    testWidgets('contains forward button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      // Look for forward arrow icon
      expect(find.byIcon(Icons.adaptive.arrow_forward), findsOneWidget);
    });

    testWidgets('contains up button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('contains home button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('contains refresh button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('back button is disabled when canGoBack is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      // Find the back button IconButton
      final backButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.adaptive.arrow_back),
          matching: find.byType(IconButton),
        ),
      );

      expect(backButton.onPressed, isNull);
    });

    testWidgets('forward button is disabled when canGoForward is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      // Find the forward button IconButton
      final forwardButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.adaptive.arrow_forward),
          matching: find.byType(IconButton),
        ),
      );

      expect(forwardButton.onPressed, isNull);
    });

    testWidgets('up button is disabled when canGoUp is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      final upButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.arrow_upward),
          matching: find.byType(IconButton),
        ),
      );

      expect(upButton.onPressed, isNull);
    });

    testWidgets('home button is disabled when homePath is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListToolbar(plugin),
          ),
        ),
      );

      final homeButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.home),
          matching: find.byType(IconButton),
        ),
      );

      expect(homeButton.onPressed, isNull);
    });
  });

  group('FileListNavigator', () {
    late FileManagerPlugin plugin;

    setUp(() {
      plugin = FileManagerPlugin();
    });

    testWidgets('can be constructed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListNavigator(plugin),
          ),
        ),
      );

      expect(find.byType(FileListNavigator), findsOneWidget);
    });

    testWidgets('is StatelessWidget', (tester) async {
      expect(FileListNavigator(FileManagerPlugin()), isA<StatelessWidget>());
    });

    testWidgets('accepts key parameter', (tester) async {
      const key = Key('test-navigator');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListNavigator(plugin, key: key),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('uses horizontal scrolling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListNavigator(plugin),
          ),
        ),
      );

      // Verify the widget tree contains SingleChildScrollView
      // Note: ScrollView might be nested in MaterialApp's scaffold
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('contains NavigationBreadcrumbs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListNavigator(plugin),
          ),
        ),
      );

      expect(find.byType(NavigationBreadcrumbs), findsOneWidget);
    });
  });

  group('FileListView', () {
    late FileManagerPlugin plugin;

    setUp(() {
      plugin = FileManagerPlugin();
    });

    testWidgets('can be constructed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListView(plugin),
          ),
        ),
      );

      expect(find.byType(FileListView), findsOneWidget);
    });

    testWidgets('is StatefulWidget', (tester) async {
      expect(FileListView(FileManagerPlugin()), isA<StatefulWidget>());
    });

    testWidgets('accepts key parameter', (tester) async {
      const key = Key('test-filelistview');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileListView(plugin, key: key),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('creates state', (tester) async {
      final widget = FileListView(plugin);
      expect(widget.createState(), isA<FileListViewState>());
    });
  });

  group('NavigationStack', () {
    group('generic type support', () {
      test('works with int', () {
        final stack = NavigationStack<int>();
        stack.push(1);
        stack.push(2);
        expect(stack.current, 2);
        stack.back();
        expect(stack.current, 1);
      });

      test('works with custom class', () {
        final stack = NavigationStack<_CustomPath>();
        final path1 = _CustomPath('/home');
        final path2 = _CustomPath('/documents');

        stack.push(path1);
        stack.push(path2);

        expect(stack.current, path2);
        expect(stack.current?.value, '/documents');
      });
    });
  });
}

class _CustomPath {
  _CustomPath(this.value);
  final String value;
}
