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
    var authType = profile?.authType ?? RemoteAuthType.bearerToken;
    final authHeaderNameController = TextEditingController(
      text: profile?.authHeaderName ?? '',
    );
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<RemoteAuthType>(
                    initialValue: authType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Auth type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final type in _mcpAuthTypes)
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
                final authHeaderName = authHeaderNameController.text.trim();
                if (url.isEmpty ||
                    (authType == RemoteAuthType.customHeader &&
                        authHeaderName.isEmpty)) {
                  return;
                }
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
                    authType: authType,
                    authHeaderName: authType == RemoteAuthType.customHeader
                        ? authHeaderName
                        : null,
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
      if (account.id == profile.accountId) {
        return '${account.name} (${_mcpAuthTypeLabel(profile)})';
      }
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
                                leading: const Icon(Icons.http),
                                title: const Text('Auth Type'),
                                value: Text(_mcpAuthTypeLabel(profile)),
                                description: const Text(
                                  'Choose how the selected secret is sent.',
                                ),
                                onPressed: (context) {
                                  _showAuthTypeDialog(context, profile);
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
      final accountName = _accountName(
        context.read<AccountsBloc>().state,
        profile.accountId!,
      );
      final apiKey = await context.read<AccountsBloc>().getApiKey(
        profile.accountId!,
      );
      final trimmedApiKey = apiKey?.trim();
      if (trimmedApiKey == null || trimmedApiKey.isEmpty) {
        throw _RemoteToolConfigurationException(
          accountName == null
              ? 'Selected service account has no secret. Update it in Service Accounts.'
              : 'Service account "$accountName" has no secret. Update it in Service Accounts.',
        );
      }
      headers.addAll(_mcpAuthHeaders(profile, trimmedApiKey));
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

  void _showAuthTypeDialog(BuildContext context, _RemoteMcpProfile profile) {
    var authType = profile.authType;
    final headerNameController = TextEditingController(
      text: profile.authHeaderName ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Auth Type'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<RemoteAuthType>(
                    initialValue: authType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Auth type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final type in _mcpAuthTypes)
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
                      controller: headerNameController,
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final headerName = headerNameController.text.trim();
                  if (authType == RemoteAuthType.customHeader &&
                      headerName.isEmpty) {
                    return;
                  }
                  _replaceProfile(
                    profile.copyWith(
                      authType: authType,
                      authHeaderName: authType == RemoteAuthType.customHeader
                          ? headerName
                          : null,
                      clearAuthHeaderName:
                          authType != RemoteAuthType.customHeader,
                    ),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('Save'),
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
      if (account.id == profile.accountId) {
        return '${account.name} (${_mcpAuthTypeLabel(profile)})';
      }
    }
    return 'Missing account';
  }

  String? _accountName(AccountsState state, int accountId) {
    if (state is! AccountsLoaded) return null;
    for (final account in state.accounts) {
      if (account.id == accountId) return account.name;
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

class _RemoteToolConfigurationException implements Exception {
  const _RemoteToolConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

const _mcpAuthTypes = [
  RemoteAuthType.bearerToken,
  RemoteAuthType.xApiKey,
  RemoteAuthType.customHeader,
];

RemoteAuthType _parseRemoteAuthType(String? value) {
  for (final type in _mcpAuthTypes) {
    if (type.name == value) return type;
  }
  return RemoteAuthType.bearerToken;
}

String _mcpAuthTypeLabel(_RemoteMcpProfile profile) {
  if (profile.authType != RemoteAuthType.customHeader) {
    return profile.authType.displayName;
  }
  final headerName = profile.authHeaderName?.trim();
  return headerName == null || headerName.isEmpty
      ? profile.authType.displayName
      : '$headerName header';
}

Map<String, String> _mcpAuthHeaders(_RemoteMcpProfile profile, String secret) {
  return switch (profile.authType) {
    RemoteAuthType.providerDefault => {'Authorization': 'Bearer $secret'},
    RemoteAuthType.bearerToken => {'Authorization': 'Bearer $secret'},
    RemoteAuthType.xApiKey => {'x-api-key': secret},
    RemoteAuthType.customHeader => {_customMcpHeaderName(profile): secret},
  };
}

String _customMcpHeaderName(_RemoteMcpProfile profile) {
  final headerName = profile.authHeaderName?.trim();
  if (headerName == null || headerName.isEmpty) {
    throw StateError('MCP custom auth header name is required.');
  }
  return headerName;
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
    this.authType = RemoteAuthType.bearerToken,
    this.authHeaderName,
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
      authType: _parseRemoteAuthType(decoded['authType'] as String?),
      authHeaderName: decoded['authHeaderName'] as String?,
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
  final RemoteAuthType authType;
  final String? authHeaderName;
  final List<_RemoteMcpTool> tools;

  _RemoteMcpProfile copyWith({
    String? name,
    String? url,
    _McpTransport? transport,
    bool? enabled,
    int? accountId,
    bool clearAccount = false,
    RemoteAuthType? authType,
    String? authHeaderName,
    bool clearAuthHeaderName = false,
    List<_RemoteMcpTool>? tools,
  }) {
    return _RemoteMcpProfile(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      transport: transport ?? this.transport,
      enabled: enabled ?? this.enabled,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      authType: authType ?? this.authType,
      authHeaderName: clearAuthHeaderName
          ? null
          : (authHeaderName ?? this.authHeaderName),
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
      'authType': authType.name,
      'authHeaderName': authHeaderName,
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
