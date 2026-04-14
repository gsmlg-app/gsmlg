import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';

class VersionBadge extends StatelessWidget {
  const VersionBadge({super.key, required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final warningColor =
        Theme.of(context).extension<DmColorExtension>()!.warning;
    return Tooltip(
      message: 'Agent v$version — update available',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: warningColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: warningColor, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, size: 12, color: warningColor),
            const SizedBox(width: 4),
            Text(
              'v$version',
              style: TextStyle(
                fontSize: 10,
                color: warningColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
