import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../grid_tile.dart';

/// A card widget displaying Bluetooth scan result details.
class BluetoothResultCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: kDefaultGridGap,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultGridGap),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                richMessage: const TextSpan(
                  text:
                      'Bluetooth RSSI (Received Signal Strength Indicator)\n',
                  children: [
                    TextSpan(
                      text:
                          "It is the strength of the beacon's signal as seen on the receiving device, e.g. a smartphone.\n",
                    ),
                    TextSpan(
                      text:
                          'The signal strength depends on distance and Broadcasting Power value.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'At maximum Broadcasting Power (+4 dBm) the RSSI ranges from -26 (a few inches) to -100 (40-50 m distance).',
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'RSSI:  ',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: result.rssi.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.618),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      result.timeStamp.toIso8601String(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 1 - 0.618),
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Text(
                'Advertisement Data: ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('  Connectable: ${result.advertisementData.connectable}'),
              Text(
                '  Tx Power Level: ${result.advertisementData.txPowerLevel ?? 'N/A'}',
              ),
              Text(
                '  Local Name: ${result.advertisementData.advName.isEmpty ? 'N/A' : result.advertisementData.advName}',
              ),
              if (result.advertisementData.manufacturerData.keys.isNotEmpty)
                const Text('  Manufacturer Data:'),
              ...result.advertisementData.manufacturerData.keys.map<Widget>(
                (k) => Text(
                  '    $k: ${result.advertisementData.manufacturerData[k]}',
                ),
              ),
              if (result.advertisementData.serviceData.keys.isNotEmpty)
                const Text('  Service Data:'),
              ...result.advertisementData.serviceData.keys.map<Widget>(
                (k) => Text(
                  '    $k: ${result.advertisementData.serviceData[k]}',
                ),
              ),
              if (result.advertisementData.serviceUuids.isNotEmpty)
                const Text('  Service UUIDs:'),
              ...result.advertisementData.serviceUuids.map<Widget>(
                (uuid) => Text('    - $uuid'),
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    'Device:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (result.advertisementData.connectable) ...[
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: onTapConnect,
                      icon: const Icon(Icons.device_hub),
                      label: const Text('Connect'),
                    ),
                  ],
                ],
              ),
              Text('  Remote ID:\n  ${result.device.remoteId}'),
              Text('  Platform Name:\n  ${result.device.platformName}'),
            ],
          ),
        ),
      ),
    );
  }
}
