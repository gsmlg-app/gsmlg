import 'package:drift/drift.dart';

/// Drift table for monitor hosts.
///
/// Each row represents a host being monitored, identified by "ip:port".
class MonitorHostTable extends Table {
  /// Primary key: "ip:port".
  TextColumn get id => text()();

  /// IP address of the host.
  TextColumn get ip => text()();

  /// Port number.
  IntColumn get port => integer()();

  /// Optional human-readable label.
  TextColumn get label => text().nullable()();

  /// Whether this host was added manually (vs discovered via mDNS).
  BoolColumn get isManual => boolean().withDefault(const Constant(true))();

  /// Timestamp when the host was first added.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
