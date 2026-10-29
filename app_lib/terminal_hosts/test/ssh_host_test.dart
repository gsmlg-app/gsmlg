import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';

/// Mock classes for testing SSH host-related functionality without real SSH connections.
/// These test the interface contracts and data structures.

void main() {
  group('SSHExecutionResult interface', () {
    test('can create implementation with all fields', () {
      final result = MockSSHExecutionResult(
        exitCode: 0,
        stdout: 'hello world',
        stderr: '',
      );

      expect(result.exitCode, 0);
      expect(result.stdout, 'hello world');
      expect(result.stderr, '');
    });

    test('exitCode represents success', () {
      final result = MockSSHExecutionResult(
        exitCode: 0,
        stdout: 'done',
        stderr: '',
      );

      expect(result.exitCode == 0, isTrue);
    });

    test('exitCode represents failure', () {
      final result = MockSSHExecutionResult(
        exitCode: 1,
        stdout: '',
        stderr: 'command not found',
      );

      expect(result.exitCode != 0, isTrue);
    });

    test('stdout can be multiline', () {
      final result = MockSSHExecutionResult(
        exitCode: 0,
        stdout: 'line1\nline2\nline3',
        stderr: '',
      );

      expect(result.stdout.split('\n').length, 3);
    });

    test('stderr can contain error messages', () {
      final result = MockSSHExecutionResult(
        exitCode: 2,
        stdout: '',
        stderr: 'permission denied\noperation failed',
      );

      expect(result.stderr.contains('permission denied'), isTrue);
    });

    test('stdout and stderr can both have content', () {
      final result = MockSSHExecutionResult(
        exitCode: 0,
        stdout: 'processing...\ndone',
        stderr: 'warning: deprecated',
      );

      expect(result.stdout.isNotEmpty, isTrue);
      expect(result.stderr.isNotEmpty, isTrue);
    });
  });

  group('SSHExecutionSession interface', () {
    test('can write data to session', () async {
      final session = MockSSHExecutionSession();
      await session.write(Uint8List.fromList([104, 105])); // "hi"

      expect(session.writtenData.length, 1);
      expect(session.writtenData.first, Uint8List.fromList([104, 105]));
    });

    test('can write multiple chunks', () async {
      final session = MockSSHExecutionSession();
      await session.write(Uint8List.fromList([72, 69, 76, 76, 79])); // HELLO
      await session.write(Uint8List.fromList([87, 79, 82, 76, 68])); // WORLD

      expect(session.writtenData.length, 2);
    });

    test('can resize terminal', () async {
      final session = MockSSHExecutionSession();
      await session.resize(120, 40);

      expect(session.lastWidth, 120);
      expect(session.lastHeight, 40);
    });

    test('resize with different dimensions', () async {
      final session = MockSSHExecutionSession();

      await session.resize(80, 24);
      expect(session.lastWidth, 80);
      expect(session.lastHeight, 24);

      await session.resize(132, 50);
      expect(session.lastWidth, 132);
      expect(session.lastHeight, 50);
    });

    test('output stream emits data', () async {
      final session = MockSSHExecutionSession();
      final received = <Uint8List>[];

      session.output.listen(received.add);
      session.emitOutput(Uint8List.fromList([65, 66, 67]));

      await Future.delayed(const Duration(milliseconds: 10));
      expect(received.length, 1);
      expect(received.first, Uint8List.fromList([65, 66, 67]));
    });

    test('output stream can emit multiple chunks', () async {
      final session = MockSSHExecutionSession();
      final received = <Uint8List>[];

      session.output.listen(received.add);
      session.emitOutput(Uint8List.fromList([1, 2, 3]));
      session.emitOutput(Uint8List.fromList([4, 5, 6]));

      await Future.delayed(const Duration(milliseconds: 10));
      expect(received.length, 2);
    });

    test('close completes without error', () async {
      final session = MockSSHExecutionSession();
      await session.close();

      expect(session.isClosed, isTrue);
    });

    test('exitCode is available after close', () async {
      final session = MockSSHExecutionSession(exitCode: 0);
      await session.close();

      final code = await session.exitCode;
      expect(code, 0);
    });

    test('exitCode can be non-zero', () async {
      final session = MockSSHExecutionSession(exitCode: 1);
      await session.close();

      final code = await session.exitCode;
      expect(code, 1);
    });
  });

  group('Host interface contracts', () {
    test('execute method returns ExecutionResult', () async {
      final host = MockSSHHost();
      final result = await host.execute('ls', args: ['-la']);

      expect(result, isA<ExecutionResult>());
      expect(result.exitCode, isA<int>());
    });

    test('execute with environment variables', () async {
      final host = MockSSHHost();
      final result = await host.execute(
        'echo',
        args: ['\$FOO'],
        environment: {'FOO': 'bar'},
      );

      expect(result, isA<ExecutionResult>());
    });

    test('shell method returns ExecutionSession', () async {
      final host = MockSSHHost();
      final session = await host.shell(width: 80, height: 24);

      expect(session, isA<ExecutionSession>());
    });

    test('shell with custom dimensions', () async {
      final host = MockSSHHost();
      final session = await host.shell(width: 120, height: 40);

      expect(session, isA<ExecutionSession>());
    });

    test('shell with environment', () async {
      final host = MockSSHHost();
      final session = await host.shell(environment: {'TERM': 'xterm-256color'});

      expect(session, isA<ExecutionSession>());
    });

    test('connectFileSystem returns FileSystem', () async {
      final host = MockSSHHost();
      final fs = await host.connectFileSystem();

      expect(fs, isA<FileSystem>());
    });

    test('disconnect completes without error', () async {
      final host = MockSSHHost();
      await host.disconnect();

      expect(host.isDisconnected, isTrue);
    });

    test('done future completes after disconnect', () async {
      final host = MockSSHHost();
      await host.disconnect();

      // done should complete
      await host.done;
    });
  });

  group('SSH connection state management', () {
    test('host can be created and disconnected', () async {
      final host = MockSSHHost();
      expect(host.isDisconnected, isFalse);

      await host.disconnect();
      expect(host.isDisconnected, isTrue);
    });

    test('shell session lifecycle', () async {
      final host = MockSSHHost();
      final session = await host.shell();

      expect(session, isA<ExecutionSession>());

      await session.close();
      // Session should be closed
    });

    test('multiple execute calls work', () async {
      final host = MockSSHHost();

      final result1 = await host.execute('ls');
      final result2 = await host.execute('pwd');

      expect(result1, isA<ExecutionResult>());
      expect(result2, isA<ExecutionResult>());
    });

    test('multiple shell sessions can be created', () async {
      final host = MockSSHHost();

      final session1 = await host.shell();
      final session2 = await host.shell();

      expect(session1, isA<ExecutionSession>());
      expect(session2, isA<ExecutionSession>());

      await session1.close();
      await session2.close();
    });
  });

  group('ExecutionResult data handling', () {
    test('empty stdout', () {
      final result = MockSSHExecutionResult(
        exitCode: 0,
        stdout: '',
        stderr: '',
      );

      expect(result.stdout, isEmpty);
    });

    test('large stdout', () {
      final largeOutput = 'x' * 10000;
      final result = MockSSHExecutionResult(
        exitCode: 0,
        stdout: largeOutput,
        stderr: '',
      );

      expect(result.stdout.length, 10000);
    });

    test('binary-like content in stdout', () {
      final result = MockSSHExecutionResult(
        exitCode: 0,
        stdout: String.fromCharCodes([0, 1, 2, 255]),
        stderr: '',
      );

      expect(result.stdout.codeUnits, contains(255));
    });

    test('unicode in stdout', () {
      final result = MockSSHExecutionResult(
        exitCode: 0,
        stdout: '你好世界 🌍',
        stderr: '',
      );

      expect(result.stdout.contains('你好'), isTrue);
      expect(result.stdout.contains('🌍'), isTrue);
    });
  });
}

/// Mock implementation of ExecutionResult for testing
class MockSSHExecutionResult implements ExecutionResult {
  MockSSHExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  @override
  final int exitCode;

  @override
  final String stdout;

  @override
  final String stderr;
}

/// Mock implementation of ExecutionSession for testing
class MockSSHExecutionSession implements ExecutionSession {
  MockSSHExecutionSession({int? exitCode}) : _exitCode = exitCode ?? 0;

  final int _exitCode;
  final List<Uint8List> writtenData = [];
  final StreamController<Uint8List> _outputController =
      StreamController<Uint8List>.broadcast();
  int? lastWidth;
  int? lastHeight;
  bool isClosed = false;

  void emitOutput(Uint8List data) {
    _outputController.add(data);
  }

  @override
  Future<void> close() async {
    isClosed = true;
    await _outputController.close();
  }

  @override
  Future<int> get exitCode async => _exitCode;

  @override
  Stream<Uint8List> get output => _outputController.stream;

  @override
  Future<void> resize(int width, int height) async {
    lastWidth = width;
    lastHeight = height;
  }

  @override
  Future<void> write(Uint8List data) async {
    writtenData.add(data);
  }

  @override
  void ackRead() {
    // Mock implementation, no-op
  }
}

/// Mock implementation of Host for testing
class MockSSHHost implements Host {
  bool isDisconnected = false;
  final Completer<void> _doneCompleter = Completer<void>();

  @override
  Future<void> disconnect() async {
    isDisconnected = true;
    _doneCompleter.complete();
  }

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    return MockSSHExecutionResult(
      exitCode: 0,
      stdout: 'mock output',
      stderr: '',
    );
  }

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    return MockSSHExecutionSession();
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    return MockSSHFileSystem();
  }
}

/// Mock FileSystem for Host.connectFileSystem()
/// Note: Uses noSuchMethod to implement complex interfaces
class MockSSHFileSystem implements FileSystem {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Return null for all methods - this is a minimal mock
    return null;
  }

  @override
  bool get isWatchSupported => false;
}
