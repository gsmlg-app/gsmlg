import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
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
    final shell = resolveLocalShell(
      _shellCommand,
      environment: Platform.environment,
      isMacOS: Platform.isMacOS,
      isWindows: Platform.isWindows,
    );
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
      workingDirectory: resolveLocalWorkingDirectory(
        _workingDirectory,
        mergedEnv,
      ),
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

class LocalExecutionSession
    implements ExecutionSession, ForegroundProcessAware {
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

  @override
  Future<bool> hasForegroundProcess() async => _pty.hasForegroundProcess;
}

class LocalShellCommand {
  final String command;

  final List<String> args;

  const LocalShellCommand(this.command, this.args);
}

LocalShellCommand resolveLocalShell(
  String? customShell, {
  required Map<String, String> environment,
  required bool isMacOS,
  required bool isWindows,
}) {
  if (isWindows) {
    return const LocalShellCommand('powershell.exe', []);
  }

  final requested = customShell?.trim();
  if (requested != null && requested.isNotEmpty) {
    return LocalShellCommand(
      requested,
      requested == 'sh' ? const [] : const ['-l'],
    );
  }

  final defaultShell = environment['SHELL'];
  if (isMacOS) {
    final shell = (defaultShell == null || defaultShell.isEmpty)
        ? '/bin/zsh'
        : defaultShell;
    return LocalShellCommand(shell, const ['-l']);
  }

  return LocalShellCommand(defaultShell ?? 'sh', const []);
}

String? resolveLocalWorkingDirectory(
  String? requested,
  Map<String, String> environment,
) {
  final home = environment['HOME'] ?? environment['USERPROFILE'];
  final hasHome = home != null && home.isNotEmpty;

  var directory = requested?.trim() ?? '';
  if (hasHome) {
    if (directory == '~') {
      directory = home;
    } else if (directory.startsWith('~/')) {
      directory = '$home${directory.substring(1)}';
    }
  }

  if (directory.isNotEmpty && io.FileSystemEntity.isDirectorySync(directory)) {
    return directory;
  }
  if (hasHome && io.FileSystemEntity.isDirectorySync(home)) {
    return home;
  }
  return null;
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
