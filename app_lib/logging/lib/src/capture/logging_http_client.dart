import 'dart:async';
import 'dart:io' show stderr;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'api_exchange_record.dart';
import 'log_capture.dart';
import 'log_context.dart';
import 'redaction.dart';

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
/// `error` and the exception is rethrown. A record is `aborted` only when the
/// request's `abortTrigger` fired or a `RequestAbortedException` was seen; a
/// plain consumer cancel is a normal end. Aborts never populate `error`.
/// Without a tagged context, [LogContext.current] is used.
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
    final context = tag?.context ?? LogContext.current;
    // Registered before the inner client's listener so the flag is set before
    // the resulting RequestAbortedException reaches the stream.
    var abortFired = false;
    final abortTrigger =
        request is http.Abortable ? request.abortTrigger : null;
    if (abortTrigger != null) {
      unawaited(
        abortTrigger.then<void>(
          (_) => abortFired = true,
          onError: (Object _) {},
        ),
      );
    }

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
              method: requestCapture?.method,
              host: requestCapture?.host,
              path: requestCapture?.uri,
              response: response,
              category: tag?.category ?? defaultCategory,
              apiType: tag?.apiType,
              context: context,
              error: error,
              aborted: aborted,
            ),
          ),
        );

    final http.StreamedResponse inner;
    try {
      inner = await _inner.send(request);
    } catch (e, st) {
      final aborted = abortFired || e is http.RequestAbortedException;
      emit(
        'exchange',
        error: aborted ? null : _describe(e, st, request.url),
        aborted: aborted,
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

    // A consumer cancel alone (e.g. stopping at an SSE end marker) is a
    // normal end; only a fired abort trigger or abort error counts as aborted.
    void finish() {
      if (finished) return;
      finished = true;
      final aborted = abortFired || error is http.RequestAbortedException;
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
        error: error == null || aborted
            ? null
            : _describe(error!, errorStack, request.url),
        aborted: aborted,
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
            finish();
            controller.close();
          },
        );
      },
      onPause: () => sub?.pause(),
      onResume: () => sub?.resume(),
      onCancel: () {
        finish();
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

  static _CaptureError _describe(Object e, StackTrace? st, Uri url) => (
        type: e.runtimeType.toString(),
        message: Redaction.inText(e.toString(), url),
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
