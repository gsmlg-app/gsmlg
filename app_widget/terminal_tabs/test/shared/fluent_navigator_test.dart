import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shared/fluent_navigator.dart';

void main() {
  group('FluentNavigatorCommandBar', () {
    testWidgets('renders children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FluentNavigatorCommandBar(
              children: [Text('Action 1'), Text('Action 2')],
            ),
          ),
        ),
      );

      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
    });

    testWidgets('uses Row to layout children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FluentNavigatorCommandBar(children: [Text('Child')]),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('aligns children to the end (right)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FluentNavigatorCommandBar(children: [Text('Child')]),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, equals(MainAxisAlignment.end));
    });

    testWidgets('centers children vertically', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FluentNavigatorCommandBar(children: [Text('Child')]),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.crossAxisAlignment, equals(CrossAxisAlignment.center));
    });

    testWidgets('has right padding of 8', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FluentNavigatorCommandBar(children: [Text('Child')]),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, equals(const EdgeInsets.only(right: 8)));
    });

    test('stores children list', () {
      const children = [Text('A'), Text('B')];
      const commandBar = FluentNavigatorCommandBar(children: children);
      expect(commandBar.children.length, equals(2));
    });

    test('can be const constructed', () {
      const commandBar = FluentNavigatorCommandBar(children: []);
      expect(commandBar, isA<FluentNavigatorCommandBar>());
      expect(commandBar.children, isEmpty);
    });

    test('can have a key', () {
      final key = UniqueKey();
      final commandBar = FluentNavigatorCommandBar(
        key: key,
        children: const [],
      );
      expect(commandBar.key, equals(key));
    });

    testWidgets('is a StatelessWidget', (tester) async {
      const commandBar = FluentNavigatorCommandBar(children: []);
      expect(commandBar, isA<StatelessWidget>());
    });

    testWidgets('can contain buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FluentNavigatorCommandBar(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Save')),
                TextButton(onPressed: () {}, child: const Text('Cancel')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('buttons are tappable', (tester) async {
      var savePressed = false;
      var cancelPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FluentNavigatorCommandBar(
              children: [
                ElevatedButton(
                  onPressed: () => savePressed = true,
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () => cancelPressed = true,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(savePressed, isTrue);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(cancelPressed, isTrue);
    });

    testWidgets('can contain icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FluentNavigatorCommandBar(
              children: [Icon(Icons.save), Icon(Icons.close)],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('can be used in AppBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: FluentNavigatorCommandBar(children: [Text('Actions')]),
            ),
            body: Text('Content'),
          ),
        ),
      );

      expect(find.byType(FluentNavigatorCommandBar), findsOneWidget);
    });
  });
}
