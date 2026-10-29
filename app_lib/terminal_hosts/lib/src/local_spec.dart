import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_conn.dart';

class LocalHostSpec implements HostSpec {
  @override
  final String name;

  /// Additional environment variables to set for the shell session.
  final Map<String, String> environment;

  /// Optional init commands to run when the shell starts.
  /// These are typically export/alias commands from a shell profile.
  final String? initCommands;

  /// Optional working directory to start the shell in.
  final String? workingDirectory;

  /// Optional shell executable name/path from shell profile.
  final String? shellCommand;

  LocalHostSpec({
    this.name = 'Local',
    this.environment = const {},
    this.initCommands,
    this.workingDirectory,
    this.shellCommand,
  });

  @override
  HostConnector createConnector() => LocalConnector(
    environment: environment,
    initCommands: initCommands,
    workingDirectory: workingDirectory,
    shellCommand: shellCommand,
  );
}
