// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatAgentsSettingsScreen extends StatefulWidget {
  static const name = 'ChatAgentsSettings';
  static const path = 'agents';

  const ChatAgentsSettingsScreen({super.key, this.agentId});

  final String? agentId;

  @override
  State<ChatAgentsSettingsScreen> createState() =>
      _ChatAgentsSettingsScreenState();
}

class ChatAgentSettingsScreen extends StatelessWidget {
  static const name = 'ChatAgentSettings';
  static const path = 'agent/:agentId';

  const ChatAgentSettingsScreen({required this.agentId, super.key});

  final String agentId;

  @override
  Widget build(BuildContext context) {
    return ChatAgentsSettingsScreen(agentId: agentId);
  }
}

class _ConfiguredModel {
  const _ConfiguredModel({
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

class _RemoteProviderConfig {
  const _RemoteProviderConfig({
    required this.id,
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
      id: map['id'] as String,
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

  final String id;
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

  static RemoteAuthType _defaultAuthTypeForApiType(RemoteLlmApiType apiType) {
    return apiType == RemoteLlmApiType.anthropicMessages
        ? RemoteAuthType.xApiKey
        : RemoteAuthType.bearerToken;
  }

  static RemoteAuthType _parseAuthType(
    String? value,
    RemoteLlmApiType apiType,
  ) {
    for (final type in RemoteAuthType.values) {
      if (type.name == value) return type;
    }
    return _defaultAuthTypeForApiType(apiType);
  }
}

class _ChatAgentsSettingsScreenState extends State<ChatAgentsSettingsScreen> {
  @override
  void initState() {
    super.initState();
    try {
      context.read<GemmaModelBloc>().add(const GemmaModelListInstalled());
    } catch (_) {
      // Some widget tests and route previews mount this screen without local
      // model management providers.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key('Settings'), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          title: Text(widget.agentId == null ? 'Agents' : 'Agent Settings'),
        ),
        body: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
          builder: (context, state) {
            final agentId = widget.agentId;
            ChatAgent? editingAgent;
            if (agentId != null) {
              editingAgent = _agentById(state, agentId);
              if (editingAgent == null) {
                return SettingsList(
                  sections: [
                    SettingsSection(
                      title: const Text('Chat Agent'),
                      tiles: [
                        SettingsTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Agent not found'),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }

            final currentConfig = editingAgent?.config ?? state.config;
            final currentSystemPrompt =
                editingAgent?.systemPrompt ?? state.defaultSystemPrompt;
            final currentSystemPromptPreview =
                currentSystemPrompt == null || currentSystemPrompt.isEmpty
                ? 'Not set'
                : '${currentSystemPrompt.substring(0, currentSystemPrompt.length.clamp(0, 30))}...';
            final currentThinkingEnabled =
                editingAgent?.thinkingEnabled ?? state.thinkingEnabled;

            return SettingsList(
              sections: [
                if (widget.agentId == null)
                  SettingsSection(
                    title: const Text('Chat Agents'),
                    tiles: [
                      SettingsTile.navigation(
                        leading: const Icon(Icons.person_add_alt_1),
                        title: const Text('Add Agent'),
                        description: const Text(
                          'Create a reusable assistant profile',
                        ),
                        onPressed: (_) => _createAgent(context),
                      ),
                      if (state.agents.isEmpty)
                        SettingsTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('No agents yet'),
                          description: const Text(
                            'Add an agent to configure a chat assistant.',
                          ),
                        )
                      else
                        ...state.agents.map(
                          (agent) => SettingsTile(
                            leading: IconButton(
                              icon: Icon(
                                state.activeAgentId == agent.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: state.activeAgentId == agent.id
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              tooltip: 'Set as default agent',
                              onPressed: () {
                                context.read<ChatSettingsBloc>().add(
                                  ChatSettingsSelectAgent(id: agent.id),
                                );
                              },
                            ),
                            title: Text(agent.name),
                            description: Text(_settingsSummary(agent)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (state.activeAgentId == agent.id) ...[
                                  Text(
                                    'Default',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                const Icon(Icons.chevron_right, size: 20),
                              ],
                            ),
                            onPressed: (_) {
                              context.goNamed(
                                ChatAgentSettingsScreen.name,
                                pathParameters: {'agentId': agent.id},
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                if (widget.agentId != null)
                  SettingsSection(
                    title: const Text('Agent'),
                    tiles: [
                      SettingsTile.navigation(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Name'),
                        value: Text(editingAgent?.name ?? 'Agent'),
                        onPressed: (_) =>
                            _showAgentDialog(context, agent: editingAgent),
                      ),
                      if (editingAgent != null)
                        SettingsTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Remove Agent'),
                          onPressed: (_) =>
                              _confirmDeleteAgent(context, editingAgent!),
                        ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.smart_toy),
                        title: const Text('Model'),
                        value: Text(_modelLabel(currentConfig)),
                        onPressed: (_) =>
                            _showModelPicker(context, editingAgent),
                      ),
                    ],
                  ),
                if (widget.agentId != null &&
                    _supportsSamplingControls(currentConfig))
                  SettingsSection(
                    title: const Text('Generation'),
                    tiles: [
                      SettingsTile.navigation(
                        leading: const Icon(Icons.thermostat),
                        title: const Text('Temperature'),
                        value: Text(
                          currentConfig.temperature.toStringAsFixed(2),
                        ),
                        description: const Text('Higher = more creative'),
                        onPressed: (_) => _showTemperatureDialog(
                          context,
                          currentConfig,
                          editingAgent?.id,
                        ),
                      ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.filter_list),
                        title: const Text('Top-K'),
                        value: Text('${currentConfig.topK}'),
                        description: const Text('Sampling diversity'),
                        onPressed: (_) => _showTopKDialog(
                          context,
                          currentConfig,
                          editingAgent?.id,
                        ),
                      ),
                    ],
                  ),
                if (widget.agentId != null)
                  SettingsSection(
                    title: const Text('System Prompt'),
                    tiles: [
                      SettingsTile.navigation(
                        leading: const Icon(Icons.edit_note),
                        title: const Text('Default System Prompt'),
                        value: Text(currentSystemPromptPreview),
                        onPressed: (_) => _showSystemPromptDialog(
                          context,
                          currentSystemPrompt,
                          editingAgent?.id,
                        ),
                      ),
                    ],
                  ),
                if (widget.agentId != null)
                  SettingsSection(
                    title: const Text('Advanced'),
                    tiles: [
                      SettingsTile.switchTile(
                        leading: const Icon(Icons.psychology),
                        title: const Text('Show Thinking Process'),
                        description: const Text(
                          'Display chain-of-thought reasoning from the model',
                        ),
                        initialValue: currentThinkingEnabled,
                        onToggle: (value) {
                          context.read<ChatSettingsBloc>().add(
                            ChatSettingsToggleThinking(
                              enabled: value,
                              agentId: editingAgent?.id,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  ChatAgent? _agentById(ChatSettingsState state, String id) {
    for (final agent in state.agents) {
      if (agent.id == id) return agent;
    }
    return null;
  }

  void _createAgent(BuildContext context) {
    final id = 'agent-${DateTime.now().microsecondsSinceEpoch}';
    context.read<ChatSettingsBloc>().add(
      ChatSettingsSaveAgent(
        id: id,
        name: 'New Agent',
        systemPrompt: '',
        config: _defaultAgentConfig(context),
        thinkingEnabled: false,
      ),
    );
    context.goNamed(
      ChatAgentSettingsScreen.name,
      pathParameters: {'agentId': id},
    );
  }

  String _settingsSummary(ChatAgent agent) {
    return _modelLabel(agent.config);
  }

  bool _supportsSamplingControls(ModelConfig config) {
    return config.inferenceMode == ChatInferenceMode.local ||
        config.remoteProvider == RemoteLlmProvider.openAiCompatible;
  }

  ModelConfig _defaultAgentConfig(BuildContext context) {
    final choices = _configuredModels(context);
    if (choices.isNotEmpty) return choices.first.config;
    return context.read<ChatSettingsBloc>().state.config;
  }

  String _modelLabel(ModelConfig config) {
    return switch (config.inferenceMode) {
      ChatInferenceMode.local =>
        config.localModelId != null
            ? (GemmaModelInfo.findById(config.localModelId!)?.displayName ??
                  config.localModelId!)
            : 'Select a local model',
      ChatInferenceMode.remote =>
        '${config.remoteProvider.displayName} · '
            '${config.remoteApiType.displayName} · ${config.remoteModel}',
    };
  }

  /// Applies a picked model onto the agent's current config so the agent's
  /// other settings (temperature, top-k, ...) are preserved.
  ModelConfig _applyModelChoice(ModelConfig base, _ConfiguredModel choice) {
    final config = choice.config;
    if (config.inferenceMode == ChatInferenceMode.local) {
      return base.copyWith(
        inferenceMode: ChatInferenceMode.local,
        localModelId: choice.localModelId,
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
    );
  }

  void _showModelPicker(BuildContext context, ChatAgent? editingAgent) {
    final choices = _configuredModels(context);
    final baseConfig =
        editingAgent?.config ?? context.read<ChatSettingsBloc>().state.config;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: choices.isEmpty
            ? const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('No configured models'),
                subtitle: Text('Configure local or remote models in Settings.'),
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
                          context.read<ChatSettingsBloc>().add(
                            ChatSettingsUpdateConfig(
                              config: _applyModelChoice(baseConfig, choice),
                              agentId: editingAgent?.id,
                            ),
                          );
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

  List<_ConfiguredModel> _configuredModels(BuildContext context) {
    return [
      ..._configuredLocalModels(context),
      ..._configuredRemoteModels(context),
    ];
  }

  List<_ConfiguredModel> _configuredLocalModels(BuildContext context) {
    final GemmaModelState state;
    try {
      state = context.read<GemmaModelBloc>().state;
    } catch (_) {
      return const <_ConfiguredModel>[];
    }
    final modelIds = <String>{};
    for (final installedId in state.installedModels) {
      final normalized = installedId.trim();
      if (normalized.isNotEmpty) {
        modelIds.add(normalized);
      }
    }

    if (modelIds.isEmpty) {
      return const <_ConfiguredModel>[];
    }
    final config = ModelConfig.platformDefaultConfig.copyWith(
      inferenceMode: ChatInferenceMode.local,
    );
    return [
      for (final modelId in modelIds)
        _ConfiguredModel(
          title: GemmaModelInfo.findById(modelId)?.displayName ?? modelId,
          subtitle: 'Local model',
          icon: Icons.memory,
          config: config.copyWith(localModelId: modelId),
          localModelId: modelId,
        ),
    ];
  }

  List<_ConfiguredModel> _configuredRemoteModels(BuildContext context) {
    final preferences = context.read<SharedPreferences>();
    final providers =
        preferences.getStringList('remote_model_provider_profiles') ??
        const <String>[];
    final choices = <_ConfiguredModel>[];

    for (final raw in providers) {
      final provider = _RemoteProviderConfig.fromJson(raw);
      if (provider == null) continue;
      final config = _remoteConfigForProvider(preferences, provider);
      final models = _remoteModelsFor(preferences, config);
      final effectiveModels = models.isNotEmpty
          ? models.toSet()
          : {
              if (provider.defaultModel.trim().isNotEmpty)
                provider.defaultModel.trim(),
            };

      for (final model in effectiveModels) {
        choices.add(
          _ConfiguredModel(
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

  ModelConfig _remoteConfigForProvider(
    SharedPreferences preferences,
    _RemoteProviderConfig provider,
  ) {
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
      clearRemoteAuthHeaderName:
          provider.authType != RemoteAuthType.customHeader,
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

  void _showAgentDialog(BuildContext context, {ChatAgent? agent}) {
    final nameController = TextEditingController(text: agent?.name);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(agent == null ? 'Add Agent' : 'Edit Agent'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Agent name',
                  hintText: 'Research assistant',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ChatSettingsBloc>().add(
                ChatSettingsSaveAgent(
                  id: agent?.id,
                  name: nameController.text,
                  systemPrompt: agent?.systemPrompt ?? '',
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAgent(BuildContext context, ChatAgent agent) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Agent?'),
        content: Text('Remove "${agent.name}" from chat agents?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ChatSettingsBloc>().add(
                ChatSettingsDeleteAgent(id: agent.id),
              );
              Navigator.pop(dialogContext);
              if (widget.agentId != null && GoRouter.maybeOf(context) != null) {
                context.goNamed(ChatAgentsSettingsScreen.name);
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showTemperatureDialog(
    BuildContext context,
    ModelConfig config,
    String? agentId,
  ) {
    var temperature = config.temperature;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Temperature'),
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
              const Text(
                '0 = deterministic, 2 = very creative',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<ChatSettingsBloc>().add(
                  ChatSettingsUpdateConfig(
                    config: config.copyWith(temperature: temperature),
                    agentId: agentId,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopKDialog(
    BuildContext context,
    ModelConfig config,
    String? agentId,
  ) {
    var topK = config.topK;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Top-K'),
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
              const Text(
                'Lower = more focused, Higher = more diverse',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<ChatSettingsBloc>().add(
                  ChatSettingsUpdateConfig(
                    config: config.copyWith(topK: topK),
                    agentId: agentId,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSystemPromptDialog(
    BuildContext context,
    String? currentPrompt,
    String? agentId,
  ) {
    final controller = TextEditingController(text: currentPrompt);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('System Prompt'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Default system prompt for new conversations',
            hintText: 'You are a helpful assistant...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final prompt = controller.text.trim();
              context.read<ChatSettingsBloc>().add(
                ChatSettingsUpdateSystemPrompt(
                  prompt: prompt.isEmpty ? null : prompt,
                  agentId: agentId,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
