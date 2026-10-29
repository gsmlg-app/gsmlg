import 'dart:async';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/src/ssh_host.dart';

class _Session implements SSHSession {
  final output = StreamController<Uint8List>();
  final errors = StreamController<Uint8List>();
  final closed = Completer<void>();

  @override
  Stream<Uint8List> get stdout => output.stream;

  @override
  Stream<Uint8List> get stderr => errors.stream;

  @override
  Future<void> get done => closed.future;

  @override
  int get exitCode => 7;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Client implements SSHClient {
  _Client(this.session);

  final SSHSession session;

  @override
  Future<SSHSession> execute(
    String command, {
    SSHPtyConfig? pty,
    Map<String, String>? environment,
  }) async => session;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'collects stdout and stderr when EOF arrives before channel close',
    () async {
      final session = _Session();
      final result = SSHHost(_Client(session)).execute('uptime');
      session.output.add(Uint8List.fromList('result'.codeUnits));
      session.errors.add(Uint8List.fromList('warning'.codeUnits));
      await session.output.close();
      await session.errors.close();
      session.closed.complete();

      final collected = await result.timeout(const Duration(milliseconds: 200));
      expect(collected.stdout, 'result');
      expect(collected.stderr, 'warning');
      expect(collected.exitCode, 7);
    },
  );

  test('waits for buffered stdout and stderr after channel close', () async {
    final session = _Session();
    final result = SSHHost(_Client(session)).execute('uptime');
    session.closed.complete();
    session.output.add(Uint8List.fromList('result'.codeUnits));
    session.errors.add(Uint8List.fromList('warning'.codeUnits));
    await session.output.close();
    await session.errors.close();

    final collected = await result.timeout(const Duration(milliseconds: 200));
    expect(collected.stdout, 'result');
    expect(collected.stderr, 'warning');
  });
}
