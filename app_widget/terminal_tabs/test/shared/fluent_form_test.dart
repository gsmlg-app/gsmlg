import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shared/fluent_form.dart';

void main() {
  group('FluentFormDivider', () {
    testWidgets('renders Divider with spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [Text('Above'), FluentFormDivider(), Text('Below')],
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
      expect(find.byType(FluentFormDivider), findsOneWidget);
    });

    testWidgets('contains a Divider', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FluentFormDivider())),
      );

      // Find Divider within FluentFormDivider
      final dividerFinder = find.descendant(
        of: find.byType(FluentFormDivider),
        matching: find.byType(Divider),
      );
      expect(dividerFinder, findsOneWidget);
    });

    test('can be const constructed', () {
      const divider = FluentFormDivider();
      expect(divider, isA<FluentFormDivider>());
    });

    testWidgets('is a StatelessWidget', (tester) async {
      const divider = FluentFormDivider();
      expect(divider, isA<StatelessWidget>());
    });

    testWidgets('uses Column to layout spacing and divider', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FluentFormDivider())),
      );

      final columnFinder = find.descendant(
        of: find.byType(FluentFormDivider),
        matching: find.byType(Column),
      );
      expect(columnFinder, findsOneWidget);
    });
  });

  group('FluentFormHeader', () {
    testWidgets('renders header text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FluentFormHeader('Test Header')),
        ),
      );

      expect(find.text('Test Header'), findsOneWidget);
    });

    testWidgets('has 8 pixel spacing below header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FluentFormHeader('Header'))),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(8.0));
    });

    test('stores header string', () {
      const header = FluentFormHeader('My Header');
      expect(header.header, equals('My Header'));
    });

    testWidgets('uses Column to layout text and spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FluentFormHeader('Header'))),
      );

      expect(find.byType(Column), findsOneWidget);
    });

    test('can be const constructed with key', () {
      final key = UniqueKey();
      final header = FluentFormHeader('Header', key: key);
      expect(header.key, equals(key));
    });

    testWidgets('renders different header texts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FluentFormHeader('Header 1'),
                FluentFormHeader('Header 2'),
                FluentFormHeader('Header 3'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Header 1'), findsOneWidget);
      expect(find.text('Header 2'), findsOneWidget);
      expect(find.text('Header 3'), findsOneWidget);
    });

    testWidgets('supports special characters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FluentFormHeader('特殊字符 & Symbols!')),
        ),
      );

      expect(find.text('特殊字符 & Symbols!'), findsOneWidget);
    });
  });

  group('FluentFormSeparator', () {
    testWidgets('renders SizedBox with height 8', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FluentFormSeparator())),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(8.0));
    });

    test('can be const constructed', () {
      const separator = FluentFormSeparator();
      expect(separator, isA<FluentFormSeparator>());
    });

    testWidgets('is a StatelessWidget', (tester) async {
      const separator = FluentFormSeparator();
      expect(separator, isA<StatelessWidget>());
    });

    test('can have a key', () {
      final key = UniqueKey();
      final separator = FluentFormSeparator(key: key);
      expect(separator.key, equals(key));
    });

    testWidgets('can be used multiple times in a Column', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Item 1'),
                FluentFormSeparator(),
                Text('Item 2'),
                FluentFormSeparator(),
                Text('Item 3'),
              ],
            ),
          ),
        ),
      );

      // Find separator SizedBoxes (height 8, no width)
      final separators = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(separators.where((s) => s.height == 8.0).length, equals(2));
    });
  });

  group('Widget integration', () {
    testWidgets('can be used together in a form layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FluentFormHeader('Personal Info'),
                Text('Name field'),
                FluentFormSeparator(),
                Text('Email field'),
                FluentFormDivider(),
                FluentFormHeader('Address'),
                Text('Street field'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Personal Info'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
