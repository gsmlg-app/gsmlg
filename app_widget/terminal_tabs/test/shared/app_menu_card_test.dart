import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shared/app_menu_card.dart';

void main() {
  group('AppMenuCard', () {
    testWidgets('renders children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppMenuCard(children: [Text('Item 1'), Text('Item 2')]),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('has minimum width of 250', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppMenuCard(children: [Text('Short')])),
          ),
        ),
      );

      // Find ConstrainedBox inside AppMenuCard
      final constrainedBoxFinder = find.descendant(
        of: find.byType(AppMenuCard),
        matching: find.byType(ConstrainedBox),
      );
      final constrainedBox = tester.widget<ConstrainedBox>(
        constrainedBoxFinder,
      );
      expect(constrainedBox.constraints.minWidth, equals(250.0));
    });

    testWidgets('applies custom border radius', (tester) async {
      final borderRadius = BorderRadius.circular(16.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppMenuCard(
              borderRadius: borderRadius,
              children: const [Text('Content')],
            ),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, equals(borderRadius));
    });

    testWidgets('applies custom background color', (tester) async {
      const bgColor = Colors.blue;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppMenuCard(bgColor: bgColor, children: [Text('Content')]),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(bgColor));
    });

    testWidgets('applies custom border', (tester) async {
      final border = Border.all(color: Colors.red, width: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppMenuCard(
              border: border,
              children: const [Text('Content')],
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, equals(border));
    });

    testWidgets('applies custom padding', (tester) async {
      const padding = EdgeInsets.all(20.0);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppMenuCard(padding: padding, children: [Text('Content')]),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, equals(padding));
    });

    testWidgets('applies custom shadows', (tester) async {
      final shadows = [
        const BoxShadow(
          color: Colors.black,
          blurRadius: 10,
          offset: Offset(5, 5),
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppMenuCard(
              shadows: shadows,
              children: const [Text('Content')],
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, equals(shadows));
    });

    testWidgets('uses Column with MainAxisSize.min', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppMenuCard(children: [Text('Content')])),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisSize, equals(MainAxisSize.min));
    });

    testWidgets('uses CrossAxisAlignment.start for children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppMenuCard(children: [Text('Content')])),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
    });

    testWidgets('uses default vertical padding when not specified', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppMenuCard(children: [Text('Content')])),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(
        container.padding,
        equals(const EdgeInsets.symmetric(vertical: 5)),
      );
    });

    testWidgets('uses default border radius of 4 when not specified', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppMenuCard(children: [Text('Content')])),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, equals(BorderRadius.circular(4)));
    });

    test('can be const constructed', () {
      const card = AppMenuCard(children: []);
      expect(card.children, isEmpty);
    });

    test('stores all provided properties', () {
      final borderRadius = BorderRadius.circular(8);
      const bgColor = Colors.green;
      final border = Border.all(color: Colors.orange);
      const shadows = [BoxShadow(color: Colors.grey)];
      const padding = EdgeInsets.all(10);

      final card = AppMenuCard(
        borderRadius: borderRadius,
        bgColor: bgColor,
        border: border,
        shadows: shadows,
        padding: padding,
        children: const [Text('Test')],
      );

      expect(card.borderRadius, equals(borderRadius));
      expect(card.bgColor, equals(bgColor));
      expect(card.border, equals(border));
      expect(card.shadows, equals(shadows));
      expect(card.padding, equals(padding));
      expect(card.children.length, equals(1));
    });
  });
}
