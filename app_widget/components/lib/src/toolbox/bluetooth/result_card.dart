import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// A modern, compact card widget displaying Bluetooth scan result details.
class BluetoothResultCard extends StatefulWidget {
  const BluetoothResultCard({
    super.key,
    required this.result,
    this.onTapConnect,
  });

  /// The Bluetooth scan result to display.
  final ScanResult result;

  /// Callback when the connect button is tapped.
  final VoidCallback? onTapConnect;

  @override
  State<BluetoothResultCard> createState() => _BluetoothResultCardState();
}

class _BluetoothResultCardState extends State<BluetoothResultCard> {
  bool _expanded = false;

  String get _displayName {
    final advName = widget.result.advertisementData.advName.trim();
    if (advName.isNotEmpty) return advName;
    final platName = widget.result.device.platformName.trim();
    if (platName.isNotEmpty) return platName;
    return '';
  }

  static Color _getRssiColor(int rssi) {
    if (rssi >= -65) return Colors.green;
    if (rssi >= -80) return Colors.orange;
    return Colors.grey;
  }

  static String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String _vendorName(int id) {
    switch (id) {
      case 76:
        return 'Apple (0x004C)';
      case 6:
        return 'Microsoft (0x0006)';
      case 117:
        return 'Samsung (0x0075)';
      case 224:
        return 'Google (0x00E0)';
      case 89:
        return 'Nordic Semi (0x0059)';
      case 13:
        return 'Texas Instruments (0x000D)';
      case 10:
        return 'Qualcomm (0x000A)';
      case 899:
        return 'Xiaomi (0x0383)';
      case 343:
        return 'Huawei (0x0157)';
      default:
        return 'Vendor 0x${id.toRadixString(16).padLeft(4, '0').toUpperCase()}';
    }
  }

  static String _formatHex(List<int> bytes) {
    if (bytes.length > 12) {
      final head = bytes
          .take(8)
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(' ');
      return '[$head ... (${bytes.length} B)]';
    }
    return '[${bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ')}]';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final result = widget.result;
    final displayName = _displayName;
    final isNamed = displayName.isNotEmpty;
    final rssiColor = _getRssiColor(result.rssi);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isNamed
              ? colorScheme.outlineVariant.withValues(alpha: 0.7)
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Icon + Device Name + RSSI badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isNamed
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    foregroundColor: isNamed
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    child: Icon(
                      isNamed ? Icons.bluetooth : Icons.bluetooth_searching,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isNamed ? displayName : 'Unnamed Device',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isNamed ? FontWeight.bold : FontWeight.normal,
                            fontStyle:
                                isNamed ? FontStyle.normal : FontStyle.italic,
                            color:
                                isNamed ? null : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.device.remoteId.str,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: rssiColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rssiColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 14,
                          color: rssiColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${result.rssi} dBm',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: rssiColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Tags Row
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _BadgeChip(
                    label: result.advertisementData.connectable
                        ? 'Connectable'
                        : 'Broadcast Only',
                    color: result.advertisementData.connectable
                        ? Colors.green
                        : colorScheme.outline,
                  ),
                  if (result.advertisementData.txPowerLevel != null)
                    _BadgeChip(
                      label: 'Tx ${result.advertisementData.txPowerLevel} dBm',
                      color: colorScheme.outline,
                    ),
                  _BadgeChip(
                    label: _formatTimestamp(result.timeStamp),
                    color: colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    icon: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                    ),
                    label: Text(
                      _expanded ? 'Hide Details' : 'Details',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  if (result.advertisementData.connectable)
                    FilledButton.tonalIcon(
                      onPressed: widget.onTapConnect,
                      icon: const Icon(Icons.link, size: 16),
                      label: const Text(
                        'Connect',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                ],
              ),
              if (_expanded) ...[
                const Divider(height: 16),
                if (result.advertisementData.advName.isNotEmpty &&
                    result.device.platformName.isNotEmpty &&
                    result.advertisementData.advName !=
                        result.device.platformName) ...[
                  Text(
                    'Platform Name: ${result.device.platformName}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Adv Name: ${result.advertisementData.advName}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                ],
                if (result.advertisementData.manufacturerData.isNotEmpty) ...[
                  Text(
                    'Manufacturer Data:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (final entry
                      in result.advertisementData.manufacturerData.entries)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text(
                        '${_vendorName(entry.key)}: ${_formatHex(entry.value)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                ],
                if (result.advertisementData.serviceUuids.isNotEmpty) ...[
                  Text(
                    'Service UUIDs (${result.advertisementData.serviceUuids.length}):',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (final uuid in result.advertisementData.serviceUuids)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text(
                        uuid.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                ],
                if (result.advertisementData.serviceData.isNotEmpty) ...[
                  Text(
                    'Service Data:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (final entry
                      in result.advertisementData.serviceData.entries)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text(
                        '${entry.key}: ${_formatHex(entry.value)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: effectiveColor,
        ),
      ),
    );
  }
}
