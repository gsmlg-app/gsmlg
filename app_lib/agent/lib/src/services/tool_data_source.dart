import 'package:app_database/app_database.dart';

/// The database reads that agent tools and Backplane perform.
///
/// Agent isolates cannot use the main-isolate Drift connection; they receive
/// a bridged implementation instead. Rows are Drift data classes, which are
/// plain values that encode with `toJson`/`fromJson`.
abstract interface class ToolDataSource {
  /// All configured DNS zones.
  Future<List<DnsZoneTableData>> listDnsZones();

  /// DNS zones matching every non-null filter. [provider] is a [DnsProvider]
  /// name.
  Future<List<DnsZoneTableData>> findDnsZones({
    int? localZoneId,
    String? zoneId,
    String? zoneName,
    String? provider,
  });

  Future<ServiceAccountTableData?> serviceAccountById(int id);

  /// Service accounts of [provider], optionally narrowed to [id].
  Future<List<ServiceAccountTableData>> serviceAccountsByProvider(
    ServiceProvider provider, {
    int? id,
  });
}

/// Main-isolate [ToolDataSource] backed by [AppDatabase].
class DatabaseToolDataSource implements ToolDataSource {
  const DatabaseToolDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<List<DnsZoneTableData>> listDnsZones() =>
      _database.select(_database.dnsZoneTable).get();

  @override
  Future<List<DnsZoneTableData>> findDnsZones({
    int? localZoneId,
    String? zoneId,
    String? zoneName,
    String? provider,
  }) {
    final query = _database.select(_database.dnsZoneTable);
    if (localZoneId != null) query.where((t) => t.id.equals(localZoneId));
    if (zoneId != null) query.where((t) => t.zoneId.equals(zoneId));
    if (zoneName != null) query.where((t) => t.zoneName.equals(zoneName));
    if (provider != null) query.where((t) => t.provider.equals(provider));
    return query.get();
  }

  @override
  Future<ServiceAccountTableData?> serviceAccountById(int id) =>
      (_database.select(
        _database.serviceAccountTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

  @override
  Future<List<ServiceAccountTableData>> serviceAccountsByProvider(
    ServiceProvider provider, {
    int? id,
  }) {
    final query = _database.select(_database.serviceAccountTable)
      ..where((t) => t.provider.equals(provider.name));
    if (id != null) query.where((t) => t.id.equals(id));
    return query.get();
  }
}
