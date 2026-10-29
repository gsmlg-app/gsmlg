import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';

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

  test('host passwords are persisted only as vault references', () async {
    final database = AppDatabase.forTesting();
    final bloc = SshHostBloc(database);
    addTearDown(bloc.close);
    addTearDown(database.close);
    final loaded = bloc.stream.firstWhere((state) => state is SshHostLoaded);
    bloc.add(const SshHostAdd(host: 'Host', password: 'secret-password'));
    await loaded;

    final row = await database.select(database.sshHosts).getSingle();
    expect(row.password, startsWith('vault:ssh:'));
    expect(row.salt, isNull);
  });

  test('host form reports a persistence failure instead of success', () async {
    final database = AppDatabase.forTesting();
    final vault = _ControlledVault()..failWrites = true;
    final bloc = SshHostBloc(
      database,
      credentials: SshCredentialRepository(database, vault: vault),
    );
    final form = SshHostFormBloc(bloc);
    addTearDown(form.close);
    addTearDown(bloc.close);
    form.port.updateValue('22');
    form.identityType.updateValue(SshIdentityType.password);
    form.password.updateValue('secret');
    addTearDown(database.close);
    final completed = form.stream.firstWhere(
      (state) => state is FormBlocSuccess || state is FormBlocFailure,
    );
    form.onSubmitting();
    expect(await completed, isA<FormBlocFailure>());
  });

  test('host form waits for vault persistence before reporting success',
      () async {
    final database = AppDatabase.forTesting();
    final vault = _ControlledVault()..writeGate = Completer<void>();
    final bloc = SshHostBloc(database,
        credentials: SshCredentialRepository(database, vault: vault));
    final form = SshHostFormBloc(bloc);
    addTearDown(database.close);
    addTearDown(bloc.close);
    addTearDown(form.close);
    form.port.updateValue('22');
    form.identityType.updateValue(SshIdentityType.password);
    form.password.updateValue('secret');
    final completed = form.stream.firstWhere(
        (state) => state is FormBlocSuccess || state is FormBlocFailure);
    form.onSubmitting();
    await vault.writeStarted.future;
    expect(form.state, isNot(isA<FormBlocSuccess>()));
    vault.writeGate!.complete();
    expect(await completed, isA<FormBlocSuccess>());
    final row = await database.select(database.sshHosts).getSingle();
    expect(await bloc.credentials.readHostPassword(row), 'secret');
  });

  test('blank password in host edit form preserves the saved secret', () async {
    final database = AppDatabase.forTesting();
    final bloc = SshHostBloc(database);
    final form = SshHostFormBloc(bloc);
    addTearDown(database.close);
    addTearDown(bloc.close);
    addTearDown(form.close);
    await bloc.credentials.addHost(SshHostsCompanion.insert(
        password: const Value('secret'), identityType: const Value(1)));
    final row = await database.select(database.sshHosts).getSingle();
    form.setSshHost(row);
    expect(form.password.value, isEmpty);
    form.hostname.updateValue('changed.example');
    final completed = form.stream.firstWhere(
        (state) => state is FormBlocSuccess || state is FormBlocFailure);
    form.onSubmitting();
    expect(await completed, isA<FormBlocSuccess>());
    final updated = await database.select(database.sshHosts).getSingle();
    expect(updated.hostname, 'changed.example');
    expect(updated.password, row.password);
    expect(await bloc.credentials.readHostPassword(updated), 'secret');
  });

  test('host migration failure emits error and preserves the legacy row',
      () async {
    final database = AppDatabase.forTesting();
    final vault = _ControlledVault()..failWrites = true;
    final bloc = SshHostBloc(database,
        credentials: SshCredentialRepository(database, vault: vault));
    addTearDown(database.close);
    addTearDown(bloc.close);
    await database.into(database.sshHosts).insert(
        SshHostsCompanion.insert(password: const Value('legacy-secret')));
    final failed = bloc.stream.firstWhere((state) => state is SshHostError);
    bloc.add(const SshHostLoad());
    await failed;
    expect((await database.select(database.sshHosts).getSingle()).password,
        'legacy-secret');
  });
}
