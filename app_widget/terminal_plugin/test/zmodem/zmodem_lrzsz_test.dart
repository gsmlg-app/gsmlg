import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_file_access.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_transfer_controller.dart';

import 'zmodem_test_support.dart';

bool _hasLrzsz() {
  try {
    return Process.runSync('which', ['sz']).exitCode == 0 &&
        Process.runSync('which', ['rz']).exitCode == 0;
  } catch (_) {
    return false;
  }
}

Uint8List _random(int length, int seed) {
  final random = Random(seed);
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

/// Runs [executable] with its stdio connected to a controller, pausing the
/// output while each chunk is processed like TerminalPlugin does.
class _Run {
  _Run(this.process, this.controller) {
    process.stderr.listen((d) => stderrText.write(String.fromCharCodes(d)));
    late final StreamSubscription<List<int>> subscription;
    subscription = process.stdout.listen((chunk) {
      final pending = controller.handleSessionOutput(Uint8List.fromList(chunk));
      if (pending is Future<void>) {
        subscription.pause();
        pending.whenComplete(subscription.resume);
      }
    });
    controller.results.listen(results.add);
  }

  final Process process;
  final ZmodemTransferController controller;
  final stderrText = StringBuffer();
  final results = <ZmodemTransferResult>[];

  static Future<_Run> start(
    String executable,
    List<String> arguments,
    ZmodemFileAccess files, {
    String? workingDirectory,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );
    late final _Run run;
    final controller = ZmodemTransferController(
      onTerminalOutput: (_) {},
      writeToSession: (bytes) async {
        try {
          run.process.stdin.add(bytes);
          await run.process.stdin.flush();
        } catch (_) {}
      },
      files: files,
    );
    run = _Run(process, controller);
    return run;
  }

  Future<ZmodemTransferResult> result() async {
    for (var i = 0; i < 3000 && results.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return results.first;
  }
}

void main() {
  final skip = _hasLrzsz() ? false : 'lrzsz (sz/rz) not installed';
  late Directory source;
  late Directory downloads;

  setUp(() {
    source = Directory.systemTemp.createTempSync('zmodem-src-');
    downloads = Directory.systemTemp.createTempSync('zmodem-dl-');
  });
  tearDown(() {
    source.deleteSync(recursive: true);
    downloads.deleteSync(recursive: true);
  });

  test('sz of two files downloads both byte-identically', () async {
    final a = _random(150000, 1);
    final b = _random(3000, 2);
    File('${source.path}/a.bin').writeAsBytesSync(a);
    File('${source.path}/b.bin').writeAsBytesSync(b);

    final run = await _Run.start(
      'sz',
      ['--binary', '${source.path}/a.bin', '${source.path}/b.bin'],
      FakeFileAccess(downloads),
    );
    final result = await run.result();
    final exitCode = await run.process.exitCode.timeout(
      const Duration(seconds: 10),
    );

    expect(exitCode, 0, reason: run.stderrText.toString());
    expect(result, isA<ZmodemDownloadCompleted>());
    expect(File('${downloads.path}/a.bin').readAsBytesSync(), a);
    expect(File('${downloads.path}/b.bin').readAsBytesSync(), b);
    await run.controller.dispose();
  }, skip: skip);

  test('rz receives the picked file byte-identically', () async {
    final data = _random(250000, 3);
    final upload = File('${downloads.path}/up.bin')..writeAsBytesSync(data);
    final files = FakeFileAccess(downloads)
      ..uploads = [
        ZmodemLocalFile(path: upload.path, name: 'up.bin', length: data.length),
      ];

    final run = await _Run.start(
      'rz',
      ['--binary'],
      files,
      workingDirectory: source.path,
    );
    final result = await run.result();
    final exitCode = await run.process.exitCode.timeout(
      const Duration(seconds: 10),
    );

    expect(exitCode, 0, reason: run.stderrText.toString());
    expect(result, isA<ZmodemUploadCompleted>());
    expect(File('${source.path}/up.bin').readAsBytesSync(), data);
    await run.controller.dispose();
  }, skip: skip);

  test('rz skipping an existing file reports it as skipped', () async {
    final data = _random(5000, 6);
    final upload = File('${downloads.path}/up.bin')..writeAsBytesSync(data);
    File('${source.path}/up.bin').writeAsStringSync('old');
    final files = FakeFileAccess(downloads)
      ..uploads = [
        ZmodemLocalFile(path: upload.path, name: 'up.bin', length: data.length),
      ];

    final run = await _Run.start(
      'rz',
      ['--binary'],
      files,
      workingDirectory: source.path,
    );
    final result = await run.result();
    await run.process.exitCode.timeout(const Duration(seconds: 10));

    expect(result, isA<ZmodemUploadCompleted>());
    result as ZmodemUploadCompleted;
    expect(result.count, 0);
    expect(result.skipped, ['up.bin']);
    expect(File('${source.path}/up.bin').readAsStringSync(), 'old');
    await run.controller.dispose();
  }, skip: skip);

  test('cancel during a large sz stops it and leaves no partial file',
      () async {
    File('${source.path}/big.bin').writeAsBytesSync(_random(20 << 20, 4));
    final run = await _Run.start(
      'sz',
      ['--binary', '${source.path}/big.bin'],
      FakeFileAccess(downloads),
    );
    for (var i = 0; i < 1000; i++) {
      final progress = run.controller.progress.value;
      if (progress != null && progress.bytesDone > 0) break;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    await run.controller.cancel();
    final exitCode = await run.process.exitCode.timeout(
      const Duration(seconds: 5),
    );

    expect(exitCode, isNot(0));
    expect(run.results.single, isA<ZmodemTransferCancelled>());
    expect(downloads.listSync(), isEmpty);
    await run.controller.dispose();
  }, skip: skip);
}
