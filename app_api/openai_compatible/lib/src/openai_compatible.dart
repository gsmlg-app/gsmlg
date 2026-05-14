/// Supported OpenAI-compatible protocol shapes.
enum OpenAiCompatibleApiType {
  /// `POST /chat/completions`.
  chatCompletions,

  /// `POST /responses`.
  responses,
}

extension OpenAiCompatibleApiTypeX on OpenAiCompatibleApiType {
  /// Resolve this API type's generation endpoint under [baseUrl].
  Uri endpoint(Uri baseUrl) {
    return switch (this) {
      OpenAiCompatibleApiType.chatCompletions => _endpoint(
        baseUrl,
        '/chat/completions',
      ),
      OpenAiCompatibleApiType.responses => _endpoint(baseUrl, '/responses'),
    };
  }
}

/// A text chat message accepted by OpenAI-compatible APIs.
class OpenAiMessage {
  const OpenAiMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Request body for OpenAI-compatible Chat Completions.
class OpenAiChatCompletionsRequest {
  const OpenAiChatCompletionsRequest({
    required this.model,
    required this.messages,
    required this.stream,
    required this.temperature,
    this.tools = const [],
    this.extra = const {},
  });

  final String model;
  final List<OpenAiMessage> messages;
  final bool stream;
  final double temperature;
  final List<Map<String, dynamic>> tools;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((message) => message.toJson()).toList(),
      'stream': stream,
      'temperature': temperature,
      ...extra,
      if (tools.isNotEmpty) 'tools': tools,
    };
  }
}

/// Request body for OpenAI Responses.
class OpenAiResponsesRequest {
  const OpenAiResponsesRequest({
    required this.model,
    required this.input,
    required this.stream,
    required this.temperature,
    this.store = false,
    this.tools = const [],
    this.extra = const {},
  });

  final String model;
  final List<OpenAiMessage> input;
  final bool stream;
  final double temperature;
  final bool store;
  final List<Map<String, dynamic>> tools;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'input': input.map((message) => message.toJson()).toList(),
      'stream': stream,
      'temperature': temperature,
      'store': store,
      ...extra,
      if (tools.isNotEmpty) 'tools': tools,
    };
  }
}

/// Tool-shape conversion helpers for OpenAI Responses.
final class OpenAiResponsesTool {
  const OpenAiResponsesTool._();

  static List<Map<String, dynamic>> fromChatCompletionsTools(
    List<Map<String, dynamic>> tools,
  ) {
    final responsesTools = <Map<String, dynamic>>[];
    for (final tool in tools) {
      final function = tool['function'];
      if (tool['type'] != 'function' || function is! Map<String, dynamic>) {
        responsesTools.add(tool);
        continue;
      }

      responsesTools.add({
        'type': 'function',
        'name': function['name'],
        if (function['description'] != null)
          'description': function['description'],
        if (function['parameters'] != null)
          'parameters': function['parameters'],
        'strict': function['strict'] ?? tool['strict'] ?? false,
      });
    }
    return responsesTools;
  }
}

Uri _endpoint(Uri baseUrl, String endpointPath) {
  if (baseUrl.path.endsWith(endpointPath)) return baseUrl;
  final basePath = _trimTrailingSlash(baseUrl.path);
  return baseUrl.replace(path: '$basePath$endpointPath');
}

String _trimTrailingSlash(String value) {
  if (value.isEmpty || value == '/') return '';
  return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
