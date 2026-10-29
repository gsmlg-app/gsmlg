import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/settings/settings_routes.dart';
import 'package:gsmlg/screens/settings/terminal/terminal_preferences_screen.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_unsupported_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

void main() {
  testWidgets('unsupported terminal route renders without terminal providers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: const TerminalScreen(),
      ),
    );
    await tester.pump();
    expect(
      find.text(
        'Terminal is available in the Android, iOS, macOS, Linux, and Windows apps.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<AppAdaptiveScaffold>(find.byType(AppAdaptiveScaffold))
          .selectedIndex,
      2,
    );
    expect(find.text('Open Local Shell'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('terminal settings routes follow native platform availability', () {
    final names = settingsRoutes().routes.whereType<GoRoute>().map(
      (route) => route.name,
    );
    expect(names.contains(TerminalPreferencesScreen.name), !kIsWeb);
  });

  if (kIsWeb) {
    testWidgets('browser Toolbox hides the native terminal tile', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: const ToolboxScreen(),
        ),
      );
      await tester.pump();
      expect(find.text('Terminal'), findsNothing);
    });
  }
}
