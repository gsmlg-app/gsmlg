// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteModelSettingsScreen extends StatefulWidget {
  static const name = 'RemoteModels';
  static const path = 'remote-models';

  const RemoteModelSettingsScreen({super.key});

  @override
  State<RemoteModelSettingsScreen> createState() =>
      _RemoteModelSettingsScreenState();
}

class _RemoteModelSettingsScreenState extends State<RemoteModelSettingsScreen> {
  static const _providersKey = 'remote_model_provider_profiles';
  static const _selectedModelPrefix = 'remote_model_provider_selected_';
  static const _providerModelsPrefix = 'remote_provider_models_';

  late List<_RemoteProviderProfile> _providers;
  final _loadedModels = <String, List<String>>{};
  final _loadErrors = <String, String>{};
  String? _loadingProviderId;

  @override
  void initState() {
    super.initState();
    _providers = _loadProviders();
    context.read<ChatSettingsBloc>().add(const ChatSettingsLoad());
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      destinations: Destinations.navs(context),
      body: (context) {
        return SafeArea(
          child: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    title: const Text('Remote Models'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Add provider',
                        onPressed: () => _showProviderDialog(context),
                      ),
                    ],
                  ),
                  SliverFillRemaining(
                    child: SettingsList(
                      sections: [
                        for (final provider in _providers)
                          _buildProviderSection(
                            context,
                            state.config,
                            provider,
                          ),
                        SettingsSection(
                          title: const Text('Accounts'),
                          tiles: [
                            SettingsTile.navigation(
                              leading: const Icon(Icons.manage_accounts),
                              title: const Text('Manage Service Accounts'),
                              description: const Text(
                                'Add API credentials for remote providers',
                              ),
                              onPressed: (context) {
                                context.goNamed(AccountScreen.name);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }

  SettingsSection _buildProviderSection(
    BuildContext context,
    ModelConfig currentConfig,
    _RemoteProviderProfile provider,
  ) {
    final providerConfig = _configForProvider(currentConfig, provider);
    final selectedModel = _selectedModelFor(provider, currentConfig);
    final providerModels = _providerModelsFor(providerConfig);
    final loaded = _loadedModels[provider.id] ?? const <String>[];
    final visible = _visibleModelsFor(providerConfig);
    final availableModels = _normalizedModels([
      ...providerModels,
      ...loaded,
      ...visible,
    ]);
    final selectedModelId = selectedModel?.trim();
    final selectedDropdownValue =
        selectedModelId != null && availableModels.contains(selectedModelId)
        ? selectedModelId
        : null;
    final models = availableModels.where((model) {
      final normalized = model.trim();
      return normalized.isNotEmpty && normalized != selectedModelId;
    }).toList()..sort();
    final isActive = _isActiveProvider(currentConfig, provider);
    final error = _loadErrors[provider.id];
    final isLoading = _loadingProviderId == provider.id;

    return SettingsSection(
      title: Row(
        children: [
          Icon(provider.isLocal ? Icons.dns : Icons.cloud_queue, size: 18),
          const SizedBox(width: 8),
          Text(provider.name),
          if (isActive) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
      tiles: [
        SettingsTile(
          leading: Icon(
            isActive ? Icons.radio_button_checked : Icons.play_circle_outline,
          ),
          title: Text(isActive ? 'Active Provider' : 'Use In Chat'),
          description: Text(provider.baseUrl),
          onPressed: (_) => _activateProvider(currentConfig, provider),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.link),
          title: const Text('Base URL'),
          value: Text(provider.baseUrl),
          onPressed: (_) => _showProviderDialog(context, provider: provider),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.key),
          title: const Text('Token'),
          value: BlocBuilder<AccountsBloc, AccountsState>(
            builder: (context, state) => Text(_authLabel(state, provider)),
          ),
          onPressed: (_) => _showTokenPicker(context, provider),
        ),
        SettingsTile(
          leading: const Icon(Icons.smart_toy),
          title: const Text('Selected Model'),
          value: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedDropdownValue,
                hint: Text(
                  selectedModel ?? 'Not selected',
                  overflow: TextOverflow.ellipsis,
                ),
                items: [
                  for (final model in availableModels)
                    DropdownMenuItem<String>(
                      value: model,
                      child: Text(model, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: availableModels.isEmpty
                    ? null
                    : (model) {
                        if (model == null) return;
                        _selectProviderModel(currentConfig, provider, model);
                      },
              ),
            ),
          ),
        ),
        SettingsTile(
          leading: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          title: const Text('Load Models'),
          description: Text(
            error ?? 'Load models from ${provider.baseUrl}/models',
          ),
          onPressed: (_) => _loadModelsForProvider(currentConfig, provider),
        ),
        if (models.isEmpty)
          SettingsTile(
            leading: const Icon(Icons.visibility_off),
            title: const Text('No models configured'),
            description: const Text('Load models or add a model ID manually.'),
            onPressed: (_) =>
                _showModelDialog(context, currentConfig, provider),
          )
        else
          for (final model in models)
            SettingsTile.switchTile(
              leading: const Icon(Icons.tune),
              title: Text(model),
              description: selectedModel != null && model == selectedModel
                  ? const Text('Selected for this provider')
                  : null,
              initialValue: visible.contains(model),
              onToggle: (value) {
                _setModelVisible(providerConfig, model, value);
              },
            ),
        if (!provider.isBuiltIn)
          SettingsTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text('Delete ${provider.name}'),
            onPressed: (_) => _deleteProvider(provider),
          ),
      ],
    );
  }

  ModelConfig _configForProvider(
    ModelConfig baseConfig,
    _RemoteProviderProfile provider,
  ) {
    return baseConfig.copyWith(
      inferenceMode: ChatInferenceMode.remote,
      remoteProvider: provider.remoteProvider,
      remoteAccountId: provider.useDummyToken
          ? ModelConfig.dummyRemoteAccountId
          : provider.accountId,
      clearRemoteAccount: !provider.useDummyToken && provider.accountId == null,
      remoteBaseUrl: provider.baseUrl,
      remoteModel: _selectedModelFor(provider, baseConfig) ?? '',
    );
  }

  bool _isActiveProvider(ModelConfig config, _RemoteProviderProfile provider) {
    if (config.inferenceMode != ChatInferenceMode.remote ||
        config.remoteProvider != provider.remoteProvider) {
      return false;
    }
    final accountId = provider.useDummyToken
        ? ModelConfig.dummyRemoteAccountId
        : provider.accountId;
    return config.remoteBaseUrl == provider.baseUrl &&
        (config.remoteAccountId == accountId ||
            (provider.useDummyToken && config.remoteUsesDummyToken));
  }

  String? _selectedModelFor(
    _RemoteProviderProfile provider,
    ModelConfig currentConfig,
  ) {
    if (_isActiveProvider(currentConfig, provider)) {
      final model = currentConfig.remoteModel.trim();
      return model.isEmpty ? null : model;
    }
    final model = context
        .read<SharedPreferences>()
        .getString(_selectedModelKey(provider))
        ?.trim();
    return model == null || model.isEmpty ? null : model;
  }

  List<String> _providerModelsFor(ModelConfig config) {
    return context.read<SharedPreferences>().getStringList(
          _providerModelsKey(config),
        ) ??
        _visibleModelsFor(config);
  }

  Future<void> _saveProviderModels(ModelConfig config, List<String> models) {
    return context.read<SharedPreferences>().setStringList(
      _providerModelsKey(config),
      _normalizedModels(models),
    );
  }

  List<String> _visibleModelsFor(ModelConfig config) {
    return context.read<SharedPreferences>().getStringList(
          config.remoteVisibleModelsKey,
        ) ??
        const <String>[];
  }

  Future<void> _saveVisibleModels(ModelConfig config, List<String> models) {
    return context.read<SharedPreferences>().setStringList(
      config.remoteVisibleModelsKey,
      _normalizedModels(models),
    );
  }

  Future<void> _setModelVisible(
    ModelConfig config,
    String model,
    bool visible,
  ) async {
    final next = _visibleModelsFor(config).toSet();
    if (visible) {
      next.add(model);
    } else {
      next.remove(model);
    }
    await _saveVisibleModels(config, next.toList());
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadModelsForProvider(
    ModelConfig currentConfig,
    _RemoteProviderProfile provider,
  ) async {
    final config = _configForProvider(currentConfig, provider);
    final remoteRepository = context.read<RemoteLlmRepository>();
    if (!_canLoadModels(config)) {
      setState(() {
        _loadErrors[provider.id] = 'Select a token or dummy token first.';
      });
      return;
    }

    setState(() {
      _loadingProviderId = provider.id;
      _loadErrors.remove(provider.id);
    });

    try {
      final models = await remoteRepository.listModels(config);
      final normalizedModels = _normalizedModels(models);
      await _saveProviderModels(config, normalizedModels);
      await _saveVisibleModels(config, normalizedModels);
      if (!mounted) return;
      setState(() {
        _loadedModels[provider.id] = normalizedModels;
        _loadingProviderId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadErrors[provider.id] = e.toString();
        _loadingProviderId = null;
      });
    }
  }

  bool _canLoadModels(ModelConfig config) {
    return (config.remoteAccountId != null || config.remoteUsesDummyToken) &&
        config.remoteBaseUrl.trim().isNotEmpty;
  }

  List<String> _normalizedModels(Iterable<String> models) {
    final normalized = {
      for (final model in models)
        if (model.trim().isNotEmpty) model.trim(),
    }.toList()..sort();
    return normalized;
  }

  String _providerModelsKey(ModelConfig config) {
    return '$_providerModelsPrefix${config.remoteProvider.name}_'
        '${config.remoteAccountId ?? 'none'}_${config.remoteBaseUrl.trim()}';
  }

  void _activateProvider(
    ModelConfig currentConfig,
    _RemoteProviderProfile provider,
  ) {
    context.read<ChatSettingsBloc>().add(
      ChatSettingsUpdateConfig(
        config: _configForProvider(currentConfig, provider),
      ),
    );
  }

  void _showModelDialog(
    BuildContext context,
    ModelConfig currentConfig,
    _RemoteProviderProfile provider,
  ) {
    final controller = TextEditingController(
      text: _selectedModelFor(provider, currentConfig) ?? '',
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${provider.name} Model'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Model ID',
            hintText: 'llama3.2, gpt-4.1-mini',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final model = controller.text.trim();
              if (model.isEmpty) return;
              await _selectProviderModel(currentConfig, provider, model);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectProviderModel(
    ModelConfig currentConfig,
    _RemoteProviderProfile provider,
    String model,
  ) async {
    final preferences = context.read<SharedPreferences>();
    final chatSettingsBloc = context.read<ChatSettingsBloc>();
    final shouldUpdateActiveProvider = _isActiveProvider(
      currentConfig,
      provider,
    );
    final providerConfig = _configForProvider(
      currentConfig,
      provider,
    ).copyWith(remoteModel: model);
    final providerModels = {
      ..._providerModelsFor(providerConfig),
      model,
    }.toList()..sort();
    final visible = {..._visibleModelsFor(providerConfig), model}.toList()
      ..sort();

    await preferences.setString(_selectedModelKey(provider), model);
    await preferences.setStringList(
      _providerModelsKey(providerConfig),
      _normalizedModels(providerModels),
    );
    await preferences.setStringList(
      providerConfig.remoteVisibleModelsKey,
      _normalizedModels(visible),
    );
    if (!mounted) return;
    if (shouldUpdateActiveProvider) {
      chatSettingsBloc.add(ChatSettingsUpdateConfig(config: providerConfig));
    }
    setState(() {});
  }

  void _showTokenPicker(BuildContext context, _RemoteProviderProfile provider) {
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
            ListTile(
              leading: Radio<bool>(
                value: true,
                groupValue: provider.useDummyToken,
                onChanged: (_) =>
                    _updateProviderToken(sheetContext, provider, true, null),
              ),
              title: const Text('Dummy token'),
              subtitle: const Text(
                'For Ollama, LM Studio, and no-auth local APIs',
              ),
              onTap: () =>
                  _updateProviderToken(sheetContext, provider, true, null),
            ),
            for (final account in accounts)
              ListTile(
                leading: Radio<int>(
                  value: account.id,
                  groupValue: provider.accountId,
                  onChanged: (_) => _updateProviderToken(
                    sheetContext,
                    provider,
                    false,
                    account.id,
                  ),
                ),
                title: Text(account.name),
                subtitle: account.description.isEmpty
                    ? null
                    : Text(account.description),
                onTap: () => _updateProviderToken(
                  sheetContext,
                  provider,
                  false,
                  account.id,
                ),
              ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Manage Service Accounts'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.goNamed(AccountScreen.name);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _updateProviderToken(
    BuildContext sheetContext,
    _RemoteProviderProfile provider,
    bool useDummyToken,
    int? accountId,
  ) {
    _replaceProvider(
      provider.copyWith(
        useDummyToken: useDummyToken,
        accountId: accountId,
        clearAccount: useDummyToken || accountId == null,
      ),
    );
    Navigator.pop(sheetContext);
  }

  void _showProviderDialog(
    BuildContext context, {
    _RemoteProviderProfile? provider,
  }) {
    final isEditing = provider != null;
    final presets = _RemoteProviderProfile.presets;
    var selectedPreset = isEditing
        ? _matchingPresetFor(provider)
        : presets.first;
    final nameController = TextEditingController(
      text: provider?.name ?? selectedPreset?.name ?? '',
    );
    final baseUrlController = TextEditingController(
      text:
          provider?.baseUrl ??
          selectedPreset?.baseUrl ??
          'http://localhost:11434/v1',
    );
    var remoteProvider =
        provider?.remoteProvider ??
        selectedPreset?.remoteProvider ??
        RemoteLlmProvider.openAiCompatible;
    var defaultModel =
        provider?.defaultModel ?? selectedPreset?.defaultModel ?? 'local-model';
    var useDummyToken =
        provider?.useDummyToken ?? selectedPreset?.useDummyToken ?? true;
    int? accountId = provider?.accountId;

    final accountsState = context.read<AccountsBloc>().state;
    final accounts = accountsState is AccountsLoaded
        ? accountsState.byProvider(ServiceProvider.openai)
        : <ServiceAccountTableData>[];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Provider' : 'Add Provider'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedPreset?.id,
                  decoration: const InputDecoration(
                    labelText: 'Provider preset',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select provider'),
                  items: [
                    for (final preset in presets)
                      DropdownMenuItem(
                        value: preset.id,
                        child: Text(preset.name),
                      ),
                  ],
                  onChanged: (value) {
                    final preset = presets.firstWhere(
                      (item) => item.id == value,
                      orElse: () => presets.first,
                    );
                    setDialogState(() {
                      selectedPreset = preset;
                      nameController.text = preset.name;
                      baseUrlController.text = preset.baseUrl;
                      remoteProvider = preset.remoteProvider;
                      defaultModel = preset.defaultModel;
                      useDummyToken = preset.useDummyToken;
                      if (useDummyToken) accountId = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Ollama, LM Studio, Work OpenAI',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'http://localhost:11434/v1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: useDummyToken,
                  title: const Text('Use dummy token'),
                  subtitle: const Text('Default for local LLM APIs'),
                  onChanged: (value) => setDialogState(() {
                    useDummyToken = value;
                    if (value) accountId = null;
                  }),
                ),
                if (!useDummyToken)
                  DropdownButtonFormField<int>(
                    initialValue: accountId,
                    decoration: const InputDecoration(
                      labelText: 'Token account',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final account in accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => accountId = value),
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
                final baseUrl = baseUrlController.text.trim();
                if (baseUrl.isEmpty || (!useDummyToken && accountId == null)) {
                  return;
                }
                final next = _RemoteProviderProfile(
                  id:
                      provider?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  name: nameController.text.trim().isEmpty
                      ? baseUrl
                      : nameController.text.trim(),
                  baseUrl: baseUrl,
                  accountId: useDummyToken ? null : accountId,
                  useDummyToken: useDummyToken,
                  isBuiltIn: false,
                  remoteProvider: remoteProvider,
                  defaultModel: defaultModel,
                );
                _replaceProvider(next);
                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  _RemoteProviderProfile? _matchingPresetFor(_RemoteProviderProfile? provider) {
    if (provider == null) return null;
    for (final preset in _RemoteProviderProfile.presets) {
      if (preset.remoteProvider == provider.remoteProvider &&
          preset.baseUrl == provider.baseUrl &&
          preset.defaultModel == provider.defaultModel) {
        return preset;
      }
    }
    return null;
  }

  String _authLabel(AccountsState state, _RemoteProviderProfile provider) {
    if (provider.useDummyToken) return 'Dummy token';
    if (state is! AccountsLoaded || provider.accountId == null) {
      return 'Not configured';
    }
    for (final account in state.accounts) {
      if (account.id == provider.accountId) return account.name;
    }
    return 'Missing account';
  }

  List<_RemoteProviderProfile> _loadProviders() {
    final saved = context.read<SharedPreferences>().getStringList(
      _providersKey,
    );
    if (saved == null || saved.isEmpty) return const <_RemoteProviderProfile>[];
    final providers = <_RemoteProviderProfile>[];
    for (final raw in saved) {
      final provider = _RemoteProviderProfile.fromJson(raw);
      if (!provider.isBuiltIn) providers.add(provider);
    }
    return providers;
  }

  Future<void> _saveProviders() {
    return context.read<SharedPreferences>().setStringList(_providersKey, [
      for (final provider in _providers) provider.toJson(),
    ]);
  }

  void _replaceProvider(_RemoteProviderProfile provider) {
    setState(() {
      final index = _providers.indexWhere((item) => item.id == provider.id);
      if (index == -1) {
        _providers = [..._providers, provider];
      } else {
        _providers = [
          ..._providers.take(index),
          provider,
          ..._providers.skip(index + 1),
        ];
      }
      _loadErrors.remove(provider.id);
      _loadedModels.remove(provider.id);
    });
    _saveProviders();
  }

  void _deleteProvider(_RemoteProviderProfile provider) {
    setState(() {
      _providers = _providers.where((item) => item.id != provider.id).toList();
      _loadErrors.remove(provider.id);
      _loadedModels.remove(provider.id);
    });
    _saveProviders();
  }

  String _selectedModelKey(_RemoteProviderProfile provider) {
    return '$_selectedModelPrefix${provider.id}';
  }
}

class _RemoteProviderProfile {
  const _RemoteProviderProfile({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.defaultModel,
    this.accountId,
    this.useDummyToken = false,
    this.isBuiltIn = false,
    this.remoteProvider = RemoteLlmProvider.openAiCompatible,
  });

  factory _RemoteProviderProfile.fromJson(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return _RemoteProviderProfile(
      id: decoded['id'] as String,
      name: decoded['name'] as String,
      baseUrl: decoded['baseUrl'] as String,
      defaultModel: decoded['defaultModel'] as String? ?? 'local-model',
      accountId: decoded['accountId'] as int?,
      useDummyToken:
          decoded['useDummyToken'] as bool? ??
          decoded['isLocal'] as bool? ??
          false,
      isBuiltIn: decoded['isBuiltIn'] as bool? ?? false,
      remoteProvider: _parseProvider(decoded['remoteProvider'] as String?),
    );
  }

  final String id;
  final String name;
  final String baseUrl;
  final String defaultModel;
  final int? accountId;
  final bool useDummyToken;
  final bool isBuiltIn;
  final RemoteLlmProvider remoteProvider;

  bool get isLocal {
    final host = Uri.tryParse(baseUrl)?.host.toLowerCase();
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '0.0.0.0' ||
        host == '::1';
  }

  _RemoteProviderProfile copyWith({
    String? name,
    String? baseUrl,
    String? defaultModel,
    int? accountId,
    bool clearAccount = false,
    bool? useDummyToken,
  }) {
    return _RemoteProviderProfile(
      id: id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      defaultModel: defaultModel ?? this.defaultModel,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      useDummyToken: useDummyToken ?? this.useDummyToken,
      isBuiltIn: isBuiltIn,
      remoteProvider: remoteProvider,
    );
  }

  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'defaultModel': defaultModel,
      'accountId': accountId,
      'useDummyToken': useDummyToken,
      'isBuiltIn': isBuiltIn,
      'remoteProvider': remoteProvider.name,
    });
  }

  static RemoteLlmProvider _parseProvider(String? value) {
    for (final provider in RemoteLlmProvider.values) {
      if (provider.name == value) return provider;
    }
    return RemoteLlmProvider.openAiCompatible;
  }

  static const presets = [
    _RemoteProviderProfile(
      id: 'openai',
      name: 'OpenAI',
      baseUrl: 'https://api.openai.com/v1',
      defaultModel: 'gpt-4.1-mini',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.openAi,
    ),
    _RemoteProviderProfile(
      id: 'openrouter',
      name: 'OpenRouter',
      baseUrl: 'https://openrouter.ai/api/v1',
      defaultModel: 'openai/gpt-4.1-mini',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.openRouter,
    ),
    _RemoteProviderProfile(
      id: 'groq',
      name: 'Groq',
      baseUrl: 'https://api.groq.com/openai/v1',
      defaultModel: 'llama-3.1-8b-instant',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.groq,
    ),
    _RemoteProviderProfile(
      id: 'deepseek',
      name: 'DeepSeek',
      baseUrl: 'https://api.deepseek.com/v1',
      defaultModel: 'deepseek-chat',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.deepSeek,
    ),
    _RemoteProviderProfile(
      id: 'ollama',
      name: 'Ollama',
      baseUrl: 'http://localhost:11434/v1',
      defaultModel: 'llama3.2',
      useDummyToken: true,
      isBuiltIn: true,
    ),
    _RemoteProviderProfile(
      id: 'lmstudio',
      name: 'LM Studio',
      baseUrl: 'http://localhost:1234/v1',
      defaultModel: 'local-model',
      useDummyToken: true,
      isBuiltIn: true,
    ),
  ];
}
