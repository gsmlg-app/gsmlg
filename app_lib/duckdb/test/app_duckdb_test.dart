import 'dart:convert';
import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDuckDb', () {
    final db = AppDuckDb.instance;

    setUp(() async {
      await db.open(inMemory: true);
      await db.ensureLogSchema();
    });

    tearDown(() async {
      if (await db.isOpen) {
        await db.close();
      }
    });

    test('open and close in-memory database', () async {
      expect(await db.isOpen, isTrue);
      await db.close();
      expect(await db.isOpen, isFalse);
    });

    test('execute SQL and query JSON', () async {
      final rows = await db.execute(
        "CREATE TABLE test_table (id INT, name VARCHAR); INSERT INTO test_table VALUES (1, 'Alice'), (2, 'Bob');",
      );
      expect(rows, greaterThanOrEqualTo(0));

      final jsonStr = await db.queryJson(
        'SELECT * FROM test_table ORDER BY id ASC;',
      );
      final list = jsonDecode(jsonStr) as List<dynamic>;
      expect(list.length, equals(2));
      expect(list[0]['id'], equals(1));
      expect(list[0]['name'], equals('Alice'));
      expect(list[1]['id'], equals(2));
      expect(list[1]['name'], equals('Bob'));
    });

    test('append and query recent logs', () async {
      final entry = AppDuckDb.createLogEntry(
        id: 'log-1',
        level: 'INFO',
        loggerName: 'dns.server',
        message: 'DNS server started',
        queryType: 'A',
        domain: 'example.com',
        sourceIp: '127.0.0.1',
        status: 'NOERROR',
        latencyMs: 5,
        metadata: '{"cached":true}',
      );

      await db.appendLog(entry);

      final logs = await db.queryRecentLogs(limit: 10);
      expect(logs.length, equals(1));
      expect(logs[0].id, equals('log-1'));
      expect(logs[0].level, equals('INFO'));
      expect(logs[0].loggerName, equals('dns.server'));
      expect(logs[0].message, equals('DNS server started'));
      expect(logs[0].domain, equals('example.com'));
      expect(logs[0].latencyMs, equals(5));
    });

    test('batch append logs', () async {
      final entries = List.generate(
        100,
        (i) => AppDuckDb.createLogEntry(
          id: 'log-$i',
          level: i % 2 == 0 ? 'INFO' : 'DEBUG',
          loggerName: 'benchmark',
          message: 'Benchmark message $i',
        ),
      );

      final count = await db.batchAppendLogs(entries);
      expect(count, equals(100));

      final allLogs = await db.queryRecentLogs(limit: 200);
      expect(allLogs.length, equals(100));

      final infoLogs = await db.queryRecentLogs(limit: 200, level: 'INFO');
      expect(infoLogs.length, equals(50));
    });

    test('dedicated tables: batch append and query system, dns, and dhcp logs',
        () async {
      await db.ensureLogSchemas();

      final sysEntry = SystemLogEntry(
        id: 'sys-1',
        timestampUs: PlatformInt64Util.from(1000),
        level: 'INFO',
        loggerName: 'AppBloc',
        message: 'App initialized',
        isolateId: 'main',
        error: null,
        stackTrace: null,
        metadata: '{"key":"val"}',
      );
      await db.batchAppendSystemLogs([sysEntry]);

      final dnsEntry = DnsLogEntry(
        id: 'dns-1',
        timestampUs: PlatformInt64Util.from(2000),
        clientIp: '192.168.1.100',
        clientPort: 53535,
        protocol: 'UDP',
        queryType: 'A',
        domain: 'example.com',
        rcode: 'NOERROR',
        answers: '93.184.216.34',
        latencyMs: 12,
        cached: false,
        upstream: '1.1.1.1',
        status: 'SUCCESS',
      );
      await db.batchAppendDnsLogs([dnsEntry]);

      final dhcpEntry = DhcpLogEntry(
        id: 'dhcp-1',
        timestampUs: PlatformInt64Util.from(3000),
        ipVersion: 'IPv4',
        messageType: 'ACK',
        clientMac: '00:11:22:33:44:55',
        hostname: 'test-device',
        assignedIp: '192.168.1.150',
        leaseTimeSec: 86400,
        serverIp: '192.168.1.1',
        interfaceName: 'en0',
        status: 'ASSIGNED',
      );
      await db.batchAppendDhcpLogs([dhcpEntry]);

      final sysLogs = await db.querySystemLogs(limit: 10);
      expect(sysLogs.length, equals(1));
      expect(sysLogs.first.message, equals('App initialized'));

      final dnsLogs = await db.queryDnsLogs(limit: 10);
      expect(dnsLogs.length, equals(1));
      expect(dnsLogs.first.domain, equals('example.com'));

      final dhcpLogs = await db.queryDhcpLogs(limit: 10);
      expect(dhcpLogs.length, equals(1));
      expect(dhcpLogs.first.assignedIp, equals('192.168.1.150'));
    });
  });
}
