class DeltaTracker<K> {
  final Map<K, int> _previous = {};
  DateTime _lastTimestamp = DateTime.now();

  /// Returns per-second rates for each key since the last call.
  /// Returns null on first call (no previous data to compute delta).
  Map<K, int>? computeRates(Map<K, int> current) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastTimestamp).inMilliseconds / 1000.0;

    if (_previous.isEmpty || elapsed <= 0) {
      _previous
        ..clear()
        ..addAll(current);
      _lastTimestamp = now;
      return null;
    }

    final rates = <K, int>{};
    for (final entry in current.entries) {
      final prev = _previous[entry.key] ?? 0;
      final delta = entry.value - prev;
      rates[entry.key] = (delta / elapsed).round().clamp(0, 1 << 62);
    }

    _previous
      ..clear()
      ..addAll(current);
    _lastTimestamp = now;
    return rates;
  }
}
