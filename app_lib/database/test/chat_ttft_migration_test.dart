import 'package:app_database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final columnExists in [false, true]) {
    test('upgrades v16 chat metrics with existing TTFT column: $columnExists',
        () async {
      final database = AppDatabase(NativeDatabase.memory(setup: (sqlite) {
        sqlite.execute('''
          CREATE TABLE chat_message_table (
            id TEXT NOT NULL PRIMARY KEY,
            conversation_id TEXT NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            token_count INTEGER NULL,
            response_output_tokens INTEGER NULL,
            response_context_tokens INTEGER NULL,
            response_max_output_tokens INTEGER NULL,
            response_duration_ms INTEGER NULL,
            ${columnExists ? 'response_time_to_first_token_ms INTEGER NULL,' : ''}
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
          VALUES ('legacy', 'conversation', 'assistant', 'saved',
                  42, 42, 512, 2048, 2000, 1767225600)
        ''');
        sqlite.execute(
            'CREATE TABLE chat_conversation_table (id TEXT PRIMARY KEY, title TEXT NOT NULL, system_prompt TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
        sqlite.execute(
            "INSERT INTO chat_conversation_table VALUES ('conversation', 'My legacy custom title', NULL, 1767225600, 1767225600)");
        sqlite.execute('PRAGMA user_version = 16');
      }));
      addTearDown(database.close);

      final row = await database.select(database.chatMessageTable).getSingle();
      expect(database.schemaVersion, 18);
      expect(row.id, 'legacy');
      expect(row.content, 'saved');
      expect(row.tokenCount, 42);
      expect(row.responseOutputTokens, 42);
      expect(row.responseContextTokens, 512);
      expect(row.responseMaxOutputTokens, 2048);
      expect(row.responseDurationMs, 2000);
      expect(row.responseTimeToFirstTokenMs, isNull);
      expect(row.timestamp, DateTime.fromMillisecondsSinceEpoch(1767225600000));
      final conversation =
          await database.select(database.chatConversationTable).getSingle();
      expect(conversation.title, 'My legacy custom title');
      expect(conversation.titleSource, 'manual');
      expect(conversation.titleRevision, 0);
      expect(conversation.contentRevision, 0);
      expect(row.completedSuccessfully, isFalse);
      final version =
          await database.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 18);
    });
  }
}
