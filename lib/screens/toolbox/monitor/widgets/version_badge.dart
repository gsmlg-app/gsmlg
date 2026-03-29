import 'package:flutter/material.dart';

class VersionBadge extends StatelessWidget {
  const VersionBadge({super.key, required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Agent v$version — update available',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, size: 12, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              'v$version',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
