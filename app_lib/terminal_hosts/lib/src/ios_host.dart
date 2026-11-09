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
    final result = await _env.execute(
      command,
      environment: <String, String>{..._profileEnvironment, ...?environment},
    );

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
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
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
class IosExecutionSession implements ExecutionSession, ForegroundProcessAware {
  final IosShellEnv _env;

  /// Environment variables from profile (applied to each command).
  /// Mutable to allow export commands to add variables.
  final Map<String, String> _environment;

  final _outputController = StreamController<Uint8List>.broadcast();
  final _exitCodeCompleter = Completer<int>();

  @override
  Future<bool> hasForegroundProcess() async => false;

  final StringBuffer _decodedInput = StringBuffer();
  late final ByteConversionSink _inputDecoder = const Utf8Decoder(
    allowMalformed: true,
  ).startChunkedConversion(StringConversionSink.fromStringSink(_decodedInput));

  String _inputBuffer = '';
  bool _closed = false;
  _EscapeState _escapeState = _EscapeState.none;
  String _cwd;
  String? _previousCwd;

  IosExecutionSession(
    this._env, {
    Map<String, String> environment = const {},
    String? initCommands,
  }) : _environment = Map<String, String>.from(environment),
       _cwd = _env.homePath {
    // Delay initialization to allow output listener to be attached first
    Future.delayed(const Duration(milliseconds: 100), () {
      _initialize(initCommands);
    });
  }

  Future<void> _initialize(String? initCommands) async {
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
    await _refreshCwd();
    _showPrompt();
  }

  /// Executes a command without showing output (for init commands).
  Future<void> _executeCommandSilent(String command) async {
    if (command.isEmpty) return;

    // Handle export commands for environment variables
    if (_handleExport(command)) return;

    // Handle alias commands (stored in memory but ios_system doesn't support them)
    if (command.startsWith('alias ')) {
      // iOS shell doesn't support aliases, silently ignore
      return;
    }

    // Execute other commands silently
    try {
      await _env.execute(command, environment: _environment);
    } catch (_) {
      // Ignore errors for init commands
    }
  }

  /// Stores `export VAR=value` in this session's environment instead of
  /// letting ios_system's built-in export change every session.
  bool _handleExport(String command) {
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
      return true;
    }
    return false;
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

    _inputDecoder.add(data);
    final input = _decodedInput.toString();
    _decodedInput.clear();

    for (final char in input.split('')) {
      if (_consumeEscapeSequence(char)) {
        continue;
      }
      if (char == '\r' || char == '\n') {
        // Execute the command
        final command = _inputBuffer.trim();
        _inputBuffer = '';
        _output('\r\n');
        await _executeCommand(command);
        if (!_closed) {
          await _refreshCwd();
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

  /// Swallows terminal escape sequences (arrow keys, Home/End, paging)
  /// because this line editor has no cursor movement or history.
  bool _consumeEscapeSequence(String char) {
    switch (_escapeState) {
      case _EscapeState.none:
        if (char != '\x1b') return false;
        _escapeState = _EscapeState.escape;
        return true;
      case _EscapeState.escape:
        if (char == '[') {
          _escapeState = _EscapeState.csi;
          return true;
        }
        if (char == 'O') {
          _escapeState = _EscapeState.ss3;
          return true;
        }
        _escapeState = _EscapeState.none;
        return false;
      case _EscapeState.csi:
        final code = char.codeUnitAt(0);
        if (code >= 0x40 && code <= 0x7e) {
          _escapeState = _EscapeState.none;
        }
        return true;
      case _EscapeState.ss3:
        _escapeState = _EscapeState.none;
        return true;
    }
  }

  void _showPrompt() {
    _output('${_promptDirectory()} \$ ');
  }

  String _promptDirectory() {
    if (_withoutPrivatePrefix(_cwd) == _withoutPrivatePrefix(_env.homePath)) {
      return '~';
    }
    final segments = _cwd.split('/').where((segment) => segment.isNotEmpty);
    return segments.isEmpty ? '/' : segments.last;
  }

  String _withoutPrivatePrefix(String path) {
    final trimmed = path.length > 1 && path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    return trimmed.startsWith('/private/')
        ? trimmed.substring('/private'.length)
        : trimmed;
  }

  Future<void> _refreshCwd() async {
    try {
      final cwd = await IosShellPlugin.getCurrentDirectory();
      if (cwd.isNotEmpty) {
        _cwd = cwd;
      }
    } catch (_) {
      // Keep the last known directory when the platform call fails.
    }
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

    if (command == 'cd' || command.startsWith('cd ')) {
      await _handleCd(command.substring(2).trim());
      return;
    }

    if (_handleExport(command)) return;

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

      final result = await _env.execute(command, environment: _environment);

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

  Future<void> _handleCd(String argument) async {
    final target = _resolveCdTarget(argument);
    if (target == null) {
      _output('cd: OLDPWD not set\r\n');
      return;
    }
    final previous = _cwd;
    final success = await IosShellPlugin.setCurrentDirectory(target);
    if (!success) {
      _output('cd: no such file or directory: $target\r\n');
      return;
    }
    _previousCwd = previous;
    if (argument == '-') {
      _output('$target\r\n');
    }
  }

  String? _resolveCdTarget(String argument) {
    var path = argument;
    final quoted =
        path.length >= 2 &&
        ((path.startsWith('"') && path.endsWith('"')) ||
            (path.startsWith("'") && path.endsWith("'")));
    if (quoted) {
      path = path.substring(1, path.length - 1);
    }
    if (path.isEmpty || path == '~') return _env.homePath;
    if (path == '-' && !quoted) return _previousCwd;
    if (path.startsWith('~/')) return '${_env.homePath}${path.substring(1)}';
    return path;
  }

  @override
  void ackRead() {
    // iOS shell doesn't use PTY backpressure, no-op
  }
}

enum _EscapeState { none, escape, csi, ss3 }
