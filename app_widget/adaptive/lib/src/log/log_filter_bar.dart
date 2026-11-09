import 'dart:async';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';

/// Filter bar with search text field, date range selector, and level dropdown.
///
/// The category dropdown and errors-only toggle are shown only when their
/// callbacks ([onCategoryChanged], [onErrorsOnlyChanged]) are provided.
class LogFilterBar extends StatefulWidget {
  final String? initialKeyword;
  final DateTimeRange? initialTimeRange;
  final LogLevel? initialLevel;
  final ValueChanged<String?> onKeywordChanged;
  final ValueChanged<DateTimeRange?> onTimeRangeChanged;
  final ValueChanged<LogLevel?> onLevelChanged;
  final VoidCallback onClearFilters;
  final List<String> categories;
  final String? initialCategory;
  final ValueChanged<String?>? onCategoryChanged;
  final bool initialErrorsOnly;
  final ValueChanged<bool>? onErrorsOnlyChanged;

  const LogFilterBar({
    super.key,
    this.initialKeyword,
    this.initialTimeRange,
    this.initialLevel,
    required this.onKeywordChanged,
    required this.onTimeRangeChanged,
    required this.onLevelChanged,
    required this.onClearFilters,
    this.categories = const [],
    this.initialCategory,
    this.onCategoryChanged,
    this.initialErrorsOnly = false,
    this.onErrorsOnlyChanged,
  });

  @override
  State<LogFilterBar> createState() => _LogFilterBarState();
}

class _LogFilterBarState extends State<LogFilterBar> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialKeyword ?? '');
  }

  @override
  void didUpdateWidget(LogFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialKeyword != _searchController.text &&
        widget.initialKeyword != null) {
      _searchController.text = widget.initialKeyword!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onKeywordChanged(text.trim().isEmpty ? null : text.trim());
    });
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'All Time';
    final s = range.start.toLocal();
    final e = range.end.toLocal();
    return '${s.month}/${s.day} - ${e.month}/${e.day}';
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: widget.initialTimeRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
    );
    if (picked != null) {
      widget.onTimeRangeChanged(picked);
    }
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      widget.initialTimeRange != null ||
      widget.initialLevel != null ||
      widget.initialCategory != null ||
      widget.initialErrorsOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        children: [
          // Row 1: Search TextField
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search logs (message, domain, client IP/MAC)...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        widget.onKeywordChanged(null);
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Row 2: Filters (Time Range, Level, Category, Errors, Clear)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Time Range Popup Menu
              PopupMenuButton<String>(
                tooltip: 'Select Time Range',
                onSelected: (value) {
                  final now = DateTime.now();
                  switch (value) {
                    case 'all':
                      widget.onTimeRangeChanged(null);
                    case 'today':
                      final start = DateTime(now.year, now.month, now.day);
                      widget.onTimeRangeChanged(
                        DateTimeRange(start: start, end: now),
                      );
                    case '24h':
                      widget.onTimeRangeChanged(
                        DateTimeRange(
                          start: now.subtract(const Duration(hours: 24)),
                          end: now,
                        ),
                      );
                    case '7d':
                      widget.onTimeRangeChanged(
                        DateTimeRange(
                          start: now.subtract(const Duration(days: 7)),
                          end: now,
                        ),
                      );
                    case 'custom':
                      _selectCustomDateRange();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('All Time')),
                  const PopupMenuItem(value: 'today', child: Text('Today')),
                  const PopupMenuItem(
                    value: '24h',
                    child: Text('Past 24 Hours'),
                  ),
                  const PopupMenuItem(value: '7d', child: Text('Past 7 Days')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'custom',
                    child: Text('Custom Date Range...'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.date_range, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateRange(widget.initialTimeRange),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
              ),

              // Level Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<LogLevel?>(
                    value: widget.initialLevel,
                    isDense: true,
                    hint: Text('Level: ALL', style: theme.textTheme.bodySmall),
                    items: [
                      const DropdownMenuItem<LogLevel?>(
                        value: null,
                        child: Text('Level: ALL'),
                      ),
                      ...LogLevel.values.map(
                        (lvl) => DropdownMenuItem<LogLevel?>(
                          value: lvl,
                          child: Text(lvl.displayName),
                        ),
                      ),
                    ],
                    onChanged: widget.onLevelChanged,
                  ),
                ),
              ),

              if (widget.onCategoryChanged != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: widget.categories.contains(widget.initialCategory)
                          ? widget.initialCategory
                          : null,
                      isDense: true,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(context.l10n.logFilterCategoryAll),
                        ),
                        for (final c in widget.categories)
                          DropdownMenuItem<String?>(value: c, child: Text(c)),
                      ],
                      onChanged: widget.onCategoryChanged,
                    ),
                  ),
                ),

              if (widget.onErrorsOnlyChanged != null)
                FilterChip(
                  label: Text(context.l10n.logFilterErrorsOnly),
                  selected: widget.initialErrorsOnly,
                  onSelected: widget.onErrorsOnlyChanged,
                  visualDensity: VisualDensity.compact,
                ),

              // Clear filter button
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    widget.onClearFilters();
                    setState(() {});
                  },
                  icon: const Icon(Icons.filter_alt_off, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
