import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';

import 'zmodem_transfer_controller.dart';

/// Compact panel shown at the bottom of a terminal while `sz`/`rz` runs.
class ZmodemProgressPanel extends StatelessWidget {
  const ZmodemProgressPanel({
    super.key = const ValueKey('zmodem-progress-panel'),
    required this.progress,
    required this.onCancel,
  });

  final ZmodemProgress progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = progress.totalBytes;
    final fraction = total == null || total == 0
        ? null
        : (progress.bytesDone / total).clamp(0.0, 1.0);
    final count = progress.fileCount;
    final sizeText = total == null
        ? _formatBytes(progress.bytesDone)
        : '${_formatBytes(progress.bytesDone)} / ${_formatBytes(total)}';

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(10),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: [
            Icon(
              progress.direction == ZmodemDirection.download
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: fraction),
                  const SizedBox(height: 4),
                  Text(
                    count != null && count > 1
                        ? '$sizeText · '
                            '${context.l10n.zmodemFileOf(progress.fileIndex, count)}'
                        : sizeText,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              key: const ValueKey('zmodem-cancel'),
              onPressed: onCancel,
              child: Text(context.l10n.zmodemCancel),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return unit == 0
      ? '$bytes ${units[0]}'
      : '${value.toStringAsFixed(1)} ${units[unit]}';
}
