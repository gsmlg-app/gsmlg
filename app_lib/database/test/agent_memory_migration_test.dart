import 'package:app_database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades v21 to v22 keeping agents and adding agent_memory', () async {
    final database = AppDatabase(NativeDatabase.memory(setup: (sqlite) {
      sqlite.execute('''
        CREATE TABLE agent_definition_table (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          avatar TEXT,
          description TEXT,
          instructions TEXT,
          config TEXT NOT NULL,
          thinking_enabled INTEGER NOT NULL DEFAULT 0,
          allowed_tools TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      sqlite.execute(
        "INSERT INTO agent_definition_table VALUES ('a1', 'Bot', NULL, NULL, NULL, '{}', 0, NULL, 1767225600, 1767225600)",
      );
      sqlite.execute('PRAGMA user_version = 21');
    }));
    addTearDown(database.close);

    expect(database.schemaVersion, 24);
    final agent =
        await database.select(database.agentDefinitionTable).getSingle();
    expect(agent.id, 'a1');

    await database.into(database.agentMemoryTable).insert(
          AgentMemoryTableCompanion.insert(
            id: 'mem_1',
            scope: 'global',
            content: 'User prefers dark mode',
            contentHash: 'abc123',
          ),
        );
    final memory = await database.select(database.agentMemoryTable).getSingle();
    expect(memory.id, 'mem_1');
    expect(memory.scope, 'global');
    expect(memory.content, 'User prefers dark mode');
    expect(memory.provenance, 'agent_inference');
    expect(memory.metadataJson, '{}');
  });
}
