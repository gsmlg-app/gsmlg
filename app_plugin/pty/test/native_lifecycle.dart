import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> main() async {
  for (var attempt = 0; attempt < 16; attempt++) {
    try {
      Pty.start('/missing-pty-shell');
      throw StateError('A missing executable must fail during startup');
    } on ProcessException catch (error) {
      check(error.message.contains('No such file'), 'Missing native error');
    }
  }

  for (var attempt = 0; attempt < 32; attempt++) {
    final pty = Pty.start(
      '/bin/sh',
      arguments: ['-c', 'printf final-output'],
      ackRead: true,
    );
    final output = pty.output.expand((data) => data).toList();
    check(await pty.exitCode.timeout(const Duration(seconds: 3)) == 0, 'Exit');
    check(utf8.decode(await output) == 'final-output', 'Lost final output');
    await Future.wait([pty.close(), pty.close()]);
    pty.ackRead();
    pty.resize(30, 100);
    pty.write(Uint8List.fromList([10]));
    check(!pty.kill(), 'An exited PTY must not signal a reused PID');
  }

  final stubborn = Pty.start(
    '/bin/sh',
    arguments: [
      '-c',
      'trap "" HUP TERM; printf ready; while :; do sleep 1; done'
    ],
    ackRead: true,
  );
  final ready = Completer<void>();
  stubborn.output.listen((data) {
    if (!ready.isCompleted) ready.complete();
  });
  await ready.future.timeout(const Duration(seconds: 3));
  final stopwatch = Stopwatch()..start();
  await Future.wait([stubborn.close(), stubborn.close()]);
  check(stopwatch.elapsed < const Duration(seconds: 3), 'Unbounded close');
  check(await stubborn.exitCode == -ProcessSignal.sigkill.signalNumber,
      'Close did not escalate to SIGKILL');

  final cwdShell = Pty.start(
    '/bin/bash',
    arguments: ['--noprofile', '--norc', '-i'],
    workingDirectory: '/usr',
  );
  cwdShell.output.listen((_) {});
  try {
    check(cwdShell.currentWorkingDirectory == '/usr',
        'Expected the shell to start in /usr');
    cwdShell.write(utf8.encode('cd /usr/bin\n'));
    final cwdDeadline = DateTime.now().add(const Duration(seconds: 3));
    while (cwdShell.currentWorkingDirectory != '/usr/bin') {
      if (DateTime.now().isAfter(cwdDeadline)) {
        throw TimeoutException('Working directory did not follow cd');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  } finally {
    await cwdShell.close();
  }
  check(cwdShell.currentWorkingDirectory == null,
      'Expected no working directory after close');

  for (final prefix in ['', 'true | ']) {
    final interactive = Pty.start(
      '/bin/bash',
      arguments: ['--noprofile', '--norc', '-i'],
      ackRead: true,
    );
    final foregroundOutput = StringBuffer();
    interactive.output.listen((data) {
      foregroundOutput.write(utf8.decode(data, allowMalformed: true));
      interactive.ackRead();
    });
    int? foregroundPid;
    try {
      interactive.write(utf8.encode(
        '$prefix'
        r'''/bin/sh -c 'trap "" HUP TERM; printf "__FOREGROUND__:%s\n" "$$"; exec sleep 60' '''
        '\n',
      ));
      final pattern = RegExp(r'__FOREGROUND__:(\d+)');
      final deadline = DateTime.now().add(const Duration(seconds: 3));
      while (!pattern.hasMatch(foregroundOutput.toString())) {
        if (DateTime.now().isAfter(deadline)) {
          throw TimeoutException('Foreground job did not start');
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      foregroundPid =
          int.parse(pattern.firstMatch(foregroundOutput.toString())!.group(1)!);
      check(foregroundPid != interactive.pid,
          'Expected a separate foreground job');
      await interactive.close();
      final stopped = DateTime.now().add(const Duration(seconds: 3));
      while (
          (await Process.run('/bin/kill', ['-0', '$foregroundPid'])).exitCode ==
              0) {
        if (DateTime.now().isAfter(stopped)) {
          throw StateError('Foreground job survived closing the PTY');
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    } finally {
      await interactive.close();
      if (foregroundPid != null) {
        Process.killPid(foregroundPid, ProcessSignal.sigkill);
      }
    }
  }
  final shell = Pty.start(
    '/bin/sh',
    arguments: ['-i'],
    environment: {'PS1': r'$ '},
  );
  final shellOutput = StringBuffer();
  shell.output.listen((data) {
    shellOutput.write(utf8.decode(data, allowMalformed: true));
  });
  try {
    final prompt = DateTime.now().add(const Duration(seconds: 3));
    while (shellOutput.isEmpty) {
      if (DateTime.now().isAfter(prompt)) {
        throw TimeoutException('Shell prompt did not appear');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    check(shell.foregroundProcessGroup == shell.pid, 'Shell owns foreground');
    check(!shell.hasForegroundProcess, 'Idle shell reported busy');
    shell.write(utf8.encode('sleep 5\n'));
    final busy = DateTime.now().add(const Duration(seconds: 3));
    while (!shell.hasForegroundProcess) {
      if (DateTime.now().isAfter(busy)) {
        throw TimeoutException('Foreground sleep was not detected');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    shell.write(Uint8List.fromList([3]));
    final idle = DateTime.now().add(const Duration(seconds: 3));
    while (shell.hasForegroundProcess) {
      if (DateTime.now().isAfter(idle)) {
        throw TimeoutException('Interrupted sleep still in foreground');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  } finally {
    await shell.close();
  }
  check(!shell.hasForegroundProcess, 'Closed PTY reported busy');
  check(shell.foregroundProcessGroup == null, 'Closed PTY has a group');

  stdout.writeln(
      'Dart/native lifecycle: startup errors, output drain, repeated close, escalation, foreground detection passed');
}
