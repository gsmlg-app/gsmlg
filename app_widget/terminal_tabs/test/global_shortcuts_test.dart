import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shortcut/global_shortcuts.dart';
import 'package:terminal_tabs/src/shortcut/intents.dart';

void main() {
  group('GlobalShortcuts', () {
    testWidgets('is a StatelessWidget', (tester) async {
      expect(const GlobalShortcuts(child: SizedBox()), isA<StatelessWidget>());
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GlobalShortcuts(child: Text('Test Child'))),
      );

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('wraps child in Shortcuts widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GlobalShortcuts(child: Text('Test Child'))),
      );

      expect(find.byType(Shortcuts), findsWidgets);
    });

    testWidgets('maps openNewWindow shortcut to NewWindowIntent', (
      tester,
    ) async {
      Intent? receivedIntent;

      await tester.pumpWidget(
        MaterialApp(
          home: Actions(
            actions: {
              NewWindowIntent: CallbackAction<NewWindowIntent>(
                onInvoke: (intent) {
                  receivedIntent = intent;
                  return null;
                },
              ),
            },
            child: GlobalShortcuts(
              child: Focus(
                autofocus: true,
                child: Builder(builder: (context) => const Text('Test')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate meta+N (works on macOS)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);

      await tester.pumpAndSettle();

      expect(receivedIntent, isA<NewWindowIntent>());
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('maps toggleFullscreen shortcut to ToggleFullscreenIntent', (
      tester,
    ) async {
      Intent? receivedIntent;

      await tester.pumpWidget(
        MaterialApp(
          home: Actions(
            actions: {
              ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
                onInvoke: (intent) {
                  receivedIntent = intent;
                  return null;
                },
              ),
            },
            child: GlobalShortcuts(
              child: Focus(
                autofocus: true,
                child: Builder(builder: (context) => const Text('Test')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate F11 keypress
      await tester.sendKeyDownEvent(LogicalKeyboardKey.f11);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.f11);

      await tester.pumpAndSettle();

      expect(receivedIntent, isA<ToggleFullscreenIntent>());
    });

    group('shortcut count', () {
      testWidgets('has expected shortcuts registered', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: GlobalShortcuts(child: Text('Test'))),
        );

        // Find the Shortcuts widget and check its mapping
        final shortcutsWidget = tester.widget<Shortcuts>(
          find
              .ancestor(of: find.text('Test'), matching: find.byType(Shortcuts))
              .first,
        );

        expect(shortcutsWidget.shortcuts.length, 2);
      });
    });
  });
}
