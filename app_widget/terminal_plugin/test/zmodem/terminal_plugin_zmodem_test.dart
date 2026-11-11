import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/terminal_plugin.dart';

import 'zmodem_test_support.dart';

class _FakeSession implements ExecutionSession {
  final _output = StreamController<Uint8List>();
  final writes = BytesBuilder(copy: true);
  void Function(Uint8List bytes)? onWrite;
  final _exit = Completer<int>();

  void emit(List<int> bytes) => _output.add(Uint8List.fromList(bytes));

  @override
  Stream<Uint8List> get output => _output.stream;

  @override
  Future<int> get exitCode => _exit.future;

  @override
  void ackRead() {}

  @override
  Future<void> close() async {
    if (!_exit.isCompleted) _exit.complete(0);
  }

  @override
  Future<void> resize(int width, int height) async {}

  @override
  Future<void> write(Uint8List data) async {
    writes.add(data);
    onWrite?.call(data);
  }
}

Uint8List _random(int length) {
  final random = Random(5);
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

void main() {
  late io.Directory tmp;
  late FakeFileAccess files;
  late TerminalPlugin plugin;
  late _FakeSession session;

  setUp(() {
    tmp = io.Directory.systemTemp.createTempSync('zmodem-plugin-');
    files = FakeFileAccess(tmp);
    session = _FakeSession();
  });
  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  Future<void> pumpView(WidgetTester tester) async {
    plugin = TerminalPlugin(fileAccess: files);
    addTearDown(plugin.terminal.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(body: TerminalTabView(plugin)),
      ),
    );
    plugin.didMounted();
    plugin.debugAttachSession(session);
    await tester.pump();
  }

  /// Connects [peer] as the remote side of [session].
  void connect(FakePeer peer) {
    session.onWrite = (bytes) => scheduleMicrotask(() => peer.receive(bytes));
    peer.toController = (bytes) => session.emit(bytes);
  }

  Future<void> waitFor(WidgetTester tester, bool Function() condition) async {
    for (var i = 0; i < 400 && !condition(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump();
    }
  }

  testWidgets('utf8 split across chunks renders intact', (tester) async {
    await pumpView(tester);
    final bytes = utf8.encode('中文');

    session.emit(bytes.sublist(0, 2));
    await tester.pump();
    session.emit(bytes.sublist(2));
    await tester.pump(const Duration(milliseconds: 20));

    expect(plugin.terminal.buffer.lines[0].toString(), contains('中文'));
  });

  testWidgets('sz shows the panel then a Saved to snackbar', (tester) async {
    await pumpView(tester);
    final peer = FakePeer.sender({'a.bin': _random(60000)})..stallAfter = 20000;
    connect(peer);

    await tester.runAsync(() async => peer.start());
    await waitFor(
      tester,
      () => find
          .byKey(const ValueKey('zmodem-progress-panel'))
          .evaluate()
          .isNotEmpty,
    );
    expect(find.text('a.bin'), findsOneWidget);

    // Let the sender finish the file.
    peer.stallAfter = null;
    await tester.runAsync(() async {
      peer.core.sendFileData(
        Uint8List.sublistView(peer.files['a.bin']!, 20000),
      );
      peer.core.finishSending(60000);
      session.emit(peer.core.dataToSend());
    });
    await waitFor(
      tester,
      () => find.textContaining('Saved to').evaluate().isNotEmpty,
    );

    expect(find.byKey(const ValueKey('zmodem-progress-panel')), findsNothing);
    expect(find.text('Saved to ${tmp.path}/a.bin'), findsOneWidget);
    expect(io.File('${tmp.path}/a.bin').readAsBytesSync(), peer.files['a.bin']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('Cancel button aborts and shows Transfer cancelled',
      (tester) async {
    await pumpView(tester);
    final peer = FakePeer.sender({'b.bin': _random(60000)})..stallAfter = 20000;
    connect(peer);
    await tester.runAsync(() async => peer.start());
    await waitFor(
      tester,
      () => find.byKey(const ValueKey('zmodem-cancel')).evaluate().isNotEmpty,
    );

    await tester.tap(find.byKey(const ValueKey('zmodem-cancel')));
    await waitFor(
      tester,
      () => find.text('Transfer cancelled').evaluate().isNotEmpty,
    );

    final written = session.writes.takeBytes();
    expect(written.sublist(written.length - 16), [
      ...List.filled(8, 0x18),
      ...List.filled(8, 0x08),
    ]);
    expect(io.File('${tmp.path}/b.bin').existsSync(), isFalse);
    await tester.pump(const Duration(seconds: 6));
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('typing during a transfer is not sent; Ctrl+C cancels',
      (tester) async {
    await pumpView(tester);
    final peer = FakePeer.sender({'c.bin': _random(60000)})..stallAfter = 20000;
    connect(peer);
    await tester.runAsync(() async => peer.start());
    await waitFor(tester, () => plugin.zmodem?.isActive ?? false);
    session.writes.clear();

    plugin.terminal.onOutput!('x');
    expect(session.writes.takeBytes(), isEmpty);

    plugin.terminal.onOutput!('\x03');
    await waitFor(
      tester,
      () => find.text('Transfer cancelled').evaluate().isNotEmpty,
    );
    expect(plugin.zmodem!.isActive, isFalse);

    session.writes.clear();
    plugin.terminal.onOutput!('y');
    expect(session.writes.takeBytes(), utf8.encode('y'));
    await tester.pump(const Duration(seconds: 5));
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('closing the tab mid-transfer deletes the partial file',
      (tester) async {
    await pumpView(tester);
    final peer = FakePeer.sender({'d.bin': _random(60000)})..stallAfter = 20000;
    connect(peer);
    await tester.runAsync(() async => peer.start());
    await waitFor(tester, () => io.File('${tmp.path}/d.bin').existsSync());

    plugin.didDisconnected();
    await waitFor(tester, () => !io.File('${tmp.path}/d.bin').existsSync());

    expect(io.File('${tmp.path}/d.bin').existsSync(), isFalse);
    await tester.pump(const Duration(seconds: 6));
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('rz skipping an existing file says so', (tester) async {
    await pumpView(tester);
    final source = io.File('${tmp.path}/e.bin')..writeAsBytesSync([1, 2, 3]);
    files.uploads = [
      ZmodemLocalFile(path: source.path, name: 'e.bin', length: 3),
    ];
    final peer = FakePeer.receiver()..refuse.add('e.bin');
    connect(peer);

    await tester.runAsync(() async => peer.start());
    await waitFor(
      tester,
      () => find.textContaining('e.bin').evaluate().isNotEmpty,
    );

    expect(
      find.text('e.bin already exists on the remote and was skipped '
          '(run rz -y to overwrite)'),
      findsOneWidget,
    );
    expect(find.text('Transfer cancelled'), findsNothing);
    await tester.pump(const Duration(seconds: 6));
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  test('ZmodemTransferController is exported for the screen', () {
    expect(ZmodemTransferCancelled(), isA<ZmodemTransferResult>());
  });
}
