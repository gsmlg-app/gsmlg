import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Re-export SshHost and SshIdentityType from app_database for convenience
export 'package:app_database/app_database.dart' show SshHost, SshIdentityType;

part 'event.dart';
part 'state.dart';

class SshHostBloc extends Bloc<SshHostEvent, SshHostState> {
  final AppDatabase database;
  final SshCredentialRepository credentials;

  SshHostBloc(this.database, {SshCredentialRepository? credentials})
      : credentials = credentials ?? SshCredentialRepository(database),
        super(const SshHostInitial()) {
    on<SshHostLoad>((event, emit) async {
      try {
        await this.credentials.migrateHosts();
        final data = await database.select(database.sshHosts).get();
        emit(SshHostLoaded(data));
      } catch (error) {
        emit(SshHostError(error));
      }
    });
    on<SshHostAdd>((event, emit) async {
      try {
        await this.credentials.addHost(
              SshHostsCompanion.insert(
                host: Value(event.host),
                hostname: Value(event.hostname),
                port: Value(event.port),
                username: Value(event.username),
                password: Value(event.password),
                salt: Value(event.salt),
                identityType: Value(event.identityType),
                identityKeyId: Value(event.identityKeyId),
                createdAt: Value(DateTime.now()),
              ),
            );
        final data = await database.select(database.sshHosts).get();
        emit(SshHostLoaded(data));
        event.completion?.complete();
      } catch (e, stackTrace) {
        emit(SshHostError(e));
        event.completion?.completeError(e, stackTrace);
      }
    });
    on<SshHostUpdate>((event, emit) async {
      try {
        await this.credentials.updateHost(
              event.id,
              SshHostsCompanion(
                host: Value(event.host),
                hostname: Value(event.hostname),
                port: Value(event.port),
                username: Value(event.username),
                password: Value(event.password),
                salt: Value(event.salt),
                identityType: Value(event.identityType),
                identityKeyId: Value(event.identityKeyId),
              ),
            );
        final data = await database.select(database.sshHosts).get();
        emit(SshHostLoaded(data));
        event.completion?.complete();
      } catch (e, stackTrace) {
        emit(SshHostError(e));
        event.completion?.completeError(e, stackTrace);
      }
    });
    on<SshHostDelete>((event, emit) async {
      try {
        await this.credentials.deleteHost(event.sshHost);
        final data = await database.select(database.sshHosts).get();
        emit(SshHostLoaded(data));
      } catch (e) {
        emit(SshHostError(e));
      }
    });
  }
}
