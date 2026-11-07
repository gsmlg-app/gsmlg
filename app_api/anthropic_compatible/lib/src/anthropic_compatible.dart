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

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content is List
        ? (content as List).map((block) {
            if (block is AnthropicContentBlock) return block.toJson();
            if (block is Map<String, dynamic>) return block;
            return block;
          }).toList()
        : content,
  };
}

/// Content block types in Anthropic Messages API.
sealed class AnthropicContentBlock {
  const AnthropicContentBlock();

  Map<String, dynamic> toJson();

  /// Create a plain text content block.
  const factory AnthropicContentBlock.text(String text) = AnthropicTextBlock;

  /// Create a tool use content block (assistant requesting a tool).
  const factory AnthropicContentBlock.toolUse({
    required String id,
    required String name,
    required Map<String, dynamic> input,
  }) = AnthropicToolUseBlock;

  /// Create a tool result content block (user providing the tool result).
  const factory AnthropicContentBlock.toolResult({
    required String toolUseId,
    required dynamic content,
    bool? isError,
  }) = AnthropicToolResultBlock;
}

class AnthropicTextBlock extends AnthropicContentBlock {
  const AnthropicTextBlock(this.text);

  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

class AnthropicToolUseBlock extends AnthropicContentBlock {
  const AnthropicToolUseBlock({
    required this.id,
    required this.name,
    required this.input,
  });

  final String id;
  final String name;
  final Map<String, dynamic> input;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_use',
    'id': id,
    'name': name,
    'input': input,
  };
}

class AnthropicToolResultBlock extends AnthropicContentBlock {
  const AnthropicToolResultBlock({
    required this.toolUseId,
    required this.content,
    this.isError,
  });

  final String toolUseId;
  final dynamic content;
  final bool? isError;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_result',
    'tool_use_id': toolUseId,
    'content': content,
    if (isError != null) 'is_error': isError,
  };
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
