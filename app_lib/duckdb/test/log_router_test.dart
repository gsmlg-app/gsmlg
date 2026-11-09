import 'package:flutter_test/flutter_test.dart';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;

void main() {
  group('LogRouter', () {
    test('all records route to system logs', () {
      final serializable = LogRouter.routeSerializable(
        SerializableLogRecord(
          level: logging.Level.INFO.value,
          levelName: 'INFO',
          message: 'Query A example.com',
          loggerName: 'DnsService',
          time: 1700000000000,
          isolateId: 'dns-worker-1',
          context: {'domain': 'example.com', 'protocol': 'DNS'},
        ),
      );
      expect(serializable, isA<RoutedSystemLog>());
      expect((serializable as RoutedSystemLog).entry.loggerName,
          equals('DnsService'));

      final root = LogRouter.routeRoot(
        logging.LogRecord(
          logging.Level.INFO,
          'DHCPACK on 192.168.1.55 to 00:11:22:33:44:55 via en0',
          'DhcpV4Server',
        ),
      );
      expect(root, isA<RoutedSystemLog>());
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
