import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_hosts/src/ssh_shell_wrapper.dart';

final class _Session extends Fake implements SSHSession {
  final output = StreamController<Uint8List>();
  final errors = StreamController<Uint8List>();
  final ended = Completer<void>();
  final credits = <int>[];

  void stdoutText(String text) => output.add(utf8.encode(text));
  void stderrText(String text) => errors.add(utf8.encode(text));

  @override
  Stream<Uint8List> get stdout => output.stream;
  @override
  Stream<Uint8List> get stderr => errors.stream;
  @override
  Future<void> get done => ended.future;
  @override
  int? get exitCode => ended.isCompleted ? 0 : null;
  @override
  void acknowledgeReceivedBytes(int bytes) => credits.add(bytes);
  @override
  void close() {
    if (ended.isCompleted) return;
    ended.complete();
    unawaited(output.close());
    unawaited(errors.close());
  }
}

final class _Client extends Fake implements SSHClient {
  _Client(this.session);

  final _Session session;
  int? window;

  @override
  Future<SSHSession> execute(
    String command, {
    SSHPtyConfig? pty,
    Map<String, String>? environment,
    int? manualReceiveWindowSize,
  }) async {
    window = manualReceiveWindowSize;
    return session;
  }
}

void main() {
  testWidgets('startup marker and stderr return only discarded byte credit', (
    tester,
  ) async {
    final core = _Session();
    final client = _Client(core);
    final pending = SSHHost(client).shell();
    await tester.pump();
    expect(client.window, sshTerminalReceiveWindowSize);

    const marker = '${shellPidMarkerPrefix}64\x07';
    final prefix = marker.substring(0, 14);
    core.stdoutText('pre$prefix');
    await tester.pump();
    expect(
      core.credits,
      isEmpty,
    ); // Partial marker retained, visible bytes not read.
    core.stderrText('err');
    core.stdoutText('${marker.substring(14)}post');
    await tester.pump();
    final session = await pending;
    expect(core.credits, [3, marker.length]);

    final visible = <String>[];
    final subscription = session.output.listen(
      (data) => visible.add(utf8.decode(data)),
    );
    await tester.pump();
    expect(visible, ['pre', 'post']);
    expect(core.credits, [3, marker.length]);
    session.ackRead();
    session.ackRead();
    session.ackRead();
    expect(core.credits, [3, marker.length, 3, 4]);

    subscription.pause();
    await tester.pump();
    expect(core.output.isPaused, isTrue);
    core.stdoutText('tail');
    var exited = false;
    unawaited(session.exitCode.then((_) => exited = true));
    core.close();
    await tester.pump();
    expect(exited, isFalse);
    subscription.resume();
    await tester.pump();
    expect(visible, ['pre', 'post', 'tail']);
    expect(exited, isTrue);
    await session.close();
  });

  testWidgets('no-marker scan does not block a startup window', (tester) async {
    final core = _Session();
    final pending = SSHHost(_Client(core)).shell();
    await tester.pump();
    core.stdoutText('x' * (32 * 1024));
    core.stdoutText('x' * (32 * 1024));
    core.stdoutText('x');
    await tester.pump();
    final session = await pending;
    expect(core.credits, isEmpty);
    final received = <int>[];
    final subscription = session.output.listen(received.addAll);
    await tester.pump();
    expect(received.length, 64 * 1024 + 1);
    session.ackRead();
    session.ackRead();
    session.ackRead();
    expect(core.credits, [32 * 1024, 32 * 1024, 1]);
    unawaited(subscription.cancel());
    await tester.pump();
    await session.close();
  });
}
