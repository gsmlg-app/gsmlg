import 'dart:convert';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;
import 'package:uuid/uuid.dart';

import 'rust/api/duckdb.dart' show SystemLogEntry;

/// Result of routing a log record.
sealed class RoutedLog {
  const RoutedLog();
}

/// A routed system / general log entry.
class RoutedSystemLog extends RoutedLog {
  final SystemLogEntry entry;
  const RoutedSystemLog(this.entry);
}

/// Utility for routing log records into [SystemLogEntry]s.
class LogRouter {
  static const _uuid = Uuid();

  /// Route a [SerializableLogRecord] coming across isolate boundaries.
  static RoutedLog routeSerializable(SerializableLogRecord record) {
    final id = _uuid.v4();
    final loggerName = record.loggerName;
    final message = record.message;
    final context = record.context ?? const {};

    return RoutedSystemLog(
      SystemLogEntry(
        id: id,
        timestampUs: PlatformInt64Util.from(record.time),
        level: record.levelName,
        loggerName: loggerName,
        message: message,
        isolateId: record.isolateId,
        error: record.error,
        stackTrace: record.stackTrace,
        metadata: context.isNotEmpty ? jsonEncode(context) : null,
      ),
    );
  }

  /// Route a standard [logging.LogRecord] from the root logger.
  static RoutedLog routeRoot(
    logging.LogRecord record, {
    String isolateId = 'main',
  }) {
    final id = _uuid.v4();
    final timeUs = record.time.microsecondsSinceEpoch;
    final loggerName = record.loggerName;
    final message = record.message;

    return RoutedSystemLog(
      SystemLogEntry(
        id: id,
        timestampUs: PlatformInt64Util.from(timeUs),
        level: record.level.name,
        loggerName: loggerName,
        message: message,
        isolateId: isolateId,
        error: record.error?.toString(),
        stackTrace: record.stackTrace?.toString(),
        metadata: null,
      ),
    );
  }
}
