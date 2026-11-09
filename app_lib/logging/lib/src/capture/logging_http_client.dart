import 'dart:async';
import 'dart:io' show stderr;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'api_exchange_record.dart';
import 'log_capture.dart';
import 'log_context.dart';

typedef _CaptureError = ({String type, String message, String? stackTrace});

/// Per-request capture metadata, attached with [tag] before `send`.
final class HttpCaptureTag {
  const HttpCaptureTag._({
    required this.category,
    this.apiType,
    this.context,
    this.secretHeaders = const {},
  });

  final String category;
  final String? apiType;
  final LogContext? context;
  final Set<String> secretHeaders;

  static final _tags = Expando<HttpCaptureTag>('HttpCaptureTag');

  /// Attaches capture metadata to [r] for [LoggingHttpClient].
  static void tag(
    http.BaseRequest r, {
    required String category,
    String? apiType,
    LogContext? context,
    Set<String> secretHeaders = const {},
  }) =>
      _tags[r] = HttpCaptureTag._(
        category: category,
        apiType: apiType,
        context: context,
        secretHeaders: secretHeaders,
      );
}

/// An [http.Client] wrapper that records each exchange via
/// [LogCapture.instance] without altering what the caller receives.
///
/// `text/event-stream` responses produce a `request` record as soon as the
/// response headers arrive and a `response` record when the body stream ends
/// (done, error or cancel). Other responses produce one `exchange` record when
/// the body stream ends. Transport failures produce an `exchange` record with
/// `error` and the exception is rethrown.
class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient(this._inner, {this.defaultCategory = 'http'});

  final http.Client _inner;
  final String defaultCategory;

  static const _uuid = Uuid();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!LogCapture.instance.apiActive) return _inner.send(request);

    final ts = DateTime.now();
    final watch = Stopwatch()..start();
    final requestId = _uuid.v4();
    final tag = HttpCaptureTag._tags[request];
    final secrets = tag?.secretHeaders ?? const <String>{};
    final requestCapture = _guard(() => _captureRequest(request, secrets));

    void emit(
      String recordType, {
      HttpMessageCapture? response,
      _CaptureError? error,
      bool aborted = false,
    }) =>
        _guard(
          () => LogCapture.instance.api(
            ApiExchangeRecord(
              ts: ts,
              requestId: requestId,
              recordType: recordType,
              durationMs:
                  recordType == 'request' ? null : watch.elapsedMilliseconds,
              request: recordType == 'response' ? null : requestCapture,
              response: response,
              category: tag?.category ?? defaultCategory,
              apiType: tag?.apiType,
              context: tag?.context,
              error: error,
              aborted: aborted,
            ),
          ),
        );

    final http.StreamedResponse inner;
    try {
      inner = await _inner.send(request);
    } catch (e, st) {
      emit(
        'exchange',
        error: _describe(e, st),
        aborted: e is http.RequestAbortedException,
      );
      rethrow;
    }

    final streamed = _isEventStream(inner.headers);
    if (streamed) emit('request');

    final buffer = BytesBuilder();
    StreamSubscription<List<int>>? sub;
    Object? error;
    StackTrace? errorStack;
    var finished = false;

    void finish({required bool cancelled}) {
      if (finished) return;
      finished = true;
      emit(
        streamed ? 'response' : 'exchange',
        response: _guard(
          () => HttpMessageCapture.response(
            status: inner.statusCode,
            headers: _listHeaders(inner.headers),
            bodyBytes: buffer.takeBytes(),
            secretHeaders: secrets,
          ),
        ),
        error: error == null ? null : _describe(error!, errorStack),
        aborted: (cancelled && error == null) ||
            error is http.RequestAbortedException,
      );
    }

    late final StreamController<List<int>> controller;
    controller = StreamController<List<int>>(
      sync: true,
      onListen: () {
        sub = inner.stream.listen(
          (chunk) {
            buffer.add(chunk);
            controller.add(chunk);
          },
          onError: (Object e, StackTrace st) {
            error ??= e;
            errorStack ??= st;
            controller.addError(e, st);
          },
          onDone: () {
            finish(cancelled: false);
            controller.close();
          },
        );
      },
      onPause: () => sub?.pause(),
      onResume: () => sub?.resume(),
      onCancel: () {
        finish(cancelled: true);
        return sub?.cancel();
      },
    );

    return http.StreamedResponse(
      controller.stream,
      inner.statusCode,
      contentLength: inner.contentLength,
      request: inner.request,
      headers: inner.headers,
      isRedirect: inner.isRedirect,
      persistentConnection: inner.persistentConnection,
      reasonPhrase: inner.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();

  static HttpMessageCapture _captureRequest(
    http.BaseRequest r,
    Set<String> secrets,
  ) {
    final headers = _listHeaders(r.headers);
    if (r is http.Request) {
      return HttpMessageCapture.request(
        method: r.method,
        url: r.url,
        headers: headers,
        bodyBytes: r.bodyBytes,
        secretHeaders: secrets,
      );
    }
    // Streamed/multipart bodies are not copied; record the body as null.
    final c = HttpMessageCapture.request(
      method: r.method,
      url: r.url,
      headers: headers,
      bodyBytes: const [],
      secretHeaders: secrets,
    );
    return HttpMessageCapture(
      method: c.method,
      scheme: c.scheme,
      host: c.host,
      uri: c.uri,
      headers: c.headers,
      bodyEncoding: c.bodyEncoding,
      contentType: c.contentType,
      contentLength: r.contentLength,
    );
  }

  static Map<String, List<String>> _listHeaders(Map<String, String> h) => {
        for (final e in h.entries) e.key: [e.value],
      };

  static bool _isEventStream(Map<String, String> h) => h.entries.any(
        (e) =>
            e.key.toLowerCase() == 'content-type' &&
            e.value.toLowerCase().contains('text/event-stream'),
      );

  static _CaptureError _describe(Object e, StackTrace? st) => (
        type: e.runtimeType.toString(),
        message: e.toString(),
        stackTrace: st?.toString(),
      );

  /// Runs capture work; failures are reported and never reach the caller.
  static T? _guard<T>(T Function() f) {
    try {
      return f();
    } catch (e) {
      stderr.writeln('LoggingHttpClient: capture failed: $e');
      return null;
    }
  }
}
