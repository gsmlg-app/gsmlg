import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_ssh/app_ssh.dart';

Future<void> until(bool Function() ready) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!ready()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('SSH lifecycle');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Future<void> main(List<String> arguments) async {
  final client = SSHClient(
    await SSHSocket.connect('127.0.0.1', int.parse(arguments[0]),
        timeout: const Duration(seconds: 5)),
    username: arguments[1],
    identities: SSHKeyPair.fromPem(File(arguments[2]).readAsStringSync()),
    onVerifyHostKeySha256: (keyType, fingerprint) =>
        keyType == 'ssh-ed25519' && fingerprint.length == 32,
    keepAliveInterval: null,
  );
  try {
    await client.authenticated.timeout(const Duration(seconds: 5));
    final sibling = await client.shell();
    final siblingOutput = StringBuffer();
    sibling.stdout.listen((data) => siblingOutput.write(utf8.decode(data)));
    sibling.stderr.drain<void>();
    for (var attempt = 0; attempt < 12; attempt++) {
      final session = await client.shell();
      final output = StringBuffer();
      session.stdout.listen((data) => output.write(utf8.decode(data)));
      session.stderr.drain<void>();
      session.stdin.add(utf8.encode(
        'stty -echo\nprintf "__SHELL__:%s\\n" "\$\$"; '
        '/bin/sh -c \'printf "__JOB__:%s\\n" "\$\$"; exec sleep 60\'\n',
      ));
      final shellPattern = RegExp(r'__SHELL__:(\d+)');
      final jobPattern = RegExp(r'__JOB__:(\d+)');
      await until(() => jobPattern.hasMatch(output.toString()));
      final shellPid = shellPattern.firstMatch(output.toString())!.group(1)!;
      final jobPid = jobPattern.firstMatch(output.toString())!.group(1)!;
      session.close();
      session.close();
      await session.done.timeout(const Duration(seconds: 2));
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (true) {
        final result = utf8.decode(await client.run(
          'kill -0 $shellPid 2>/dev/null || echo shell-gone; '
          'kill -0 $jobPid 2>/dev/null || echo job-gone',
        ));
        if (result.contains('shell-gone') && result.contains('job-gone')) break;
        if (DateTime.now().isAfter(deadline)) {
          throw StateError(
              'Cancelled SSH shell or foreground job is still alive');
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    }
    sibling.stdin.add(
        utf8.encode("printf '\\123\\111\\102\\114\\111\\116\\107_OK\\n'\n"));
    await until(() => siblingOutput.toString().contains('SIBLING_OK'));
    sibling.close();
    stdout.writeln(
        'OpenSSH lifecycle: 12 shells/jobs removed; sibling and shared transport usable');
  } finally {
    client.close();
    await client.done;
  }
}
