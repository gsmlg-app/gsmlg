import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:terminal_core/terminal_core.dart' show ExecutionSession;
import 'package:terminal_plugin/src/isolate_session_binding.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_file_access.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_transfer_controller.dart';
import 'package:xterm/session_isolate.dart';

import 'zmodem_test_support.dart';

class _Session implements ExecutionSession {
  final frames = StreamController<Uint8List>();
  final exited = Completer<int>();
  final writes = <Uint8List>[];
  void Function(Uint8List)? toPeer;
  Completer<void>? blockNextWrite;
  int acked = 0;
  int closed = 0;
  int _inFlight = 0;

  @override
  Stream<Uint8List> get output => frames.stream;
  @override
  Future<int> get exitCode => exited.future;

  void emit(List<int> frame) => frames.add(Uint8List.fromList(frame));

  @override
  void ackRead() => acked++;

  @override
  Future<void> resize(int columns, int rows) async {}

  @override
  Future<void> close() async {
    closed++;
    if (!exited.isCompleted) exited.complete(0);
    unawaited(frames.close());
  }

  @override
  Future<void> write(Uint8List data) async {
    expect(_inFlight++, 0, reason: 'Transport writes must never overlap');
    try {
      writes.add(Uint8List.fromList(data));
      final block = blockNextWrite;
      blockNextWrite = null;
      await block?.future;
      toPeer?.call(data);
    } finally {
      _inFlight--;
    }
  }
}

class _DelayedFiles extends FakeFileAccess {
  _DelayedFiles(super.directory);
  final opened = Completer<void>();
  final release = Completer<void>();
  int created = 0;
  bool returned = false;

  @override
  Future<String?> resolveDownloadDirectory() async {
    opened.complete();
    await release.future;
    returned = true;
    return directory.path;
  }

  @override
  Future<ZmodemDownloadTarget> createDownload(String dir, String remote) async {
    created++;
    return super.createDownload(dir, remote);
  }
}

class _DelayedUpload extends FakeFileAccess {
  _DelayedUpload(super.directory);
  final opened = Completer<void>();
  final release = Completer<void>();
  final returned = Completer<void>();

  @override
  Future<List<ZmodemLocalFile>?> pickUploadFiles() async {
    opened.complete();
    await release.future;
    returned.complete();
    return uploads;
  }
}

class _CleanupFiles extends FakeFileAccess {
  _CleanupFiles(super.directory);
  final discarding = Completer<void>();
  final allowDiscard = Completer<void>();

  @override
  Future<ZmodemDownloadTarget> createDownload(String dir, String remote) async {
    final target = await super.createDownload(dir, remote);
    return _CleanupTarget(target.path, target.sink, discarding, allowDiscard);
  }
}

class _CleanupTarget extends ZmodemDownloadTarget {
  _CleanupTarget(super.path, super.sink, this.discarding, this.allowDiscard);
  final Completer<void> discarding;
  final Completer<void> allowDiscard;

  @override
  Future<void> discard() async {
    discarding.complete();
    await allowDiscard.future;
    await super.discard();
  }
}

Future<void> _until(bool Function() ok) async {
  final watch = Stopwatch()..start();
  while (!ok()) {
    if (watch.elapsed > const Duration(seconds: 5)) fail('Timed out');
    await Future<void>.delayed(const Duration(milliseconds: 4));
  }
}

bool _projected(IsolateSessionBinding binding, String marker) =>
    binding.snapshot.value?.lines.any((line) => line.text.contains(marker)) ??
    false;

void main() {
  late Directory tmp;
  late IsolateHub hub;

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('isolate-zmodem-test-');
    hub = IsolateHub();
    await hub.start();
  });

  tearDown(() async {
    await hub.stop();
    tmp.deleteSync(recursive: true);
  });

  Future<(IsolateSessionBinding, _Session)> open(String name,
      [ZmodemFileAccess? files, int? Function()? capability]) async {
    final session = _Session();
    final worker = await TerminalIsolateSession.open(hub, name);
    final bound = IsolateSessionBinding(
      worker,
      session,
      transferFiles: files,
      clipboardCapability: capability,
      onClosed: (error) {
        if (error != null) fail('Unexpected close: $error');
      },
    );
    addTearDown(bound.close);
    bound.start();
    return (bound, session);
  }

  test('merged scanner text cannot adopt a later clipboard capability',
      () async {
    int? capability;
    final (bound, session) =
        await open('scanner-authority', FakeFileAccess(tmp), () => capability);
    final capabilities = <int?>[];
    bound.onParseClipboardCapability = capabilities.add;

    // Ordinary text with a potentially split scanner prefix, not a clipboard
    // command. Only the internal capability passed to the parser is inspected.
    session.emit(utf8.encode('**'));
    await _until(() => session.acked == 1);
    expect(bound.zmodem!.hasPendingTerminalProbe, isTrue);
    capability = 11;
    session.emit(utf8.encode('ordinary text'));
    await _until(() => session.acked == 2);
    expect(capabilities, [null]);
    await _until(() => _projected(bound, '**ordinary text'));
    session.emit(utf8.encode('\r\nnew frame'));
    await _until(() => session.acked == 3);
    expect(capabilities, [null, 11]);
    await _until(() => _projected(bound, 'new frame'));
  });

  test('delayed cancelled-file cleanup cannot send on a successor transfer',
      () async {
    final files = _CleanupFiles(tmp);
    final (bound, session) = await open('abort-ownership', files);
    final controller = bound.zmodem!;
    final outcomes = <ZmodemTransferResult>[];
    final resultSubscription = controller.results.listen(outcomes.add);
    addTearDown(resultSubscription.cancel);
    final old = FakePeer.sender({'cancelled.bin': Uint8List(10)})
      ..stallAfter = 1
      ..toController = session.emit;
    session.toPeer = old.receive;
    old.start();
    await _until(() => controller.progress.value?.fileName == 'cancelled.bin');

    session.toPeer = null;
    final cancelling = controller.cancel();
    await files.discarding.future.timeout(const Duration(seconds: 4));
    await _until(() => !controller.isDraining);

    final successor = FakePeer.receiver()..toController = session.emit;
    final oldEpoch = controller.transferEpoch;
    successor.start();
    await _until(
        () => controller.isActive && controller.transferEpoch > oldEpoch);
    int aborts() => session.writes
        .where((write) =>
            write.length == 16 && write.take(8).every((byte) => byte == 0x18))
        .length;
    final beforeCleanup = aborts();
    files.allowDiscard.complete();
    await cancelling.timeout(const Duration(seconds: 4));
    expect(controller.isActive, isTrue);
    expect(aborts(), beforeCleanup);
    await _until(() => outcomes.isNotEmpty);
    expect(outcomes.single, isA<ZmodemTransferCancelled>());
    expect(File('${tmp.path}/cancelled.bin').existsSync(), isFalse);

    // A cancellation still writes normally when its generation owns egress.
    final currentResult = controller.results.first;
    await controller.cancel();
    expect(await currentResult, isA<ZmodemTransferCancelled>());
    expect(session.writes.last.take(8), List.filled(8, 0x18));
  });

  test('download demux keeps shell prefix ordered before protocol egress',
      () async {
    final (bound, session) = await open('download', FakeFileAccess(tmp));
    final data = Uint8List.fromList(List.generate(54000, (i) => (i * 7) % 256));
    final peer = FakePeer.sender({'only-fixture.bin': data});
    final results = <ZmodemTransferResult>[];
    final resultSub = bound.zmodem!.results.listen(results.add);
    addTearDown(resultSub.cancel);
    session.toPeer = (data) {
      if (session.writes.length > 1) peer.receive(data);
    };
    var first = true;
    peer.toController = (data) {
      if (first) {
        first = false;
        session.emit([...utf8.encode('terminal-prefix\x1b[5n'), ...data]);
      } else {
        session.emit(data);
      }
    };
    final unblock = session.blockNextWrite = Completer<void>();
    peer.start();
    await _until(() => session.writes.isNotEmpty);
    expect(utf8.decode(session.writes.single), '\x1b[0n');
    expect(session.acked, 0);
    expect(bound.text('must-not-leak'), isTrue);
    unblock.complete();
    await _until(() => results.isNotEmpty);
    expect(results.single, isA<ZmodemDownloadCompleted>());
    expect(File('${tmp.path}/only-fixture.bin').readAsBytesSync(), data);
    expect(session.acked, greaterThan(1));
    session.emit(utf8.encode('\r\nterminal-restored'));
    await _until(() => _projected(bound, 'terminal-restored'));
    final lines = bound.snapshot.value!.lines.map((line) => line.text).join();
    expect(lines, contains('terminal-prefix'));
    expect(lines, isNot(contains('only-fixture.bin')));
    expect(bound.isClosed, isFalse);
  });

  test('upload streams only the fixture selected by the picker', () async {
    final file = File('${tmp.path}/upload.bin');
    final data = Uint8List.fromList(List.generate(96000, (i) => (i * 5) % 256));
    file.writeAsBytesSync(data);
    final files = FakeFileAccess(tmp)
      ..uploads = [
        ZmodemLocalFile(
            path: file.path, name: 'chosen.bin', length: data.length),
      ];
    final (bound, session) = await open('upload', files);
    final received = bound.zmodem!.results.first;
    final peer = FakePeer.receiver()..toController = session.emit;
    session.toPeer = peer.receive;
    peer.start();
    final result = await received.timeout(const Duration(seconds: 5));
    expect(result, isA<ZmodemUploadCompleted>());
    expect(peer.received.keys, ['chosen.bin']);
    expect(peer.received['chosen.bin']!.toBytes(), data);
    expect(session.acked, greaterThan(1));
  });

  test('cancel while folder picker is pending releases only this frame',
      () async {
    final files = _DelayedFiles(tmp);
    final (bound, session) = await open('pending-picker', files);
    final (sibling, other) = await open('sibling', FakeFileAccess(tmp));
    final peer = FakePeer.sender({
      'must-not-open.bin': Uint8List.fromList([1])
    })
      ..toController = session.emit;
    peer.start();
    await files.opened.future.timeout(const Duration(seconds: 4));
    expect(session.acked, 0);
    expect(session.writes, isEmpty);
    expect(sibling.text('other session'), isTrue);
    await _until(() => other.writes.isNotEmpty);
    expect(utf8.decode(other.writes.single), 'other session');
    final done = bound.zmodem!.results.first;
    expect(bound.key(TerminalKey.keyC, ctrl: true), isTrue);
    expect(await done.timeout(const Duration(seconds: 4)),
        isA<ZmodemTransferCancelled>());
    await _until(() => session.acked == 1);
    expect(files.returned, isFalse);
    expect(session.writes.first.take(8), List.filled(8, 0x18));
    files.release.complete();
    await _until(() => files.returned);
    await bound.close();
    expect(files.created, 0);
    expect(tmp.listSync(), isEmpty);
    expect(other.closed, 0);
  });

  test('close while upload picker is pending never sends the late file',
      () async {
    final file = File('${tmp.path}/not-sent.bin')..writeAsBytesSync([42]);
    final files = _DelayedUpload(tmp)
      ..uploads = [
        ZmodemLocalFile(path: file.path, name: 'not-sent.bin', length: 1),
      ];
    final (bound, session) = await open('stale-upload-picker', files);
    final peer = FakePeer.receiver()..toController = session.emit;
    session.toPeer = peer.receive;
    peer.start();
    await files.opened.future.timeout(const Duration(seconds: 4));
    await bound.close().timeout(const Duration(seconds: 4));
    final writes = session.writes.length;
    expect(session.closed, 1);
    files.release.complete();
    await files.returned.future.timeout(const Duration(seconds: 4));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(session.writes, hasLength(writes));
    expect(peer.received, isEmpty);
  });

  test('EOF flushes an incomplete handshake probe as terminal text', () async {
    final (bound, session) = await open('probe-eof', FakeFileAccess(tmp));
    session.emit(utf8.encode('terminal-tail*'));
    await _until(() => session.acked == 1);
    await session.frames.close();
    await _until(() => bound.isClosed);
    expect(_projected(bound, 'terminal-tail*'), isTrue);
    expect(session.writes, isEmpty);
  });

  test('cancelling a stalled active protocol frame returns its credit once',
      () async {
    final (bound, session) = await open('active-frame', FakeFileAccess(tmp));
    final blockActiveWrite = Completer<void>();
    final peer = FakePeer.sender({'pending.bin': Uint8List(10)})
      ..toController = session.emit;
    session.toPeer = (bytes) {
      if (session.writes.length == 1) {
        // Let the initial handshake cross, then hold the response to the
        // actual file offer (the controller already owns ingress).
        session.blockNextWrite = blockActiveWrite;
        peer.receive(bytes);
      }
    };
    peer.start();
    await _until(() => session.writes.length == 2);
    expect(session.acked, 1);
    expect(bound.zmodem!.isActive, isTrue);
    final result = bound.zmodem!.results.first;
    final cancelling = bound.zmodem!.cancel();
    await _until(() => session.acked == 2);
    expect(session.writes, hasLength(2));
    blockActiveWrite.complete();
    await cancelling.timeout(const Duration(seconds: 4));
    expect(await result, isA<ZmodemTransferCancelled>());
    expect(session.acked, 2);
    expect(session.writes.last.take(8), List.filled(8, 0x18));
    expect(tmp.listSync(), isEmpty);
  });

  test('cancel does not overlap a transport write already in flight', () async {
    final (bound, session) = await open('stalled-write', FakeFileAccess(tmp));
    final firstWrite = session.blockNextWrite = Completer<void>();
    final peer = FakePeer.sender({'unused.bin': Uint8List(0)})
      ..toController = session.emit;
    peer.start();
    await _until(() => session.writes.isNotEmpty);
    expect(session.acked, 0);
    final done = bound.zmodem!.results.first;
    final cancelling = bound.zmodem!.cancel();
    await _until(() => session.acked == 1 && !bound.zmodem!.isActive);
    expect(session.writes, hasLength(1));
    firstWrite.complete();
    await cancelling.timeout(const Duration(seconds: 4));
    expect(await done, isA<ZmodemTransferCancelled>());
    expect(session.writes, hasLength(2));
    expect(session.writes.last.take(8), List.filled(8, 0x18));
    expect(tmp.listSync(), isEmpty);
  });
}
