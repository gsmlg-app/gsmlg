import 'dart:io';

import 'package:test/test.dart';

import '../../tools/run_package_tests.dart' as runner;

void main() {
  late Directory temporary;

  setUp(
    () => temporary = Directory.systemTemp.createTempSync('test-discovery-'),
  );
  tearDown(() => temporary.deleteSync(recursive: true));

  test('missing, empty and native-only directories are not Dart suites', () {
    final directory = Directory('${temporary.path}/test');
    expect(runner.hasDartTests(directory), isFalse);
    directory.createSync();
    expect(runner.hasDartTests(directory), isFalse);
    File('${directory.path}/collector_test.cc').writeAsStringSync('');
    File('${directory.path}/channel_test.sh').writeAsStringSync('');
    File('${directory.path}/helper.dart').writeAsStringSync('');
    expect(runner.hasDartTests(directory), isFalse);
  });

  test('nested Dart suites remain selected alongside native tests', () {
    final nested = Directory('${temporary.path}/test/nested')
      ..createSync(recursive: true);
    File('${nested.path}/regression_test.dart').writeAsStringSync('');
    File('${temporary.path}/test/native_test.cc').writeAsStringSync('');
    expect(runner.hasDartTests(Directory('${temporary.path}/test')), isTrue);
  });

  test('a failing test process keeps its failure exit code', () async {
    final testDirectory = Directory('${temporary.path}/test')..createSync();
    File('${testDirectory.path}/failing_test.dart').writeAsStringSync('');
    final bin = Directory('${temporary.path}/bin')..createSync();
    final executable = File('${bin.path}/dart')
      ..writeAsStringSync('#!/bin/sh\nexit 37\n');
    final chmod = await Process.run('chmod', ['+x', executable.path]);
    expect(chmod.exitCode, 0);
    final script = File('tools/run_package_tests.dart').absolute.path;
    final result = await Process.run(
      Platform.resolvedExecutable,
      [script, 'dart'],
      workingDirectory: temporary.path,
      environment: {'PATH': '${bin.path}:${Platform.environment['PATH']}'},
    );
    expect(result.exitCode, 37, reason: '${result.stdout}\n${result.stderr}');
  }, skip: Platform.isWindows ? 'POSIX executable fixture' : false);
}
