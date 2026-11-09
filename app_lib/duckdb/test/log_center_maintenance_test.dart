import 'dart:convert';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter_test/flutter_test.dart';

ApiExchangeEntry _api(
  String id,
  int ts,
  String category, {
  int? status = 200,
  bool hasError = false,
  String? conversationId,
}) =>
    ApiExchangeEntry(
      id: id,
      timestampUs: PlatformInt64Util.from(ts),
      requestId: 'r-$id',
      recordType: 'response',
      category: category,
      method: 'POST',
      host: 'h.com',
      path: '/p',
      status: status,
      hasError: hasError,
      aborted: false,
      conversationId: conversationId,
      recordJson: '{"id":"$id"}',
    );

void main() {
  final db = AppDuckDb.instance;
  final now = DateTime.now().microsecondsSinceEpoch;
  const day = 86400 * 1000000;

  setUp(() async {
    await db.open(inMemory: true);
    await db.ensureLogSchemas();
  });
  tearDown(() => db.close());

  test('deleteOlderThan removes old rows in every table, keeps new', () async {
    await db.batchAppendSystemLogs([
      SystemLogEntry(
        id: 's-old',
        timestampUs: PlatformInt64Util.from(now - 8 * day),
        level: 'INFO',
        loggerName: 'x',
        message: 'm',
      ),
      SystemLogEntry(
        id: 's-new',
        timestampUs: PlatformInt64Util.from(now - day),
        level: 'INFO',
        loggerName: 'x',
        message: 'm',
      ),
    ]);
    await db.batchAppendApiExchanges([
      _api('a-old', now - 8 * day, 'c'),
      _api('a-new', now - day, 'c'),
    ]);
    await db.batchAppendAgentEvents([
      for (final e in [('g-old', 8), ('g-new', 1)])
        AgentEventEntry(
          id: e.$1,
          timestampUs: PlatformInt64Util.from(now - e.$2 * day),
          eventType: 'x',
          level: 'INFO',
          isError: false,
          summary: 's',
        ),
    ]);
    await db.batchAppendUsageEvents([
      for (final e in [('u-old', 8), ('u-new', 1)])
        UsageEventEntry(
          id: e.$1,
          timestampUs: PlatformInt64Util.from(now - e.$2 * day),
          sessionId: 's',
          eventType: 'x',
        ),
    ]);

    await db.deleteOlderThan(days: 7, tables: LogTables.all);

    for (final (table, keep) in [
      ('system_logs', 's-new'),
      ('api_exchanges', 'a-new'),
      ('agent_events', 'g-new'),
      ('usage_events', 'u-new'),
    ]) {
      final rows = await db.queryLogs(tableOrView: table);
      expect(rows.map((r) => r.id), [keep], reason: table);
    }
  });

  test('deleteOlderThan rejects unknown tables and days < 1', () async {
    expect(
      () => db.deleteOlderThan(days: 7, tables: ['users']),
      throwsArgumentError,
    );
    expect(
      () => db.deleteOlderThan(days: 0, tables: ['system_logs']),
      throwsArgumentError,
    );
  });

  test('exportJsonl api_exchanges returns record_json in time order', () async {
    await db.batchAppendApiExchanges([
      _api('2', 20, 'llm:x'),
      _api('1', 10, 'llm:x'),
      _api('3', 30, 'other'),
    ]);
    final out = await db.exportJsonl(
      table: 'api_exchanges',
      filter: const LogFilter(category: 'llm:x'),
    );
    expect(out, '{"id":"1"}\n{"id":"2"}');
    expect(await db.exportJsonl(table: 'usage_events'), '');
    expect(
      () => db.exportJsonl(table: 'users'),
      throwsArgumentError,
    );
  });

  test('exportJsonl agent_events emits row JSON per line', () async {
    await db.batchAppendAgentEvents([
      for (final i in [2, 1])
        AgentEventEntry(
          id: 'g$i',
          timestampUs: PlatformInt64Util.from(i),
          eventType: 'x',
          level: 'INFO',
          isError: false,
          summary: 's$i',
        ),
    ]);
    final lines = (await db.exportJsonl(table: 'agent_events')).split('\n');
    expect(lines.map((l) => (jsonDecode(l) as Map)['id']), ['g1', 'g2']);
  });

  test('errorsOnly, category and conversation filters; listCategories',
      () async {
    await db.batchAppendApiExchanges([
      _api('ok', 1, 'b', conversationId: "c'1"),
      _api('s500', 2, 'a', status: 500),
      _api('err', 3, 'a', status: null, hasError: true),
    ]);
    final errs = await db.queryLogs(
      tableOrView: 'api_exchanges',
      filter: const LogFilter(errorsOnly: true),
    );
    expect(errs.map((r) => r.id).toSet(), {'s500', 'err'});
    expect(
      await db.countLogs(
        tableOrView: 'api_exchanges',
        filter: const LogFilter(conversationId: "c'1"),
      ),
      1,
    );
    expect(await db.listCategories(), ['a', 'b']);
    final item = (await db.queryLogs(
      tableOrView: 'api_exchanges',
      filter: const LogFilter(keyword: 'ok'),
    ))
        .single;
    expect(item.message, 'POST h.com/p');
    expect(item.status, '200');
    expect(item.category, 'b');
  });
}
