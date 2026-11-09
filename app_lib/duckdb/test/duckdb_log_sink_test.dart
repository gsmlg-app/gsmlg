import 'dart:convert';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';

ApiExchangeRecord _api(int i, {List<int>? body}) => ApiExchangeRecord(
      ts: DateTime.utc(2026, 3, 12, 10, 0, i),
      requestId: 'req-$i',
      recordType: 'exchange',
      durationMs: 12,
      request: HttpMessageCapture.request(
        method: 'POST',
        url: Uri.parse('https://api.example.com/v1/chat?x=1'),
        headers: {
          'content-type': ['application/json'],
        },
        bodyBytes: body ?? utf8.encode('{"i":$i}'),
      ),
      category: 'llm',
      apiType: 'chat',
      context: const LogContext(conversationId: 'c1', runId: 'r1', turn: 2),
      error: i == 1 ? (type: 'E', message: 'boom', stackTrace: null) : null,
    );

Future<List<Map<String, dynamic>>> _rows(AppDuckDb db, String sql) async =>
    (jsonDecode(await db.queryJson(sql)) as List).cast<Map<String, dynamic>>();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = AppDuckDb.instance;

  setUp(() async {
    await db.open(inMemory: true);
    await db.ensureLogSchemas();
  });

  tearDown(() async {
    if (await db.isOpen) await db.close();
  });

  test('persists api, agent and usage records', () async {
    final sink = DuckDbLogSink(
      duckDb: db,
      flushInterval: const Duration(seconds: 10),
    );
    final apis = [for (var i = 0; i < 3; i++) _api(i)];
    apis.forEach(sink.writeApi);
    sink.writeAgent(
      AgentLogEvent(
        ts: DateTime.utc(2026, 3, 12),
        eventType: 'tool_call',
        context: const LogContext(conversationId: 'c1', runId: 'r1'),
        toolName: 'search',
        payload: const {'a': 1},
      ),
    );
    sink.writeAgent(
      AgentLogEvent(ts: DateTime.utc(2026, 3, 12), eventType: 'run_start'),
    );
    sink.writeUsage(
      UsageEvent(
        ts: DateTime.utc(2026, 3, 12),
        sessionId: 's1',
        eventType: 'screen_view',
        screenName: 'Home',
        durationMs: 5,
        payload: const {'k': 'v'},
      ),
    );
    sink.writeUsage(
      UsageEvent(
        ts: DateTime.utc(2026, 3, 12),
        sessionId: 's1',
        eventType: 'session_start',
      ),
    );
    await sink.flush();

    final api =
        await _rows(db, 'SELECT * FROM api_exchanges ORDER BY request_id');
    expect(api.length, 3);
    expect(api.map((r) => jsonDecode(r['record_json'] as String)),
        apis.map((r) => r.toJson()));
    expect(api[0]['method'], 'POST');
    expect(api[0]['host'], 'api.example.com');
    expect(api[0]['path'], '/v1/chat?x=1');
    expect(api[1]['has_error'], true);
    expect(api[0]['has_error'], false);
    expect(api[0]['conversation_id'], 'c1');
    expect(api[0]['timestamp_us'],
        DateTime.utc(2026, 3, 12, 10).microsecondsSinceEpoch);

    final agent =
        await _rows(db, 'SELECT * FROM agent_events ORDER BY event_type');
    expect(agent.length, 2);
    expect(agent.last['tool_name'], 'search');
    expect(jsonDecode(agent.last['payload_json'] as String), {'a': 1});
    expect(agent.first['payload_json'], isNull);

    final usage =
        await _rows(db, 'SELECT * FROM usage_events ORDER BY event_type');
    expect(usage.length, 2);
    expect(usage.first['screen_name'], 'Home');
    expect(jsonDecode(usage.first['payload_json'] as String), {'k': 'v'});
    await sink.close();
  });

  test('stores a 5 MB json request body intact', () async {
    final sink = DuckDbLogSink(duckDb: db);
    final big = utf8.encode(jsonEncode({'data': 'x' * (5 * 1024 * 1024)}));
    final rec = _api(0, body: big);
    sink.writeApi(rec);
    await sink.flush();
    final rows = await _rows(db, 'SELECT record_json FROM api_exchanges');
    expect(rows.single['record_json'], rec.toJsonLine());
    await sink.close();
  });

  test('write and flush do not throw when the store is closed', () async {
    final sink = DuckDbLogSink(duckDb: db);
    await db.close();
    sink.writeApi(_api(0));
    sink.writeAgent(AgentLogEvent(ts: DateTime.utc(2026), eventType: 'x'));
    sink.writeUsage(
      UsageEvent(ts: DateTime.utc(2026), sessionId: 's', eventType: 'x'),
    );
    await sink.flush();
    await sink.close();
  });

  test('streamed response rows carry method, host and path', () async {
    final sink = DuckDbLogSink(
      duckDb: db,
      flushInterval: const Duration(seconds: 10),
    );
    final response = ApiExchangeRecord(
      ts: DateTime.utc(2026, 3, 12, 10, 0, 1),
      requestId: 'req-s',
      recordType: 'response',
      method: 'POST',
      host: 'api.example.com',
      path: '/v1/chat',
      response: HttpMessageCapture.response(
        status: 200,
        headers: const {},
        bodyBytes: utf8.encode('data: x'),
      ),
    );
    sink.writeApi(response);
    await sink.flush();

    final row = (await _rows(db, 'SELECT * FROM api_exchanges')).single;
    expect(row['method'], 'POST');
    expect(row['host'], 'api.example.com');
    expect(row['path'], '/v1/chat');
    expect(
      jsonDecode(row['record_json'] as String),
      isNot(contains('request')),
    );
    await sink.close();
  });
}
