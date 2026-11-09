import 'package:flutter_test/flutter_test.dart';
import 'package:app_duckdb/app_duckdb.dart';

void main() {
  group('LogRecordItem.fromMap', () {
    test('parses from v_all_logs row map', () {
      final map = {
        'id': 'log-1',
        'log_type': 'dns',
        'timestamp_us': 1762700000000000,
        'level': 'INFO',
        'message': 'baidu.com. A => 180.101.50.242',
        'details': '{"domain": "baidu.com.", "latency_ms": 12}',
      };

      final item = LogRecordItem.fromMap(map);
      expect(item.id, equals('log-1'));
      expect(item.logType, equals('dns'));
      expect(item.level, equals(LogLevel.info));
      expect(item.message, equals('baidu.com. A => 180.101.50.242'));
      expect(item.timestamp.microsecondsSinceEpoch, equals(1762700000000000));
    });

    test('parses from dns_logs row map', () {
      final map = {
        'id': 'dns-1',
        'timestamp_us': 1762700000000000,
        'query_type': 'AAAA',
        'domain': 'google.com.',
        'client_ip': '192.168.1.10',
        'rcode': 'NoError',
        'answers': '2607:f8b0:4005:805::200e',
        'latency_ms': 18,
        'cached': true,
        'status': 'cached',
      };

      final item = LogRecordItem.fromMap(map, defaultType: 'dns');
      expect(item.id, equals('dns-1'));
      expect(item.logType, equals('dns'));
      expect(item.clientAddress, equals('192.168.1.10'));
      expect(item.latencyMs, equals(18));
      expect(item.status, equals('NoError'));
      expect(item.message, contains('AAAA google.com.'));
    });

    test('parses from dhcp_logs row map', () {
      final map = {
        'id': 'dhcp-1',
        'timestamp_us': 1762700000000000,
        'message_type': 'ACK',
        'client_mac': 'aa:bb:cc:dd:ee:ff',
        'assigned_ip': '192.168.1.100',
        'hostname': 'my-macbook',
        'status': 'ACK',
      };

      final item = LogRecordItem.fromMap(map, defaultType: 'dhcp');
      expect(item.id, equals('dhcp-1'));
      expect(item.logType, equals('dhcp'));
      expect(item.clientAddress, equals('aa:bb:cc:dd:ee:ff'));
      expect(item.message, contains('ACK 192.168.1.100'));
      expect(item.message, contains('(my-macbook)'));
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
