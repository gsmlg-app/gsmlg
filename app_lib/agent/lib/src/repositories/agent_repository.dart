import 'dart:convert';

import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/agent_definition.dart';

/// Persists [AgentDefinition]s in the app database.
class AgentRepository {
  AgentRepository(this._db);

  final AppDatabase _db;

  static const legacyAgentsKey = 'chat_agents';
  static const migratedFlagKey = 'agents_migrated_v1';

  Future<List<AgentDefinition>> list() async {
    final rows = await (_db.select(
      _db.agentDefinitionTable,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return rows.map(_fromRow).toList();
  }

  Future<AgentDefinition?> get(String id) async {
    final row = await (_db.select(
      _db.agentDefinitionTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<void> save(AgentDefinition agent) {
    return _db
        .into(_db.agentDefinitionTable)
        .insertOnConflictUpdate(
          AgentDefinitionTableCompanion(
            id: Value(agent.id),
            name: Value(agent.name),
            avatar: Value(agent.avatar),
            description: Value(agent.description),
            instructions: Value(agent.instructions),
            config: Value(jsonEncode(modelConfigToJson(agent.config))),
            thinkingEnabled: Value(agent.thinkingEnabled),
            allowedTools: Value(
              agent.allowedTools == null
                  ? null
                  : jsonEncode(agent.allowedTools),
            ),
            createdAt: Value(agent.createdAt),
            updatedAt: Value(agent.updatedAt),
          ),
        );
  }

  Future<void> delete(String id) async {
    await (_db.delete(
      _db.agentDefinitionTable,
    )..where((t) => t.id.equals(id))).go();
  }

  /// One-time import of agents stored as JSON strings under `chat_agents`.
  /// Preserves ids; unparseable entries are skipped. The legacy key is left
  /// in place for rollback.
  Future<void> importLegacy(SharedPreferences prefs) async {
    if (prefs.getBool(migratedFlagKey) ?? false) return;
    final now = DateTime.now();
    for (final raw in prefs.getStringList(legacyAgentsKey) ?? const []) {
      try {
        final json = (jsonDecode(raw) as Map).cast<String, Object?>();
        await save(
          AgentDefinition(
            id: json['id'] as String,
            name: json['name'] as String,
            instructions: json['systemPrompt'] as String?,
            config: modelConfigFromJson(
              (json['config'] as Map?)?.cast<String, Object?>(),
            ),
            thinkingEnabled: json['thinkingEnabled'] as bool? ?? false,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } catch (_) {
        continue;
      }
    }
    await prefs.setBool(migratedFlagKey, true);
  }

  AgentDefinition _fromRow(AgentDefinitionTableData row) {
    return AgentDefinition(
      id: row.id,
      name: row.name,
      avatar: row.avatar,
      description: row.description,
      instructions: row.instructions,
      config: modelConfigFromJson(
        (jsonDecode(row.config) as Map).cast<String, Object?>(),
      ),
      thinkingEnabled: row.thinkingEnabled,
      allowedTools: row.allowedTools == null
          ? null
          : (jsonDecode(row.allowedTools!) as List).cast<String>(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
