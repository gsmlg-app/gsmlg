import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:process_run/shell.dart' as pr;
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

import '../services/tool_executor.dart';

/// A session representing a running or completed shell command.
class ShellSession {
  ShellSession({
    required this.sessionId,
    required this.runId,
    required this.command,
    required this.host,
    required this.isPty,
    required this.startedAt,
    Process? process,
    ExecutionSession? ptySession,
    int maxBufferChars = 500000,
  }) : _process = process,
       _ptySession = ptySession,
       _maxBufferChars = maxBufferChars {
    _initDraining();
  }

  final String sessionId;
  final String runId;
  final String command;
  final String host;
  final bool isPty;
  final DateTime startedAt;
  final Process? _process;
  final ExecutionSession? _ptySession;
  final int _maxBufferChars;

  final StringBuffer _buffer = StringBuffer();
  final Completer<int> _exitCompleter = Completer<int>();
  final List<Completer<void>> _outputWaiters = [];

  bool _isClosed = false;
  int? _exitCode;
  String? _error;
  int _droppedChars = 0;

  bool get isCompleted => _exitCompleter.isCompleted;
  int? get exitCode => _exitCode;
  String? get error => _error;
  Future<int> get done => _exitCompleter.future;

  void _initDraining() {
    final proc = _process;
    final pty = _ptySession;
    if (proc != null) {
      proc.stdout.listen(
        (data) => _appendBytes(data),
        onError: (err) => _onError(err),
        onDone: () => _checkProcessExit(),
      );
      proc.stderr.listen(
        (data) => _appendBytes(data),
        onError: (err) => _onError(err),
        onDone: () => _checkProcessExit(),
      );
      proc.exitCode.then((code) {
        _exitCode = code;
        if (!_exitCompleter.isCompleted) {
          _exitCompleter.complete(code);
        }
        _notifyWaiters();
      }).catchError((err) {
        _onError(err);
      });
    } else if (pty != null) {
      pty.output.listen(
        (data) {
          _appendBytes(data);
          pty.ackRead();
        },
        onError: (err) => _onError(err),
        onDone: () => _checkPtyExit(),
      );
      pty.exitCode.then((code) {
        _exitCode = code;
        if (!_exitCompleter.isCompleted) {
          _exitCompleter.complete(code);
        }
        _notifyWaiters();
      }).catchError((err) {
        _onError(err);
      });
    } else {
      // Completed / mock session
      if (!_exitCompleter.isCompleted) {
        _exitCompleter.complete(0);
      }
    }
  }

  void _appendBytes(List<int> bytes) {
    if (_isClosed) return;
    try {
      final decoded = utf8.decode(bytes, allowMalformed: true);
      _appendString(decoded);
    } catch (_) {}
  }

  void _appendString(String text) {
    if (_isClosed) return;
    _buffer.write(text);
    if (_buffer.length > _maxBufferChars) {
      final excess = _buffer.length - _maxBufferChars;
      _droppedChars += excess;
      final remaining = _buffer.toString().substring(excess);
      _buffer.clear();
      _buffer.write(remaining);
    }
    _notifyWaiters();
  }

  void _onError(Object err) {
    _error = err.toString();
    _notifyWaiters();
  }

  void _checkProcessExit() {
    // exitCode future will finalize
  }

  void _checkPtyExit() {
    // exitCode future will finalize
  }

  void _notifyWaiters() {
    final waiters = List<Completer<void>>.from(_outputWaiters);
    _outputWaiters.clear();
    for (final waiter in waiters) {
      if (!waiter.isCompleted) {
        waiter.complete();
      }
    }
  }

  Future<void> waitForNewOutput({Duration timeout = const Duration(milliseconds: 3000)}) async {
    if (isCompleted) return;
    final completer = Completer<void>();
    _outputWaiters.add(completer);
    try {
      await completer.future.timeout(timeout);
    } on TimeoutException {
      // Return on timeout
    } finally {
      _outputWaiters.remove(completer);
    }
  }

  /// Reads buffered output starting from the given character cursor.
  Map<String, dynamic> read({int cursor = 0, int maxLength = 16000}) {
    final currentText = _buffer.toString();
    final effectiveStart = (cursor - _droppedChars).clamp(0, currentText.length);
    final available = currentText.length - effectiveStart;
    final toRead = available > maxLength ? maxLength : available;
    final output = currentText.substring(effectiveStart, effectiveStart + toRead);
    final nextCursor = _droppedChars + effectiveStart + toRead;
    final isTruncated = (available > maxLength) || (_droppedChars > 0 && cursor < _droppedChars);

    return {
      'sessionId': sessionId,
      'output': output,
      'cursor': nextCursor,
      'isTruncated': isTruncated,
      'isRunning': !isCompleted,
      'exitCode': _exitCode,
      if (_error != null) 'error': _error,
    };
  }

  /// Writes text data to process or PTY standard input.
  Future<void> write(String input) async {
    if (_isClosed || isCompleted) {
      throw StateError('Cannot write to terminated shell session $sessionId');
    }
    final proc = _process;
    final pty = _ptySession;
    if (proc != null) {
      proc.stdin.write(input);
      await proc.stdin.flush();
    } else if (pty != null) {
      final bytes = Uint8List.fromList(utf8.encode(input));
      await pty.write(bytes);
    }
  }

  /// Terminates the process tree or closes PTY.
  Future<bool> terminate([String? signal]) async {
    if (_isClosed) return true;
    _isClosed = true;

    var terminated = false;
    final proc = _process;
    final pty = _ptySession;

    if (proc != null) {
      try {
        // Kill process and descendants using process_run on desktop
        if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          pr.Shell().kill(signal == 'SIGKILL' ? ProcessSignal.sigkill : ProcessSignal.sigterm);
        }
        proc.kill(signal == 'SIGKILL' ? ProcessSignal.sigkill : ProcessSignal.sigterm);
        terminated = true;
      } catch (_) {
        try {
          proc.kill(ProcessSignal.sigkill);
          terminated = true;
        } catch (_) {}
      }
    }

    if (pty != null) {
      try {
        await pty.close();
        terminated = true;
      } catch (_) {}
    }

    if (!_exitCompleter.isCompleted) {
      _exitCode = -1;
      _exitCompleter.complete(-1);
    }
    _notifyWaiters();

    return terminated;
  }
}

/// Service managing shell execution sessions and tools.
class ShellExecutionService {
  ShellExecutionService({
    Map<String, Host>? hosts,
    bool? isMobileOverride,
  }) : _hosts = hosts ?? {},
       _isMobileOverride = isMobileOverride;

  final Map<String, Host> _hosts;
  final bool? _isMobileOverride;

  /// Active sessions mapped by sessionId.
  final Map<String, ShellSession> _sessions = {};

  /// Session IDs grouped by runId for run-scoped cleanup.
  final Map<String, List<String>> _sessionsByRunId = {};

  bool get _isMobile => _isMobileOverride ?? (Platform.isAndroid || Platform.isIOS);

  static const _execCommandTool = 'exec_command';
  static const _writeStdinTool = 'write_stdin';
  static const _readOutputTool = 'read_process_output';
  static const _terminateSessionTool = 'terminate_session';

  bool handlesTool(String toolName) => {
    _execCommandTool,
    _writeStdinTool,
    _readOutputTool,
    _terminateSessionTool,
  }.contains(toolName);

  List<ChatToolDefinition> get toolDefinitions => [
    const ChatToolDefinition(
      name: _execCommandTool,
      description: 'Execute a shell command locally or on a configured remote host. '
          'Short tasks finish and return output directly; long-running tasks return a session handle.',
      parameters: {
        'type': 'object',
        'properties': {
          'command': {
            'type': 'string',
            'description': 'The command line string or executable to run.',
          },
          'args': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'Optional arguments list for executable.',
          },
          'workingDirectory': {
            'type': 'string',
            'description': 'Optional working directory.',
          },
          'host': {
            'type': 'string',
            'description': 'Target host ID ("local" or configured SSH host). Defaults to "local".',
          },
          'pty': {
            'type': 'boolean',
            'description': 'Whether to run in an interactive PTY session. Defaults to false.',
          },
          'waitForOutput': {
            'type': 'integer',
            'description': 'Milliseconds to wait for execution to complete before backgrounding (default 3000ms).',
          },
          'timeout': {
            'type': 'integer',
            'description': 'Optional execution deadline in milliseconds.',
          },
        },
        'required': ['command'],
      },
    ),
    const ChatToolDefinition(
      name: _writeStdinTool,
      description: 'Write input data to standard input of an active shell session.',
      parameters: {
        'type': 'object',
        'properties': {
          'sessionId': {
            'type': 'string',
            'description': 'The active shell session ID.',
          },
          'input': {
            'type': 'string',
            'description': 'Input string to write to standard input.',
          },
          'waitForOutput': {
            'type': 'integer',
            'description': 'Milliseconds to wait for response output after writing (default 1000ms).',
          },
        },
        'required': ['sessionId', 'input'],
      },
    ),
    const ChatToolDefinition(
      name: _readOutputTool,
      description: 'Read incremental output from an active or completed shell session using an output cursor.',
      parameters: {
        'type': 'object',
        'properties': {
          'sessionId': {
            'type': 'string',
            'description': 'The shell session ID.',
          },
          'cursor': {
            'type': 'integer',
            'description': 'Character cursor offset from which to read output (default 0).',
          },
          'maxLength': {
            'type': 'integer',
            'description': 'Maximum characters of output to return (default 16000).',
          },
          'waitForOutput': {
            'type': 'integer',
            'description': 'Milliseconds to wait for new output if buffer is empty.',
          },
        },
        'required': ['sessionId'],
      },
    ),
    const ChatToolDefinition(
      name: _terminateSessionTool,
      description: 'Terminate an active shell execution session and cleanup its process tree.',
      parameters: {
        'type': 'object',
        'properties': {
          'sessionId': {
            'type': 'string',
            'description': 'The shell session ID to terminate.',
          },
          'signal': {
            'type': 'string',
            'description': 'Optional termination signal (SIGTERM, SIGKILL).',
          },
        },
        'required': ['sessionId'],
      },
    ),
  ];

  /// Executes shell tools through the gateway.
  Future<dynamic> executeTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    required String runId,
    required String sessionId,
    CancelToken? cancelToken,
  }) async {
    switch (toolName) {
      case _execCommandTool:
        return _execCommand(arguments, runId, cancelToken);
      case _writeStdinTool:
        return _writeStdin(arguments, runId);
      case _readOutputTool:
        return _readOutput(arguments, runId);
      case _terminateSessionTool:
        return _terminateSession(arguments, runId);
      default:
        return {'error': 'Unknown shell tool: $toolName'};
    }
  }

  Future<dynamic> _execCommand(
    Map<String, dynamic> args,
    String runId,
    CancelToken? cancelToken,
  ) async {
    final command = args['command'] as String;
    final cmdArgs = (args['args'] as List?)?.cast<String>();
    final workingDir = args['workingDirectory'] as String?;
    final host = (args['host'] as String?) ?? 'local';
    final isPty = args['pty'] == true;
    final waitForOutputMs = (args['waitForOutput'] as num?)?.toInt() ?? 3000;
    final timeoutMs = (args['timeout'] as num?)?.toInt();

    // Check mobile capability restriction
    if (_isMobile && (host == 'local' || host.isEmpty)) {
      return {
        'error': 'Local shell execution is not supported on mobile platforms. '
            'Use remote SSH hosts instead.',
        'host': host,
        'supported': false,
      };
    }

    final newSessionId = 'sh_${DateTime.now().microsecondsSinceEpoch}';

    Process? process;
    ExecutionSession? ptySession;

    try {
      if (host != 'local' && _hosts.containsKey(host)) {
        // Execute on remote host
        final remoteHost = _hosts[host]!;
        if (isPty) {
          ptySession = await remoteHost.shell();
          if (command.isNotEmpty) {
            await ptySession.write(Uint8List.fromList(utf8.encode('$command\n')));
          }
        } else {
          final res = await remoteHost.execute(
            command,
            args: cmdArgs ?? [],
          );
          return {
            'sessionId': newSessionId,
            'status': 'completed',
            'output': res.stdout + (res.stderr.isNotEmpty ? '\n${res.stderr}' : ''),
            'exitCode': res.exitCode,
            'isTruncated': false,
            'isRunning': false,
          };
        }
      } else {
        // Local execution
        if (isPty) {
          final localHost = LocalHost(workingDirectory: workingDir);
          ptySession = await localHost.shell();
          if (command.isNotEmpty) {
            await ptySession.write(Uint8List.fromList(utf8.encode('$command\n')));
          }
        } else {
          // Standard process execution
          final executable = cmdArgs != null && cmdArgs.isNotEmpty ? command : (Platform.isWindows ? 'cmd.exe' : '/bin/sh');
          final runArgs = cmdArgs != null && cmdArgs.isNotEmpty ? cmdArgs : (Platform.isWindows ? ['/c', command] : ['-c', command]);

          process = await Process.start(
            executable,
            runArgs,
            workingDirectory: workingDir,
          );
        }
      }

      final session = ShellSession(
        sessionId: newSessionId,
        runId: runId,
        command: command,
        host: host,
        isPty: isPty,
        startedAt: DateTime.now(),
        process: process,
        ptySession: ptySession,
      );

      _sessions[newSessionId] = session;
      _sessionsByRunId.putIfAbsent(runId, () => []).add(newSessionId);

      // Handle execution timeout deadline if specified
      if (timeoutMs != null && timeoutMs > 0) {
        Future.delayed(Duration(milliseconds: timeoutMs)).then((_) {
          if (!session.isCompleted) {
            session.terminate('SIGKILL');
          }
        });
      }

      // Observe token cancellation
      if (cancelToken != null) {
        cancelToken.whenCancel.then((_) {
          if (!session.isCompleted) {
            session.terminate('SIGTERM');
          }
        });
      }

      // Wait up to waitForOutputMs for process to complete or produce initial output
      if (waitForOutputMs > 0) {
        final waitFuture = session.done;
        final timeoutFuture = Future.delayed(Duration(milliseconds: waitForOutputMs));
        await Future.any([waitFuture, timeoutFuture]);
      }

      final readResult = session.read();

      if (session.isCompleted) {
        return {
          'sessionId': newSessionId,
          'status': 'completed',
          'output': readResult['output'],
          'cursor': readResult['cursor'],
          'exitCode': session.exitCode,
          'isTruncated': readResult['isTruncated'],
          'isRunning': false,
        };
      } else {
        // Still running: return session handle for polling
        return {
          'sessionId': newSessionId,
          'status': 'running',
          'output': readResult['output'],
          'cursor': readResult['cursor'],
          'isTruncated': readResult['isTruncated'],
          'isRunning': true,
        };
      }
    } catch (e) {
      return {
        'error': 'Failed to execute command: $e',
        'command': command,
        'status': 'failed',
      };
    }
  }

  Future<dynamic> _writeStdin(Map<String, dynamic> args, String runId) async {
    final sessionId = args['sessionId'] as String;
    final input = args['input'] as String;
    final waitForOutputMs = (args['waitForOutput'] as num?)?.toInt() ?? 1000;

    final session = _sessions[sessionId];
    if (session == null) {
      return {'error': 'Shell session $sessionId not found'};
    }
    if (session.runId != runId) {
      return {'error': 'Shell session $sessionId belongs to a different run'};
    }

    try {
      await session.write(input);
      if (waitForOutputMs > 0) {
        await session.waitForNewOutput(
          timeout: Duration(milliseconds: waitForOutputMs),
        );
      }
      return {
        'sessionId': sessionId,
        'status': 'written',
        'isCompleted': session.isCompleted,
      };
    } catch (e) {
      return {'error': 'Failed to write to stdin: $e'};
    }
  }

  Future<dynamic> _readOutput(Map<String, dynamic> args, String runId) async {
    final sessionId = args['sessionId'] as String;
    final cursor = (args['cursor'] as num?)?.toInt() ?? 0;
    final maxLength = (args['maxLength'] as num?)?.toInt() ?? 16000;
    final waitForOutputMs = (args['waitForOutput'] as num?)?.toInt();

    final session = _sessions[sessionId];
    if (session == null) {
      return {'error': 'Shell session $sessionId not found'};
    }
    if (session.runId != runId) {
      return {'error': 'Shell session $sessionId belongs to a different run'};
    }

    if (waitForOutputMs != null && waitForOutputMs > 0 && !session.isCompleted) {
      await session.waitForNewOutput(
        timeout: Duration(milliseconds: waitForOutputMs),
      );
    }

    return session.read(cursor: cursor, maxLength: maxLength);
  }

  Future<dynamic> _terminateSession(Map<String, dynamic> args, String runId) async {
    final sessionId = args['sessionId'] as String;
    final signal = args['signal'] as String?;

    final session = _sessions[sessionId];
    if (session == null) {
      return {'error': 'Shell session $sessionId not found'};
    }
    if (session.runId != runId) {
      return {'error': 'Shell session $sessionId belongs to a different run'};
    }

    final terminated = await session.terminate(signal);
    return {
      'sessionId': sessionId,
      'status': 'terminated',
      'terminated': terminated,
      'exitCode': session.exitCode,
    };
  }

  /// Clean up all sessions owned by the given run.
  Future<void> cleanupRun(String runId) async {
    final sessionIds = _sessionsByRunId.remove(runId);
    if (sessionIds != null) {
      for (final id in sessionIds) {
        final session = _sessions.remove(id);
        if (session != null && !session.isCompleted) {
          await session.terminate();
        }
      }
    }
  }
}
