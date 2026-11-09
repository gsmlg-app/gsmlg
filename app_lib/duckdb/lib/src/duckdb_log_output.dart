import 'dart:async';
import 'dart:io';

import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;

import 'app_duckdb.dart';
import 'log_router.dart';
import 'rust/api/duckdb.dart';

/// A high-performance [LogOutput] implementation that routes and batches log records
/// into DuckDB dedicated tables (`system_logs`, `dns_logs`, `dhcp_logs`).
class DuckDbLogOutput extends LogOutput {
  final AppDuckDb duckDb;
  final int dnsThreshold;
  final int systemThreshold;
  final int dhcpThreshold;
  final Duration flushInterval;

  final List<SystemLogEntry> _systemBuffer = [];
  final List<DnsLogEntry> _dnsBuffer = [];
  final List<DhcpLogEntry> _dhcpBuffer = [];

  Timer? _timer;
  bool _isFlushing = false;
  bool _isClosed = false;

  DuckDbLogOutput({
    required this.duckDb,
    this.dnsThreshold = 100,
    this.systemThreshold = 50,
    this.dhcpThreshold = 50,
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
      case RoutedDnsLog(:final entry):
        _dnsBuffer.add(entry);
        if (_dnsBuffer.length >= dnsThreshold) {
          needsFlush = true;
        }
      case RoutedDhcpLog(:final entry):
        _dhcpBuffer.add(entry);
        if (_dhcpBuffer.length >= dhcpThreshold) {
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
    if (_systemBuffer.isEmpty && _dnsBuffer.isEmpty && _dhcpBuffer.isEmpty) {
      return;
    }

    _isFlushing = true;
    try {
      // Drain current buffers atomically
      final sysToFlush = List<SystemLogEntry>.of(_systemBuffer);
      _systemBuffer.clear();

      final dnsToFlush = List<DnsLogEntry>.of(_dnsBuffer);
      _dnsBuffer.clear();

      final dhcpToFlush = List<DhcpLogEntry>.of(_dhcpBuffer);
      _dhcpBuffer.clear();

      if (sysToFlush.isNotEmpty) {
        await duckDb.batchAppendSystemLogs(sysToFlush);
      }
      if (dnsToFlush.isNotEmpty) {
        await duckDb.batchAppendDnsLogs(dnsToFlush);
      }
      if (dhcpToFlush.isNotEmpty) {
        await duckDb.batchAppendDhcpLogs(dhcpToFlush);
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
