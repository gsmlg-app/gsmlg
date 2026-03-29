import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/chat_conversation.dart';
import 'tables/chat_message.dart';
import 'tables/chat_settings.dart';
import 'tables/dns_zone.dart';
import 'tables/github_repo.dart';
import 'tables/monitor_host.dart';
import 'tables/monitor_trusted_cert.dart';
import 'tables/service_account.dart';
import 'tables/whois_history.dart';
import 'type_converter.dart';

export 'tables/chat_conversation.dart';
export 'tables/chat_message.dart';
export 'tables/chat_settings.dart';
export 'tables/dns_zone.dart';
export 'tables/github_repo.dart';
export 'tables/monitor_host.dart';
export 'tables/monitor_trusted_cert.dart';
export 'tables/service_account.dart';
export 'tables/whois_history.dart';
export 'type_converter.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  WhoisHistoryTable,
  DnsZoneTable,
  GitHubRepoTable,
  ChatConversationTable,
  ChatMessageTable,
  ChatSettingsTable,
  ServiceAccountTable,
  MonitorHostTable,
  MonitorTrustedCertTable,
])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  // Add this factory for tests
  factory AppDatabase.forTesting() {
    return AppDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(dnsZoneTable);
        }
        if (from < 3) {
          await m.createTable(gitHubRepoTable);
        }
        if (from < 4) {
          await m.createTable(chatConversationTable);
          await m.createTable(chatMessageTable);
          await m.createTable(chatSettingsTable);
        }
        if (from < 5) {
          // v5 had an earlier version of this table; drop it for v6.
          await m.createTable(serviceAccountTable);
        }
        if (from < 6) {
          // Recreate service_account_table with name + description columns.
          await m.deleteTable('service_account_table');
          await m.createTable(serviceAccountTable);
        }
        if (from < 7) {
          await m.createTable(monitorHostTable);
          await m.createTable(monitorTrustedCertTable);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Monitor host methods
  // ---------------------------------------------------------------------------

  /// Watch all monitor hosts, ordered by creation date.
  Stream<List<MonitorHostTableData>> watchMonitorHosts() {
    return (select(monitorHostTable)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Get all monitor hosts.
  Future<List<MonitorHostTableData>> getMonitorHosts() {
    return (select(monitorHostTable)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Insert or replace a monitor host.
  Future<void> insertMonitorHost(MonitorHostTableCompanion entry) {
    return into(monitorHostTable).insertOnConflictUpdate(entry);
  }

  /// Delete a monitor host (and its pinned cert via cascade).
  Future<void> deleteMonitorHost(String id) async {
    // Remove trusted cert first (foreign key).
    await (delete(monitorTrustedCertTable)
          ..where((t) => t.hostId.equals(id)))
        .go();
    await (delete(monitorHostTable)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Monitor trusted cert methods
  // ---------------------------------------------------------------------------

  /// Get the pinned fingerprint for a host, or null if none.
  Future<String?> getPinnedFingerprint(String hostId) async {
    final row = await (select(monitorTrustedCertTable)
          ..where((t) => t.hostId.equals(hostId)))
        .getSingleOrNull();
    return row?.fingerprint;
  }

  /// Pin (insert or update) a fingerprint for a host.
  Future<void> pinFingerprint(String hostId, String fingerprint) {
    return into(monitorTrustedCertTable).insertOnConflictUpdate(
      MonitorTrustedCertTableCompanion.insert(
        hostId: hostId,
        fingerprint: fingerprint,
      ),
    );
  }

  /// Remove a pinned fingerprint for a host.
  Future<void> removePinnedFingerprint(String hostId) {
    return (delete(monitorTrustedCertTable)
          ..where((t) => t.hostId.equals(hostId)))
        .go();
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'flutter_app_template',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
