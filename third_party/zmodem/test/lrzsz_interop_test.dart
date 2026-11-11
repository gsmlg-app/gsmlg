import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:zmodem/zmodem.dart';

bool _hasLrzsz() {
  try {
    return Process.runSync('which', ['sz']).exitCode == 0 &&
        Process.runSync('which', ['rz']).exitCode == 0;
  } catch (_) {
    return false;
  }
}

Uint8List _payload(int randomLength) {
  final random = Random(42);
  return Uint8List.fromList([
    for (var i = 0; i < randomLength; i++) random.nextInt(256),
    for (var r = 0; r < 4; r++)
      for (var b = 0; b < 256; b++) b,
  ]);
}

/// Receives every file `sz` offers. Returns name → bytes.
Future<Map<String, Uint8List>> _receiveFromSz(List<String> paths) async {
  final process = await Process.start('sz', ['--binary', ...paths]);
  final core = ZModemCore();
  final files = <String, BytesBuilder>{};
  String? current;
  final done = Completer<void>();
  final stderrText = StringBuffer();
  process.stderr.listen((d) => stderrText.write(String.fromCharCodes(d)));

  void flush() {
    final out = core.dataToSend();
    if (out.isNotEmpty) process.stdin.add(out);
  }

  process.stdout.listen((chunk) {
    for (final event in core.receive(Uint8List.fromList(chunk))) {
      if (event is ZFileOfferedEvent) {
        current = event.fileInfo.pathname;
        files[current!] = BytesBuilder();
        core.acceptFile(0);
      } else if (event is ZFileDataEvent) {
        files[current!]!.add(event.data);
      } else if (event is ZSessionFinishedEvent) {
        if (!done.isCompleted) done.complete();
      }
      flush();
    }
    flush();
  });

  await done.future.timeout(const Duration(seconds: 20));
  final exitCode = await process.exitCode.timeout(const Duration(seconds: 10));
  expect(exitCode, 0, reason: stderrText.toString());
  return {for (final e in files.entries) e.key: e.value.takeBytes()};
}

void main() {
  final skip = _hasLrzsz() ? false : 'lrzsz (sz/rz) not installed';
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('zmodem-interop-'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('receives a file from sz byte-identically', () async {
    final data = _payload(300 * 1024);
    final file = File('${tmp.path}/payload.bin')..writeAsBytesSync(data);

    final received = await _receiveFromSz([file.path]);

    expect(received.keys, ['payload.bin']);
    expect(received['payload.bin'], data);
  }, skip: skip);

  test('sz of two files delivers both', () async {
    final a = _payload(1000);
    final b = _payload(70000);
    File('${tmp.path}/a.bin').writeAsBytesSync(a);
    File('${tmp.path}/b.bin').writeAsBytesSync(b);

    final received =
        await _receiveFromSz(['${tmp.path}/a.bin', '${tmp.path}/b.bin']);

    expect(received['a.bin'], a);
    expect(received['b.bin'], b);
  }, skip: skip);

  test('sends a file to rz byte-identically', () async {
    final data = _payload(200 * 1024);
    final process = await Process.start(
      'rz',
      ['--binary'],
      workingDirectory: tmp.path,
    );
    final stderrText = StringBuffer();
    process.stderr.listen((d) => stderrText.write(String.fromCharCodes(d)));
    final core = ZModemCore();
    var offered = false;

    void flush() {
      final out = core.dataToSend();
      if (out.isNotEmpty) process.stdin.add(out);
    }

    core.initiateSend();
    flush();

    process.stdout.listen((chunk) {
      for (final event in core.receive(Uint8List.fromList(chunk))) {
        if (event is ZReadyToSendEvent) {
          if (!offered) {
            offered = true;
            core.offerFile(
              ZModemFileInfo(pathname: 'up.bin', length: data.length),
            );
          } else {
            core.finishSession();
          }
        } else if (event is ZFileAcceptedEvent) {
          for (var i = event.offset; i < data.length; i += 8192) {
            core.sendFileData(
              Uint8List.sublistView(data, i, min(i + 8192, data.length)),
            );
            flush();
          }
          core.finishSending(data.length);
        }
        flush();
      }
      flush();
    });

    final exitCode =
        await process.exitCode.timeout(const Duration(seconds: 20));
    expect(exitCode, 0, reason: stderrText.toString());
    expect(File('${tmp.path}/up.bin').readAsBytesSync(), data);
  }, skip: skip);
}
