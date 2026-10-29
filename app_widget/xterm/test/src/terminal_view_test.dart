import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xterm/src/ui/render.dart';
import 'package:xterm/xterm.dart';

import '../_fixture/_fixture.dart';

@GenerateNiceMocks([MockSpec<TerminalInputHandler>()])
import 'terminal_view_test.mocks.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'htop golden test',
    (tester) async {
      final terminal = Terminal();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TerminalView(terminal),
        ),
      ));

      terminal.write(TestFixtures.htop_80x25_3s());
      await tester.pump();

      await expectLater(
        find.byType(TerminalView),
        matchesGoldenFile('_goldens/htop_80x25_3s.png'),
      );
    },
    skip: !Platform.isMacOS,
  );

  testWidgets(
    'color golden test',
    (tester) async {
      final terminal = Terminal();

      // terminal.lineFeedMode = true;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TerminalView(
            terminal,
            textStyle: TerminalStyle(fontSize: 8),
          ),
        ),
      ));

      terminal.write(TestFixtures.colors().replaceAll('\n', '\r\n'));
      await tester.pump();

      await expectLater(
        find.byType(TerminalView),
        matchesGoldenFile('_goldens/colors.png'),
      );
    },
    skip: !Platform.isMacOS,
  );

  group('TerminalView.readOnly', () {
    testWidgets('works', (tester) async {
      final terminalOutput = <String>[];
      final terminal = Terminal(onOutput: terminalOutput.add);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TerminalView(terminal, readOnly: true, autofocus: true),
        ),
      ));

      // https://github.com/flutter/flutter/issues/11181#issuecomment-314936646
      await tester.tap(find.byType(TerminalView));
      await tester.pump(Duration(seconds: 1));

      binding.testTextInput.enterText('ls -al');
      await binding.idle();

      expect(terminalOutput.join(), isEmpty);
    });

    testWidgets('does not block input when false', (tester) async {
      final terminalOutput = <String>[];
      final terminal = Terminal(onOutput: terminalOutput.add);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TerminalView(terminal, readOnly: false, autofocus: true),
        ),
      ));

      // https://github.com/flutter/flutter/issues/11181#issuecomment-314936646
      await tester.tap(find.byType(TerminalView));
      await tester.pump(Duration(seconds: 1));

      binding.testTextInput.enterText('ls -al');
      await binding.idle();

      expect(terminalOutput.join(), 'ls -al');
    });
  });

  group('TerminalView.focusNode', () {
    testWidgets('is not listened when terminal is disposed', (tester) async {
      final terminal = Terminal();

      final focusNode = FocusNode();

      final isActive = ValueNotifier(true);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: isActive,
            builder: (context, isActive, child) {
              if (!isActive) {
                return Container();
              }
              return TerminalView(
                terminal,
                focusNode: focusNode,
                autofocus: true,
              );
            },
          ),
        ),
      ));

      // ignore: invalid_use_of_protected_member
      expect(focusNode.hasListeners, isTrue);

      isActive.value = false;
      await tester.pumpAndSettle();

      // ignore: invalid_use_of_protected_member
      expect(focusNode.hasListeners, isFalse);
    });

    testWidgets('does not dispose external focus node', (tester) async {
      final terminal = Terminal();

      final focusNode = FocusNode();

      final isActive = ValueNotifier(true);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: isActive,
            builder: (context, isActive, child) {
              if (!isActive) {
                return Container();
              }
              return TerminalView(
                terminal,
                focusNode: focusNode,
                autofocus: true,
              );
            },
          ),
        ),
      ));

      isActive.value = false;
      await tester.pumpAndSettle();

      expect(() => focusNode.addListener(() {}), returnsNormally);
    });
  });

  group('TerminalController.pointerInputs', () {
    testWidgets('works', (tester) async {
      final output = <String>[];

      final terminal = Terminal(onOutput: output.add);

      // enable mouse reporting
      terminal.write('\x1b[?1000h');

      final terminalView = TerminalController(
        pointerInputs: PointerInputs.all(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminal,
              controller: terminalView,
            ),
          ),
        ),
      );

      final pointer = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(pointer.down(Offset(1, 1)));

      await tester.pumpAndSettle();

      expect(output, isNotEmpty);
    });

    testWidgets('does not respond when disabled', (tester) async {
      final output = <String>[];

      final terminal = Terminal(onOutput: output.add);

      // enable mouse reporting
      terminal.write('\x1b[?1000h');

      final terminalView = TerminalController(
        pointerInputs: PointerInputs.none(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminal,
              controller: terminalView,
            ),
          ),
        ),
      );

      final pointer = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(pointer.down(Offset(1, 1)));

      await tester.pumpAndSettle();

      expect(output, isEmpty);
    });
  });

  group('TerminalView.selection', () {
    testWidgets('double click selects the word under the pointer',
        (tester) async {
      final terminal = Terminal();
      final controller = TerminalController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminal,
              controller: controller,
            ),
          ),
        ),
      );

      terminal.write('hello world');
      await tester.pump();

      final terminalViewState =
          tester.state<TerminalViewState>(find.byType(TerminalView));
      final RenderTerminal renderTerminal = terminalViewState.renderTerminal;
      final tapOffset = renderTerminal.localToGlobal(
        renderTerminal.getOffset(const CellOffset(7, 0)) +
            renderTerminal.cellSize.center(Offset.zero),
      );

      await tester.tapAt(tapOffset);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(tapOffset);
      await tester.pump(kDoubleTapTimeout);

      expect(
        controller.selection,
        BufferRangeLine(
          const CellOffset(6, 0),
          const CellOffset(11, 0),
        ),
      );
      expect(terminal.buffer.getText(controller.selection), 'world');
    });

    testWidgets('shift primary tap extends the current selection',
        (tester) async {
      final terminal = Terminal();
      final controller = TerminalController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminal,
              controller: controller,
            ),
          ),
        ),
      );

      controller.setSelection(
        terminal.buffer.createAnchor(1, 0),
        terminal.buffer.createAnchor(2, 0),
      );
      await tester.pump();

      final terminalViewState =
          tester.state<TerminalViewState>(find.byType(TerminalView));
      final RenderTerminal renderTerminal = terminalViewState.renderTerminal;
      final tapOffset = renderTerminal.localToGlobal(
        renderTerminal.getOffset(const CellOffset(4, 0)) +
            renderTerminal.cellSize.center(Offset.zero),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tapAt(tapOffset);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump(kDoubleTapTimeout);

      expect(
        controller.selection,
        BufferRangeLine(
          const CellOffset(1, 0),
          const CellOffset(5, 0),
        ),
      );
    });

    testWidgets('selection highlight clips to line content while scrolled',
        (tester) async {
      const selectionColor = Color(0xFFFF0000);
      const backgroundColor = Color(0xFF000000);
      const testTheme = TerminalTheme(
        cursor: Color(0xFFFFFFFF),
        selection: selectionColor,
        foreground: Color(0xFFFFFFFF),
        background: backgroundColor,
        black: Color(0xFF000000),
        red: Color(0xFFFF0000),
        green: Color(0xFF00FF00),
        yellow: Color(0xFFFFFF00),
        blue: Color(0xFF0000FF),
        magenta: Color(0xFFFF00FF),
        cyan: Color(0xFF00FFFF),
        white: Color(0xFFFFFFFF),
        brightBlack: Color(0xFF808080),
        brightRed: Color(0xFFFF8080),
        brightGreen: Color(0xFF80FF80),
        brightYellow: Color(0xFFFFFF80),
        brightBlue: Color(0xFF8080FF),
        brightMagenta: Color(0xFFFF80FF),
        brightCyan: Color(0xFF80FFFF),
        brightWhite: Color(0xFFFFFFFF),
        searchHitBackground: Color(0xFFFFFF00),
        searchHitBackgroundCurrent: Color(0xFF00FF00),
        searchHitForeground: Color(0xFF000000),
      );
      final repaintKey = GlobalKey();
      final terminal = Terminal();
      final controller = TerminalController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: repaintKey,
              child: SizedBox(
                width: 240,
                height: 72,
                child: TerminalView(
                  terminal,
                  controller: controller,
                  theme: testTheme,
                  textStyle: TerminalStyle(fontSize: 10),
                  alwaysShowCursor: false,
                ),
              ),
            ),
          ),
        ),
      );

      final lines = List.generate(24, (index) {
        return index == 10 ? 'm   ' : 'line $index';
      });
      terminal.write(lines.join('\r\n'));
      terminal.flush();
      await tester.pump();

      final terminalViewState =
          tester.state<TerminalViewState>(find.byType(TerminalView));
      final renderTerminal = terminalViewState.renderTerminal;
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      scrollable.position.jumpTo(renderTerminal.lineHeight * 8);

      controller.setSelection(
        terminal.buffer.createAnchor(1, 9),
        terminal.buffer.createAnchor(2, 11),
      );
      await tester.pump();

      final insideContentColor = await _sampleTerminalPixel(
        tester,
        repaintKey,
        renderTerminal,
        const CellOffset(2, 10),
      );
      final outsideContentColor = await _sampleTerminalPixel(
        tester,
        repaintKey,
        renderTerminal,
        const CellOffset(8, 10),
      );

      expect(insideContentColor, selectionColor);
      expect(outsideContentColor, backgroundColor);
    });
  });

  group('TerminalView.scroll', () {
    testWidgets('shows a high-contrast raw scrollbar', (tester) async {
      final terminal = Terminal();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(terminal),
          ),
        ),
      );

      final scrollbar = tester.widget<RawScrollbar>(
        find.bySubtype<RawScrollbar>(),
      );

      expect(scrollbar.thumbVisibility, isTrue);
      expect(scrollbar.trackVisibility, isTrue);
      expect(scrollbar.thickness, 8);
      expect(scrollbar.thumbColor, isNotNull);
      expect(scrollbar.trackColor, isNotNull);
    });

    testWidgets('uses click cursor over the scrollbar', (tester) async {
      final terminal = Terminal();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 120,
              child: TerminalView(terminal),
            ),
          ),
        ),
      );

      terminal.write(List.generate(80, (i) => 'line $i').join('\r\n'));
      terminal.flush();
      await tester.pump();

      final terminalBounds = tester.getRect(find.byType(TerminalView));
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer
            .hover(Offset(terminalBounds.right - 2, terminalBounds.bottom - 4)),
      );
      await tester.pump();

      final cursors = tester
          .widgetList<MouseRegion>(find.byType(MouseRegion))
          .map((region) => region.cursor);

      expect(cursors, contains(SystemMouseCursors.click));
    });

    testWidgets('shift page up and down scrolls the viewport', (tester) async {
      final terminalOutput = <String>[];
      final terminal = Terminal(onOutput: terminalOutput.add);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 120,
              child: TerminalView(
                terminal,
                autofocus: true,
                textStyle: TerminalStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      );

      terminal.write(List.generate(80, (i) => 'line $i').join('\r\n'));
      terminal.flush();
      await tester.pump();

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      final bottomOffset = scrollable.position.pixels;

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();

      expect(scrollable.position.pixels, lessThan(bottomOffset));
      expect(terminalOutput.join(), isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(scrollable.position.pixels, bottomOffset);
      expect(terminalOutput.join(), isEmpty);
    });

    testWidgets('mouse wheel scrolls the viewport', (tester) async {
      final terminal = Terminal();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 120,
              child: TerminalView(
                terminal,
                textStyle: TerminalStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      );

      terminal.write(List.generate(80, (i) => 'line $i').join('\r\n'));
      terminal.flush();
      await tester.pump();

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      final bottomOffset = scrollable.position.pixels;
      final center = tester.getCenter(find.byType(TerminalView));
      final pointer = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(pointer.hover(center));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -240)));
      await tester.pump();

      expect(scrollable.position.pixels, lessThan(bottomOffset));
    });
  });

  group('TerminalView.autofocus', () {
    testWidgets('works', (tester) async {
      final terminal = Terminal();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminal,
              autofocus: true,
              focusNode: focusNode,
            ),
          ),
        ),
      );

      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('works in hardwareKeyboardOnly mode', (tester) async {
      final terminal = Terminal();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminal,
              autofocus: true,
              focusNode: focusNode,
              hardwareKeyboardOnly: true,
            ),
          ),
        ),
      );

      expect(focusNode.hasFocus, isTrue);
    });
  });

  group('TerminalView.hardwareKeyboardOnly', () {
    testWidgets('works', (tester) async {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminal,
              autofocus: true,
              hardwareKeyboardOnly: true,
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);

      expect(output.join(), 'abc');
    });
  });

  group('TerminalView.textScaler', () {
    testWidgets(
      'works',
      (tester) async {
        final terminal = Terminal();

        final textScaler = ValueNotifier(TextScaler.linear(1.0));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<TextScaler>(
                valueListenable: textScaler,
                builder: (context, textScaler, child) {
                  return TerminalView(
                    terminal,
                    textScaler: textScaler,
                  );
                },
              ),
            ),
          ),
        );

        terminal.write('Hello World');
        await tester.pump();

        await expectLater(
          find.byType(TerminalView),
          matchesGoldenFile('_goldens/text_scale_factor@1x.png'),
        );

        textScaler.value = TextScaler.linear(2.0);
        await tester.pump();

        await expectLater(
          find.byType(TerminalView),
          matchesGoldenFile('_goldens/text_scale_factor@2x.png'),
        );
      },
      skip: !Platform.isMacOS,
    );

    testWidgets(
      'can obtain textScaler from parent',
      (tester) async {
        final terminal = Terminal();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
                child: TerminalView(
                  terminal,
                ),
              ),
            ),
          ),
        );

        terminal.write('Hello World');
        await tester.pump();

        await expectLater(
          find.byType(TerminalView),
          matchesGoldenFile('_goldens/text_scale_factor@2x.png'),
        );
      },
      skip: !Platform.isMacOS,
    );
  });

  group('TerminalView.inputHandler', () {
    testWidgets('works', (tester) async {
      final terminalOutput = <String>[];
      final terminal = Terminal(onOutput: terminalOutput.add);

      await tester.pumpWidget(MaterialApp(
        home: TerminalView(terminal, autofocus: true),
      ));

      await tester.tap(find.byType(TerminalView));
      await tester.pump(Duration(seconds: 1));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      await tester.pumpAndSettle();

      expect(terminalOutput.join(), '\x04');
    });

    testWidgets('can convert text input to key events', (tester) async {
      final inputHandler = MockTerminalInputHandler();
      when(inputHandler.call(any)).thenAnswer((invocation) => 'AAA');

      final terminalOutput = <String>[];
      final terminal = Terminal(
        inputHandler: inputHandler,
        onOutput: terminalOutput.add,
      );

      await tester.pumpWidget(MaterialApp(
        home: TerminalView(terminal, autofocus: true),
      ));

      await tester.tap(find.byType(TerminalView));
      await tester.pump(Duration(seconds: 1));

      binding.testTextInput.enterText('c');
      await binding.idle();

      await tester.pumpAndSettle();

      verify(inputHandler.call(any));
      expect(terminalOutput.join(), 'AAA');
    });
  });

  group('TerminalView.simulateScroll', () {
    testWidgets('works', (tester) async {
      final terminalOutput = <String>[];
      final terminal = Terminal(onOutput: terminalOutput.add);
      terminal.useAltBuffer();

      await tester.pumpWidget(MaterialApp(
        home: TerminalView(terminal, autofocus: true, simulateScroll: true),
      ));

      await tester.drag(find.byType(TerminalView), const Offset(0, -100));

      expect(terminalOutput.join(), contains('\x1B[B'));
    });

    testWidgets('does nothing when disabled', (tester) async {
      final terminalOutput = <String>[];
      final terminal = Terminal(onOutput: terminalOutput.add);
      terminal.useAltBuffer();

      await tester.pumpWidget(MaterialApp(
        home: TerminalView(terminal, autofocus: true, simulateScroll: false),
      ));

      await tester.drag(find.byType(TerminalView), const Offset(0, -100));

      expect(terminalOutput.join(), isEmpty);
    });
  });
}

Future<Color> _sampleTerminalPixel(
  WidgetTester tester,
  GlobalKey repaintKey,
  RenderTerminal renderTerminal,
  CellOffset offset,
) async {
  final boundary =
      repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final boundaryBox = boundary;
  final image = await tester.runAsync(boundary.toImage);
  final byteData = await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  final globalOffset = renderTerminal.localToGlobal(
    renderTerminal.getOffset(offset) +
        renderTerminal.cellSize.center(Offset.zero),
  );
  final localOffset = boundaryBox.globalToLocal(globalOffset);
  final x = localOffset.dx.round().clamp(0, image!.width - 1);
  final y = localOffset.dy.round().clamp(0, image.height - 1);
  final byteOffset = (y * image.width + x) * 4;
  final data = byteData!.buffer.asUint8List();
  final color = Color.fromARGB(
    data[byteOffset + 3],
    data[byteOffset],
    data[byteOffset + 1],
    data[byteOffset + 2],
  );
  image.dispose();
  return color;
}
