import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_fs.dart';

class LocalHost implements Host {
  /// Additional environment variables from shell profile.
  final Map<String, String> _profileEnvironment;

  /// Optional init commands to run when shell starts.
  final String? _initCommands;

  /// Optional working directory to start the shell in.
  final String? _workingDirectory;

  /// Optional shell executable name/path from shell profile (e.g. zsh, bash, fish, sh).
  final String? _shellCommand;

  LocalHost({
    Map<String, String> environment = const {},
    String? initCommands,
    String? workingDirectory,
    String? shellCommand,
  }) : _profileEnvironment = environment,
       _initCommands = initCommands,
       _workingDirectory = workingDirectory,
       _shellCommand = shellCommand;

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    final result = await Process.run(
      executable,
      args,
      environment: environment,
    );
    return LocalExecutionResult(result);
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    return LocalFileSystem();
  }

  @override
  Future<LocalExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    final shell = _resolveShell(_shellCommand);
    final mergedEnv = <String, String>{
      if (Platform.isMacOS) 'TERM_PROGRAM': 'Apple_Terminal',
      ...Platform.environment,
      ..._profileEnvironment,
      ...environment ?? {},
    };
    final pty = Pty.start(
      shell.command,
      arguments: shell.args,
      environment: mergedEnv,
      workingDirectory:
          (_workingDirectory != null && _workingDirectory.isNotEmpty)
          ? _workingDirectory
          : null,
      rows: height,
      columns: width,
      ackRead: true, // Enable backpressure to prevent message queue flooding
    );

    final startupCommands = buildLocalShellStartupCommands(
      workingDirectory: _workingDirectory,
      initCommands: _initCommands,
    );
    if (startupCommands.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        pty.write(utf8.encode('$startupCommands\n'));
      });
    }

    return LocalExecutionSession(pty);
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

class LocalExecutionResult implements ExecutionResult {
  final ProcessResult _result;

  LocalExecutionResult(this._result);

  @override
  int get exitCode => _result.exitCode;

  @override
  String get stderr => _result.stderr;

  @override
  String get stdout => _result.stdout;
}

class LocalExecutionSession implements ExecutionSession {
  final Pty _pty;

  LocalExecutionSession(this._pty);

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

class _ShellCommand {
  final String command;

  final List<String> args;

  _ShellCommand(this.command, this.args);
}

_ShellCommand _resolveShell(String? customShell) {
  if (Platform.isWindows) {
    return _ShellCommand('powershell.exe', []);
  }

  final requested = customShell?.trim();
  if (requested != null && requested.isNotEmpty) {
    final defaultShell = Platform.environment['SHELL'] ?? '';
    final defaultBase = defaultShell.split('/').last;
    if (Platform.isMacOS && requested == defaultBase) {
      final user = Platform.environment['USER'];
      if (user != null && user.isNotEmpty) {
        return _ShellCommand('login', ['-fpl', user]);
      }
    }
    return _ShellCommand(
      requested,
      requested == 'sh' ? const [] : const ['-l'],
    );
  }

  if (Platform.isMacOS) {
    final user = Platform.environment['USER'];
    if (user != null && user.isNotEmpty) {
      // -l prevents login from chdir'ing to $HOME so Pty.start workingDirectory is preserved.
      return _ShellCommand('login', ['-fpl', user]);
    }
  }

  final shell = Platform.environment['SHELL'] ?? 'sh';
  return _ShellCommand(shell, []);
}

String buildLocalShellStartupCommands({
  String? workingDirectory,
  String? initCommands,
}) {
  final profileCommands = initCommands?.trim();
  if (profileCommands == null || profileCommands.isEmpty) {
    return '';
  }
  return profileCommands;
}
