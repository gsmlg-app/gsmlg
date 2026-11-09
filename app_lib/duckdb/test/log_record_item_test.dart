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

    test('api row without host keeps a space before the path', () {
      final item = LogRecordItem.fromMap({
        'id': 'a1',
        'timestamp_us': 1,
        'record_json': '{}',
        'method': 'POST',
        'host': null,
        'path': '/p',
        'status': 200,
      });
      expect(item.message, 'POST /p');
      final full = LogRecordItem.fromMap({
        'id': 'a2',
        'timestamp_us': 1,
        'record_json': '{}',
        'method': 'GET',
        'host': 'h.com',
        'path': '/x',
      });
      expect(full.message, 'GET h.com/x');
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

    test('usage rows get a readable one-line message', () {
      LogRecordItem item(Map<String, dynamic> m) => LogRecordItem.fromMap({
            'id': 'u',
            'timestamp_us': 1762700000000000,
            'session_id': 's',
            ...m,
          }, defaultType: 'usage');

      expect(
        item({
          'event_type': 'screen_view',
          'module': 'Toolbox',
          'screen_name': 'Whois',
          'duration_ms': 5000,
        }).message,
        'screen_view Toolbox · Whois · 5.0s',
      );
      expect(
        item({'event_type': 'menu_tap', 'target': 'Whois'}).message,
        'menu_tap → Whois',
      );
      expect(item({'event_type': 'session_start'}).message, 'session_start');
    });
  });
}
