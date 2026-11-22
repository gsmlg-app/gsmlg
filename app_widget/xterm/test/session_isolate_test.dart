import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:test/test.dart';
import 'package:xterm/session_isolate.dart';

void main() {
  late IsolateHub hub;

  setUp(() async {
    hub = IsolateHub();
    await hub.start();
  });

  tearDown(() async {
    await hub.stop();
  });

  test('OSC 52 yields only a bounded writable effect under one authority',
      () async {
    final worker = await TerminalIsolateSession.open(hub, 'clipboard');
    Future<TerminalIsolateResult> send(String data, [int? capability]) =>
        worker.appendOutput(utf8.encode(data), clipboardCapability: capability);
    final plain = await send('\x1b]52;c;4pyT\x07', 1);
    expect(plain.clipboardWrite, (1, '✓'));
    expect(plain.output, isEmpty);
    expect((await worker.snapshot()).clipboardWrite, isNull);
    final tmux = await send('\x1bPtmux;\x1b\x1b]52;pc;YQ\x07\x1b\\', 2);
    expect(tmux.clipboardWrite, (2, 'a'));
    expect((await send('\x1b]52;;\x1b\\', 2)).clipboardWrite, (2, ''));
    expect((await send('\x1b]52;c;YQ\x07\x1b]52;c;Yg\x07', 2)).clipboardWrite,
        (2, 'b'));
    for (final data in [
      '\x1b]52;c;?\x07',
      '\x1b]52;p;YQ\x07',
      '\x1b]52;c;YQ=\x07',
      '\x1b]52;c;/w==\x07',
      '\x1b]52;c;YQ;YQ\x07',
    ]) {
      final result = await send(data, 2);
      expect(result.clipboardWrite, isNull, reason: data);
      expect(result.output, isEmpty);
    }
    expect((await send('\x1b]52;c;YQ\x07')).clipboardWrite, isNull);
    await send('\x1b');
    expect((await send(']52;c;YQ\x07', 2)).clipboardWrite, isNull);
    await send('\x1b]52;c;');
    expect((await send('YQ\x07', 2)).clipboardWrite, isNull);
    await send('\x1bPtmux;\x1b\x1b]52;c;YQ\x07', 2);
    expect((await send('\x1b\\', 3)).clipboardWrite, isNull);
    await send('\x1b]52;c;YQ', 3);
    expect((await send('\x07', 4)).clipboardWrite, isNull);
    await send('\x1b]52;c;', 4);
    await send('YQ');
    expect((await send('\x07', 4)).clipboardWrite, isNull);
    final tooBig = base64.encode(Uint8List(100 * 1024 + 1));
    await send('\x1b]52;c;', 4);
    for (var i = 0; i < tooBig.length; i += 8192) {
      expect(
          (await send(
                  tooBig.substring(i, (i + 8192).clamp(0, tooBig.length)), 4))
              .clipboardWrite,
          isNull);
    }
    expect((await send('\x07', 4)).clipboardWrite, isNull);
    expect((await send('\x1b]52;c;Yw\x07', 4)).clipboardWrite, (4, 'c'));
    await worker.close();
  });

  test('mouse reports current live cells and releases each accepted down once',
      () async {
    final terminal = await TerminalIsolateSession.open(hub, 'mouse');
    await terminal.resize(12, 4);
    await terminal
        .appendOutput(utf8.encode('\x1b[?1049h\x1b[?1000h\x1b[?1006h'));
    TerminalIsolatePoint at(TerminalIsolateSnapshot view) =>
        TerminalIsolatePoint(view.viewId, 2, view.lines[2].id, 4);
    Future<String> mouse(TerminalMouseButton button, int gesture,
            TerminalIsolatePoint? point) async =>
        utf8.decode((await terminal.mouse(button, gesture, point)).output);
    const left = TerminalMouseButton.left;
    const up = TerminalMouseButton.wheelUp;
    const down = TerminalMouseButton.wheelDown;
    final alt = (await terminal.snapshot()).snapshot!;
    expect(alt.mouseButtons, isTrue);
    expect(alt.mouseWheel, isTrue);
    expect(await mouse(left, 1, at(alt)), '\x1b[<0;5;3M');
    expect(await mouse(left, 2, at(alt)), isEmpty);
    expect(await mouse(left, 2, null), isEmpty);
    // Release remains valid while ordinary output makes new downs stale.
    await terminal.appendOutput(utf8.encode('text'));
    expect(await mouse(left, 1, null), '\x1b[<0;5;3m');
    expect(await mouse(left, 1, null), isEmpty);
    expect(await mouse(left, 3, at(alt)), isEmpty);
    var current = (await terminal.snapshot()).snapshot!;
    expect(await mouse(up, 4, at(current)), '\x1b[<64;5;3M');
    expect(await mouse(down, 5, at(current)), '\x1b[<65;5;3M');
    expect(await mouse(left, 6, at(current)), '\x1b[<0;5;3M');
    // Even a mode change that reverses before projection invalidates the down.
    await terminal.appendOutput(utf8.encode('\x1b[?1006l\x1b[?1006h'));
    expect(await mouse(left, 6, null), isEmpty);
    current = (await terminal.snapshot()).snapshot!;
    expect(await mouse(left, 7, at(current)), '\x1b[<0;5;3M');
    await terminal.appendOutput(utf8.encode('\x1b[?1049l'));
    expect(await mouse(left, 7, null), isEmpty);
    expect(await mouse(left, 8, at(current)), isEmpty);
    await terminal.appendOutput(utf8.encode('a\r\nb\r\nc\r\nd\r\ne\r\nf'));
    final historical = (await terminal.snapshot(scrollRows: -2)).snapshot!;
    expect(historical.firstRow, lessThan(historical.historyRows));
    expect(historical.mouseButtons, isFalse);
    expect(await mouse(left, 9, at(historical)), isEmpty);
    current = (await terminal.snapshot(followTail: true)).snapshot!;
    expect(current.mouseButtons, isTrue);
    expect(current.mouseWheel, isFalse);
    expect(await mouse(up, 10, at(current)), isEmpty);
    expect(await mouse(left, 11, at(current)), '\x1b[<0;5;3M');
    expect(utf8.decode((await terminal.resize(10, 4)).output), '\x1b[<0;5;3m');
    expect(await mouse(left, 11, null), isEmpty);
    expect(await mouse(left, 12, at(current)), isEmpty);
    await terminal.close();
  });

  test('one worker per session, with isolated parser state and ID', () async {
    final first = await TerminalIsolateSession.open(
      hub,
      'first',
      scrollback: 50000,
    );
    final second = await TerminalIsolateSession.open(hub, 'second');
    expect(first.workerId, isNot(second.workerId));

    await first.appendOutput(utf8.encode('first shell'));
    await second.appendOutput(utf8.encode('second shell'));
    final firstView = (await first.snapshot()).snapshot!;
    final secondView = (await second.snapshot()).snapshot!;
    expect(firstView.lines.first.text, 'first shell');
    expect(secondView.lines.first.text, 'second shell');
    expect(firstView.lines, hasLength(firstView.rows));
    expect(firstView.lines.first.cells, hasLength(firstView.columns * 4));

    await first.close();
    expect(hub.lookupNode('/first'), isNull);
    expect(
        (await second.snapshot()).snapshot!.lines.first.text, 'second shell');
    await second.close();
  });

  test('split DECSET completes and returns credit before queued paste',
      () async {
    final session = await TerminalIsolateSession.open(hub, 'ordered');
    final events = <String>[];
    final prefix = utf8.encode('\x1b[?20');
    final suffix = utf8.encode('04h');
    final first = session.appendOutput(prefix).then((result) {
      expect(result.consumedBytes, prefix.length);
      events.add('first credit');
    });
    final second = session.appendOutput(suffix).then((result) {
      expect(result.consumedBytes, suffix.length);
      events.add('mode credit');
    });
    final paste = session.paste('a\nb').then((result) {
      expect(result.consumedBytes, 0);
      expect(utf8.decode(result.output), '\x1b[200~a\rb\x1b[201~');
      events.add('paste');
    });
    expect(events, isEmpty);
    await Future.wait([first, second, paste]);
    expect(events, ['first credit', 'mode credit', 'paste']);
    await session.close();
  });

  test('a delayed dispatch retains credit and blocks later paste', () async {
    final controlled = _ControlledHub(hub);
    final session = await TerminalIsolateSession.open(controlled, 'delayed');
    final release = controlled.pauseNext();
    final mode = utf8.encode('\x1b[?2004h');
    var credited = false;
    final parsed = session.appendOutput(mode).then((result) {
      credited = true;
      return result;
    });
    final paste = session.paste('example');
    expect(controlled.commandCount, 1);
    expect(credited, isFalse);
    release.complete();
    expect((await parsed).consumedBytes, mode.length);
    expect(utf8.decode((await paste).output), '\x1b[200~example\x1b[201~');
    expect(controlled.commandCount, 2);
    await session.close();
  });

  test('an ambiguous RPC failure aborts instead of replaying', () async {
    final controlled = _ControlledHub(hub);
    final session = await TerminalIsolateSession.open(controlled, 'failed');
    final release = controlled.pauseNext();
    final first = expectLater(
      session.appendOutput(utf8.encode('partial')),
      throwsA(isA<TimeoutException>()),
    );
    final queued = expectLater(session.paste('not replayed'), throwsStateError);
    release.completeError(TimeoutException('controlled deadline'));
    await Future.wait([first, queued]);
    await session.close();
    expect(controlled.commandCount, 1);
    expect(hub.lookupNode('/failed'), isNull);
  });

  test('UTF-8 remains streaming across frames and EOF is serialized', () async {
    final session = await TerminalIsolateSession.open(hub, 'utf8');
    final symbol = utf8.encode('中');
    await session.appendOutput(Uint8List.fromList(symbol.take(2).toList()));
    await session.appendOutput(Uint8List.fromList([symbol.last, symbol.first]));
    await session.finishOutput();
    final view = (await session.snapshot()).snapshot!;
    expect(view.lines.first.text, '中�');
    await session.close();
  });

  test('viewport responds to resize and alternate screen switching', () async {
    final session = await TerminalIsolateSession.open(hub, 'viewport');
    await session.resize(20, 5);
    await session.appendOutput(utf8.encode('main'));
    await session.appendOutput(utf8.encode('\x1b[?1049halt'));
    final alt = (await session.snapshot()).snapshot!;
    expect(alt.columns, 20);
    expect(alt.rows, 5);
    expect(alt.alternateScreen, isTrue);
    expect(alt.lines.first.text, 'alt');
    await session.appendOutput(utf8.encode('\x1b[?1049l'));
    final main = (await session.snapshot()).snapshot!;
    expect(main.alternateScreen, isFalse);
    expect(main.lines.first.text, 'main');
    await session.close();
  });

  test('history exposes one bounded page with a persistent top line', () async {
    final session =
        await TerminalIsolateSession.open(hub, 'history', scrollback: 50000);
    await session.resize(10, 3);
    await session.appendOutput(utf8.encode(
      List.generate(20, (n) => 'row${n.toString().padLeft(2, '0')}')
          .join('\r\n'),
    ));
    final live = (await session.snapshot()).snapshot!;
    expect(live.historyRows, greaterThan(10));
    expect(live.firstRow, live.historyRows);
    final oldest = (await session.snapshot(scrollRows: -100000)).snapshot!;
    expect(oldest.firstRow, 0);
    expect(oldest.lines, hasLength(3));
    expect(oldest.cursorVisible, isFalse);
    expect(oldest.lines.first.text, 'row00');
    await session.appendOutput(utf8.encode('\r\nnewest'));
    final held = (await session.snapshot()).snapshot!;
    expect(held.lines.first.id, oldest.lines.first.id);
    expect(held.historyRows, greaterThan(oldest.historyRows));

    await session.appendOutput(utf8.encode('\x1b[?1049halt'));
    final alternate = (await session.snapshot(scrollRows: -5)).snapshot!;
    expect(alternate.alternateScreen, isTrue);
    expect(alternate.historyRows, 0);
    expect(alternate.firstRow, 0);
    expect(alternate.lines.first.text, 'alt');
    await session.appendOutput(utf8.encode('\x1b[?1049l'));
    expect((await session.snapshot()).snapshot!.lines.first.id,
        oldest.lines.first.id);
    final returned = (await session.snapshot(followTail: true)).snapshot!;
    expect(returned.firstRow, returned.historyRows);
    expect(returned.lines.last.text, 'newest');
    await session.close();
  });

  test('worker selection can extend across pages despite unrelated output',
      () async {
    final session = await TerminalIsolateSession.open(hub, 'selection');
    await session.resize(10, 3);
    await session.appendOutput(utf8.encode(
      List.generate(20, (n) => 'row${n.toString().padLeft(2, '0')}')
          .join('\r\n'),
    ));
    final start = (await session.snapshot(scrollRows: -100000)).snapshot!;
    final id = (await session.beginSelection(_point(start, 0, 0))).selectionId!;
    // Advance through more projections than the worker's short hit-test cache.
    for (var step = 0; step < 4; step++) {
      final frame = (await session.snapshot(scrollRows: 1)).snapshot!;
      expect(frame.selectionAnchorRow, 0);
      expect(frame.selectionId, id);
    }
    final end = (await session.snapshot()).snapshot!;
    await session.appendOutput(utf8.encode('\r\nunrelated'));
    final copy = await session.copySelection(id, _point(end, 0, 5));
    expect(copy.selectionText, 'row00\nrow01\nrow02\nrow03\nrow04');
    await session.appendOutput(utf8.encode('\x1b[3J'));
    expect((await session.snapshot()).snapshot!.selectionAnchorRow, isNull);
    expect((await session.copySelection(id, _point(end, 0, 5))).selectionText,
        isNull);
    await session.close();
  });

  test('worker snaps to full wide glyphs and joins soft-wrap rows', () async {
    final session = await TerminalIsolateSession.open(hub, 'wide');
    await session.resize(5, 3);
    await session.appendOutput(utf8.encode('a你bcdef'));
    final frame = (await session.snapshot()).snapshot!;
    expect(frame.lines.take(2).map((line) => line.text), ['a你bc', 'def']);
    final id = (await session.beginSelection(_point(frame, 0, 2))).selectionId!;
    expect((await session.copySelection(id, _point(frame, 0, 3))).selectionText,
        '你');
    expect((await session.copySelection(id, _point(frame, 1, 3))).selectionText,
        '你bcdef');

    final reversed =
        (await session.beginSelection(_point(frame, 0, 2))).selectionId!;
    expect(
        (await session.copySelection(reversed, _point(frame, 0, 0)))
            .selectionText,
        'a你');
    await session.close();
  });

  test('stale live hit, wrong buffer, and resize are rejected without closing',
      () async {
    final session = await TerminalIsolateSession.open(hub, 'stale');
    await session.resize(10, 3);
    await session.appendOutput(utf8.encode('old'));
    final frame = (await session.snapshot()).snapshot!;
    final id = (await session.beginSelection(_point(frame, 0, 0))).selectionId!;
    await session.appendOutput(utf8.encode('\rnew'));
    expect((await session.beginSelection(_point(frame, 0, 0))).selectionId,
        isNull);
    expect((await session.copySelection(id, _point(frame, 0, 3))).selectionText,
        isNull);

    final fresh = (await session.snapshot()).snapshot!;
    final nextId =
        (await session.beginSelection(_point(fresh, 0, 0))).selectionId!;
    await session.appendOutput(utf8.encode('\x1b[?1049hother'));
    expect(
        (await session.copySelection(nextId, _point(fresh, 0, 3)))
            .selectionText,
        isNull);
    await session.appendOutput(utf8.encode('\x1b[?1049l'));
    await session.resize(8, 3);
    expect((await session.beginSelection(_point(fresh, 0, 0))).selectionId,
        isNull);
    expect((await session.snapshot()).snapshot!.columns, 8);
    expect(() => session.resize(1, 3), throwsRangeError);
    await session.close();
  });

  test('small profile still covers taller viewport and hidden excess history',
      () async {
    final session =
        await TerminalIsolateSession.open(hub, 'tall', scrollback: 24);
    await session.resize(10, 64);
    final tall = (await session.snapshot()).snapshot!;
    expect(tall.lines.length, 64);
    expect(tall.firstRow, tall.historyRows);
    await session.appendOutput(
        utf8.encode(List.generate(80, (index) => 'row$index').join('\r\n')));
    await session.appendOutput(utf8.encode('\x1b[?1049halt'));
    final alt = (await session.snapshot()).snapshot!;
    expect(alt.lines.length, 64);
    expect(alt.historyRows, 0);
    expect(alt.alternateScreen, isTrue);
    await session.appendOutput(utf8.encode('\x1b[?1049l'));
    await session.resize(10, 3);
    final shrunk = (await session.snapshot(scrollRows: -100000)).snapshot!;
    expect(shrunk.historyRows - shrunk.firstRow, lessThanOrEqualTo(21));
    expect(shrunk.lines.length, 3);
    await session.resize(10, 64);
    final grown = (await session.snapshot()).snapshot!;
    expect(grown.lines.map((line) => line.text), isNot(contains('row16')));
    await session.close();
  });

  test('one selection cannot marshal an unbounded copy result', () async {
    final session = await TerminalIsolateSession.open(hub, 'large');
    await session.resize(512, 256);
    final frame = (await session.snapshot()).snapshot!;
    final id = (await session.beginSelection(_point(frame, 0, 0))).selectionId!;
    expect(
        (await session.copySelection(id, _point(frame, 255, 512)))
            .selectionText,
        isNull);
    await session.close();
  });

  test('bounded admission and immediate queued cancellation on close',
      () async {
    final session = await TerminalIsolateSession.open(hub, 'bounded');
    final work = <Future<void>>[];
    final chunk = Uint8List(TerminalIsolateSession.maxCommandBytes);
    for (var index = 0;
        index < TerminalIsolateSession.maxPendingBytes ~/ chunk.length;
        index++) {
      work.add(expectLater(session.appendOutput(chunk), throwsStateError));
    }
    final overflow = expectLater(session.appendOutput(chunk), throwsStateError);
    final closing = session.close();
    expect(session.close(), same(closing));
    await Future.wait([...work, overflow]);
    await closing;
    expect(hub.lookupNode('/bounded'), isNull);
    await expectLater(session.paste('late'), throwsStateError);
  });
}

final class _ControlledHub implements IsolateHub {
  _ControlledHub(this.inner);

  final IsolateHub inner;
  Completer<void>? _pause;
  var commandCount = 0;

  Completer<void> pauseNext() => _pause = Completer<void>();

  @override
  TreeNode? lookupNode(String target) => inner.lookupNode(target);

  @override
  Future<IsolateNode> registerService(
    ChildSpec spec, {
    String? parentPath,
    bool start = true,
  }) =>
      inner.registerService(spec, parentPath: parentPath, start: start);

  @override
  Future<TRes> call<TRes>(
    String target,
    Object? request, {
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) async {
    if (request != 'identity') {
      commandCount++;
      if (_pause case final pause?) {
        _pause = null;
        await pause.future;
      }
    }
    return inner.call<TRes>(target, request,
        timeout: timeout, metadata: metadata);
  }

  @override
  Future<void> removeNode(String target, {Duration? timeout}) =>
      inner.removeNode(target, timeout: timeout);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TerminalIsolatePoint _point(
        TerminalIsolateSnapshot frame, int row, int column) =>
    TerminalIsolatePoint(frame.viewId, row, frame.lines[row].id, column);
