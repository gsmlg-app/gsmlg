import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/log_center_screen.dart';

void main() {
  testWidgets('LogCenterScreen shows title, tabs and a viewer per tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: const LogCenterScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Log Center'), findsOneWidget);
    expect(find.text('All Logs'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(
      tester.widget<DuckDbLogViewer>(find.byType(DuckDbLogViewer)).tableOrView,
      'v_all_logs',
    );

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<DuckDbLogViewer>(find.byType(DuckDbLogViewer)).tableOrView,
      'system_logs',
    );
  });
}
