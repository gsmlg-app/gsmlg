import 'package:flutter/material.dart';

/// Safe SQL generator for querying, counting, and pruning logs in DuckDB.
class LogQueryBuilder {
  static String escapeLiteral(String text) {
    return text.replaceAll("'", "''");
  }

  /// Stored `package:logging` level names matching a UI filter level
  /// (mirrors `LogLevel.fromString`), e.g. `ERROR` matches `SEVERE` and `SHOUT`.
  static List<String> storedLevelNames(String level) {
    final upper = level.toUpperCase();
    return switch (upper) {
      'DEBUG' => const ['DEBUG', 'FINE', 'FINER', 'FINEST'],
      'INFO' => const ['INFO', 'CONFIG'],
      'WARNING' => const ['WARNING', 'WARN'],
      'ERROR' => const ['ERROR', 'SEVERE', 'SHOUT'],
      _ => [upper],
    };
  }

  static String buildWhereClause({
    required String tableOrView,
    String? keyword,
    DateTimeRange? timeRange,
    String? level,
  }) {
    final conditions = <String>[];

    if (timeRange != null) {
      final startUs = timeRange.start.microsecondsSinceEpoch;
      final endUs = timeRange.end.microsecondsSinceEpoch;
      conditions.add('timestamp_us >= $startUs');
      conditions.add('timestamp_us <= $endUs');
    }

    if (level != null && level.isNotEmpty && level.toUpperCase() != 'ALL') {
      final stored = storedLevelNames(level)
          .map((name) => "'${escapeLiteral(name)}'")
          .join(', ');
      conditions.add('level IN ($stored)');
    }

    if (keyword != null && keyword.trim().isNotEmpty) {
      final safeKw = escapeLiteral(keyword.trim());
      if (tableOrView == 'dns_logs') {
        conditions.add(
          "(domain ILIKE '%$safeKw%' OR client_ip ILIKE '%$safeKw%' OR answers ILIKE '%$safeKw%' OR query_type ILIKE '%$safeKw%')",
        );
      } else if (tableOrView == 'dhcp_logs') {
        conditions.add(
          "(client_mac ILIKE '%$safeKw%' OR assigned_ip ILIKE '%$safeKw%' OR hostname ILIKE '%$safeKw%' OR message_type ILIKE '%$safeKw%')",
        );
      } else {
        conditions.add(
          "(message ILIKE '%$safeKw%' OR logger_name ILIKE '%$safeKw%')",
        );
      }
    }

    if (conditions.isEmpty) {
      return '';
    }
    return ' WHERE ${conditions.join(' AND ')}';
  }

  static String buildSelectSql({
    required String tableOrView,
    String? keyword,
    DateTimeRange? timeRange,
    String? level,
    int limit = 50,
    int offset = 0,
  }) {
    final where = buildWhereClause(
      tableOrView: tableOrView,
      keyword: keyword,
      timeRange: timeRange,
      level: level,
    );
    return 'SELECT * FROM $tableOrView$where ORDER BY timestamp_us DESC LIMIT $limit OFFSET $offset;';
  }

  static String buildCountSql({
    required String tableOrView,
    String? keyword,
    DateTimeRange? timeRange,
    String? level,
  }) {
    final where = buildWhereClause(
      tableOrView: tableOrView,
      keyword: keyword,
      timeRange: timeRange,
      level: level,
    );
    return 'SELECT COUNT(*) AS total FROM $tableOrView$where;';
  }

  static String buildPruneSql({
    required String table,
    required DateTime before,
  }) {
    final beforeUs = before.microsecondsSinceEpoch;
    return 'DELETE FROM $table WHERE timestamp_us < $beforeUs;';
  }

  static String buildClearSql({required String table}) {
    return 'DELETE FROM $table;';
  }
}
