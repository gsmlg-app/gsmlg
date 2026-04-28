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
    final accountId = config.remoteAccountId;
    if (accountId == null) return false;
    final apiKey = await _vault.read(key: _vaultKey(accountId));
    return apiKey != null && apiKey.trim().isNotEmpty;
  }

  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config,
  ) async* {
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
      ..body = jsonEncode(_requestBody(messages, config));

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
      final content = _contentFromNonStreamingResponse(body);
      if (content.isNotEmpty) yield ChatTextChunk(content);
      return;
    }

    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;

      final data = trimmed.substring(5).trim();
      if (data == '[DONE]') return;

      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) continue;

      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) continue;
      final first = choices.first;
      if (first is! Map<String, dynamic>) continue;

      final delta = first['delta'];
      if (delta is! Map<String, dynamic>) continue;

      final text = _stringValue(delta['content']);
      if (text != null && text.isNotEmpty) {
        yield ChatTextChunk(text);
      }

      final thinking = _stringValue(delta['reasoning_content']) ??
          _stringValue(delta['reasoning']);
      if (thinking != null && thinking.isNotEmpty) {
        yield ChatThinkingChunk(thinking);
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
    ModelConfig config,
  ) {
    return {
      'model': config.remoteModel.trim(),
      'messages': _toRemoteMessages(messages),
      'stream': config.remoteStreamingEnabled,
      'temperature': config.temperature,
      'max_tokens': config.maxTokens,
    };
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
        result.add({
          'role': 'user',
          'content': 'Tool result: ${message.content}',
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

  String _contentFromNonStreamingResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return '';
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return '';
    final first = choices.first;
    if (first is! Map<String, dynamic>) return '';
    final message = first['message'];
    if (message is! Map<String, dynamic>) return '';
    return _stringValue(message['content']) ?? '';
  }

  String _vaultKey(int id) => '$_accountKeyPrefix$id';

  String _trimTrailingSlash(String value) {
    if (value.isEmpty || value == '/') return '';
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  String? _stringValue(Object? value) => value is String ? value : null;

  String _shortenErrorBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'empty response body';
    if (trimmed.length <= 500) return trimmed;
    return '${trimmed.substring(0, 500)}...';
  }
}

class RemoteLlmException implements Exception {
  const RemoteLlmException(this.message);

  final String message;

  @override
  String toString() => message;
}
