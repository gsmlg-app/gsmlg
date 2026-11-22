import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:gsmlg/screens/toolbox/terminal/services/session_controller.dart';
import 'package:gsmlg/screens/toolbox/terminal/services/session_store.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_screen.dart';
import 'package:provider/provider.dart';

class SessionSnapshotsScreen extends StatelessWidget {
  const SessionSnapshotsScreen({super.key});

  static const name = 'Session Snapshots';
  static const path = 'terminal/sessions';

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (context) => _buildContent(context),
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }

  SessionController? _readSessions(BuildContext context) {
    try {
      return context.read<SessionController?>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  Widget _buildContent(BuildContext context) {
    final sessions = _readSessions(context);
    return SafeArea(
      child: Column(
        children: [
          DmNavigationHeader(
            builder: (context, header) => AppBar(
              leading: header.leading,
              leadingWidth: header.leadingWidth,
              automaticallyImplyLeading: header.automaticallyImplyLeading,
              title: Text(context.l10n.sessionSnapshots),
            ),
          ),
          Expanded(
            child: sessions == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(context.l10n.sessionStorageUnavailable),
                    ),
                  )
                : ListenableBuilder(
                    listenable: sessions,
                    builder: (context, _) {
                      final store = sessions.store;
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(context.l10n.sessionRestoreDescription),
                          if (store.latest == null && store.saved.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(context.l10n.sessionNoSnapshots),
                            ),
                          if (store.recovery
                              case final SessionSnapshot recovery)
                            ..._section(
                              context,
                              sessions,
                              context.l10n.sessionRecovery,
                              [recovery],
                            ),
                          ..._section(
                            context,
                            sessions,
                            context.l10n.sessionExitHistory,
                            store.history,
                          ),
                          ..._section(
                            context,
                            sessions,
                            context.l10n.sessionManualSaved,
                            store.saved,
                            manual: true,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    SessionController sessions,
    String title,
    List<SessionSnapshot> snapshots, {
    bool manual = false,
  }) {
    if (snapshots.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      for (final snapshot in snapshots)
        Card(
          child: ListTile(
            title: Text(
              snapshot.name ??
                  MaterialLocalizations.of(
                    context,
                  ).formatFullDate(snapshot.createdAt.toLocal()),
            ),
            subtitle: Text(
              '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(snapshot.createdAt.toLocal()))} · ${context.l10n.sessionDetails((snapshot.layout['tabs'] as List).length, (snapshot.layout['groups'] as List? ?? []).length)}',
            ),
            onTap: () {
              sessions.requestRestore(snapshot);
              context.goNamed(TerminalScreen.name);
            },
            trailing: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    sessions.requestRestore(snapshot);
                    context.goNamed(TerminalScreen.name);
                  },
                  child: Text(context.l10n.sessionRestore),
                ),
                if (manual)
                  IconButton(
                    tooltip: context.l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.l10n.sessionDeleteConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(context.l10n.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        await sessions.deleteSaved(snapshot.id);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${context.l10n.error}: $error'),
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
    ];
  }
}
