import 'package:app_database/app_database.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import 'credentials_service.dart';

part 'zone_event.dart';
part 'zone_state.dart';

/// BLoC for managing DNS zones.
class ZoneBloc extends Bloc<ZoneEvent, ZoneState> {
  final AppDatabase database;
  final CredentialsService credentialsService;

  ZoneBloc(this.database, this.credentialsService) : super(const ZoneInitial()) {
    on<ZoneSync>(_onSync);
    on<ZoneAdd>(_onAdd);
    on<ZoneUpdate>(_onUpdate);
    on<ZoneRemove>(_onRemove);
  }

  Future<void> _onSync(
    ZoneSync event,
    Emitter<ZoneState> emit,
  ) async {
    emit(const ZoneLoading());
    try {
      final query = database.select(database.dnsZoneTable)
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.updatedAt,
                mode: OrderingMode.desc,
              ),
        ]);
      final list = await query.get();
      emit(ZoneLoaded(list));
    } catch (e) {
      emit(ZoneFailure(e.toString()));
    }
  }

  Future<void> _onAdd(
    ZoneAdd event,
    Emitter<ZoneState> emit,
  ) async {
    try {
      // Check for duplicate zone with same provider and zoneId
      final existingQuery = database.select(database.dnsZoneTable)
        ..where((t) =>
            t.provider.equals(event.provider.name) &
            t.zoneId.equals(event.zoneId));
      final existing = await existingQuery.getSingleOrNull();

      if (existing != null) {
        emit(ZoneFailure(
          'Zone "${event.zoneName}" already exists for this provider',
        ));
        add(const ZoneSync());
        return;
      }

      // Insert zone into database (credentials stored in vault, not DB)
      final zoneId = await database.into(database.dnsZoneTable).insert(
            DnsZoneTableCompanion.insert(
              provider: event.provider,
              zoneId: event.zoneId,
              zoneName: event.zoneName,
              credentials: '', // Empty - credentials stored in secure vault
              comment: Value(event.comment),
            ),
          );

      // Save credentials to secure vault using the zone's database ID
      await credentialsService.saveCredentials(
        zoneId: zoneId,
        encodedCredentials: event.credentials,
      );

      add(const ZoneSync());
    } catch (e) {
      emit(ZoneFailure(e.toString()));
    }
  }

  Future<void> _onUpdate(
    ZoneUpdate event,
    Emitter<ZoneState> emit,
  ) async {
    try {
      await (database.update(database.dnsZoneTable)
            ..where((t) => t.id.equals(event.zone.id)))
          .write(
        DnsZoneTableCompanion(
          zoneName: Value(event.zoneName ?? event.zone.zoneName),
          comment: Value(event.comment ?? event.zone.comment),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Update credentials in vault if provided
      if (event.credentials != null) {
        await credentialsService.saveCredentials(
          zoneId: event.zone.id,
          encodedCredentials: event.credentials!,
        );
      }

      add(const ZoneSync());
    } catch (e) {
      emit(ZoneFailure(e.toString()));
    }
  }

  Future<void> _onRemove(
    ZoneRemove event,
    Emitter<ZoneState> emit,
  ) async {
    try {
      // Delete credentials from vault first
      await credentialsService.deleteCredentials(event.zone.id);

      // Then delete zone from database
      await (database.delete(database.dnsZoneTable)
            ..where((t) => t.id.equals(event.zone.id)))
          .go();
      add(const ZoneSync());
    } catch (e) {
      emit(ZoneFailure(e.toString()));
    }
  }
}
