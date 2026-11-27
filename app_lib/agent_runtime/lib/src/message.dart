import 'package:equatable/equatable.dart';

/// Content parts carried inside a [UserMessage] or [FunctionExecutionResult].
sealed class UserContentPart extends Equatable {
  const UserContentPart();

  Map<String, dynamic> toJson();

  factory UserContentPart.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'image' => ImagePart(
        json['data'] as String? ?? json['base64Data'] as String? ?? '',
        json['mimeType'] as String? ?? 'image/png',
      ),
      _ => TextPart(json['text'] as String? ?? ''),
    };
  }
}

final class TextPart extends UserContentPart {
  const TextPart(this.text);

  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};

  @override
  List<Object?> get props => [text];
}

final class ImagePart extends UserContentPart {
  const ImagePart(this.base64Data, this.mimeType);

  final String base64Data;
  final String mimeType;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image',
    'data': base64Data,
    'mimeType': mimeType,
  };

  @override
  List<Object?> get props => [base64Data, mimeType];
}

/// Token usage for a model turn (modeled after `Sigma.Ai.Message.usage`).
class ModelUsage extends Equatable {
  const ModelUsage({
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
    this.cachedTokens = 0,
    this.thoughtTokens = 0,
    this.model,
    this.timestamp,
  });

  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final int cachedTokens;
  final int thoughtTokens;
  final String? model;
  final int? timestamp;

  Map<String, dynamic> toJson() => {
    'promptTokens': promptTokens,
    'completionTokens': completionTokens,
    'totalTokens': totalTokens,
    if (cachedTokens != 0) 'cachedTokens': cachedTokens,
    if (thoughtTokens != 0) 'thoughtTokens': thoughtTokens,
    if (model != null) 'model': model,
    if (timestamp != null) 'timestamp': timestamp,
  };

  factory ModelUsage.fromJson(Map<String, dynamic> json) => ModelUsage(
    promptTokens: (json['promptTokens'] as num?)?.toInt() ?? 0,
    completionTokens: (json['completionTokens'] as num?)?.toInt() ?? 0,
    totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
    cachedTokens: (json['cachedTokens'] as num?)?.toInt() ?? 0,
    thoughtTokens: (json['thoughtTokens'] as num?)?.toInt() ?? 0,
    model: json['model'] as String?,
    timestamp: (json['timestamp'] as num?)?.toInt(),
  );

  @override
  List<Object?> get props => [
    promptTokens,
    completionTokens,
    totalTokens,
    cachedTokens,
    thoughtTokens,
    model,
    timestamp,
  ];
}

/// A function/tool invocation requested by the model.
class FunctionCall extends Equatable {
  const FunctionCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  final String id;
  final String name;
  final String arguments;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'arguments': arguments,
  };

  factory FunctionCall.fromJson(Map<String, dynamic> json) => FunctionCall(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    arguments: json['arguments'] as String? ?? '{}',
  );

  @override
  List<Object?> get props => [id, name, arguments];
}

/// Execution output for a single [FunctionCall], paired by [id].
class FunctionExecutionResult extends Equatable {
  const FunctionExecutionResult({
    required this.id,
    required this.name,
    this.arguments = '',
    required this.content,
    this.isError = false,
  });

  final String id;
  final String name;
  final String arguments;
  final List<UserContentPart> content;
  final bool isError;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'arguments': arguments,
    'isError': isError,
    'content': [for (final part in content) part.toJson()],
  };

  factory FunctionExecutionResult.fromJson(Map<String, dynamic> json) =>
      FunctionExecutionResult(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        arguments: json['arguments'] as String? ?? '',
        isError: json['isError'] as bool? ?? false,
        content: [
          for (final item in (json['content'] as List? ?? const []))
            UserContentPart.fromJson(Map<String, dynamic>.from(item as Map)),
        ],
      );

  @override
  List<Object?> get props => [id, name, arguments, content, isError];
}

/// Canonical LLM message in the agent history (modeled after `Sigma.Ai.Message`).
sealed class LLMMessage extends Equatable {
  const LLMMessage({this.timestamp});

  final int? timestamp;

  String get role;

  Map<String, dynamic> toJson();

  factory LLMMessage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? json['role'] as String?;
    return switch (type) {
      'system' => SystemMessage.fromJson(json),
      'user' => UserMessage.fromJson(json),
      'model' || 'assistant' => ModelMessage.fromJson(json),
      'function_execution_result' ||
      'tool_result' ||
      'tool' => FunctionExecutionResultMessage.fromJson(json),
      _ => throw ArgumentError('Unknown LLMMessage type: $type'),
    };
  }
}

final class SystemMessage extends LLMMessage {
  const SystemMessage(this.content, {super.timestamp});

  final String content;

  @override
  String get role => 'system';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'system',
    'role': role,
    'content': content,
    if (timestamp != null) 'timestamp': timestamp,
  };

  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage(
    json['content'] as String? ?? '',
    timestamp: (json['timestamp'] as num?)?.toInt(),
  );

  @override
  List<Object?> get props => [content, timestamp];
}

final class UserMessage extends LLMMessage {
  const UserMessage(this.contents, {super.timestamp});

  factory UserMessage.text(String text, {int? timestamp}) =>
      UserMessage([TextPart(text)], timestamp: timestamp);

  final List<UserContentPart> contents;

  @override
  String get role => 'user';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'user',
    'role': role,
    'contents': [for (final part in contents) part.toJson()],
    if (timestamp != null) 'timestamp': timestamp,
  };

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    final raw = json['contents'] ?? json['content'];
    if (raw is String) {
      return UserMessage([
        TextPart(raw),
      ], timestamp: (json['timestamp'] as num?)?.toInt());
    }
    return UserMessage([
      for (final item in (raw as List? ?? const []))
        UserContentPart.fromJson(Map<String, dynamic>.from(item as Map)),
    ], timestamp: (json['timestamp'] as num?)?.toInt());
  }

  @override
  List<Object?> get props => [contents, timestamp];
}

final class ModelMessage extends LLMMessage {
  const ModelMessage({
    required this.model,
    this.textOutput,
    this.thought,
    this.thoughtSignature,
    this.functionCalls = const [],
    this.responseId,
    this.stopReason,
    this.usage,
    super.timestamp,
  });

  final String model;
  final String? textOutput;
  final String? thought;
  final String? thoughtSignature;
  final List<FunctionCall> functionCalls;
  final String? responseId;
  final String? stopReason;
  final ModelUsage? usage;

  @override
  String get role => 'assistant';

  ModelMessage copyWith({
    String? model,
    String? textOutput,
    String? thought,
    String? thoughtSignature,
    List<FunctionCall>? functionCalls,
    String? responseId,
    String? stopReason,
    ModelUsage? usage,
    int? timestamp,
  }) => ModelMessage(
    model: model ?? this.model,
    textOutput: textOutput ?? this.textOutput,
    thought: thought ?? this.thought,
    thoughtSignature: thoughtSignature ?? this.thoughtSignature,
    functionCalls: functionCalls ?? this.functionCalls,
    responseId: responseId ?? this.responseId,
    stopReason: stopReason ?? this.stopReason,
    usage: usage ?? this.usage,
    timestamp: timestamp ?? this.timestamp,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'model',
    'role': role,
    'model': model,
    if (textOutput != null) 'textOutput': textOutput,
    if (thought != null) 'thought': thought,
    if (thoughtSignature != null) 'thoughtSignature': thoughtSignature,
    if (functionCalls.isNotEmpty)
      'functionCalls': [for (final fc in functionCalls) fc.toJson()],
    if (responseId != null) 'responseId': responseId,
    if (stopReason != null) 'stopReason': stopReason,
    if (usage != null) 'usage': usage!.toJson(),
    if (timestamp != null) 'timestamp': timestamp,
  };

  factory ModelMessage.fromJson(Map<String, dynamic> json) => ModelMessage(
    model: json['model'] as String? ?? 'assistant',
    textOutput: json['textOutput'] as String?,
    thought: json['thought'] as String?,
    thoughtSignature: json['thoughtSignature'] as String?,
    functionCalls: [
      for (final fc in (json['functionCalls'] as List? ?? const []))
        FunctionCall.fromJson(Map<String, dynamic>.from(fc as Map)),
    ],
    responseId: json['responseId'] as String?,
    stopReason: json['stopReason'] as String?,
    usage: json['usage'] is Map
        ? ModelUsage.fromJson(Map<String, dynamic>.from(json['usage'] as Map))
        : null,
    timestamp: (json['timestamp'] as num?)?.toInt(),
  );

  @override
  List<Object?> get props => [
    model,
    textOutput,
    thought,
    thoughtSignature,
    functionCalls,
    responseId,
    stopReason,
    usage,
    timestamp,
  ];
}

final class FunctionExecutionResultMessage extends LLMMessage {
  const FunctionExecutionResultMessage({
    required this.results,
    super.timestamp,
  });

  final List<FunctionExecutionResult> results;

  @override
  String get role => 'tool_result';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_execution_result',
    'role': role,
    'results': [for (final r in results) r.toJson()],
    if (timestamp != null) 'timestamp': timestamp,
  };

  factory FunctionExecutionResultMessage.fromJson(Map<String, dynamic> json) =>
      FunctionExecutionResultMessage(
        results: [
          for (final r in (json['results'] as List? ?? const []))
            FunctionExecutionResult.fromJson(
              Map<String, dynamic>.from(r as Map),
            ),
        ],
        timestamp: (json['timestamp'] as num?)?.toInt(),
      );

  @override
  List<Object?> get props => [results, timestamp];
}

/// Incremental provider stream frame wrapping a partial [ModelMessage].
class StreamingMessage {
  const StreamingMessage({this.modelMessage});

  final ModelMessage? modelMessage;
}
