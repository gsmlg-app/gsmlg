import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';

class _ControlledVault extends SecureStorageVaultRepository {
  bool failWrites = false;
  Completer<void>? writeGate;
  Completer<void>? readGate;
  final writeStarted = Completer<void>();
  final readStarted = Completer<void>();

  @override
  Future<void> write({required String key, required String value}) async {
    if (!writeStarted.isCompleted) writeStarted.complete();
    await writeGate?.future;
    if (failWrites) throw StateError('Vault unavailable');
    await super.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    if (!readStarted.isCompleted) readStarted.complete();
    await readGate?.future;
    return super.read(key: key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('private keys and passphrases are persisted as vault references',
      () async {
    final database = AppDatabase.forTesting();
    final bloc = SshKeyBloc(database);
    addTearDown(bloc.close);
    addTearDown(database.close);
    final loaded = bloc.stream.firstWhere((state) => state is SshKeyLoaded);
    bloc.add(const SshKeyAdd(
      name: 'Key',
      content: 'private-key-content',
      password: 'passphrase',
    ));
    await loaded;

    final row = await database.select(database.sshKeys).getSingle();
    expect(row.content, startsWith('vault:ssh:'));
    expect(row.password, startsWith('vault:ssh:'));
    expect(row.salt, isNull);
  });

  test('key form reports a persistence failure instead of success', () async {
    final database = AppDatabase.forTesting();
    final vault = _ControlledVault()..failWrites = true;
    final bloc = SshKeyBloc(
      database,
      credentials: SshCredentialRepository(database, vault: vault),
    );
    final form = SshKeyFormBloc(bloc);
    addTearDown(form.close);
    addTearDown(bloc.close);
    form.content.updateValue('private-key-content');
    addTearDown(database.close);
    final completed = form.stream.firstWhere(
      (state) => state is FormBlocSuccess || state is FormBlocFailure,
    );
    form.onSubmitting();
    expect(await completed, isA<FormBlocFailure>());
  });

  test('key form waits for vault persistence before reporting success',
      () async {
    final database = AppDatabase.forTesting();
    final vault = _ControlledVault()..writeGate = Completer<void>();
    final bloc = SshKeyBloc(database,
        credentials: SshCredentialRepository(database, vault: vault));
    final form = SshKeyFormBloc(bloc);
    addTearDown(database.close);
    addTearDown(bloc.close);
    addTearDown(form.close);
    form.content.updateValue('private-key');
    final completed = form.stream.firstWhere(
        (state) => state is FormBlocSuccess || state is FormBlocFailure);
    form.onSubmitting();
    await vault.writeStarted.future;
    expect(form.state, isNot(isA<FormBlocSuccess>()));
    vault.writeGate!.complete();
    expect(await completed, isA<FormBlocSuccess>());
    final row = await database.select(database.sshKeys).getSingle();
    expect(await bloc.credentials.readPrivateKey(row), 'private-key');
  });

  test('key editing loads plaintext and preserves later user input', () async {
    final database = AppDatabase.forTesting();
    final vault = _ControlledVault();
    final bloc = SshKeyBloc(database,
        credentials: SshCredentialRepository(database, vault: vault));
    final form = SshKeyFormBloc(bloc);
    addTearDown(database.close);
    addTearDown(bloc.close);
    addTearDown(form.close);
    const pem = '-----BEGIN PRIVATE KEY-----\nkey\n-----END PRIVATE KEY-----';
    await bloc.credentials
        .addKey(SshKeysCompanion.insert(content: const Value(pem)));
    final row = await database.select(database.sshKeys).getSingle();
    expect(row.content, startsWith('vault:ssh:'));
    vault.readGate = Completer<void>();
    final loading = form.setSshKey(row);
    expect(form.content.value, isEmpty);
    await vault.readStarted.future;
    form.content.updateValue('later input');
    vault.readGate!.complete();
    await loading;
    expect(form.content.value, 'later input');
    await form.setSshKey(row);
    expect(form.content.value, pem);
  });

  test('changing selection discards a pending private key load', () async {
    final database = AppDatabase.forTesting();
    final vault = _ControlledVault()..readGate = Completer<void>();
    final bloc = SshKeyBloc(database,
        credentials: SshCredentialRepository(database, vault: vault));
    final form = SshKeyFormBloc(bloc);
    addTearDown(database.close);
    addTearDown(bloc.close);
    addTearDown(form.close);
    await bloc.credentials
        .addKey(SshKeysCompanion.insert(content: const Value('private-key')));
    final row = await database.select(database.sshKeys).getSingle();
    final loading = form.setSshKey(row);
    await vault.readStarted.future;
    await form.setSshKey(null);
    vault.readGate!.complete();
    await loading;
    expect(form.content.value, isEmpty);
  });

  test('key migration failure emits error and preserves the legacy row',
      () async {
    final database = AppDatabase.forTesting();
    final vault = _ControlledVault()..failWrites = true;
    final bloc = SshKeyBloc(database,
        credentials: SshCredentialRepository(database, vault: vault));
    addTearDown(database.close);
    addTearDown(bloc.close);
    await database
        .into(database.sshKeys)
        .insert(SshKeysCompanion.insert(content: const Value('legacy-key')));
    final failed = bloc.stream.firstWhere((state) => state is SshKeyError);
    bloc.add(const SshKeyLoad());
    await failed;
    expect((await database.select(database.sshKeys).getSingle()).content,
        'legacy-key');
  });
}
