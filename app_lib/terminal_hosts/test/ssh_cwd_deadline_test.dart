import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  testWidgets('cwd deadline closes only the acquired exec channel', (
    tester,
  ) async {
    final client = _Client();
    final pendingShell = SSHHost(client).shell();
    final shellChannel = _Channel();
    client.opens.single.complete(shellChannel);
    shellChannel.emit('\x1b]1337;WebTerminalShellPid=42\x07');
    await tester.pump();
    final shell = (await pendingShell) as WorkingDirectoryAware;

    final pendingDirectory = shell.currentWorkingDirectory();
    final cwdChannel = _Channel();
    client.opens.last.complete(cwdChannel);
    await tester.pump();
    cwdChannel.emit('/partial');
    await tester.pump(const Duration(seconds: 2));

    expect(await pendingDirectory, isNull);
    expect(cwdChannel.closed, isTrue);
    expect(shellChannel.closed, isFalse);
    expect(client.closed, isFalse);
    await (shell as ExecutionSession).close();
  });

  testWidgets('opening cwd exec retains ownership through the deadline', (
    tester,
  ) async {
    final client = _Client();
    final pendingShell = SSHHost(client).shell();
    final shellChannel = _Channel();
    client.opens.single.complete(shellChannel);
    shellChannel.emit('\x1b]1337;WebTerminalShellPid=42\x07');
    await tester.pump();
    final shell = (await pendingShell) as WorkingDirectoryAware;

    var settled = false;
    final pendingDirectory = shell.currentWorkingDirectory();
    unawaited(pendingDirectory.then((_) => settled = true));
    await tester.pump(const Duration(seconds: 2));
    expect(settled, isFalse);
    final lateChannel = _Channel();
    client.opens.last.complete(lateChannel);
    await tester.pump();

    expect(await pendingDirectory, isNull);
    expect(lateChannel.closed, isTrue);
    expect(shellChannel.closed, isFalse);
    expect(client.closed, isFalse);
    await (shell as ExecutionSession).close();
  });
}

class _Client extends Fake implements SSHClient {
  final opens = <Completer<SSHSession>>[];
  bool closed = false;

  @override
  Future<SSHSession> execute(
    String command, {
    SSHPtyConfig? pty,
    Map<String, String>? environment,
    int? manualReceiveWindowSize,
  }) {
    final opening = Completer<SSHSession>();
    opens.add(opening);
    return opening.future;
  }

  @override
  void close() => closed = true;
}

class _Channel extends Fake implements SSHSession {
  final _stdout = StreamController<Uint8List>();
  final _stderr = StreamController<Uint8List>();
  final _done = Completer<void>();
  bool closed = false;

  void emit(String text) => _stdout.add(utf8.encode(text));

  @override
  void acknowledgeReceivedBytes(int bytes) {}

  @override
  Stream<Uint8List> get stdout => _stdout.stream;

  @override
  Stream<Uint8List> get stderr => _stderr.stream;

  @override
  Future<void> get done => _done.future;

  @override
  int? get exitCode => closed ? 0 : null;

  @override
  void close() {
    if (closed) return;
    closed = true;
    _done.complete();
    unawaited(_stdout.close());
    unawaited(_stderr.close());
  }
}
