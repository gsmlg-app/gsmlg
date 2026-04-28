import 'dart:async';
import 'dart:convert';

import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/inference.dart';
import '../models/message.dart';
import '../models/model_config.dart';

/// Repository for OpenAI-compatible remote LLM chat completion APIs.
class RemoteLlmRepository {
  RemoteLlmRepository({
    required VaultRepository vault,
    http.Client? client,
  })  : _vault = vault,
        _client = client ?? http.Client(),
        _ownsClient = client == null;

  final VaultRepository _vault;
  http.Client _client;
  final bool _ownsClient;

  static const _accountKeyPrefix = 'service_account_';

  /// Whether the configured account has an API key in secure storage.
  Future<bool> isReady(ModelConfig config) async {
    if (config.remoteUsesDummyToken && config.remoteBaseUrl.trim().isNotEmpty) {
      return true;
    }
    final accountId = config.remoteAccountId;
    if (accountId == null) return false;
    final apiKey = await _vault.read(key: _vaultKey(accountId));
    return apiKey != null && apiKey.trim().isNotEmpty;
  }

  Future<List<String>> listModels(ModelConfig config) async {
    final apiKey = await _apiKeyFor(config);
    final response = await _client.get(
      _modelsUri(config.remoteBaseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RemoteLlmException(
        'Failed to load models (${response.statusCode}): '
        '${_shortenErrorBody(response.body)}',
      );
    }

    final decoded = jsonDecode(response.body);
    final rawModels =
        decoded is Map<String, dynamic> ? decoded['data'] : decoded;
    if (rawModels is! List) {
      throw const RemoteLlmException('Models response did not contain a list.');
    }

    final models = <String>[];
    for (final item in rawModels) {
      final id = switch (item) {
        {'id': final String id} => id,
        final String id => id,
        _ => null,
      };
      if (id != null && id.trim().isNotEmpty) {
        models.add(id.trim());
      }
    }
    models.sort();
    return models;
  }

  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
  }) async* {
    final apiKey = await _apiKeyFor(config);
    final request = http.Request(
      'POST',
      _chatCompletionsUri(config.remoteBaseUrl),
    )
      ..headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': config.remoteStreamingEnabled
            ? 'text/event-stream'
            : 'application/json',
      })
      ..body = jsonEncode(_requestBody(messages, config, tools: tools));

    final response = await _client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw RemoteLlmException(
        'Remote LLM request failed (${response.statusCode}): '
        '${_shortenErrorBody(body)}',
      );
    }

    if (!config.remoteStreamingEnabled) {
      final body = await response.stream.bytesToString();
      for (final chunk in _chunksFromNonStreamingResponse(body)) {
        yield chunk;
      }
      return;
    }

    final toolCallBuffers = <int, _RemoteToolCallBuffer>{};
    final thinkTagParser = _ThinkTagParser();
    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;

      final data = trimmed.substring(5).trim();
      if (data == '[DONE]') {
        for (final chunk in thinkTagParser.close()) {
          yield chunk;
        }
        final toolCall = _toolCallChunkFromBuffers(toolCallBuffers);
        if (toolCall != null) yield toolCall;
        return;
      }

      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) continue;

      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) continue;
      final first = choices.first;
      if (first is! Map<String, dynamic>) continue;

      final finishReason = _stringValue(first['finish_reason']);
      final delta = first['delta'];
      if (delta is Map<String, dynamic>) {
        _collectToolCallDeltas(toolCallBuffers, delta['tool_calls']);
        _collectLegacyFunctionCallDelta(
          toolCallBuffers,
          delta['function_call'],
        );

        final text = _contentString(delta['content']);
        if (text != null && text.isNotEmpty) {
          for (final chunk in thinkTagParser.add(text)) {
            yield chunk;
          }
        }

        final thinking = _stringValue(delta['reasoning_content']) ??
            _stringValue(delta['reasoning']);
        if (thinking != null && thinking.isNotEmpty) {
          yield ChatThinkingChunk(thinking);
        }
      }

      if (finishReason == 'tool_calls' || finishReason == 'function_call') {
        for (final chunk in thinkTagParser.close()) {
          yield chunk;
        }
        final toolCall = _toolCallChunkFromBuffers(toolCallBuffers);
        if (toolCall != null) yield toolCall;
        return;
      }
    }
  }

  Future<void> stopGeneration() async {
    if (!_ownsClient) return;
    _client.close();
    _client = http.Client();
  }

  Future<void> dispose() async {
    if (_ownsClient) _client.close();
  }

  Future<String> _apiKeyFor(ModelConfig config) async {
    if (config.remoteUsesDummyToken) {
      return 'dummy';
    }

    final accountId = config.remoteAccountId;
    if (accountId == null) {
      throw const RemoteLlmException('Select a remote LLM account first.');
    }

    final apiKey = await _vault.read(key: _vaultKey(accountId));
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const RemoteLlmException(
        'The selected remote LLM account is missing an API key.',
      );
    }
    return apiKey.trim();
  }

  Map<String, dynamic> _requestBody(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
  }) {
    final body = {
      'model': config.remoteModel.trim(),
      'messages': _toRemoteMessages(messages),
      'stream': config.remoteStreamingEnabled,
      'temperature': config.temperature,
      'max_tokens': config.maxTokens,
    };
    if (config.remoteProvider == RemoteLlmProvider.deepSeek) {
      final effort = config.remoteThinkingEffort.deepSeekReasoningEffort;
      body['thinking'] = {
        'type': effort == null ? 'disabled' : 'enabled',
      };
      if (effort != null) {
        body['reasoning_effort'] = effort;
        body.remove('temperature');
      }
    }
    if (tools.isNotEmpty) {
      body['tools'] = tools;
    }
    return body;
  }

  List<Map<String, String>> _toRemoteMessages(List<Message> messages) {
    final result = <Map<String, String>>[];
    for (final message in messages) {
      if (message is AssistantMessage && message.isStreaming) continue;

      final role = switch (message) {
        SystemMessage() => 'system',
        UserMessage() => 'user',
        AssistantMessage() => 'assistant',
        ToolResponseMessage() => 'tool',
      };

      if (role == 'tool') {
        final toolName =
            message is ToolResponseMessage ? ' for ${message.toolName}' : '';
        result.add({
          'role': 'user',
          'content': 'Tool result$toolName: ${message.content}',
        });
      } else {
        result.add({'role': role, 'content': message.content});
      }
    }
    return result;
  }

  Uri _chatCompletionsUri(String baseUrl) {
    final uri = Uri.parse(baseUrl.trim());
    final normalizedPath = uri.path.endsWith('/chat/completions')
        ? uri.path
        : '${_trimTrailingSlash(uri.path)}/chat/completions';
    return uri.replace(path: normalizedPath);
  }

  Uri _modelsUri(String baseUrl) {
    final uri = Uri.parse(baseUrl.trim());
    final normalizedPath = uri.path.endsWith('/models')
        ? uri.path
        : '${_trimTrailingSlash(uri.path)}/models';
    return uri.replace(path: normalizedPath);
  }

  List<ChatGenerationChunk> _chunksFromNonStreamingResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return const [];
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return const [];
    final first = choices.first;
    if (first is! Map<String, dynamic>) return const [];
    final message = first['message'];
    if (message is! Map<String, dynamic>) return const [];

    final chunks = <ChatGenerationChunk>[];
    final thinking = _stringValue(message['reasoning_content']) ??
        _stringValue(message['reasoning']);
    if (thinking != null && thinking.isNotEmpty) {
      chunks.add(ChatThinkingChunk(thinking));
    }

    final content = _contentString(message['content']);
    if (content != null && content.isNotEmpty) {
      chunks.addAll(_ThinkTagParser.parse(content));
    }

    final buffers = <int, _RemoteToolCallBuffer>{};
    _collectToolCallDeltas(buffers, message['tool_calls']);
    _collectLegacyFunctionCallDelta(buffers, message['function_call']);
    final toolCall = _toolCallChunkFromBuffers(buffers);
    if (toolCall != null) chunks.add(toolCall);

    return chunks;
  }

  String _vaultKey(int id) => '$_accountKeyPrefix$id';

  String _trimTrailingSlash(String value) {
    if (value.isEmpty || value == '/') return '';
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  String? _stringValue(Object? value) => value is String ? value : null;

  String? _contentString(Object? value) {
    if (value is String) return value;
    if (value is! List) return null;

    final buffer = StringBuffer();
    for (final item in value) {
      if (item is String) {
        buffer.write(item);
      } else if (item is Map<String, dynamic>) {
        final text = _stringValue(item['text']);
        if (text != null) buffer.write(text);
      }
    }
    return buffer.toString();
  }

  void _collectToolCallDeltas(
    Map<int, _RemoteToolCallBuffer> buffers,
    Object? rawToolCalls,
  ) {
    if (rawToolCalls is! List) return;

    for (var fallbackIndex = 0;
        fallbackIndex < rawToolCalls.length;
        fallbackIndex++) {
      final rawToolCall = rawToolCalls[fallbackIndex];
      if (rawToolCall is! Map<String, dynamic>) continue;

      final index = _intValue(rawToolCall['index']) ?? fallbackIndex;
      final buffer = buffers.putIfAbsent(
        index,
        _RemoteToolCallBuffer.new,
      );

      final function = rawToolCall['function'];
      if (function is! Map<String, dynamic>) continue;

      final name = _stringValue(function['name']);
      if (name != null && name.isNotEmpty) buffer.name = name;

      final arguments = _stringValue(function['arguments']);
      if (arguments != null) buffer.arguments.write(arguments);
    }
  }

  void _collectLegacyFunctionCallDelta(
    Map<int, _RemoteToolCallBuffer> buffers,
    Object? rawFunctionCall,
  ) {
    if (rawFunctionCall is! Map<String, dynamic>) return;

    final buffer = buffers.putIfAbsent(0, _RemoteToolCallBuffer.new);
    final name = _stringValue(rawFunctionCall['name']);
    if (name != null && name.isNotEmpty) buffer.name = name;

    final arguments = _stringValue(rawFunctionCall['arguments']);
    if (arguments != null) buffer.arguments.write(arguments);
  }

  ChatFunctionCallChunk? _toolCallChunkFromBuffers(
    Map<int, _RemoteToolCallBuffer> buffers,
  ) {
    final indexes = buffers.keys.toList()..sort();
    for (final index in indexes) {
      final buffer = buffers[index]!;
      final name = buffer.name?.trim();
      if (name == null || name.isEmpty) continue;
      return ChatFunctionCallChunk(
        name: name,
        args: _decodeToolArgs(buffer.arguments.toString()),
      );
    }
    return null;
  }

  Map<String, dynamic> _decodeToolArgs(String arguments) {
    final trimmed = arguments.trim();
    if (trimmed.isEmpty) return const {};

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'value': decoded};
    } catch (_) {
      return {'raw': trimmed};
    }
  }

  int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _shortenErrorBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'empty response body';
    if (trimmed.length <= 500) return trimmed;
    return '${trimmed.substring(0, 500)}...';
  }
}

class _ThinkTagParser {
  static const _startTag = '<think>';
  static const _endTag = '</think>';

  var _buffer = '';
  var _inThinkBlock = false;

  static List<ChatGenerationChunk> parse(String text) {
    final parser = _ThinkTagParser();
    return [...parser.add(text), ...parser.close()];
  }

  List<ChatGenerationChunk> add(String text) {
    if (text.isEmpty) return const [];
    _buffer += text;
    return _drain(complete: false);
  }

  List<ChatGenerationChunk> close() {
    return _drain(complete: true);
  }

  List<ChatGenerationChunk> _drain({required bool complete}) {
    final chunks = <ChatGenerationChunk>[];

    while (_buffer.isNotEmpty) {
      final marker = _inThinkBlock ? _endTag : _startTag;
      final markerIndex = _buffer.indexOf(marker);
      if (markerIndex != -1) {
        _emit(chunks, _buffer.substring(0, markerIndex));
        _buffer = _buffer.substring(markerIndex + marker.length);
        _inThinkBlock = !_inThinkBlock;
        continue;
      }

      final keep = complete ? 0 : _trailingMarkerPrefixLength(_buffer, marker);
      final emitLength = _buffer.length - keep;
      if (emitLength > 0) {
        _emit(chunks, _buffer.substring(0, emitLength));
        _buffer = _buffer.substring(emitLength);
      }
      break;
    }

    return chunks;
  }

  int _trailingMarkerPrefixLength(String text, String marker) {
    final max =
        text.length < marker.length - 1 ? text.length : marker.length - 1;
    for (var length = max; length > 0; length -= 1) {
      if (marker.startsWith(text.substring(text.length - length))) {
        return length;
      }
    }
    return 0;
  }

  void _emit(List<ChatGenerationChunk> chunks, String text) {
    if (text.isEmpty) return;
    chunks.add(_inThinkBlock ? ChatThinkingChunk(text) : ChatTextChunk(text));
  }
}

class _RemoteToolCallBuffer {
  String? name;
  final arguments = StringBuffer();
}

class RemoteLlmException implements Exception {
  const RemoteLlmException(this.message);

  final String message;

  @override
  String toString() => message;
}
