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
  stdout.writeln(
      'Dart/native lifecycle: startup errors, output drain, repeated close, escalation passed');
}
