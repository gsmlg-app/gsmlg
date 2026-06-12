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
import 'tables/tts_dataset_clip.dart';
import 'tables/tts_dataset_project.dart';
import 'tables/tts_dataset_prompt.dart';
import 'tables/tts_dataset_speaker.dart';
import 'tables/tts_dataset_validation_issue.dart';
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
export 'tables/tts_dataset_clip.dart';
export 'tables/tts_dataset_project.dart';
export 'tables/tts_dataset_prompt.dart';
export 'tables/tts_dataset_speaker.dart';
export 'tables/tts_dataset_validation_issue.dart';
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
  TtsDatasetProjectTable,
  TtsDatasetSpeakerTable,
  TtsDatasetPromptTable,
  TtsDatasetClipTable,
  TtsDatasetValidationIssueTable,
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
  int get schemaVersion => 15;

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
        if (from < 8) {
          // Recreate dns_zone_table with serviceAccountId column,
          // replacing the old per-zone credentials field.
          await m.deleteTable('dns_zone_table');
          await m.createTable(dnsZoneTable);
        }
        if (from < 9) {
          await _addColumnIfMissing(
            m,
            chatMessageTable,
            chatMessageTable.imageBytes,
          );
          await _addColumnIfMissing(
            m,
            chatMessageTable,
            chatMessageTable.toolName,
          );
        }
        if (from < 10) {
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.inferenceMode,
          );
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.remoteProvider,
          );
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.remoteAccountId,
          );
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.remoteBaseUrl,
          );
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.remoteModel,
          );
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.remoteStreamingEnabled,
          );
        }
        if (from < 11) {
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.remoteThinkingEffort,
          );
        }
        if (from < 12) {
          await _addColumnIfMissing(
            m,
            chatMessageTable,
            chatMessageTable.responseOutputTokens,
          );
          await _addColumnIfMissing(
            m,
            chatMessageTable,
            chatMessageTable.responseContextTokens,
          );
          await _addColumnIfMissing(
            m,
            chatMessageTable,
            chatMessageTable.responseMaxOutputTokens,
          );
          await _addColumnIfMissing(
            m,
            chatMessageTable,
            chatMessageTable.responseDurationMs,
          );
        }
        if (from < 13) {
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.remoteApiType,
          );
          await customStatement(
            "UPDATE chat_settings_table SET remote_api_type = "
            "CASE WHEN remote_provider = 'openAi' THEN 'openAiResponses' "
            "ELSE 'openAiChatCompletions' END",
          );
        }
        if (from < 14) {
          await _addColumnIfMissing(
            m,
            chatSettingsTable,
            chatSettingsTable.localModelId,
          );
        }
        if (from < 15) {
          await m.createTable(ttsDatasetProjectTable);
          await m.createTable(ttsDatasetSpeakerTable);
          await m.createTable(ttsDatasetPromptTable);
          await m.createTable(ttsDatasetClipTable);
          await m.createTable(ttsDatasetValidationIssueTable);
        }
      },
    );
  }

  Future<void> _addColumnIfMissing(
    Migrator migrator,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final existing = await customSelect(
      'SELECT name FROM pragma_table_info(?) WHERE name = ? LIMIT 1',
      variables: [
        Variable.withString(table.actualTableName),
        Variable.withString(column.name),
      ],
    ).getSingleOrNull();

    if (existing == null) {
      await migrator.addColumn(table, column);
    }
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
    await (delete(monitorTrustedCertTable)..where((t) => t.hostId.equals(id)))
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
