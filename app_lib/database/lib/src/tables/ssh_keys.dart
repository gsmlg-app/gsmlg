import 'package:drift/drift.dart';

/// Algorithm types for SSH keys
enum SshKeyAlgorithm {
  rsa(1),
  dsa(2),
  ecdsa(3),
  ed25519(4);

  const SshKeyAlgorithm(this.value);
  final int value;

  static SshKeyAlgorithm? fromValue(int? value) {
    if (value == null) return null;
    return SshKeyAlgorithm.values.cast<SshKeyAlgorithm?>().firstWhere(
          (e) => e?.value == value,
          orElse: () => null,
        );
  }
}

/// Table for storing SSH keys
@DataClassName('SshKey')
class SshKeys extends Table {
  /// Primary key - auto increment
  IntColumn get id => integer().autoIncrement()();

  /// Display name for the key
  TextColumn get name => text().nullable()();

  /// Encrypted PEM key content
  TextColumn get content => text().nullable()();

  /// Password for the key (if encrypted)
  TextColumn get password => text().nullable()();

  /// Salt used for encryption
  TextColumn get salt => text().nullable()();

  /// Algorithm type (1=rsa, 2=dsa, 3=ecdsa, 4=ed25519)
  IntColumn get algorithm => integer().nullable()();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().nullable()();
}
