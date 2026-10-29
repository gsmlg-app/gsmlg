import 'dart:io';

import 'package:path/path.dart' as p;

import 'ios_shell_plugin.dart';

/// Callback for reporting initialization progress.
typedef ProgressCallback = void Function(String message, double progress);

/// Singleton managing the iOS shell environment.
///
/// Provides paths and environment variables for the ios_system-based shell.
/// Uses the ios_system framework from the a-shell project for command execution.
class IosShellEnv {
  IosShellEnv._();

  static IosShellEnv? _instance;

  /// Gets the singleton instance.
  ///
  /// You must call [initialize] before using other properties.
  static IosShellEnv get instance {
    _instance ??= IosShellEnv._();
    return _instance!;
  }

  bool _initialized = false;
  late String _documentsPath;
  late String _tmpPath;

  /// Whether the environment has been initialized.
  bool get isInitialized => _initialized;

  /// The app's Documents directory (user-accessible).
  String get documentsPath => _documentsPath;

  /// The user's home directory (same as Documents on iOS).
  String get homePath => _documentsPath;

  /// The bin directory for user scripts.
  /// e.g., /var/mobile/.../Documents/bin
  String get binPath => p.join(_documentsPath, 'bin');

  /// The temporary files directory.
  String get tmpPath => _tmpPath;

  /// The default shell path (uses ios_system's built-in shell).
  /// On iOS, we use the dash shell provided by ios_system.
  String get shellPath => 'dash';

  /// Initializes the shell environment.
  ///
  /// This sets up directories and prepares the ios_system environment.
  /// Subsequent calls are no-ops if already initialized.
  ///
  /// [onProgress] - Optional callback for progress updates.
  Future<void> initialize({ProgressCallback? onProgress}) async {
    if (_initialized) return;

    onProgress?.call('Initializing iOS shell environment...', 0.1);

    // Call native plugin to initialize
    final paths = await IosShellPlugin.initialize();

    _documentsPath = paths['documentsPath'] ?? '';
    _tmpPath = paths['tmpPath'] ?? '';

    // Ensure bin directory exists for user scripts
    final binDir = Directory(binPath);
    if (!await binDir.exists()) {
      await binDir.create(recursive: true);
    }

    onProgress?.call('Shell environment ready', 1.0);
    _initialized = true;
  }

  /// Returns environment variables for the shell.
  ///
  /// These should be passed when executing commands.
  Map<String, String> getEnvironment() {
    return {
      'HOME': homePath,
      'PATH': '$binPath:/usr/bin:/bin',
      'SHELL': shellPath,
      'TERM': 'xterm-256color',
      'LANG': 'en_US.UTF-8',
      'TMPDIR': tmpPath,
      'CLICOLOR': '1',
      'COLUMNS': '80',
      'LINES': '25',
    };
  }

  /// Returns the shell command and arguments for starting a shell session.
  ///
  /// Note: On iOS with ios_system, the shell is typically 'dash' or 'sh'.
  (String, List<String>) getShellCommand() {
    return (shellPath, ['-l']);
  }

  /// Executes a command using ios_system.
  ///
  /// Returns the execution result with exit code, stdout, and stderr.
  Future<IosExecutionResult> execute(String command) async {
    final result = await IosShellPlugin.execute(command);
    return IosExecutionResult(
      exitCode: result['exitCode'] as int? ?? -1,
      stdout: result['stdout'] as String? ?? '',
      stderr: result['stderr'] as String? ?? '',
    );
  }

  /// Returns the list of available commands.
  Future<List<String>> listCommands() async {
    return await IosShellPlugin.listCommands();
  }

  /// Resets the singleton instance (useful for testing).
  static void reset() {
    _instance = null;
  }
}

/// Result of executing a command on iOS.
class IosExecutionResult {
  final int exitCode;
  final String stdout;
  final String stderr;

  IosExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  bool get success => exitCode == 0;
}
