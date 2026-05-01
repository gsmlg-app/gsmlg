// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSettingsScreen extends StatefulWidget {
  static const name = 'ChatSettings';
  static const path = 'settings';

  const ChatSettingsScreen({super.key, this.agentId});

  final String? agentId;

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class ChatAgentSettingsScreen extends StatelessWidget {
  static const name = 'ChatAgentSettings';
  static const path = 'agent/:agentId';

  const ChatAgentSettingsScreen({required this.agentId, super.key});

  final String agentId;

  @override
  Widget build(BuildContext context) {
    return ChatSettingsScreen(agentId: agentId);
  }
}

class _ConfiguredModel {
  const _ConfiguredModel({
    required this.title,
    required this.icon,
    required this.config,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final ModelConfig config;
}

class _RemoteProviderConfig {
  const _RemoteProviderConfig({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.defaultModel,
    required this.remoteProvider,
    this.accountId,
    this.useDummyToken = false,
  });

  factory _RemoteProviderConfig.fromMap(Map<String, Object?> map) {
    return _RemoteProviderConfig(
      id: map['id'] as String,
      name: map['name'] as String,
      baseUrl: map['baseUrl'] as String,
      defaultModel: map['defaultModel'] as String? ?? 'local-model',
      remoteProvider: _parseProvider(map['remoteProvider'] as String?),
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
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key(HomeScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          title: Text(
            widget.agentId == null ? 'Chat Settings' : 'Agent Settings',
          ),
        ),
        body: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
          builder: (context, state) {
            final agentId = widget.agentId;
            if (agentId != null) {
              final agent = _agentById(state, agentId);
              if (agent == null) {
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
              if (state.activeAgentId != agent.id) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  context.read<ChatSettingsBloc>().add(
                    ChatSettingsSelectAgent(id: agent.id),
                  );
                });
                return const Center(child: CircularProgressIndicator());
              }
            }

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
                          (agent) => SettingsTile.navigation(
                            leading: Icon(
                              state.activeAgentId == agent.id
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                            ),
                            title: Text(agent.name),
                            description: Text(_settingsSummary(agent)),
                            onPressed: (_) {
                              context.read<ChatSettingsBloc>().add(
                                ChatSettingsSelectAgent(id: agent.id),
                              );
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
                        value: Text(state.activeAgent?.name ?? 'Agent'),
                        onPressed: (_) =>
                            _showAgentDialog(context, agent: state.activeAgent),
                      ),
                      if (state.activeAgent != null)
                        SettingsTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Remove Agent'),
                          onPressed: (_) =>
                              _confirmDeleteAgent(context, state.activeAgent!),
                        ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.smart_toy),
                        title: const Text('Model'),
                        value: Text(_modelLabel(state.config)),
                        onPressed: (_) => _showModelPicker(context),
                      ),
                    ],
                  ),
                if (widget.agentId != null)
                  SettingsSection(
                    title: const Text('Generation'),
                    tiles: [
                      SettingsTile.navigation(
                        leading: const Icon(Icons.thermostat),
                        title: const Text('Temperature'),
                        value: Text(
                          state.config.temperature.toStringAsFixed(2),
                        ),
                        description: const Text('Higher = more creative'),
                        onPressed: (_) =>
                            _showTemperatureDialog(context, state.config),
                      ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.filter_list),
                        title: const Text('Top-K'),
                        value: Text('${state.config.topK}'),
                        description: const Text('Sampling diversity'),
                        onPressed: (_) =>
                            _showTopKDialog(context, state.config),
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
                        value: Text(
                          state.defaultSystemPrompt?.isNotEmpty == true
                              ? '${state.defaultSystemPrompt!.substring(0, state.defaultSystemPrompt!.length.clamp(0, 30))}...'
                              : 'Not set',
                        ),
                        onPressed: (_) => _showSystemPromptDialog(
                          context,
                          state.defaultSystemPrompt,
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
                        initialValue: state.thinkingEnabled,
                        onToggle: (value) {
                          context.read<ChatSettingsBloc>().add(
                            ChatSettingsToggleThinking(enabled: value),
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
    final config = agent.config;
    return _modelLabel(config);
  }

  ModelConfig _defaultAgentConfig(BuildContext context) {
    final choices = _configuredModels(context);
    if (choices.isNotEmpty) return choices.first.config;
    return context.read<ChatSettingsBloc>().state.config;
  }

  String _modelLabel(ModelConfig config) {
    return switch (config.inferenceMode) {
      ChatInferenceMode.local => config.modelDisplayName,
      ChatInferenceMode.remote =>
        '${config.remoteProvider.displayName} · ${config.remoteModel}',
    };
  }

  void _showModelPicker(BuildContext context) {
    final choices = _configuredModels(context);
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
                            ChatSettingsUpdateConfig(config: choice.config),
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
    final selectedId = state.selectedModelId;
    if (selectedId == null || selectedId.trim().isEmpty) {
      return const <_ConfiguredModel>[];
    }
    final info = GemmaModelInfo.findById(selectedId);
    final config = ModelConfig.defaultConfig.copyWith(
      inferenceMode: ChatInferenceMode.local,
    );
    return [
      _ConfiguredModel(
        title: info?.displayName ?? selectedId,
        subtitle: 'Local model',
        icon: Icons.memory,
        config: config,
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
      final selectedModel = preferences.getString(
        'remote_model_provider_selected_${provider.id}',
      );
      final effectiveModels = {
        if (selectedModel != null && selectedModel.trim().isNotEmpty)
          selectedModel.trim(),
        ...models,
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

    final currentConfig = context.read<ChatSettingsBloc>().state.config;
    if (currentConfig.inferenceMode == ChatInferenceMode.remote &&
        currentConfig.remoteModel.trim().isNotEmpty &&
        choices.every((choice) => choice.config != currentConfig)) {
      choices.add(
        _ConfiguredModel(
          title: currentConfig.remoteModel,
          subtitle: currentConfig.remoteProvider.displayName,
          icon: Icons.cloud_queue,
          config: currentConfig,
        ),
      );
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
      remoteAccountId: provider.useDummyToken
          ? ModelConfig.dummyRemoteAccountId
          : provider.accountId,
      clearRemoteAccount: !provider.useDummyToken && provider.accountId == null,
      remoteBaseUrl: provider.baseUrl,
      remoteModel: provider.defaultModel,
    );
  }

  List<String> _remoteModelsFor(
    SharedPreferences preferences,
    ModelConfig config,
  ) {
    final providerModelsKey =
        'remote_provider_models_${config.remoteProvider.name}_'
        '${config.remoteAccountId ?? 'none'}_${config.remoteBaseUrl.trim()}';
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
                context.goNamed(ChatSettingsScreen.name);
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showTemperatureDialog(BuildContext context, ModelConfig config) {
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

  void _showTopKDialog(BuildContext context, ModelConfig config) {
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
                  ChatSettingsUpdateConfig(config: config.copyWith(topK: topK)),
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

  void _showSystemPromptDialog(BuildContext context, String? currentPrompt) {
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
