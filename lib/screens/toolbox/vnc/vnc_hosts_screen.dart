import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:app_vnc/app_vnc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_launch_config.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_session_route.dart';
import 'package:gsmlg/screens/toolbox/vnc/widgets/vnc_host_form_dialog.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:vnc_host_bloc/vnc_host_bloc.dart';

/// Native VNC hosts screen displaying saved hosts and Bonjour LAN discovery.
class VncScreen extends StatefulWidget {
  static const name = 'Vnc';
  static const path = 'vnc';

  const VncScreen({super.key, this.autoDiscover = true});

  final bool autoDiscover;

  @override
  State<VncScreen> createState() => _VncScreenState();
}

class _VncScreenState extends State<VncScreen> {
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sshHostBloc = _maybeReadSshHostBloc(context);
      if (sshHostBloc != null && sshHostBloc.state is SshHostInitial) {
        sshHostBloc.add(SshHostLoad());
      }
      final sshKeyBloc = _maybeReadSshKeyBloc(context);
      if (sshKeyBloc != null && sshKeyBloc.state is SshKeyInitial) {
        sshKeyBloc.add(SshKeyLoad());
      }
      if (widget.autoDiscover) {
        context.read<VncHostBloc>().add(const VncHostDiscoverLan());
      }
    });
  }

  SshHostBloc? _maybeWatchSshHostBloc(BuildContext context) {
    try {
      return context.watch<SshHostBloc>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  SshHostBloc? _maybeReadSshHostBloc(BuildContext context) {
    try {
      return context.read<SshHostBloc>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  SshKeyBloc? _maybeReadSshKeyBloc(BuildContext context) {
    try {
      return context.read<SshKeyBloc>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  SshCredentialRepository? _maybeReadSshCredentials(BuildContext context) {
    try {
      return context.read<SshCredentialRepository>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  List<SshHost> _readSshHosts(SshHostBloc? sshHostBloc) {
    final state = sshHostBloc?.state;
    if (state is SshHostLoaded) {
      return state.sshHosts;
    }
    return const [];
  }

  VncAuthPreference _toAuthPreference(VncHostAuthType type) => switch (type) {
    VncHostAuthType.auto => VncAuthPreference.auto,
    VncHostAuthType.none => VncAuthPreference.none,
    VncHostAuthType.vncPassword => VncAuthPreference.vncPassword,
    VncHostAuthType.appleArd => VncAuthPreference.appleArd,
  };

  String _authBadgeLabel(BuildContext context, VncHostAuthType type) {
    final l10n = context.l10n;
    return switch (type) {
      VncHostAuthType.auto => l10n.vncAuthAuto,
      VncHostAuthType.appleArd => l10n.vncAuthAppleArd,
      VncHostAuthType.vncPassword => l10n.vncAuthPassword,
      VncHostAuthType.none => l10n.vncAuthNone,
    };
  }

  Future<VncSshTunnelConfig?> _buildSshTunnelConfig(
    BuildContext context,
    int? sshHostId,
    Map<int, SshHost> sshHostMap,
  ) async {
    if (sshHostId == null) {
      return null;
    }
    final sshHost = sshHostMap[sshHostId];
    if (sshHost == null) {
      throw StateError(
        'Configured SSH tunnel host was not found. Update or remove the SSH tunnel before connecting.',
      );
    }

    final hostAddress = (sshHost.hostname?.trim().isNotEmpty ?? false)
        ? sshHost.hostname!.trim()
        : (sshHost.host?.trim() ?? '');
    if (hostAddress.isEmpty) {
      throw StateError(
        'Configured SSH tunnel host has no hostname or address.',
      );
    }

    final credentials = _maybeReadSshCredentials(context);
    if (credentials == null) {
      throw StateError(
        'SSH credentials service is unavailable for the configured SSH tunnel.',
      );
    }
    final port = sshHost.port ?? 22;
    final username = sshHost.username?.trim() ?? '';

    if (SshIdentityType.fromValue(sshHost.identityType) ==
        SshIdentityType.key) {
      final keyId = sshHost.identityKeyId;
      SshKey? sshKey;
      final keyState = _maybeReadSshKeyBloc(context)?.state;
      if (keyId != null && keyState is SshKeyLoaded) {
        for (final key in keyState.sshKeys) {
          if (key.id == keyId) {
            sshKey = key;
            break;
          }
        }
      }
      if (sshKey == null) {
        throw StateError('SSH private key not found for tunnel host.');
      }
      final privateKeyPem = await credentials.readPrivateKey(sshKey);
      final passphrase = await credentials.readKeyPassphrase(sshKey);
      return VncSshTunnelConfig(
        host: hostAddress,
        port: port,
        username: username,
        privateKeyPem: privateKeyPem,
        privateKeyPassphrase: passphrase,
      );
    }

    final sshPassword = await credentials.readHostPassword(sshHost);
    return VncSshTunnelConfig(
      host: hostAddress,
      port: port,
      username: username,
      password: sshPassword,
    );
  }

  void _openSession(VncLaunchConfig launchConfig) {
    if (!mounted) return;
    context.goNamed(VncSessionScreen.name, extra: launchConfig);
  }

  void _showErrorSnackBar(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.l10n.error}: $error'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _connectSavedHost(
    VncHost host,
    Map<int, SshHost> sshHostMap,
  ) async {
    if (_isLaunching) return;
    _isLaunching = true;
    final vncHostBloc = context.read<VncHostBloc>();
    try {
      final sshTunnel = await _buildSshTunnelConfig(
        context,
        host.sshHostId,
        sshHostMap,
      );
      if (!mounted) return;
      final password = await vncHostBloc.repository.readPassword(host);
      if (!mounted) return;

      vncHostBloc.add(VncHostMarkConnected(host.id));

      final authType = VncHostAuthType.fromValue(host.authType);
      _openSession(
        VncLaunchConfig(
          title: host.name,
          savedHostId: host.id,
          config: VncConnectionConfig(
            host: host.host,
            port: host.port,
            authPreference: _toAuthPreference(authType),
            credentials: VncCredentials(
              username: host.username,
              password: password,
            ),
            sshTunnel: sshTunnel,
            viewOnly: host.viewOnly,
          ),
        ),
      );
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      _isLaunching = false;
    }
  }

  Future<void> _openQuickConnect(
    List<SshHost> sshHosts,
    Map<int, SshHost> sshHostMap,
  ) async {
    final result = await VncHostFormDialog.show(
      context,
      mode: VncHostFormMode.quickConnect,
      sshHosts: sshHosts,
    );
    if (result == null || !mounted || _isLaunching) return;

    _isLaunching = true;
    try {
      final sshTunnel = await _buildSshTunnelConfig(
        context,
        result.sshHostId,
        sshHostMap,
      );
      if (!mounted) return;
      _openSession(
        VncLaunchConfig(
          title: result.name,
          config: VncConnectionConfig(
            host: result.host,
            port: result.port,
            authPreference: _toAuthPreference(result.authType),
            credentials: VncCredentials(
              username: result.username,
              password: result.password,
            ),
            sshTunnel: sshTunnel,
            viewOnly: result.viewOnly,
          ),
        ),
      );
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      _isLaunching = false;
    }
  }

  Future<void> _openAddHostDialog(
    List<SshHost> sshHosts, {
    String? prefillName,
    String? prefillHost,
    int? prefillPort,
    VncHostAuthType? prefillAuthType,
  }) async {
    final result = await VncHostFormDialog.show(
      context,
      mode: VncHostFormMode.add,
      prefillName: prefillName,
      prefillHost: prefillHost,
      prefillPort: prefillPort,
      prefillAuthType: prefillAuthType,
      sshHosts: sshHosts,
    );
    if (result == null || !mounted) return;

    context.read<VncHostBloc>().add(
      VncHostAdd(
        name: result.name,
        host: result.host,
        port: result.port,
        authType: result.authType,
        username: result.username,
        password: result.password,
        sshHostId: result.sshHostId,
        viewOnly: result.viewOnly,
      ),
    );
  }

  Future<void> _openEditHostDialog(VncHost host, List<SshHost> sshHosts) async {
    final result = await VncHostFormDialog.show(
      context,
      mode: VncHostFormMode.edit,
      initialHost: host,
      sshHosts: sshHosts,
    );
    if (result == null || !mounted) return;

    context.read<VncHostBloc>().add(
      VncHostUpdate(
        id: host.id,
        name: result.name,
        host: result.host,
        port: result.port,
        authType: result.authType,
        username: result.username,
        password: result.password,
        clearPassword: result.clearPassword,
        sshHostId: result.sshHostId,
        viewOnly: result.viewOnly,
      ),
    );
  }

  Future<void> _confirmDeleteHost(VncHost host) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.vncDeleteHost),
        content: Text(l10n.vncDeleteHostConfirm(host.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<VncHostBloc>().add(VncHostDelete(host));
    }
  }

  void _connectDiscoveredHost(VncDiscoveredHost discovered) {
    _openSession(
      VncLaunchConfig(
        title: discovered.name,
        config: VncConnectionConfig(
          host: discovered.preferredAddress,
          port: discovered.port,
          authPreference: VncAuthPreference.auto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sshHostBloc = _maybeWatchSshHostBloc(context);
    final sshHosts = _readSshHosts(sshHostBloc);
    final sshHostMap = <int, SshHost>{for (final h in sshHosts) h.id: h};

    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => BlocBuilder<VncHostBloc, VncHostState>(
        builder: (context, state) {
          return SafeArea(
            minimum: const EdgeInsets.symmetric(
              horizontal: Constants.defaultGridGap,
            ),
            child: CustomScrollView(
              slivers: [
                DmNavigationHeader(
                  builder: (context, header) {
                    final isNarrow = MediaQuery.sizeOf(context).width < 460;
                    return SliverAppBar(
                      leading: header.leading,
                      leadingWidth: header.leadingWidth,
                      automaticallyImplyLeading:
                          header.automaticallyImplyLeading,
                      floating: true,
                      title: Text(l10n.vncTitle),
                      actions: [
                        if (isNarrow)
                          IconButton(
                            icon: const Icon(Icons.bolt),
                            tooltip: l10n.vncQuickConnect,
                            onPressed: () =>
                                _openQuickConnect(sshHosts, sshHostMap),
                          )
                        else
                          TextButton.icon(
                            onPressed: () =>
                                _openQuickConnect(sshHosts, sshHostMap),
                            icon: const Icon(Icons.bolt, size: 18),
                            label: Text(l10n.vncQuickConnect),
                          ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: l10n.vncAddHost,
                          onPressed: () => _openAddHostDialog(sshHosts),
                        ),
                        if (state.isDiscovering)
                          IconButton(
                            tooltip: l10n.vncRefreshLan,
                            onPressed: null,
                            icon: const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: l10n.vncRefreshLan,
                            onPressed: () => context.read<VncHostBloc>().add(
                              const VncHostDiscoverLan(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      icon: Icons.desktop_windows_outlined,
                      title: l10n.vncSavedHosts,
                    ),
                  ),
                ),
                if (state.isLoading && state.hosts.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (state.hosts.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    sliver: SliverToBoxAdapter(
                      child: _EmptySectionCard(
                        icon: Icons.desktop_access_disabled_outlined,
                        message: l10n.vncNoSavedHosts,
                        action: FilledButton.icon(
                          onPressed: () => _openAddHostDialog(sshHosts),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n.vncAddHost),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    sliver: SliverList.separated(
                      itemCount: state.hosts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final host = state.hosts[index];
                        final authType = VncHostAuthType.fromValue(
                          host.authType,
                        );
                        final sshTunnelHost = host.sshHostId != null
                            ? sshHostMap[host.sshHostId]
                            : null;
                        return _SavedHostCard(
                          host: host,
                          authLabel: _authBadgeLabel(context, authType),
                          sshTunnelHost: sshTunnelHost,
                          onTap: () => _connectSavedHost(host, sshHostMap),
                          onEdit: () => _openEditHostDialog(host, sshHosts),
                          onDelete: () => _confirmDeleteHost(host),
                        );
                      },
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      icon: Icons.wifi_tethering,
                      title: l10n.vncLanDiscovery,
                      trailing: state.isDiscovering
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.vncScanningLan,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                if (state.discoveredHosts.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                    sliver: SliverToBoxAdapter(
                      child: _EmptySectionCard(
                        icon: Icons.radar,
                        message: state.isDiscovering
                            ? l10n.vncScanningLan
                            : l10n.vncNoDiscoveredHosts,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                    sliver: SliverList.separated(
                      itemCount: state.discoveredHosts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final discovered = state.discoveredHosts[index];
                        return _DiscoveredHostCard(
                          host: discovered,
                          onConnect: () => _connectDiscoveredHost(discovered),
                          onSave: () => _openAddHostDialog(
                            sshHosts,
                            prefillName: discovered.name,
                            prefillHost: discovered.preferredAddress,
                            prefillPort: discovered.port,
                            prefillAuthType: VncHostAuthType.auto,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  const _EmptySectionCard({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 14), action!],
          ],
        ),
      ),
    );
  }
}

class _SavedHostCard extends StatelessWidget {
  const _SavedHostCard({
    required this.host,
    required this.authLabel,
    required this.sshTunnelHost,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final VncHost host;
  final String authLabel;
  final SshHost? sshTunnelHost;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tunnelLabel = sshTunnelHost != null
        ? (sshTunnelHost!.host?.trim().isNotEmpty == true
              ? sshTunnelHost!.host!.trim()
              : (sshTunnelHost!.hostname?.trim() ?? ''))
        : null;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.desktop_mac_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      host.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${host.host}:${host.port}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _InfoBadge(
                          label: authLabel,
                          backgroundColor: colorScheme.secondaryContainer,
                          foregroundColor: colorScheme.onSecondaryContainer,
                        ),
                        if (tunnelLabel != null && tunnelLabel.isNotEmpty)
                          _InfoBadge(
                            icon: Icons.vpn_key_outlined,
                            label: '${l10n.vncSshTunnelLabel}: $tunnelLabel',
                            backgroundColor: colorScheme.tertiaryContainer,
                            foregroundColor: colorScheme.onTertiaryContainer,
                          ),
                        if (host.viewOnly)
                          _InfoBadge(
                            icon: Icons.visibility_outlined,
                            label: l10n.vncViewOnlyLabel,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            foregroundColor: colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: l10n.vncEditHost,
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: l10n.vncDeleteHost,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveredHostCard extends StatelessWidget {
  const _DiscoveredHostCard({
    required this.host,
    required this.onConnect,
    required this.onSave,
  });

  final VncDiscoveredHost host;
  final VoidCallback onConnect;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final infoRow = Row(
              children: [
                Icon(Icons.computer_outlined, color: colorScheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        host.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${host.preferredAddress}:${host.port}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  infoRow,
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: onSave,
                        child: Text(l10n.vncSaveHost),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: onConnect,
                        child: Text(l10n.vncConnect),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: infoRow),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onSave,
                  child: Text(l10n.vncSaveHost),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: onConnect,
                  child: Text(l10n.vncConnect),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
