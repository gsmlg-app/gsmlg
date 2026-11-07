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
  const OpenAiMessage({
    required this.role,
    this.content,
    this.toolCalls,
    this.toolCallId,
    this.name,
  });

  final String role;
  final dynamic content;
  final List<Map<String, dynamic>>? toolCalls;
  final String? toolCallId;
  final String? name;

  Map<String, dynamic> toJson() => {
    'role': role,
    if (content != null) 'content': content,
    if (toolCalls != null && toolCalls!.isNotEmpty) 'tool_calls': toolCalls,
    if (toolCallId != null) 'tool_call_id': toolCallId,
    if (name != null) 'name': name,
  };
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
  final List<dynamic> input;
  final bool stream;
  final double temperature;
  final bool store;
  final List<Map<String, dynamic>> tools;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toJson() {
    final List<dynamic> mappedInput;
    if (input.every((item) => item is OpenAiMessage)) {
      mappedInput = OpenAiResponsesInput.fromMessages(
        input.cast<OpenAiMessage>(),
      );
    } else {
      mappedInput = input.map((message) {
        if (message is OpenAiMessage) {
          final mapped = OpenAiResponsesInput.fromMessages([message]);
          return mapped.isNotEmpty ? mapped.first : message.toJson();
        }
        if (message is Map<String, dynamic>) return message;
        return (message as dynamic).toJson();
      }).toList();
    }

    return {
      'model': model,
      'input': mappedInput,
      'stream': stream,
      'temperature': temperature,
      'store': store,
      ...extra,
      if (tools.isNotEmpty) 'tools': tools,
    };
  }
}

/// Helpers for mapping messages to OpenAI Responses API input format.
final class OpenAiResponsesInput {
  const OpenAiResponsesInput._();

  static List<Map<String, dynamic>> fromMessages(List<OpenAiMessage> messages) {
    final result = <Map<String, dynamic>>[];
    for (final message in messages) {
      if (message.role == 'tool' && message.toolCallId != null) {
        result.add({
          'type': 'function_call_output',
          'call_id': message.toolCallId,
          'output': message.content?.toString() ?? '',
        });
      } else if (message.role == 'assistant' &&
          message.toolCalls != null &&
          message.toolCalls!.isNotEmpty) {
        final text = message.content?.toString().trim();
        if (text != null && text.isNotEmpty) {
          result.add({'role': 'assistant', 'content': message.content});
        }
        for (final call in message.toolCalls!) {
          final function = call['function'] as Map<String, dynamic>? ?? {};
          result.add({
            'type': 'function_call',
            'call_id': call['id'] ?? '',
            'name': function['name'] ?? call['name'] ?? '',
            'arguments': function['arguments'] ?? call['arguments'] ?? '',
          });
        }
      } else {
        // Discard empty assistant messages with no tool calls to protect against 500 errors
        if (message.role == 'assistant') {
          final text = message.content?.toString().trim();
          if (text == null || text.isEmpty) continue;
        }
        result.add(message.toJson());
      }
    }
    return result;
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
