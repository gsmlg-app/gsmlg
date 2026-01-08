import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_components/app_components.dart';

void main() {
  group('GlassContainer', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GlassContainer(child: Text('Test'))),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('applies default blur and opacity', (
      WidgetTester tester,
    ) async {
      const container = GlassContainer(child: SizedBox());
      expect(container.blur, 5.0);
      expect(container.opacity, 0.5);
    });
  });

  group('AppGridTile', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppGridTile(child: const Text('Tile Content'))),
        ),
      );

      expect(find.text('Tile Content'), findsOneWidget);
    });

    testWidgets('calls onTap callback', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppGridTile(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, isTrue);
    });
  });

  group('NeonButton', () {
    testWidgets('renders text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonButton(text: 'Neon')),
        ),
      );

      expect(find.text('Neon'), findsOneWidget);
    });

    testWidgets('calls onPressed callback', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'Press', onPressed: () => pressed = true),
          ),
        ),
      );

      await tester.tap(find.text('Press'));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });

  group('LifecycleManager', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LifecycleManager(child: Text('Managed Content')),
        ),
      );

      expect(find.text('Managed Content'), findsOneWidget);
    });
  });
}
