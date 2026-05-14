import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades legacy chat schema when response columns already exist',
      () async {
    final database = AppDatabase(_legacyV11DatabaseWithResponseColumns());
    addTearDown(database.close);

    await database.customSelect('SELECT 1').get();

    expect(
      await _columnNames(database, 'chat_message_table'),
      containsAll({
        'response_output_tokens',
        'response_context_tokens',
        'response_max_output_tokens',
        'response_duration_ms',
      }),
    );
    expect(
      await _columnNames(database, 'chat_settings_table'),
      contains('remote_api_type'),
    );
  });
}

NativeDatabase _legacyV11DatabaseWithResponseColumns() {
  return NativeDatabase.memory(
    setup: (database) {
      database.execute('''
        CREATE TABLE chat_message_table (
          id TEXT NOT NULL PRIMARY KEY,
          conversation_id TEXT NOT NULL,
          role TEXT NOT NULL,
          content TEXT NOT NULL,
          token_count INTEGER NULL,
          image_bytes BLOB NULL,
          tool_name TEXT NULL,
          response_output_tokens INTEGER NULL,
          response_context_tokens INTEGER NULL,
          response_max_output_tokens INTEGER NULL,
          response_duration_ms INTEGER NULL,
          timestamp INTEGER NOT NULL
        );
      ''');
      database.execute('''
        CREATE TABLE chat_settings_table (
          key TEXT NOT NULL PRIMARY KEY DEFAULT 'default',
          inference_mode TEXT NOT NULL DEFAULT 'local',
          model_type TEXT NOT NULL DEFAULT 'gemma2bIt',
          custom_model_path TEXT NULL,
          max_tokens INTEGER NOT NULL DEFAULT 2048,
          temperature_x100 INTEGER NOT NULL DEFAULT 80,
          top_k INTEGER NOT NULL DEFAULT 40,
          backend TEXT NOT NULL DEFAULT 'gpu',
          remote_provider TEXT NOT NULL DEFAULT 'openAiCompatible',
          remote_account_id INTEGER NULL,
          remote_base_url TEXT NOT NULL DEFAULT 'https://api.openai.com/v1',
          remote_model TEXT NOT NULL DEFAULT 'gpt-4.1-mini',
          remote_streaming_enabled INTEGER NOT NULL DEFAULT 1,
          remote_thinking_effort TEXT NOT NULL DEFAULT 'off',
          default_system_prompt TEXT NULL
        );
      ''');
      database.execute('PRAGMA user_version = 11');
    },
  );
}

Future<Set<String>> _columnNames(AppDatabase database, String tableName) async {
  final rows = await database.customSelect(
    'SELECT name FROM pragma_table_info(?)',
    variables: [Variable.withString(tableName)],
  ).get();

  return rows.map((row) => row.read<String>('name')).toSet();
}
