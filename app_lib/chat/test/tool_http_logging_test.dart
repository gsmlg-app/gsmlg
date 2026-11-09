import 'dart:convert';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:app_logging/app_logging.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Sink implements LogSink {
  final api = <ApiExchangeRecord>[];
  @override
  void writeApi(ApiExchangeRecord r) => api.add(r);
  @override
  void writeAgent(AgentLogEvent e) {}
  @override
  void writeUsage(UsageEvent e) {}
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.body);
  final int status;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: ['text/plain'],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Sink sink;
  setUp(() {
    sink = _Sink();
    LogCapture.instance.attach(sink);
  });
  tearDown(() => LogCapture.instance.attach(null));

  test('MCP HTTP call is captured with all profile headers redacted', () async {
    final dio = Dio()..httpClientAdapter = _Adapter(401, 'denied');
    final client = DartMcpToolClient(dio: dio);

    await expectLater(
      client.listHttpTools(
        const DartMcpHttpServerConfig(
          url: 'https://mcp.example.com/http',
          name: 'docs',
          headers: {'X-Team-Token': 'super-secret'},
        ),
      ),
      throwsA(anything),
    );

    expect(sink.api, isNotEmpty);
    final r = sink.api.first;
    expect(r.category, 'mcp:docs');
    expect(r.request!.headers['X-Team-Token'], ['[REDACTED]']);
    expect(jsonEncode(r.request!.headers), isNot(contains('super-secret')));
  });

  test('web_fetch 500 is recorded once with full body', () async {
    final dio = Dio()..httpClientAdapter = _Adapter(500, 'upstream exploded');
    final executor = ToolExecutor(dio: dio);

    final result = await executor.execute('web_fetch', {
      'url': 'https://example.com/page',
    });

    expect(result['error'], isNotNull);
    expect(sink.api, hasLength(1));
    final r = sink.api.single;
    expect(r.category, 'tool:web_fetch');
    expect(r.response!.status, 500);
    expect(jsonEncode(r.response!.body), contains('upstream exploded'));
  });
}
