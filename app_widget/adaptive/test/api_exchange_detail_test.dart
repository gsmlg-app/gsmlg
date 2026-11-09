import 'dart:convert';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _sse = 'data: {"choices":[{"delta":{"content":"Hi"}}]}\n\n'
    'data: [DONE]\n\n';

Map<String, Object?> _record() => {
      'ts': '2026-11-10T10:00:00.000000+08:00',
      'request_id': 'req-1',
      'record_type': 'exchange',
      'duration_ms': 42,
      'category': 'llm',
      'request': {
        'method': 'POST',
        'scheme': 'https',
        'host': 'api.example.com',
        'uri': '/v1/chat/completions',
        'proto': 'HTTP/1.1',
        'headers': {
          'authorization': ['[REDACTED]'],
          'content-type': ['application/json'],
        },
        'body': {
          'model': 'm',
          'stream': true,
        },
        'body_encoding': 'json',
        'body_truncated': false,
        'content_type': 'application/json',
      },
      'response': {
        'status': 200,
        'headers': {
          'content-type': ['text/event-stream'],
        },
        'body': _sse,
        'body_encoding': 'text',
        'body_truncated': false,
        'content_type': 'text/event-stream',
      },
    };

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('renders SSE body verbatim and redacted header values', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(ApiExchangeDetail(record: _record())));
    await tester.pumpAndSettle();

    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Response'), findsOneWidget);
    expect(find.text(_sse), findsOneWidget);
    expect(find.text('authorization'), findsOneWidget);
    expect(find.text('[REDACTED]'), findsOneWidget);
    // JSON request body is pretty-printed.
    expect(
      find.text(const JsonEncoder.withIndent('  ').convert({
        'model': 'm',
        'stream': true,
      })),
      findsOneWidget,
    );
  });

  testWidgets('Copy JSONL copies the record json', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(_wrap(ApiExchangeDetail(record: _record())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy JSONL'));
    await tester.pump();

    expect(copied, isNotNull);
    expect(jsonDecode(copied!), _record());
  });

  test('merge combines streamed request and response records', () {
    final request = {
      'request_id': 'r',
      'record_type': 'request',
      'request': {'method': 'POST'},
    };
    final response = {
      'request_id': 'r',
      'record_type': 'response',
      'duration_ms': 9,
      'response': {'status': 200},
    };
    final merged = ApiExchangeDetail.merge([request, response]);
    expect(merged['request'], {'method': 'POST'});
    expect(merged['response'], {'status': 200});
    expect(merged['duration_ms'], 9);
  });
}
