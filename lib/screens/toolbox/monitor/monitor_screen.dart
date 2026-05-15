import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/add_host_dialog.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/cert_mismatch_dialog.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/host_list_tile.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/metrics_dashboard.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/trust_dialog.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';
import 'package:monitor_bloc/monitor_bloc.dart';

class MonitorScreen extends StatefulWidget {
  static const name = 'Monitor';
  static const path = 'monitor';

  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  String? _selectedHostId;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Auto-trigger mDNS discovery on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDiscovery();
    });
  }

  void _startDiscovery() {
    setState(() => _isScanning = true);
    context.read<MonitorBloc>().add(const MonitorDiscoverHosts());
    // mDNS browse is finite; hide scanning after a timeout
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
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
                SizedBox(width: 280, child: _buildHostList(context, hosts)),
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
          return _buildHostList(context, hosts);
        },
      ),
    );
  }

  Widget _buildHostList(BuildContext context, Map<String, MonitorHost> hosts) {
    return SafeArea(
      minimum: Platform.isMacOS
          ? const EdgeInsets.all(kDefaultGridGap)
          : const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
      child: RefreshIndicator(
        onRefresh: () async => _startDiscovery(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
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
            if (hosts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monitor_heart_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isScanning ? 'Scanning network...' : 'No hosts found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a host manually or start an agent on your network.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _showAddHostDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Host'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: hosts.length,
                itemBuilder: (context, index) {
                  final host = hosts.values.elementAt(index);
                  return HostListTile(
                    host: host,
                    selected: host.id == _selectedHostId,
                    onTap: () {
                      if (host.trustStatus == TrustStatus.pending &&
                          host.certFingerprint != null) {
                        _showTrustDialog(context, host);
                      } else {
                        setState(() => _selectedHostId = host.id);
                      }
                    },
                    onRemove: () {
                      context.read<MonitorBloc>().add(
                        MonitorRemoveHost(hostId: host.id),
                      );
                      if (_selectedHostId == host.id) {
                        setState(() => _selectedHostId = null);
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDetail(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back,
            size: 48,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a host to view metrics',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsDetailWithBack(BuildContext context, MonitorHost host) {
    return Column(
      children: [
        DmAppBar(
          title: Text(host.displayName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to host list',
            onPressed: () => setState(() => _selectedHostId = null),
          ),
        ),
        Expanded(child: _buildMetricsContent(context, host)),
      ],
    );
  }

  Widget _buildMetricsDetail(BuildContext context, MonitorHost host) {
    return Column(
      children: [
        DmAppBar(title: Text(host.displayName)),
        Expanded(child: _buildMetricsContent(context, host)),
      ],
    );
  }

  Widget _buildMetricsContent(BuildContext context, MonitorHost host) {
    if (host.trustStatus == TrustStatus.pending) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color:
                  Theme.of(context).extension<DmColorExtension>()!.warning,
            ),
            const SizedBox(height: 16),
            const Text('Waiting for trust verification'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _showTrustDialog(context, host),
              child: const Text('Verify Fingerprint'),
            ),
          ],
        ),
      );
    }

    if (host.status == ConnectionStatus.connecting) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (host.status == ConnectionStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text('Unable to connect'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<MonitorBloc>().add(
                MonitorConnectHost(hostId: host.id),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (host.status == ConnectionStatus.disconnected) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 16),
            const Text('Disconnected'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<MonitorBloc>().add(
                MonitorConnectHost(hostId: host.id),
              ),
              child: const Text('Connect'),
            ),
          ],
        ),
      );
    }

    return MetricsDashboard(
      host: host,
      cpuHistory: host.cpuHistory,
      memoryHistory: host.memoryHistory,
      rxHistory: host.rxHistory,
      txHistory: host.txHistory,
      readHistory: host.readHistory,
      writeHistory: host.writeHistory,
    );
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
