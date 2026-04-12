import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_database/app_database.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/service/service_screen.dart';
import 'package:vultr_api/api.dart' show InstanceGet;
import 'package:vultr_bloc/vultr_bloc.dart';

class VultrScreen extends StatelessWidget {
  static const name = 'Vultr';
  static const path = 'vultr';

  const VultrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ServiceScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        child: BlocConsumer<VultrBloc, VultrState>(
          listener: (context, state) {
            if (state is VultrLoaded && state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            return switch (state) {
              VultrLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              VultrInitial() => const _AccountSelectView(),
              VultrError(:final message) => _ErrorView(message: message),
              VultrLoaded(:final instances, :final refreshing) =>
                _InstancesListView(
                  instances: instances,
                  refreshing: refreshing,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _AccountSelectView extends StatelessWidget {
  const _AccountSelectView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        final accounts = state is AccountsLoaded
            ? state.accounts
                  .where((a) => a.provider == ServiceProvider.vultr)
                  .toList()
            : <ServiceAccountTableData>[];

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Vultr Servers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select a Vultr account to manage cloud servers.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (accounts.isEmpty) ...[
                    const Text(
                      'No Vultr accounts configured.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/settings/account'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Vultr Account'),
                    ),
                  ] else ...[
                    ...accounts.map(
                      (account) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.cloud),
                          title: Text(account.name),
                          subtitle: account.description.isNotEmpty
                              ? Text(account.description)
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.read<VultrBloc>().add(
                              VultrSelectAccount(accountId: account.id),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => context.go('/settings/account'),
                      icon: const Icon(Icons.settings),
                      label: const Text('Manage Accounts'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text('Error: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<VultrBloc>().add(const VultrRefresh()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _InstancesListView extends StatelessWidget {
  const _InstancesListView({required this.instances, required this.refreshing});

  final List<InstanceGet> instances;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Vultr Servers'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<VultrBloc>().add(const VultrRefresh()),
              tooltip: 'Refresh',
            ),
          ],
        ),
        if (refreshing)
          const SliverToBoxAdapter(child: LinearProgressIndicator()),
        if (instances.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dns_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('No instances found'),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final instance = instances[index];
              return _InstanceTile(instance: instance);
            }, childCount: instances.length),
          ),
      ],
    );
  }
}

class _InstanceTile extends StatelessWidget {
  const _InstanceTile({required this.instance});

  final InstanceGet instance;

  @override
  Widget build(BuildContext context) {
    final isRunning = instance.powerStatus == 'running';
    final statusColor = isRunning ? Colors.green : Colors.red;
    final statusIcon = isRunning ? Icons.play_circle : Icons.stop_circle;

    final bloc = context.watch<VultrBloc>();
    final isActioning =
        bloc.state is VultrLoaded &&
        (bloc.state as VultrLoaded).actionInstanceId == instance.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: isActioning
            ? const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(statusIcon, color: statusColor, size: 32),
        title: Text(instance.label ?? instance.hostname ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${instance.mainIp ?? ''} • ${instance.region ?? ''}'),
            Text(
              '${instance.os ?? ''} • ${instance.vcpuCount ?? 0} vCPU • ${_formatRam(instance.ram)} RAM • ${instance.disk ?? 0} GB',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${instance.status ?? 'unknown'} / ${instance.powerStatus ?? 'unknown'}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: statusColor),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          enabled: !isActioning,
          onSelected: (value) => _onAction(context, value),
          itemBuilder: (context) => [
            if (!isRunning)
              const PopupMenuItem(
                value: 'start',
                child: ListTile(
                  leading: Icon(Icons.play_arrow, color: Colors.green),
                  title: Text('Start'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (isRunning)
              const PopupMenuItem(
                value: 'stop',
                child: ListTile(
                  leading: Icon(Icons.stop, color: Colors.red),
                  title: Text('Stop'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (isRunning)
              const PopupMenuItem(
                value: 'reboot',
                child: ListTile(
                  leading: Icon(Icons.restart_alt, color: Colors.orange),
                  title: Text('Reboot'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        onTap: () => context.go('/service/vultr/${instance.id}'),
      ),
    );
  }

  String _formatRam(int? ramMb) {
    if (ramMb == null) return '0 MB';
    if (ramMb >= 1024) return '${(ramMb / 1024).toStringAsFixed(1)} GB';
    return '$ramMb MB';
  }

  void _onAction(BuildContext context, String action) {
    final id = instance.id;
    if (id == null) return;

    switch (action) {
      case 'start':
        context.read<VultrBloc>().add(VultrStartInstance(instanceId: id));
      case 'stop':
        _showConfirmDialog(
          context,
          title: 'Stop Server',
          content: 'Stop "${instance.label ?? instance.hostname}"?',
          onConfirm: () =>
              context.read<VultrBloc>().add(VultrStopInstance(instanceId: id)),
        );
      case 'reboot':
        _showConfirmDialog(
          context,
          title: 'Reboot Server',
          content: 'Reboot "${instance.label ?? instance.hostname}"?',
          onConfirm: () => context.read<VultrBloc>().add(
            VultrRebootInstance(instanceId: id),
          ),
        );
    }
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDmDialog(
      context: context,
      title: Text(title),
      content: Text(content),
      actions: [
        DmDialogAction(
          onPressed: (ctx) => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        DmDialogAction(
          onPressed: (ctx) {
            onConfirm();
            Navigator.of(ctx).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
