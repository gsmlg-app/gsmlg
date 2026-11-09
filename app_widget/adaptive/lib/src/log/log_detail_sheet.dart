import 'dart:convert';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal bottom sheet or dialog to inspect full details of a [LogRecordItem].
class LogDetailSheet extends StatelessWidget {
  final LogRecordItem item;

  const LogDetailSheet({super.key, required this.item});

  /// Displays the detail sheet as a modal bottom sheet on mobile, or dialog on large screens.
  static Future<void> show(BuildContext context, LogRecordItem item) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (isWide) {
      return showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680, maxHeight: 600),
            child: LogDetailSheet(item: item),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.85,
          child: LogDetailSheet(item: item),
        ),
      );
    }
  }

  Color _levelColor(LogLevel level, ColorScheme colors) {
    return switch (level) {
      LogLevel.error => colors.error,
      LogLevel.warning => Colors.orange,
      LogLevel.info => colors.primary,
      LogLevel.debug => colors.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final levelColor = _levelColor(item.level, colors);

    final rawJson = const JsonEncoder.withIndent('  ').convert(item.rawFields);
    final errorText = item.rawFields['error']?.toString();
    final stackTrace = item.rawFields['stack_trace']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sheet Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: levelColor, width: 1),
                ),
                child: Text(
                  item.level.displayName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.logType.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.timestamp.toLocal().toString().split('.').first,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Body content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Message card
              Card(
                elevation: 0,
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    item.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Key attributes table
              _buildAttributeRow(
                context,
                'Status',
                item.status ?? 'N/A',
                isStatus: true,
              ),
              if (item.clientAddress != null)
                _buildAttributeRow(
                    context, 'Client/Source', item.clientAddress!),
              if (item.latencyMs != null)
                _buildAttributeRow(context, 'Latency', '${item.latencyMs} ms'),
              if (item.loggerName != null)
                _buildAttributeRow(context, 'Logger', item.loggerName!),
              _buildAttributeRow(context, 'Log ID', item.id),

              // Error and Stack trace section (if any)
              if (errorText != null && errorText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: colors.error.withValues(alpha: 0.5)),
                  ),
                  child: SelectableText(
                    errorText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: colors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              if (stackTrace != null && stackTrace.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stack Trace',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text('Copy'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: stackTrace));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stack trace copied')),
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    stackTrace,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Raw JSON section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Raw JSON Fields',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Copy JSON'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: rawJson));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('JSON copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: SelectableText(
                  rawJson,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeRow(
    BuildContext context,
    String label,
    String value, {
    bool isStatus = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
