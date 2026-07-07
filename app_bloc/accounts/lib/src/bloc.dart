import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'event.dart';
part 'state.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc({required AppDatabase database, required VaultRepository vault})
    : _db = database,
      _vault = vault,
      super(const AccountsInitial()) {
    on<AccountsLoad>(_onLoad);
    on<AccountsRefresh>(_onRefresh);
    on<AccountsAdd>(_onAdd);
    on<AccountsUpdate>(_onUpdate);
    on<AccountsUpdateApiKey>(_onUpdateApiKey);
    on<AccountsDelete>(_onDelete);
  }

  final AppDatabase _db;
  final VaultRepository _vault;

  /// Vault key prefix for service account credentials.
  static const String _keyPrefix = 'service_account_';

  String _vaultKey(int id) => '$_keyPrefix$id';

  Future<AccountsLoaded> _loadAccountsWithSecrets() async {
    final accounts = await _db.select(_db.serviceAccountTable).get();
    final secrets = await _vault.readAll();
    final missingSecretAccountIds = <int>{};

    for (final account in accounts) {
      final secret = secrets[_vaultKey(account.id)];
      if (secret == null || secret.isEmpty) {
        missingSecretAccountIds.add(account.id);
      }
    }

    return AccountsLoaded(
      accounts: accounts,
      missingSecretAccountIds: missingSecretAccountIds,
    );
  }

  Future<void> _onLoad(AccountsLoad event, Emitter<AccountsState> emit) async {
    emit(const AccountsLoading());

    try {
      emit(await _loadAccountsWithSecrets());
    } catch (e) {
      emit(AccountsError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    AccountsRefresh event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;

    try {
      emit(await _loadAccountsWithSecrets());
    } catch (e) {
      if (currentState is AccountsLoaded) {
        emit(
          AccountsLoaded(
            accounts: currentState.accounts,
            missingSecretAccountIds: currentState.missingSecretAccountIds,
            error: 'Failed to refresh accounts: ${e.toString()}',
          ),
        );
      } else {
        emit(AccountsError(message: e.toString()));
      }
    }
  }

  Future<void> _onAdd(AccountsAdd event, Emitter<AccountsState> emit) async {
    final currentState = state;
    final currentAccounts = currentState is AccountsLoaded
        ? currentState.accounts
        : <ServiceAccountTableData>[];
    final currentMissingSecretAccountIds = currentState is AccountsLoaded
        ? currentState.missingSecretAccountIds
        : const <int>{};

    emit(const AccountsLoading());

    try {
      await _db.transaction(() async {
        final id = await _db
            .into(_db.serviceAccountTable)
            .insert(
              ServiceAccountTableCompanion.insert(
                provider: event.provider,
                name: event.name,
                description: Value(event.description),
              ),
            );
        await _vault.write(key: _vaultKey(id), value: event.apiKey);
        return id;
      });

      emit(await _loadAccountsWithSecrets());
    } catch (e) {
      emit(
        AccountsLoaded(
          accounts: currentAccounts,
          missingSecretAccountIds: currentMissingSecretAccountIds,
          error: 'Failed to add account: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdate(
    AccountsUpdate event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    try {
      await (_db.update(
        _db.serviceAccountTable,
      )..where((t) => t.id.equals(event.id))).write(
        ServiceAccountTableCompanion(
          name: Value(event.name),
          description: Value(event.description),
          updatedAt: Value(DateTime.now()),
        ),
      );

      emit(await _loadAccountsWithSecrets());
    } catch (e) {
      emit(
        AccountsLoaded(
          accounts: currentState.accounts,
          missingSecretAccountIds: currentState.missingSecretAccountIds,
          error: 'Failed to update account: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateApiKey(
    AccountsUpdateApiKey event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    try {
      await _vault.write(key: _vaultKey(event.id), value: event.apiKey);

      await (_db.update(
        _db.serviceAccountTable,
      )..where((t) => t.id.equals(event.id))).write(
        ServiceAccountTableCompanion(updatedAt: Value(DateTime.now())),
      );

      emit(await _loadAccountsWithSecrets());
    } catch (e) {
      emit(
        AccountsLoaded(
          accounts: currentState.accounts,
          missingSecretAccountIds: currentState.missingSecretAccountIds,
          error: 'Failed to update API key: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDelete(
    AccountsDelete event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    try {
      await _vault.delete(key: _vaultKey(event.id));

      await (_db.delete(
        _db.serviceAccountTable,
      )..where((t) => t.id.equals(event.id))).go();

      emit(await _loadAccountsWithSecrets());
    } catch (e) {
      emit(
        AccountsLoaded(
          accounts: currentState.accounts,
          missingSecretAccountIds: currentState.missingSecretAccountIds,
          error: 'Failed to delete account: ${e.toString()}',
        ),
      );
    }
  }

  /// Read the API key for a service account.
  Future<String?> getApiKey(int accountId) async {
    return _vault.read(key: _vaultKey(accountId));
  }
}
