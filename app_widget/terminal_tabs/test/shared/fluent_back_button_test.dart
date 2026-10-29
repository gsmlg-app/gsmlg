import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shared/fluent_back_button.dart';

void main() {
  group('FluentBackButton', () {
    testWidgets('renders as a tappable button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FluentBackButton())),
      );

      expect(find.byType(FluentBackButton), findsOneWidget);
    });

    testWidgets('has back arrow icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FluentBackButton())),
      );

      // Find Icon descendants within FluentBackButton
      final iconFinder = find.descendant(
        of: find.byType(FluentBackButton),
        matching: find.byType(Icon),
      );
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('icon has size 14.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FluentBackButton())),
      );

      final iconFinder = find.descendant(
        of: find.byType(FluentBackButton),
        matching: find.byType(Icon),
      );
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, equals(14.0));
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var wasPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FluentBackButton(onPressed: () => wasPressed = true),
          ),
        ),
      );

      await tester.tap(find.byType(FluentBackButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('calls Navigator.maybePop when no onPressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const Scaffold(body: FluentBackButton()),
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              );
            },
          ),
        ),
      );

      // Navigate to a page with FluentBackButton
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Verify we're on the new page
      expect(find.byType(FluentBackButton), findsOneWidget);

      // Tap the back button
      await tester.tap(find.byType(FluentBackButton));
      await tester.pumpAndSettle();

      // Verify navigation happened (we're back to first page)
      expect(find.text('Go'), findsOneWidget);
    });

    test('can be const constructed', () {
      const button = FluentBackButton();
      expect(button, isA<FluentBackButton>());
      expect(button.onPressed, isNull);
    });

    test('stores onPressed callback', () {
      callback() {}
      final button = FluentBackButton(onPressed: callback);
      expect(button.onPressed, equals(callback));
    });

    test('can have a key', () {
      final key = UniqueKey();
      final button = FluentBackButton(key: key);
      expect(button.key, equals(key));
    });

    testWidgets('is a StatelessWidget', (tester) async {
      const button = FluentBackButton();
      expect(button, isA<StatelessWidget>());
    });

    testWidgets('can be used in AppBar leading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: FluentBackButton(),
            ),
            body: Text('Content'),
          ),
        ),
      );

      expect(find.byType(FluentBackButton), findsOneWidget);
    });
  });
}
