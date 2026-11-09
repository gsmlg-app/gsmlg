import 'dart:convert';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDuckDb', () {
    final db = AppDuckDb.instance;

    setUp(() async {
      await db.open(inMemory: true);
      await db.ensureLogSchemas();
    });

    tearDown(() async {
      if (await db.isOpen) {
        await db.close();
      }
    });

    test('open and close in-memory database', () async {
      expect(await db.isOpen, isTrue);
      await db.close();
      expect(await db.isOpen, isFalse);
    });

    test('execute SQL and query JSON', () async {
      final rows = await db.execute(
        "CREATE TABLE test_table (id INT, name VARCHAR); INSERT INTO test_table VALUES (1, 'Alice'), (2, 'Bob');",
      );
      expect(rows, greaterThanOrEqualTo(0));

      final jsonStr = await db.queryJson(
        'SELECT * FROM test_table ORDER BY id ASC;',
      );
      final list = jsonDecode(jsonStr) as List<dynamic>;
      expect(list.length, equals(2));
      expect(list[0]['id'], equals(1));
      expect(list[0]['name'], equals('Alice'));
      expect(list[1]['id'], equals(2));
      expect(list[1]['name'], equals('Bob'));
    });

    test('ensureLogSchemas drops legacy dns/dhcp/app_logs tables', () async {
      await db.execute('CREATE TABLE dns_logs (id VARCHAR);');
      await db.execute('CREATE TABLE app_logs (id VARCHAR);');
      await db.ensureLogSchemas();
      final rows = jsonDecode(
        await db.queryJson(
          "SELECT count(*) AS n FROM information_schema.tables WHERE table_name IN ('dns_logs','dhcp_logs','app_logs')",
        ),
      ) as List<dynamic>;
      expect(rows.first['n'], equals(0));
    });

    test('system logs: batch append and query', () async {
      await db.batchAppendSystemLogs([
        SystemLogEntry(
          id: 'sys-1',
          timestampUs: PlatformInt64Util.from(1000),
          level: 'INFO',
          loggerName: 'AppBloc',
          message: 'App initialized',
          isolateId: 'main',
          metadata: '{"key":"val"}',
        ),
      ]);
      final sysLogs = await db.querySystemLogs(limit: 10);
      expect(sysLogs.length, equals(1));
      expect(sysLogs.first.message, equals('App initialized'));
    });

    test('api_exchanges: append and read back', () async {
      final n = await db.batchAppendApiExchanges([
        ApiExchangeEntry(
          id: 'api-1',
          timestampUs: PlatformInt64Util.from(2000),
          requestId: 'req-1',
          recordType: 'response',
          category: 'chat',
          apiType: 'openai',
          method: 'POST',
          host: 'api.example.com',
          path: '/v1/chat',
          status: 200,
          durationMs: 42,
          hasError: false,
          aborted: false,
          conversationId: 'c1',
          runId: 'r1',
          turn: 1,
          toolCallId: null,
          recordJson: '{"a":1}',
        ),
      ]);
      expect(n, equals(1));
      final rows = jsonDecode(
        await db.queryJson('SELECT * FROM api_exchanges'),
      ) as List<dynamic>;
      expect(rows.length, equals(1));
      expect(rows.first['request_id'], equals('req-1'));
      expect(rows.first['status'], equals(200));
      expect(rows.first['has_error'], isFalse);
      expect(rows.first['tool_call_id'], isNull);
      expect(rows.first['record_json'], equals('{"a":1}'));
    });

    test('agent_events: append and read back', () async {
      final n = await db.batchAppendAgentEvents([
        AgentEventEntry(
          id: 'ag-1',
          timestampUs: PlatformInt64Util.from(3000),
          eventType: 'tool_call',
          conversationId: 'c1',
          runId: 'r1',
          turn: 2,
          toolName: 'search',
          level: 'INFO',
          isError: false,
          durationMs: 7,
          summary: 'called search',
          payloadJson: '{"q":"x"}',
        ),
      ]);
      expect(n, equals(1));
      final rows = jsonDecode(
        await db.queryJson('SELECT * FROM agent_events'),
      ) as List<dynamic>;
      expect(rows.first['event_type'], equals('tool_call'));
      expect(rows.first['tool_name'], equals('search'));
      expect(rows.first['is_error'], isFalse);
      expect(rows.first['payload_json'], equals('{"q":"x"}'));
    });

    test('usage_events: append and read back', () async {
      final n = await db.batchAppendUsageEvents([
        UsageEventEntry(
          id: 'u-1',
          timestampUs: PlatformInt64Util.from(4000),
          sessionId: 's1',
          eventType: 'screen_view',
          screenName: 'Home',
          durationMs: PlatformInt64Util.from(1500),
        ),
      ]);
      expect(n, equals(1));
      final rows = jsonDecode(
        await db.queryJson('SELECT * FROM usage_events'),
      ) as List<dynamic>;
      expect(rows.first['session_id'], equals('s1'));
      expect(rows.first['screen_name'], equals('Home'));
      expect(rows.first['duration_ms'], equals(1500));
    });

    test('v_all_logs projects api error as SEVERE', () async {
      await db.batchAppendApiExchanges([
        ApiExchangeEntry(
          id: 'api-ok',
          timestampUs: PlatformInt64Util.from(10),
          requestId: 'r-ok',
          recordType: 'response',
          category: 'chat',
          method: 'GET',
          host: 'h.com',
          path: '/ok',
          status: 200,
          hasError: false,
          aborted: false,
          recordJson: '{}',
        ),
        ApiExchangeEntry(
          id: 'api-500',
          timestampUs: PlatformInt64Util.from(20),
          requestId: 'r-500',
          recordType: 'response',
          category: 'chat',
          method: 'GET',
          host: 'h.com',
          path: '/bad',
          status: 500,
          hasError: false,
          aborted: false,
          recordJson: '{}',
        ),
        ApiExchangeEntry(
          id: 'api-err',
          timestampUs: PlatformInt64Util.from(30),
          requestId: 'r-err',
          recordType: 'error',
          category: 'chat',
          method: 'GET',
          host: 'h.com',
          path: '/err',
          hasError: true,
          aborted: false,
          recordJson: '{}',
        ),
      ]);
      await db.batchAppendAgentEvents([
        AgentEventEntry(
          id: 'ag-v',
          timestampUs: PlatformInt64Util.from(40),
          eventType: 'x',
          level: 'INFO',
          isError: false,
          summary: 'agent summary',
        ),
      ]);
      await db.batchAppendUsageEvents([
        UsageEventEntry(
          id: 'u-v',
          timestampUs: PlatformInt64Util.from(50),
          sessionId: 's',
          eventType: 'e',
        ),
      ]);
      final rows = jsonDecode(
        await db.queryJson(
          'SELECT id, log_type, level, message FROM v_all_logs ORDER BY timestamp_us',
        ),
      ) as List<dynamic>;
      expect(
          rows.map((r) => r['id']), ['api-ok', 'api-500', 'api-err', 'ag-v']);
      expect(rows[0]['level'], 'INFO');
      expect(rows[0]['log_type'], 'api');
      expect(rows[0]['message'], 'GET h.com/ok → 200');
      expect(rows[1]['level'], 'SEVERE');
      expect(rows[2]['level'], 'SEVERE');
      expect(rows[2]['message'], 'GET h.com/err → ERR');
      expect(rows[3]['log_type'], 'agent');
      expect(rows[3]['message'], 'agent summary');
    });
  });
}
