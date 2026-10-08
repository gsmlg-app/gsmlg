import 'dart:async';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_compass/app_compass.dart';
import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

import 'compass_dial.dart';
import 'compass_math.dart';

bool isCompassPlatformSupported({
  required bool isWeb,
  required TargetPlatform platform,
}) =>
    !isWeb &&
    (platform == TargetPlatform.android || platform == TargetPlatform.iOS);

class CompassScreen extends StatefulWidget {
  static const name = 'Compass';
  static const path = 'compass';

  const CompassScreen({super.key, this.source});

  final CompassSource? source;

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with WidgetsBindingObserver {
  late final CompassSource _source;
  StreamSubscription<CompassReading>? _subscription;
  Timer? _firstReadingTimer;
  Future<void> _transitions = Future<void>.value();
  CompassReading? _reading;
  bool _routeCurrent = false;
  bool _resumed = false;
  bool _failed = false;
  int _session = 0;
  int? _subscriptionSession;

  bool get _supported => isCompassPlatformSupported(
    isWeb: kIsWeb,
    platform: defaultTargetPlatform,
  );
  bool get _eligible => mounted && _supported && _routeCurrent && _resumed;
  bool _isSessionCurrent(int session) =>
      _eligible && !_failed && session == _session;

  @override
  void initState() {
    super.initState();
    _source = widget.source ?? AppCompass();
    _resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeCurrent = ModalRoute.isCurrentOf(context) ?? false;
    _requestReconcile();
  }

  void _invalidateSession() {
    _session++;
    _firstReadingTimer?.cancel();
    _firstReadingTimer = null;
  }

  void _requestReconcile() {
    if (!_eligible || _failed) _invalidateSession();
    _transitions = _transitions.then((_) => _reconcile());
  }

  Future<void> _reconcile() async {
    if (_subscription != null &&
        (!_eligible || _failed || _subscriptionSession != _session)) {
      final subscription = _subscription!;
      _subscription = null;
      _subscriptionSession = null;
      try {
        await subscription.cancel();
      } catch (_) {
        if (_eligible) _fail();
        return;
      }
    }
    if (!_eligible || _failed || _subscription != null) return;
    final session = ++_session;
    setState(() => _reading = null);
    try {
      await _source.refreshOrientation();
      if (!_isSessionCurrent(session)) return;
      // Start before listen: a synchronous first event must cancel this timer.
      _firstReadingTimer = Timer(const Duration(seconds: 5), () {
        if (_isSessionCurrent(session)) _fail();
      });
      _subscriptionSession = session;
      _subscription = _source.readings.listen(
        (reading) {
          if (!_isSessionCurrent(session)) return;
          _firstReadingTimer?.cancel();
          _firstReadingTimer = null;
          if (reading.status == CompassStatus.unavailable &&
              reading.unavailableReason !=
                  CompassUnavailableReason.sensorNotFound) {
            _fail();
            return;
          }
          final heading = reading.magneticHeadingDegrees;
          if (reading.status == CompassStatus.ready &&
              !_validHeading(heading)) {
            _fail();
            return;
          }
          setState(() => _reading = reading);
        },
        onError: (Object error, StackTrace stack) {
          if (_isSessionCurrent(session)) _fail();
        },
        onDone: () {
          if (_isSessionCurrent(session)) _fail();
        },
      );
      // A synchronous failure may have invalidated the session during listen.
      if (!_isSessionCurrent(session)) _requestReconcile();
    } catch (_) {
      if (_isSessionCurrent(session)) _fail();
    }
  }

  bool _validHeading(double? value) =>
      value != null && value.isFinite && value >= 0 && value < 360;

  void _fail() {
    if (!mounted) return;
    _invalidateSession();
    setState(() {
      _failed = true;
      _reading = null;
    });
    _requestReconcile();
  }

  void _retry() {
    setState(() {
      _failed = false;
      _reading = null;
    });
    _requestReconcile();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _requestReconcile();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_eligible || _failed) return;
      _invalidateSession();
      setState(() => _reading = null);
      _requestReconcile();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _invalidateSession();
    _routeCurrent = false;
    // Queue cancellation behind any in-flight orientation refresh.
    _transitions = _transitions.then((_) => _reconcile());
    super.dispose();
  }

  Future<void> _showHelp() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.compassHelpTitle),
      content: SingleChildScrollView(child: Text(context.l10n.compassHelpBody)),
      actions: [
        DmButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final directions = [
      l10n.compassDirectionNorth,
      l10n.compassDirectionNorthEast,
      l10n.compassDirectionEast,
      l10n.compassDirectionSouthEast,
      l10n.compassDirectionSouth,
      l10n.compassDirectionSouthWest,
      l10n.compassDirectionWest,
      l10n.compassDirectionNorthWest,
    ];
    final value = _reading?.magneticHeadingDegrees;
    final heading =
        _supported &&
            !_failed &&
            _reading?.status != CompassStatus.unavailable &&
            _validHeading(value)
        ? value
        : null;
    final readout = heading == null
        ? '—'
        : l10n.compassHeadingReadout(
            roundedCompassHeading(heading),
            directions[compassDirectionIndex(heading)],
          );
    final calibrating = _reading?.status == CompassStatus.calibrating;
    final String? status = !_supported
        ? l10n.compassUnsupportedPlatform
        : _failed
        ? l10n.compassSensorError
        : _reading?.status == CompassStatus.unavailable
        ? l10n.compassUnavailable
        : calibrating
        ? l10n.compassCalibrationNeeded
        : _reading == null
        ? l10n.compassWaitingForSensor
        : null;

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: Constants.defaultGridGap,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(l10n.compassTitle),
              actions: [
                // TODO(upstream): duskmoon-dev/flutter-duskmoon-ui#21
                // WORKAROUND(upstream): duskmoon-dev/flutter-duskmoon-ui#21
                // The Cupertino button drops the tooltip's semantic label.
                Semantics(
                  label: l10n.compassHelpTitle,
                  button: true,
                  excludeSemantics: true,
                  onTap: _showHelp,
                  child: DmIconButton(
                    tooltip: l10n.compassHelpTitle,
                    icon: const Icon(Icons.help_outline),
                    onPressed: _showHelp,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    CompassDial(
                      heading: heading,
                      directions: [
                        directions[0],
                        directions[2],
                        directions[4],
                        directions[6],
                      ],
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      label: readout,
                      excludeSemantics: true,
                      child: Text(
                        readout,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.compassMagneticNorth,
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (status != null) ...[
                      const SizedBox(height: 16),
                      if (calibrating)
                        Icon(
                          Icons.warning_amber_rounded,
                          color:
                              theme.extension<DmColorExtension>()?.warning ??
                              theme.colorScheme.tertiary,
                        ),
                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                    if (_failed && _supported) ...[
                      const SizedBox(height: 16),
                      DmButton(onPressed: _retry, child: Text(l10n.retry)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
