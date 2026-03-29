import 'package:flutter/material.dart';

class CertMismatchDialog extends StatelessWidget {
  const CertMismatchDialog({
    super.key,
    required this.hostname,
    required this.previousFingerprint,
    required this.currentFingerprint,
  });

  final String hostname;
  final String previousFingerprint;
  final String currentFingerprint;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
        size: 48,
      ),
      title: const Text('Certificate changed!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "The agent's certificate has changed since you last connected. "
            'This could indicate a security issue.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _fingerprintRow(context, 'Previous', previousFingerprint),
          const SizedBox(height: 8),
          _fingerprintRow(context, 'Current', currentFingerprint),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Disconnect'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Trust Anyway'),
        ),
      ],
    );
  }

  Widget _fingerprintRow(BuildContext context, String label, String fp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            fp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
