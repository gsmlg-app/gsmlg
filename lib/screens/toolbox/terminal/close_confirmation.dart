import 'dart:async';
import 'dart:ui' show AppExitResponse, AppExitType;

import 'package:app_locale/app_locale.dart';
import 'package:app_logging/app_logging.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:window_manager/window_manager.dart';

/// Whether closing [tab] would kill a program running in it.
Future<bool> isTabBusy(TabItem tab) async {
  if (tab is! PluginTab) return false;
  final plugin = tab.plugin;
  if (plugin is! TerminalPlugin) return false;
  return plugin.isBusy();
}

/// Returns the tabs in [tabs] that have a program running.
Future<List<TabItem>> findBusyTabs(Iterable<TabItem> tabs) async {
  final busyTabs = <TabItem>[];
  for (final tab in tabs) {
    if (await isTabBusy(tab)) busyTabs.add(tab);
  }
  return busyTabs;
}

String _tabTitle(TabItem tab) => tab is PluginTab ? tab.displayTitle : '';

/// Asks before closing [tab] when it has a running program.
///
/// Returns true when the tab may be closed.
Future<bool> confirmCloseTab(BuildContext context, TabItem tab) async {
  if (!await isTabBusy(tab)) return true;
  if (!context.mounted) return false;
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(l10n.closeTabConfirmTitle),
      content: Text(l10n.closeTabConfirmMessage(_tabTitle(tab))),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Asks once before closing a tab group when any of its [tabs] is busy.
///
/// Returns true when every tab in the group may close.
Future<bool> confirmCloseGroup(BuildContext context, List<TabItem> tabs) async {
  final busyTabs = await findBusyTabs(tabs);
  if (busyTabs.isEmpty || !context.mounted) return busyTabs.isEmpty;
  final l10n = context.l10n;
  final titles = busyTabs
      .map((TabItem tab) => '• ${_tabTitle(tab)}')
      .join('\n');
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(l10n.tabGroupCloseConfirmTitle),
      content: Text(l10n.tabGroupCloseConfirmMessage(busyTabs.length, titles)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Asks before quitting while [busyTabs] have running programs.
///
/// Returns true when the app may quit.
Future<bool> confirmQuitWithBusyTabs(
  BuildContext context,
  List<TabItem> busyTabs,
) async {
  if (busyTabs.isEmpty) return true;
  final l10n = context.l10n;
  final titles = busyTabs
      .map((TabItem tab) => '• ${_tabTitle(tab)}')
      .join('\n');
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(l10n.quitConfirmTitle),
      content: Text(l10n.quitConfirmMessage(busyTabs.length, titles)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.quit),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Confirms app quit and window close while terminal tabs have running
/// programs.
///
/// Quit requests (Cmd+Q, the app menu) reach Flutter through the engine's
/// `System.requestAppExit`. When [interceptWindowClose] is set, the window
/// close button is routed into the same request, so closing the last window
/// asks once and then quits.
class AppExitGuard extends StatefulWidget {
  const AppExitGuard({
    super.key,
    required this.navigatorKey,
    required this.child,
    this.interceptWindowClose = false,
  });

  final GlobalKey<NavigatorState> navigatorKey;

  final bool interceptWindowClose;

  final Widget child;

  @override
  State<AppExitGuard> createState() => _AppExitGuardState();
}

class _AppExitGuardState extends State<AppExitGuard> with WindowListener {
  late final AppLifecycleListener _lifecycleListener;
  Future<AppExitResponse>? _pendingExit;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onExitRequested: _onExitRequested,
    );
    if (widget.interceptWindowClose) {
      windowManager.addListener(this);
      unawaited(_preventWindowClose());
    }
  }

  @override
  void dispose() {
    if (widget.interceptWindowClose) {
      windowManager.removeListener(this);
    }
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _preventWindowClose() async {
    try {
      await windowManager.setPreventClose(true);
    } catch (error, stackTrace) {
      AppLogger().e('Failed to intercept window close', error, stackTrace);
    }
  }

  @override
  void onWindowClose() {
    unawaited(_requestExit());
  }

  Future<void> _requestExit() async {
    try {
      await ServicesBinding.instance.exitApplication(AppExitType.cancelable);
    } catch (error, stackTrace) {
      AppLogger().e('Failed to request app exit', error, stackTrace);
    }
  }

  Future<AppExitResponse> _onExitRequested() {
    return _pendingExit ??= _confirmExit().whenComplete(() {
      _pendingExit = null;
    });
  }

  Future<AppExitResponse> _confirmExit() async {
    final state = context.read<TerminalTabBloc>().state;
    if (state is! TerminalTabLoaded) return AppExitResponse.exit;
    final busyTabs = await findBusyTabs(state.allTabs);
    if (busyTabs.isEmpty) return AppExitResponse.exit;
    final navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) {
      return AppExitResponse.exit;
    }
    final confirmed = await confirmQuitWithBusyTabs(navigatorContext, busyTabs);
    return confirmed ? AppExitResponse.exit : AppExitResponse.cancel;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
