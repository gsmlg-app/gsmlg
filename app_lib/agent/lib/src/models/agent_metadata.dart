import 'dart:convert';

/// Versioned metadata stored in `chat_message_table.agent_metadata`.
class AgentMessageMetadata {
  const AgentMessageMetadata({
    this.version = 1,
    this.toolCalls = const [],
    this.contentBlocks = const [],
    this.thought,
    this.thoughtSignature,
    this.responseId,
    this.model,
    this.toolCallId,
    this.toolName,
    this.toolArguments,
    this.isError,
    this.receiptStatus,
    this.microsecondTimestamp,
  });

  final int version;
  final List<Map<String, dynamic>> toolCalls;
  final List<Map<String, dynamic>> contentBlocks;
  final String? thought;
  final String? thoughtSignature;
  final String? responseId;
  final String? model;
  final String? toolCallId;
  final String? toolName;
  final String? toolArguments;
  final bool? isError;
  final String? receiptStatus;
  final int? microsecondTimestamp;

  Map<String, dynamic> toJson() => {
    'version': version,
    if (toolCalls.isNotEmpty) 'toolCalls': toolCalls,
    if (contentBlocks.isNotEmpty) 'contentBlocks': contentBlocks,
    if (thought != null) 'thought': thought,
    if (thoughtSignature != null) 'thoughtSignature': thoughtSignature,
    if (responseId != null) 'responseId': responseId,
    if (model != null) 'model': model,
    if (toolCallId != null) 'toolCallId': toolCallId,
    if (toolName != null) 'toolName': toolName,
    if (toolArguments != null) 'toolArguments': toolArguments,
    if (isError != null) 'isError': isError,
    if (receiptStatus != null) 'receiptStatus': receiptStatus,
    if (microsecondTimestamp != null)
      'microsecondTimestamp': microsecondTimestamp,
  };

  factory AgentMessageMetadata.fromJson(Map<String, dynamic> json) {
    return AgentMessageMetadata(
      version: json['version'] as int? ?? 1,
      toolCalls:
          (json['toolCalls'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      contentBlocks:
          (json['contentBlocks'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      thought: json['thought'] as String?,
      thoughtSignature: json['thoughtSignature'] as String?,
      responseId: json['responseId'] as String?,
      model: json['model'] as String?,
      toolCallId: json['toolCallId'] as String?,
      toolName: json['toolName'] as String?,
      toolArguments: json['toolArguments'] as String?,
      isError: json['isError'] as bool?,
      receiptStatus: json['receiptStatus'] as String?,
      microsecondTimestamp: json['microsecondTimestamp'] as int?,
    );
  }

  String encode() => jsonEncode(toJson());

  static AgentMessageMetadata? decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AgentMessageMetadata.fromJson(decoded);
      }
      if (decoded is Map) {
        return AgentMessageMetadata.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (_) {}
    return null;
  }
}
