import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/src/ui/render.dart';
import 'package:xterm/xterm.dart';

void main() {
  late Terminal terminal;
  late TerminalController controller;
  late List<String> output;

  setUp(() {
    output = <String>[];
    terminal = Terminal(onOutput: output.add);
    controller = TerminalController();
  });

  Future<RenderTerminal> pumpTerminal(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TerminalView(terminal, controller: controller),
        ),
      ),
    );
    await tester.pump();
    return tester
        .state<TerminalViewState>(find.byType(TerminalView))
        .renderTerminal;
  }

  Offset cellCenter(RenderTerminal render, CellOffset cell) {
    return render.localToGlobal(
      render.getOffset(cell) + render.cellSize.center(Offset.zero),
    );
  }

  Future<void> mouseDrag(
    WidgetTester tester,
    Offset from,
    Offset to,
  ) async {
    final gesture = await tester.startGesture(
      from,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(Offset.lerp(from, to, 0.5)!);
    await tester.pump();
    await gesture.moveTo(to);
    await tester.pump();
    await gesture.up();
    await tester.pump(kDoubleTapTimeout);
  }

  testWidgets('triple click selects the whole logical line', (tester) async {
    final render = await pumpTerminal(tester);
    terminal.resize(10, 5);
    terminal.write('first\r\nhello world wrap\r\nlast');
    await tester.pump();

    final tap = cellCenter(render, const CellOffset(2, 1));
    await tester.tapAt(tap);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tap);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tap);
    await tester.pump(kDoubleTapTimeout);

    expect(terminal.buffer.getText(controller.selection), 'hello world wrap');
  });

  testWidgets('mouse drag selects characters when mouse reporting is off',
      (tester) async {
    final render = await pumpTerminal(tester);
    terminal.write('hello world');
    await tester.pump();

    await mouseDrag(
      tester,
      cellCenter(render, const CellOffset(0, 0)),
      cellCenter(render, const CellOffset(4, 0)),
    );

    expect(terminal.buffer.getText(controller.selection), 'hello');
    expect(output, isEmpty);
  });

  testWidgets('mouse drag is reported to programs that track drags',
      (tester) async {
    final render = await pumpTerminal(tester);
    terminal.write('\x1b[?1002h\x1b[?1006h');
    await tester.pump();

    await mouseDrag(
      tester,
      cellCenter(render, const CellOffset(1, 0)),
      cellCenter(render, const CellOffset(5, 2)),
    );

    expect(output.first, '\x1b[<0;2;1M');
    expect(output, contains('\x1b[<32;6;3M'));
    expect(output.last, '\x1b[<0;6;3m');
    expect(controller.selection, isNull);
  });

  testWidgets('Option drag selects text even when mouse reporting is on',
      (tester) async {
    final render = await pumpTerminal(tester);
    terminal.write('\x1b[?1002h\x1b[?1006hhello world');
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await mouseDrag(
      tester,
      cellCenter(render, const CellOffset(6, 0)),
      cellCenter(render, const CellOffset(10, 0)),
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);

    expect(terminal.buffer.getText(controller.selection), 'world');
    expect(output, isEmpty);
  });

  testWidgets('mouse reports use screen rows when scrollback exists',
      (tester) async {
    final render = await pumpTerminal(tester);
    terminal.resize(20, 4);
    for (var i = 0; i < 10; i++) {
      terminal.write('line $i\r\n');
    }
    terminal.write('\x1b[?1000h\x1b[?1006h');
    await tester.pump();

    final screenTop = CellOffset(0, terminal.buffer.scrollBack);
    await tester.tapAt(cellCenter(render, screenTop));
    await tester.pump(kDoubleTapTimeout);

    expect(output.first, '\x1b[<0;1;1M');
  });

  testWidgets('Select All includes scrollback', (tester) async {
    await pumpTerminal(tester);
    terminal.resize(20, 3);
    for (var i = 0; i < 6; i++) {
      terminal.write('row $i\r\n');
    }
    await tester.pump();

    await tester.tap(find.byType(TerminalView));
    await tester.pump(kDoubleTapTimeout);
    final isApple = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final modifier =
        isApple ? LogicalKeyboardKey.metaLeft : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();

    expect(
      terminal.buffer.getText(controller.selection),
      startsWith('row 0\nrow 1\n'),
    );
  });

  testWidgets('paste sends clipboard text and scrolls to the bottom',
      (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.getData') {
          return <String, dynamic>{'text': 'echo 1\necho 2'};
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final render = await pumpTerminal(tester);
    terminal.resize(20, 3);
    for (var i = 0; i < 200; i++) {
      terminal.write('row $i\r\n');
    }
    await tester.pump();
    await tester.tap(find.byType(TerminalView));
    await tester.pump(kDoubleTapTimeout);
    final bottom = render.scrollOffset;
    render.scrollBy(-render.lineHeight * 10);
    await tester.pump();
    expect(render.scrollOffset, lessThan(bottom));

    final isApple = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final modifier =
        isApple ? LogicalKeyboardKey.metaLeft : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(modifier);
    await tester.pumpAndSettle();

    expect(output, contains('echo 1\recho 2'));
    expect(render.scrollOffset, bottom);
  });
}
