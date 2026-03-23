import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/service/service_screen.dart';
import 'package:vultr_api/api.dart' show InstanceGet;
import 'package:vultr_bloc/vultr_bloc.dart';

class VultrDetailScreen extends StatelessWidget {
  static const name = 'VultrDetail';
  static const path = ':instanceId';

  const VultrDetailScreen({super.key, required this.instanceId});

  final String instanceId;

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
        child: BlocBuilder<VultrBloc, VultrState>(
          builder: (context, state) {
            if (state is! VultrLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final instance = state.instances
                .where((i) => i.id == instanceId)
                .firstOrNull;

            if (instance == null) {
              return const Center(child: Text('Instance not found'));
            }

            final isActioning = state.actionInstanceId == instanceId;

            return _DetailView(instance: instance, isActioning: isActioning);
          },
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.instance, required this.isActioning});

  final InstanceGet instance;
  final bool isActioning;

  @override
  Widget build(BuildContext context) {
    final isRunning = instance.powerStatus == 'running';
    final statusColor = isRunning ? Colors.green : Colors.red;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text(instance.label ?? instance.hostname ?? 'Server'),
          actions: [
            if (isActioning)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else ...[
              if (!isRunning)
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: () => _startInstance(context),
                  tooltip: 'Start',
                ),
              if (isRunning)
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.red),
                  onPressed: () => _stopInstance(context),
                  tooltip: 'Stop',
                ),
              if (isRunning)
                IconButton(
                  icon: const Icon(Icons.restart_alt, color: Colors.orange),
                  onPressed: () => _rebootInstance(context),
                  tooltip: 'Reboot',
                ),
            ],
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${instance.status ?? 'unknown'} / ${instance.powerStatus ?? 'unknown'}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: statusColor),
                        ),
                        const Spacer(),
                        Text(
                          'Server: ${instance.serverStatus ?? 'unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info sections
                _InfoSection(
                  title: 'Network',
                  items: [
                    _InfoItem('Main IP', instance.mainIp),
                    _InfoItem('Netmask', instance.netmaskV4),
                    _InfoItem('Gateway', instance.gatewayV4),
                    if (instance.internalIp?.isNotEmpty ?? false)
                      _InfoItem('Internal IP', instance.internalIp),
                  ],
                ),
                const SizedBox(height: 16),

                _InfoSection(
                  title: 'Specifications',
                  items: [
                    _InfoItem('OS', instance.os),
                    _InfoItem('Plan', instance.plan),
                    _InfoItem('vCPU', '${instance.vcpuCount ?? 0}'),
                    _InfoItem('RAM', _formatRam(instance.ram)),
                    _InfoItem('Disk', '${instance.disk ?? 0} GB'),
                    _InfoItem(
                      'Bandwidth',
                      '${instance.allowedBandwidth ?? 0} GB/mo',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _InfoSection(
                  title: 'Details',
                  items: [
                    _InfoItem('ID', instance.id),
                    _InfoItem('Region', instance.region),
                    _InfoItem('Hostname', instance.hostname),
                    _InfoItem('Created', instance.dateCreated),
                    if (instance.tags.isNotEmpty)
                      _InfoItem('Tags', instance.tags.join(', ')),
                    if (instance.features.isNotEmpty)
                      _InfoItem('Features', instance.features.join(', ')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatRam(int? ramMb) {
    if (ramMb == null) return '0 MB';
    if (ramMb >= 1024) return '${(ramMb / 1024).toStringAsFixed(1)} GB';
    return '$ramMb MB';
  }

  void _startInstance(BuildContext context) {
    if (instance.id == null) return;
    context.read<VultrBloc>().add(VultrStartInstance(instanceId: instance.id!));
  }

  void _stopInstance(BuildContext context) {
    if (instance.id == null) return;
    _showConfirmDialog(
      context,
      title: 'Stop Server',
      content: 'Stop "${instance.label ?? instance.hostname}"?',
      onConfirm: () => context.read<VultrBloc>().add(
        VultrStopInstance(instanceId: instance.id!),
      ),
    );
  }

  void _rebootInstance(BuildContext context) {
    if (instance.id == null) return;
    _showConfirmDialog(
      context,
      title: 'Reboot Server',
      content: 'Reboot "${instance.label ?? instance.hostname}"?',
      onConfirm: () => context.read<VultrBloc>().add(
        VultrRebootInstance(instanceId: instance.id!),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.items});

  final String title;
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          if (item.value != null) {
                            Clipboard.setData(ClipboardData(text: item.value!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied ${item.label}')),
                            );
                          }
                        },
                        child: Text(item.value ?? '-'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String? value;
}
