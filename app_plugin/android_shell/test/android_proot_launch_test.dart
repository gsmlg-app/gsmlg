import 'dart:io';

import 'package:android_shell/android_shell.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app.gsmlg/android_shell');
  late Directory directory;

  setUp(() async {
    AndroidShellEnv.reset();
    directory = await Directory.systemTemp.createTemp('android_proot_launch_');
    final nativeDir = Directory('${directory.path}/native')..createSync();
    File('${nativeDir.path}/libproot.so').writeAsStringSync('fixture');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => <String, String>{
            'filesDir': directory.path,
            'rootfsPath': '${directory.path}/rootfs',
            'nativeLibDir': nativeDir.path,
            'prootPath': '${nativeDir.path}/libproot.so',
            'loaderPath': '${nativeDir.path}/libloader.so',
            'loader32Path': '${nativeDir.path}/libloader32.so',
            'tmpPath': '${directory.path}/tmp',
            'homePath': '${directory.path}/rootfs/home/gao',
            'userName': 'gao',
            'userId': '1000',
            'groupId': '1000',
            'guestHome': '/home/gao',
            'guestShell': '/bin/zsh',
            'arch': 'arm64-v8a',
          },
        );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    AndroidShellEnv.reset();
    await directory.delete(recursive: true);
  });

  test('PRoot can resolve its packaged native dependencies', () async {
    final environment = AndroidShellEnv.instance;
    await environment.initialize();

    expect(environment.usesSystemShell, isFalse);
    expect(
      environment.getEnvironment()['LD_LIBRARY_PATH'],
      environment.nativeLibDir,
    );
    expect(
      environment.getEnvironment()['PROOT_LOADER'],
      environment.loaderPath,
    );
    final (command, arguments) = environment.getShellCommand();
    expect(command, '${directory.path}/native/libproot.so');
    expect(arguments, containsAllInOrder(['-r', environment.rootfsPath]));
    expect(arguments, containsAllInOrder(['-i', '1000:1000']));
    expect(arguments, isNot(contains('-0')));
    expect(arguments, containsAllInOrder(['-w', '/home/gao']));
    expect(arguments.sublist(arguments.length - 2), ['/bin/zsh', '-l']);
    expect(environment.getEnvironment(), containsPair('HOME', '/home/gao'));
    expect(environment.getEnvironment(), containsPair('USER', 'gao'));
    expect(environment.getEnvironment(), containsPair('LOGNAME', 'gao'));
    expect(environment.getEnvironment(), containsPair('SHELL', '/bin/zsh'));
    expect(environment.homePath, '${directory.path}/rootfs/home/gao');
  });

  test('administrator command and environment use root consistently', () async {
    final environment = AndroidShellEnv.instance;
    await environment.initialize();
    final (_, arguments) = environment.getShellCommand(root: true);
    expect(arguments, contains('-0'));
    expect(arguments, isNot(contains('-i')));
    expect(arguments, containsAllInOrder(['-w', '/root']));
    expect(arguments.sublist(arguments.length - 2), ['/bin/zsh', '-l']);
    expect(
      environment.getEnvironment(root: true),
      containsPair('HOME', '/root'),
    );
    expect(
      environment.getEnvironment(root: true),
      containsPair('USER', 'root'),
    );
    expect(
      environment.getEnvironment(root: true),
      containsPair('LOGNAME', 'root'),
    );
    expect(environment.rootHomePath, '${directory.path}/rootfs/root');
  });

  test(
    'execution shares PRoot flags without assuming shell tail length',
    () async {
      final environment = AndroidShellEnv.instance;
      await environment.initialize();
      final (_, shellArguments) = environment.getShellCommand();
      final (_, arguments) = environment.getExecutionCommand(
        '/usr/bin/printf',
        arguments: ['%s', 'argument with spaces'],
      );
      expect(
        arguments.take(shellArguments.length - 2),
        shellArguments.take(shellArguments.length - 2),
      );
      expect(arguments.skip(shellArguments.length - 2), [
        '/bin/sh',
        '-c',
        r'exec "$0" "$@"',
        '/usr/bin/printf',
        '%s',
        'argument with spaces',
      ]);
      final (_, rootArguments) = environment.getExecutionCommand(
        'apk',
        root: true,
      );
      expect(rootArguments, contains('-0'));
      expect(rootArguments, containsAllInOrder(['-w', '/root']));
    },
  );

  test(
    'missing PRoot uses Android system paths in fallback environment',
    () async {
      File('${directory.path}/native/libproot.so').deleteSync();
      final environment = AndroidShellEnv.instance;
      await environment.initialize();

      expect(environment.usesSystemShell, isTrue);
      final (command, arguments) = environment.getShellCommand();
      expect(command, '/system/bin/sh');
      expect(arguments, ['-i']);
      expect(environment.getEnvironment()['PATH'], contains('/system/bin'));
      expect(environment.getEnvironment()['HOME'], environment.homePath);
      expect(environment.getEnvironment()['TMPDIR'], environment.tmpPath);
    },
  );
}
