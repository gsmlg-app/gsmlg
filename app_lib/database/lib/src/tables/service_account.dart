import 'package:drift/drift.dart';

/// Service provider type enumeration.
enum ServiceProvider {
  github,
  vultr,
  aws,
  cloudflare,
}

/// Drift table definition for ServiceAccount.
///
/// Stores service accounts with provider type, name, description,
/// and references to credentials in secure storage.
class ServiceAccountTable extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Service provider type.
  TextColumn get provider => textEnum<ServiceProvider>()();

  /// User-friendly name for this account.
  TextColumn get name => text()();

  /// Optional description for this account.
  TextColumn get description => text().withDefault(const Constant(''))();

  /// Timestamp when the record was created.
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the record was last updated.
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
