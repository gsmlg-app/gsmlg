import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ios_conn.dart';

/// Host specification for iOS devices using ios_system shell.
class IosHostSpec implements HostSpec {
  @override
  final String name;

  /// Additional environment variables to set for the shell session.
  final Map<String, String> environment;

  /// Optional init commands to run when the shell starts.
  final String? initCommands;

  IosHostSpec({
    this.name = 'iOS',
    this.environment = const {},
    this.initCommands,
  });

  @override
  HostConnector createConnector() =>
      IosConnector(environment: environment, initCommands: initCommands);
}
