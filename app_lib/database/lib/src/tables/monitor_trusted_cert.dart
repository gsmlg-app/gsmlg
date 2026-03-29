import 'package:drift/drift.dart';

import 'monitor_host.dart';

/// Drift table for pinned TLS certificate fingerprints per monitor host.
class MonitorTrustedCertTable extends Table {
  /// Foreign key referencing [MonitorHostTable.id].
  TextColumn get hostId => text().references(MonitorHostTable, #id)();

  /// SHA-256 fingerprint of the pinned certificate.
  TextColumn get fingerprint => text()();

  /// When the fingerprint was first trusted.
  DateTimeColumn get firstTrustedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// When the fingerprint was last verified against a live connection.
  DateTimeColumn get lastVerifiedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {hostId};
}
