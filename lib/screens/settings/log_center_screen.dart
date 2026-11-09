import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_locale/gen_l10n/app_localizations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';

/// Settings screen for browsing, filtering, exporting and pruning logs
/// persisted in the local DuckDB log store.
class LogCenterScreen extends StatefulWidget {
  static const name = 'Log Center';
  static const path = 'log-center';

  const LogCenterScreen({super.key, this.duckDb});

  /// Log store override for tests; defaults to [AppDuckDb.instance].
  final AppDuckDb? duckDb;

  @override
  State<LogCenterScreen> createState() => _LogCenterScreenState();
}

/// One Log Center tab. [table] is a `LogTables.all` entry or `v_all_logs`.
class _LogTab {
  const _LogTab({
    required this.table,
    required this.icon,
    required this.label,
    this.apiFilters = false,
    this.groupByRun = false,
  });

  final String table;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;

  /// Category and method filters (API tab).
  final bool apiFilters;
  final bool groupByRun;
}

class _LogCenterScreenState extends State<LogCenterScreen>
    with SingleTickerProviderStateMixin {
  static final _tabs = [
    _LogTab(
      table: 'v_all_logs',
      icon: Icons.all_inbox,
      label: (l10n) => l10n.logCenterAllLogs,
    ),
    _LogTab(
      table: 'system_logs',
      icon: Icons.memory,
      label: (l10n) => l10n.logCenterSystemLogs,
    ),
    _LogTab(
      table: 'api_exchanges',
      icon: Icons.http,
      label: (l10n) => l10n.logCenterApiLogs,
      apiFilters: true,
    ),
    _LogTab(
      table: 'agent_events',
      icon: Icons.smart_toy_outlined,
      label: (l10n) => l10n.logCenterAgentLogs,
      groupByRun: true,
    ),
    _LogTab(
      table: 'usage_events',
      icon: Icons.insights,
      label: (l10n) => l10n.logCenterUsageLogs,
    ),
  ];

  /// Tables pruned from the All tab: the ones `v_all_logs` shows.
  static const _allTabTables = ['system_logs', 'api_exchanges', 'agent_events'];

  late final TabController _tabController;
  final _viewerKeys = [
    for (final _ in _tabs) GlobalKey<DuckDbLogViewerState>(),
  ];

  AppDuckDb get _duckDb => widget.duckDb ?? AppDuckDb.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DuckDbLogViewerState? get _activeViewer =>
      _viewerKeys[_tabController.index].currentState;

  /// The active tab's table when it is a single log table, else `null`.
  String? get _activeTable {
    final table = _tabs[_tabController.index].table;
    return LogTables.all.contains(table) ? table : null;
  }

  Future<void> _showPruneDialog() async {
    final l10n = context.l10n;
    final currentTable = _activeTable;
    final result = await showDialog<({int days, bool allTables})>(
      context: context,
      builder: (context) => _PruneDialog(showScope: currentTable != null),
    );
    if (result == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _duckDb.deleteOlderThan(
        days: result.days,
        tables: currentTable == null
            ? _allTabTables
            : result.allTables
            ? LogTables.all
            : [currentTable],
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.logCenterPruneDone)));
      await _activeViewer?.refresh();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.logCenterPruneFailed('$error'))),
      );
    }
  }

  Future<void> _export() async {
    final table = _activeTable;
    if (table == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final stamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
    try {
      final location = await getSaveLocation(
        suggestedName: 'gsmlg-$table-$stamp.jsonl',
        acceptedTypeGroups: const [
          XTypeGroup(label: 'JSON Lines', extensions: ['jsonl']),
        ],
      );
      if (location == null) return;
      final jsonl = await _duckDb.exportJsonl(
        table: table,
        filter: _activeViewer?.filter ?? const LogFilter(),
      );
      final file = File(location.path);
      await file.writeAsString(jsonl.isEmpty ? '' : '$jsonl\n');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.logCenterExportDone(file.path))),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.logCenterExportFailed('$error'))),
      );
    }
  }

  Widget _viewer(int index) {
    final tab = _tabs[index];
    return DuckDbLogViewer(
      key: _viewerKeys[index],
      tableOrView: tab.table,
      duckDb: widget.duckDb,
      showTypeColumn: tab.table == 'v_all_logs',
      showCategoryFilter: tab.apiFilters,
      showMethodFilter: tab.apiFilters,
      showErrorsOnlyFilter: tab.table != 'v_all_logs',
      pageQuery: tab.groupByRun
          ? AgentRunGroupList.pageQuery(widget.duckDb)
          : null,
      itemsBuilder: tab.groupByRun
          ? (context, items) =>
                AgentRunGroupList(items: items, duckDb: widget.duckDb)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) => AppAdaptiveScaffold(
    navigationRestoreInHeader: true,
    selectedIndex: Destinations.indexOf(
      const Key(SettingsScreen.name),
      context,
    ),
    onSelectedIndexChange: (index) =>
        Destinations.changeHandler(index, context),
    destinations: Destinations.navs(context),
    body: (context) => SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          DmNavigationHeader(
            builder: (context, header) => SliverAppBar(
              pinned: true,
              leading: header.leading,
              leadingWidth: header.leadingWidth,
              automaticallyImplyLeading: header.automaticallyImplyLeading,
              title: Text(context.l10n.logCenterTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: context.l10n.logCenterRefresh,
                  onPressed: () => _activeViewer?.refresh(),
                ),
                PopupMenuButton<void>(
                  tooltip: context.l10n.logCenterMaintenance,
                  itemBuilder: (context) => [
                    if (_activeTable != null)
                      PopupMenuItem<void>(
                        onTap: _export,
                        child: Row(
                          children: [
                            const Icon(Icons.download, size: 18),
                            const SizedBox(width: 8),
                            Text(context.l10n.logCenterExportAction),
                          ],
                        ),
                      ),
                    PopupMenuItem<void>(
                      onTap: _showPruneDialog,
                      child: Row(
                        children: [
                          const Icon(Icons.cleaning_services, size: 18),
                          const SizedBox(width: 8),
                          Text(context.l10n.logCenterPruneAction),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final tab in _tabs)
                    Tab(
                      icon: Icon(tab.icon, size: 18),
                      text: tab.label(context.l10n),
                    ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [for (var i = 0; i < _tabs.length; i++) _viewer(i)],
        ),
      ),
    ),
    smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
  );
}

/// Asks for N (>= 1) days and, when [showScope], whether to prune the
/// current tab's table or every log table.
class _PruneDialog extends StatefulWidget {
  const _PruneDialog({required this.showScope});

  final bool showScope;

  @override
  State<_PruneDialog> createState() => _PruneDialogState();
}

class _PruneDialogState extends State<_PruneDialog> {
  final _days = TextEditingController(text: '7');
  bool _allTables = false;
  String? _error;

  @override
  void dispose() {
    _days.dispose();
    super.dispose();
  }

  void _submit() {
    final days = int.tryParse(_days.text.trim());
    if (days == null || days < 1) {
      setState(() => _error = context.l10n.logCenterPruneDaysInvalid);
      return;
    }
    Navigator.of(context).pop((days: days, allTables: _allTables));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.logCenterPruneTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.logCenterPruneMessage),
          const SizedBox(height: 16),
          TextField(
            key: const Key('logCenterPruneDays'),
            controller: _days,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.logCenterPruneDaysLabel,
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (widget.showScope) ...[
            const SizedBox(height: 8),
            RadioGroup<bool>(
              groupValue: _allTables,
              onChanged: (v) => setState(() => _allTables = v ?? false),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    value: false,
                    title: Text(l10n.logCenterPruneScopeCurrent),
                  ),
                  RadioListTile<bool>(
                    value: true,
                    title: Text(l10n.logCenterPruneScopeAll),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: _submit,
          child: Text(l10n.logCenterPruneConfirm),
        ),
      ],
    );
  }
}
