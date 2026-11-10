import 'dart:convert';

import 'package:app_agent/app_agent.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model, temperature and top-k tiles for an agent's [config].
///
/// Edits are reported through [onChanged]; the caller decides when to save.
class AgentModelConfigTiles extends StatelessWidget {
  const AgentModelConfigTiles({
    required this.config,
    required this.onChanged,
    super.key,
  });

  final ModelConfig config;
  final ValueChanged<ModelConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.smart_toy),
          title: Text(l10n.agentModelTitle),
          subtitle: Text(agentModelLabel(context, config)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showModelPicker(context),
        ),
        if (_supportsSamplingControls(config)) ...[
          ListTile(
            leading: const Icon(Icons.thermostat),
            title: Text(l10n.agentModelTemperature),
            subtitle: Text(l10n.agentModelTemperatureDescription),
            trailing: Text(config.temperature.toStringAsFixed(2)),
            onTap: () => _showTemperatureDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.filter_list),
            title: Text(l10n.agentModelTopK),
            subtitle: Text(l10n.agentModelTopKDescription),
            trailing: Text('${config.topK}'),
            onTap: () => _showTopKDialog(context),
          ),
        ],
      ],
    );
  }

  static bool _supportsSamplingControls(ModelConfig config) {
    return config.inferenceMode == ChatInferenceMode.local ||
        config.remoteProvider == RemoteLlmProvider.openAiCompatible;
  }

  void _showModelPicker(BuildContext context) {
    final choices = configuredAgentModels(context);
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: choices.isEmpty
            ? ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.agentModelNone),
                subtitle: Text(l10n.agentModelNoneDescription),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final choice in choices)
                      ListTile(
                        leading: Icon(choice.icon),
                        title: Text(choice.title),
                        subtitle: choice.subtitle == null
                            ? null
                            : Text(choice.subtitle!),
                        onTap: () {
                          onChanged(applyModelChoice(config, choice));
                          Navigator.pop(sheetContext);
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  void _showTemperatureDialog(BuildContext context) {
    var temperature = config.temperature;
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.agentModelTemperature),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(temperature.toStringAsFixed(2)),
              Slider(
                value: temperature,
                min: 0.0,
                max: 2.0,
                divisions: 40,
                label: temperature.toStringAsFixed(2),
                onChanged: (v) => setDialogState(() => temperature = v),
              ),
              Text(
                l10n.agentModelTemperatureHelp,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                onChanged(config.copyWith(temperature: temperature));
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopKDialog(BuildContext context) {
    var topK = config.topK;
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.agentModelTopK),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$topK'),
              Slider(
                value: topK.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: '$topK',
                onChanged: (v) => setDialogState(() => topK = v.round()),
              ),
              Text(
                l10n.agentModelTopKHelp,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                onChanged(config.copyWith(topK: topK));
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

/// Human-readable label of the model an agent [config] uses.
String agentModelLabel(BuildContext context, ModelConfig config) {
  return switch (config.inferenceMode) {
    ChatInferenceMode.local =>
      config.localModelId != null
          ? (GemmaModelInfo.findById(config.localModelId!)?.displayName ??
                config.localModelId!)
          : context.l10n.agentModelSelectLocal,
    ChatInferenceMode.remote =>
      '${config.remoteProvider.displayName} · '
          '${config.remoteApiType.displayName} · ${config.remoteModel}',
  };
}

/// A model the user configured (installed local model, Backplane model or
/// remote provider model) that an agent can pick.
class AgentModelChoice {
  const AgentModelChoice({
    required this.title,
    required this.icon,
    required this.config,
    this.subtitle,
    this.localModelId,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final ModelConfig config;
  final String? localModelId;
}

/// Applies a picked model onto the agent's current config so the agent's
/// other settings (temperature, top-k, ...) are preserved.
ModelConfig applyModelChoice(ModelConfig base, AgentModelChoice choice) {
  final config = choice.config;
  if (config.inferenceMode == ChatInferenceMode.local) {
    return base.copyWith(
      inferenceMode: ChatInferenceMode.local,
      localModelId: choice.localModelId,
      clearManagedRemote: true,
    );
  }
  return base.copyWith(
    inferenceMode: ChatInferenceMode.remote,
    remoteProvider: config.remoteProvider,
    remoteApiType: config.remoteApiType,
    remoteAccountId: config.remoteAccountId,
    clearRemoteAccount: config.remoteAccountId == null,
    remoteBaseUrl: config.remoteBaseUrl,
    remoteModel: config.remoteModel,
    remoteAuthType: config.remoteAuthType,
    remoteAuthHeaderName: config.remoteAuthHeaderName,
    clearRemoteAuthHeaderName: config.remoteAuthHeaderName == null,
    managedRemoteId: config.managedRemoteId,
    clearManagedRemote: config.managedRemoteId == null,
  );
}

/// All models an agent can currently pick.
List<AgentModelChoice> configuredAgentModels(BuildContext context) {
  return [
    ..._configuredLocalModels(context),
    ..._configuredRemoteModels(context),
  ];
}

List<AgentModelChoice> _configuredLocalModels(BuildContext context) {
  final GemmaModelState state;
  try {
    state = context.read<GemmaModelBloc>().state;
  } catch (_) {
    return const <AgentModelChoice>[];
  }
  final modelIds = <String>{};
  for (final installedId in state.installedModels) {
    final normalized = installedId.trim();
    if (normalized.isNotEmpty) {
      modelIds.add(normalized);
    }
  }

  if (modelIds.isEmpty) {
    return const <AgentModelChoice>[];
  }
  final config = ModelConfig.platformDefaultConfig.copyWith(
    inferenceMode: ChatInferenceMode.local,
  );
  return [
    for (final modelId in modelIds)
      AgentModelChoice(
        title: GemmaModelInfo.findById(modelId)?.displayName ?? modelId,
        subtitle: context.l10n.agentModelLocal,
        icon: Icons.memory,
        config: config.copyWith(localModelId: modelId),
        localModelId: modelId,
      ),
  ];
}

List<AgentModelChoice> _configuredRemoteModels(BuildContext context) {
  final preferences = context.read<SharedPreferences>();
  final providers =
      preferences.getStringList('remote_model_provider_profiles') ??
      const <String>[];
  final choices = <AgentModelChoice>[];
  final backplane = BackplaneSettingsBloc.readSettings(preferences);
  for (final model in backplane.models) {
    choices.add(
      AgentModelChoice(
        title: model,
        subtitle: 'Backplane',
        icon: Icons.cloud_queue,
        config: backplane.modelConfig(model),
      ),
    );
  }

  for (final raw in providers) {
    final provider = _RemoteProviderConfig.fromJson(raw);
    if (provider == null) continue;
    final config = _remoteConfigForProvider(provider);
    final models = _remoteModelsFor(preferences, config);
    final effectiveModels = models.isNotEmpty
        ? models.toSet()
        : {
            if (provider.defaultModel.trim().isNotEmpty)
              provider.defaultModel.trim(),
          };

    for (final model in effectiveModels) {
      choices.add(
        AgentModelChoice(
          title: model,
          subtitle: provider.name,
          icon: provider.isLocal ? Icons.dns : Icons.cloud_queue,
          config: config.copyWith(remoteModel: model),
        ),
      );
    }
  }

  return choices;
}

ModelConfig _remoteConfigForProvider(_RemoteProviderConfig provider) {
  return ModelConfig.defaultConfig.copyWith(
    inferenceMode: ChatInferenceMode.remote,
    remoteProvider: provider.remoteProvider,
    remoteApiType: provider.remoteApiType,
    remoteAccountId: provider.useDummyToken
        ? ModelConfig.dummyRemoteAccountId
        : provider.accountId,
    clearRemoteAccount: !provider.useDummyToken && provider.accountId == null,
    remoteBaseUrl: provider.baseUrl,
    remoteModel: provider.defaultModel,
    remoteAuthType: provider.authType,
    remoteAuthHeaderName: provider.authHeaderName,
    clearRemoteAuthHeaderName: provider.authType != RemoteAuthType.customHeader,
  );
}

List<String> _remoteModelsFor(
  SharedPreferences preferences,
  ModelConfig config,
) {
  final providerModelsKey =
      'remote_provider_models_${config.remoteProvider.name}_'
      '${config.remoteApiType.name}_${config.remoteAccountId ?? 'none'}_'
      '${config.remoteBaseUrl.trim()}';
  final models = {
    ...(preferences.getStringList(providerModelsKey) ?? const <String>[]),
    ...(preferences.getStringList(config.remoteVisibleModelsKey) ??
        const <String>[]),
  }.where((model) => model.trim().isNotEmpty).map((model) => model.trim());
  return models.toList()..sort();
}

class _RemoteProviderConfig {
  const _RemoteProviderConfig({
    required this.name,
    required this.baseUrl,
    required this.defaultModel,
    required this.remoteProvider,
    required this.remoteApiType,
    required this.authType,
    this.accountId,
    this.useDummyToken = false,
    this.authHeaderName,
  });

  factory _RemoteProviderConfig.fromMap(Map<String, Object?> map) {
    final remoteProvider = _parseProvider(map['remoteProvider'] as String?);
    final remoteApiType = _parseApiType(
      map['remoteApiType'] as String?,
      remoteProvider,
    );
    return _RemoteProviderConfig(
      name: map['name'] as String,
      baseUrl: map['baseUrl'] as String,
      defaultModel: map['defaultModel'] as String? ?? 'local-model',
      remoteProvider: remoteProvider,
      remoteApiType: remoteApiType,
      authType: _parseAuthType(map['authType'] as String?, remoteApiType),
      authHeaderName: map['authHeaderName'] as String?,
      accountId: map['accountId'] as int?,
      useDummyToken:
          map['useDummyToken'] as bool? ?? map['isLocal'] as bool? ?? false,
    );
  }

  static _RemoteProviderConfig? fromJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return null;
      return _RemoteProviderConfig.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  final String name;
  final String baseUrl;
  final String defaultModel;
  final RemoteLlmProvider remoteProvider;
  final RemoteLlmApiType remoteApiType;
  final RemoteAuthType authType;
  final String? authHeaderName;
  final int? accountId;
  final bool useDummyToken;

  bool get isLocal {
    final host = Uri.tryParse(baseUrl)?.host.toLowerCase();
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '0.0.0.0' ||
        host == '::1';
  }

  static RemoteLlmProvider _parseProvider(String? value) {
    for (final provider in RemoteLlmProvider.values) {
      if (provider.name == value) return provider;
    }
    return RemoteLlmProvider.openAiCompatible;
  }

  static RemoteLlmApiType _parseApiType(
    String? value,
    RemoteLlmProvider remoteProvider,
  ) {
    for (final apiType in RemoteLlmApiType.values) {
      if (apiType.name == value) return apiType;
    }
    return remoteProvider.defaultApiType;
  }

  static RemoteAuthType _parseAuthType(
    String? value,
    RemoteLlmApiType apiType,
  ) {
    for (final type in RemoteAuthType.values) {
      if (type.name == value) return type;
    }
    return apiType == RemoteLlmApiType.anthropicMessages
        ? RemoteAuthType.xApiKey
        : RemoteAuthType.bearerToken;
  }
}
