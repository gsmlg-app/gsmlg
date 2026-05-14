// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteToolsSettingsScreen extends StatefulWidget {
  static const name = 'RemoteTools';
  static const path = 'remote-tools';

  const RemoteToolsSettingsScreen({super.key});

  @override
  State<RemoteToolsSettingsScreen> createState() =>
      _RemoteToolsSettingsScreenState();
}

class _RemoteToolsSettingsScreenState extends State<RemoteToolsSettingsScreen> {
  static const profilesKey = 'remote_mcp_profiles';

  late List<_RemoteMcpProfile> _profiles;

  @override
  void initState() {
    super.initState();
    _profiles = _loadProfiles();
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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Remote Tools'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add MCP service',
                    onPressed: () => _showProfileDialog(context),
                  ),
                ],
              ),
              SliverFillRemaining(
                child: SettingsList(
                  sections: [
                    SettingsSection(
                      title: const Text('MCP Services'),
                      tiles: [
                        if (_profiles.isEmpty)
                          SettingsTile(
                            leading: const Icon(Icons.hub_outlined),
                            title: const Text('No MCP services configured'),
                            description: const Text(
                              'Add HTTP or SSE MCP endpoints for remote tools.',
                            ),
                            onPressed: (_) => _showProfileDialog(context),
                          )
                        else
                          for (final profile in _profiles)
                            _buildProfileTile(context, profile),
                      ],
                    ),
                    SettingsSection(
                      title: const Text('Accounts'),
                      tiles: [
                        SettingsTile.navigation(
                          leading: const Icon(Icons.manage_accounts),
                          title: const Text('Manage Service Accounts'),
                          description: const Text(
                            'Use service account credentials for MCP auth',
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
          ),
        );
      },
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }

  SettingsTile _buildProfileTile(
    BuildContext context,
    _RemoteMcpProfile profile,
  ) {
    return SettingsTile(
      leading: const Icon(Icons.http),
      title: Text(profile.name),
      description: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) => Text(
          '${profile.transport.label} - ${profile.url} - '
          '${_authLabel(state, profile)}',
        ),
      ),
      trailing: Switch(
        value: profile.enabled,
        onChanged: (enabled) {
          _replaceProfile(profile.copyWith(enabled: enabled));
        },
      ),
      onPressed: (_) {
        context.goNamed(
          RemoteToolSettingsScreen.name,
          pathParameters: {'profileId': profile.id},
        );
      },
    );
  }

  void _showProfileDialog(BuildContext context, {_RemoteMcpProfile? profile}) {
    final isEditing = profile != null;
    final nameController = TextEditingController(text: profile?.name ?? '');
    final urlController = TextEditingController(text: profile?.url ?? '');
    const transport = _McpTransport.http;
    var enabled = profile?.enabled ?? true;
    int? accountId = profile?.accountId;
    final accountsState = context.read<AccountsBloc>().state;
    final accounts = accountsState is AccountsLoaded
        ? accountsState.accounts
        : <ServiceAccountTableData>[];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit MCP Service' : 'Add MCP Service'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Docs MCP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint URL',
                      hintText: 'https://mcp.example.com/mcp',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: accountId,
                    decoration: const InputDecoration(
                      labelText: 'Auth account',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('No auth'),
                      ),
                      for (final account in accounts)
                        DropdownMenuItem<int?>(
                          value: account.id,
                          child: Text(account.name),
                        ),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => accountId = value),
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: enabled,
                    title: const Text('Enabled'),
                    onChanged: (value) => setDialogState(() => enabled = value),
                  ),
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
                final url = urlController.text.trim();
                if (url.isEmpty) return;
                final name = nameController.text.trim();
                _replaceProfile(
                  _RemoteMcpProfile(
                    id:
                        profile?.id ??
                        DateTime.now().microsecondsSinceEpoch.toString(),
                    name: name.isEmpty ? url : name,
                    url: url,
                    transport: transport,
                    enabled: enabled,
                    accountId: accountId,
                    tools: profile?.tools ?? const [],
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _authLabel(AccountsState state, _RemoteMcpProfile profile) {
    if (profile.accountId == null) return 'No auth';
    if (state is! AccountsLoaded) return 'Loading auth';
    for (final account in state.accounts) {
      if (account.id == profile.accountId) return account.name;
    }
    return 'Missing account';
  }

  List<_RemoteMcpProfile> _loadProfiles() {
    final saved = context.read<SharedPreferences>().getStringList(profilesKey);
    if (saved == null || saved.isEmpty) return const <_RemoteMcpProfile>[];
    return [for (final raw in saved) _RemoteMcpProfile.fromJson(raw)];
  }

  Future<void> _saveProfiles() {
    return context.read<SharedPreferences>().setStringList(profilesKey, [
      for (final profile in _profiles) profile.toJson(),
    ]);
  }

  void _replaceProfile(_RemoteMcpProfile profile) {
    setState(() {
      final index = _profiles.indexWhere((item) => item.id == profile.id);
      if (index == -1) {
        _profiles = [..._profiles, profile];
      } else {
        _profiles = [
          ..._profiles.take(index),
          profile,
          ..._profiles.skip(index + 1),
        ];
      }
    });
    _saveProfiles();
  }
}

class RemoteToolSettingsScreen extends StatefulWidget {
  static const name = 'RemoteTool';
  static const path = ':profileId';

  const RemoteToolSettingsScreen({super.key, required this.profileId});

  final String profileId;

  @override
  State<RemoteToolSettingsScreen> createState() =>
      _RemoteToolSettingsScreenState();
}

class _RemoteToolSettingsScreenState extends State<RemoteToolSettingsScreen> {
  late List<_RemoteMcpProfile> _profiles;
  bool _isRefreshingTools = false;

  _RemoteMcpProfile? get _profile {
    for (final profile in _profiles) {
      if (profile.id == widget.profileId) return profile;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _profiles = _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      destinations: Destinations.navs(context),
      body: (context) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(profile?.name ?? 'Remote Tool'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () =>
                      context.goNamed(RemoteToolsSettingsScreen.name),
                ),
                actions: [
                  if (profile != null)
                    IconButton(
                      icon: _isRefreshingTools
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      tooltip: 'Refresh tools',
                      onPressed: _isRefreshingTools
                          ? null
                          : () => _refreshTools(context, profile),
                    ),
                ],
              ),
              SliverFillRemaining(
                child: profile == null
                    ? SettingsList(
                        sections: [
                          SettingsSection(
                            title: const Text('Remote Tool'),
                            tiles: [
                              SettingsTile(
                                leading: const Icon(Icons.error_outline),
                                title: const Text('Tool not found'),
                                description: const Text(
                                  'This remote tool may have been deleted.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SettingsList(
                        sections: [
                          SettingsSection(
                            title: const Text('Tool'),
                            tiles: [
                              SettingsTile.navigation(
                                leading: const Icon(
                                  Icons.drive_file_rename_outline,
                                ),
                                title: const Text('Name'),
                                value: Text(profile.name),
                                onPressed: (context) {
                                  _showRenameDialog(context, profile);
                                },
                              ),
                              SettingsTile.navigation(
                                leading: const Icon(Icons.http),
                                title: const Text('Endpoint'),
                                value: Text(profile.transport.label),
                                description: Text(profile.url),
                                onPressed: (context) {
                                  _showEndpointDialog(context, profile);
                                },
                              ),
                              SettingsTile.switchTile(
                                leading: const Icon(Icons.power_settings_new),
                                title: const Text('Enabled'),
                                initialValue: profile.enabled,
                                onToggle: (enabled) {
                                  _replaceProfile(
                                    profile.copyWith(enabled: enabled),
                                  );
                                },
                              ),
                            ],
                          ),
                          SettingsSection(
                            title: const Text('Secret'),
                            tiles: [
                              SettingsTile.navigation(
                                leading: const Icon(Icons.key_outlined),
                                title: const Text('Auth Account'),
                                value: BlocBuilder<AccountsBloc, AccountsState>(
                                  builder: (context, state) {
                                    return Text(_authLabel(state, profile));
                                  },
                                ),
                                description: const Text(
                                  'Choose the service account used for this MCP service.',
                                ),
                                onPressed: (context) {
                                  _showAccountPicker(context, profile);
                                },
                              ),
                              SettingsTile.navigation(
                                leading: const Icon(Icons.password),
                                title: const Text('Change Secret'),
                                value: BlocBuilder<AccountsBloc, AccountsState>(
                                  builder: (context, state) {
                                    final account = _selectedAccount(
                                      state,
                                      profile,
                                    );
                                    return Text(account?.name ?? 'No account');
                                  },
                                ),
                                description: const Text(
                                  'Update the selected service account secret.',
                                ),
                                onPressed: (context) {
                                  final account = _selectedAccount(
                                    context.read<AccountsBloc>().state,
                                    profile,
                                  );
                                  if (account == null) {
                                    _showAccountPicker(context, profile);
                                    return;
                                  }
                                  _showUpdateSecretDialog(context, account);
                                },
                              ),
                              SettingsTile.navigation(
                                leading: const Icon(Icons.manage_accounts),
                                title: const Text('Manage Service Accounts'),
                                onPressed: (context) {
                                  context.goNamed(AccountScreen.name);
                                },
                              ),
                            ],
                          ),
                          SettingsSection(
                            title: const Text('Discovered Tools'),
                            tiles: [
                              SettingsTile.navigation(
                                leading: const Icon(Icons.sync),
                                title: const Text('Refresh Tools'),
                                description: Text(
                                  _refreshDescription(profile.transport),
                                ),
                                onPressed: _isRefreshingTools
                                    ? null
                                    : (context) =>
                                          _refreshTools(context, profile),
                              ),
                              if (profile.tools.isEmpty)
                                SettingsTile(
                                  leading: const Icon(Icons.extension_outlined),
                                  title: const Text('No tools discovered'),
                                )
                              else
                                for (final tool in profile.tools)
                                  SettingsTile(
                                    leading: const Icon(
                                      Icons.extension_outlined,
                                    ),
                                    title: Text(tool.name),
                                    description: tool.description.isEmpty
                                        ? null
                                        : Text(tool.description),
                                  ),
                            ],
                          ),
                          SettingsSection(
                            title: const Text('Danger Zone'),
                            tiles: [
                              SettingsTile(
                                leading: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                title: Text(
                                  'Delete Remote Tool',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                description: const Text(
                                  'Remove this MCP service from remote tools.',
                                ),
                                onPressed: (_) {
                                  _showDeleteDialog(context, profile);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }

  Future<void> _refreshTools(
    BuildContext context,
    _RemoteMcpProfile profile,
  ) async {
    setState(() => _isRefreshingTools = true);
    try {
      final tools = await _listHttpTools(profile);
      final updated = profile.copyWith(tools: tools);
      _replaceProfile(updated);
      if (!context.mounted) return;
      _showMessage(
        context,
        '${tools.length} tool${tools.length == 1 ? '' : 's'} discovered.',
      );
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, 'Failed to list tools: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshingTools = false);
      }
    }
  }

  Future<List<_RemoteMcpTool>> _listHttpTools(_RemoteMcpProfile profile) async {
    final headers = <String, dynamic>{};
    if (profile.accountId != null) {
      final apiKey = await context.read<AccountsBloc>().getApiKey(
        profile.accountId!,
      );
      if (apiKey != null && apiKey.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${apiKey.trim()}';
      }
    }

    final tools = await DartMcpToolClient().listHttpTools(
      DartMcpHttpServerConfig(
        url: profile.url,
        headers: headers.cast<String, String>(),
      ),
    );
    return [for (final tool in tools) _RemoteMcpTool.fromJson(tool)];
  }

  String _refreshDescription(_McpTransport transport) {
    return 'List tools from this MCP endpoint.';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showRenameDialog(BuildContext context, _RemoteMcpProfile profile) {
    final controller = TextEditingController(text: profile.name);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename Remote Tool'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name',
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
                final name = controller.text.trim();
                if (name.isEmpty) return;
                _replaceProfile(profile.copyWith(name: name));
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEndpointDialog(BuildContext context, _RemoteMcpProfile profile) {
    final urlController = TextEditingController(text: profile.url);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Endpoint'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint URL',
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
                final url = urlController.text.trim();
                if (url.isEmpty) return;
                _replaceProfile(profile.copyWith(url: url));
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountPicker(BuildContext context, _RemoteMcpProfile profile) {
    final accountsState = context.read<AccountsBloc>().state;
    final accounts = accountsState is AccountsLoaded
        ? accountsState.accounts
        : <ServiceAccountTableData>[];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.lock_open),
                title: const Text('No auth'),
                trailing: profile.accountId == null
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  _replaceProfile(profile.copyWith(clearAccount: true));
                  Navigator.pop(sheetContext);
                },
              ),
              for (final account in accounts)
                ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: Text(account.name),
                  subtitle: Text(account.provider.name),
                  trailing: profile.accountId == account.id
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    _replaceProfile(profile.copyWith(accountId: account.id));
                    Navigator.pop(sheetContext);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: const Text('Manage Service Accounts'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.goNamed(AccountScreen.name);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateSecretDialog(
    BuildContext context,
    ServiceAccountTableData account,
  ) {
    if (account.provider == ServiceProvider.aws) {
      _showUpdateAwsSecretDialog(context, account);
      return;
    }
    _showUpdateGenericSecretDialog(context, account);
  }

  void _showUpdateGenericSecretDialog(
    BuildContext context,
    ServiceAccountTableData account,
  ) {
    final controller = TextEditingController();
    var obscure = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Change ${_providerLabel(account.provider)} Secret'),
            content: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: _secretLabel(account.provider),
                hintText: _secretHint(account.provider),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setDialogState(() => obscure = !obscure);
                  },
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
                  final secret = controller.text.trim();
                  if (secret.isEmpty) return;
                  context.read<AccountsBloc>().add(
                    AccountsUpdateApiKey(id: account.id, apiKey: secret),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateAwsSecretDialog(
    BuildContext context,
    ServiceAccountTableData account,
  ) {
    final accessKeyIdController = TextEditingController();
    final secretKeyController = TextEditingController();
    var obscureSecret = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Change AWS Secret'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: accessKeyIdController,
                    decoration: const InputDecoration(
                      labelText: 'Access Key ID',
                      hintText: 'AKIAIOSFODNN7EXAMPLE',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: secretKeyController,
                    obscureText: obscureSecret,
                    decoration: InputDecoration(
                      labelText: 'Secret Access Key',
                      hintText: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureSecret
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setDialogState(() => obscureSecret = !obscureSecret);
                        },
                      ),
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
                  final accessKeyId = accessKeyIdController.text.trim();
                  final secretKey = secretKeyController.text.trim();
                  if (accessKeyId.isEmpty || secretKey.isEmpty) return;
                  context.read<AccountsBloc>().add(
                    AccountsUpdateApiKey(
                      id: account.id,
                      apiKey: jsonEncode({
                        'accessKeyId': accessKeyId,
                        'secretAccessKey': secretKey,
                      }),
                    ),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, _RemoteMcpProfile profile) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Remote Tool?'),
          content: Text('Delete "${profile.name}" from remote tools?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                _deleteProfile(profile);
                Navigator.pop(dialogContext);
                context.goNamed(RemoteToolsSettingsScreen.name);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _authLabel(AccountsState state, _RemoteMcpProfile profile) {
    if (profile.accountId == null) return 'No auth';
    if (state is! AccountsLoaded) return 'Loading auth';
    for (final account in state.accounts) {
      if (account.id == profile.accountId) return account.name;
    }
    return 'Missing account';
  }

  ServiceAccountTableData? _selectedAccount(
    AccountsState state,
    _RemoteMcpProfile profile,
  ) {
    if (profile.accountId == null || state is! AccountsLoaded) return null;
    for (final account in state.accounts) {
      if (account.id == profile.accountId) return account;
    }
    return null;
  }

  List<_RemoteMcpProfile> _loadProfiles() {
    final saved = context.read<SharedPreferences>().getStringList(
      _RemoteToolsSettingsScreenState.profilesKey,
    );
    if (saved == null || saved.isEmpty) return const <_RemoteMcpProfile>[];
    return [for (final raw in saved) _RemoteMcpProfile.fromJson(raw)];
  }

  Future<void> _saveProfiles() {
    return context.read<SharedPreferences>().setStringList(
      _RemoteToolsSettingsScreenState.profilesKey,
      [for (final profile in _profiles) profile.toJson()],
    );
  }

  void _replaceProfile(_RemoteMcpProfile profile) {
    setState(() {
      final index = _profiles.indexWhere((item) => item.id == profile.id);
      if (index == -1) {
        _profiles = [..._profiles, profile];
      } else {
        _profiles = [
          ..._profiles.take(index),
          profile,
          ..._profiles.skip(index + 1),
        ];
      }
    });
    _saveProfiles();
  }

  void _deleteProfile(_RemoteMcpProfile profile) {
    setState(() {
      _profiles = _profiles.where((item) => item.id != profile.id).toList();
    });
    _saveProfiles();
  }
}

String _providerLabel(ServiceProvider provider) {
  return switch (provider) {
    ServiceProvider.openai => 'OpenAI',
    ServiceProvider.anthropic => 'Anthropic',
    ServiceProvider.ollama => 'Ollama',
    ServiceProvider.github => 'GitHub',
    ServiceProvider.vultr => 'Vultr',
    ServiceProvider.aws => 'AWS',
    ServiceProvider.cloudflare => 'Cloudflare',
    ServiceProvider.huggingface => 'Hugging Face',
  };
}

String _secretLabel(ServiceProvider provider) {
  return switch (provider) {
    ServiceProvider.openai => 'API Key',
    ServiceProvider.anthropic => 'API Key',
    ServiceProvider.ollama => 'API Key',
    ServiceProvider.github => 'Personal Access Token',
    ServiceProvider.vultr => 'API Key',
    ServiceProvider.aws => 'Secret Access Key',
    ServiceProvider.cloudflare => 'API Token',
    ServiceProvider.huggingface => 'Access Token',
  };
}

String _secretHint(ServiceProvider provider) {
  return switch (provider) {
    ServiceProvider.openai => 'sk-...',
    ServiceProvider.anthropic => 'sk-ant-...',
    ServiceProvider.ollama => 'Ollama API key',
    ServiceProvider.github => 'ghp_...',
    ServiceProvider.vultr => 'Vultr API key',
    ServiceProvider.aws => 'AWS secret access key',
    ServiceProvider.cloudflare => 'Cloudflare API token',
    ServiceProvider.huggingface => 'hf_...',
  };
}

enum _McpTransport {
  http;

  String get label => 'HTTP';

  static _McpTransport parse(String? value) {
    return _McpTransport.http;
  }
}

class _RemoteMcpProfile {
  const _RemoteMcpProfile({
    required this.id,
    required this.name,
    required this.url,
    required this.transport,
    required this.enabled,
    this.accountId,
    this.tools = const [],
  });

  factory _RemoteMcpProfile.fromJson(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final rawTools = decoded['tools'] as List<dynamic>? ?? const [];
    return _RemoteMcpProfile(
      id: decoded['id'] as String,
      name: decoded['name'] as String,
      url: decoded['url'] as String,
      transport: _McpTransport.parse(decoded['transport'] as String?),
      enabled: decoded['enabled'] as bool? ?? true,
      accountId: decoded['accountId'] as int?,
      tools: [
        for (final rawTool in rawTools)
          if (rawTool is Map<String, dynamic>) _RemoteMcpTool.fromJson(rawTool),
      ],
    );
  }

  final String id;
  final String name;
  final String url;
  final _McpTransport transport;
  final bool enabled;
  final int? accountId;
  final List<_RemoteMcpTool> tools;

  _RemoteMcpProfile copyWith({
    String? name,
    String? url,
    _McpTransport? transport,
    bool? enabled,
    int? accountId,
    bool clearAccount = false,
    List<_RemoteMcpTool>? tools,
  }) {
    return _RemoteMcpProfile(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      transport: transport ?? this.transport,
      enabled: enabled ?? this.enabled,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      tools: tools ?? this.tools,
    );
  }

  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'url': url,
      'transport': transport.name,
      'enabled': enabled,
      'accountId': accountId,
      'tools': [for (final tool in tools) tool.toJson()],
    });
  }
}

class _RemoteMcpTool {
  const _RemoteMcpTool({
    required this.name,
    this.description = '',
    this.inputSchema,
  });

  factory _RemoteMcpTool.fromJson(Map<String, dynamic> decoded) {
    final schema = decoded['inputSchema'] ?? decoded['parameters'];
    return _RemoteMcpTool(
      name: decoded['name'] as String? ?? '',
      description: decoded['description'] as String? ?? '',
      inputSchema: schema is Map<String, dynamic> ? schema : null,
    );
  }

  final String name;
  final String description;
  final Map<String, dynamic>? inputSchema;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      if (inputSchema != null) 'inputSchema': inputSchema,
    };
  }
}
