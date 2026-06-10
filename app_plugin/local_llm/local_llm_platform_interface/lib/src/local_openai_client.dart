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
  ) async* {
    final request = await _httpClient.postUrl(_uri('/v1/chat/completions'));
    request.headers
      ..contentType = ContentType.json
      ..set(HttpHeaders.acceptHeader, 'text/event-stream');

    final apiKey = _apiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
    }

    request.add(utf8.encode(jsonEncode({...requestBody, 'stream': true})));
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LocalOpenAiHttpException(
        response.statusCode,
        await response.transform(utf8.decoder).join(),
      );
    }

    yield* _parseSse(
      response.transform(utf8.decoder).transform(const LineSplitter()),
    );
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

Stream<Map<String, Object?>> _parseSse(Stream<String> lines) async* {
  final dataLines = <String>[];

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

  await for (final line in lines) {
    if (line.isEmpty) {
      final event = flush();
      if (event == null) continue;
      if (event.isEmpty) return;
      yield event;
      continue;
    }
    if (line.startsWith('data:')) {
      dataLines.add(line.substring('data:'.length).trimLeft());
    }
  }

  final trailingEvent = flush();
  if (trailingEvent != null && trailingEvent.isNotEmpty) {
    yield trailingEvent;
  }
}
