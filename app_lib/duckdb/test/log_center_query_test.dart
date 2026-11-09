import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter_test/flutter_test.dart';

SystemLogEntry _entry(String id, String level, String message) =>
    SystemLogEntry(
      id: id,
      timestampUs: PlatformInt64Util.from(
        DateTime(2026, 11, 9).microsecondsSinceEpoch,
      ),
      level: level,
      loggerName: 'AppLogger',
      message: message,
    );

void main() {
  final db = AppDuckDb.instance;

  setUp(() async {
    await db.open(inMemory: true);
    await db.ensureLogSchemas();
    await db.batchAppendSystemLogs([
      _entry('1', 'SEVERE', 'request failed'),
      _entry('2', 'FINE', 'debug detail'),
      _entry('3', 'INFO', 'app started'),
    ]);
  });

  tearDown(() => db.close());

  test('keyword search works on the unified v_all_logs view', () async {
    final rows = await db.queryLogs(
      tableOrView: 'v_all_logs',
      filter: const LogFilter(keyword: 'fail'),
    );
    expect(rows.map((r) => r.id), ['1']);
    expect(rows.single.logType, 'system');
  });

  test('UI level ERROR matches records stored as SEVERE', () async {
    final rows = await db.queryLogs(
      tableOrView: 'system_logs',
      filter: LogFilter(level: LogLevel.error.displayName),
    );
    expect(rows.map((r) => r.id), ['1']);
  });

  test('UI level DEBUG matches records stored as FINE', () async {
    expect(
      await db.countLogs(
        tableOrView: 'v_all_logs',
        filter: LogFilter(level: LogLevel.debug.displayName),
      ),
      1,
    );
  });
}
