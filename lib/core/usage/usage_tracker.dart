import 'dart:math';

import 'package:app_logging/app_logging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

import '../../screens/app/splash_screen.dart';

/// Records sessions and per-screen foreground time via [LogCapture].
///
/// Time is measured only while the app is in the foreground; the visit of the
/// current screen is closed on route change, background, or [dispose].
class UsageTracker {
  UsageTracker({DateTime Function()? clock, this._appVersion})
    : _clock = clock ?? DateTime.now,
      sessionId = _newSessionId();

  final DateTime Function() _clock;
  final String? _appVersion;
  final String sessionId;

  Uri? _uri;
  Uri? _resumeUri; // screen to reopen when returning to foreground
  String? _routeName;
  int _visitMs = 0;
  int _sessionMs = 0;
  DateTime? _foregroundSince;
  bool _started = false;
  bool _disposed = false;

  static String _newSessionId() {
    final r = Random.secure();
    return List.generate(
      16,
      (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  static String moduleFor(Uri uri) => switch (uri.pathSegments.firstOrNull) {
    'home' => 'Home',
    'service' => 'Service',
    'toolbox' => 'Toolbox',
    'chat' => 'Chat',
    'settings' => 'Settings',
    _ => 'Other',
  };

  void start() {
    if (_started || _disposed) return;
    _started = true;
    _foregroundSince = _clock();
    _emit(
      'session_start',
      payload: {
        'platform': defaultTargetPlatform.name,
        'app_version': _appVersion,
      },
    );
  }

  void onRouteChanged(Uri uri, String? routeName) {
    if (!_started || _disposed) return;
    if (_foregroundSince == null) {
      _resumeUri = uri.path == SplashScreen.path ? null : uri;
      _routeName = routeName;
      return;
    }
    if (uri.path == _uri?.path) return;
    _closeVisit();
    if (uri.path == SplashScreen.path) {
      _uri = null;
      return;
    }
    _checkpoint();
    _uri = uri;
    _routeName = routeName;
    _visitMs = 0;
  }

  void onForeground() {
    if (!_started || _disposed || _foregroundSince != null) return;
    _foregroundSince = _clock();
    _uri = _resumeUri;
    _resumeUri = null;
  }

  void onBackground() {
    if (!_started || _disposed || _foregroundSince == null) return;
    _resumeUri = _uri;
    _closeVisit();
    _accrue();
  }

  void dispose() {
    if (!_started || _disposed) return;
    _closeVisit();
    _accrue();
    _disposed = true;
    _emit('session_end', durationMs: _sessionMs);
  }

  /// Moves elapsed foreground time into the visit and session totals and
  /// marks the app as backgrounded.
  void _accrue() {
    final since = _foregroundSince;
    if (since == null) return;
    final ms = _clock().difference(since).inMilliseconds;
    _visitMs += ms;
    _sessionMs += ms;
    _foregroundSince = null;
  }

  /// Accrues elapsed time but keeps the foreground segment open.
  void _checkpoint() {
    if (_foregroundSince == null) return;
    _accrue();
    _foregroundSince = _clock();
  }

  void _closeVisit() {
    final uri = _uri;
    if (uri == null) return;
    _checkpoint();
    _emit(
      'screen_view',
      module: moduleFor(uri),
      screenName: _routeName ?? uri.path,
      routePath: uri.path,
      durationMs: _visitMs,
    );
    _uri = null;
    _visitMs = 0;
  }

  void _emit(
    String type, {
    String? module,
    String? screenName,
    String? routePath,
    int? durationMs,
    Map<String, Object?>? payload,
  }) => LogCapture.instance.usage(
    UsageEvent(
      ts: _clock(),
      sessionId: sessionId,
      eventType: type,
      module: module,
      screenName: screenName,
      routePath: routePath,
      durationMs: durationMs,
      payload: payload,
    ),
  );
}
