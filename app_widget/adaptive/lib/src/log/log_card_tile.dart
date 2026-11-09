import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter/material.dart';

/// Mobile card tile for displaying a single [LogRecordItem].
class LogCardTile extends StatelessWidget {
  final LogRecordItem item;
  final VoidCallback onTap;
  final bool showTypeBadge;

  const LogCardTile({
    super.key,
    required this.item,
    required this.onTap,
    this.showTypeBadge = false,
  });

  Color _levelColor(LogLevel level, ColorScheme colors) {
    return switch (level) {
      LogLevel.error => colors.error,
      LogLevel.warning => Colors.orange,
      LogLevel.info => colors.primary,
      LogLevel.debug => colors.outline,
    };
  }

  String _formatTime(DateTime time) {
    final t = time.toLocal();
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final levelColor = _levelColor(item.level, colors);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type, Level, Time, Latency
            Row(
              children: [
                // Level dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: levelColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),

                // Type badge (optional)
                if (showTypeBadge) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.logType.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Formatted Time
                Text(
                  _formatTime(item.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),

                const Spacer(),

                // Status chip
                if (item.status != null && item.status!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Latency chip
                if (item.latencyMs != null)
                  Text(
                    '${item.latencyMs}ms',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Middle: Message
            Text(
              item.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Bottom row: Client/Source address if present
            if (item.clientAddress != null &&
                item.clientAddress!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.devices,
                    size: 13,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.clientAddress!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
