import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter/material.dart';

import 'log_card_tile.dart';
import 'log_detail_sheet.dart';
import 'log_filter_bar.dart';
import 'log_pagination_bar.dart';

/// Loads one page of rows plus the total row count for [filter].
typedef LogPageQuery = Future<({int total, List<LogRecordItem> items})>
    Function(LogFilter filter, int limit, int offset);

/// Adaptive log viewer querying DuckDB with dynamic filters, pagination,
/// and responsive mobile Card / desktop DataTable rendering.
class DuckDbLogViewer extends StatefulWidget {
  final String tableOrView;
  final LogLevel? defaultFilterLevel;
  final bool? showTypeColumn;
  final LogStore logStore;
  final List<Widget>? actions;

  /// Shows the API category dropdown (values from `listCategories`).
  final bool showCategoryFilter;

  /// Shows the errors-only toggle.
  final bool showErrorsOnlyFilter;

  /// Shows the HTTP method dropdown.
  final bool showMethodFilter;

  /// Replaces the default `countLogs` / `queryLogs` page loading, e.g. to
  /// page over aggregated rows such as agent runs.
  final LogPageQuery? pageQuery;

  /// Replaces the default table / card list rendering of the current page.
  final Widget Function(BuildContext context, List<LogRecordItem> items)?
      itemsBuilder;

  const DuckDbLogViewer({
    super.key,
    required this.tableOrView,
    this.defaultFilterLevel,
    this.showTypeColumn,
    required this.logStore,
    this.actions,
    this.showCategoryFilter = false,
    this.showErrorsOnlyFilter = false,
    this.showMethodFilter = false,
    this.pageQuery,
    this.itemsBuilder,
  });

  @override
  State<DuckDbLogViewer> createState() => DuckDbLogViewerState();
}

class DuckDbLogViewerState extends State<DuckDbLogViewer> {
  static const int _pageSize = 50;

  String? _keyword;
  DateTimeRange? _timeRange;
  LogLevel? _level;
  String? _category;
  bool _errorsOnly = false;
  String? _method;
  List<String> _categories = const [];
  int _currentPage = 0;

  int _totalCount = 0;
  List<LogRecordItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _level = widget.defaultFilterLevel;
    _fetchData();
    if (widget.showCategoryFilter) _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.logStore.listCategories();
      if (mounted) setState(() => _categories = categories);
    } catch (e) {
      debugPrint('DuckDbLogViewer category load error: $e');
    }
  }

  /// The filter currently applied, e.g. for exporting the same rows.
  LogFilter get filter => LogFilter(
        keyword: _keyword,
        timeRange: _timeRange,
        level: _level?.displayName,
        category: _category,
        errorsOnly: _errorsOnly ? true : null,
        method: _method,
      );

  bool get _hasFilters =>
      _keyword != null ||
      _timeRange != null ||
      _level != null ||
      _category != null ||
      _method != null ||
      _errorsOnly;

  @override
  void didUpdateWidget(DuckDbLogViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tableOrView != widget.tableOrView) {
      _currentPage = 0;
      _fetchData();
    }
  }

  /// Refreshes the log data from DuckDB.
  Future<void> refresh() {
    if (widget.showCategoryFilter) _loadCategories();
    return _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final filter = this.filter;
      final offset = _currentPage * _pageSize;
      final page = widget.pageQuery != null
          ? await widget.pageQuery!(filter, _pageSize, offset)
          : (
              total: await widget.logStore.countLogs(
                tableOrView: widget.tableOrView,
                filter: filter,
              ),
              items: await widget.logStore.queryLogs(
                tableOrView: widget.tableOrView,
                filter: filter,
                limit: _pageSize,
                offset: offset,
              ),
            );
      final total = page.total;
      final logs = page.items;

      if (mounted) {
        setState(() {
          _totalCount = total;
          _items = logs;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('DuckDbLogViewer fetch error: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onKeywordChanged(String? kw) {
    setState(() {
      _keyword = kw;
      _currentPage = 0;
    });
    _fetchData();
  }

  void _onTimeRangeChanged(DateTimeRange? range) {
    setState(() {
      _timeRange = range;
      _currentPage = 0;
    });
    _fetchData();
  }

  void _onLevelChanged(LogLevel? lvl) {
    setState(() {
      _level = lvl;
      _currentPage = 0;
    });
    _fetchData();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _category = category;
      _currentPage = 0;
    });
    _fetchData();
  }

  void _onMethodChanged(String? method) {
    setState(() {
      _method = method;
      _currentPage = 0;
    });
    _fetchData();
  }

  void _onErrorsOnlyChanged(bool errorsOnly) {
    setState(() {
      _errorsOnly = errorsOnly;
      _currentPage = 0;
    });
    _fetchData();
  }

  void _onClearFilters() {
    setState(() {
      _keyword = null;
      _timeRange = null;
      _level = null;
      _category = null;
      _method = null;
      _errorsOnly = false;
      _currentPage = 0;
    });
    _fetchData();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
    _fetchData();
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
    final isWide = MediaQuery.of(context).size.width >= 720;
    final showType =
        widget.showTypeColumn ?? (widget.tableOrView == 'v_all_logs');
    final totalPages = (_totalCount / _pageSize).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top filter bar
        LogFilterBar(
          initialKeyword: _keyword,
          initialTimeRange: _timeRange,
          initialLevel: _level,
          onKeywordChanged: _onKeywordChanged,
          onTimeRangeChanged: _onTimeRangeChanged,
          onLevelChanged: _onLevelChanged,
          onClearFilters: _onClearFilters,
          categories: _categories,
          initialCategory: _category,
          onCategoryChanged:
              widget.showCategoryFilter ? _onCategoryChanged : null,
          initialMethod: _method,
          onMethodChanged: widget.showMethodFilter ? _onMethodChanged : null,
          initialErrorsOnly: _errorsOnly,
          onErrorsOnlyChanged:
              widget.showErrorsOnlyFilter ? _onErrorsOnlyChanged : null,
        ),

        // Main content area
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: colors.error),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to query logs: $_errorMessage',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _fetchData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 48,
                                color: colors.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _hasFilters
                                    ? 'No logs match filters'
                                    : 'No historical logs found',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              if (_hasFilters) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _onClearFilters,
                                  icon: const Icon(Icons.filter_alt_off),
                                  label: const Text('Clear Filters'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : widget.itemsBuilder != null
                          ? widget.itemsBuilder!(context, _items)
                          : isWide
                              ? _buildDesktopDataTable(context, showType)
                              : _buildMobileListView(context, showType),
        ),

        // Bottom pagination bar
        LogPaginationBar(
          currentPage: _currentPage,
          totalPages: totalPages,
          totalCount: _totalCount,
          onPageChanged: _onPageChanged,
        ),
      ],
    );
  }

  Widget _buildMobileListView(BuildContext context, bool showType) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return LogCardTile(
            item: item,
            showTypeBadge: showType,
            onTap: () =>
                LogDetailSheet.open(context, item, logStore: widget.logStore),
          );
        },
      ),
    );
  }

  Widget _buildDesktopDataTable(BuildContext context, bool showType) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          headingRowHeight: 40,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 52,
          horizontalMargin: 16,
          columnSpacing: 18,
          columns: [
            const DataColumn(label: Text('TIME')),
            if (showType) const DataColumn(label: Text('TYPE')),
            const DataColumn(label: Text('LEVEL')),
            const DataColumn(label: Text('CLIENT / SOURCE')),
            const DataColumn(label: Text('MESSAGE / SUMMARY')),
            const DataColumn(label: Text('STATUS')),
            const DataColumn(label: Text('LATENCY')),
          ],
          rows: _items.map((item) {
            final levelColor = _levelColor(item.level, colors);
            final timeStr = item.timestamp
                .toLocal()
                .toString()
                .split(' ')
                .last
                .split('.')
                .first;

            return DataRow(
              onSelectChanged: (_) =>
                  LogDetailSheet.open(context, item, logStore: widget.logStore),
              cells: [
                DataCell(
                  Text(timeStr,
                      style: const TextStyle(fontFamily: 'monospace')),
                ),
                if (showType)
                  DataCell(
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
                  ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: levelColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(item.level.displayName,
                          style: TextStyle(
                            color: levelColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
                DataCell(
                  Text(item.clientAddress ?? '-',
                      style: const TextStyle(fontFamily: 'monospace')),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      item.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(item.status ?? '-'),
                ),
                DataCell(
                  Text(
                    item.latencyMs != null ? '${item.latencyMs}ms' : '-',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
