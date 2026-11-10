import 'dart:convert';

import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simulates a JSON wire hop (as a plain map crosses an isolate or file).
Map<String, Object?> _hop(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  final ts = DateTime.utc(2026, 11, 10, 8, 30, 15, 123, 456);

  group('LogContext.fromJson', () {
    test('round-trips every field', () {
      const ctx = LogContext(
        conversationId: 'c',
        runId: 'r',
        parentRunId: 'p',
        generationId: 'g',
        toolCallId: 't',
        turn: 3,
      );
      expect(LogContext.fromJson(_hop(ctx.toJson())).toJson(), ctx.toJson());
    });
  });

  group('ApiExchangeRecord.fromJson', () {
    test('round-trips an exchange with request, response, context, error', () {
      final rec = ApiExchangeRecord(
        ts: ts,
        requestId: 'req-1',
        recordType: 'exchange',
        durationMs: 42,
        request: HttpMessageCapture.request(
          method: 'POST',
          url: Uri.parse('https://api.example.com/v1/x?key=s&a=1'),
          headers: {
            'Authorization': ['Bearer x'],
            'Content-Type': ['application/json'],
          },
          bodyBytes: utf8.encode('{"a":[1,2,{"b":null}]}'),
        ),
        response: HttpMessageCapture.response(
          status: 500,
          headers: {
            'content-type': ['text/plain'],
          },
          bodyBytes: utf8.encode('boom'),
        ),
        category: 'github',
        apiType: 'rest',
        context: const LogContext(conversationId: 'c', runId: 'r', turn: 2),
        error: (type: 'DioException', message: 'bad', stackTrace: 'st'),
        aborted: true,
      );
      final back = ApiExchangeRecord.fromJson(_hop(rec.toJson()));
      expect(back.toJsonLine(), rec.toJsonLine());
      expect(back.ts.isAtSameMomentAs(ts), isTrue);
      expect(back.method, 'POST');
      expect(back.host, 'api.example.com');
      expect(back.path, '/v1/x?key=[REDACTED]&a=1');
      expect(back.response?.status, 500);
      expect(back.context?.runId, 'r');
      expect(back.error?.type, 'DioException');
      expect(back.aborted, isTrue);
    });

    test('round-trips a minimal record', () {
      final rec = ApiExchangeRecord(
        ts: ts,
        requestId: 'req-2',
        recordType: 'request',
      );
      final back = ApiExchangeRecord.fromJson(_hop(rec.toJson()));
      expect(back.toJsonLine(), rec.toJsonLine());
      expect(back.error, isNull);
      expect(back.context, isNull);
    });

    test('response record keeps summary method/host/path keys', () {
      final rec = ApiExchangeRecord(
        ts: ts,
        requestId: 'req-3',
        recordType: 'response',
        method: 'GET',
        host: 'h.com',
        path: '/p',
        response: HttpMessageCapture.response(
          status: 200,
          headers: const {},
          bodyBytes: const [],
        ),
      );
      final json = {
        ...rec.toJson(),
        'method': rec.method,
        'host': rec.host,
        'path': rec.path,
      };
      final back = ApiExchangeRecord.fromJson(_hop(json));
      expect(back.method, 'GET');
      expect(back.host, 'h.com');
      expect(back.path, '/p');
      // Summary keys never leak into the stored record.
      expect(back.toJsonLine(), rec.toJsonLine());
    });
  });

  group('AgentLogEvent.fromJson', () {
    test('round-trips every field', () {
      final e = AgentLogEvent(
        ts: ts,
        eventType: 'tool_call',
        context: const LogContext(
          conversationId: 'c',
          runId: 'r',
          parentRunId: 'p',
          turn: 1,
          toolCallId: 't',
        ),
        toolName: 'whois',
        backend: 'gemini',
        requestId: 'req',
        level: 'SEVERE',
        isError: true,
        durationMs: 9,
        summary: 'failed',
        payload: const {
          'n': 1,
          'nested': {
            'l': [1, 'x'],
          },
        },
      );
      final back = AgentLogEvent.fromJson(_hop(e.toJson()));
      expect(back.toJson(), e.toJson());
      expect(back.context.runId, 'r');
      expect(back.ts.isAtSameMomentAs(ts), isTrue);
    });

    test('round-trips defaults', () {
      final e = AgentLogEvent(ts: ts, eventType: 'run_start');
      expect(AgentLogEvent.fromJson(_hop(e.toJson())).toJson(), e.toJson());
    });
  });

  group('UsageEvent.fromJson', () {
    test('round-trips every field', () {
      final e = UsageEvent(
        ts: ts,
        sessionId: 's',
        eventType: 'screen_view',
        module: 'm',
        screenName: 'Home',
        routePath: '/home',
        target: 't',
        sourceScreen: 'src',
        durationMs: 1500,
        payload: const {'k': 'v'},
      );
      final back = UsageEvent.fromJson(_hop(e.toJson()));
      expect(back.toJson(), e.toJson());
      expect(back.ts.isAtSameMomentAs(ts), isTrue);
    });

    test('round-trips required fields only', () {
      final e = UsageEvent(ts: ts, sessionId: 's', eventType: 'session_start');
      expect(UsageEvent.fromJson(_hop(e.toJson())).toJson(), e.toJson());
    });
  });
}
