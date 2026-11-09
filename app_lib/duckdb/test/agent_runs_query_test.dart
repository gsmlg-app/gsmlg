import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter_test/flutter_test.dart';

AgentEventEntry _event(String id, String runId, int us, {bool error = false}) =>
    AgentEventEntry(
      id: id,
      timestampUs: PlatformInt64Util.from(us),
      eventType: 'tool_call_completed',
      conversationId: 'conv-$runId',
      runId: runId,
      level: error ? 'SEVERE' : 'INFO',
      isError: error,
      summary: 'event $id',
    );

void main() {
  final db = AppDuckDb.instance;

  setUp(() async {
    await db.open(inMemory: true);
    await db.ensureLogSchemas();
    await db.batchAppendAgentEvents([
      for (var i = 0; i < 60; i++) _event('a$i', 'run-a', 1000 + i),
      _event('b0', 'run-b', 500, error: true),
    ]);
  });

  tearDown(() => db.close());

  test('pages over distinct runs with full run event counts', () async {
    expect(await db.countAgentRuns(), 2);
    final runs = await db.queryAgentRuns(limit: 50);
    expect(runs.map((r) => r['run_id']), ['run-a', 'run-b']);
    final a = runs.first;
    expect(a['event_count'], 60);
    expect(a['conversation_id'], 'conv-run-a');
    expect(a['last_us'], 1059);
    expect(a['last_summary'], 'event a59');
    expect(a['has_error'], isFalse);
    expect(runs.last['has_error'], isTrue);

    final page2 = await db.queryAgentRuns(limit: 1, offset: 1);
    expect(page2.map((r) => r['run_id']), ['run-b']);
  });

  test('filter selects runs but counts all of their events', () async {
    const filter = LogFilter(keyword: 'event a7');
    expect(await db.countAgentRuns(filter: filter), 1);
    final runs = await db.queryAgentRuns(filter: filter);
    expect(runs.single['run_id'], 'run-a');
    expect(runs.single['event_count'], 60);
  });
}
