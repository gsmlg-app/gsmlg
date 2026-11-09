import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_duckdb/app_duckdb.dart';

void main() {
  group('LogQueryBuilder', () {
    test('builds select and count sql for v_all_logs with time and keyword',
        () {
      final range = DateTimeRange(
        start: DateTime.fromMicrosecondsSinceEpoch(1000),
        end: DateTime.fromMicrosecondsSinceEpoch(2000),
      );
      final selectSql = LogQueryBuilder.buildSelectSql(
        tableOrView: 'v_all_logs',
        keyword: 'test',
        timeRange: range,
        level: 'INFO',
        limit: 50,
        offset: 100,
      );

      expect(selectSql, contains('FROM v_all_logs'));
      expect(selectSql, contains('timestamp_us >= 1000'));
      expect(selectSql, contains('timestamp_us <= 2000'));
      expect(selectSql, contains("level IN ('INFO', 'CONFIG')"));
      expect(selectSql, contains("ILIKE '%test%'"));
      expect(selectSql, contains('LIMIT 50 OFFSET 100'));

      final countSql = LogQueryBuilder.buildCountSql(
        tableOrView: 'v_all_logs',
        keyword: 'test',
        timeRange: range,
        level: 'INFO',
      );
      expect(countSql, contains('SELECT COUNT(*) AS total FROM v_all_logs'));
      expect(countSql, contains("level IN ('INFO', 'CONFIG')"));
    });

    test('escapes single quotes in keyword to prevent syntax errors', () {
      final sql = LogQueryBuilder.buildSelectSql(
        tableOrView: 'api_exchanges',
        keyword: "test' OR '1'='1",
      );
      expect(sql, contains("''1''=''1"));
    });

    test('builds prune sql correctly', () {
      final before = DateTime.fromMicrosecondsSinceEpoch(5000000);
      final sql = LogQueryBuilder.buildPruneSql(
        table: 'api_exchanges',
        before: before,
      );
      expect(sql,
          equals('DELETE FROM api_exchanges WHERE timestamp_us < 5000000;'));
    });

    test('builds clear sql correctly', () {
      final sql = LogQueryBuilder.buildClearSql(table: 'system_logs');
      expect(sql, equals('DELETE FROM system_logs;'));
    });
  });
}
