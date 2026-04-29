// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
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
    return SettingsTile.switchTile(
      leading: Icon(
        profile.transport == _McpTransport.sse ? Icons.stream : Icons.http,
      ),
      title: Text(profile.name),
      description: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) => Text(
          '${profile.transport.label} - ${profile.url} - '
          '${_authLabel(state, profile)}',
        ),
      ),
      initialValue: profile.enabled,
      onToggle: (enabled) {
        _replaceProfile(profile.copyWith(enabled: enabled));
      },
      trailing: PopupMenuButton<String>(
        onSelected: (action) {
          switch (action) {
            case 'list_tools':
              _showToolsDialog(context, profile);
            case 'edit':
              _showProfileDialog(context, profile: profile);
            case 'delete':
              _deleteProfile(profile);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'list_tools',
            child: ListTile(
              leading: Icon(Icons.list_alt),
              title: Text('List Tools'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _showToolsDialog(BuildContext context, _RemoteMcpProfile profile) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${profile.name} Tools'),
        content: SizedBox(
          width: 420,
          child: profile.tools.isEmpty
              ? const Text('No tools discovered for this MCP service.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: profile.tools.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tool = profile.tools[index];
                    return ListTile(
                      leading: const Icon(Icons.extension_outlined),
                      title: Text(tool.name),
                      subtitle: tool.description.isEmpty
                          ? null
                          : Text(tool.description),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, {_RemoteMcpProfile? profile}) {
    final isEditing = profile != null;
    final nameController = TextEditingController(text: profile?.name ?? '');
    final urlController = TextEditingController(text: profile?.url ?? '');
    var transport = profile?.transport ?? _McpTransport.http;
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
                      hintText: 'https://mcp.example.com/sse',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<_McpTransport>(
                    initialValue: transport,
                    decoration: const InputDecoration(
                      labelText: 'Transport',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final item in _McpTransport.values)
                        DropdownMenuItem(value: item, child: Text(item.label)),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => transport = value);
                    },
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

  void _deleteProfile(_RemoteMcpProfile profile) {
    setState(() {
      _profiles = _profiles.where((item) => item.id != profile.id).toList();
    });
    _saveProfiles();
  }
}

enum _McpTransport {
  http,
  sse;

  String get label => switch (this) {
    _McpTransport.http => 'HTTP',
    _McpTransport.sse => 'SSE',
  };

  static _McpTransport parse(String? value) {
    for (final transport in values) {
      if (transport.name == value) return transport;
    }
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
  const _RemoteMcpTool({required this.name, this.description = ''});

  factory _RemoteMcpTool.fromJson(Map<String, dynamic> decoded) {
    return _RemoteMcpTool(
      name: decoded['name'] as String? ?? '',
      description: decoded['description'] as String? ?? '',
    );
  }

  final String name;
  final String description;

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}
