import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrustDialog extends StatelessWidget {
  const TrustDialog({
    super.key,
    required this.hostname,
    required this.fingerprint,
  });

  final String hostname;
  final String fingerprint;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Trust this agent?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Host: $hostname'),
          const SizedBox(height: 12),
          const Text('Fingerprint:'),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    fingerprint,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fingerprint));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fingerprint copied')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Verify this matches the agent's terminal output.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Trust'),
        ),
      ],
    );
  }
}
