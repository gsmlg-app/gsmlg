import 'package:flutter_test/flutter_test.dart';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DuckDbLogOutput', () {
    final db = AppDuckDb.instance;

    setUp(() async {
      await db.open(inMemory: true);
      await db.ensureLogSchemas();
    });

    tearDown(() async {
      if (await db.isOpen) {
        await db.close();
      }
    });

    test('DuckDbLogOutput batches and flushes when buffer threshold reached',
        () async {
      final output = DuckDbLogOutput(
        duckDb: db,
        dnsThreshold: 5,
        systemThreshold: 5,
        dhcpThreshold: 5,
        flushInterval:
            const Duration(seconds: 10), // long interval to test count trigger
      );

      // Send 5 DNS records
      for (var i = 0; i < 5; i++) {
        output.write(
          SerializableLogRecord(
            level: logging.Level.INFO.value,
            levelName: 'INFO',
            message: 'Query A domain$i.com',
            loggerName: 'DnsService',
            time: 1700000000000 + i,
            isolateId: 'w1',
            context: {'domain': 'domain$i.com', 'queryType': 'A'},
          ),
          'formatted',
        );
      }

      await output.flush();

      final logs = await db.queryDnsLogs();
      expect(logs.length, equals(5));

      await output.close();
    });

    test('DuckDbLogOutput flushes automatically on periodic timer', () async {
      final output = DuckDbLogOutput(
        duckDb: db,
        dnsThreshold: 100,
        flushInterval: const Duration(milliseconds: 100),
      );

      output.write(
        SerializableLogRecord(
          level: logging.Level.INFO.value,
          levelName: 'INFO',
          message: 'Query A timer.com',
          loggerName: 'DnsService',
          time: 1700000000000,
          isolateId: 'w1',
          context: {'domain': 'timer.com'},
        ),
        'formatted',
      );

      // Wait 250ms for timer to trigger flush
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final logs = await db.queryDnsLogs();
      expect(logs.length, equals(1));
      expect(logs.first.domain, equals('timer.com'));

      await output.close();
    });
  });
}
