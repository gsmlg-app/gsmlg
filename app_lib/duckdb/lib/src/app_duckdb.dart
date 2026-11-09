import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'log_query_builder.dart';
import 'models/log_record_item.dart';
import 'rust/api/duckdb.dart' as rust_duckdb;
import 'rust/api/duckdb.dart'
    show DuckDbLogEntry, SystemLogEntry, DnsLogEntry, DhcpLogEntry;
import 'rust/frb_generated.dart';

/// High-level Dart interface to the embedded DuckDB database powered by Rust.
class AppDuckDb {
  AppDuckDb._();

  /// Singleton instance of [AppDuckDb].
  static final AppDuckDb instance = AppDuckDb._();

  static bool _initialized = false;

  /// Initializes the underlying RustLib. Safe to call multiple times.
  static Future<void> initialize({ExternalLibrary? externalLibrary}) async {
    if (!_initialized) {
      if (externalLibrary != null) {
        await RustLib.init(externalLibrary: externalLibrary);
      } else {
        try {
          await RustLib.init();
        } catch (_) {
          // In unit tests / headless runner on macOS/Linux/Windows, locate local dylib
          final candidates = [
            'app_lib/duckdb/rust/target/debug/libapp_duckdb_rust.dylib',
            'app_lib/duckdb/rust/target/release/libapp_duckdb_rust.dylib',
            'rust/target/debug/libapp_duckdb_rust.dylib',
            'rust/target/release/libapp_duckdb_rust.dylib',
          ];
          ExternalLibrary? fallback;
          for (final path in candidates) {
            final file = File(path);
            if (file.existsSync()) {
              fallback = ExternalLibrary.open(file.absolute.path);
              break;
            }
          }
          if (fallback != null) {
            await RustLib.init(externalLibrary: fallback);
          } else {
            rethrow;
          }
        }
      }
      _initialized = true;
    }
  }

  /// Opens DuckDB database.
  ///
  /// - If [inMemory] is `true`, opens an in-memory database `:memory:`.
  /// - If [path] is provided, opens the database file at [path].
  /// - If both are null/false, opens `gsmlg_logs.duckdb` in the application support directory.
  Future<void> open({String? path, bool inMemory = false}) async {
    await initialize();

    String targetPath;
    if (inMemory || path == ':memory:') {
      targetPath = ':memory:';
    } else if (path != null && path.isNotEmpty) {
      targetPath = path;
    } else {
      final dir = await getApplicationSupportDirectory();
      targetPath = p.join(dir.path, 'gsmlg_logs.duckdb');
    }

    await rust_duckdb.openDuckdb(path: targetPath);
  }

  /// Closes the current database connection if open.
  Future<void> close() async {
    await rust_duckdb.closeDuckdb();
  }

  /// Whether the database is currently open.
  Future<bool> get isOpen => rust_duckdb.isDuckdbOpen();

  /// Executes arbitrary DDL/DML SQL statements (e.g. CREATE TABLE, DELETE, etc.).
  Future<int> execute(String sql) async {
    final count = await rust_duckdb.executeSql(sql: sql);
    return count.toInt();
  }

  /// Executes SQL query and returns the results formatted as a JSON string.
  Future<String> queryJson(String sql) async {
    return rust_duckdb.querySqlJson(sql: sql);
  }

  /// Ensures that the legacy `app_logs` table schema exists in DuckDB.
  Future<void> ensureLogSchema() async {
    await rust_duckdb.ensureLogSchema();
  }

  /// Ensures that the dedicated tables (`system_logs`, `dns_logs`, `dhcp_logs`)
  /// and the unified `v_all_logs` view exist in DuckDB.
  Future<void> ensureLogSchemas() async {
    await rust_duckdb.ensureLogSchemas();
  }

  /// Appends a single log entry into DuckDB (legacy).
  Future<void> appendLog(DuckDbLogEntry entry) async {
    await rust_duckdb.appendLog(entry: entry);
  }

  /// Appends a batch of log entries using the high-performance DuckDB Appender (legacy).
  Future<int> batchAppendLogs(List<DuckDbLogEntry> entries) async {
    final count = await rust_duckdb.batchAppendLogs(entries: entries);
    return count.toInt();
  }

  /// Appends a batch of system log entries into `system_logs`.
  Future<int> batchAppendSystemLogs(List<SystemLogEntry> entries) async {
    final count = await rust_duckdb.batchAppendSystemLogs(entries: entries);
    return count.toInt();
  }

  /// Appends a batch of DNS log entries into `dns_logs`.
  Future<int> batchAppendDnsLogs(List<DnsLogEntry> entries) async {
    final count = await rust_duckdb.batchAppendDnsLogs(entries: entries);
    return count.toInt();
  }

  /// Appends a batch of DHCP log entries into `dhcp_logs`.
  Future<int> batchAppendDhcpLogs(List<DhcpLogEntry> entries) async {
    final count = await rust_duckdb.batchAppendDhcpLogs(entries: entries);
    return count.toInt();
  }

  /// Queries recent logs from legacy `app_logs`.
  Future<List<DuckDbLogEntry>> queryRecentLogs({
    int? limit,
    String? level,
  }) async {
    return rust_duckdb.queryRecentLogs(limit: limit, level: level);
  }

  /// Queries system logs from `system_logs` with optional [level] filter and [limit].
  Future<List<SystemLogEntry>> querySystemLogs({
    int? limit,
    String? level,
  }) async {
    return rust_duckdb.querySystemLogs(limit: limit, level: level);
  }

  /// Queries DNS logs from `dns_logs` with optional [domain], [rcode] filters and [limit].
  Future<List<DnsLogEntry>> queryDnsLogs({
    int? limit,
    String? domain,
    String? rcode,
  }) async {
    return rust_duckdb.queryDnsLogs(
      limit: limit,
      domain: domain,
      rcode: rcode,
    );
  }

  /// Queries DHCP logs from `dhcp_logs` with optional [clientMac], [assignedIp] filters and [limit].
  Future<List<DhcpLogEntry>> queryDhcpLogs({
    int? limit,
    String? clientMac,
    String? assignedIp,
  }) async {
    return rust_duckdb.queryDhcpLogs(
      limit: limit,
      clientMac: clientMac,
      assignedIp: assignedIp,
    );
  }

  /// Query logs from any table or view with dynamic filtering and pagination.
  Future<List<LogRecordItem>> queryLogs({
    required String tableOrView,
    String? keyword,
    DateTimeRange? timeRange,
    String? level,
    int limit = 50,
    int offset = 0,
  }) async {
    final sql = LogQueryBuilder.buildSelectSql(
      tableOrView: tableOrView,
      keyword: keyword,
      timeRange: timeRange,
      level: level,
      limit: limit,
      offset: offset,
    );
    final jsonStr = await rust_duckdb.querySqlJson(sql: sql);
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is! List) return [];

    final defaultType = switch (tableOrView) {
      'dns_logs' => 'dns',
      'dhcp_logs' => 'dhcp',
      'system_logs' => 'system',
      _ => null,
    };

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((m) => LogRecordItem.fromMap(m, defaultType: defaultType))
        .toList();
  }

  /// Get total count of matching logs for pagination.
  Future<int> countLogs({
    required String tableOrView,
    String? keyword,
    DateTimeRange? timeRange,
    String? level,
  }) async {
    final sql = LogQueryBuilder.buildCountSql(
      tableOrView: tableOrView,
      keyword: keyword,
      timeRange: timeRange,
      level: level,
    );
    final jsonStr = await rust_duckdb.querySqlJson(sql: sql);
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first as Map<String, dynamic>;
      final total = first['total'];
      if (total is num) return total.toInt();
      if (total is String) return int.tryParse(total) ?? 0;
    }
    return 0;
  }

  /// Prune logs older than given datetime.
  Future<void> pruneLogs({
    required String table,
    required DateTime before,
  }) async {
    final sql = LogQueryBuilder.buildPruneSql(table: table, before: before);
    await rust_duckdb.executeSql(sql: sql);
  }

  /// Clear all logs in given table.
  Future<void> clearLogsTable({required String table}) async {
    final sql = LogQueryBuilder.buildClearSql(table: table);
    await rust_duckdb.executeSql(sql: sql);
  }

  /// Helper factory to create a [DuckDbLogEntry] with convenient defaults.
  static DuckDbLogEntry createLogEntry({
    required String id,
    DateTime? timestamp,
    int? timestampUs,
    required String level,
    String? loggerName,
    required String message,
    String? queryType,
    String? domain,
    String? sourceIp,
    String? status,
    int? latencyMs,
    String? metadata,
  }) {
    final ts =
        timestampUs ?? (timestamp ?? DateTime.now()).microsecondsSinceEpoch;
    return DuckDbLogEntry(
      id: id,
      timestampUs: PlatformInt64Util.from(ts),
      level: level,
      loggerName: loggerName,
      message: message,
      queryType: queryType,
      domain: domain,
      sourceIp: sourceIp,
      status: status,
      latencyMs: latencyMs,
      metadata: metadata,
    );
  }
}
