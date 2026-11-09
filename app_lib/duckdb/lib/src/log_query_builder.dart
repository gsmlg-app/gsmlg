import 'package:flutter/material.dart';

/// Tables that hold log data and may be pruned, cleared or exported.
class LogTables {
  static const all = [
    'system_logs',
    'api_exchanges',
    'agent_events',
    'usage_events',
  ];
}

/// Optional filters shared by queries, counts and exports.
class LogFilter {
  const LogFilter({
    this.keyword,
    this.timeRange,
    this.level,
    this.category,
    this.conversationId,
    this.runId,
    this.sessionId,
    this.errorsOnly,
  });

  final String? keyword;
  final DateTimeRange? timeRange;
  final String? level;
  final String? category;
  final String? conversationId;
  final String? runId;
  final String? sessionId;
  final bool? errorsOnly;
}

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

  static const _errorLevels = "level IN ('ERROR', 'SEVERE', 'SHOUT')";
  static const _apiErrorExpr = 'has_error OR coalesce(status, 0) >= 400';

  static String _kw(List<String> columns, String keyword) {
    final safe = escapeLiteral(keyword);
    return '(${columns.map((c) => "$c ILIKE '%$safe%'").join(' OR ')})';
  }

  static String _eq(String column, String value) =>
      "$column = '${escapeLiteral(value)}'";

  static String buildWhereClause({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
  }) {
    final conditions = <String>[];
    final isApi = tableOrView == 'api_exchanges';
    final isAgent = tableOrView == 'agent_events';
    final isUsage = tableOrView == 'usage_events';

    final timeRange = filter.timeRange;
    if (timeRange != null) {
      final startUs = timeRange.start.microsecondsSinceEpoch;
      final endUs = timeRange.end.microsecondsSinceEpoch;
      conditions.add('timestamp_us >= $startUs');
      conditions.add('timestamp_us <= $endUs');
    }

    final level = filter.level;
    if (level != null && level.isNotEmpty && level.toUpperCase() != 'ALL') {
      final stored = storedLevelNames(level)
          .map((name) => "'${escapeLiteral(name)}'")
          .join(', ');
      if (isApi) {
        // api_exchanges has no level column: derive it like `v_all_logs`.
        conditions.add(
          "(CASE WHEN $_apiErrorExpr THEN 'SEVERE' ELSE 'INFO' END) "
          'IN ($stored)',
        );
      } else if (!isUsage) {
        conditions.add('level IN ($stored)');
      }
    }

    final keyword = filter.keyword?.trim();
    if (keyword != null && keyword.isNotEmpty) {
      conditions.add(
        _kw(
          isApi
              ? ['path', 'host', 'category', 'record_json']
              : isAgent
                  ? ['summary', 'tool_name', 'payload_json']
                  : isUsage
                      ? ['screen_name', 'target', 'module']
                      : ['message', 'logger_name'],
          keyword,
        ),
      );
    }

    // Filters on columns a table lacks match nothing.
    final category = filter.category;
    if (category != null && category.isNotEmpty) {
      conditions.add(
        isApi || tableOrView == 'v_all_logs'
            ? _eq('category', category)
            : '1 = 0',
      );
    }
    final conversationId = filter.conversationId;
    if (conversationId != null && conversationId.isNotEmpty) {
      conditions.add(
        isApi || isAgent ? _eq('conversation_id', conversationId) : '1 = 0',
      );
    }
    final runId = filter.runId;
    if (runId != null && runId.isNotEmpty) {
      conditions.add(isApi || isAgent ? _eq('run_id', runId) : '1 = 0');
    }
    final sessionId = filter.sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      conditions.add(isUsage ? _eq('session_id', sessionId) : '1 = 0');
    }

    if (filter.errorsOnly == true) {
      if (isApi) {
        conditions.add('($_apiErrorExpr)');
      } else if (isAgent) {
        conditions.add('(is_error OR $_errorLevels)');
      } else if (isUsage) {
        conditions.add('1 = 0');
      } else {
        conditions.add(_errorLevels);
      }
    }

    if (conditions.isEmpty) {
      return '';
    }
    return ' WHERE ${conditions.join(' AND ')}';
  }

  static String buildSelectSql({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
    int limit = 50,
    int offset = 0,
  }) {
    final where = buildWhereClause(tableOrView: tableOrView, filter: filter);
    return 'SELECT * FROM $tableOrView$where ORDER BY timestamp_us DESC LIMIT $limit OFFSET $offset;';
  }

  static String buildCountSql({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
  }) {
    final where = buildWhereClause(tableOrView: tableOrView, filter: filter);
    return 'SELECT COUNT(*) AS total FROM $tableOrView$where;';
  }

  /// Export query ordered oldest first. `api_exchanges` yields only the
  /// stored `record_json`.
  static String buildExportSql({
    required String table,
    LogFilter filter = const LogFilter(),
  }) {
    final where = buildWhereClause(tableOrView: table, filter: filter);
    final columns = table == 'api_exchanges' ? 'record_json' : '*';
    return 'SELECT $columns FROM $table$where ORDER BY timestamp_us ASC;';
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
