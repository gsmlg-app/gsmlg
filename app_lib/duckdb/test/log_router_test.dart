import 'package:flutter_test/flutter_test.dart';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;

void main() {
  group('LogRouter', () {
    test('routes structured DNS SerializableLogRecord to DnsLogEntry', () {
      final record = SerializableLogRecord(
        level: logging.Level.INFO.value,
        levelName: 'INFO',
        message: 'Query A example.com',
        loggerName: 'DnsService',
        time: 1700000000000,
        isolateId: 'dns-worker-1',
        context: {
          'domain': 'example.com',
          'queryType': 'A',
          'clientIp': '192.168.1.100',
          'clientPort': 53535,
          'rcode': 'NOERROR',
          'latencyMs': 8,
          'cached': true,
        },
      );

      final routed = LogRouter.routeSerializable(record);
      expect(routed, isA<RoutedDnsLog>());
      final entry = (routed as RoutedDnsLog).entry;
      expect(entry.domain, equals('example.com'));
      expect(entry.queryType, equals('A'));
      expect(entry.clientIp, equals('192.168.1.100'));
      expect(entry.cached, isTrue);
    });

    test('routes regex fallback DNS log message to DnsLogEntry', () {
      final record = SerializableLogRecord(
        level: logging.Level.INFO.value,
        levelName: 'INFO',
        message: 'Response A google.com => 142.250.72.14 (NOERROR, 15ms)',
        loggerName: 'DnsWorker',
        time: 1700000000000,
        isolateId: 'dns-worker-1',
      );

      final routed = LogRouter.routeSerializable(record);
      expect(routed, isA<RoutedDnsLog>());
      final entry = (routed as RoutedDnsLog).entry;
      expect(entry.domain, equals('google.com'));
      expect(entry.queryType, equals('A'));
      expect(entry.rcode, equals('NOERROR'));
      expect(entry.latencyMs, equals(15));
    });

    test('routes DHCP log to DhcpLogEntry', () {
      final logRecord = logging.LogRecord(
        logging.Level.INFO,
        'DHCPACK on 192.168.1.55 to 00:11:22:33:44:55 via en0',
        'DhcpV4Server',
      );

      final routed = LogRouter.routeRoot(logRecord);
      expect(routed, isA<RoutedDhcpLog>());
      final entry = (routed as RoutedDhcpLog).entry;
      expect(entry.ipVersion, equals('IPv4'));
      expect(entry.messageType, equals('ACK'));
    });

    test('routes generic log to SystemLogEntry', () {
      final logRecord = logging.LogRecord(
        logging.Level.WARNING,
        'Database connection pool high usage',
        'AppDatabase',
      );

      final routed = LogRouter.routeRoot(logRecord);
      expect(routed, isA<RoutedSystemLog>());
      final entry = (routed as RoutedSystemLog).entry;
      expect(entry.level, equals('WARNING'));
      expect(entry.loggerName, equals('AppDatabase'));
    });
  });
}
