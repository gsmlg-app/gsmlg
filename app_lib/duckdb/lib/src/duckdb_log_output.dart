import 'dart:async';
import 'dart:io';

import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;

import 'app_duckdb.dart';
import 'log_router.dart';
import 'rust/api/duckdb.dart';

/// A high-performance [LogOutput] implementation that routes and batches log records
/// into DuckDB the system log table (`system_logs`).
class DuckDbLogOutput extends LogOutput {
  final AppDuckDb duckDb;
  final int systemThreshold;
  final Duration flushInterval;

  final List<SystemLogEntry> _systemBuffer = [];

  Timer? _timer;
  bool _isFlushing = false;
  bool _isClosed = false;

  DuckDbLogOutput({
    required this.duckDb,
    this.systemThreshold = 50,
    this.flushInterval = const Duration(milliseconds: 500),
  }) {
    if (flushInterval > Duration.zero) {
      _timer = Timer.periodic(flushInterval, (_) => _triggerFlush());
    }
  }

  @override
  void write(SerializableLogRecord record, String formatted) {
    if (_isClosed) return;

    final routed = LogRouter.routeSerializable(record);
    _appendRouted(routed);
  }

  /// Hook for receiving standard [logging.LogRecord] instances from the main isolate root logger.
  void writeRootRecord(logging.LogRecord record) {
    if (_isClosed) return;

    final routed = LogRouter.routeRoot(record);
    _appendRouted(routed);
  }

  void _appendRouted(RoutedLog routed) {
    bool needsFlush = false;

    switch (routed) {
      case RoutedSystemLog(:final entry):
        _systemBuffer.add(entry);
        if (_systemBuffer.length >= systemThreshold) {
          needsFlush = true;
        }
    }

    if (needsFlush) {
      _triggerFlush();
    }
  }

  void _triggerFlush() {
    if (_isFlushing || _isClosed) return;
    unawaited(_flushBuffers());
  }

  Future<void> _flushBuffers() async {
    if (_isFlushing) return;
    if (_systemBuffer.isEmpty) return;

    _isFlushing = true;
    try {
      // Drain current buffers atomically
      final sysToFlush = List<SystemLogEntry>.of(_systemBuffer);
      _systemBuffer.clear();

      if (sysToFlush.isNotEmpty) {
        await duckDb.batchAppendSystemLogs(sysToFlush);
      }
    } catch (e, stack) {
      // Isolate error: report without failing caller
      stderr.writeln(
          '[DuckDbLogOutput] Error writing logs to DuckDB: $e\n$stack');
    } finally {
      _isFlushing = false;
    }
  }

  @override
  Future<void> flush() async {
    while (_isFlushing) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await _flushBuffers();
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    _timer?.cancel();
    _timer = null;
    await flush();
  }
}
