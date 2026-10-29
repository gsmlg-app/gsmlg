import 'dart:io';

/// Native-only test directories are exercised by their platform CI jobs.
bool hasDartTests(Directory directory) =>
    directory.existsSync() &&
    directory
        .listSync(recursive: true, followLinks: false)
        .any((file) => file is File && file.path.endsWith('_test.dart'));

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1 ||
      !const {'dart', 'flutter'}.contains(arguments.single)) {
    stderr.writeln('Usage: dart tools/run_package_tests.dart <dart|flutter>');
    exitCode = 64;
    return;
  }
  if (!hasDartTests(Directory('test'))) {
    stdout.writeln(
      'No Dart test files in ${Directory.current.path}/test; skipped.',
    );
    return;
  }
  final process = await Process.start(arguments.single, [
    'test',
  ], mode: ProcessStartMode.inheritStdio);
  exitCode = await process.exitCode;
}
