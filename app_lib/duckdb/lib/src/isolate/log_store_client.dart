import 'dart:isolate';

import 'package:isolate_orchestrator/isolate_orchestrator.dart';

import '../app_duckdb.dart';
import '../log_query_builder.dart';
import '../log_store.dart';
import '../models/log_record_item.dart';

/// [LogStore] backed by the `logstore` isolate (see `logStoreEntryPoint`).
///
/// Worker failures surface as `TaskException`; an unreachable or crashed
/// worker as `NodeNotFoundException` / `TaskTimeoutException`.
class LogStoreClient implements LogStore {
  LogStoreClient(this.hub, {this.target = 'logstore'});

  final IsolateHub hub;
  final String target;

  static const queryTimeout = Duration(seconds: 30);
  static const flushTimeout = Duration(seconds: 5);

  Future<T> _call<T>(
    String op, [
    Map<String, Object?> args = const {},
    Duration timeout = queryTimeout,
  ]) async =>
      await hub.call<Object?>(
        target,
        {'op': op, ...args},
        timeout: timeout,
      ) as T;

  /// Port producers send log records to (see `PortLogSink`).
  Future<SendPort> ingestPort() => _call('ingestPort', const {}, flushTimeout);

  @override
  Future<List<LogRecordItem>> queryLogs({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _call<List<Object?>>('queryLogs', {
      'tableOrView': tableOrView,
      'filter': filter.toWire(),
      'limit': limit,
      'offset': offset,
    });
    final defaultType = AppDuckDb.defaultLogType(tableOrView);
    return [
      for (final row in rows.cast<Map<Object?, Object?>>())
        LogRecordItem.fromMap(
          row.cast<String, dynamic>(),
          defaultType: defaultType,
        ),
    ];
  }

  @override
  Future<int> countLogs({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
  }) =>
      _call('countLogs', {
        'tableOrView': tableOrView,
        'filter': filter.toWire(),
      });

  @override
  Future<List<String>> listCategories() async =>
      (await _call<List<Object?>>('listCategories')).cast<String>();

  @override
  Future<List<Map<String, dynamic>>> queryAgentRuns({
    LogFilter filter = const LogFilter(),
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _call<List<Object?>>('queryAgentRuns', {
      'filter': filter.toWire(),
      'limit': limit,
      'offset': offset,
    });
    return [
      for (final row in rows.cast<Map<Object?, Object?>>())
        row.cast<String, dynamic>(),
    ];
  }

  @override
  Future<int> countAgentRuns({LogFilter filter = const LogFilter()}) =>
      _call('countAgentRuns', {'filter': filter.toWire()});

  @override
  Future<void> deleteOlderThan({
    required int days,
    required List<String> tables,
  }) =>
      _call<void>('deleteOlderThan', {'days': days, 'tables': tables});

  @override
  Future<void> clearLogsTable({required String table}) =>
      _call<void>('clearLogsTable', {'table': table});

  @override
  Future<String> exportJsonl({
    required String table,
    LogFilter filter = const LogFilter(),
  }) =>
      _call('exportJsonl', {'table': table, 'filter': filter.toWire()});

  @override
  Future<String> queryJson(String sql) => _call('queryJson', {'sql': sql});

  @override
  Future<void> flush() => _call<void>('flush', const {}, flushTimeout);
}
