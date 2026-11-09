import 'dart:async';
import 'dart:io';

/// Collects entries and writes them in batches. Write failures are reported
/// to stderr and never propagate to the caller.
class BatchBuffer<T> {
  BatchBuffer({
    required this.name,
    required this.threshold,
    required Future<void> Function(List<T>) write,
  }) : _write = write;

  final String name;
  final int threshold;
  final Future<void> Function(List<T>) _write;
  final List<T> _items = [];
  bool _isFlushing = false;

  /// Adds [item]; returns true when the buffer reached its threshold.
  bool add(T item) {
    _items.add(item);
    return _items.length >= threshold;
  }

  /// Starts a background flush unless one is already running.
  void trigger() {
    if (_isFlushing) return;
    unawaited(_drain());
  }

  /// Waits for any running flush, then writes whatever is buffered.
  Future<void> flush() async {
    while (_isFlushing) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await _drain();
  }

  Future<void> _drain() async {
    if (_isFlushing || _items.isEmpty) return;
    _isFlushing = true;
    try {
      final batch = List<T>.of(_items);
      _items.clear();
      await _write(batch);
    } catch (e, stack) {
      stderr.writeln('[$name] Error writing logs to DuckDB: $e\n$stack');
    } finally {
      _isFlushing = false;
    }
  }
}
