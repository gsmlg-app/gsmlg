import 'dart:async';

import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;

import 'app_duckdb.dart';
import 'batch_buffer.dart';
import 'log_router.dart';
import 'rust/api/duckdb.dart';

/// A high-performance [LogOutput] that routes and batches log records into
/// the DuckDB system log table (`system_logs`).
class DuckDbLogOutput extends LogOutput {
  final AppDuckDb duckDb;
  final int systemThreshold;
  final Duration flushInterval;

  late final BatchBuffer<SystemLogEntry> _systemBuffer = BatchBuffer(
    name: 'DuckDbLogOutput',
    threshold: systemThreshold,
    write: (batch) => duckDb.batchAppendSystemLogs(batch),
  );

  Timer? _timer;
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
    switch (routed) {
      case RoutedSystemLog(:final entry):
        if (_systemBuffer.add(entry)) _triggerFlush();
    }
  }

  void _triggerFlush() {
    if (_isClosed) return;
    _systemBuffer.trigger();
  }

  @override
  Future<void> flush() => _systemBuffer.flush();

  @override
  Future<void> close() async {
    _isClosed = true;
    _timer?.cancel();
    _timer = null;
    await flush();
  }
}
