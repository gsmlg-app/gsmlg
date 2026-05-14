/// Endpoint and header helpers for Anthropic Messages.
final class AnthropicMessagesApi {
  const AnthropicMessagesApi._();

  static const version = '2023-06-01';

  static Uri endpoint(Uri baseUrl) {
    if (baseUrl.path.endsWith('/messages')) return baseUrl;
    final basePath = _trimTrailingSlash(baseUrl.path);
    return baseUrl.replace(path: '$basePath/messages');
  }

  static Map<String, String> headers({
    required String apiKey,
    required bool stream,
  }) {
    return {
      'x-api-key': apiKey,
      'anthropic-version': version,
      'content-type': 'application/json; charset=utf-8',
      'accept': stream ? 'text/event-stream' : 'application/json',
    };
  }
}

/// A Messages API message.
class AnthropicMessage {
  const AnthropicMessage({required this.role, required this.content});

  final String role;
  final Object content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// A client tool definition for Anthropic Messages.
class AnthropicTool {
  const AnthropicTool({
    required this.name,
    required this.inputSchema,
    this.description,
  });

  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'input_schema': inputSchema,
    };
  }

  static List<AnthropicTool> fromOpenAiTools(List<Map<String, dynamic>> tools) {
    final result = <AnthropicTool>[];
    for (final tool in tools) {
      final function = tool['function'];
      if (tool['type'] != 'function' || function is! Map<String, dynamic>) {
        continue;
      }

      final name = function['name'];
      if (name is! String || name.trim().isEmpty) continue;

      final parameters = function['parameters'];
      result.add(
        AnthropicTool(
          name: name,
          description: function['description'] as String?,
          inputSchema: parameters is Map<String, dynamic>
              ? parameters
              : const {'type': 'object'},
        ),
      );
    }
    return result;
  }
}

/// Request body for Anthropic-compatible Messages.
class AnthropicMessagesRequest {
  const AnthropicMessagesRequest({
    required this.model,
    required this.maxTokens,
    required this.messages,
    required this.stream,
    this.temperature,
    this.system,
    this.tools = const [],
  });

  final String model;
  final int maxTokens;
  final List<AnthropicMessage> messages;
  final bool stream;
  final double? temperature;
  final String? system;
  final List<AnthropicTool> tools;

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'max_tokens': maxTokens,
      if (system != null && system!.isNotEmpty) 'system': system,
      'messages': messages.map((message) => message.toJson()).toList(),
      'stream': stream,
      if (temperature != null) 'temperature': temperature,
      if (tools.isNotEmpty)
        'tools': tools.map((tool) => tool.toJson()).toList(),
    };
  }
}

String _trimTrailingSlash(String value) {
  if (value.isEmpty || value == '/') return '';
  return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
