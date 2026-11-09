import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/log_center_screen.dart';

class _FakeDuckDb implements AppDuckDb {
  final deleteCalls = <({int days, List<String> tables})>[];

  @override
  Future<List<LogRecordItem>> queryLogs({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
    int limit = 50,
    int offset = 0,
  }) async => const [];

  @override
  Future<int> countLogs({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
  }) async => 0;

  @override
  Future<List<String>> listCategories() async => const ['llm'];

  @override
  Future<void> deleteOlderThan({
    required int days,
    required List<String> tables,
  }) async {
    deleteCalls.add((days: days, tables: tables));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(AppDuckDb duckDb) => MaterialApp(
  localizationsDelegates: AppLocale.localizationsDelegates,
  supportedLocales: AppLocale.supportedLocales,
  home: LogCenterScreen(duckDb: duckDb),
);

void main() {
  testWidgets('LogCenterScreen shows the four tabs and a viewer per tab', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FakeDuckDb()));
    await tester.pumpAndSettle();

    expect(find.text('Log Center'), findsOneWidget);
    for (final tab in ['All Logs', 'System', 'API', 'Agent']) {
      expect(find.widgetWithText(Tab, tab), findsOneWidget);
    }
    expect(
      tester.widget<DuckDbLogViewer>(find.byType(DuckDbLogViewer)).tableOrView,
      'v_all_logs',
    );

    await tester.tap(find.widgetWithText(Tab, 'API'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<DuckDbLogViewer>(find.byType(DuckDbLogViewer)).tableOrView,
      'api_exchanges',
    );

    await tester.tap(find.widgetWithText(Tab, 'Agent'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<DuckDbLogViewer>(find.byType(DuckDbLogViewer)).tableOrView,
      'agent_events',
    );
  });

  testWidgets('delete dialog rejects 0 and deletes the API table by age', (
    tester,
  ) async {
    final fake = _FakeDuckDb();
    await tester.pumpWidget(_app(fake));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, 'API'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Log Maintenance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Old Data…'));
    await tester.pumpAndSettle();

    final daysField = find.byKey(const Key('logCenterPruneDays'));
    await tester.enterText(daysField, '0');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a whole number of days, 1 or more'),
      findsOneWidget,
    );
    expect(fake.deleteCalls, isEmpty);

    await tester.enterText(daysField, '3');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(fake.deleteCalls, hasLength(1));
    expect(fake.deleteCalls.single.days, 3);
    expect(fake.deleteCalls.single.tables, ['api_exchanges']);
  });
}
