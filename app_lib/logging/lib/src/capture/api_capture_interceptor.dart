import 'dart:convert';
import 'dart:io' show stderr;

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'api_exchange_record.dart';
import 'log_capture.dart';
import 'log_context.dart';

typedef _Start = ({DateTime ts, Stopwatch watch, String requestId});

/// Records each Dio exchange via [LogCapture.instance] without altering the
/// request flow. Add it **last** so it sees final headers (after signing).
///
/// `RequestOptions.extra['log_category']` (String) and
/// `extra['log_context']` ([LogContext]) override the constructor values;
/// `extra['log_secret_headers']` (`Set<String>`) adds to [secretHeaders].
class ApiCaptureInterceptor extends Interceptor {
  ApiCaptureInterceptor({
    required this.category,
    this.secretHeaders = const {},
    this.context,
  });

  final String category;
  final Set<String> secretHeaders;
  final LogContext? Function()? context;

  static const _uuid = Uuid();
  static const _startKey = '_app_logging_capture_start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _guard(() {
      if (!LogCapture.instance.apiActive) return;
      options.extra[_startKey] = (
        ts: DateTime.now(),
        watch: Stopwatch()..start(),
        requestId: _uuid.v4(),
      );
    });
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    _guard(() => _emit(response.requestOptions, response: response));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _guard(() => _emit(err.requestOptions, response: err.response, error: err));
    handler.next(err);
  }

  void _emit(
    RequestOptions options, {
    Response<dynamic>? response,
    DioException? error,
  }) {
    final start = options.extra[_startKey];
    if (start is! _Start || !LogCapture.instance.apiActive) return;
    final cat = options.extra['log_category'];
    final ctx = options.extra['log_context'];
    final extraSecrets = options.extra['log_secret_headers'];
    final secrets = extraSecrets is Set<String>
        ? {...secretHeaders, ...extraSecrets}
        : secretHeaders;
    LogCapture.instance.api(
      ApiExchangeRecord(
        ts: start.ts,
        requestId: start.requestId,
        recordType: 'exchange',
        durationMs: start.watch.elapsedMilliseconds,
        request: HttpMessageCapture.request(
          method: options.method,
          url: options.uri,
          headers: {
            for (final e in options.headers.entries) e.key: _values(e.value),
          },
          bodyBytes: _bytes(options.data),
          secretHeaders: secrets,
        ),
        response: response == null
            ? null
            : HttpMessageCapture.response(
                status: response.statusCode ?? 0,
                headers: response.headers.map,
                bodyBytes: options.responseType == ResponseType.stream
                    ? const []
                    : _bytes(response.data),
                secretHeaders: secrets,
              ),
        category: cat is String ? cat : category,
        context: ctx is LogContext ? ctx : context?.call(),
        error: error == null
            ? null
            : (
                type: error.runtimeType.toString(),
                message: error.toString(),
                stackTrace: error.stackTrace.toString(),
              ),
        aborted: error?.type == DioExceptionType.cancel,
      ),
    );
  }

  static List<String> _values(Object? v) =>
      v is List ? [for (final x in v) x.toString()] : [v.toString()];

  static List<int> _bytes(Object? data) => switch (data) {
        null => const [],
        List<int> b => b,
        String s => utf8.encode(s),
        Map<dynamic, dynamic>() ||
        List<dynamic>() =>
          utf8.encode(jsonEncode(data)),
        _ => utf8.encode(data.toString()),
      };

  static void _guard(void Function() f) {
    try {
      f();
    } catch (e) {
      stderr.writeln('ApiCaptureInterceptor: capture failed: $e');
    }
  }
}
