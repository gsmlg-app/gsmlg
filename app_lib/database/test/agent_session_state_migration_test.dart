import 'package:app_database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades schema v23 to v24 creating agent_session_state_table',
      () async {
    final db = AppDatabase(NativeDatabase.memory(setup: (sqlite) {
      sqlite.execute('''
        CREATE TABLE chat_conversation_table (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          title_source TEXT NOT NULL DEFAULT 'manual',
          title_revision INTEGER NOT NULL DEFAULT 0,
          content_revision INTEGER NOT NULL DEFAULT 0,
          system_prompt TEXT NULL,
          agent_id TEXT NULL,
          created_at INTEGER NOT NULL DEFAULT 0,
          updated_at INTEGER NOT NULL DEFAULT 0
        );
      ''');
      sqlite.execute(
        "INSERT INTO chat_conversation_table (id, title) VALUES ('sess-1', 'Existing');",
      );
      sqlite.execute('PRAGMA user_version = 23;');
    }));
    addTearDown(db.close);

    expect(db.schemaVersion, 24);
    await db.into(db.agentSessionStateTable).insert(
          AgentSessionStateTableCompanion.insert(
            sessionId: 'sess-1',
            stateJson: '{"version":1,"sessionId":"sess-1"}',
          ),
        );

    final row = await (db.select(db.agentSessionStateTable)
          ..where((t) => t.sessionId.equals('sess-1')))
        .getSingle();
    expect(row.stateJson, '{"version":1,"sessionId":"sess-1"}');

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 24);
  });
}
