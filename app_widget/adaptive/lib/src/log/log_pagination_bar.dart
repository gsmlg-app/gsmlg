import 'package:flutter/material.dart';

/// Bottom pagination bar with first, previous, next, and last page navigation.
class LogPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final ValueChanged<int> onPageChanged;

  const LogPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final displayPage = totalPages == 0 ? 0 : currentPage + 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total count label
          Text(
            '$totalCount records',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          // Pagination controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page, size: 20),
                tooltip: 'First page',
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                tooltip: 'Previous page',
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Page $displayPage of $totalPages',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                tooltip: 'Next page',
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, size: 20),
                tooltip: 'Last page',
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(totalPages - 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
