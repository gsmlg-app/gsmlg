import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:monitor_bloc/monitor_bloc.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/sparkline_chart.dart';
import 'package:gsmlg/screens/toolbox/monitor/widgets/version_badge.dart';

class HostCard extends StatelessWidget {
  const HostCard({
    super.key,
    required this.host,
    required this.onTap,
    required this.onRemove,
    this.onConnect,
    this.onDisconnect,
    this.selected = false,
  });

  final MonitorHost host;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dmColors = theme.extension<DmColorExtension>();
    final warningColor = dmColors?.warning ?? colorScheme.secondary;
    final successColor = dmColors?.success ?? colorScheme.primary;

    final cpuUsage = host.snapshot?.cpuUsage ?? host.metrics?.cpu?.usagePercent;
    final memoryUsage =
        host.snapshot?.memory.usage ?? host.metrics?.memory?.usagePercent;
    final memUsedBytes =
        host.snapshot?.memory.usedBytes ?? host.metrics?.memory?.usedBytes;
    final memTotalBytes =
        host.snapshot?.memory.totalBytes ?? host.metrics?.memory?.totalBytes;

    final rxSpeed =
        host.snapshot?.network.receivedBytesPerSecond ??
        (host.metrics != null && host.metrics!.networks.isNotEmpty
            ? host.metrics!.networks
                .fold<double>(0.0, (acc, n) => acc + n.rxBytesPerSec)
            : null);
    final txSpeed =
        host.snapshot?.network.sentBytesPerSecond ??
        (host.metrics != null && host.metrics!.networks.isNotEmpty
            ? host.metrics!.networks
                .fold<double>(0.0, (acc, n) => acc + n.txBytesPerSec)
            : null);

    final cpuItems = host.cpuHistory.items;
    final isConnected = host.status == ConnectionStatus.connected;

    return Card(
      elevation: selected ? 3 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: OS Icon + Name/IP + Status Badge + Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOsIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                host.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (host.isManual) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.push_pin,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                            if (host.trustStatus == TrustStatus.pending) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: warningColor,
                              ),
                            ] else if (host.trustStatus == TrustStatus.trusted) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified_user,
                                size: 14,
                                color: successColor,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${host.ip}:${host.port}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (host.hostInfo != null &&
                                host.hostInfo!.os.isNotEmpty) ...[
                              Text(
                                ' • ${host.hostInfo!.os}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(context),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (action) {
                      switch (action) {
                        case 'connect':
                          onConnect?.call();
                        case 'disconnect':
                          onDisconnect?.call();
                        case 'remove':
                          onRemove();
                      }
                    },
                    itemBuilder: (context) => [
                      if (!isConnected)
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
                            Text('Remove'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Metrics or Connection State Content
              if (isConnected && (cpuUsage != null || memoryUsage != null)) ...[
                // CPU Progress & Details
                if (cpuUsage != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.memory,
                            size: 15,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CPU',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${cpuUsage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _metricColor(cpuUsage, successColor, warningColor, colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (cpuUsage / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _metricColor(cpuUsage, successColor, warningColor, colorScheme.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Memory Progress & Details
                if (memoryUsage != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 15,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Memory',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        memUsedBytes != null && memTotalBytes != null
                            ? '${_formatBytes(memUsedBytes)} / ${_formatBytes(memTotalBytes)} (${memoryUsage.toStringAsFixed(0)}%)'
                            : '${memoryUsage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (memoryUsage / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _metricColor(memoryUsage, successColor, warningColor, colorScheme.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Network & Sparkline row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (rxSpeed != null || txSpeed != null)
                      Row(
                        children: [
                          Icon(
                            Icons.network_check,
                            size: 14,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '↓ ${_formatRate(rxSpeed ?? 0)}  ↑ ${_formatRate(txSpeed ?? 0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    if (host.versionWarning && host.hostInfo != null)
                      VersionBadge(version: host.hostInfo!.agentVersion),
                  ],
                ),

                if (cpuItems.length > 2) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SparklineChart(
                      values: cpuItems,
                      maxValue: 100,
                      color: _metricColor(cpuUsage ?? 0, successColor, warningColor, colorScheme.error),
                      height: 36,
                      strokeWidth: 1.5,
                    ),
                  ),
                ],
              ] else ...[
                // Idle / Disconnected / Error status row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon,
                        size: 18,
                        color: _statusColor(dmColors, colorScheme),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (host.status == ConnectionStatus.disconnected && onConnect != null)
                        TextButton(
                          onPressed: onConnect,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Connect'),
                        )
                      else if (host.status == ConnectionStatus.error && onConnect != null)
                        TextButton(
                          onPressed: onConnect,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Retry'),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOsIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final os = (host.hostInfo?.os ?? host.snapshot?.architecture ?? '').toLowerCase();
    final name = host.displayName.toLowerCase();

    IconData iconData = Icons.dns_outlined;
    if (os.contains('mac') || os.contains('darwin') || name.contains('mac') || name.contains('apple')) {
      iconData = Icons.laptop_mac;
    } else if (os.contains('linux') || os.contains('ubuntu') || os.contains('debian') || name.contains('linux')) {
      iconData = Icons.terminal;
    } else if (os.contains('win') || name.contains('win')) {
      iconData = Icons.desktop_windows_outlined;
    } else if (os.contains('android') || name.contains('android')) {
      iconData = Icons.android;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          iconData,
          size: 24,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dmColors = theme.extension<DmColorExtension>();
    final color = _statusColor(dmColors, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String get _statusLabel => switch (host.status) {
    ConnectionStatus.connected => 'Online',
    ConnectionStatus.connecting => 'Connecting',
    ConnectionStatus.disconnected => 'Offline',
    ConnectionStatus.error => 'Error',
  };

  String get _statusMessage => switch (host.status) {
    ConnectionStatus.connected => 'Receiving live telemetry',
    ConnectionStatus.connecting => 'Connecting to monitor agent...',
    ConnectionStatus.disconnected => 'Host offline. Tap to connect.',
    ConnectionStatus.error => 'Connection error. Tap to retry.',
  };

  IconData get _statusIcon => switch (host.status) {
    ConnectionStatus.connected => Icons.check_circle_outline,
    ConnectionStatus.connecting => Icons.sync,
    ConnectionStatus.disconnected => Icons.cloud_off,
    ConnectionStatus.error => Icons.error_outline,
  };

  Color _statusColor(DmColorExtension? dmColors, ColorScheme colorScheme) =>
      switch (host.status) {
        ConnectionStatus.connected => dmColors?.success ?? colorScheme.primary,
        ConnectionStatus.connecting => dmColors?.warning ?? colorScheme.secondary,
        ConnectionStatus.disconnected => colorScheme.outline,
        ConnectionStatus.error => colorScheme.error,
      };

  Color _metricColor(double percent, Color normal, Color warning, Color critical) {
    if (percent >= 85) return critical;
    if (percent >= 65) return warning;
    return normal;
  }

  static String _formatBytes(num? bytes) {
    if (bytes == null || bytes <= 0) return '0 B';
    var amount = bytes.toDouble();
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var unit = 0;
    while (amount >= 1024 && unit < units.length - 1) {
      amount /= 1024;
      unit++;
    }
    return '${amount.toStringAsFixed(amount >= 10 ? 1 : 2)} ${units[unit]}';
  }

  static String _formatRate(double bytesPerSec) {
    return '${_formatBytes(bytesPerSec)}/s';
  }
}
