import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ios_shell/ios_shell.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_fs.dart';

/// Host implementation for iOS using the ios_system framework.
///
/// Note: iOS doesn't support traditional PTY/fork like Unix systems.
/// This implementation uses ios_system for command execution with
/// a simulated shell session that processes commands line by line.
class IosHost implements Host {
  final IosShellEnv _env;

  /// Additional environment variables from shell profile.
  final Map<String, String> _profileEnvironment;

  /// Optional init commands to run when shell starts.
  final String? _initCommands;

  IosHost(
    this._env, {
    Map<String, String> environment = const {},
    String? initCommands,
  }) : _profileEnvironment = environment,
       _initCommands = initCommands;

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    // Build command string
    final command = args.isEmpty ? executable : '$executable ${args.join(' ')}';

    // Execute using ios_system
    final result = await _env.execute(command);

    return IosExecutionResult(
      exitCode: result.exitCode,
      stdout: result.stdout,
      stderr: result.stderr,
    );
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    return LocalFileSystem();
  }

  @override
  Future<IosExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    // Merge environment: profile → session-specific
    final mergedEnv = {..._profileEnvironment, ...environment ?? {}};

    // Create a simulated shell session for iOS
    // Note: width/height are accepted for API compatibility but iOS
    // doesn't support true PTY resizing
    return IosExecutionSession(
      _env,
      environment: mergedEnv,
      initCommands: _initCommands,
    );
  }

  final _doneCompleter = Completer<void>();

  @override
  Future<void> disconnect() async {
    _doneCompleter.complete();
  }

  @override
  Future<void> get done => _doneCompleter.future;
}

/// Result of executing a command on iOS.
class IosExecutionResult implements ExecutionResult {
  @override
  final int exitCode;

  @override
  final String stdout;

  @override
  final String stderr;

  IosExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });
}

/// Session for an interactive shell on iOS.
///
/// iOS doesn't support true PTY, so this simulates a shell by:
/// - Displaying a prompt
/// - Reading lines of input
/// - Executing commands via ios_system
/// - Outputting results
class IosExecutionSession implements ExecutionSession {
  final IosShellEnv _env;

  /// Environment variables from profile (applied to each command).
  /// Mutable to allow export commands to add variables.
  final Map<String, String> _environment;

  final _outputController = StreamController<Uint8List>.broadcast();
  final _exitCodeCompleter = Completer<int>();

  String _inputBuffer = '';
  bool _closed = false;

  IosExecutionSession(
    this._env, {
    Map<String, String> environment = const {},
    String? initCommands,
  }) : _environment = Map<String, String>.from(environment) {
    // Delay initialization to allow output listener to be attached first
    Future.delayed(const Duration(milliseconds: 100), () {
      _initialize(initCommands);
    });
  }

  Future<void> _initialize(String? initCommands) async {
    // Note: External commands (ls, pwd, etc.) currently don't work because
    // ios_system needs to be rebuilt with a bundled command dictionary.
    // Only built-in commands (cd, alias, export) are functional.

    // Run init commands silently if provided
    final cmds = initCommands;
    if (cmds != null && cmds.isNotEmpty) {
      for (final line in cmds.split('\n')) {
        final cmd = line.trim();
        if (cmd.isNotEmpty) {
          await _executeCommandSilent(cmd);
        }
      }
    }
    _showPrompt();
  }

  /// Executes a command without showing output (for init commands).
  Future<void> _executeCommandSilent(String command) async {
    if (command.isEmpty) return;

    // Handle export commands for environment variables
    if (command.startsWith('export ')) {
      _handleExport(command);
      return;
    }

    // Handle alias commands (stored in memory but ios_system doesn't support them)
    if (command.startsWith('alias ')) {
      // iOS shell doesn't support aliases, silently ignore
      return;
    }

    // Execute other commands silently
    try {
      await _env.execute(command);
    } catch (_) {
      // Ignore errors for init commands
    }
  }

  void _handleExport(String command) {
    // Parse: export VAR=value or export VAR="value"
    final match = RegExp(r'^export\s+(\w+)=(.*)$').firstMatch(command);
    if (match != null) {
      final varName = match.group(1)!;
      var value = match.group(2)!;
      // Remove surrounding quotes if present
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      _environment[varName] = value;
    }
  }

  @override
  Future<int> get exitCode => _exitCodeCompleter.future;

  @override
  Stream<Uint8List> get output => _outputController.stream;

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _outputController.close();
    if (!_exitCodeCompleter.isCompleted) {
      _exitCodeCompleter.complete(0);
    }
  }

  @override
  Future<void> resize(int width, int height) async {
    // iOS shell doesn't have true PTY, resize is a no-op
  }

  @override
  Future<void> write(Uint8List data) async {
    if (_closed) return;

    final input = utf8.decode(data);

    for (final char in input.split('')) {
      if (char == '\r' || char == '\n') {
        // Execute the command
        final command = _inputBuffer.trim();
        _inputBuffer = '';
        _output('\r\n');
        await _executeCommand(command);
        if (!_closed) {
          _showPrompt();
        }
      } else if (char == '\x7f' || char == '\b') {
        // Backspace
        if (_inputBuffer.isNotEmpty) {
          _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1);
          _output('\b \b'); // Move back, clear, move back
        }
      } else if (char == '\x03') {
        // Ctrl+C
        _inputBuffer = '';
        _output('^C\r\n');
        _showPrompt();
      } else if (char == '\x04') {
        // Ctrl+D - exit
        if (_inputBuffer.isEmpty) {
          _output('exit\r\n');
          close();
        }
      } else if (char.codeUnitAt(0) >= 32) {
        // Printable character
        _inputBuffer += char;
        _output(char);
      }
    }
  }

  void _showPrompt() {
    final cwd = _env.homePath;
    final shortCwd = cwd.split('/').last;
    _output('$shortCwd \$ ');
  }

  void _output(String text) {
    if (!_closed) {
      _outputController.add(Uint8List.fromList(utf8.encode(text)));
    }
  }

  Future<void> _executeCommand(String command) async {
    if (command.isEmpty) return;

    // Handle built-in commands
    if (command == 'exit' || command == 'logout') {
      close();
      return;
    }

    if (command.startsWith('cd ')) {
      final path = command.substring(3).trim();
      await _handleCd(path);
      return;
    }

    if (command == 'cd') {
      await _handleCd(_env.homePath);
      return;
    }

    // Execute via ios_system
    try {
      if (command == 'clear') {
        _output('\x1b[2J\x1b[H');
        return;
      }

      if (command == 'help') {
        final commands = {
          ...await _env.listCommands(),
          'cd',
          'clear',
          'exit',
          'help',
          'logout',
        }.toList()..sort();
        _output('${commands.join('  ')}\r\n');
        return;
      }

      final result = await _env.execute(command);

      if (result.stdout.isNotEmpty) {
        // Normalize line endings for terminal display
        final stdout = result.stdout.replaceAll('\n', '\r\n');
        _output(stdout);
        if (!stdout.endsWith('\r\n')) {
          _output('\r\n');
        }
      }

      if (result.stderr.isNotEmpty) {
        final stderr = result.stderr.replaceAll('\n', '\r\n');
        _output(stderr);
        if (!stderr.endsWith('\r\n')) {
          _output('\r\n');
        }
      }

      // If no output but non-zero exit code, show error
      if (result.stdout.isEmpty &&
          result.stderr.isEmpty &&
          result.exitCode != 0) {
        _output('Command failed with exit code ${result.exitCode}\r\n');
      }
    } catch (e) {
      _output('Error: $e\r\n');
    }
  }

  Future<void> _handleCd(String path) async {
    final success = await IosShellPlugin.setCurrentDirectory(path);
    if (!success) {
      _output('cd: no such file or directory: $path\r\n');
    }
  }

  @override
  void ackRead() {
    // iOS shell doesn't use PTY backpressure, no-op
  }
}
