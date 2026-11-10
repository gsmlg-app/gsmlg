import 'dart:convert';
import 'dart:typed_data';

import 'package:app_logging/app_logging.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CancellableAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await cancelFuture;
    throw DioException.requestCancelled(
      requestOptions: options,
      reason: 'cancelled',
    );
  }

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

  Dio make(int status, String body, {Set<String> secrets = const {}}) =>
      Dio(BaseOptions(baseUrl: 'https://api.example.com'))
        ..httpClientAdapter = _Adapter(status, body)
        ..interceptors.add(
          ApiCaptureInterceptor(category: 'github', secretHeaders: secrets),
        );

  test('cancel is recorded as aborted without an error', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = _CancellableAdapter()
      ..interceptors.add(ApiCaptureInterceptor(category: 'github'));
    final token = CancelToken();
    final future = dio.get<dynamic>('/slow', cancelToken: token);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    token.cancel('stop');
    await expectLater(future, throwsA(isA<DioException>()));
    final r = sink.api.single;
    expect(r.aborted, isTrue);
    expect(r.error, isNull);
  });

  test('records JSON request/response exchange', () async {
    final dio = make(200, '{"ok":true}');
    final res = await dio.post<dynamic>('/v1/x?key=s', data: {'a': 1});
    expect(res.statusCode, 200);
    expect(sink.api, hasLength(1));
    final r = sink.api.single;
    expect(r.recordType, 'exchange');
    expect(r.category, 'github');
    expect(r.request!.method, 'POST');
    expect(r.request!.host, 'api.example.com');
    expect(r.request!.uri, isNot(contains('key=s')));
    expect(jsonEncode(r.request!.body), contains('"a":1'));
    expect(r.response!.status, 200);
    expect(jsonEncode(r.response!.body), contains('ok'));
    expect(r.durationMs, greaterThanOrEqualTo(0));
    expect(r.error, isNull);
  });

  test('DioException keeps status, body and error type', () async {
    final dio = make(404, '{"message":"nope"}');
    await expectLater(
        dio.get<dynamic>('/missing'), throwsA(isA<DioException>()));
    final r = sink.api.single;
    expect(r.response!.status, 404);
    expect(jsonEncode(r.response!.body), contains('nope'));
    expect(r.error!.type, 'DioException');
  });

  test('redacts secret headers', () async {
    final dio = make(200, '{}');
    await dio.get<dynamic>(
      '/x',
      options: Options(headers: {'X-Amz-Security-Token': 'tok'}),
    );
    expect(
      sink.api.single.request!.headers['X-Amz-Security-Token'],
      ['[REDACTED]'],
    );
  });

  test('extra log_secret_headers redacts per request', () async {
    final dio = make(200, '{}');
    await dio.get<dynamic>(
      '/x',
      options: Options(
        headers: {'X-Team-Token': 'abc'},
        extra: {
          'log_secret_headers': {'X-Team-Token'},
        },
      ),
    );
    expect(sink.api.single.request!.headers['X-Team-Token'], ['[REDACTED]']);
  });

  test('extra overrides category and context', () async {
    final dio = make(200, '{}');
    await dio.get<dynamic>(
      '/x',
      options: Options(extra: {
        'log_category': 'mcp',
        'log_context': const LogContext(runId: 'r1'),
      }),
    );
    expect(sink.api.single.category, 'mcp');
    expect(sink.api.single.context!.runId, 'r1');
  });

  test('no sink: no records, request still works', () async {
    LogCapture.instance.attach(null);
    final res = await make(200, '{}').get<dynamic>('/x');
    expect(res.statusCode, 200);
    expect(sink.api, isEmpty);
  });

  test('zone LogContext is the fallback context', () async {
    final dio = make(200, '{}');
    await LogContext.runZoned(
      const LogContext(runId: 'run-z', toolCallId: 'call-z'),
      () => dio.get<dynamic>('/x'),
    );
    expect(sink.api.single.context?.runId, 'run-z');
    expect(sink.api.single.context?.toolCallId, 'call-z');

    await LogContext.runZoned(
      const LogContext(runId: 'run-z'),
      () => dio.get<dynamic>(
        '/x',
        options: Options(
          extra: {'log_context': const LogContext(runId: 'run-e')},
        ),
      ),
    );
    expect(sink.api.last.context?.runId, 'run-e');
  });

  test('error message does not leak secret query values', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = _ThrowingAdapter()
      ..interceptors.add(ApiCaptureInterceptor(category: 'github'));
    await expectLater(
      dio.get<dynamic>('/v1/x?key=SECRET'),
      throwsA(isA<DioException>()),
    );
    final r = sink.api.single;
    expect(r.error!.message, isNot(contains('SECRET')));
    expect(r.error!.message, contains('api.example.com/v1/x'));
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'failed ${options.uri}',
      );

  @override
  void close({bool force = false}) {}
}
