import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:app_system_metrics/app_system_metrics.dart' as sys;
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/device/activity_monitor_dashboard.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/add_host_dialog.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/cert_mismatch_dialog.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/host_activity_converter.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/host_card.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/trust_dialog.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:monitor_bloc/monitor_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MonitorScreen extends StatefulWidget {
  static const name = 'Monitor';
  static const path = 'monitor';

  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  late final MonitorBloc _monitorBloc;
  String? _selectedHostId;
  bool _isScanning = false;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _monitorBloc = context.read<MonitorBloc>();
    // Auto-trigger mDNS discovery on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDiscovery();
    });
  }

  @override
  void dispose() {
    _monitorBloc.add(const MonitorDisconnectAllHosts());
    if (_isPinned) {
      WakelockPlus.disable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
      if (_isPinned) {
        WakelockPlus.enable();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        WakelockPlus.disable();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _startDiscovery() {
    setState(() => _isScanning = true);
    _monitorBloc.add(const MonitorDiscoverHosts());
    // mDNS browse is finite; hide scanning after a timeout
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => BlocConsumer<MonitorBloc, MonitorState>(
        listenWhen: (prev, curr) {
          if (prev is! MonitorLoaded || curr is! MonitorLoaded) return false;
          for (final entry in curr.hosts.entries) {
            final prevHost = prev.hosts[entry.key];
            if (prevHost == null) continue;
            final changed = prevHost.trustStatus != entry.value.trustStatus;
            if (changed &&
                (entry.value.trustStatus == TrustStatus.pending ||
                    entry.value.trustStatus == TrustStatus.mismatch)) {
              return true;
            }
          }
          return false;
        },
        listener: (context, state) {
          if (state is! MonitorLoaded) return;
          for (final host in state.hosts.values) {
            if (host.trustStatus == TrustStatus.pending &&
                host.certFingerprint != null) {
              _showTrustDialog(context, host);
              break;
            }
            if (host.trustStatus == TrustStatus.mismatch &&
                host.certFingerprint != null) {
              _showMismatchDialog(context, host);
              break;
            }
          }
        },
        builder: (context, state) {
          final hosts = switch (state) {
            MonitorLoaded(:final hosts) => hosts,
            _ => const <String, MonitorHost>{},
          };

          final screenWidth = MediaQuery.of(context).size.width;
          final isWide = screenWidth >= 900;

          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 360,
                  child: _buildHostList(context, hosts, isSidePane: true),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child:
                      _selectedHostId != null &&
                              hosts.containsKey(_selectedHostId)
                          ? _buildMetricsDetail(context, hosts[_selectedHostId]!)
                          : _buildEmptyDetail(context),
                ),
              ],
            );
          }

          if (_selectedHostId != null && hosts.containsKey(_selectedHostId)) {
            return _buildMetricsDetailWithBack(
              context,
              hosts[_selectedHostId]!,
            );
          }
          return _buildHostList(context, hosts, isSidePane: false);
        },
      ),
    );
  }

  Widget _buildHostList(
    BuildContext context,
    Map<String, MonitorHost> hosts, {
    bool isSidePane = false,
  }) {
    return SafeArea(
      minimum: Platform.isMacOS
          ? const EdgeInsets.all(kDefaultGridGap)
          : const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
      child: RefreshIndicator(
        onRefresh: () async => _startDiscovery(),
        child: CustomScrollView(
          slivers: [
            DmNavigationHeader(
              builder: (context, header) => SliverAppBar(
                leading: isSidePane ? null : header.leading,
                leadingWidth: isSidePane ? null : header.leadingWidth,
                automaticallyImplyLeading:
                    !isSidePane && header.automaticallyImplyLeading,
                floating: true,
                title: const Text('Monitor'),
                actions: [
                  if (_isScanning)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _startDiscovery,
                    tooltip: 'Scan network',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddHostDialog(context),
                    tooltip: 'Add host manually',
                  ),
                ],
              ),
            ),
            if (hosts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.monitor_heart_outlined,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isScanning
                                  ? 'Scanning network...'
                                  : 'No hosts found',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a host manually or start an agent on your local network.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () => _showAddHostDialog(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Host'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              _buildResponsiveHostGrid(context, hosts, isSidePane: isSidePane),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveHostGrid(
    BuildContext context,
    Map<String, MonitorHost> hosts, {
    required bool isSidePane,
  }) {
    if (isSidePane) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        sliver: SliverList.separated(
          itemCount: hosts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final host = hosts.values.elementAt(index);
            return HostCard(
              host: host,
              selected: host.id == _selectedHostId,
              onTap: () => _onHostTap(host),
              onRemove: () => _onHostRemove(host),
              onConnect: () => _monitorBloc.add(
                MonitorConnectHost(hostId: host.id),
              ),
              onDisconnect: () => _monitorBloc.add(
                MonitorDisconnectHost(hostId: host.id),
              ),
            );
          },
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.crossAxisExtent;
        const padding = 16.0;
        const gap = 16.0;
        final contentWidth = availableWidth - padding * 2;
        final cols = (contentWidth / 360).floor().clamp(1, 4);

        if (cols == 1) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: padding,
              vertical: 12,
            ),
            sliver: SliverList.separated(
              itemCount: hosts.length,
              separatorBuilder: (_, _) => const SizedBox(height: gap),
              itemBuilder: (context, index) {
                final host = hosts.values.elementAt(index);
                return HostCard(
                  host: host,
                  selected: host.id == _selectedHostId,
                  onTap: () => _onHostTap(host),
                  onRemove: () => _onHostRemove(host),
                  onConnect: () => _monitorBloc.add(
                    MonitorConnectHost(hostId: host.id),
                  ),
                  onDisconnect: () => _monitorBloc.add(
                    MonitorDisconnectHost(hostId: host.id),
                  ),
                );
              },
            ),
          );
        }

        final cardWidth = (contentWidth - (cols - 1) * gap) / cols;
        return SliverPadding(
          padding: const EdgeInsets.all(padding),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: hosts.values.map((host) {
                return SizedBox(
                  width: cardWidth,
                  child: HostCard(
                    host: host,
                    selected: host.id == _selectedHostId,
                    onTap: () => _onHostTap(host),
                    onRemove: () => _onHostRemove(host),
                    onConnect: () => _monitorBloc.add(
                      MonitorConnectHost(hostId: host.id),
                    ),
                    onDisconnect: () => _monitorBloc.add(
                      MonitorDisconnectHost(hostId: host.id),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _onHostTap(MonitorHost host) {
    if (host.trustStatus == TrustStatus.pending &&
        host.certFingerprint != null) {
      _showTrustDialog(context, host);
    } else {
      if (host.status == ConnectionStatus.disconnected) {
        _monitorBloc.add(MonitorConnectHost(hostId: host.id));
      }
      setState(() => _selectedHostId = host.id);
    }
  }

  void _onHostRemove(MonitorHost host) {
    _monitorBloc.add(MonitorRemoveHost(hostId: host.id));
    if (_selectedHostId == host.id) {
      setState(() => _selectedHostId = null);
    }
  }

  Widget _buildEmptyDetail(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.computer_outlined,
                size: 44,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Host Selected',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a host from the list to view real-time CPU, memory, disk, and network activity.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsDetailWithBack(BuildContext context, MonitorHost host) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to host list',
              onPressed: () => setState(() => _selectedHostId = null),
            ),
            title: _buildHostTitle(context, host),
            actions: _buildHostActions(context, host),
          ),
          ..._buildMetricsSlivers(context, host),
        ],
      ),
    );
  }

  Widget _buildMetricsDetail(BuildContext context, MonitorHost host) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            title: _buildHostTitle(context, host),
            actions: _buildHostActions(context, host),
          ),
          ..._buildMetricsSlivers(context, host),
        ],
      ),
    );
  }

  Widget _buildHostTitle(BuildContext context, MonitorHost host) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final osText = host.hostInfo?.os != null && host.hostInfo!.os.isNotEmpty
        ? ' • ${host.hostInfo!.os}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          host.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${host.ip}:${host.port}$osText',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  List<Widget> _buildHostActions(BuildContext context, MonitorHost host) {
    return [
      if (host.status == ConnectionStatus.connected)
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Ping host',
          onPressed: () => _monitorBloc.add(
            MonitorPingHost(hostId: host.id),
          ),
        ),
      IconButton(
        icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
        tooltip: _isPinned ? 'Unpin' : 'Pin fullscreen',
        onPressed: _togglePin,
      ),
      PopupMenuButton<String>(
        onSelected: (action) {
          switch (action) {
            case 'connect':
              _monitorBloc.add(MonitorConnectHost(hostId: host.id));
            case 'disconnect':
              _monitorBloc.add(MonitorDisconnectHost(hostId: host.id));
            case 'remove':
              _onHostRemove(host);
          }
        },
        itemBuilder: (context) => [
          if (host.status != ConnectionStatus.connected)
            const PopupMenuItem(
              value: 'connect',
              child: Row(
                children: [
                  Icon(Icons.link, size: 18),
                  SizedBox(width: 8),
                  Text('Connect'),
                ],
              ),
            )
          else
            const PopupMenuItem(
              value: 'disconnect',
              child: Row(
                children: [
                  Icon(Icons.link_off, size: 18),
                  SizedBox(width: 8),
                  Text('Disconnect'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18),
                SizedBox(width: 8),
                Text('Remove Host'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMetricsSlivers(BuildContext context, MonitorHost host) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dmColors = theme.extension<DmColorExtension>();
    final warningColor = dmColors?.warning ?? colorScheme.secondary;

    if (host.trustStatus == TrustStatus.pending) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: warningColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 48, color: warningColor),
                      const SizedBox(height: 16),
                      Text(
                        'Certificate Verification Required',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This host is presenting a new TLS certificate. Verify its fingerprint to establish trust.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => _showTrustDialog(context, host),
                        icon: const Icon(Icons.verified_user),
                        label: const Text('Verify Fingerprint'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    if (host.status == ConnectionStatus.connecting) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator.adaptive(),
                const SizedBox(height: 16),
                Text(
                  'Connecting to ${host.displayName}...',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${host.ip}:${host.port}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (host.status == ConnectionStatus.error) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connection Error',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to connect to host agent at ${host.ip}:${host.port}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _monitorBloc.add(
                      MonitorConnectHost(hostId: host.id),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Connection'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    if (host.status == ConnectionStatus.disconnected) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 48,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Host Offline',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Host is disconnected. Connect to resume live telemetry monitoring.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _monitorBloc.add(
                      MonitorConnectHost(hostId: host.id),
                    ),
                    icon: const Icon(Icons.link),
                    label: const Text('Connect Host'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final sysSnapshot = host.snapshot != null
        ? toAppMetricsSnapshot(host.snapshot!)
        : (host.metrics != null
            ? systemMetricsToActivitySnapshot(host.metrics!, host.hostInfo)
            : null);

    if (sysSnapshot != null) {
      final sysHistory = host.history.isNotEmpty
          ? host.history.map(toAppMetricsSnapshot).toList()
          : <sys.ActivitySnapshot>[sysSnapshot];

      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          sliver: SliverToBoxAdapter(
            child: ActivityMonitorDashboard(
              snapshot: sysSnapshot,
              history: sysHistory,
              running: host.status == ConnectionStatus.connected,
              deviceName: host.displayName,
            ),
          ),
        ),
      ];
    }

    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator.adaptive(),
              const SizedBox(height: 16),
              Text(
                'Waiting for telemetry from ${host.displayName}...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showTrustDialog(BuildContext context, MonitorHost host) {
    final bloc = context.read<MonitorBloc>();
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TrustDialog(
        hostname: host.displayName,
        fingerprint: host.certFingerprint ?? 'Unknown',
      ),
    ).then((trusted) {
      if (trusted == true) {
        bloc.add(MonitorTrustHost(hostId: host.id));
      } else {
        bloc.add(MonitorRejectHost(hostId: host.id));
      }
    });
  }

  void _showMismatchDialog(BuildContext context, MonitorHost host) {
    final bloc = context.read<MonitorBloc>();
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CertMismatchDialog(
        hostname: host.displayName,
        previousFingerprint: 'Previously pinned',
        currentFingerprint: host.certFingerprint ?? 'Unknown',
      ),
    ).then((reTrust) {
      if (reTrust == true) {
        bloc.add(MonitorTrustHost(hostId: host.id));
      } else {
        bloc.add(MonitorRejectHost(hostId: host.id));
      }
    });
  }

  void _showAddHostDialog(BuildContext context) {
    final bloc = context.read<MonitorBloc>();
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddHostDialog(),
    ).then((result) {
      if (result != null) {
        bloc.add(
          MonitorAddManualHost(
            ip: result['ip'] as String,
            port: result['port'] as int,
          ),
        );
      }
    });
  }
}
