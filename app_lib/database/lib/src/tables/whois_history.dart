import 'package:drift/drift.dart';

import '../type_converter.dart';

/// Drift table definition for WhoisHistory.
///
/// Stores WHOIS lookup history with query string and result data.
class WhoisHistoryTable extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// The WHOIS query string (domain name, IP address, etc.).
  TextColumn get query => text().nullable()();

  /// The WHOIS lookup result as a list of strings (JSON encoded in DB).
  TextColumn get result => text().map(const StringListConverter()).nullable()();

  /// Timestamp when the record was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
