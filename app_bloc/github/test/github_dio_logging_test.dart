import 'dart:typed_data';

import 'package:app_logging/app_logging.dart';
import 'package:dio/dio.dart';
import 'package:github_bloc/github_bloc.dart';
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
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{}',
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
  @override
  void close({bool force = false}) {}
}

void main() {
  tearDown(() => LogCapture.instance.attach(null));

  test('GitHub Dio has capture last and records category github', () async {
    final sink = _Sink();
    LogCapture.instance.attach(sink);
    final dio = GitHubBloc.createDio('secret-token')
      ..httpClientAdapter = _Adapter();
    expect(dio.interceptors.last, isA<ApiCaptureInterceptor>());
    await dio.get<dynamic>('/user');
    expect(sink.api.single.category, 'github');
    expect(sink.api.single.request!.headers['Authorization'], ['[REDACTED]']);
  });
}
