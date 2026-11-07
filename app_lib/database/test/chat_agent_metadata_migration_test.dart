import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades schema to v20 and adds agent_metadata column', () async {
    final database = AppDatabase(NativeDatabase.memory(setup: (sqlite) {
      sqlite.execute('''
        CREATE TABLE chat_message_table (
          id TEXT NOT NULL PRIMARY KEY,
          conversation_id TEXT NOT NULL,
          role TEXT NOT NULL,
          content TEXT NOT NULL,
          completed_successfully INTEGER NOT NULL DEFAULT 0,
          token_count INTEGER NULL,
          response_output_tokens INTEGER NULL,
          response_context_tokens INTEGER NULL,
          response_max_output_tokens INTEGER NULL,
          response_duration_ms INTEGER NULL,
          response_time_to_first_token_ms INTEGER NULL,
          image_bytes BLOB NULL,
          tool_name TEXT NULL,
          timestamp INTEGER NOT NULL
        )
      ''');
      sqlite.execute('''
        INSERT INTO chat_message_table
          (id, conversation_id, role, content, token_count,
           response_output_tokens, response_context_tokens,
           response_max_output_tokens, response_duration_ms, timestamp)
        VALUES ('legacy_msg_1', 'conv_1', 'assistant', 'historical output',
                10, 10, 50, 100, 500, 1767225600)
      ''');
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
      sqlite.execute('PRAGMA user_version = 19');
    }));
    addTearDown(database.close);

    expect(database.schemaVersion, 20);
    final row = await database.select(database.chatMessageTable).getSingle();
    expect(row.id, 'legacy_msg_1');
    expect(row.content, 'historical output');
    expect(row.agentMetadata, isNull);

    // Verify inserting a message with agentMetadata works
    await database.into(database.chatMessageTable).insert(
          ChatMessageTableCompanion.insert(
            id: 'agent_msg_2',
            conversationId: 'conv_1',
            role: 'assistant',
            content: 'I called tools',
            timestamp: Value(DateTime.now()),
            agentMetadata: Value('{"toolCalls":[{"id":"c1","name":"lookup"}]}'),
          ),
        );

    final inserted = await (database.select(database.chatMessageTable)
          ..where((t) => t.id.equals('agent_msg_2')))
        .getSingle();
    expect(
        inserted.agentMetadata, '{"toolCalls":[{"id":"c1","name":"lookup"}]}');

    final version =
        await database.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 20);
  });
}
