import 'dart:convert';
import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'log_query_builder.dart';
import 'models/log_record_item.dart';
import 'rust/api/duckdb.dart' as rust_duckdb;
import 'rust/api/duckdb.dart'
    show AgentEventEntry, ApiExchangeEntry, SystemLogEntry, UsageEventEntry;
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
          const libNames = [
            'libapp_duckdb_rust.dylib',
            'libapp_duckdb_rust.so',
            'app_duckdb_rust.dll',
          ];
          const roots = ['app_lib/duckdb/rust/target', 'rust/target'];
          final candidates = [
            for (final root in roots)
              for (final mode in const ['debug', 'release'])
                for (final name in libNames) '$root/$mode/$name',
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

  /// Ensures that the log tables (`system_logs`, `api_exchanges`,
  /// `agent_events`, `usage_events`) and the unified `v_all_logs` view exist,
  /// dropping legacy DNS/DHCP/app_logs objects.
  Future<void> ensureLogSchemas() async {
    await rust_duckdb.ensureLogSchemas();
  }

  /// Appends a batch of system log entries into `system_logs`.
  Future<int> batchAppendSystemLogs(List<SystemLogEntry> entries) async {
    final count = await rust_duckdb.batchAppendSystemLogs(entries: entries);
    return count.toInt();
  }

  /// Appends a batch of API exchange records into `api_exchanges`.
  Future<int> batchAppendApiExchanges(List<ApiExchangeEntry> entries) async {
    final count = await rust_duckdb.batchAppendApiExchanges(entries: entries);
    return count.toInt();
  }

  /// Appends a batch of agent events into `agent_events`.
  Future<int> batchAppendAgentEvents(List<AgentEventEntry> entries) async {
    final count = await rust_duckdb.batchAppendAgentEvents(entries: entries);
    return count.toInt();
  }

  /// Appends a batch of usage events into `usage_events`.
  Future<int> batchAppendUsageEvents(List<UsageEventEntry> entries) async {
    final count = await rust_duckdb.batchAppendUsageEvents(entries: entries);
    return count.toInt();
  }

  /// Queries system logs from `system_logs` with optional [level] filter and [limit].
  Future<List<SystemLogEntry>> querySystemLogs({
    int? limit,
    String? level,
  }) async {
    return rust_duckdb.querySystemLogs(limit: limit, level: level);
  }

  static void _checkTable(String table) {
    if (!LogTables.all.contains(table)) {
      throw ArgumentError.value(table, 'table', 'not a log table');
    }
  }

  static const _queryable = [...LogTables.all, 'v_all_logs'];

  /// Query logs from any log table or `v_all_logs` with filtering and pagination.
  Future<List<LogRecordItem>> queryLogs({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
    int limit = 50,
    int offset = 0,
  }) async {
    if (!_queryable.contains(tableOrView)) {
      throw ArgumentError.value(tableOrView, 'tableOrView', 'unknown table');
    }
    final sql = LogQueryBuilder.buildSelectSql(
      tableOrView: tableOrView,
      filter: filter,
      limit: limit,
      offset: offset,
    );
    final jsonStr = await rust_duckdb.querySqlJson(sql: sql);
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is! List) return [];

    final defaultType = switch (tableOrView) {
      'system_logs' => 'system',
      'api_exchanges' => 'api',
      'agent_events' => 'agent',
      'usage_events' => 'usage',
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
    LogFilter filter = const LogFilter(),
  }) async {
    if (!_queryable.contains(tableOrView)) {
      throw ArgumentError.value(tableOrView, 'tableOrView', 'unknown table');
    }
    final sql = LogQueryBuilder.buildCountSql(
      tableOrView: tableOrView,
      filter: filter,
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

  /// Distinct API exchange categories, sorted.
  Future<List<String>> listCategories() async {
    final jsonStr = await rust_duckdb.querySqlJson(
      sql: 'SELECT DISTINCT category FROM api_exchanges '
          'WHERE category IS NOT NULL ORDER BY category;',
    );
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((m) => m['category'].toString())
        .toList();
  }

  /// Deletes rows older than [days] days (by `timestamp_us`) from [tables].
  Future<void> deleteOlderThan({
    required int days,
    required List<String> tables,
  }) async {
    if (days < 1) {
      throw ArgumentError.value(days, 'days', 'must be >= 1');
    }
    tables.forEach(_checkTable);
    final before = DateTime.now().subtract(Duration(days: days));
    for (final table in tables) {
      await rust_duckdb.executeSql(
        sql: LogQueryBuilder.buildPruneSql(table: table, before: before),
      );
    }
  }

  /// Exports matching rows of [table] as JSON Lines, oldest first.
  ///
  /// `api_exchanges` rows are the stored `record_json` verbatim; other
  /// tables emit one JSON object of the row's columns per line.
  Future<String> exportJsonl({
    required String table,
    LogFilter filter = const LogFilter(),
  }) async {
    _checkTable(table);
    final jsonStr = await rust_duckdb.querySqlJson(
      sql: LogQueryBuilder.buildExportSql(table: table, filter: filter),
    );
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is! List) return '';
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(
          (m) => table == 'api_exchanges'
              ? m['record_json'].toString()
              : jsonEncode(m),
        )
        .join('\n');
  }

  /// Clear all logs in given log table.
  Future<void> clearLogsTable({required String table}) async {
    _checkTable(table);
    final sql = LogQueryBuilder.buildClearSql(table: table);
    await rust_duckdb.executeSql(sql: sql);
  }
}
