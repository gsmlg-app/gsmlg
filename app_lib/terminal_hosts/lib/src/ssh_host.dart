import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ssh_fs.dart';
import 'package:terminal_hosts/src/ssh_shell_wrapper.dart';

/// How long a wrapped shell may take to report its pid.
const _wrapperStartTimeout = Duration(seconds: 10);

/// Raw stdout + extended-data credit per terminal channel, including startup.
const sshTerminalReceiveWindowSize = 128 * 1024;

/// How long a working directory lookup may take.
const _workingDirectoryTimeout = Duration(seconds: 2);

class SSHHost implements Host, DirectoryShellHost {
  SSHHost(this.client);

  final SSHClient client;

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    final command = [executable, ...args].join(' ');
    final result = await client.execute(command, environment: environment);
    return _collectResult(result);
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    final sftp = await client.sftp();
    try {
      final currentDirectory = await sftp.absolute('.');
      return SSHFileSystem(sftp, currentDirectory);
    } catch (_) {
      sftp.close();
      rethrow;
    }
  }

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) => shellIn(null, width: width, height: height, environment: environment);

  /// Starts the login shell through [wrappedShellCommand] so its pid, and
  /// with it the working directory, can be looked up later. Falls back to a
  /// plain shell when the wrapper cannot run on the server.
  @override
  Future<ExecutionSession> shellIn(
    String? workingDirectory, {
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    final pty = SSHPtyConfig(height: height, width: width);
    try {
      final wrapped = _SSHExecutionSession(
        await client.execute(
          wrappedShellCommand(workingDirectory: workingDirectory),
          pty: pty,
          environment: environment,
          manualReceiveWindowSize: sshTerminalReceiveWindowSize,
        ),
        client: client,
        filter: ShellPidFilter(),
      );
      if (await wrapped.started.timeout(
        _wrapperStartTimeout,
        onTimeout: () => true,
      )) {
        return wrapped;
      }
      wrapped.discard();
    } on SSHChannelOpenError {
      rethrow;
    } catch (_) {
      // The server refused the command; use a plain shell.
    }
    return _SSHExecutionSession(
      await client.shell(
        environment: environment,
        pty: pty,
        manualReceiveWindowSize: sshTerminalReceiveWindowSize,
      ),
      client: client,
    );
  }

  @override
  Future<void> disconnect() async {
    client.close();
  }

  @override
  Future<void> get done => client.done;
}

Future<_SSHExecutionResult> _collectResult(SSHSession session) async {
  final stdout = StringBuffer();
  final stderr = StringBuffer();

  final stdoutStream = session.stdout.listen(
    (data) => stdout.write(String.fromCharCodes(data)),
  );

  final stderrStream = session.stderr.listen(
    (data) => stderr.write(String.fromCharCodes(data)),
  );

  await Future.wait<void>([
    session.done,
    stdoutStream.asFuture<void>(),
    stderrStream.asFuture<void>(),
  ]);

  return _SSHExecutionResult(
    exitCode: session.exitCode ?? 0,
    stdout: stdout.toString(),
    stderr: stderr.toString(),
  );
}

class _SSHExecutionResult implements ExecutionResult {
  _SSHExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  @override
  final int exitCode;

  @override
  final String stderr;

  @override
  final String stdout;
}

class _SSHExecutionSession implements ExecutionSession, WorkingDirectoryAware {
  _SSHExecutionSession(this.session, {required this.client, this.filter}) {
    if (filter == null) _started.complete(true);
    _subscription = session.stdout.listen(
      _onStdout,
      onError: _output.addError,
      onDone: _finishOutput,
    );
    // PTYs normally merge stderr into stdout. Drain any separate SSH stderr
    // channel data instead of letting it consume the terminal's receive window.
    _stderr = session.stderr.listen(
      (data) => session.acknowledgeReceivedBytes(data.length),
      onError: _output.addError,
    );
  }

  final SSHSession session;
  final SSHClient client;

  /// Strips the wrapper's pid marker; null for a plain shell.
  final ShellPidFilter? filter;

  late final _output = StreamController<Uint8List>(
    onPause: () => _subscription.pause(),
    onResume: () => _subscription.resume(),
  );
  final _started = Completer<bool>();
  final _credits = Queue<int>();
  late final StreamSubscription<Uint8List> _subscription;
  late final StreamSubscription<Uint8List> _stderr;
  SSHSession? _directoryQuery;
  Future<void>? _closeFuture;
  bool _closed = false;

  void _onStdout(Uint8List data) {
    if (_closed) return;
    final filter = this.filter;
    if (filter == null) {
      if (data.isNotEmpty) _output.add(data);
      return;
    }

    final previouslyHeld = filter.pendingBytes;
    final visible = filter.process(data);
    final hidden =
        previouslyHeld + data.length - filter.pendingBytes - visible.length;
    if (hidden > 0) session.acknowledgeReceivedBytes(hidden);
    if (visible.isNotEmpty) _output.add(visible);

    if (!_started.isCompleted && filter.isDone) _started.complete(true);
  }

  void _finishOutput() {
    if (_closed) return;
    final rest = filter?.flush();
    if (rest != null && rest.isNotEmpty) _output.add(rest);
    if (!_started.isCompleted) _started.complete(false);
    unawaited(_output.close());
  }

  /// Completes with true when startup has been classified, or false when
  /// the session ended before the wrapper produced a recognizable prelude.
  Future<bool> get started => _started.future;

  void discard() => unawaited(close());

  @override
  Future<String?> currentWorkingDirectory() async {
    final pid = filter?.pid;
    if (pid == null || _closed) return null;
    final expired = Completer<void>();
    final timer = Timer(_workingDirectoryTimeout, expired.complete);
    SSHSession? query;
    var finished = false;
    try {
      final opened = await client.execute(workingDirectoryQueryCommand(pid));
      query = opened;
      if (_closed || expired.isCompleted) return null;
      _directoryQuery = opened;
      const maxDirectoryResponse = 64 * 1024;
      final output = <int>[];
      final stdout = opened.stdout.listen((bytes) {
        final remaining = maxDirectoryResponse + 1 - output.length;
        if (remaining > 0) output.addAll(bytes.take(remaining));
      });
      final stderr = opened.stderr.listen((_) {});
      try {
        final completed = Future.wait<void>([
          opened.done,
          stdout.asFuture<void>(),
          stderr.asFuture<void>(),
        ], eagerError: true);
        finished = await Future.any([
          completed.then((_) => true),
          expired.future.then((_) => false),
        ]);
      } finally {
        unawaited(stdout.cancel());
        unawaited(stderr.cancel());
      }
      if (finished &&
          !_closed &&
          output.length <= maxDirectoryResponse &&
          opened.exitCode == 0) {
        return parseWorkingDirectoryQuery(utf8.decode(output));
      }
    } catch (_) {
      // Let the caller retain the last observation, including passive OSC 7.
    } finally {
      timer.cancel();
      if (identical(_directoryQuery, query)) _directoryQuery = null;
      if (!finished) query?.close();
    }
    return null;
  }

  @override
  Future<void> close() => _closeFuture ??= _close();

  Future<void> _close() async {
    _closed = true;
    _credits.clear();
    if (!_started.isCompleted) _started.complete(false);
    _directoryQuery?.close();
    session.close();
    // Cancel delivery synchronously; channel close must not wait for a paused
    // downstream subscriber or for its cleanup future.
    unawaited(_subscription.cancel());
    unawaited(_stderr.cancel());
    if (!_output.isClosed) unawaited(_output.close());
    await session.done;
  }

  @override
  Future<void> resize(int width, int height) async {
    session.resizeTerminal(width, height);
  }

  @override
  Stream<Uint8List> get output => _output.stream.map((frame) {
    if (!_closed) _credits.addLast(frame.length);
    return frame;
  });

  @override
  Future<void> write(Uint8List data) async {
    session.stdin.add(data);
  }

  @override
  Future<int> get exitCode async {
    await session.done;
    // The connection can report CHANNEL_CLOSE while visible data remains
    // queued. Consumers using exitCode must not tear down a subscribed stream
    // before those final output bytes have been delivered.
    if (_output.hasListener) await _output.done;
    return session.exitCode ?? 0;
  }

  @override
  void ackRead() {
    if (_closed || _credits.isEmpty) return;
    session.acknowledgeReceivedBytes(_credits.removeFirst());
  }
}
