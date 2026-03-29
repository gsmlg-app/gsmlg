import 'dart:io';
import 'dart:isolate';

/// Runs a process in an isolate to avoid blocking the event loop.
Future<ProcessResult> runProcess(
  String executable,
  List<String> arguments,
) async {
  return Isolate.run(() => Process.run(executable, arguments));
}

/// Reads a file in an isolate.
Future<String> readFileAsync(String path) async {
  return Isolate.run(() => File(path).readAsString());
}
