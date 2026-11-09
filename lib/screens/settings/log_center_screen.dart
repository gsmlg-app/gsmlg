import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_duckdb/app_duckdb.dart' show AppDuckDb;
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';

/// Settings screen for browsing, filtering and pruning logs persisted in
/// the local DuckDB log store.
class LogCenterScreen extends StatefulWidget {
  static const name = 'Log Center';
  static const path = 'log-center';

  const LogCenterScreen({super.key});

  @override
  State<LogCenterScreen> createState() => _LogCenterScreenState();
}

enum _PruneChoice { olderThan7Days, olderThan30Days, all }

class _LogCenterScreenState extends State<LogCenterScreen>
    with SingleTickerProviderStateMixin {
  /// Tables that hold rows written by this app. `v_all_logs` unions them.
  static const _tables = ['system_logs'];

  late final TabController _tabController;
  final _allViewerKey = GlobalKey<DuckDbLogViewerState>();
  final _systemViewerKey = GlobalKey<DuckDbLogViewerState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DuckDbLogViewerState? get _activeViewer => switch (_tabController.index) {
    0 => _allViewerKey.currentState,
    _ => _systemViewerKey.currentState,
  };

  List<String> get _activeTables =>
      _tabController.index == 0 ? _tables : const ['system_logs'];

  Future<void> _showPruneDialog() async {
    final l10n = context.l10n;
    final choice = await showDialog<_PruneChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logCenterPruneTitle),
        content: Text(l10n.logCenterPruneMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_PruneChoice.olderThan7Days),
            child: Text(l10n.logCenterOlderThan7Days),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_PruneChoice.olderThan30Days),
            child: Text(l10n.logCenterOlderThan30Days),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(_PruneChoice.all),
            child: Text(l10n.logCenterClearAll),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final duckDb = AppDuckDb.instance;
    try {
      switch (choice) {
        case _PruneChoice.olderThan7Days:
          await duckDb.deleteOlderThan(days: 7, tables: _activeTables);
        case _PruneChoice.olderThan30Days:
          await duckDb.deleteOlderThan(days: 30, tables: _activeTables);
        case _PruneChoice.all:
          for (final table in _activeTables) {
            await duckDb.clearLogsTable(table: table);
          }
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.logCenterPruneDone)));
      await _activeViewer?.refresh();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.logCenterPruneFailed('$error'))),
      );
    }
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
                  Tab(
                    icon: const Icon(Icons.all_inbox, size: 18),
                    text: context.l10n.logCenterAllLogs,
                  ),
                  Tab(
                    icon: const Icon(Icons.memory, size: 18),
                    text: context.l10n.logCenterSystemLogs,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            DuckDbLogViewer(
              key: _allViewerKey,
              tableOrView: 'v_all_logs',
              showTypeColumn: true,
            ),
            DuckDbLogViewer(
              key: _systemViewerKey,
              tableOrView: 'system_logs',
              showTypeColumn: false,
            ),
          ],
        ),
      ),
    ),
    smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
  );
}
