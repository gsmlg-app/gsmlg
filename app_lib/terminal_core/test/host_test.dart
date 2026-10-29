import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';

// Mock implementations for testing abstract classes
class MockExecutionResult implements ExecutionResult {
  @override
  final int exitCode;
  @override
  final String stdout;
  @override
  final String stderr;

  MockExecutionResult({this.exitCode = 0, this.stdout = '', this.stderr = ''});
}

class MockExecutionSession implements ExecutionSession {
  final StreamController<Uint8List> _outputController =
      StreamController<Uint8List>.broadcast();
  final Completer<int> _exitCodeCompleter = Completer<int>();
  final List<Uint8List> writtenData = [];
  final List<(int, int)> resizeEvents = [];
  bool isClosed = false;

  @override
  Stream<Uint8List> get output => _outputController.stream;

  @override
  Future<int> get exitCode => _exitCodeCompleter.future;

  @override
  Future<void> write(Uint8List data) async {
    writtenData.add(data);
  }

  @override
  Future<void> resize(int width, int height) async {
    resizeEvents.add((width, height));
  }

  @override
  Future<void> close() async {
    if (isClosed) return;
    isClosed = true;
    if (!_exitCodeCompleter.isCompleted) {
      _exitCodeCompleter.complete(0);
    }
    await _outputController.close();
  }

  void addOutput(Uint8List data) {
    if (!_outputController.isClosed) {
      _outputController.add(data);
    }
  }

  void completeWithExitCode(int code) {
    if (!_exitCodeCompleter.isCompleted) {
      _exitCodeCompleter.complete(code);
    }
  }

  @override
  void ackRead() {
    // Mock implementation, no-op
  }
}

class MockHost implements Host {
  final Completer<void> _doneCompleter = Completer<void>();
  bool isDisconnected = false;
  final List<String> executedCommands = [];
  final List<Map<String, int>> shellRequests = [];

  MockExecutionResult? mockExecutionResult;
  MockExecutionSession? mockSession;
  FileSystem? mockFileSystem;

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  Future<void> disconnect() async {
    if (isDisconnected) return;
    isDisconnected = true;
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    executedCommands.add(executable);
    return mockExecutionResult ??
        MockExecutionResult(exitCode: 0, stdout: 'mocked output', stderr: '');
  }

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    shellRequests.add({'width': width, 'height': height});
    return mockSession ?? MockExecutionSession();
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    if (mockFileSystem != null) {
      return mockFileSystem!;
    }
    throw UnimplementedError('Mock FileSystem not provided');
  }

  void completeDone() {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }
}

void main() {
  group('ExecutionResult', () {
    test('stores exitCode', () {
      final result = MockExecutionResult(exitCode: 42);
      expect(result.exitCode, 42);
    });

    test('stores stdout', () {
      final result = MockExecutionResult(stdout: 'Hello, World!');
      expect(result.stdout, 'Hello, World!');
    });

    test('stores stderr', () {
      final result = MockExecutionResult(stderr: 'Error message');
      expect(result.stderr, 'Error message');
    });

    test('has default values', () {
      final result = MockExecutionResult();
      expect(result.exitCode, 0);
      expect(result.stdout, '');
      expect(result.stderr, '');
    });

    test('can represent successful execution', () {
      final result = MockExecutionResult(
        exitCode: 0,
        stdout: 'Success output',
        stderr: '',
      );
      expect(result.exitCode, 0);
      expect(result.stdout, isNotEmpty);
      expect(result.stderr, isEmpty);
    });

    test('can represent failed execution', () {
      final result = MockExecutionResult(
        exitCode: 1,
        stdout: '',
        stderr: 'Command not found',
      );
      expect(result.exitCode, isNot(0));
      expect(result.stderr, 'Command not found');
    });
  });

  group('ExecutionSession', () {
    test('write stores written data', () async {
      final session = MockExecutionSession();
      final data = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
      await session.write(data);
      expect(session.writtenData, contains(data));
      await session.close();
    });

    test('write can write multiple times', () async {
      final session = MockExecutionSession();
      await session.write(Uint8List.fromList([1, 2, 3]));
      await session.write(Uint8List.fromList([4, 5, 6]));
      expect(session.writtenData.length, 2);
      await session.close();
    });

    test('write preserves write order', () async {
      final session = MockExecutionSession();
      await session.write(Uint8List.fromList([1]));
      await session.write(Uint8List.fromList([2]));
      await session.write(Uint8List.fromList([3]));
      expect(session.writtenData[0][0], 1);
      expect(session.writtenData[1][0], 2);
      expect(session.writtenData[2][0], 3);
      await session.close();
    });

    test('resize stores resize events', () async {
      final session = MockExecutionSession();
      await session.resize(100, 50);
      expect(session.resizeEvents, contains((100, 50)));
      await session.close();
    });

    test('resize can resize multiple times', () async {
      final session = MockExecutionSession();
      await session.resize(80, 25);
      await session.resize(120, 40);
      expect(session.resizeEvents.length, 2);
      await session.close();
    });

    test('resize preserves resize order', () async {
      final session = MockExecutionSession();
      await session.resize(80, 25);
      await session.resize(100, 30);
      expect(session.resizeEvents[0], (80, 25));
      expect(session.resizeEvents[1], (100, 30));
      await session.close();
    });

    test('output stream is a Stream of Uint8List', () async {
      final session = MockExecutionSession();
      expect(session.output, isA<Stream<Uint8List>>());
      await session.close();
    });

    test('close marks session as closed', () async {
      final session = MockExecutionSession();
      await session.close();
      expect(session.isClosed, isTrue);
    });

    test('close completes exitCode future', () async {
      final session = MockExecutionSession();
      final codeFuture = session.exitCode;
      await session.close();
      final code = await codeFuture;
      expect(code, 0);
    });

    test('exitCode returns Future<int>', () {
      final session = MockExecutionSession();
      expect(session.exitCode, isA<Future<int>>());
    });

    test('exitCode completes with specified code', () async {
      final session = MockExecutionSession();
      session.completeWithExitCode(42);
      final code = await session.exitCode;
      expect(code, 42);
    });
  });

  group('Host', () {
    test('execute records executed command', () async {
      final host = MockHost();
      await host.execute('ls', args: ['-la']);
      expect(host.executedCommands, contains('ls'));
      await host.disconnect();
    });

    test('execute returns ExecutionResult', () async {
      final host = MockHost();
      final result = await host.execute('echo', args: ['test']);
      expect(result, isA<ExecutionResult>());
      await host.disconnect();
    });

    test('execute can execute multiple commands', () async {
      final host = MockHost();
      await host.execute('cmd1');
      await host.execute('cmd2');
      await host.execute('cmd3');
      expect(host.executedCommands.length, 3);
      await host.disconnect();
    });

    test('execute uses custom mock result when provided', () async {
      final host = MockHost();
      host.mockExecutionResult = MockExecutionResult(
        exitCode: 127,
        stderr: 'command not found',
      );

      final result = await host.execute('nonexistent');
      expect(result.exitCode, 127);
      expect(result.stderr, 'command not found');
      await host.disconnect();
    });

    test('shell records shell request', () async {
      final host = MockHost();
      final session = await host.shell(width: 100, height: 40);
      expect(host.shellRequests, isNotEmpty);
      expect(host.shellRequests.first['width'], 100);
      expect(host.shellRequests.first['height'], 40);
      await session.close();
      await host.disconnect();
    });

    test('shell returns ExecutionSession', () async {
      final host = MockHost();
      final session = await host.shell();
      expect(session, isA<ExecutionSession>());
      await session.close();
      await host.disconnect();
    });

    test('shell uses default dimensions', () async {
      final host = MockHost();
      final session = await host.shell();
      expect(host.shellRequests.first['width'], 80);
      expect(host.shellRequests.first['height'], 25);
      await session.close();
      await host.disconnect();
    });

    test('disconnect marks host as disconnected', () async {
      final host = MockHost();
      await host.disconnect();
      expect(host.isDisconnected, isTrue);
    });

    test('disconnect completes done future', () async {
      final host = MockHost();
      final doneFuture = host.done;
      await host.disconnect();
      await expectLater(doneFuture, completes);
    });

    test('done returns Future<void>', () {
      final host = MockHost();
      expect(host.done, isA<Future<void>>());
    });

    test('done completes when completeDone is called', () async {
      final host = MockHost();
      final doneFuture = host.done;
      host.completeDone();
      await expectLater(doneFuture, completes);
    });
  });

  group('Interface contract', () {
    test('Host can be implemented', () {
      final host = MockHost();
      expect(host, isA<Host>());
    });

    test('ExecutionResult can be implemented', () {
      final result = MockExecutionResult();
      expect(result, isA<ExecutionResult>());
    });

    test('ExecutionSession can be implemented', () {
      final session = MockExecutionSession();
      expect(session, isA<ExecutionSession>());
    });
  });
}
