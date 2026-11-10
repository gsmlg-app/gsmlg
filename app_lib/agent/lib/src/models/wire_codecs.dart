import 'dart:typed_data';

import 'package:app_logging/app_logging.dart' show LogContext;

import '../agent/agent_invocation.dart';
import 'agent_definition.dart';
import 'agent_metadata.dart';
import 'conversation.dart';
import 'inference.dart';
import 'message.dart';
import 'model_config.dart';

/// Plain-map codecs so models can cross isolate boundaries. Only maps, lists,
/// primitives and [Uint8List] are produced; times are epoch microseconds.

Map<String, Object?> _asMap(Object? v) => (v as Map).cast<String, Object?>();

Map<String, Object?> _timeToWire(DateTime t) => {
  'us': t.microsecondsSinceEpoch,
  'utc': t.isUtc,
};

DateTime _timeFromWire(Object? v) {
  final m = _asMap(v);
  return DateTime.fromMicrosecondsSinceEpoch(
    m['us'] as int,
    isUtc: m['utc'] as bool? ?? false,
  );
}

Uint8List? _bytes(Object? v) => switch (v) {
  null => null,
  Uint8List() => v,
  List() => Uint8List.fromList(v.cast<int>()),
  _ => throw ArgumentError('Not bytes: ${v.runtimeType}'),
};

extension ChatAttachmentWire on ChatAttachment {
  Map<String, Object?> toWire() => {
    'id': id,
    'name': name,
    'sizeBytes': sizeBytes,
    'mimeType': mimeType,
    'bytes': bytes,
  };
}

ChatAttachment chatAttachmentFromWire(Map<String, Object?> w) => ChatAttachment(
  id: w['id'] as String,
  name: w['name'] as String,
  sizeBytes: w['sizeBytes'] as int?,
  mimeType: w['mimeType'] as String?,
  bytes: _bytes(w['bytes']),
);

extension ChatResponseInfoWire on ChatResponseInfo {
  Map<String, Object?> toWire() => {
    'outputTokens': outputTokens,
    'contextTokens': contextTokens,
    'maxOutputTokens': maxOutputTokens,
    'durationUs': duration.inMicroseconds,
    'timeToFirstTokenUs': timeToFirstToken?.inMicroseconds,
  };
}

ChatResponseInfo chatResponseInfoFromWire(Map<String, Object?> w) {
  final ttft = w['timeToFirstTokenUs'] as int?;
  return ChatResponseInfo(
    outputTokens: w['outputTokens'] as int,
    contextTokens: w['contextTokens'] as int?,
    maxOutputTokens: w['maxOutputTokens'] as int?,
    duration: Duration(microseconds: w['durationUs'] as int),
    timeToFirstToken: ttft == null ? null : Duration(microseconds: ttft),
  );
}

extension MessageWire on Message {
  Map<String, Object?> toWire() {
    final base = <String, Object?>{
      'kind': switch (this) {
        UserMessage() => 'user',
        AssistantMessage() => 'assistant',
        SystemMessage() => 'system',
        ToolResponseMessage() => 'tool_response',
      },
      'id': id,
      'content': content,
      'conversationId': conversationId,
      'timestamp': _timeToWire(timestamp),
    };
    return switch (this) {
      final UserMessage m => {
        ...base,
        'imageBytes': m.imageBytes,
        'audioBytes': m.audioBytes,
        'attachments': [for (final a in m.attachments) a.toWire()],
      },
      final AssistantMessage m => {
        ...base,
        'isStreaming': m.isStreaming,
        'completedSuccessfully': m.completedSuccessfully,
        'tokenCount': m.tokenCount,
        'thinkingContent': m.thinkingContent,
        'responseInfo': m.responseInfo?.toWire(),
        'agentMetadata': m.agentMetadata,
      },
      SystemMessage() => base,
      final ToolResponseMessage m => {
        ...base,
        'toolName': m.toolName,
        'toolCallId': m.toolCallId,
        'isError': m.isError,
        'agentMetadata': m.agentMetadata,
      },
    };
  }
}

Message messageFromWire(Map<String, Object?> w) {
  final id = w['id'] as String;
  final content = w['content'] as String;
  final conversationId = w['conversationId'] as String;
  final timestamp = _timeFromWire(w['timestamp']);
  return switch (w['kind']) {
    'user' => UserMessage(
      id: id,
      content: content,
      conversationId: conversationId,
      timestamp: timestamp,
      imageBytes: _bytes(w['imageBytes']),
      audioBytes: _bytes(w['audioBytes']),
      attachments: [
        for (final a in (w['attachments'] as List? ?? const []))
          chatAttachmentFromWire(_asMap(a)),
      ],
    ),
    'assistant' => AssistantMessage(
      id: id,
      content: content,
      conversationId: conversationId,
      timestamp: timestamp,
      isStreaming: w['isStreaming'] as bool? ?? false,
      completedSuccessfully: w['completedSuccessfully'] as bool? ?? true,
      tokenCount: w['tokenCount'] as int?,
      thinkingContent: w['thinkingContent'] as String?,
      responseInfo: w['responseInfo'] == null
          ? null
          : chatResponseInfoFromWire(_asMap(w['responseInfo'])),
      agentMetadata: w['agentMetadata'] as String?,
    ),
    'system' => SystemMessage(
      id: id,
      content: content,
      conversationId: conversationId,
      timestamp: timestamp,
    ),
    'tool_response' => ToolResponseMessage(
      id: id,
      content: content,
      conversationId: conversationId,
      timestamp: timestamp,
      toolName: w['toolName'] as String,
      toolCallId: w['toolCallId'] as String?,
      isError: w['isError'] as bool? ?? false,
      agentMetadata: w['agentMetadata'] as String?,
    ),
    final k => throw ArgumentError('Unknown message kind: $k'),
  };
}

extension ConversationWire on Conversation {
  Map<String, Object?> toWire() => {
    'id': id,
    'title': title,
    'titleSource': titleSource,
    'titleRevision': titleRevision,
    'contentRevision': contentRevision,
    'createdAt': _timeToWire(createdAt),
    'updatedAt': _timeToWire(updatedAt),
    'messages': [for (final m in messages) m.toWire()],
    'systemPrompt': systemPrompt,
    'agentId': agentId,
  };
}

Conversation conversationFromWire(Map<String, Object?> w) => Conversation(
  id: w['id'] as String,
  title: w['title'] as String,
  titleSource: w['titleSource'] as String? ?? 'manual',
  titleRevision: w['titleRevision'] as int? ?? 0,
  contentRevision: w['contentRevision'] as int? ?? 0,
  createdAt: _timeFromWire(w['createdAt']),
  updatedAt: _timeFromWire(w['updatedAt']),
  messages: [
    for (final m in (w['messages'] as List? ?? const []))
      messageFromWire(_asMap(m)),
  ],
  systemPrompt: w['systemPrompt'] as String?,
  agentId: w['agentId'] as String?,
);

extension ModelConfigWire on ModelConfig {
  Map<String, Object?> toWire() => modelConfigToJson(this);
}

ModelConfig modelConfigFromWire(Map<String, Object?> w) =>
    modelConfigFromJson(w);

extension AgentMessageMetadataWire on AgentMessageMetadata {
  Map<String, Object?> toWire() => toJson().cast<String, Object?>();
}

AgentMessageMetadata agentMessageMetadataFromWire(Map<String, Object?> w) =>
    AgentMessageMetadata.fromJson(w);

extension ToolInvocationReceiptWire on ToolInvocationReceipt {
  Map<String, Object?> toWire() => toJson().cast<String, Object?>();
}

ToolInvocationReceipt toolInvocationReceiptFromWire(Map<String, Object?> w) =>
    ToolInvocationReceipt.fromJson(w);

extension LogContextWire on LogContext {
  Map<String, Object?> toWire() => toJson();
}

LogContext logContextFromWire(Map<String, Object?> w) => LogContext.fromJson(w);

extension ChatGenerationChunkWire on ChatGenerationChunk {
  Map<String, Object?> toWire() => switch (this) {
    ChatTextChunk(:final text) => {'kind': 'text', 'text': text},
    ChatThinkingChunk(:final content) => {
      'kind': 'thinking',
      'content': content,
    },
    ChatFunctionCallChunk(:final name, :final args, :final id, :final index) =>
      {
        'kind': 'functionCall',
        'name': name,
        'args': args,
        'id': id,
        'index': index,
      },
  };
}

ChatGenerationChunk chatGenerationChunkFromWire(Map<String, Object?> w) =>
    switch (w['kind']) {
      'text' => ChatTextChunk(w['text'] as String),
      'thinking' => ChatThinkingChunk(w['content'] as String),
      'functionCall' => ChatFunctionCallChunk(
        name: w['name'] as String,
        args: Map<String, dynamic>.from(w['args'] as Map),
        id: w['id'] as String?,
        index: w['index'] as int?,
      ),
      final k => throw ArgumentError('Unknown chunk kind: $k'),
    };
