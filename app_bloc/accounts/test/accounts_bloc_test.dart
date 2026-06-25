import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:test/test.dart';

void main() {
  group('AccountsBloc', () {
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
