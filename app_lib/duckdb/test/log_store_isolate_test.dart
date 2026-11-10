import 'dart:isolate';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_logging/app_logging.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';

ApiExchangeRecord _api({
  DateTime? ts,
  String requestId = 'req-1',
  String recordType = 'exchange',
  String category = 'github',
  String? runId,
}) =>
    ApiExchangeRecord(
      ts: ts ?? DateTime.now(),
      requestId: requestId,
      recordType: recordType,
      durationMs: 12,
      request: recordType == 'response'
          ? null
          : HttpMessageCapture.request(
              method: 'GET',
              url: Uri.parse('https://api.github.com/user'),
              headers: const {},
              bodyBytes: const [],
            ),
      method: 'GET',
      host: 'api.github.com',
      path: '/user',
      response: HttpMessageCapture.response(
        status: 200,
        headers: const {},
        bodyBytes: const [],
      ),
      category: category,
      context: runId == null ? null : LogContext(runId: runId),
    );

void main() {
  late IsolateHub hub;
  late LogStoreClient store;
  late PortLogSink sink;
  late SendPort ingest;

  setUpAll(() async {
    hub = IsolateHub();
    await hub.start();
    await hub.registerService(
      const ChildSpec(
        name: 'logstore',
        entryPoint: logStoreEntryPoint,
        config: {'dbPath': ':memory:'},
      ),
    );
    store = LogStoreClient(hub);
    ingest = await store.ingestPort();
    sink = PortLogSink(ingest);
  });

  tearDownAll(() => hub.stop());

  setUp(() async {
    for (final table in LogTables.all) {
      await store.clearLogsTable(table: table);
    }
  });

  test('api record written via PortLogSink is stored after flush', () async {
    final rec = _api();
    sink.writeApi(rec);
    await store.flush();

    expect(await store.countLogs(tableOrView: 'api_exchanges'), 1);
    final items = await store.queryLogs(tableOrView: 'api_exchanges');
    expect(items, hasLength(1));
    final item = items.single;
    expect(item.logType, 'api');
    expect(item.category, 'github');
    expect(item.message, 'GET api.github.com/user');
    expect(item.rawFields['request_id'], 'req-1');
    expect(item.rawFields['record_json'], rec.toJsonLine());
    expect(
      item.timestamp.microsecondsSinceEpoch,
      rec.ts.microsecondsSinceEpoch,
    );
  });

  test('response record keeps method/host/path index columns', () async {
    sink.writeApi(_api(recordType: 'response'));
    await store.flush();
    final row =
        (await store.queryLogs(tableOrView: 'api_exchanges')).single.rawFields;
    expect(row['method'], 'GET');
    expect(row['host'], 'api.github.com');
    expect(row['path'], '/user');
  });

  test('agent, usage and system records are stored', () async {
    sink.writeAgent(
      AgentLogEvent(
        ts: DateTime.now(),
        eventType: 'run_start',
        context: const LogContext(conversationId: 'c1', runId: 'run-1'),
        summary: 'started',
        payload: const {'k': 'v'},
      ),
    );
    sink.writeUsage(
      UsageEvent(
        ts: DateTime.now(),
        sessionId: 's1',
        eventType: 'screen_view',
        screenName: 'Home',
      ),
    );
    final now = DateTime.now().microsecondsSinceEpoch;
    ingest.send({
      'k': 'system',
      'r': SerializableLogRecord(
        level: 800,
        levelName: 'INFO',
        message: 'hello',
        loggerName: 'test',
        time: now,
        isolateId: 'main',
      ).toMap(),
    });
    // IsolateLogBridge sends bare SerializableLogRecord maps.
    ingest.send(
      SerializableLogRecord(
        level: 1000,
        levelName: 'SEVERE',
        message: 'bridged',
        loggerName: 'worker',
        time: now,
        isolateId: 'agent:1',
      ).toMap(),
    );
    await store.flush();

    expect(await store.countLogs(tableOrView: 'agent_events'), 1);
    expect(await store.countLogs(tableOrView: 'usage_events'), 1);
    expect(await store.countLogs(tableOrView: 'system_logs'), 2);
    final agent = (await store.queryLogs(tableOrView: 'agent_events')).single;
    expect(agent.logType, 'agent');
    expect(agent.message, 'started');
    final system = await store.queryLogs(
      tableOrView: 'system_logs',
      filter: const LogFilter(level: 'ERROR'),
    );
    expect(system.single.message, 'bridged');
    expect(system.single.clientAddress, 'agent:1');
    // v_all_logs unions system, api and agent rows (not usage).
    expect(await store.countLogs(tableOrView: 'v_all_logs'), 3);
  });

  test('malformed ingest messages are dropped; worker keeps running', () async {
    ingest
      ..send('garbage')
      ..send({'k': 'api', 'r': 'not a map'})
      ..send({
        'k': 'agent',
        'r': {'ts': 'bad'},
      })
      ..send({'k': 'nope', 'r': <String, Object?>{}});
    sink.writeApi(_api());
    await store.flush();
    expect(await store.countLogs(tableOrView: 'api_exchanges'), 1);
  });

  test('deleteOlderThan works through the client', () async {
    sink
      ..writeApi(
        _api(
          requestId: 'old',
          ts: DateTime.now().subtract(const Duration(days: 10)),
        ),
      )
      ..writeApi(_api(requestId: 'new'));
    await store.flush();
    expect(await store.countLogs(tableOrView: 'api_exchanges'), 2);

    await store.deleteOlderThan(days: 7, tables: ['api_exchanges']);

    final items = await store.queryLogs(tableOrView: 'api_exchanges');
    expect(items.map((i) => i.rawFields['request_id']), ['new']);
  });

  test('filters, categories, agent runs, export and queryJson', () async {
    sink
      ..writeApi(_api(requestId: 'a', category: 'github'))
      ..writeApi(_api(requestId: 'b', category: 'vultr'))
      ..writeAgent(
        AgentLogEvent(
          ts: DateTime.now(),
          eventType: 'run_end',
          context: const LogContext(conversationId: 'c', runId: 'run-x'),
          summary: 'done',
        ),
      );
    await store.flush();

    expect(await store.listCategories(), ['github', 'vultr']);
    const vultr = LogFilter(category: 'vultr');
    expect(
      await store.countLogs(tableOrView: 'api_exchanges', filter: vultr),
      1,
    );
    final windowed = await store.queryLogs(
      tableOrView: 'api_exchanges',
      filter: LogFilter(
        timeRange: DateTimeRange(
          start: DateTime.now().subtract(const Duration(hours: 1)),
          end: DateTime.now().add(const Duration(hours: 1)),
        ),
      ),
      limit: 1,
    );
    expect(windowed, hasLength(1));

    expect(await store.countAgentRuns(), 1);
    final runs = await store.queryAgentRuns(
      filter: const LogFilter(runId: 'run-x'),
    );
    expect(runs.single['run_id'], 'run-x');
    expect(runs.single['last_summary'], 'done');

    final jsonl =
        await store.exportJsonl(table: 'api_exchanges', filter: vultr);
    expect(jsonl.split('\n'), hasLength(1));
    expect(jsonl, contains('"request_id":"b"'));

    final json = await store.queryJson(
      'SELECT count(*) AS n FROM api_exchanges',
    );
    expect(json, contains('"n":2'));
  });

  test('worker errors surface as TaskException', () async {
    await expectLater(
      hub.call<Object?>('logstore', {'op': 'nope'}),
      throwsA(isA<TaskException>()),
    );
    await expectLater(
      store.clearLogsTable(table: 'not_a_table'),
      throwsA(isA<TaskException>()),
    );
  });

  test('PortLogSink never throws, even for unsendable payloads', () {
    final port = ReceivePort();
    addTearDown(port.close);
    final s = PortLogSink(ingest);
    expect(
      () => s.writeAgent(
        AgentLogEvent(
          ts: DateTime.now(),
          eventType: 'x',
          payload: {'port': port},
        ),
      ),
      returnsNormally,
    );
    final closed = ReceivePort()..close();
    expect(
        () => PortLogSink(closed.sendPort).writeApi(_api()), returnsNormally);
  });

  test('LogFilter wire round-trip', () {
    final filter = LogFilter(
      keyword: 'k',
      timeRange: DateTimeRange(
        start: DateTime.fromMicrosecondsSinceEpoch(1000),
        end: DateTime.fromMicrosecondsSinceEpoch(2000),
      ),
      level: 'ERROR',
      category: 'c',
      conversationId: 'conv',
      runId: 'r',
      sessionId: 's',
      errorsOnly: true,
      method: 'GET',
    );
    final back = LogFilter.fromWire(filter.toWire());
    for (final table in [...LogTables.all, 'v_all_logs']) {
      expect(
        LogQueryBuilder.buildWhereClause(tableOrView: table, filter: back),
        LogQueryBuilder.buildWhereClause(tableOrView: table, filter: filter),
      );
    }
    expect(const LogFilter().toWire(), isEmpty);
    expect(
      LogQueryBuilder.buildWhereClause(
        tableOrView: 'system_logs',
        filter: LogFilter.fromWire(null),
      ),
      '',
    );
  });
}
