import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

/// Re-export SshKey from app_database for convenience
export 'package:app_database/app_database.dart' show SshKey, SshKeyAlgorithm;

/// Re-export extensions for encryption functionality
export 'ssh_key_extensions.dart';

part 'event.dart';
part 'state.dart';

class SshKeyBloc extends Bloc<SshKeyEvent, SshKeyState> {
  final AppDatabase database;
  final SshCredentialRepository credentials;

  SshKeyBloc(this.database, {SshCredentialRepository? credentials})
      : credentials = credentials ?? SshCredentialRepository(database),
        super(const SshKeyInitial()) {
    on<SshKeyLoad>((event, emit) async {
      try {
        await this.credentials.migrateKeys();
        final data = await database.select(database.sshKeys).get();
        emit(SshKeyLoaded(data));
      } catch (error) {
        emit(SshKeyError(error));
      }
    });
    on<SshKeyAdd>((event, emit) async {
      try {
        await this.credentials.addKey(
              SshKeysCompanion.insert(
                name: Value(event.name),
                content: Value(event.content),
                password: Value(event.password),
                salt: Value(event.salt),
                algorithm: Value(event.algorithm),
                createdAt: Value(DateTime.now()),
              ),
            );
        final data = await database.select(database.sshKeys).get();
        emit(SshKeyLoaded(data));
        event.completion?.complete();
      } catch (e, stackTrace) {
        emit(SshKeyError(e));
        event.completion?.completeError(e, stackTrace);
      }
    });
    on<SshKeyDelete>((event, emit) async {
      try {
        await this.credentials.deleteKey(event.sshKey);
        final data = await database.select(database.sshKeys).get();
        emit(SshKeyLoaded(data));
      } catch (e) {
        emit(SshKeyError(e));
      }
    });
  }
}
