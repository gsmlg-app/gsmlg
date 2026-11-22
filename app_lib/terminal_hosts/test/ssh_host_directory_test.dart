import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:app_ssh/app_ssh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

/// Real-server tests. Set WEBTERMINAL_TEST_SSHD to `host:port:user:keyfile`,
/// and optionally WEBTERMINAL_TEST_SSHD_FORCED to the same for a server with
/// a ForceCommand.
({String host, int port, String user, String key})? _server(String name) {
  final value = io.Platform.environment[name];
  if (value == null) return null;
  final parts = value.split(':');
  return (
    host: parts[0],
    port: int.parse(parts[1]),
    user: parts[2],
    key: parts.sublist(3).join(':'),
  );
}

Future<SSHHost> _connect(
  ({String host, int port, String user, String key}) server,
) async {
  final client = SSHClient(
    await SSHSocket.connect(server.host, server.port),
    username: server.user,
    identities: SSHKeyPair.fromPem(io.File(server.key).readAsStringSync()),
    onVerifyHostKeySha256: (_, _) => true,
    keepAliveInterval: null,
  );
  await client.authenticated;
  return SSHHost(client);
}

Future<String?> _cwd(ExecutionSession session) =>
    (session as WorkingDirectoryAware).currentWorkingDirectory();

class _Screen {
  _Screen(ExecutionSession session) {
    session.output.listen((data) => text.write(utf8.decode(data)));
  }

  final text = StringBuffer();

  Future<void> waitFor(Pattern pattern) async {
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (!text.toString().contains(pattern)) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('waiting for $pattern in:\n$text');
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }
}

void main() {
  final server = _server('WEBTERMINAL_TEST_SSHD');
  final forced = _server('WEBTERMINAL_TEST_SSHD_FORCED');

  late io.Directory tmp;
  setUp(() {
    tmp = io.Directory(
      io.Directory.systemTemp
          .createTempSync('ssh-dir ')
          .resolveSymbolicLinksSync(),
    );
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('shellIn starts in the directory and reports it', () async {
    final host = await _connect(server!);
    addTearDown(host.disconnect);
    final target = io.Directory("${tmp.path}/it's 中文")..createSync();

    final session = await host.shellIn(target.path);
    final screen = _Screen(session);
    await session.write(utf8.encode('echo "AT=\$PWD"\n'));
    await screen.waitFor('AT=${target.path}');

    expect(screen.text.toString(), isNot(contains('WebTerminalShellPid')));
    expect(session, isA<WorkingDirectoryAware>());
    expect(await _cwd(session), target.path);

    await session.write(utf8.encode('cd "${tmp.path}"; echo MO""VED\n'));
    await screen.waitFor('MOVED');
    expect(await _cwd(session), tmp.path);
    await session.close();
  }, skip: server == null ? 'WEBTERMINAL_TEST_SSHD not set' : false);

  test('shell() is also directory aware', () async {
    final host = await _connect(server!);
    addTearDown(host.disconnect);

    final session = await host.shell();
    final screen = _Screen(session);
    await session.write(utf8.encode('cd "${tmp.path}"; echo RE""ADY\n'));
    await screen.waitFor('READY');

    expect(await _cwd(session), tmp.path);
    await session.close();
  }, skip: server == null ? 'WEBTERMINAL_TEST_SSHD not set' : false);

  test('falls back to a plain shell when the wrapper cannot run', () async {
    final host = await _connect(forced!);
    addTearDown(host.disconnect);

    final session = await host.shellIn(tmp.path);
    final screen = _Screen(session);
    await screen.waitFor('FORCED-');

    expect(screen.text.toString().split('FORCED-').length, 2);
    expect(await _cwd(session), isNull);
  }, skip: forced == null ? 'WEBTERMINAL_TEST_SSHD_FORCED not set' : false);
}
