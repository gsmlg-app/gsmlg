import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/src/isolate_session_binding.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:xterm/session_isolate.dart';
import 'package:xterm/session_isolate_view.dart';
import 'package:xterm/src/ui/custom_text_edit.dart';
import 'package:xterm/xterm.dart';

final class _Transport implements ExecutionSession {
  final received = StreamController<Uint8List>();
  final exited = Completer<int>();
  final writes = <String>[];
  final observed = <String>[];
  Completer<void>? delayNextWrite;
  int closes = 0;

  @override
  Stream<Uint8List> get output => received.stream;
  @override
  Future<int> get exitCode => exited.future;

  @override
  void ackRead() => observed.add('ack');

  @override
  Future<void> write(Uint8List data) async {
    final text = utf8.decode(data);
    writes.add(text);
    observed.add('write');
    final delay = delayNextWrite;
    delayNextWrite = null;
    await delay?.future;
  }

  @override
  Future<void> resize(int width, int height) async =>
      observed.add('resize:$width:$height');

  @override
  Future<void> close() async {
    closes++;
    if (!exited.isCompleted) exited.complete(0);
    unawaited(received.close());
  }
}

final class _Host implements Host {
  _Host(this.sessions);

  final List<_Transport> sessions;
  final _done = Completer<void>();
  int disconnects = 0;

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async =>
      sessions.removeAt(0);

  @override
  Future<void> disconnect() async {
    disconnects++;
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<void> get done => _done.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Spec implements HostSpec {
  @override
  String get name => 'Isolate experiment fixture';

  @override
  HostConnector createConnector() => throw UnsupportedError('No connector');
}

Future<void> _until(bool Function() done) async {
  final timeout = Stopwatch()..start();
  while (!done()) {
    if (timeout.elapsed > const Duration(seconds: 3)) {
      fail('Timed out waiting for worker or transport');
    }
    await Future<void>.delayed(const Duration(milliseconds: 4));
  }
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() done) async {
  final timeout = Stopwatch()..start();
  while (!done()) {
    if (timeout.elapsed > const Duration(seconds: 3)) {
      fail('Timed out pumping isolate view');
    }
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 6)));
    await tester.pump(const Duration(milliseconds: 17));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a detached terminal keeps parsing without publishing snapshots',
      () async {
    final hub = IsolateHub();
    await hub.start();
    addTearDown(hub.stop);
    final worker = await TerminalIsolateSession.open(hub, 'view-admission');
    final transport = _Transport();
    final binding = IsolateSessionBinding(
      worker,
      transport,
      onClosed: (error) => fail('Unexpected close: $error'),
      projectOnlyWhenVisible: true,
    );
    addTearDown(binding.close);
    binding.start();
    transport.received.add(utf8.encode('parsed while detached\x1b[5n'));
    await _until(() => transport.observed.contains('ack'));
    expect(transport.writes, ['\x1b[0n']);
    expect(binding.snapshot.value, isNull);

    binding.setProjectionVisible(true);
    await _until(() => binding.snapshot.value != null);
    final first = binding.snapshot.value!;
    expect(first.lines.first.text, 'parsed while detached');
    binding.setProjectionVisible(false);
    transport.received.add(utf8.encode('\r\nnew detached output'));
    await _until(
        () => transport.observed.where((value) => value == 'ack').length == 2);
    await Future<void>.delayed(const Duration(milliseconds: 35));
    expect(binding.snapshot.value, same(first));

    binding.setProjectionVisible(true);
    await _until(() => binding.snapshot.value != first);
    expect(binding.snapshot.value!.lines[1].text, 'new detached output');
    await binding.close();
  });

  test('egress and frame acknowledgment cannot overtake a blocked reply',
      () async {
    final hub = IsolateHub();
    await hub.start();
    addTearDown(hub.stop);
    final worker = await TerminalIsolateSession.open(hub, 'transport');
    final transport = _Transport();
    final binding = IsolateSessionBinding(
      worker,
      transport,
      onClosed: (error) => fail('Unexpected close: $error'),
    );
    addTearDown(binding.close);
    binding.start();

    final releaseWrite = transport.delayNextWrite = Completer<void>();
    transport.received.add(utf8.encode('\x1b[?2004h\x1b[5n'));
    await _until(() => transport.writes.isNotEmpty);
    expect(transport.writes, ['\x1b[0n']);
    expect(binding.paste('x'), isTrue);
    expect(transport.observed, ['write']);
    releaseWrite.complete();
    await _until(() => transport.writes.length == 2);
    expect(transport.observed, ['write', 'ack', 'write']);
    expect(transport.writes.last, '\x1b[200~x\x1b[201~');
    await binding.close();
    expect(binding.text('late'), isFalse);
    expect(transport.closes, 1);
    expect(hub.lookupNode('/transport'), isNull);
  });

  test('a pending local scroll wins over a down aimed at the live tail',
      () async {
    final hub = IsolateHub();
    await hub.start();
    addTearDown(hub.stop);
    final worker = await TerminalIsolateSession.open(hub, 'mouse-scroll-race');
    final transport = _Transport();
    final binding = IsolateSessionBinding(
      worker,
      transport,
      onClosed: (error) => fail('Unexpected close: $error'),
    );
    addTearDown(binding.close);
    binding.start();
    binding.resize(12, 4);
    transport.received.add(utf8.encode('\x1b[?1000h\x1b[?1006h'
        '${List.generate(8, (n) => "row$n").join("\r\n")}'));
    await _until(() => binding.snapshot.value?.mouseButtons == true);
    final frame = binding.snapshot.value!;
    final at = TerminalIsolatePoint(frame.viewId, 0, frame.lines[0].id, 0);
    binding.scrollRows(-1);
    binding.mouse(TerminalMouseButton.left, 1, at);
    binding.mouse(TerminalMouseButton.left, 1, null);
    await _until(() => binding.snapshot.value!.firstRow < frame.firstRow);
    expect(transport.writes, isEmpty);
    await binding.close();
  });

  test('a wheel burst drops excess while preserving ordered release and input',
      () async {
    final hub = IsolateHub();
    await hub.start();
    addTearDown(hub.stop);
    final worker = await TerminalIsolateSession.open(hub, 'mouse-pressure');
    final transport = _Transport();
    final binding = IsolateSessionBinding(
      worker,
      transport,
      onClosed: (error) => fail('Unexpected close: $error'),
    );
    addTearDown(binding.close);
    binding.start();
    transport.received.add(utf8.encode('\x1b[?1049h\x1b[?1000h\x1b[?1006h'));
    await _until(() => binding.snapshot.value?.mouseWheel == true);
    final frame = binding.snapshot.value!;
    final at = TerminalIsolatePoint(frame.viewId, 0, frame.lines[0].id, 0);
    final releaseWrite = transport.delayNextWrite = Completer<void>();
    binding.mouse(TerminalMouseButton.left, 1, at);
    await _until(() => transport.writes.isNotEmpty);
    for (var i = 0; i < 128; i++) {
      binding.mouse(TerminalMouseButton.wheelUp, i + 2, at);
    }
    binding.mouse(TerminalMouseButton.left, 1, null);
    expect(binding.text('barrier'), isTrue);
    releaseWrite.complete();
    await _until(() => transport.writes.contains('barrier'));
    expect(transport.writes, [
      '\x1b[<0;1;1M',
      ...List.filled(7, '\x1b[<64;1;1M'),
      '\x1b[<0;1;1m',
      'barrier',
    ]);
    expect(binding.isClosed, isFalse);
    await binding.close();
  });

  test('bindings close only their own channel and block stale egress',
      () async {
    final hub = IsolateHub();
    await hub.start();
    addTearDown(hub.stop);
    final firstWorker = await TerminalIsolateSession.open(hub, 'one');
    final secondWorker = await TerminalIsolateSession.open(hub, 'two');
    final first = _Transport();
    final second = _Transport();
    final one = IsolateSessionBinding(firstWorker, first, onClosed: (_) {});
    final two = IsolateSessionBinding(secondWorker, second, onClosed: (_) {});
    addTearDown(one.close);
    addTearDown(two.close);
    one.start();
    two.start();
    final releaseWrite = first.delayNextWrite = Completer<void>();
    first.received.add(utf8.encode('\x1b[5n'));
    await _until(() => first.writes.isNotEmpty);
    expect(one.text('queued old input'), isTrue);
    await one.close();
    releaseWrite.complete();
    expect(one.text('late old input'), isFalse);
    expect(two.text('new input'), isTrue);
    await _until(() => second.writes.isNotEmpty);
    expect(first.closes, 1);
    expect(first.observed, ['write']);
    expect(second.closes, 0);
    expect(second.writes, ['new input']);
  });

  test('typing cancels an earlier pending scroll but not a later one',
      () async {
    final hub = IsolateHub();
    await hub.start();
    addTearDown(hub.stop);
    final worker = await TerminalIsolateSession.open(hub, 'scroll-intent');
    final transport = _Transport();
    final binding = IsolateSessionBinding(worker, transport, onClosed: (_) {});
    addTearDown(binding.close);
    binding.start();
    binding.resize(10, 3);
    transport.received
        .add(utf8.encode(List.generate(16, (n) => 'row$n').join('\r\n')));
    await _until(() => (binding.snapshot.value?.historyRows ?? 0) > 5);
    final firstView = binding.snapshot.value!.viewId;
    binding.scrollRows(-3);
    binding.text('type');
    await _until(() => binding.snapshot.value!.viewId > firstView);
    expect(
        binding.snapshot.value!.firstRow, binding.snapshot.value!.historyRows);
    final secondView = binding.snapshot.value!.viewId;
    binding.text('type');
    binding.scrollRows(-2);
    await _until(() => binding.snapshot.value!.viewId > secondView);
    expect(
        binding.snapshot.value!.historyRows - binding.snapshot.value!.firstRow,
        2);
    await binding.close();
  });

  testWidgets('opt-in route paints snapshots and forwards keyboard and IME',
      (tester) async {
    final first = _Transport();
    final second = _Transport();
    final host = _Host([first, second]);
    final manager = PluginManager(_Spec());
    final optedIn = TerminalPlugin(useIsolatedTerminal: true);
    final sibling = TerminalPlugin(useIsolatedTerminal: true);

    await tester.runAsync(() async {
      manager.add(optedIn);
      manager.add(sibling);
      manager.didConnected(host);
      await _until(() => optedIn.session == first && sibling.session == second);
      first.received.add(utf8.encode('visible text'));
      await _until(() => first.observed.contains('ack'));
    });
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xff000000),
        builder: (_, __) => SizedBox(
            width: 480, height: 270, child: Builder(builder: optedIn.build)),
      ),
    );
    await tester.pump();
    final view = find.byType(TerminalIsolateView);
    expect(view, findsOneWidget);
    expect(find.byType(TerminalView), findsNothing);
    final projected = tester.widget<TerminalIsolateView>(view).snapshot;
    await _pumpUntil(tester, () {
      final snapshot = projected.value;
      return snapshot != null &&
          snapshot.lines.first.text == 'visible text' &&
          first.observed
              .contains('resize:${snapshot.columns}:${snapshot.rows}');
    });
    await tester.tap(view);
    await tester.pump();
    final oldView = tester.widget<TerminalIsolateView>(view);
    final input =
        tester.state<CustomTextEditState>(find.byType(CustomTextEdit));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    final prefix = input.currentTextEditingValue!.text;
    input.updateEditingValue(TextEditingValue(text: '$prefix\u6587'));
    await _pumpUntil(tester, () => first.writes.length == 2);
    expect(first.writes.first, '\x1b[A');
    expect(first.writes.last, '文');
    await tester.runAsync(() async {
      manager.remove(optedIn);
      await _until(() => first.closes == 1);
    });
    await tester.pump();
    expect(view, findsNothing);
    oldView.onText('late');
    expect(first.writes, ['\x1b[A', '文']);
    expect(second.writes, isEmpty);
    expect(second.closes, 0);
    expect(host.disconnects, 0);
    await tester.runAsync(() async {
      manager.remove(sibling);
      await _until(() => second.closes == 1);
    });
  }, variant: const TargetPlatformVariant({TargetPlatform.macOS}));
  testWidgets('OSC 52 is write-only, foreground scoped and never replayed',
      (tester) async {
    final transport = _Transport();
    final manager = PluginManager(_Spec());
    final writes = <String>[];
    final elsewhere = FocusNode();
    addTearDown(elsewhere.dispose);
    bool allowed = true;
    bool active = true;
    Completer<void>? releaseClipboard;
    final plugin = TerminalPlugin(
      useIsolatedTerminal: true,
      remoteClipboardWritesAllowed: () => allowed,
      isExperimentalClipboardTabActive: () => active,
      writeClipboard: (text) async {
        writes.add(text);
        await releaseClipboard?.future;
      },
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.runAsync(() async {
      manager.add(plugin);
      manager.didConnected(_Host([transport]));
      await _until(() => plugin.session == transport);
    });
    await tester.pumpWidget(WidgetsApp(
      color: const Color(0xff000000),
      builder: (context, _) => Column(children: [
        Focus(focusNode: elsewhere, child: const SizedBox(height: 10)),
        SizedBox(width: 380, height: 120, child: plugin.build(context)),
      ]),
    ));
    final view = find.byType(TerminalIsolateView);
    await _pumpUntil(tester, () => view.evaluate().isNotEmpty);
    expect(plugin.remoteClipboard.trusted, isTrue);

    Future<void> receive(String message) async {
      final previous =
          transport.observed.where((event) => event == 'ack').length;
      await tester.runAsync(() async {
        transport.received.add(utf8.encode(message));
      });
      await _pumpUntil(
        tester,
        () =>
            transport.observed.where((event) => event == 'ack').length >
            previous,
      );
    }

    String osc(String text) =>
        '\x1b]52;c;${base64.encode(utf8.encode(text))}\x07';

    elsewhere.requestFocus();
    await tester.pump();
    await receive(osc('unfocused'));
    expect(writes, isEmpty);
    await tester.tap(view);
    await tester.pump();
    await receive(osc('trusted'));
    await _pumpUntil(tester, () => writes.contains('trusted'));
    await receive('\x1b]52;c;?\x07');
    expect(transport.writes, isEmpty);

    plugin.setRemoteClipboardTrusted(false);
    await receive('\x1b]52;c;YmVmb3Jl');
    plugin.setRemoteClipboardTrusted(true);
    await receive('\x07');
    expect(writes, ['trusted']);
    active = false;
    plugin.invalidateIsolatedClipboardContext();
    await receive(osc('hidden tab'));
    active = true;
    plugin.invalidateIsolatedClipboardContext();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await receive(osc('inactive window'));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(writes, ['trusted']);

    releaseClipboard = Completer<void>();
    await receive(osc('dispatched'));
    await _pumpUntil(tester, () => writes.contains('dispatched'));
    await receive(osc('pending'));
    allowed = false;
    plugin.invalidateIsolatedClipboardContext();
    allowed = true;
    plugin.invalidateIsolatedClipboardContext();
    releaseClipboard.complete();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump();
    expect(writes, ['trusted', 'dispatched']);
    final snapshot = tester.widget<TerminalIsolateView>(view).snapshot;
    await receive("${osc('after settings cycle')}\r\nWT_CLIPBOARD_LAST");
    await _pumpUntil(
        tester,
        () =>
            snapshot.value?.lines
                .any((line) => line.text.contains('WT_CLIPBOARD_LAST')) ??
            false);
    await _pumpUntil(tester, () => writes.contains('after settings cycle'));
    expect(writes, ['trusted', 'dispatched', 'after settings cycle']);
    expect(transport.writes, isEmpty);

    releaseClipboard = Completer<void>();
    await receive(osc('dispatched before close'));
    await _pumpUntil(tester, () => writes.contains('dispatched before close'));
    await receive("${osc('pending at close')}\r\nWT_CLIPBOARD_CLOSE");
    await _pumpUntil(
        tester,
        () =>
            snapshot.value?.lines
                .any((line) => line.text.contains('WT_CLIPBOARD_CLOSE')) ??
            false);
    await tester.runAsync(() async {
      manager.remove(plugin);
      await _until(() => transport.closes == 1);
    });
    releaseClipboard.complete();
    await tester.pump();
    expect(plugin.remoteClipboard.sessionActive, isFalse);
    expect(writes, [
      'trusted',
      'dispatched',
      'after settings cycle',
      'dispatched before close',
    ]);
  }, variant: const TargetPlatformVariant({TargetPlatform.macOS}));

  testWidgets('viewport input and IME follow the displayed snapshot source',
      (tester) async {
    final first = ValueNotifier<TerminalIsolateSnapshot?>(null);
    final second = ValueNotifier<TerminalIsolateSnapshot?>(null);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    late int width;
    late int height;
    final hits = <TerminalIsolatePoint>[];
    final sources =
        ValueNotifier<ValueNotifier<TerminalIsolateSnapshot?>>(first);
    addTearDown(sources.dispose);
    await tester.pumpWidget(WidgetsApp(
      color: const Color(0xff000000),
      builder: (context, _) => Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          height: 110,
          child: ValueListenableBuilder(
            valueListenable: sources,
            builder: (context, source, _) => TerminalIsolateView(
              snapshot: source,
              onKey: (_, {required ctrl, required alt, required shift}) =>
                  false,
              onText: (_) {},
              onResize: (columns, rows) {
                width = columns;
                height = rows;
              },
              onMouse: (_, __, point) {
                if (point != null) hits.add(point);
              },
              textStyle: const TerminalStyle(),
              cursorType: TerminalCursorType.block,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    TerminalIsolateSnapshot frame(int id, {int column = 0}) =>
        TerminalIsolateSnapshot(
            columns: width,
            rows: height,
            cursorColumn: column,
            cursorRow: 0,
            cursorVisible: true,
            alternateScreen: false,
            lines: [
              for (var row = 0; row < height; row++)
                TerminalIsolateLine(row + 1, '', Uint32List(width * 4), false),
            ],
            viewId: id,
            revision: id,
            firstRow: 0,
            historyRows: 0,
            selectionId: null,
            selectionAnchorRow: null,
            mouseButtons: true);
    final view = find.byType(TerminalIsolateView);
    final paint = find.descendant(
        of: view,
        matching: find.byWidgetPredicate(
            (widget) => widget is CustomPaint && widget.painter != null));
    final start = tester.getTopLeft(view) + const Offset(2, 2);

    Future<void> click() async {
      final pointer = await tester.startGesture(start,
          kind: PointerDeviceKind.mouse, buttons: kPrimaryMouseButton);
      await pointer.up();
    }

    first.value = frame(1);
    await tester.pump();
    double caretX() => ((tester.testTextInput.log
            .lastWhere(
              (call) => call.method == 'TextInput.setCaretRect',
            )
            .arguments as Map)['x'] as num)
        .toDouble();
    final initialCaret = caretX();
    final initialPainter = tester.widget<CustomPaint>(paint).painter;
    first.value = frame(2, column: 2);
    await click();
    expect(hits.last.viewId, 1);
    await tester.pump();
    expect(caretX(), greaterThan(initialCaret));
    await click();
    expect(hits.last.viewId, 2);

    second.value = frame(8);
    sources.value = second;
    await tester.pump();
    final secondPainter = tester.widget<CustomPaint>(paint).painter;
    expect(secondPainter, isNot(same(initialPainter)));
    first.value = frame(3);
    await tester.pump();
    await click();
    expect(hits.last.viewId, 8);
    await tester.pumpWidget(const SizedBox.shrink());
  }, variant: const TargetPlatformVariant({TargetPlatform.macOS}));

  testWidgets('desktop physical mouse routes through the worker and transport',
      (tester) async {
    final transport = _Transport();
    final manager = PluginManager(_Spec());
    final plugin = TerminalPlugin(useIsolatedTerminal: true);
    await tester.runAsync(() async {
      manager.add(plugin);
      manager.didConnected(_Host([transport]));
      await _until(() => plugin.session == transport);
    });
    await tester.pumpWidget(WidgetsApp(
      color: const Color(0xff000000),
      builder: (context, _) => Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 380, height: 120, child: plugin.build(context)),
      ),
    ));
    await tester.runAsync(() async {
      transport.received.add(utf8.encode('\x1b[?1049h\x1b[?1000h\x1b[?1006h'));
    });
    final view = find.byType(TerminalIsolateView);
    await _pumpUntil(tester, () {
      if (view.evaluate().isEmpty) return false;
      final frame = tester.widget<TerminalIsolateView>(view).snapshot.value;
      return frame != null &&
          frame.mouseButtons &&
          transport.observed.contains('resize:${frame.columns}:${frame.rows}');
    });
    final start = tester.getTopLeft(view) + const Offset(2, 2);
    final send = tester.widget<TerminalIsolateView>(view);
    for (final button in [
      kPrimaryMouseButton,
      kMiddleMouseButton,
      kSecondaryMouseButton,
    ]) {
      final pointer = await tester.startGesture(start,
          kind: PointerDeviceKind.mouse, buttons: button);
      await pointer.moveBy(const Offset(80, 30));
      await pointer.up();
    }
    await tester.sendEventToBinding(PointerScrollEvent(
        position: start,
        kind: PointerDeviceKind.mouse,
        scrollDelta: const Offset(0, -30)));
    await tester.sendEventToBinding(PointerScrollEvent(
        position: start,
        kind: PointerDeviceKind.mouse,
        scrollDelta: const Offset(0, 30)));
    await _pumpUntil(tester, () => transport.writes.length == 8);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    final optionDrag =
        await tester.startGesture(start, kind: PointerDeviceKind.mouse);
    await optionDrag.moveBy(const Offset(70, 0));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await optionDrag.up();
    await _pumpUntil(tester, () => send.snapshot.value?.selectionId != null);
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump();
    final canceled =
        await tester.startGesture(start, kind: PointerDeviceKind.mouse);
    await canceled.cancel();
    send.onText('barrier');
    await _pumpUntil(tester, () => transport.writes.contains('barrier'));
    expect(transport.writes, [
      '\x1b[<0;1;1M',
      '\x1b[<0;1;1m',
      '\x1b[<1;1;1M',
      '\x1b[<1;1;1m',
      '\x1b[<2;1;1M',
      '\x1b[<2;1;1m',
      '\x1b[<64;1;1M',
      '\x1b[<65;1;1M',
      '\x1b[<0;1;1M',
      '\x1b[<0;1;1m',
      'barrier',
    ]);
    await tester.runAsync(() async {
      manager.remove(plugin);
      await _until(() => transport.closes == 1);
    });
    await tester.pump();
  }, variant: const TargetPlatformVariant({TargetPlatform.macOS}));

  testWidgets('wheel browses history and Shift extends a worker selection',
      (tester) async {
    final transport = _Transport();
    final manager = PluginManager(_Spec());
    final plugin = TerminalPlugin(useIsolatedTerminal: true);
    await tester.runAsync(() async {
      manager.add(plugin);
      manager.didConnected(_Host([transport]));
      await _until(() => plugin.session == transport);
    });

    await tester.pumpWidget(WidgetsApp(
      color: const Color(0xff000000),
      builder: (context, _) => Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 380, height: 120, child: plugin.build(context)),
      ),
    ));
    final view = find.byType(TerminalIsolateView);
    await _pumpUntil(
        tester,
        () =>
            view.evaluate().isNotEmpty &&
            transport.observed.any((signal) => signal.startsWith('resize:')));
    final displayed = tester.widget<TerminalIsolateView>(view).snapshot;
    await tester.runAsync(() async {
      transport.received.add(utf8.encode(List.generate(
        24,
        (index) => 'row${index.toString().padLeft(2, '0')}',
      ).join('\r\n')));
    });
    await _pumpUntil(tester, () => (displayed.value?.historyRows ?? 0) > 10);

    final bounds = tester.getRect(view);
    final position = bounds.topLeft + const Offset(1, 5);
    await tester.sendEventToBinding(PointerScrollEvent(
      position: position,
      scrollDelta: const Offset(0, -10000),
    ));
    await _pumpUntil(tester, () => displayed.value?.firstRow == 0);
    expect(displayed.value!.lines.first.text, 'row00');
    expect(displayed.value!.cursorVisible, isFalse);

    await tester.dragFrom(position, const Offset(33, 0));
    await _pumpUntil(tester, () => displayed.value?.selectionId != null);
    await tester.sendEventToBinding(PointerScrollEvent(
      position: position,
      scrollDelta: const Offset(0, 90),
    ));
    await _pumpUntil(tester, () => (displayed.value?.firstRow ?? 0) >= 3);
    final lastRow = displayed.value!.firstRow;
    expect(displayed.value!.selectionAnchorRow, 0);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tapAt(position + const Offset(75, 0));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    // Let later frame projections exceed the worker hit-cache capacity. The
    // historical endpoint pinned by Shift-click must still resolve.
    for (var index = 0; index < 6; index++) {
      final previousView = displayed.value!.viewId;
      await tester.runAsync(() async {
        transport.received.add(utf8.encode('\r\nlater$index'));
      });
      await _pumpUntil(tester, () => displayed.value!.viewId > previousView);
      expect(displayed.value!.firstRow, lastRow);
    }

    String? clipboard;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() =>
        messenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await _pumpUntil(tester, () => clipboard != null);
    expect(
        clipboard,
        List.generate(lastRow + 1, (n) => 'row${n.toString().padLeft(2, '0')}')
            .join('\n'));
    expect(transport.writes, isEmpty);
    await tester.runAsync(plugin.closeForAppExit);
    manager.remove(plugin);
  }, variant: const TargetPlatformVariant({TargetPlatform.macOS}));

  testWidgets('copy completing after view detach leaves clipboard untouched',
      (tester) async {
    final snapshot = ValueNotifier<TerminalIsolateSnapshot?>(
      TerminalIsolateSnapshot(
        columns: 10,
        rows: 1,
        cursorColumn: 0,
        cursorRow: 0,
        cursorVisible: false,
        alternateScreen: false,
        lines: [TerminalIsolateLine(1, 'example', Uint32List(40), false)],
        viewId: 1,
        revision: 1,
        firstRow: 0,
        historyRows: 0,
        selectionId: null,
        selectionAnchorRow: null,
      ),
    );
    final copy = Completer<String?>();
    var applied = false;
    var requested = false;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') applied = true;
      return null;
    });
    addTearDown(() =>
        messenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(WidgetsApp(
      color: const Color(0xff000000),
      builder: (_, __) => TerminalIsolateView(
        snapshot: snapshot,
        onKey: (_, {required ctrl, required alt, required shift}) => false,
        onText: (_) {},
        onResize: (_, __) {},
        onBeginSelection: (_) async => 1,
        onCopySelection: (_, __) {
          requested = true;
          return copy.future;
        },
        textStyle: const TerminalStyle(),
        cursorType: TerminalCursorType.block,
      ),
    ));
    await tester.pump();
    final view = find.byType(TerminalIsolateView);
    await tester.dragFrom(
        tester.getTopLeft(view) + const Offset(1, 5), const Offset(32, 0));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    expect(requested, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    copy.complete('stale');
    await tester.pump();
    expect(applied, isFalse);
    snapshot.dispose();
  }, variant: const TargetPlatformVariant({TargetPlatform.macOS}));
}
