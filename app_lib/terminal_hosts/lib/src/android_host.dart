import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:android_shell/android_shell.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_fs.dart';

/// Host implementation for Android using the sandboxed shell environment.
class AndroidHost implements Host {
  final AndroidShellEnv _env;

  /// Additional environment variables from shell profile.
  final Map<String, String> _profileEnvironment;

  /// Optional init commands to run when shell starts.
  final String? _initCommands;

  AndroidHost(
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
    final (mergedEnv, useRoot) = _sessionEnvironment(environment, root: root);

    if (!_env.usesSystemShell && _env.prootPath.isNotEmpty) {
      final (prootBin, execArgs) = _env.getExecutionCommand(
        executable,
        arguments: args,
        root: useRoot,
      );

      final result = await io.Process.run(
        prootBin,
        execArgs,
        environment: mergedEnv,
        workingDirectory: _env.tmpPath,
      );
      return AndroidExecutionResult(result);
    }

    // Resolve executable path in sandboxed bin directory
    final execPath = _resolveExecutable(executable);

    final result = await io.Process.run(
      execPath,
      args,
      environment: mergedEnv,
      workingDirectory: _env.homePath,
    );
    return AndroidExecutionResult(result);
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    return LocalFileSystem();
  }

  @override
  Future<AndroidExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    final (mergedEnv, useRoot) = _sessionEnvironment(environment);
    final (command, args) = _env.getShellCommand(root: useRoot);

    final pty = Pty.start(
      command,
      arguments: args,
      environment: mergedEnv,
      workingDirectory: useRoot ? _env.rootHomePath : _env.homePath,
      rows: height,
      columns: width,
      ackRead: true, // Enable backpressure to prevent message queue flooding
    );

    // Send init commands if provided (after a short delay for shell to start)
    final initCmds = _initCommands;
    if (initCmds != null && initCmds.isNotEmpty) {
      // Wait briefly for shell prompt
      Future.delayed(const Duration(milliseconds: 100), () {
        pty.write(utf8.encode('$initCmds\n'));
      });
    }

    return AndroidExecutionSession(pty);
  }

  (Map<String, String>, bool) _sessionEnvironment(
    Map<String, String>? environment, {
    bool root = false,
  }) {
    final overrides = {..._profileEnvironment, ...?environment};
    final selectedUser = overrides['WEB_TERMINAL_USER'] ?? _env.userName;
    if (selectedUser != 'root' && selectedUser != _env.userName) {
      throw ArgumentError.value(
        selectedUser,
        'WEB_TERMINAL_USER',
        'Expected root or ${_env.userName}',
      );
    }
    final useRoot = root || selectedUser == 'root';
    final base = _env.getEnvironment(root: useRoot);
    final merged = {...base, ...overrides};
    for (final key in [
      'HOME',
      'USER',
      'LOGNAME',
      'SHELL',
      'WEB_TERMINAL_USER',
    ]) {
      if (base.containsKey(key)) merged[key] = base[key]!;
    }
    return (merged, useRoot);
  }

  final _doneCompleter = Completer<void>();

  @override
  Future<void> disconnect() async {
    _doneCompleter.complete();
  }

  @override
  Future<void> get done => _doneCompleter.future;

  /// Resolves an executable name to its full path.
  ///
  /// If the executable is not an absolute path, looks for it in the
  /// sandboxed bin directory first.
  String _resolveExecutable(String executable) {
    if (executable.startsWith('/')) {
      return executable;
    }

    // Check if it exists in our bin directory
    final sandboxedPath = '${_env.binPath}/$executable';
    if (io.File(sandboxedPath).existsSync()) {
      return sandboxedPath;
    }

    // Fall back to system PATH resolution
    return executable;
  }
}

/// Result of executing a command on Android.
class AndroidExecutionResult implements ExecutionResult {
  final io.ProcessResult _result;

  /// Creates an [AndroidExecutionResult] from a [io.ProcessResult].
  AndroidExecutionResult(this._result);

  @override
  int get exitCode => _result.exitCode;

  @override
  String get stderr => _result.stderr;

  @override
  String get stdout => _result.stdout;
}

/// Session for an interactive shell on Android.
class AndroidExecutionSession implements ExecutionSession {
  final Pty _pty;

  /// Creates an [AndroidExecutionSession] from a [Pty].
  AndroidExecutionSession(this._pty);

  @override
  Future<int> get exitCode => _pty.exitCode;

  @override
  Stream<Uint8List> get output => _pty.output;

  @override
  Future<void> close() async {
    await _pty.close();
  }

  @override
  Future<void> resize(int width, int height) async {
    _pty.resize(height, width);
  }

  @override
  Future<void> write(Uint8List data) async {
    _pty.write(data);
  }

  @override
  void ackRead() {
    _pty.ackRead();
  }
}
