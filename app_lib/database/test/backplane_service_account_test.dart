import 'package:app_database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists and reads backplane provider by enum name', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.into(database.serviceAccountTable).insert(
          ServiceAccountTableCompanion.insert(
            provider: ServiceProvider.backplane,
            name: 'Backplane token',
          ),
        );

    final account =
        await database.select(database.serviceAccountTable).getSingle();
    final providerText = await database
        .customSelect('SELECT provider FROM service_account_table')
        .getSingle();

    expect(account.provider, ServiceProvider.backplane);
    expect(providerText.read<String>('provider'), 'backplane');
  });

  test('preserves existing provider names and account IDs', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    const existingProviders = {
      'openai': ServiceProvider.openai,
      'anthropic': ServiceProvider.anthropic,
      'ollama': ServiceProvider.ollama,
      'github': ServiceProvider.github,
      'vultr': ServiceProvider.vultr,
      'aws': ServiceProvider.aws,
      'cloudflare': ServiceProvider.cloudflare,
      'huggingface': ServiceProvider.huggingface,
    };

    for (final entry in existingProviders.entries.indexed) {
      await database.customStatement(
        'INSERT INTO service_account_table (id, provider, name) VALUES (?, ?, ?)',
        [entry.$1 + 1, entry.$2.key, entry.$2.key],
      );
    }

    final accounts = await database.select(database.serviceAccountTable).get();
    for (final entry in existingProviders.entries.indexed) {
      final account =
          accounts.singleWhere((account) => account.name == entry.$2.key);
      expect(account.id, entry.$1 + 1);
      expect(account.provider, entry.$2.value);
    }
    expect(
      ServiceProvider.values.map((provider) => provider.name),
      [...existingProviders.keys, 'backplane'],
    );
  });
}
