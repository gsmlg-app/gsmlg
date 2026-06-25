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
    final providerConfig = _baseConfigForProvider(currentConfig, provider);
    final availableModels = _availableModelsFor(provider, providerConfig);
    final visible = _visibleModelsFor(providerConfig);
    final models = availableModels.where((model) {
      final normalized = model.trim();
      return normalized.isNotEmpty;
    }).toList()..sort();
    final error = _loadErrors[provider.id];
    final isLoading = _loadingProviderId == provider.id;

    return SettingsSection(
      title: Row(
        children: [
          Icon(provider.isLocal ? Icons.dns : Icons.cloud_queue, size: 18),
          const SizedBox(width: 8),
          Text(provider.name),
        ],
      ),
      tiles: [
        SettingsTile.navigation(
          leading: const Icon(Icons.link),
          title: const Text('Base URL'),
          value: Text(provider.baseUrl),
          onPressed: (_) => _showProviderDialog(context, provider: provider),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.api),
          title: const Text('API type'),
          value: Text(provider.remoteApiType.displayName),
          onPressed: (_) => _showProviderDialog(context, provider: provider),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.http),
          title: const Text('Auth type'),
          value: Text(_authTypeLabel(provider)),
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

  ModelConfig _baseConfigForProvider(
    ModelConfig baseConfig,
    _RemoteProviderProfile provider,
  ) {
    return baseConfig.copyWith(
      inferenceMode: ChatInferenceMode.remote,
      remoteProvider: provider.remoteProvider,
      remoteApiType: provider.remoteApiType,
      remoteAccountId: provider.useDummyToken
          ? ModelConfig.dummyRemoteAccountId
          : provider.accountId,
      clearRemoteAccount: !provider.useDummyToken && provider.accountId == null,
      remoteBaseUrl: provider.baseUrl,
      remoteModel: '',
      remoteAuthType: provider.authType,
      remoteAuthHeaderName: provider.authHeaderName,
      clearRemoteAuthHeaderName:
          provider.authType != RemoteAuthType.customHeader,
    );
  }

  List<String> _availableModelsFor(
    _RemoteProviderProfile provider,
    ModelConfig providerConfig,
  ) {
    return _normalizedModels([
      ..._providerModelsFor(providerConfig),
      ...(_loadedModels[provider.id] ?? const <String>[]),
      ..._visibleModelsFor(providerConfig),
    ]);
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
    final config = _baseConfigForProvider(currentConfig, provider);
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
        '${config.remoteApiType.name}_${config.remoteAccountId ?? 'none'}_'
        '${config.remoteBaseUrl.trim()}';
  }

  void _showModelDialog(
    BuildContext context,
    ModelConfig currentConfig,
    _RemoteProviderProfile provider,
  ) {
    final controller = TextEditingController();
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
              await _addProviderModel(currentConfig, provider, model);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProviderModel(
    ModelConfig currentConfig,
    _RemoteProviderProfile provider,
    String model,
  ) async {
    final providerConfig = _baseConfigForProvider(currentConfig, provider);
    final providerModels = {
      ..._providerModelsFor(providerConfig),
      model,
    }.toList()..sort();
    final visible = {..._visibleModelsFor(providerConfig), model}.toList()
      ..sort();

    await _saveProviderModels(providerConfig, providerModels);
    await _saveVisibleModels(providerConfig, visible);
    if (!mounted) return;
    setState(() {});
  }

  void _showTokenPicker(BuildContext context, _RemoteProviderProfile provider) {
    final accountsState = context.read<AccountsBloc>().state;
    final accounts = accountsState is AccountsLoaded
        ? accountsState.byProvider(provider.accountProvider)
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
    var remoteApiType =
        provider?.remoteApiType ??
        selectedPreset?.remoteApiType ??
        remoteProvider.defaultApiType;
    var defaultModel =
        provider?.defaultModel ?? selectedPreset?.defaultModel ?? 'local-model';
    var useDummyToken =
        provider?.useDummyToken ?? selectedPreset?.useDummyToken ?? true;
    int? accountId = provider?.accountId;
    var authType =
        provider?.authType ??
        selectedPreset?.authType ??
        _RemoteProviderProfile.defaultAuthTypeForApiType(remoteApiType);
    final authHeaderNameController = TextEditingController(
      text: provider?.authHeaderName ?? selectedPreset?.authHeaderName ?? '',
    );

    final accountsState = context.read<AccountsBloc>().state;
    final List<ServiceAccountTableData> allAccounts =
        accountsState is AccountsLoaded
        ? accountsState.accounts
        : const <ServiceAccountTableData>[];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final accounts = allAccounts
              .where(
                (account) =>
                    account.provider ==
                    _accountProviderForApiType(remoteApiType),
              )
              .toList(growable: false);
          return AlertDialog(
            title: Text(isEditing ? 'Edit Provider' : 'Add Provider'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedPreset?.id,
                      isExpanded: true,
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
                          remoteApiType = preset.remoteApiType;
                          defaultModel = preset.defaultModel;
                          useDummyToken = preset.useDummyToken;
                          authType = preset.authType;
                          authHeaderNameController.text =
                              preset.authHeaderName ?? '';
                          if (useDummyToken) accountId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RemoteLlmApiType>(
                      initialValue: remoteApiType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'API type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final apiType in RemoteLlmApiType.values)
                          DropdownMenuItem(
                            value: apiType,
                            child: Text(apiType.displayName),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          remoteApiType = value;
                          remoteProvider = _providerForApiType(
                            value,
                            currentProvider: remoteProvider,
                          );
                          authType =
                              _RemoteProviderProfile.defaultAuthTypeForApiType(
                                value,
                              );
                          authHeaderNameController.clear();
                          accountId = null;
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
                        isExpanded: true,
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RemoteAuthType>(
                      initialValue: authType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Auth type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final type in _RemoteProviderProfile.authTypes)
                          DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => authType = value);
                      },
                    ),
                    if (authType == RemoteAuthType.customHeader) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: authHeaderNameController,
                        decoration: const InputDecoration(
                          labelText: 'Header name',
                          hintText: 'X-API-Key',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
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
                  final authHeaderName = authHeaderNameController.text.trim();
                  if (baseUrl.isEmpty ||
                      (!useDummyToken && accountId == null) ||
                      (authType == RemoteAuthType.customHeader &&
                          authHeaderName.isEmpty)) {
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
                    remoteApiType: remoteApiType,
                    defaultModel: defaultModel,
                    authType: authType,
                    authHeaderName: authType == RemoteAuthType.customHeader
                        ? authHeaderName
                        : null,
                  );
                  _replaceProvider(next);
                  Navigator.pop(dialogContext);
                },
                child: Text(isEditing ? 'Save' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  _RemoteProviderProfile? _matchingPresetFor(_RemoteProviderProfile? provider) {
    if (provider == null) return null;
    for (final preset in _RemoteProviderProfile.presets) {
      if (preset.remoteProvider == provider.remoteProvider &&
          preset.remoteApiType == provider.remoteApiType &&
          preset.baseUrl == provider.baseUrl &&
          preset.defaultModel == provider.defaultModel &&
          preset.authType == provider.authType &&
          preset.authHeaderName == provider.authHeaderName) {
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

  String _authTypeLabel(_RemoteProviderProfile provider) {
    if (provider.authType != RemoteAuthType.customHeader) {
      return provider.authType.displayName;
    }
    final headerName = provider.authHeaderName?.trim();
    return headerName == null || headerName.isEmpty
        ? provider.authType.displayName
        : '$headerName header';
  }

  ServiceProvider _accountProviderForApiType(RemoteLlmApiType apiType) {
    return apiType == RemoteLlmApiType.anthropicMessages
        ? ServiceProvider.anthropic
        : ServiceProvider.openai;
  }

  RemoteLlmProvider _providerForApiType(
    RemoteLlmApiType apiType, {
    required RemoteLlmProvider currentProvider,
  }) {
    return switch (apiType) {
      RemoteLlmApiType.openAiResponses => RemoteLlmProvider.openAi,
      RemoteLlmApiType.anthropicMessages => RemoteLlmProvider.anthropic,
      RemoteLlmApiType.openAiChatCompletions =>
        currentProvider == RemoteLlmProvider.anthropic
            ? RemoteLlmProvider.openAiCompatible
            : currentProvider,
    };
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
}

class _RemoteProviderProfile {
  _RemoteProviderProfile({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.defaultModel,
    this.accountId,
    this.useDummyToken = false,
    this.isBuiltIn = false,
    this.remoteProvider = RemoteLlmProvider.openAiCompatible,
    RemoteLlmApiType? remoteApiType,
    RemoteAuthType? authType,
    this.authHeaderName,
  }) : remoteApiType = remoteApiType ?? remoteProvider.defaultApiType,
       authType =
           authType ??
           defaultAuthTypeForApiType(
             remoteApiType ?? remoteProvider.defaultApiType,
           );

  factory _RemoteProviderProfile.fromJson(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final remoteProvider = _parseProvider(decoded['remoteProvider'] as String?);
    final remoteApiType = _parseApiType(
      decoded['remoteApiType'] as String?,
      remoteProvider,
    );
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
      remoteProvider: remoteProvider,
      remoteApiType: remoteApiType,
      authType: _parseAuthType(decoded['authType'] as String?, remoteApiType),
      authHeaderName: decoded['authHeaderName'] as String?,
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
  final RemoteLlmApiType remoteApiType;
  final RemoteAuthType authType;
  final String? authHeaderName;

  ServiceProvider get accountProvider {
    return remoteApiType == RemoteLlmApiType.anthropicMessages
        ? ServiceProvider.anthropic
        : ServiceProvider.openai;
  }

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
    RemoteAuthType? authType,
    String? authHeaderName,
    bool clearAuthHeaderName = false,
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
      remoteApiType: remoteApiType,
      authType: authType ?? this.authType,
      authHeaderName: clearAuthHeaderName
          ? null
          : (authHeaderName ?? this.authHeaderName),
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
      'remoteApiType': remoteApiType.name,
      'authType': authType.name,
      'authHeaderName': authHeaderName,
    });
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

  static const authTypes = [
    RemoteAuthType.bearerToken,
    RemoteAuthType.xApiKey,
    RemoteAuthType.customHeader,
  ];

  static RemoteAuthType defaultAuthTypeForApiType(RemoteLlmApiType apiType) {
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
    return defaultAuthTypeForApiType(apiType);
  }

  static final presets = [
    _RemoteProviderProfile(
      id: 'openai',
      name: 'OpenAI',
      baseUrl: 'https://api.openai.com/v1',
      defaultModel: 'gpt-4.1-mini',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.openAi,
      remoteApiType: RemoteLlmApiType.openAiResponses,
    ),
    _RemoteProviderProfile(
      id: 'backplane',
      name: 'Backplane',
      baseUrl: 'https://backplane.gsmlg.net/v1',
      defaultModel: 'gpt-4.1-mini',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.openAi,
      remoteApiType: RemoteLlmApiType.openAiResponses,
    ),
    _RemoteProviderProfile(
      id: 'anthropic',
      name: 'Anthropic',
      baseUrl: 'https://api.anthropic.com/v1',
      defaultModel: 'claude-sonnet-4-5',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.anthropic,
      remoteApiType: RemoteLlmApiType.anthropicMessages,
    ),
    _RemoteProviderProfile(
      id: 'openrouter',
      name: 'OpenRouter',
      baseUrl: 'https://openrouter.ai/api/v1',
      defaultModel: 'openai/gpt-4.1-mini',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.openRouter,
      remoteApiType: RemoteLlmApiType.openAiChatCompletions,
    ),
    _RemoteProviderProfile(
      id: 'groq',
      name: 'Groq',
      baseUrl: 'https://api.groq.com/openai/v1',
      defaultModel: 'llama-3.1-8b-instant',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.groq,
      remoteApiType: RemoteLlmApiType.openAiChatCompletions,
    ),
    _RemoteProviderProfile(
      id: 'deepseek',
      name: 'DeepSeek',
      baseUrl: 'https://api.deepseek.com/v1',
      defaultModel: 'deepseek-chat',
      isBuiltIn: true,
      remoteProvider: RemoteLlmProvider.deepSeek,
      remoteApiType: RemoteLlmApiType.openAiChatCompletions,
    ),
    _RemoteProviderProfile(
      id: 'ollama',
      name: 'Ollama',
      baseUrl: 'http://localhost:11434/v1',
      defaultModel: 'llama3.2',
      useDummyToken: true,
      isBuiltIn: true,
      remoteApiType: RemoteLlmApiType.openAiChatCompletions,
    ),
    _RemoteProviderProfile(
      id: 'lmstudio',
      name: 'LM Studio',
      baseUrl: 'http://localhost:1234/v1',
      defaultModel: 'local-model',
      useDummyToken: true,
      isBuiltIn: true,
      remoteApiType: RemoteLlmApiType.openAiChatCompletions,
    ),
  ];
}
