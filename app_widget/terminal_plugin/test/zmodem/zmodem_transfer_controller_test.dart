import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_file_access.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_transfer_controller.dart';
import 'package:zmodem/src/consts.dart' as consts;
import 'package:zmodem/src/zmodem_frame.dart';
import 'package:zmodem/zmodem.dart';

import 'zmodem_test_support.dart';

Uint8List _random(int length, [int seed = 1]) {
  final random = Random(seed);
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

const _abortSequence = [
  0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, //
  0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
];

class _Harness {
  _Harness(
    this.files, {
    bool supported = true,
    Duration handshakeTimeout = const Duration(seconds: 10),
    Duration idleTimeout = const Duration(seconds: 30),
  }) {
    controller = ZmodemTransferController(
      onTerminalOutput: terminal.add,
      writeToSession: (bytes) async {
        sessionWrites.add(bytes);
        final peer = this.peer;
        if (peer != null) scheduleMicrotask(() => peer.receive(bytes));
      },
      files: files,
      supported: supported,
      handshakeTimeout: handshakeTimeout,
      idleTimeout: idleTimeout,
    );
    controller.results.listen(results.add);
  }

  final FakeFileAccess files;
  late final ZmodemTransferController controller;
  final terminal = BytesBuilder(copy: true);
  final sessionWrites = BytesBuilder(copy: true);
  final results = <ZmodemTransferResult>[];
  FakePeer? peer;

  /// Delivers peer output one chunk at a time, waiting until the controller
  /// has processed each chunk, like TerminalPlugin pausing the session.
  final _pipe = <Uint8List>[];
  bool _delivering = false;

  void connect(FakePeer peer) {
    this.peer = peer;
    peer.toController = (bytes) {
      _pipe.add(bytes);
      if (!_delivering) unawaited(_deliver());
    };
  }

  Future<void> _deliver() async {
    _delivering = true;
    while (_pipe.isNotEmpty) {
      await Future<void>.delayed(Duration.zero);
      await controller.handleSessionOutput(_pipe.removeAt(0));
    }
    _delivering = false;
  }

  /// Bytes waiting in the pipe (the session's own buffer, not the
  /// controller's).
  int get pipeBytes => _pipe.fold(0, (sum, chunk) => sum + chunk.length);

  Future<ZmodemTransferResult> nextResult() async {
    for (var i = 0; i < 2000 && results.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    return results.removeAt(0);
  }

  Future<void> settle() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

void main() {
  late Directory tmp;
  late FakeFileAccess files;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('zmodem-controller-');
    files = FakeFileAccess(tmp);
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('plain output passes through unchanged', () async {
    final h = _Harness(files);
    final chunks = [
      utf8.encode('hello '),
      utf8.encode('中文 world\r\n'),
      Uint8List.fromList([0x1b, 0x5b, 0x33, 0x31, 0x6d, 0x2a]),
    ];
    for (final chunk in chunks) {
      await h.controller.handleSessionOutput(Uint8List.fromList(chunk));
    }
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(h.terminal.takeBytes(), [for (final c in chunks) ...c]);
    expect(h.controller.isActive, isFalse);
  });

  test('handshake split across chunks starts a download', () async {
    final init = (ZModemCore()..initiateSend()).dataToSend();
    for (var split = 1; split < init.length; split++) {
      final local = FakeFileAccess(tmp);
      final h = _Harness(local);
      await h.controller.handleSessionOutput(
        Uint8List.sublistView(init, 0, split),
      );
      await h.controller
          .handleSessionOutput(Uint8List.sublistView(init, split));
      await h.settle();

      expect(h.controller.isActive, isTrue, reason: 'split at $split');
      expect(h.terminal.takeBytes(), isEmpty, reason: 'split at $split');
      await h.controller.dispose();
    }
  });

  test('invalid header text passes through', () async {
    final h = _Harness(files);
    final text = utf8.encode('**\x18B00ffffffffffffff\r\n');

    await h.controller.handleSessionOutput(Uint8List.fromList(text));
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(h.terminal.takeBytes(), text);
    expect(h.controller.isActive, isFalse);
    expect(h.sessionWrites.takeBytes(), isEmpty);
  });

  test('download writes the file and reports completion', () async {
    final h = _Harness(files);
    final data = _random(100000);
    h.connect(FakePeer.sender({'a.bin': data}));
    h.peer!.start();

    final result = await h.nextResult();

    expect(result, isA<ZmodemDownloadCompleted>());
    expect((result as ZmodemDownloadCompleted).paths, ['${tmp.path}/a.bin']);
    expect(File('${tmp.path}/a.bin').readAsBytesSync(), data);
    await h.settle();
    expect(h.controller.isActive, isFalse);
    expect(h.controller.progress.value, isNull);
  });

  test('multi-file download with clash', () async {
    File('${tmp.path}/b.txt').writeAsStringSync('old');
    final h = _Harness(files);
    h.connect(
      FakePeer.sender({
        'a.txt': Uint8List.fromList(utf8.encode('A')),
        'b.txt': Uint8List.fromList(utf8.encode('B')),
      }),
    );
    h.peer!.start();

    final result = await h.nextResult() as ZmodemDownloadCompleted;

    expect(result.paths, ['${tmp.path}/a.txt', '${tmp.path}/b (1).txt']);
    expect(File('${tmp.path}/b.txt').readAsStringSync(), 'old');
    expect(File('${tmp.path}/b (1).txt').readAsStringSync(), 'B');
  });

  test('ask mode cancelled skips every file', () async {
    files.downloadDirectory = () => null;
    final h = _Harness(files);
    final peer = FakePeer.sender({
      'a.txt': Uint8List.fromList([1]),
      'b.txt': Uint8List.fromList([2]),
    });
    h.connect(peer);
    peer.start();

    final result = await h.nextResult();

    expect(result, isA<ZmodemTransferCancelled>());
    expect(peer.skipped, ['a.txt', 'b.txt']);
    expect(tmp.listSync(), isEmpty);
  });

  test('a slow folder dialog survives the sender retrying', () async {
    files.folderDialog = Completer<void>();
    final h = _Harness(files);
    final data = _random(20000);
    final peer = FakePeer.sender({'slow.bin': data});
    h.connect(peer);
    peer.start();
    await h.settle();
    // sz retries its handshake while the dialog is open.
    for (var i = 0; i < 3; i++) {
      peer.toController((ZModemCore()..initiateSend()).dataToSend());
      await h.settle();
    }

    files.folderDialog!.complete();
    final result = await h.nextResult();

    expect(result, isA<ZmodemDownloadCompleted>());
    expect(File('${tmp.path}/slow.bin').readAsBytesSync(), data);
  });

  test('upload sends picked files', () async {
    final data = _random(50000, 7);
    final source = File('${tmp.path}/up.bin')..writeAsBytesSync(data);
    files.uploads = [
      ZmodemLocalFile(path: source.path, name: 'up.bin', length: data.length),
    ];
    final h = _Harness(files);
    final peer = FakePeer.receiver();
    h.connect(peer);
    peer.start();

    final result = await h.nextResult();

    expect(result, isA<ZmodemUploadCompleted>());
    expect((result as ZmodemUploadCompleted).count, 1);
    expect(peer.received['up.bin']!.takeBytes(), data);
  });

  test('upload honours XOFF/XON flow control from the receiver', () async {
    final data = _random(400000, 9);
    final source = File('${tmp.path}/flow.bin')..writeAsBytesSync(data);
    files.uploads = [
      ZmodemLocalFile(path: source.path, name: 'flow.bin', length: data.length),
    ];
    final peer = FakePeer.receiver();
    var written = 0;
    var writesAfterXoff = 0;
    var xoff = false;
    late final ZmodemTransferController controller;
    controller = ZmodemTransferController(
      onTerminalOutput: (_) {},
      writeToSession: (bytes) async {
        written += bytes.length;
        if (xoff) writesAfterXoff++;
        scheduleMicrotask(() => peer.receive(bytes));
        if (!xoff && written > 10000) {
          xoff = true;
          // The receiver's terminal asks us to stop.
          await controller.handleSessionOutput(Uint8List.fromList([0x13]));
        }
      },
      files: files,
    );
    final results = <ZmodemTransferResult>[];
    controller.results.listen(results.add);
    peer.toController = (bytes) =>
        scheduleMicrotask(() => controller.handleSessionOutput(bytes));
    peer.start();
    for (var i = 0; i < 500 && !xoff; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(writesAfterXoff, lessThanOrEqualTo(1), reason: 'kept sending');
    expect(results, isEmpty);

    await controller.handleSessionOutput(Uint8List.fromList([0x11]));
    for (var i = 0; i < 3000 && results.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    expect(results.single, isA<ZmodemUploadCompleted>());
    expect(peer.received['flow.bin']!.takeBytes(), data);
    await controller.dispose();
  });

  test('uploads are written in slices of at most 1 KB', () async {
    final data = _random(100000, 10);
    final source = File('${tmp.path}/slices.bin')..writeAsBytesSync(data);
    files.uploads = [
      ZmodemLocalFile(
          path: source.path, name: 'slices.bin', length: data.length),
    ];
    final sizes = <int>[];
    final peer = FakePeer.receiver();
    late final ZmodemTransferController controller;
    controller = ZmodemTransferController(
      onTerminalOutput: (_) {},
      writeToSession: (bytes) async {
        sizes.add(bytes.length);
        scheduleMicrotask(() => peer.receive(bytes));
      },
      files: files,
    );
    final results = <ZmodemTransferResult>[];
    controller.results.listen(results.add);
    peer.toController = (bytes) =>
        scheduleMicrotask(() => controller.handleSessionOutput(bytes));
    peer.start();
    for (var i = 0; i < 3000 && results.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    expect(results.single, isA<ZmodemUploadCompleted>());
    expect(sizes.reduce(max), lessThanOrEqualTo(1024));
    await controller.dispose();
  });

  test('upload picker cancelled ends the session', () async {
    files.uploads = null;
    final h = _Harness(files);
    final peer = FakePeer.receiver();
    h.connect(peer);
    peer.start();

    final result = await h.nextResult();
    await peer.finished.future.timeout(const Duration(seconds: 2));

    expect(result, isA<ZmodemTransferCancelled>());
  });

  test('cancel mid-download sends the abort sequence and deletes the file',
      () async {
    final h = _Harness(files);
    final peer = FakePeer.sender({'big.bin': _random(200000)})
      ..stallAfter = 50000;
    h.connect(peer);
    peer.start();
    for (var i = 0; i < 500 && !File('${tmp.path}/big.bin').existsSync(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    await h.settle();

    await h.controller.cancel();
    final result = await h.nextResult();

    final written = h.sessionWrites.takeBytes();
    expect(
      written.sublist(written.length - _abortSequence.length),
      _abortSequence,
    );
    expect(result, isA<ZmodemTransferCancelled>());
    expect(File('${tmp.path}/big.bin').existsSync(), isFalse);
    expect(h.controller.isActive, isFalse);
  });

  test('remote cancel mid-download fails and deletes the file', () async {
    final h = _Harness(files);
    final peer = FakePeer.sender({'big.bin': _random(200000)})
      ..stallAfter = 50000;
    h.connect(peer);
    peer.start();
    for (var i = 0; i < 500 && !File('${tmp.path}/big.bin').existsSync(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    await h.settle();

    await h.controller.handleSessionOutput(
      Uint8List.fromList(List.filled(8, 0x18)),
    );
    final result = await h.nextResult();

    expect(result, isA<ZmodemTransferFailed>());
    expect(File('${tmp.path}/big.bin').existsSync(), isFalse);
    expect(h.controller.isActive, isFalse);
  });

  test('session ends mid-download deletes the partial file', () async {
    final h = _Harness(files);
    final peer = FakePeer.sender({'big.bin': _random(200000)})
      ..stallAfter = 50000;
    h.connect(peer);
    peer.start();
    for (var i = 0; i < 500 && !File('${tmp.path}/big.bin').existsSync(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    await h.settle();

    await h.controller.dispose();

    expect(File('${tmp.path}/big.bin').existsSync(), isFalse);
  });

  test('keyboard is held during a transfer and Ctrl+C cancels', () async {
    final h = _Harness(files);
    expect(
        h.controller.handleKeyboardInput(Uint8List.fromList([0x61])), isFalse);
    final peer = FakePeer.sender({'big.bin': _random(200000)})
      ..stallAfter = 50000;
    h.connect(peer);
    peer.start();
    await h.settle();
    expect(h.controller.isActive, isTrue);

    expect(
      h.controller.handleKeyboardInput(Uint8List.fromList([0x61])),
      isTrue,
    );
    expect(
      h.controller.handleKeyboardInput(Uint8List.fromList([0x03])),
      isTrue,
    );
    final result = await h.nextResult();

    expect(result, isA<ZmodemTransferCancelled>());
    expect(h.controller.isActive, isFalse);
  });

  test('handshake timeout restores passthrough', () async {
    final h = _Harness(
      files,
      handshakeTimeout: const Duration(milliseconds: 50),
    );
    await h.controller.handleSessionOutput(
      (ZModemCore()..initiateSend()).dataToSend(),
    );
    await h.settle();
    expect(h.controller.isActive, isTrue);

    final result = await h.nextResult();
    // Output right after a failure is discarded until the remote is quiet.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await h.controller.handleSessionOutput(utf8.encode('after\r\n'));
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(result, isA<ZmodemTransferFailed>());
    expect(h.controller.isActive, isFalse);
    expect(utf8.decode(h.terminal.takeBytes()), contains('after'));
  });

  test('unsupported device declines with a notice', () async {
    final h = _Harness(files, supported: false);

    await h.controller.handleSessionOutput(
      (ZModemCore()..initiateSend()).dataToSend(),
    );
    await h.settle();

    expect(h.controller.isActive, isFalse);
    expect(h.sessionWrites.takeBytes(), _abortSequence);
    expect(
      utf8.decode(h.terminal.takeBytes()),
      contains('ZMODEM transfers are not supported on this device'),
    );
  });

  test('download of 8 MB completes with bounded buffering', () async {
    final h = _Harness(files);
    final data = _random(8 * 1024 * 1024, 3);
    var maxBuffered = 0;
    final watcher = Timer.periodic(const Duration(milliseconds: 1), (_) {
      maxBuffered = max(maxBuffered, h.controller.bufferedBytes);
    });
    h.connect(FakePeer.sender({'big.bin': data}));
    h.peer!.start();

    final result = await h.nextResult();
    watcher.cancel();

    expect(result, isA<ZmodemDownloadCompleted>());
    expect(File('${tmp.path}/big.bin').lengthSync(), data.length);
    expect(maxBuffered, lessThanOrEqualTo(1024 * 1024));
  });

  test('progress reports the file being downloaded', () async {
    final h = _Harness(files);
    final seen = <ZmodemProgress>[];
    h.controller.progress.addListener(() {
      final value = h.controller.progress.value;
      if (value != null) seen.add(value);
    });
    h.connect(FakePeer.sender({'p.bin': _random(30000)}));
    h.peer!.start();

    await h.nextResult();

    expect(seen, isNotEmpty);
    expect(seen.first.direction, ZmodemDirection.download);
    expect(seen.last.fileName, 'p.bin');
    expect(seen.last.totalBytes, 30000);
    expect(seen.last.bytesDone, 30000);
  });

  test('output after a cancel is discarded until the remote goes quiet',
      () async {
    final h = _Harness(files);
    final peer = FakePeer.sender({'big.bin': _random(200000)})
      ..stallAfter = 50000;
    h.connect(peer);
    peer.start();
    for (var i = 0; i < 500 && !File('${tmp.path}/big.bin').existsSync(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    await h.settle();
    h.terminal.clear();

    await h.controller.cancel();
    await h.nextResult();
    // sz keeps streaming binary data until it notices the cancel.
    for (var i = 0; i < 5; i++) {
      await h.controller.handleSessionOutput(
        Uint8List.fromList([0x1b, 0x5b, 0x36, 0x6e, ...List.filled(500, 0x41)]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(h.terminal.takeBytes(), isEmpty, reason: 'garbage reached terminal');

    await Future<void>.delayed(const Duration(milliseconds: 600));
    await h.controller.handleSessionOutput(utf8.encode('prompt\$ '));
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(utf8.decode(h.terminal.takeBytes()), contains('prompt\$ '));
  });

  test('a silent remote mid-download fails after the idle timeout', () async {
    final h = _Harness(files, idleTimeout: const Duration(milliseconds: 150));
    final peer = FakePeer.sender({'dead.bin': _random(200000)})
      ..stallAfter = 50000;
    h.connect(peer);
    peer.start();

    final result = await h.nextResult();

    expect(result, isA<ZmodemTransferFailed>());
    expect(File('${tmp.path}/dead.bin').existsSync(), isFalse);
    expect(h.controller.isActive, isFalse);
  });

  /// Drives an upload by hand: returns the bytes the controller writes.
  Future<(ZmodemTransferController, BytesBuilder, List<ZmodemTransferResult>)>
      manualUpload(Uint8List data) async {
    final source = File('${tmp.path}/manual.bin')..writeAsBytesSync(data);
    files.uploads = [
      ZmodemLocalFile(
          path: source.path, name: 'manual.bin', length: data.length),
    ];
    final written = BytesBuilder(copy: true);
    final controller = ZmodemTransferController(
      onTerminalOutput: (_) {},
      writeToSession: (bytes) async => written.add(bytes),
      files: files,
    );
    final results = <ZmodemTransferResult>[];
    controller.results.listen(results.add);
    await controller.handleSessionOutput(
      (ZModemCore()..initiateReceive()).dataToSend(),
    );
    for (var i = 0; i < 200 && written.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    written.clear();
    await controller.handleSessionOutput(ZModemHeader.rpos(0).encode());
    return (controller, written, results);
  }

  test('upload stops when too much data is unacknowledged', () async {
    final (controller, written, results) =
        await manualUpload(_random(2 << 20, 11));

    await Future<void>.delayed(const Duration(milliseconds: 200));
    final inFlight = written.length;
    expect(inFlight, lessThan(400 * 1024));
    expect(inFlight, greaterThan(64 * 1024));

    await controller.handleSessionOutput(
      ZModemHeader(consts.ZACK, 0, 0, 0x04, 0).encode(), // ack 256 KB
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(written.length, greaterThan(inFlight));
    expect(results, isEmpty);
    await controller.dispose();
  });

  test('ZRPOS mid-upload resends from the requested offset', () async {
    final (controller, written, _) = await manualUpload(_random(600000, 12));
    for (var i = 0; i < 200 && written.length < 100000; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    written.clear();

    await controller.handleSessionOutput(ZModemHeader.rpos(10000).encode());
    for (var i = 0; i < 200 && written.length < 4096; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    final bytes = written.takeBytes();
    final header = ZModemHeader.data(10000).encode();
    final at = _indexOf(bytes, header);
    expect(at, greaterThanOrEqualTo(0), reason: 'no ZDATA(10000) header');
    expect(at, lessThanOrEqualTo(1024), reason: 'old data sent before header');
    await controller.dispose();
  });
}

int _indexOf(Uint8List haystack, Uint8List needle) {
  outer:
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return i;
  }
  return -1;
}
