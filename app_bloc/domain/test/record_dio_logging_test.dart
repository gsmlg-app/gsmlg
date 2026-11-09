import 'dart:typed_data';

import 'package:app_logging/app_logging.dart';
import 'package:dio/dio.dart';
import 'package:domain_bloc/domain_bloc.dart';
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
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString('<ok/>', 200, headers: {
        Headers.contentTypeHeader: ['application/xml'],
      });
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

  test('Route53 Dio: capture last, Authorization redacted after signing',
      () async {
    final dio = RecordBloc.createRoute53Dio(
        const Route53Credentials(accessKeyId: 'AKIAX', secretAccessKey: 's'))
      ..httpClientAdapter = _Adapter();
    expect(dio.interceptors.last, isA<ApiCaptureInterceptor>());
    await dio.get<dynamic>('/hostedzone');
    expect(sink.api, hasLength(1));
    expect(sink.api.single.category, 'route53');
    final headers = sink.api.single.request!.headers;
    final auth = headers.entries
        .firstWhere((e) => e.key.toLowerCase() == 'authorization')
        .value;
    expect(auth, ['[REDACTED]']);
  });

  test('Cloudflare Dio: capture last, category cloudflare_dns', () async {
    final dio = RecordBloc.createCloudflareDio(
        const CloudflareCredentials(apiToken: 'tok'))
      ..httpClientAdapter = _Adapter();
    expect(dio.interceptors.last, isA<ApiCaptureInterceptor>());
    await dio.get<dynamic>('/zones');
    expect(sink.api.single.category, 'cloudflare_dns');
    expect(sink.api.single.request!.headers['Authorization'], ['[REDACTED]']);
  });
}
