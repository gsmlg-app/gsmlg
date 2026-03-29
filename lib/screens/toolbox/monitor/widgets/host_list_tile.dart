import 'package:flutter/material.dart';
import 'package:monitor_bloc/monitor_bloc.dart';

import 'package:gsmlg/screens/toolbox/monitor/widgets/version_badge.dart';

class HostListTile extends StatelessWidget {
  const HostListTile({
    super.key,
    required this.host,
    required this.onTap,
    required this.onRemove,
    this.selected = false,
  });

  final MonitorHost host;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      leading: Stack(
        children: [
          Icon(_statusIcon, color: _statusColor),
          // Badge: discovered (network icon) vs manual (pin icon)
          Positioned(
            right: -2,
            bottom: -2,
            child: Icon(
              host.isManual ? Icons.push_pin : Icons.wifi,
              size: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      title: Text(host.displayName),
      subtitle: Row(
        children: [
          Text('${host.ip}:${host.port}'),
          if (host.trustStatus == TrustStatus.pending) ...[
            const SizedBox(width: 8),
            Icon(Icons.lock_outline,
                size: 14, color: Colors.orange.shade700),
          ],
          if (host.trustStatus == TrustStatus.trusted) ...[
            const SizedBox(width: 8),
            const Icon(Icons.verified_user, size: 14, color: Colors.green),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (host.metrics?.cpu != null)
            Text(
              '${host.metrics!.cpu!.usagePercent.toStringAsFixed(0)}%',
              style: TextStyle(
                color: _cpuColor(host.metrics!.cpu!.usagePercent),
                fontWeight: FontWeight.bold,
              ),
            ),
          if (host.versionWarning && host.hostInfo != null) ...[
            const SizedBox(width: 4),
            VersionBadge(version: host.hostInfo!.agentVersion),
          ],
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'remove') onRemove();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove'),
              ),
            ],
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  IconData get _statusIcon => switch (host.status) {
        ConnectionStatus.connected => Icons.check_circle,
        ConnectionStatus.connecting => Icons.sync,
        ConnectionStatus.disconnected => Icons.cloud_off,
        ConnectionStatus.error => Icons.error,
      };

  Color get _statusColor => switch (host.status) {
        ConnectionStatus.connected => Colors.green,
        ConnectionStatus.connecting => Colors.orange,
        ConnectionStatus.disconnected => Colors.grey,
        ConnectionStatus.error => Colors.red,
      };

  Color _cpuColor(double percent) {
    if (percent < 60) return Colors.green;
    if (percent < 80) return Colors.orange;
    return Colors.red;
  }
}
