import 'package:flutter_test/flutter_test.dart';
import 'package:app_duckdb/app_duckdb.dart';

void main() {
  group('LogRecordItem.fromMap', () {
    test('parses from v_all_logs row map', () {
      final map = {
        'id': 'log-1',
        'log_type': 'api',
        'timestamp_us': 1762700000000000,
        'level': 'INFO',
        'message': 'baidu.com. A => 180.101.50.242',
        'details': '{"domain": "baidu.com.", "latency_ms": 12}',
      };

      final item = LogRecordItem.fromMap(map);
      expect(item.id, equals('log-1'));
      expect(item.logType, equals('api'));
      expect(item.level, equals(LogLevel.info));
      expect(item.message, equals('baidu.com. A => 180.101.50.242'));
      expect(item.timestamp.microsecondsSinceEpoch, equals(1762700000000000));
    });

    test('parses from system_logs row map', () {
      final map = {
        'id': 'sys-1',
        'timestamp_us': 1762700000000000,
        'level': 'WARNING',
        'logger_name': 'isolate_pool',
        'message': 'worker restarted',
        'isolate_id': 'worker-2',
      };

      final item = LogRecordItem.fromMap(map, defaultType: 'system');
      expect(item.id, equals('sys-1'));
      expect(item.logType, equals('system'));
      expect(item.level, equals(LogLevel.warning));
      expect(item.loggerName, equals('isolate_pool'));
      expect(item.clientAddress, equals('worker-2'));
    });
  });
}
