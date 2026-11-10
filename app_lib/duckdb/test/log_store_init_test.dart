import 'dart:io';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';

/// The DuckDB connection is process-wide (one per loaded native library), so
/// the main isolate observes what the `logstore` worker leaves open.
void main() {
  late Directory dir;

  setUp(() async {
    await AppDuckDb.initialize();
    dir = await Directory.systemTemp.createTemp('logstore_init');
  });

  tearDown(() async {
    await AppDuckDb.instance.close();
    await dir.delete(recursive: true);
  });

  test('a failed schema setup closes the connection it opened', () async {
    // A legacy name that is a view makes `DROP TABLE IF EXISTS` fail after
    // the database was opened.
    final path = '${dir.path}/logs.duckdb';
    await AppDuckDb.instance.open(path: path);
    await AppDuckDb.instance.execute('CREATE VIEW dns_logs AS SELECT 1 AS a');
    await AppDuckDb.instance.close();

    final hub = IsolateHub();
    await hub.start();
    addTearDown(() => hub.stop(timeout: const Duration(seconds: 2)));
    await expectLater(
      hub.registerService(
        ChildSpec(
          name: 'logstore',
          entryPoint: logStoreEntryPoint,
          restartType: ChildRestartType.temporary,
          config: {'dbPath': path},
        ),
      ),
      throwsA(anything),
    );
    expect(await AppDuckDb.instance.isOpen, isFalse);
  });

  test('init replaces a connection left open in the process', () async {
    await AppDuckDb.instance.open(inMemory: true);
    await AppDuckDb.instance.execute('CREATE TABLE stale_marker (a INT)');

    final hub = IsolateHub();
    await hub.start();
    addTearDown(() => hub.stop(timeout: const Duration(seconds: 2)));
    await hub.registerService(
      ChildSpec(
        name: 'logstore',
        entryPoint: logStoreEntryPoint,
        restartType: ChildRestartType.temporary,
        config: {'dbPath': '${dir.path}/fresh.duckdb'},
      ),
    );
    final json = await LogStoreClient(hub).queryJson(
      "SELECT count(*) AS n FROM information_schema.tables "
      "WHERE table_name = 'stale_marker'",
    );
    expect(json, contains('"n":0'));
  });
}
