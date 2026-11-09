import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _Sink implements LogSink {
  final api = <ApiExchangeRecord>[];
  @override
  void writeApi(ApiExchangeRecord r) => api.add(r);
  @override
  void writeAgent(AgentLogEvent e) {}
  @override
  void writeUsage(UsageEvent e) {}
}

/// Inner client whose response body is driven by a [StreamController].
class _ControlledClient extends http.BaseClient {
  _ControlledClient({
    this.status = 200,
    this.contentType = 'text/event-stream; charset=utf-8',
  });
  final int status;
  final String contentType;
  final body = StreamController<List<int>>();
  bool closed = false;
  bool get cancelled => _cancelled;
  bool _cancelled = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await request.finalize().drain<void>();
    body.onCancel = () => _cancelled = true;
    return http.StreamedResponse(
      body.stream,
      status,
      headers: {'content-type': contentType},
      request: request,
      reasonPhrase: 'R',
    );
  }

  @override
  void close() => closed = true;
}

http.Request _post(String body) =>
    http.Request('POST', Uri.parse('https://api.example.com/v1/chat?key=s'))
      ..headers['Content-Type'] = 'application/json'
      ..headers['Authorization'] = 'Bearer secret'
      ..body = body;

void main() {
  late _Sink sink;
  setUp(() {
    sink = _Sink();
    LogCapture.instance.attach(sink);
  });
  tearDown(() {
    LogCapture.instance.attach(null);
    LogCapture.instance.apiEnabled = true;
  });

  test('non-streaming JSON 200 writes one exchange with parsed bodies',
      () async {
    final inner = MockClient(
      (req) async => http.Response(
        '{"ok":true}',
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    final client = LoggingHttpClient(inner, defaultCategory: 'svc');
    final res = await client.send(_post('{"q":1}'));
    expect(await res.stream.bytesToString(), '{"ok":true}');
    expect(res.statusCode, 200);

    expect(sink.api, hasLength(1));
    final r = sink.api.single;
    expect(r.recordType, 'exchange');
    expect(r.category, 'svc');
    expect(r.request!.method, 'POST');
    expect(r.request!.body, {'q': 1});
    expect(r.request!.headers['Authorization'], ['[REDACTED]']);
    expect(r.request!.uri, '/v1/chat?key=[REDACTED]');
    expect(r.response!.status, 200);
    expect(r.response!.body, {'ok': true});
    expect(r.durationMs, isNotNull);
    expect(r.error, isNull);
    expect(r.aborted, isFalse);
    expect(r.requestId, hasLength(36));
  });

  test('HttpCaptureTag sets category, apiType, context and secret headers',
      () async {
    final inner = MockClient((req) async => http.Response('x', 200));
    final client = LoggingHttpClient(inner);
    final req = _post('{}')..headers['X-Custom'] = 'tok';
    HttpCaptureTag.tag(
      req,
      category: 'llm:openrouter',
      apiType: 'chat_completions',
      context: const LogContext(conversationId: 'c1', turn: 2),
      secretHeaders: {'x-custom'},
    );
    await (await client.send(req)).stream.drain<void>();
    final r = sink.api.single;
    expect(r.category, 'llm:openrouter');
    expect(r.apiType, 'chat_completions');
    expect(r.context!.conversationId, 'c1');
    expect(r.request!.headers['X-Custom'], ['[REDACTED]']);
  });

  test('SSE consumed fully writes request then response with full text',
      () async {
    final inner = _ControlledClient();
    final client = LoggingHttpClient(inner);
    final res = await client.send(_post('{}'));

    expect(sink.api, hasLength(1));
    expect(sink.api.first.recordType, 'request');
    expect(sink.api.first.response, isNull);

    final received = <List<int>>[];
    final done = res.stream.listen(received.add).asFuture<void>();
    inner.body.add(utf8.encode('data: a\n\n'));
    inner.body.add(utf8.encode('data: b\n\n'));
    await inner.body.close();
    await done;

    expect(utf8.decode(received.expand((b) => b).toList()),
        'data: a\n\ndata: b\n\n');
    expect(sink.api, hasLength(2));
    final req = sink.api[0], resp = sink.api[1];
    expect(resp.recordType, 'response');
    expect(resp.requestId, req.requestId);
    expect(resp.response!.status, 200);
    expect(resp.response!.body, 'data: a\n\ndata: b\n\n');
    expect(resp.aborted, isFalse);
    expect(resp.durationMs, isNotNull);
  });

  test('SSE cancelled after first chunk records aborted with first chunk',
      () async {
    final inner = _ControlledClient();
    final client = LoggingHttpClient(inner);
    final res = await client.send(_post('{}'));

    final first = Completer<void>();
    late StreamSubscription<List<int>> sub;
    sub = res.stream.listen((_) => first.complete());
    inner.body.add(utf8.encode('data: a\n\n'));
    await first.future;
    await sub.cancel();

    expect(inner.cancelled, isTrue);
    expect(sink.api, hasLength(2));
    final resp = sink.api[1];
    expect(resp.recordType, 'response');
    expect(resp.aborted, isTrue);
    expect(resp.response!.body, 'data: a\n\n');
  });

  test('SSE RequestAbortedException is forwarded and recorded as aborted',
      () async {
    final inner = _ControlledClient();
    final client = LoggingHttpClient(inner);
    final res = await client.send(_post('{}'));
    final errors = <Object>[];
    final done = Completer<void>();
    res.stream.listen(
      (_) {},
      onError: errors.add,
      onDone: done.complete,
    );
    inner.body.add(utf8.encode('data: a\n\n'));
    final abortErr = http.RequestAbortedException(Uri.parse('https://x'));
    inner.body.addError(abortErr);
    await inner.body.close();
    await done.future;

    expect(errors, [same(abortErr)]);
    final resp = sink.api[1];
    expect(resp.aborted, isTrue);
    expect(resp.error!.type, 'RequestAbortedException');
    expect(resp.response!.body, 'data: a\n\n');
  });

  test('SSE other stream error sets error, aborted false', () async {
    final inner = _ControlledClient();
    final client = LoggingHttpClient(inner);
    final res = await client.send(_post('{}'));
    final f = res.stream.toBytes();
    inner.body.add(utf8.encode('data: a\n\n'));
    inner.body.addError(const SocketException('reset'));
    await expectLater(f, throwsA(isA<SocketException>()));

    final resp = sink.api[1];
    expect(resp.aborted, isFalse);
    expect(resp.error!.type, 'SocketException');
    expect(resp.response!.body, 'data: a\n\n');
  });

  test('SSE 401 body read by caller records status and full body', () async {
    final inner = _ControlledClient(status: 401);
    final client = LoggingHttpClient(inner);
    final res = await client.send(_post('{}'));
    final f = res.stream.bytesToString();
    inner.body.add(utf8.encode('{"error":'));
    inner.body.add(utf8.encode('"unauthorized"}'));
    await inner.body.close();
    expect(await f, '{"error":"unauthorized"}');

    final resp = sink.api.last;
    expect(resp.response!.status, 401);
    expect(resp.response!.body, '{"error":"unauthorized"}');
  });

  test('transport exception writes exchange with error and rethrows', () async {
    final inner = MockClient((req) async => throw const SocketException('dns'));
    final client = LoggingHttpClient(inner);
    await expectLater(
      client.send(_post('{}')),
      throwsA(isA<SocketException>()),
    );
    final r = sink.api.single;
    expect(r.recordType, 'exchange');
    expect(r.error!.type, 'SocketException');
    expect(r.error!.message, contains('dns'));
    expect(r.response, isNull);
    expect(r.request, isNotNull);
    expect(r.aborted, isFalse);
  });

  test('caller receives byte-identical stream in same chunks', () async {
    final chunks = [
      [0, 1, 2, 255],
      <int>[],
      [10, 20],
      List<int>.generate(5000, (i) => i % 256),
    ];
    final inner = MockClient.streaming(
      (req, body) async => http.StreamedResponse(
        Stream.fromIterable(chunks),
        200,
        headers: {'content-type': 'application/octet-stream'},
      ),
    );
    final client = LoggingHttpClient(inner);
    final res = await client.send(_post('{}'));
    expect(await res.stream.toList(), chunks);
    expect(sink.api.single.response!.bodyEncoding, 'base64');
  });

  test('non-Request bodies are recorded as null', () async {
    final inner = MockClient.streaming(
      (req, body) async {
        await body.drain<void>();
        return http.StreamedResponse(const Stream.empty(), 204);
      },
    );
    final client = LoggingHttpClient(inner);
    final req = http.StreamedRequest('PUT', Uri.parse('https://h/x'));
    req.sink.add([1, 2, 3]);
    unawaited(req.sink.close());
    await (await client.send(req)).stream.drain<void>();
    expect(sink.api.single.request!.body, isNull);
  });

  test('passes through untouched without a sink or when disabled', () async {
    final inner = MockClient((req) async => http.Response('hi', 200));
    final client = LoggingHttpClient(inner);
    LogCapture.instance.attach(null);
    expect(await (await client.send(_post('{}'))).stream.bytesToString(), 'hi');
    LogCapture.instance.attach(sink);
    LogCapture.instance.apiEnabled = false;
    expect(await (await client.send(_post('{}'))).stream.bytesToString(), 'hi');
    expect(sink.api, isEmpty);
  });

  test('preserves response metadata and close() closes inner', () async {
    final inner = _ControlledClient(contentType: 'text/plain');
    final client = LoggingHttpClient(inner);
    final req = _post('{}');
    final res = await client.send(req);
    expect(res.statusCode, 200);
    expect(res.reasonPhrase, 'R');
    expect(res.headers['content-type'], 'text/plain');
    expect(res.request, same(req));
    client.close();
    expect(inner.closed, isTrue);
  });
}
