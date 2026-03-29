import 'package:flutter/material.dart';

/// Column definition for ResponsiveDataList.
class DataColumnDef<T> {
  /// The label displayed in the table header.
  final String label;

  /// Function to extract the cell value from an item.
  final String Function(T item) getValue;

  /// Optional widget builder for custom cell rendering.
  final Widget Function(T item)? buildCell;

  /// Whether this column should be shown in the list view (small screens).
  /// Defaults to true.
  final bool showInList;

  /// Whether this column is the primary field (shown prominently in list view).
  final bool isPrimary;

  /// Whether this column is searchable/filterable.
  /// Defaults to true.
  final bool filterable;

  /// Maximum width for this column. If content exceeds, it will be truncated
  /// with an expand option.
  final double? maxWidth;

  /// Flex value for table column width distribution.
  final int flex;

  const DataColumnDef({
    required this.label,
    required this.getValue,
    this.buildCell,
    this.showInList = true,
    this.isPrimary = false,
    this.filterable = true,
    this.maxWidth,
    this.flex = 1,
  });
}

/// A responsive widget that displays data as a list on small screens
/// and as a DataTable on larger screens.
class ResponsiveDataList<T> extends StatefulWidget {
  /// The list of items to display.
  final List<T> items;

  /// Column definitions that describe how to display each field.
  final List<DataColumnDef<T>> columns;

  /// Callback when an item is tapped.
  final void Function(T item)? onItemTap;

  /// Builder for action buttons shown on each row/card.
  final List<Widget> Function(T item)? actionsBuilder;

  /// The breakpoint width to switch between list and table views.
  /// Defaults to 600 pixels.
  final double breakpoint;

  /// Whether to show a header row in the table view.
  final bool showHeader;

  /// Whether to show a filter/search field.
  final bool showFilter;

  /// Placeholder text for the filter field.
  final String filterHint;

  /// Custom builder for the list item card.
  /// If provided, overrides the default list item rendering.
  final Widget Function(BuildContext context, T item)? listItemBuilder;

  /// Empty state widget shown when items list is empty.
  final Widget? emptyWidget;

  /// Padding around the content.
  final EdgeInsetsGeometry padding;

  const ResponsiveDataList({
    super.key,
    required this.items,
    required this.columns,
    this.onItemTap,
    this.actionsBuilder,
    this.breakpoint = 600,
    this.showHeader = true,
    this.showFilter = false,
    this.filterHint = 'Search...',
    this.listItemBuilder,
    this.emptyWidget,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<ResponsiveDataList<T>> createState() => _ResponsiveDataListState<T>();
}

class _ResponsiveDataListState<T> extends State<ResponsiveDataList<T>> {
  final _filterController = TextEditingController();
  final _horizontalScrollController = ScrollController();
  String _filterText = '';

  @override
  void dispose() {
    _filterController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    if (_filterText.isEmpty) return widget.items;

    final searchLower = _filterText.toLowerCase();
    return widget.items.where((item) {
      for (final col in widget.columns) {
        if (col.filterable) {
          final value = col.getValue(item).toLowerCase();
          if (value.contains(searchLower)) return true;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    if (widget.items.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= widget.breakpoint;

        return Column(
          children: [
            if (widget.showFilter) _buildFilterField(context),
            Expanded(
              child: isLargeScreen
                  ? _buildDataTable(context, filteredItems)
                  : _buildListView(context, filteredItems),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterField(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: TextField(
        controller: _filterController,
        decoration: InputDecoration(
          hintText: widget.filterHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _filterText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _filterController.clear();
                    setState(() => _filterText = '');
                  },
                )
              : null,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (value) => setState(() => _filterText = value),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, List<T> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: widget.padding,
      child: Scrollbar(
        controller: _horizontalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            columns: [
              ...widget.columns.map((col) => DataColumn(
                    label: Text(
                      col.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
              const DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: items.map((item) {
              return DataRow(
                onSelectChanged: widget.onItemTap != null
                    ? (_) => widget.onItemTap!(item)
                    : null,
                cells: [
                  ...widget.columns.map((col) => DataCell(
                        _buildCellContent(col, item, theme),
                      )),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.actionsBuilder?.call(item) ??
                          [const SizedBox.shrink()],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(DataColumnDef<T> col, T item, ThemeData theme) {
    if (col.buildCell != null) {
      final cell = col.buildCell!(item);
      if (col.maxWidth != null) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: col.maxWidth!),
          child: cell,
        );
      }
      return cell;
    }

    final value = col.getValue(item);
    if (col.maxWidth != null) {
      return _ExpandableCell(
        value: value,
        maxWidth: col.maxWidth!,
      );
    }
    return Text(value);
  }

  Widget _buildListView(BuildContext context, List<T> items) {
    return ListView.builder(
      padding: widget.padding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (widget.listItemBuilder != null) {
          return widget.listItemBuilder!(context, item);
        }

        return _buildDefaultListItem(context, item);
      },
    );
  }

  Widget _buildDefaultListItem(BuildContext context, T item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Find primary column
    final primaryColumn = widget.columns.where((c) => c.isPrimary).firstOrNull;
    // Get columns to show in list view
    final listColumns =
        widget.columns.where((c) => c.showInList && !c.isPrimary).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with primary field and actions
              Row(
                children: [
                  if (primaryColumn != null)
                    Expanded(
                      child: primaryColumn.buildCell?.call(item) ??
                          Text(
                            primaryColumn.getValue(item),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    )
                  else
                    const Spacer(),
                  if (widget.actionsBuilder != null)
                    ...widget.actionsBuilder!(item),
                ],
              ),
              if (listColumns.isNotEmpty) ...[
                const SizedBox(height: 8),
                // Other fields
                ...listColumns.map((col) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              col.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: col.buildCell?.call(item) ??
                                Text(
                                  col.getValue(item),
                                  style: theme.textTheme.bodyMedium,
                                ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A cell that can be expanded to show full content.
class _ExpandableCell extends StatefulWidget {
  final String value;
  final double maxWidth;

  const _ExpandableCell({
    required this.value,
    required this.maxWidth,
  });

  @override
  State<_ExpandableCell> createState() => _ExpandableCellState();
}

class _ExpandableCellState extends State<_ExpandableCell> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_expanded) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              widget.value,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () => setState(() => _expanded = false),
              child: Text(
                'Show less',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (widget.value.length > 30)
            InkWell(
              onTap: () => setState(() => _expanded = true),
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A sliver version of ResponsiveDataList for use in CustomScrollView.
/// Since slivers cannot manage their own filter state easily,
/// this widget accepts an external filter value.
class SliverResponsiveDataList<T> extends StatefulWidget {
  /// The list of items to display.
  final List<T> items;

  /// Column definitions that describe how to display each field.
  final List<DataColumnDef<T>> columns;

  /// Callback when an item is tapped.
  final void Function(T item)? onItemTap;

  /// Builder for action buttons shown on each row/card.
  final List<Widget> Function(T item)? actionsBuilder;

  /// The breakpoint width to switch between list and table views.
  final double breakpoint;

  /// Custom builder for the list item card.
  final Widget Function(BuildContext context, T item)? listItemBuilder;

  /// Padding around the content.
  final EdgeInsetsGeometry padding;

  /// External filter text for filtering items.
  final String? filterText;

  const SliverResponsiveDataList({
    super.key,
    required this.items,
    required this.columns,
    this.onItemTap,
    this.actionsBuilder,
    this.breakpoint = 600,
    this.listItemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.filterText,
  });

  @override
  State<SliverResponsiveDataList<T>> createState() =>
      _SliverResponsiveDataListState<T>();
}

class _SliverResponsiveDataListState<T>
    extends State<SliverResponsiveDataList<T>> {
  final _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    if (widget.filterText == null || widget.filterText!.isEmpty) {
      return widget.items;
    }

    final searchLower = widget.filterText!.toLowerCase();
    return widget.items.where((item) {
      for (final col in widget.columns) {
        if (col.filterable) {
          final value = col.getValue(item).toLowerCase();
          if (value.contains(searchLower)) return true;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.crossAxisExtent >= widget.breakpoint;

        if (isLargeScreen) {
          return _buildSliverDataTable(context, filteredItems);
        } else {
          return _buildSliverList(context, filteredItems);
        }
      },
    );
  }

  Widget _buildSliverDataTable(BuildContext context, List<T> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: widget.padding,
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              columns: [
                ...widget.columns.map((col) => DataColumn(
                      label: Text(
                        col.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
                const DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: items.map((item) {
                return DataRow(
                  onSelectChanged: widget.onItemTap != null
                      ? (_) => widget.onItemTap!(item)
                      : null,
                  cells: [
                    ...widget.columns.map((col) => DataCell(
                          _buildCellContent(col, item, theme),
                        )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.actionsBuilder?.call(item) ??
                            [const SizedBox.shrink()],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(DataColumnDef<T> col, T item, ThemeData theme) {
    if (col.buildCell != null) {
      final cell = col.buildCell!(item);
      if (col.maxWidth != null) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: col.maxWidth!),
          child: cell,
        );
      }
      return cell;
    }

    final value = col.getValue(item);
    if (col.maxWidth != null) {
      return _ExpandableCell(
        value: value,
        maxWidth: col.maxWidth!,
      );
    }
    return Text(value);
  }

  Widget _buildSliverList(BuildContext context, List<T> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverPadding(
      padding: widget.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];

            if (widget.listItemBuilder != null) {
              return widget.listItemBuilder!(context, item);
            }

            return _buildDefaultListItem(context, item, theme, colorScheme);
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildDefaultListItem(
    BuildContext context,
    T item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Find primary column
    final primaryColumn = widget.columns.where((c) => c.isPrimary).firstOrNull;
    // Get columns to show in list view
    final listColumns =
        widget.columns.where((c) => c.showInList && !c.isPrimary).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with primary field and actions
              Row(
                children: [
                  if (primaryColumn != null)
                    Expanded(
                      child: primaryColumn.buildCell?.call(item) ??
                          Text(
                            primaryColumn.getValue(item),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    )
                  else
                    const Spacer(),
                  if (widget.actionsBuilder != null)
                    ...widget.actionsBuilder!(item),
                ],
              ),
              if (listColumns.isNotEmpty) ...[
                const SizedBox(height: 8),
                // Other fields
                ...listColumns.map((col) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              col.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: col.buildCell?.call(item) ??
                                Text(
                                  col.getValue(item),
                                  style: theme.textTheme.bodyMedium,
                                ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A filter field widget to be used with SliverResponsiveDataList.
/// Place this in a SliverToBoxAdapter above the SliverResponsiveDataList.
class DataListFilterField extends StatelessWidget {
  /// Controller for the filter text field.
  final TextEditingController controller;

  /// Callback when the filter text changes.
  final ValueChanged<String> onChanged;

  /// Placeholder text.
  final String hintText;

  /// Padding around the filter field.
  final EdgeInsetsGeometry padding;

  const DataListFilterField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
