// ignore_for_file: deprecated_member_use

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

class ChatSettingsScreen extends StatefulWidget {
  static const name = 'ChatSettings';
  static const path = 'settings';

  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key(HomeScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(title: const Text('Chat Settings')),
        body: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
          builder: (context, state) {
            return SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Inference'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.hub),
                      title: const Text('Mode'),
                      value: Text(state.config.inferenceModeDisplayName),
                      onPressed: (_) =>
                          _showInferenceModePicker(context, state.config),
                    ),
                  ],
                ),
                if (state.config.inferenceMode == ChatInferenceMode.local)
                  SettingsSection(
                    title: const Text('Local Model'),
                    tiles: [
                      SettingsTile.navigation(
                        leading: const Icon(Icons.memory),
                        title: const Text('Model Type'),
                        value: Text(state.config.modelDisplayName),
                        onPressed: (_) =>
                            _showModelTypePicker(context, state.config),
                      ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.speed),
                        title: const Text('Backend'),
                        value: Text(
                          state.config.backend == GemmaBackend.gpu
                              ? 'GPU (Recommended)'
                              : 'CPU',
                        ),
                        onPressed: (_) =>
                            _showBackendPicker(context, state.config),
                      ),
                    ],
                  ),
                if (state.config.inferenceMode == ChatInferenceMode.remote)
                  SettingsSection(
                    title: const Text('Remote LLM'),
                    tiles: [
                      SettingsTile.navigation(
                        leading: const Icon(Icons.cloud_queue),
                        title: const Text('Provider'),
                        value: Text(state.config.remoteProvider.displayName),
                        onPressed: (_) =>
                            _showRemoteProviderPicker(context, state.config),
                      ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.account_circle),
                        title: const Text('Account'),
                        value: BlocBuilder<AccountsBloc, AccountsState>(
                          builder: (context, accountsState) {
                            final account = _selectedRemoteAccount(
                              accountsState,
                              state.config.remoteAccountId,
                            );
                            return Text(account?.name ?? 'Not selected');
                          },
                        ),
                        onPressed: (_) =>
                            _showRemoteAccountPicker(context, state.config),
                      ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.link),
                        title: const Text('Base URL'),
                        value: Text(state.config.remoteBaseUrl),
                        onPressed: (_) =>
                            _showRemoteBaseUrlDialog(context, state.config),
                      ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.smart_toy),
                        title: const Text('Model'),
                        value: Text(state.config.remoteModel),
                        onPressed: (_) =>
                            _showRemoteModelDialog(context, state.config),
                      ),
                      SettingsTile.switchTile(
                        leading: const Icon(Icons.stream),
                        title: const Text('Streaming'),
                        description: const Text('Show tokens as they arrive'),
                        initialValue: state.config.remoteStreamingEnabled,
                        onToggle: (value) {
                          context.read<ChatSettingsBloc>().add(
                            ChatSettingsUpdateConfig(
                              config: state.config.copyWith(
                                remoteStreamingEnabled: value,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                SettingsSection(
                  title: const Text('Generation'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.format_list_numbered),
                      title: const Text('Max Tokens'),
                      value: Text('${state.config.maxTokens}'),
                      onPressed: (_) =>
                          _showMaxTokensDialog(context, state.config),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.thermostat),
                      title: const Text('Temperature'),
                      value: Text(state.config.temperature.toStringAsFixed(2)),
                      description: const Text('Higher = more creative'),
                      onPressed: (_) =>
                          _showTemperatureDialog(context, state.config),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.filter_list),
                      title: const Text('Top-K'),
                      value: Text('${state.config.topK}'),
                      description: const Text('Sampling diversity'),
                      onPressed: (_) => _showTopKDialog(context, state.config),
                    ),
                  ],
                ),
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
                SettingsSection(
                  title: const Text('Actions'),
                  tiles: [
                    SettingsTile(
                      leading: const Icon(Icons.restore),
                      title: const Text('Reset to Defaults'),
                      onPressed: (_) => _confirmReset(context),
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

  ServiceAccountTableData? _selectedRemoteAccount(
    AccountsState state,
    int? accountId,
  ) {
    if (state is! AccountsLoaded || accountId == null) return null;
    for (final account in state.accounts) {
      if (account.id == accountId) return account;
    }
    return null;
  }

  void _showInferenceModePicker(BuildContext context, ModelConfig config) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Radio<ChatInferenceMode>(
              value: ChatInferenceMode.local,
              groupValue: config.inferenceMode,
              onChanged: (v) => _updateInferenceMode(context, sheetContext, v!),
            ),
            title: const Text('Local'),
            subtitle: const Text('Run the model on this device'),
            onTap: () => _updateInferenceMode(
              context,
              sheetContext,
              ChatInferenceMode.local,
            ),
          ),
          ListTile(
            leading: Radio<ChatInferenceMode>(
              value: ChatInferenceMode.remote,
              groupValue: config.inferenceMode,
              onChanged: (v) => _updateInferenceMode(context, sheetContext, v!),
            ),
            title: const Text('Remote'),
            subtitle: const Text('Use an OpenAI-compatible API'),
            onTap: () => _updateInferenceMode(
              context,
              sheetContext,
              ChatInferenceMode.remote,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _updateInferenceMode(
    BuildContext context,
    BuildContext sheetContext,
    ChatInferenceMode mode,
  ) {
    final currentConfig = context.read<ChatSettingsBloc>().state.config;
    context.read<ChatSettingsBloc>().add(
      ChatSettingsUpdateConfig(
        config: currentConfig.copyWith(inferenceMode: mode),
      ),
    );
    Navigator.pop(sheetContext);
  }

  void _showRemoteProviderPicker(BuildContext context, ModelConfig config) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final provider in RemoteLlmProvider.values)
                ListTile(
                  leading: Radio<RemoteLlmProvider>(
                    value: provider,
                    groupValue: config.remoteProvider,
                    onChanged: (value) =>
                        _updateRemoteProvider(context, sheetContext, value!),
                  ),
                  title: Text(provider.displayName),
                  subtitle: Text(provider.defaultBaseUrl),
                  onTap: () =>
                      _updateRemoteProvider(context, sheetContext, provider),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _updateRemoteProvider(
    BuildContext context,
    BuildContext sheetContext,
    RemoteLlmProvider provider,
  ) {
    final currentConfig = context.read<ChatSettingsBloc>().state.config;
    context.read<ChatSettingsBloc>().add(
      ChatSettingsUpdateConfig(
        config: currentConfig.copyWith(
          remoteProvider: provider,
          remoteBaseUrl: provider.defaultBaseUrl,
          remoteModel: _defaultRemoteModel(provider),
          remoteThinkingEffort: provider == RemoteLlmProvider.deepSeek
              ? currentConfig.remoteThinkingEffort
              : RemoteThinkingEffort.off,
        ),
      ),
    );
    Navigator.pop(sheetContext);
  }

  String _defaultRemoteModel(RemoteLlmProvider provider) {
    return switch (provider) {
      RemoteLlmProvider.openAiCompatible => 'gpt-4.1-mini',
      RemoteLlmProvider.openAi => 'gpt-4.1-mini',
      RemoteLlmProvider.openRouter => 'openai/gpt-4.1-mini',
      RemoteLlmProvider.groq => 'llama-3.1-8b-instant',
      RemoteLlmProvider.deepSeek => 'deepseek-chat',
    };
  }

  void _showRemoteAccountPicker(BuildContext context, ModelConfig config) {
    final accountsState = context.read<AccountsBloc>().state;
    final accounts = accountsState is AccountsLoaded
        ? accountsState.byProvider(ServiceProvider.openai)
        : <ServiceAccountTableData>[];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (accounts.isEmpty)
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('No OpenAI-compatible accounts'),
                subtitle: Text('Add one in Settings > Account'),
              )
            else
              for (final account in accounts)
                ListTile(
                  leading: Radio<int>(
                    value: account.id,
                    groupValue: config.remoteAccountId,
                    onChanged: (value) =>
                        _updateRemoteAccount(context, sheetContext, value),
                  ),
                  title: Text(account.name),
                  subtitle: account.description.isEmpty
                      ? null
                      : Text(account.description),
                  onTap: () =>
                      _updateRemoteAccount(context, sheetContext, account.id),
                ),
            if (config.remoteAccountId != null)
              ListTile(
                leading: const Icon(Icons.link_off),
                title: const Text('Clear Selection'),
                onTap: () => _updateRemoteAccount(context, sheetContext, null),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _updateRemoteAccount(
    BuildContext context,
    BuildContext sheetContext,
    int? accountId,
  ) {
    final currentConfig = context.read<ChatSettingsBloc>().state.config;
    context.read<ChatSettingsBloc>().add(
      ChatSettingsUpdateConfig(
        config: currentConfig.copyWith(
          remoteAccountId: accountId,
          clearRemoteAccount: accountId == null,
        ),
      ),
    );
    Navigator.pop(sheetContext);
  }

  void _showRemoteBaseUrlDialog(BuildContext context, ModelConfig config) {
    final controller = TextEditingController(text: config.remoteBaseUrl);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remote Base URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'https://api.openai.com/v1',
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
              context.read<ChatSettingsBloc>().add(
                ChatSettingsUpdateConfig(
                  config: config.copyWith(
                    remoteBaseUrl: controller.text.trim(),
                  ),
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

  void _showRemoteModelDialog(BuildContext context, ModelConfig config) {
    final controller = TextEditingController(text: config.remoteModel);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remote Model'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Model',
            hintText: 'gpt-4.1-mini',
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
              context.read<ChatSettingsBloc>().add(
                ChatSettingsUpdateConfig(
                  config: config.copyWith(remoteModel: controller.text.trim()),
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

  void _showModelTypePicker(BuildContext context, ModelConfig config) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Radio<GemmaModelType>(
              value: GemmaModelType.gemma2bIt,
              groupValue: config.modelType,
              onChanged: (v) => _updateModelType(context, sheetContext, v!),
            ),
            title: const Text('Gemma 2B-IT'),
            subtitle: const Text('Recommended for most devices'),
            onTap: () => _updateModelType(
              context,
              sheetContext,
              GemmaModelType.gemma2bIt,
            ),
          ),
          ListTile(
            leading: Radio<GemmaModelType>(
              value: GemmaModelType.gemma7bIt,
              groupValue: config.modelType,
              onChanged: (v) => _updateModelType(context, sheetContext, v!),
            ),
            title: const Text('Gemma 7B-IT'),
            subtitle: const Text('Better quality, requires more RAM'),
            onTap: () => _updateModelType(
              context,
              sheetContext,
              GemmaModelType.gemma7bIt,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _updateModelType(
    BuildContext context,
    BuildContext sheetContext,
    GemmaModelType type,
  ) {
    final currentConfig = context.read<ChatSettingsBloc>().state.config;
    context.read<ChatSettingsBloc>().add(
      ChatSettingsUpdateConfig(config: currentConfig.copyWith(modelType: type)),
    );
    Navigator.pop(sheetContext);
  }

  void _showBackendPicker(BuildContext context, ModelConfig config) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Radio<GemmaBackend>(
              value: GemmaBackend.gpu,
              groupValue: config.backend,
              onChanged: (v) => _updateBackend(context, sheetContext, v!),
            ),
            title: const Text('GPU'),
            subtitle: const Text('Faster, recommended'),
            onTap: () =>
                _updateBackend(context, sheetContext, GemmaBackend.gpu),
          ),
          ListTile(
            leading: Radio<GemmaBackend>(
              value: GemmaBackend.cpu,
              groupValue: config.backend,
              onChanged: (v) => _updateBackend(context, sheetContext, v!),
            ),
            title: const Text('CPU'),
            subtitle: const Text('Fallback if GPU not available'),
            onTap: () =>
                _updateBackend(context, sheetContext, GemmaBackend.cpu),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _updateBackend(
    BuildContext context,
    BuildContext sheetContext,
    GemmaBackend backend,
  ) {
    final currentConfig = context.read<ChatSettingsBloc>().state.config;
    context.read<ChatSettingsBloc>().add(
      ChatSettingsUpdateConfig(
        config: currentConfig.copyWith(backend: backend),
      ),
    );
    Navigator.pop(sheetContext);
  }

  void _showMaxTokensDialog(BuildContext context, ModelConfig config) {
    final controller = TextEditingController(text: '${config.maxTokens}');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Max Tokens'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Maximum tokens (1-8192)',
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
              final value = int.tryParse(controller.text);
              if (value != null && value >= 1 && value <= 8192) {
                context.read<ChatSettingsBloc>().add(
                  ChatSettingsUpdateConfig(
                    config: config.copyWith(maxTokens: value),
                  ),
                );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
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

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will reset all chat settings to their default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ChatSettingsBloc>().add(const ChatSettingsReset());
              Navigator.pop(dialogContext);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
