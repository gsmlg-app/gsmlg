import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('resolveLocalShell', () {
    test('macOS default shell starts as a login shell', () {
      final shell = resolveLocalShell(
        null,
        environment: const <String, String>{'SHELL': '/bin/zsh', 'USER': 'me'},
        isMacOS: true,
        isWindows: false,
      );

      expect(shell.command, '/bin/zsh');
      expect(shell.args, <String>['-l']);
    });

    test('macOS falls back to zsh when SHELL is missing', () {
      final shell = resolveLocalShell(
        '  ',
        environment: const <String, String>{},
        isMacOS: true,
        isWindows: false,
      );

      expect(shell.command, '/bin/zsh');
      expect(shell.args, <String>['-l']);
    });

    test('profile shell matching the default shell is a login shell', () {
      final shell = resolveLocalShell(
        'zsh',
        environment: const <String, String>{'SHELL': '/bin/zsh', 'USER': 'me'},
        isMacOS: true,
        isWindows: false,
      );

      expect(shell.command, 'zsh');
      expect(shell.args, <String>['-l']);
    });

    test('sh profile shell gets no login flag', () {
      final shell = resolveLocalShell(
        'sh',
        environment: const <String, String>{'SHELL': '/bin/zsh'},
        isMacOS: true,
        isWindows: false,
      );

      expect(shell.args, isEmpty);
    });

    test('Linux default shell keeps existing behavior', () {
      final shell = resolveLocalShell(
        null,
        environment: const <String, String>{'SHELL': '/bin/bash'},
        isMacOS: false,
        isWindows: false,
      );

      expect(shell.command, '/bin/bash');
      expect(shell.args, isEmpty);
    });
  });

  group('resolveLocalWorkingDirectory', () {
    late Directory home;

    setUp(() {
      home = Directory.systemTemp.createTempSync('wt_home_');
      Directory('${home.path}/proj').createSync();
      File('${home.path}/file.txt').writeAsStringSync('x');
    });

    tearDown(() => home.deleteSync(recursive: true));

    Map<String, String> env() => <String, String>{'HOME': home.path};

    test('defaults to HOME when no directory is requested', () {
      expect(resolveLocalWorkingDirectory(null, env()), home.path);
      expect(resolveLocalWorkingDirectory('', env()), home.path);
    });

    test('expands ~ and ~/ paths', () {
      expect(resolveLocalWorkingDirectory('~', env()), home.path);
      expect(
        resolveLocalWorkingDirectory('~/proj', env()),
        '${home.path}/proj',
      );
    });

    test('keeps an existing absolute directory', () {
      expect(
        resolveLocalWorkingDirectory('${home.path}/proj', env()),
        '${home.path}/proj',
      );
    });

    test('falls back to HOME for missing paths and files', () {
      expect(resolveLocalWorkingDirectory('~/missing', env()), home.path);
      expect(
        resolveLocalWorkingDirectory('${home.path}/file.txt', env()),
        home.path,
      );
    });

    test('returns null without a usable HOME and directory', () {
      expect(
        resolveLocalWorkingDirectory('/definitely/missing', const {}),
        isNull,
      );
    });
  });
}
