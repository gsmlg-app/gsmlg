import 'dart:async';

/// Serializes native model lifecycle changes with local generation.
///
/// Acquire at the outer operation boundary: repository load methods may call
/// unload internally, so this lease deliberately does not wrap those methods.
class LocalModelAccess {
  LocalModelAccess();

  static final _resources = Expando<LocalModelAccess>();

  /// BLoCs using the same repository share access even without explicit DI.
  factory LocalModelAccess.forResource(Object repository) =>
      _resources[repository] ??= LocalModelAccess();

  Future<void> _tail = Future<void>.value();

  Future<LocalModelLease> acquire() async {
    final previous = _tail;
    final released = Completer<void>();
    _tail = released.future;
    await previous;
    return LocalModelLease._(() => released.complete());
  }

  Future<T> run<T>(Future<T> Function() operation) async {
    final lease = await acquire();
    try {
      return await operation();
    } finally {
      lease.release();
    }
  }
}

class LocalModelLease {
  LocalModelLease._(this._release);
  final void Function() _release;
  bool _released = false;

  void release() {
    if (_released) return;
    _released = true;
    _release();
  }
}
