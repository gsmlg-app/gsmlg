import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/android_conn.dart';

/// Host specification for Android devices using sandboxed shell.
class AndroidHostSpec implements HostSpec {
  @override
  final String name;

  /// Additional environment variables to set for the shell session.
  final Map<String, String> environment;

  /// Optional init commands to run when the shell starts.
  final String? initCommands;

  AndroidHostSpec({
    this.name = 'Android',
    this.environment = const {},
    this.initCommands,
  });

  @override
  HostConnector createConnector() =>
      AndroidConnector(environment: environment, initCommands: initCommands);
}
