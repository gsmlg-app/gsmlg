import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';

import 'models/activity_snapshot.dart';

/// A sampling session with its own baseline for CPU and I/O interval metrics.
///
/// Call [sample] at the desired interval. The first sample after construction or
/// [reset] contains absolute values but no rates. No timers or native resources
/// are retained by this class.
class ActivityMonitor {
  Map<String, dynamic>? _previous;
  Future<ActivitySnapshot>? _pending;
  int _generation = 0;

  /// Collect a snapshot, sharing an already pending request when called again.
  Future<ActivitySnapshot> sample() {
    return _pending ??= _sample().whenComplete(() => _pending = null);
  }

  Future<ActivitySnapshot> _sample() async {
    final generation = _generation;
    final raw = await SystemMetricsPlatform.instance.getActivityData();
    final current = ActivitySnapshot.fromSamples(
      raw,
      previous: generation == _generation ? _previous : null,
    );
    if (generation == _generation) _previous = raw;
    return current;
  }

  /// Clear interval history, for example after pausing or hiding the page.
  ///
  /// A request already in flight cannot establish the next session's baseline.
  void reset() {
    _generation++;
    _previous = null;
  }
}
