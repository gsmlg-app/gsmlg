import 'package:drift/drift.dart';

import 'ssh_keys.dart';

/// Identity types for SSH host authentication
enum SshIdentityType {
  password(1),
  key(2);

  const SshIdentityType(this.value);
  final int value;

  static SshIdentityType? fromValue(int? value) {
    if (value == null) return null;
    return SshIdentityType.values.cast<SshIdentityType?>().firstWhere(
          (e) => e?.value == value,
          orElse: () => null,
        );
  }
}

/// Table for storing SSH host configurations
@DataClassName('SshHost')
class SshHosts extends Table {
  /// Primary key - auto increment
  IntColumn get id => integer().autoIncrement()();

  /// Display name for the host
  TextColumn get host => text().nullable()();

  /// IP address or domain name
  TextColumn get hostname => text().nullable()();

  /// SSH port (default: 22)
  IntColumn get port => integer().nullable()();

  /// Username for authentication
  TextColumn get username => text().nullable()();

  /// Encrypted password
  TextColumn get password => text().nullable()();

  /// Salt used for password encryption
  TextColumn get salt => text().nullable()();

  /// Foreign key reference to SshKeys table
  IntColumn get identityKeyId =>
      integer().nullable().references(SshKeys, #id)();

  /// Identity type (1=password, 2=key)
  IntColumn get identityType => integer().nullable()();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().nullable()();
}
