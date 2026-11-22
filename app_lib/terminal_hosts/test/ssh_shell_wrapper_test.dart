import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/src/ssh_shell_wrapper.dart';

Uint8List _bytes(String text) => Uint8List.fromList(utf8.encode(text));

String _marker(int pid) => '\x1b]1337;WebTerminalShellPid=$pid\x07';

String _filterAll(ShellPidFilter filter, List<String> chunks) {
  final out = BytesBuilder();
  for (final chunk in chunks) {
    out.add(filter.process(_bytes(chunk)));
  }
  out.add(filter.flush());
  return utf8.decode(out.takeBytes());
}

void main() {
  group('wrappedShellCommand', () {
    late Directory tmp;
    late File fakeShell;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('ssh-wrap-');
      tmp = Directory(tmp.resolveSymbolicLinksSync());
      fakeShell = File('${tmp.path}/fake-login-shell')
        ..writeAsStringSync('#!/bin/sh\necho "PID=\$\$"\necho "PWD=\$(pwd)"\n');
      Process.runSync('chmod', ['+x', fakeShell.path]);
    });
    tearDown(() => tmp.deleteSync(recursive: true));

    final loginShells = [
      '/bin/sh',
      '/bin/bash',
      '/bin/zsh',
      '/bin/tcsh',
    ].where((String shell) => File(shell).existsSync());

    const awkwardNames = [
      'plain',
      'with space',
      "it's",
      'quote"d',
      r'dollar $HOME',
      r'back\slash',
      'pct %s %%',
      '中文 目录',
      'bang!',
    ];

    for (final loginShell in loginShells) {
      for (final name in awkwardNames) {
        test('$loginShell starts in "$name" and reports the shell pid', () {
          final target = Directory('${tmp.path}/$name')..createSync();

          final result = Process.runSync(
            loginShell,
            ['-c', wrappedShellCommand(workingDirectory: target.path)],
            environment: {'SHELL': fakeShell.path},
            workingDirectory: tmp.path,
            stdoutEncoding: utf8,
          );
          final output = result.stdout as String;

          expect(result.exitCode, 0, reason: '${result.stderr}');
          final marker = RegExp(
            '\x1b\\]1337;WebTerminalShellPid=(\\d+)\x07',
          ).firstMatch(output);
          expect(marker, isNotNull, reason: output);
          expect(output, contains('PID=${marker!.group(1)}\n'));
          expect(output, contains('PWD=${target.path}\n'));
        });
      }
    }

    test('a missing directory still starts the login shell', () {
      final result = Process.runSync(
        '/bin/sh',
        ['-c', wrappedShellCommand(workingDirectory: '${tmp.path}/gone')],
        environment: {'SHELL': fakeShell.path},
        workingDirectory: tmp.path,
      );

      expect(result.exitCode, 0);
      expect(result.stdout as String, contains('PWD=${tmp.path}\n'));
    });

    test('without a directory it does not change directory', () {
      final command = wrappedShellCommand();

      expect(command, isNot(contains('cd ')));
      final result = Process.runSync(
        '/bin/sh',
        ['-c', command],
        environment: {'SHELL': fakeShell.path},
        workingDirectory: tmp.path,
      );
      expect(result.stdout as String, contains('PWD=${tmp.path}\n'));
    });
  });

  group('ShellPidFilter', () {
    test('removes the marker and records the pid', () {
      final filter = ShellPidFilter();

      final text = _filterAll(filter, ['${_marker(4321)}Welcome\r\n\$ ']);

      expect(text, 'Welcome\r\n\$ ');
      expect(filter.pid, 4321);
    });

    test('handles the marker split into single bytes', () {
      final filter = ShellPidFilter();
      final input = 'rc says hi\r\n${_marker(77)}\$ ';

      final text = _filterAll(filter, [
        for (final rune in input.split('')) rune,
      ]);

      expect(text, 'rc says hi\r\n\$ ');
      expect(filter.pid, 77);
    });

    test('passes output through untouched when there is no marker', () {
      final filter = ShellPidFilter();

      final text = _filterAll(filter, ['hello \x1b]0;title\x07', 'world']);

      expect(text, 'hello \x1b]0;title\x07world');
      expect(filter.pid, isNull);
    });

    test('a later marker-like sequence is left alone', () {
      final filter = ShellPidFilter();

      final text = _filterAll(filter, [_marker(1), 'x', _marker(2)]);

      expect(text, 'x${_marker(2)}');
      expect(filter.pid, 1);
    });

    test('a broken marker is released as normal output', () {
      final filter = ShellPidFilter();

      final text = _filterAll(filter, [
        '\x1b]1337;WebTerminalShellPid=12',
        'zz\x07rest',
      ]);

      expect(text, '\x1b]1337;WebTerminalShellPid=12zz\x07rest');
      expect(filter.pid, isNull);
    });
  });

  group('workingDirectoryQueryCommand', () {
    test('reports the directory of a running process', () async {
      final dir = Directory.systemTemp.createTempSync('ssh-cwd q ');
      final resolved = dir.resolveSymbolicLinksSync();
      final sleeper = await Process.start('sleep', [
        '30',
      ], workingDirectory: resolved);
      addTearDown(() {
        sleeper.kill();
        dir.deleteSync(recursive: true);
      });

      final result = Process.runSync('/bin/sh', [
        '-c',
        workingDirectoryQueryCommand(sleeper.pid),
      ], stdoutEncoding: utf8);

      expect(parseWorkingDirectoryQuery(result.stdout as String), resolved);
    });

    test('parse trims the trailing newline and rejects junk', () {
      expect(parseWorkingDirectoryQuery('/srv/app\n'), '/srv/app');
      expect(parseWorkingDirectoryQuery(''), isNull);
      expect(parseWorkingDirectoryQuery('not a path\n'), isNull);
    });
  });
}
