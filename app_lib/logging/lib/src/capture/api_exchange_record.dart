import 'dart:convert';

import 'http_body.dart';
import 'log_context.dart';
import 'redaction.dart';

/// Formats [t] as local ISO-8601 with microseconds and `+HH:MM` offset.
String formatLogTimestamp(DateTime t) {
  final l = t.toLocal();
  String p(int v, int w) => v.toString().padLeft(w, '0');
  final off = l.timeZoneOffset;
  final mins = off.inMinutes.abs();
  final sign = off.isNegative ? '-' : '+';
  return '${p(l.year, 4)}-${p(l.month, 2)}-${p(l.day, 2)}'
      'T${p(l.hour, 2)}:${p(l.minute, 2)}:${p(l.second, 2)}'
      '.${p(l.millisecond * 1000 + l.microsecond, 6)}'
      '$sign${p(mins ~/ 60, 2)}:${p(mins % 60, 2)}';
}

class HttpMessageCapture {
  const HttpMessageCapture({
    this.method,
    this.scheme,
    this.host,
    this.uri,
    this.proto = 'HTTP/1.1',
    this.remoteAddr,
    this.status,
    required this.headers,
    this.body,
    required this.bodyEncoding,
    this.bodyTruncated = false,
    this.contentType,
    this.contentLength,
  });

  factory HttpMessageCapture.request({
    required String method,
    required Uri url,
    required Map<String, List<String>> headers,
    required List<int> bodyBytes,
    Set<String> secretHeaders = const {},
  }) {
    final ct = _headerValue(headers, 'content-type');
    final b = HttpBody.encode(bodyBytes, ct);
    return HttpMessageCapture(
      method: method,
      scheme: url.scheme,
      host: url.hasPort ? '${url.host}:${url.port}' : url.host,
      uri: '${url.path}${url.hasQuery ? '?${Redaction.query(url.query)}' : ''}',
      headers: Redaction.headers(headers, extra: secretHeaders),
      body: b.body,
      bodyEncoding: b.encoding,
      bodyTruncated: b.truncated,
      contentType: ct,
      contentLength: bodyBytes.length,
    );
  }

  factory HttpMessageCapture.response({
    required int status,
    required Map<String, List<String>> headers,
    required List<int> bodyBytes,
    Set<String> secretHeaders = const {},
  }) {
    final ct = _headerValue(headers, 'content-type');
    final b = HttpBody.encode(bodyBytes, ct);
    return HttpMessageCapture(
      status: status,
      headers: Redaction.headers(headers, extra: secretHeaders),
      body: b.body,
      bodyEncoding: b.encoding,
      bodyTruncated: b.truncated,
      contentType: ct,
    );
  }

  final String? method, scheme, host, uri, remoteAddr;
  final String proto;
  final int? status;
  final Map<String, List<String>> headers;
  final Object? body;
  final String bodyEncoding;
  final bool bodyTruncated;
  final String? contentType;
  final int? contentLength;

  static String? _headerValue(Map<String, List<String>> h, String name) {
    for (final e in h.entries) {
      if (e.key.toLowerCase() == name && e.value.isNotEmpty) {
        return e.value.first;
      }
    }
    return null;
  }

  Map<String, Object?> toJson() {
    final isRequest = method != null;
    return {
      if (status != null) 'status': status,
      if (isRequest) ...{
        'method': method,
        'scheme': scheme,
        'host': host,
        'uri': uri,
        'proto': proto,
        if (remoteAddr != null) 'remote_addr': remoteAddr,
      },
      'headers': headers,
      if (body != null) 'body': body,
      'body_encoding': bodyEncoding,
      'body_truncated': bodyTruncated,
      if (contentType != null) 'content_type': contentType,
      if (contentLength != null) 'content_length': contentLength,
    };
  }
}

class ApiExchangeRecord {
  const ApiExchangeRecord({
    required this.ts,
    required this.requestId,
    required this.recordType,
    this.durationMs,
    this.request,
    this.response,
    this.category = 'other',
    this.apiType,
    this.context,
    this.error,
    this.aborted = false,
    String? method,
    String? host,
    String? path,
  })  : _method = method,
        _host = host,
        _path = path;

  final DateTime ts;
  final String requestId;

  /// `exchange`, `request` or `response`.
  final String recordType;
  final int? durationMs;
  final HttpMessageCapture? request;
  final HttpMessageCapture? response;
  final String category;
  final String? apiType;
  final LogContext? context;
  final ({String type, String message, String? stackTrace})? error;
  final bool aborted;
  final String? _method, _host, _path;

  /// Request summary used for index columns. `response` records carry it
  /// without the full [request] (which [toJson] omits for them).
  String? get method => request?.method ?? _method;
  String? get host => request?.host ?? _host;
  String? get path => request?.uri ?? _path;

  Map<String, Object?> toJson() => {
        'ts': formatLogTimestamp(ts),
        'request_id': requestId,
        'record_type': recordType,
        if (durationMs != null) 'duration_ms': durationMs,
        if (request != null) 'request': request!.toJson(),
        if (response != null) 'response': response!.toJson(),
        'category': category,
        if (apiType != null) 'api_type': apiType,
        if (context != null) 'context': context!.toJson(),
        if (error != null)
          'error': {
            'type': error!.type,
            'message': error!.message,
            if (error!.stackTrace != null) 'stack_trace': error!.stackTrace,
          },
        if (aborted) 'aborted': true,
      };

  String toJsonLine() => jsonEncode(toJson());
}
