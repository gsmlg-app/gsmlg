import 'dart:convert';

import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('streamed request record matches reference key set', () {
    final rec = ApiExchangeRecord(
      ts: DateTime.now(),
      requestId: 'id',
      recordType: 'request',
      request: HttpMessageCapture.request(
        method: 'POST',
        url: Uri.parse('http://localhost:6780/v1/messages?beta=true&key=s'),
        headers: {
          'Authorization': ['Bearer x'],
          'Content-Type': ['application/json'],
        },
        bodyBytes: utf8.encode('{"a":1}'),
      ),
    );
    final j = jsonDecode(rec.toJsonLine()) as Map<String, dynamic>;
    expect(j.keys, containsAll(['ts', 'request_id', 'record_type', 'request']));
    expect(j.containsKey('response'), isFalse);
    expect(j.containsKey('duration_ms'), isFalse);
    final r = j['request'] as Map<String, dynamic>;
    expect(r.keys.toList(), [
      'method',
      'scheme',
      'host',
      'uri',
      'proto',
      'headers',
      'body',
      'body_encoding',
      'body_truncated',
      'content_type',
      'content_length',
    ]);
    expect(r['host'], 'localhost:6780');
    expect(r['uri'], '/v1/messages?beta=true&key=[REDACTED]');
    expect(r['headers']['Authorization'], ['[REDACTED]']);
    expect(r['body'], {'a': 1});
    expect(
      j['ts'],
      matches(r'^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{6}[+-]\d\d:\d\d$'),
    );
  });

  test('response message keys', () {
    final m = HttpMessageCapture.response(
      status: 200,
      headers: {
        'Content-Type': ['text/event-stream']
      },
      bodyBytes: utf8.encode('data: x'),
    ).toJson();
    expect(m.keys.toList(), [
      'status',
      'headers',
      'body',
      'body_encoding',
      'body_truncated',
      'content_type',
    ]);
  });

  test('empty body omits body, keeps encoding none', () {
    final m = HttpMessageCapture.response(
      status: 204,
      headers: {},
      bodyBytes: [],
    ).toJson();
    expect(m.containsKey('body'), isFalse);
    expect(m['body_encoding'], 'none');
  });

  test('timestamp formatter', () {
    final s = formatLogTimestamp(DateTime(2026, 3, 12, 18, 24, 24, 739, 327));
    expect(s, matches(r'^2026-03-12T18:24:24\.739327[+-]\d\d:\d\d$'));
  });

  test('agent and usage toJson', () {
    final a = AgentLogEvent(
      ts: DateTime.now(),
      eventType: 'tool_call',
      context: const LogContext(runId: 'r', turn: 2),
      toolName: 't',
    ).toJson();
    expect(a['run_id'], 'r');
    expect(a['turn'], 2);
    expect(a['tool_name'], 't');
    expect(a['is_error'], false);
    final u = UsageEvent(
      ts: DateTime.now(),
      sessionId: 's',
      eventType: 'screen_view',
      screenName: 'Home',
    ).toJson();
    expect(u['screen_name'], 'Home');
    expect(u['session_id'], 's');
  });

  test('AgentLogEvent default level and full key set', () {
    expect(AgentLogEvent(ts: DateTime.now(), eventType: 'e').level, 'INFO');
    final j = AgentLogEvent(
      ts: DateTime.now(),
      eventType: 'e',
      context: const LogContext(
        conversationId: 'c',
        runId: 'r',
        parentRunId: 'p',
        turn: 1,
        toolCallId: 't',
      ),
      toolName: 'n',
      backend: 'b',
      requestId: 'q',
      durationMs: 5,
      summary: 's',
      payload: const {'a': 1},
    ).toJson();
    expect(j.keys.toSet(), {
      'ts',
      'event_type',
      'conversation_id',
      'run_id',
      'parent_run_id',
      'turn',
      'tool_call_id',
      'tool_name',
      'backend',
      'request_id',
      'level',
      'is_error',
      'duration_ms',
      'summary',
      'payload',
    });
    expect(j['level'], 'INFO');
  });
}
