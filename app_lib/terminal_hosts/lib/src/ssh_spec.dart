import 'dart:async';

import 'package:app_ssh/app_ssh.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ssh_conn.dart';

/// SSH host specification implementing the HostSpec interface.
///
/// This bridges the database [SshHost] model to the terminal plugin system
/// by implementing [HostSpec], allowing SSH hosts to be used with
/// [PluginManager] and [PluginTab].
class SSHHostSpec implements HostSpec {
  /// The SSH host record from the database.
  final SshHost record;

  /// Optional SSH key data for key-based authentication.
  /// Must be provided when [record.identityType] is [SshIdentityType.key].
  final SshKeyData? keyData;

  final SSHHostkeyVerifyHandler? verifyHostKey;
  final FutureOr<String?> Function()? passwordProvider;

  /// Creates an SSH host specification.
  ///
  /// Throws [ArgumentError] if [keyData] is null when the host's identity type
  /// is set to key-based authentication.
  SSHHostSpec(
    this.record, {
    this.keyData,
    this.verifyHostKey,
    this.passwordProvider,
  }) {
    final identityType = SshIdentityType.fromValue(record.identityType);
    if (identityType == SshIdentityType.key && keyData == null) {
      throw ArgumentError(
        'keyData is required when identityType is SshIdentityType.key',
      );
    }
  }

  @override
  String get name => record.host ?? record.hostname ?? 'SSH Host';

  @override
  HostConnector createConnector() => SSHConnector(
    record,
    keyData: keyData,
    verifyHostKey: verifyHostKey,
    passwordProvider: passwordProvider,
  );
}
