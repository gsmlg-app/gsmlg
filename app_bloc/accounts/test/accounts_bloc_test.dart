import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:test/test.dart';

void main() {
  group('AccountsBloc', () {
    test('refresh marks accounts missing from vault', () async {
      final database = AppDatabase.forTesting();
      final vault = _MemoryVaultRepository();
      final bloc = AccountsBloc(database: database, vault: vault);
      addTearDown(bloc.close);
      addTearDown(database.close);

      final configuredId = await database
          .into(database.serviceAccountTable)
          .insert(
            ServiceAccountTableCompanion.insert(
              provider: ServiceProvider.openai,
              name: 'Configured',
            ),
          );
      final missingId = await database
          .into(database.serviceAccountTable)
          .insert(
            ServiceAccountTableCompanion.insert(
              provider: ServiceProvider.openai,
              name: 'Missing Secret',
            ),
          );
      await vault.write(key: 'service_account_$configuredId', value: 'secret');

      bloc.add(const AccountsRefresh());

      await expectLater(
        bloc.stream,
        emits(
          isA<AccountsLoaded>()
              .having((state) => state.accounts.length, 'accounts', 2)
              .having(
                (state) => state.missingSecretAccountIds,
                'missingSecretAccountIds',
                {missingId},
              ),
        ),
      );
    });

    test('load clears missing marker after secret is stored', () async {
      final database = AppDatabase.forTesting();
      final vault = _MemoryVaultRepository();
      final bloc = AccountsBloc(database: database, vault: vault);
      addTearDown(bloc.close);
      addTearDown(database.close);

      final accountId = await database
          .into(database.serviceAccountTable)
          .insert(
            ServiceAccountTableCompanion.insert(
              provider: ServiceProvider.openai,
              name: 'Backplane',
            ),
          );

      bloc.add(const AccountsLoad());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AccountsLoading>(),
          isA<AccountsLoaded>().having(
            (state) => state.missingSecretAccountIds,
            'missingSecretAccountIds',
            {accountId},
          ),
        ]),
      );

      await vault.write(key: 'service_account_$accountId', value: 'secret');
      bloc.add(const AccountsLoad());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AccountsLoading>(),
          isA<AccountsLoaded>().having(
            (state) => state.missingSecretAccountIds,
            'missingSecretAccountIds',
            isEmpty,
          ),
        ]),
      );
    });

    test(
      'does not persist account metadata when secret storage fails',
      () async {
        final database = AppDatabase.forTesting();
        final bloc = AccountsBloc(
          database: database,
          vault: _ThrowingVaultRepository(),
        );
        addTearDown(bloc.close);
        addTearDown(database.close);

        bloc.add(
          const AccountsAdd(
            provider: ServiceProvider.openai,
            name: 'Backplane',
            apiKey: 'secret',
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<AccountsLoading>(),
            isA<AccountsLoaded>()
                .having((state) => state.accounts, 'accounts', isEmpty)
                .having(
                  (state) => state.error,
                  'error',
                  contains('Failed to add account'),
                ),
          ]),
        );
        final accounts = await database
            .select(database.serviceAccountTable)
            .get();
        expect(accounts, isEmpty);
      },
    );
  });
}

class _MemoryVaultRepository implements VaultRepository {
  final Map<String, String> _storage = {};

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_storage);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }
}

class _ThrowingVaultRepository implements VaultRepository {
  @override
  Future<bool> containsKey({required String key}) async => false;

  @override
  Future<void> delete({required String key}) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<String?> read({required String key}) async => null;

  @override
  Future<Map<String, String>> readAll() async => const {};

  @override
  Future<void> write({required String key, required String value}) {
    throw StateError('secret storage unavailable');
  }
}
