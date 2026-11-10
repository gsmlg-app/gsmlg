import 'package:equatable/equatable.dart';

import 'inference.dart';
import 'model_config.dart';

/// A persisted, GPTs-style agent: a named bot with its own model settings.
class AgentDefinition extends Equatable {
  const AgentDefinition({
    required this.id,
    required this.name,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
    this.avatar,
    this.description,
    this.instructions,
    this.thinkingEnabled = false,
    this.allowedTools,
  });

  /// Rebuilds a definition from [toWire] output.
  factory AgentDefinition.fromWire(Map<String, Object?> wire) {
    return AgentDefinition(
      id: wire['id'] as String,
      name: wire['name'] as String,
      avatar: wire['avatar'] as String?,
      description: wire['description'] as String?,
      instructions: wire['instructions'] as String?,
      config: modelConfigFromJson(
        (wire['config'] as Map?)?.cast<String, Object?>(),
      ),
      thinkingEnabled: wire['thinkingEnabled'] as bool? ?? false,
      allowedTools: (wire['allowedTools'] as List?)?.cast<String>(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(wire['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(wire['updatedAt'] as int),
    );
  }

  final String id;
  final String name;

  /// Emoji avatar.
  final String? avatar;
  final String? description;
  final String? instructions;
  final ModelConfig config;
  final bool thinkingEnabled;

  /// Tool names this agent may use; null means all tools.
  final List<String>? allowedTools;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgentDefinition copyWith({
    String? name,
    String? avatar,
    String? description,
    String? instructions,
    ModelConfig? config,
    bool? thinkingEnabled,
    List<String>? allowedTools,
    DateTime? updatedAt,
  }) {
    return AgentDefinition(
      id: id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      config: config ?? this.config,
      thinkingEnabled: thinkingEnabled ?? this.thinkingEnabled,
      allowedTools: allowedTools ?? this.allowedTools,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Plain map safe to send across isolates.
  Map<String, Object?> toWire() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'description': description,
    'instructions': instructions,
    'config': modelConfigToJson(config),
    'thinkingEnabled': thinkingEnabled,
    'allowedTools': allowedTools,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    description,
    instructions,
    config,
    thinkingEnabled,
    allowedTools,
    createdAt,
    updatedAt,
  ];
}

/// Canonical JSON shape for [ModelConfig] (matches the legacy
/// `chat_agents` SharedPreferences format).
Map<String, Object?> modelConfigToJson(ModelConfig config) => {
  'inferenceMode': config.inferenceMode.name,
  'modelType': config.modelType.name,
  'customModelPath': config.customModelPath,
  'localModelId': config.localModelId,
  'maxTokens': config.maxTokens,
  'temperature': config.temperature,
  'topK': config.topK,
  'backend': config.backend.name,
  'remoteProvider': config.remoteProvider.name,
  'remoteApiType': config.remoteApiType.name,
  'remoteAccountId': config.remoteAccountId,
  'remoteBaseUrl': config.remoteBaseUrl,
  'remoteModel': config.remoteModel,
  'remoteAuthType': config.remoteAuthType.name,
  'remoteAuthHeaderName': config.remoteAuthHeaderName,
  'remoteStreamingEnabled': config.remoteStreamingEnabled,
  'remoteThinkingEffort': config.remoteThinkingEffort.name,
  'managedRemoteId': config.managedRemoteId,
};

/// Parses [modelConfigToJson] output; missing or unknown fields fall back to
/// defaults.
ModelConfig modelConfigFromJson(Map<String, Object?>? json) {
  if (json == null) return ModelConfig.platformDefaultConfig;
  const defaults = ModelConfig.defaultConfig;
  final provider = _enumFromName(
    RemoteLlmProvider.values,
    json['remoteProvider'],
    defaults.remoteProvider,
  );
  return ModelConfig(
    inferenceMode: _enumFromName(
      ChatInferenceMode.values,
      json['inferenceMode'],
      defaults.inferenceMode,
    ),
    modelType: _enumFromName(
      GemmaModelType.values,
      json['modelType'],
      defaults.modelType,
    ),
    customModelPath: json['customModelPath'] as String?,
    localModelId: json['localModelId'] as String?,
    maxTokens: json['maxTokens'] as int? ?? defaults.maxTokens,
    temperature:
        (json['temperature'] as num?)?.toDouble() ?? defaults.temperature,
    topK: json['topK'] as int? ?? defaults.topK,
    backend: json['backend'] == 'gpu'
        ? defaultGemmaBackendForCurrentPlatform()
        : _enumFromName(
            GemmaBackend.values,
            json['backend'],
            defaultGemmaBackendForCurrentPlatform(),
          ),
    remoteProvider: provider,
    remoteApiType: json['remoteApiType'] is String
        ? _enumFromName(
            RemoteLlmApiType.values,
            json['remoteApiType'],
            RemoteLlmApiType.openAiChatCompletions,
          )
        : provider.defaultApiType,
    remoteAccountId: json['remoteAccountId'] as int?,
    remoteBaseUrl: json['remoteBaseUrl'] as String? ?? defaults.remoteBaseUrl,
    remoteModel: json['remoteModel'] as String? ?? defaults.remoteModel,
    remoteAuthType: _enumFromName(
      RemoteAuthType.values,
      json['remoteAuthType'],
      defaults.remoteAuthType,
    ),
    remoteAuthHeaderName: json['remoteAuthHeaderName'] as String?,
    remoteStreamingEnabled:
        json['remoteStreamingEnabled'] as bool? ??
        defaults.remoteStreamingEnabled,
    remoteThinkingEffort: _enumFromName(
      RemoteThinkingEffort.values,
      json['remoteThinkingEffort'],
      defaults.remoteThinkingEffort,
    ),
    managedRemoteId: json['managedRemoteId'] as String?,
  ).withSupportedBackendForCurrentPlatform();
}

T _enumFromName<T extends Enum>(List<T> values, Object? name, T fallback) {
  if (name is! String) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
