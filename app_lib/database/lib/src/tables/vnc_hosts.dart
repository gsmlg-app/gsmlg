import 'package:drift/drift.dart';

import 'ssh_hosts.dart';

/// Authentication mode for a saved VNC host.
enum VncHostAuthType {
  auto(0),
  none(1),
  vncPassword(2),
  appleArd(30);

  const VncHostAuthType(this.value);
  final int value;

  static VncHostAuthType fromValue(int value) =>
      VncHostAuthType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => VncHostAuthType.auto,
      );
}

/// Table for storing saved VNC host profiles (secrets live in VaultRepository).
@DataClassName('VncHost')
class VncHosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get host => text()();
  IntColumn get port => integer().withDefault(const Constant(5900))();
  IntColumn get authType => integer().withDefault(const Constant(0))();
  TextColumn get username => text().nullable()();
  TextColumn get passwordRef => text().nullable()();
  IntColumn get sshHostId => integer()
      .nullable()
      .references(SshHosts, #id, onDelete: KeyAction.setNull)();
  BoolColumn get viewOnly => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
}
