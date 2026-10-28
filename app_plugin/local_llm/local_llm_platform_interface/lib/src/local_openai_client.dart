import 'dart:async';
import 'dart:convert';
import 'dart:io';

final class LocalOpenAiChatCompletionsClient {
  LocalOpenAiChatCompletionsClient({
    required Uri baseUri,
    String? apiKey,
    HttpClient? httpClient,
  })  : _baseUri = _normalizeBaseUri(baseUri),
        _apiKey = apiKey,
        _httpClient = httpClient ?? HttpClient();

  final Uri _baseUri;
  final String? _apiKey;
  final HttpClient _httpClient;

  Stream<Map<String, Object?>> streamChatCompletion({
    required String model,
    required List<Map<String, Object?>> messages,
    int? maxTokens,
    double? temperature,
    double? topP,
    int? topK,
    List<String> stop = const [],
  }) {
    return streamChatCompletionRequest(<String, Object?>{
      'model': model,
      'messages': messages,
      'stream': true,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (topK != null) 'top_k': topK,
      if (stop.isNotEmpty) 'stop': stop,
    });
  }

  Stream<Map<String, Object?>> streamChatCompletionRequest(
    Map<String, Object?> requestBody,
  ) {
    HttpClientRequest? activeRequest;
    StreamSubscription<Object?>? responseSubscription;
    var cancelled = false;
    late final StreamController<Map<String, Object?>> controller;

    void forwardError(Object error, StackTrace stackTrace) {
      if (!cancelled) controller.addError(error, stackTrace);
    }

    void finish() {
      if (!cancelled) unawaited(controller.close());
    }

    Future<void> start() async {
      try {
        final request = await _httpClient.postUrl(_uri('/v1/chat/completions'));
        activeRequest = request;
        if (cancelled) {
          request.abort();
          // Observe the abort error even when cancellation won the connection
          // race before there was a request handle to abort in onCancel.
          await request.done;
          return;
        }
        request.headers
          ..contentType = ContentType.json
          ..set(HttpHeaders.acceptHeader, 'text/event-stream');

        final apiKey = _apiKey;
        if (apiKey != null && apiKey.isNotEmpty) {
          request.headers
              .set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
        }
        request.add(utf8.encode(jsonEncode({...requestBody, 'stream': true})));
        final response = await request.close();
        if (cancelled) {
          await response.listen((_) {}).cancel();
          return;
        }

        if (response.statusCode < 200 || response.statusCode >= 300) {
          final body = StringBuffer();
          responseSubscription = response.transform(utf8.decoder).listen(
            body.write,
            onError: forwardError,
            onDone: () {
              if (!cancelled) {
                controller.addError(LocalOpenAiHttpException(
                    response.statusCode, body.toString()));
              }
              finish();
            },
          );
        } else {
          responseSubscription = _parseSse(
            response.transform(utf8.decoder).transform(const LineSplitter()),
          ).listen(controller.add, onError: forwardError, onDone: finish);
        }
        if (controller.isPaused) responseSubscription!.pause();
      } catch (error, stackTrace) {
        forwardError(error, stackTrace);
        finish();
      }
    }

    controller = StreamController<Map<String, Object?>>(
      onListen: () => unawaited(start()),
      onPause: () => responseSubscription?.pause(),
      onResume: () => responseSubscription?.resume(),
      onCancel: () async {
        cancelled = true;
        // Cancelling an async* stream cannot interrupt an awaited response
        // future. Abort the specific request while retaining the shared client.
        activeRequest?.abort();
        await responseSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  void close({bool force = false}) {
    _httpClient.close(force: force);
  }

  Uri _uri(String path) {
    final basePath = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    return _baseUri.replace(path: '$basePath$path');
  }

  static Uri _normalizeBaseUri(Uri uri) {
    if (!uri.hasScheme) {
      return Uri.parse('http://$uri');
    }
    return uri;
  }
}

final class LocalOpenAiHttpException implements Exception {
  const LocalOpenAiHttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'LocalOpenAiHttpException($statusCode): $body';
}

Stream<Map<String, Object?>> _parseSse(Stream<String> lines) {
  final dataLines = <String>[];
  var ended = false;

  Map<String, Object?>? flush() {
    if (dataLines.isEmpty) return null;
    final rawData = dataLines.join('\n');
    dataLines.clear();

    if (rawData == '[DONE]') return const {};
    final decoded = jsonDecode(rawData);
    if (decoded is Map) {
      return decoded.cast<String, Object?>();
    }
    return null;
  }

  // A transformer forwards cancellation to the native response subscription
  // immediately, including when no further SSE line is forthcoming.
  return lines
      .transform(StreamTransformer<String, Map<String, Object?>>.fromHandlers(
    handleData: (line, sink) {
      if (ended) return;
      try {
        if (line.isEmpty) {
          final event = flush();
          if (event == null) return;
          if (event.isEmpty) {
            ended = true;
            sink.close();
          } else {
            sink.add(event);
          }
        } else if (line.startsWith('data:')) {
          dataLines.add(line.substring('data:'.length).trimLeft());
        }
      } catch (error, stackTrace) {
        ended = true;
        sink.addError(error, stackTrace);
        sink.close();
      }
    },
    handleError: (Object error, StackTrace stackTrace, sink) {
      if (ended) return;
      ended = true;
      sink.addError(error, stackTrace);
      sink.close();
    },
    handleDone: (sink) {
      if (ended) return;
      ended = true;
      try {
        final trailingEvent = flush();
        if (trailingEvent != null && trailingEvent.isNotEmpty) {
          sink.add(trailingEvent);
        }
      } catch (error, stackTrace) {
        sink.addError(error, stackTrace);
      }
      sink.close();
    },
  ));
}
