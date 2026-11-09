import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves run summary rows as `queryAgentRuns` would for 60 events in
/// `run-a` plus one event in `run-b`.
class _FakeDuckDb implements AppDuckDb {
  LogFilter? lastFilter;

  @override
  Future<int> countAgentRuns({LogFilter filter = const LogFilter()}) async => 2;

  @override
  Future<List<Map<String, dynamic>>> queryAgentRuns({
    LogFilter filter = const LogFilter(),
    int limit = 50,
    int offset = 0,
  }) async {
    lastFilter = filter;
    return [
      {
        'run_id': 'run-a',
        'conversation_id': 'conv-a',
        'started_us': 1000,
        'last_us': 1059,
        'event_count': 60,
        'has_error': false,
        'last_summary': 'run completed',
      },
      {
        'run_id': 'run-b',
        'conversation_id': 'conv-b',
        'started_us': 500,
        'last_us': 500,
        'event_count': 1,
        'has_error': true,
        'last_summary': 'run failed: boom',
      },
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Agent viewer pages over runs: one card per run, full count', (
    tester,
  ) async {
    final fake = _FakeDuckDb();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(
          body: DuckDbLogViewer(
            tableOrView: 'agent_events',
            duckDb: fake,
            pageQuery: AgentRunGroupList.pageQuery(fake),
            itemsBuilder: (context, items) =>
                AgentRunGroupList(items: items, duckDb: fake),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('Conversation conv-a'), findsOneWidget);
    expect(find.textContaining('60 events'), findsOneWidget);
    expect(find.textContaining('run completed'), findsOneWidget);
    expect(find.textContaining('1 event'), findsOneWidget);
    expect(find.text('2 records'), findsOneWidget);
  });

  test('runItem takes timestamp and summary from the latest event', () {
    final item = AgentRunGroupList.runItem({
      'run_id': 'r',
      'started_us': 1,
      'last_us': 99,
      'last_summary': 'latest',
      'has_error': true,
    });
    expect(item.id, 'r');
    expect(item.timestamp.microsecondsSinceEpoch, 99);
    expect(item.message, 'latest');
    expect(item.level, LogLevel.error);
  });
}
