import 'dart:async';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_system_metrics/app_system_metrics.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';

import 'activity_monitor_dashboard.dart';

class ActivityMonitorScreen extends StatefulWidget {
  static const name = 'Activity Monitor';
  static const path = 'activity-monitor';

  const ActivityMonitorScreen({super.key});

  @override
  State<ActivityMonitorScreen> createState() => _ActivityMonitorScreenState();
}

class _ActivityMonitorScreenState extends State<ActivityMonitorScreen>
    with WidgetsBindingObserver {
  final _monitor = ActivityMonitor();
  final _history = <ActivitySnapshot>[];
  Timer? _timer;
  ActivitySnapshot? _snapshot;
  bool _routeCurrent = false;
  bool _resumed = false;
  bool _running = false;
  bool _inFlight = false;
  bool _failed = false;
  bool _samplingPaused = false;
  int _session = 0;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  @override
  void initState() {
    super.initState();
    _resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeCurrent = ModalRoute.isCurrentOf(context) ?? false;
    _reconcile();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _reconcile();
    if (mounted) setState(() {});
  }

  void _reconcile() {
    final shouldRun =
        mounted && _supported && _routeCurrent && _resumed && !_samplingPaused;
    if (shouldRun == _running) return;
    _running = shouldRun;
    _session++;
    _timer?.cancel();
    _timer = null;
    _monitor.reset();
    if (_running) {
      _snapshot = null;
      _history.clear();
      _failed = false;
      unawaited(_sample(_session));
    }
  }

  Future<void> _sample(int session) async {
    if (!_running || _inFlight || _failed || session != _session) return;
    _inFlight = true;
    try {
      final snapshot = await _monitor.sample();
      if (!mounted || !_running || session != _session) return;
      setState(() {
        _snapshot = snapshot;
        _history.add(snapshot);
        if (_history.length > 60) _history.removeAt(0);
      });
    } catch (error, stack) {
      if (!mounted || !_running || session != _session) return;
      AppLogger().w('Activity Monitor sampling failed', error, stack);
      _monitor.reset();
      setState(() {
        _failed = true;
        _snapshot = null;
      });
    } finally {
      _inFlight = false;
      if (mounted && _running && !_failed) {
        // A sample completed after pause/resume belongs to the old session.
        if (session != _session) _monitor.reset();
        _timer = Timer(
          session == _session ? const Duration(seconds: 1) : Duration.zero,
          () => unawaited(_sample(_session)),
        );
      }
    }
  }

  void _retry() {
    _monitor.reset();
    setState(() {
      _failed = false;
      _snapshot = null;
      _history.clear();
    });
    unawaited(_sample(_session));
  }

  void _toggleSampling() {
    setState(() {
      _samplingPaused = !_samplingPaused;
      _reconcile();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _running = false;
    _session++;
    _timer?.cancel();
    super.dispose();
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
      child: CustomScrollView(
        slivers: [
          DmNavigationHeader(
            builder: (context, header) => SliverAppBar(
              leading: header.leading,
              leadingWidth: header.leadingWidth,
              automaticallyImplyLeading: header.automaticallyImplyLeading,
              title: Text(context.l10n.activityMonitorTitle),
            ),
          ),
          if (!_supported)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _message(context.l10n.activityMonitorUnsupported),
            )
          else if (_failed)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _message(context.l10n.activityMonitorFailed),
                  DmButton(onPressed: _retry, child: Text(context.l10n.retry)),
                ],
              ),
            )
          else if (_snapshot == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _message(
                _running
                    ? context.l10n.activityMonitorLoading
                    : context.l10n.activityMonitorPaused,
              ),
            )
          else
            SliverToBoxAdapter(
              child: ActivityMonitorDashboard(
                snapshot: _snapshot!,
                history: _history,
                running: _running,
                samplingPaused: _samplingPaused,
                onToggleSampling: _toggleSampling,
              ),
            ),
        ],
      ),
    ),
    smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
  );

  Widget _message(String text) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(child: Text(text, textAlign: TextAlign.center)),
  );
}
