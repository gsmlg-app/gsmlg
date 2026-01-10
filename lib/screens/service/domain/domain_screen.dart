import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_database/app_database.dart';
import 'package:domain_bloc/domain_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/service/service_screen.dart';

class DomainScreen extends StatefulWidget {
  static const name = 'Domain';
  static const path = 'domain';

  const DomainScreen({super.key});

  @override
  State<DomainScreen> createState() => _DomainScreenState();
}

class _DomainScreenState extends State<DomainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ZoneBloc>().add(const ZoneSync());
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key(ServiceScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('DNS Zones'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => context.go('/service/domain/add'),
                  tooltip: 'Add Zone',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<ZoneBloc>().add(const ZoneSync()),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            BlocBuilder<ZoneBloc, ZoneState>(
              builder: (context, state) {
                return switch (state) {
                  ZoneInitial() => const SliverFillRemaining(
                      child: Center(child: Text('Loading zones...')),
                    ),
                  ZoneLoading() => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ZoneFailure(:final error) => SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 16),
                            Text('Error: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<ZoneBloc>().add(const ZoneSync()),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ZoneLoaded(:final zones) when zones.isEmpty =>
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.dns_outlined, size: 64),
                            const SizedBox(height: 16),
                            const Text('No DNS zones configured'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/service/domain/add'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Zone'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ZoneLoaded(:final zones) => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final zone = zones[index];
                          return _ZoneListTile(zone: zone);
                        },
                        childCount: zones.length,
                      ),
                    ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneListTile extends StatelessWidget {
  final DnsZoneTableData zone;

  const _ZoneListTile({required this.zone});

  @override
  Widget build(BuildContext context) {
    final providerIcon = switch (zone.provider) {
      DnsProvider.route53 => Icons.cloud_outlined,
      DnsProvider.cloudflare => Icons.cloud_circle_outlined,
    };

    final providerName = switch (zone.provider) {
      DnsProvider.route53 => 'AWS Route 53',
      DnsProvider.cloudflare => 'Cloudflare',
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(providerIcon, size: 32),
        title: Text(zone.zoneName),
        subtitle: Text('$providerName • ${zone.zoneId}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _showDeleteDialog(context, zone);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => context.go('/service/domain/${zone.id}'),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DnsZoneTableData zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Zone'),
        content: Text('Are you sure you want to remove "${zone.zoneName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ZoneBloc>().add(ZoneRemove(zone));
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
