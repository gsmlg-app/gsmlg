import 'package:app_database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades v20 to v21 keeping conversations and adding agents', () async {
    final database = AppDatabase(NativeDatabase.memory(setup: (sqlite) {
      sqlite.execute('''
        CREATE TABLE chat_conversation_table (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          system_prompt TEXT,
          title_source TEXT NOT NULL DEFAULT 'manual',
          title_revision INTEGER NOT NULL DEFAULT 0,
          content_revision INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      sqlite.execute(
        "INSERT INTO chat_conversation_table VALUES ('conv_1', 'Legacy Chat', NULL, 'manual', 0, 0, 1767225600, 1767225600)",
      );
      sqlite.execute('PRAGMA user_version = 20');
    }));
    addTearDown(database.close);

    expect(database.schemaVersion, 21);
    final row =
        await database.select(database.chatConversationTable).getSingle();
    expect(row.id, 'conv_1');
    expect(row.agentId, isNull);

    await database.into(database.agentDefinitionTable).insert(
          AgentDefinitionTableCompanion.insert(
            id: 'a1',
            name: 'Bot',
            config: '{}',
          ),
        );
    final agent =
        await database.select(database.agentDefinitionTable).getSingle();
    expect(agent.name, 'Bot');
    expect(agent.allowedTools, isNull);
    expect(agent.thinkingEnabled, isFalse);
  });
}
