import 'package:ios_shell/ios_shell.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ios_host.dart';

/// Connector for iOS shell environment.
///
/// Ensures the ios_system shell environment is initialized before creating
/// the host.
class IosConnector extends HostConnector<IosHost> {
  /// Additional environment variables from shell profile.
  final Map<String, String> environment;

  /// Optional init commands to run when shell starts.
  final String? initCommands;

  IosConnector({this.environment = const {}, this.initCommands});

  @override
  Future<IosHost> createHost() async {
    // Ensure shell environment is initialized
    final env = IosShellEnv.instance;
    if (!env.isInitialized) {
      await env.initialize();
    }

    return IosHost(env, environment: environment, initCommands: initCommands);
  }
}
