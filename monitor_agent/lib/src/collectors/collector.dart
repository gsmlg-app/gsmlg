/// Abstract base for all metrics collectors.
abstract class MetricsCollector<T> {
  /// Collect current metrics. Returns null if collection fails.
  Future<T?> collect();

  /// Whether this collector is supported on the current platform.
  bool get isSupported;
}
