import 'dart:convert';
import 'dart:io';

import 'package:android_shell/android_shell.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_hosts/src/android_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.gsmlg/android_shell');
  late Directory directory;
  late AndroidShellEnv environment;

  setUp(() async {
    AndroidShellEnv.reset();
    directory = await Directory.systemTemp.createTemp('android_host_');
    final proot = File('${directory.path}/native/libproot.so');
    await proot.parent.create();
    await proot.writeAsString(r'''#!/bin/sh
printf '%s\n' "$HOME" "$USER" "$LOGNAME" "$SHELL" "$WEB_TERMINAL_USER" "$CUSTOM_VALUE" 'ARGS'
printf '%s\n' "$@"
''');
    await Process.run('/bin/chmod', ['+x', proot.path]);
    await Directory('${directory.path}/rootfs/root').create(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => <String, String>{
            'filesDir': directory.path,
            'rootfsPath': '${directory.path}/rootfs',
            'nativeLibDir': proot.parent.path,
            'prootPath': proot.path,
            'homePath': '${directory.path}/rootfs/home/gao',
            'userName': 'gao',
            'userId': '1000',
            'groupId': '1000',
            'guestHome': '/home/gao',
            'guestShell': '/bin/zsh',
          },
        );
    environment = AndroidShellEnv.instance;
    await environment.initialize();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    AndroidShellEnv.reset();
    await directory.delete(recursive: true);
  });

  test(
    'normal execution uses configured identity and preserves custom env',
    () async {
      final host = AndroidHost(
        environment,
        environment: {'CUSTOM_VALUE': 'profile'},
      );
      final result = await host.execute('printf', args: ['two words']);
      expect(result.exitCode, 0);
      final lines = const LineSplitter().convert(result.stdout);
      expect(lines.take(6), [
        '/home/gao',
        'gao',
        'gao',
        '/bin/zsh',
        'gao',
        'profile',
      ]);
      expect(lines, containsAllInOrder(['-i', '1000:1000', '-w', '/home/gao']));
      expect(lines.last, 'two words');
    },
  );

  test(
    'administrator selector chooses root and protects identity fields',
    () async {
      final host = AndroidHost(
        environment,
        environment: {
          'WEB_TERMINAL_USER': 'root',
          'HOME': '/wrong-home',
          'USER': 'wrong-user',
          'LOGNAME': 'wrong-name',
          'SHELL': '/wrong-shell',
        },
      );
      final result = await host.execute('apk');
      final lines = const LineSplitter().convert(result.stdout);
      expect(lines.take(5), ['/root', 'root', 'root', '/bin/zsh', 'root']);
      expect(lines, containsAllInOrder(['-0', '-w', '/root']));
      expect(lines, isNot(contains('-i')));
    },
  );

  test(
    'root argument works without administrator environment selector',
    () async {
      final result = await AndroidHost(environment).execute('apk', root: true);
      final lines = const LineSplitter().convert(result.stdout);
      expect(lines.take(5), ['/root', 'root', 'root', '/bin/zsh', 'root']);
      expect(lines, contains('-0'));
    },
  );

  test('session selector overrides profile administrator selection', () async {
    final host = AndroidHost(
      environment,
      environment: {'WEB_TERMINAL_USER': 'root'},
    );
    final result = await host.execute(
      'id',
      environment: {'WEB_TERMINAL_USER': 'gao'},
    );
    final lines = const LineSplitter().convert(result.stdout);
    expect(lines.take(5), ['/home/gao', 'gao', 'gao', '/bin/zsh', 'gao']);
    expect(lines, containsAllInOrder(['-i', '1000:1000']));
  });

  test(
    'unsupported user selector fails before starting a process or PTY',
    () async {
      final host = AndroidHost(
        environment,
        environment: {'WEB_TERMINAL_USER': 'unknown'},
      );
      await expectLater(host.execute('id'), throwsArgumentError);
      await expectLater(host.shell(), throwsArgumentError);
    },
  );
}
