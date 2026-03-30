import 'package:drift/drift.dart';

/// DNS provider type enumeration.
enum DnsProvider {
  route53,
  cloudflare,
}

/// Drift table definition for DnsZone.
///
/// Stores DNS zones linked to a service account for credentials.
class DnsZoneTable extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// DNS provider type (route53 or cloudflare).
  TextColumn get provider => textEnum<DnsProvider>()();

  /// Zone ID from the provider.
  TextColumn get zoneId => text()();

  /// Zone name (domain name).
  TextColumn get zoneName => text()();

  /// Reference to the service account that holds API credentials.
  IntColumn get serviceAccountId => integer()();

  /// Optional comment/description.
  TextColumn get comment => text().nullable()();

  /// Timestamp when the record was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the record was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
