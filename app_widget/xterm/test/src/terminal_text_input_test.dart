import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/xterm.dart';

void main() {
  group('TerminalView.onTextInput', () {
    testWidgets('preserves input when no callback is provided', (tester) async {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(tester, terminal);
      tester.testTextInput.enterText('echo hello');
      await tester.pump();

      expect(output, ['echo hello']);
    });

    testWidgets('consumes text without sending it a second time',
        (tester) async {
      final output = <String>[];
      final received = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        onTextInput: (text) {
          received.add(text);
          terminal.charInput(text.codeUnitAt(0), ctrl: true);
          return true;
        },
      );
      tester.testTextInput.enterText('c');
      await tester.pump();

      expect(received, ['c']);
      expect(output, ['\x03']);
    });

    testWidgets('falls back to normal input when callback returns false',
        (tester) async {
      final output = <String>[];
      final received = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        onTextInput: (text) {
          received.add(text);
          return false;
        },
      );
      tester.testTextInput.enterText('hello');
      await tester.pump();

      expect(received, ['hello']);
      expect(output, ['hello']);
    });

    for (final text in ['你好', '🙂', '  command  ', ' ']) {
      testWidgets('passes committed ${text.runes.toList()} unchanged',
          (tester) async {
        final output = <String>[];
        final received = <String>[];
        final terminal = Terminal(onOutput: output.add);

        await _pumpTerminal(
          tester,
          terminal,
          onTextInput: (text) {
            received.add(text);
            return false;
          },
        );
        tester.testTextInput.enterText(text);
        await tester.pump();

        expect(received, [text]);
        expect(output, [text]);
      });
    }

    testWidgets('waits for IME composition to be committed', (tester) async {
      final output = <String>[];
      final received = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        onTextInput: (text) {
          received.add(text);
          return false;
        },
      );
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'ni',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 0, end: 2),
        ),
      );
      await tester.pump();

      expect(received, isEmpty);
      expect(output, isEmpty);

      tester.testTextInput.enterText('你好');
      await tester.pump();

      expect(received, ['你好']);
      expect(output, ['你好']);
    });

    testWidgets('does not invoke callback for a read-only terminal',
        (tester) async {
      final output = <String>[];
      final received = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        readOnly: true,
        onTextInput: (text) {
          received.add(text);
          return true;
        },
      );
      expect(tester.testTextInput.hasAnyClients, isFalse);
      tester.testTextInput.enterText('ignored');
      await tester.pump();

      expect(received, isEmpty);
      expect(output, isEmpty);
    });

    testWidgets('scrolls to the bottom when callback consumes text',
        (tester) async {
      final terminal = Terminal();

      await _pumpTerminal(tester, terminal, onTextInput: (_) => true);
      terminal.write(List.generate(80, (i) => 'line $i').join('\r\n'));
      terminal.flush();
      await tester.pump();

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
      scrollable.position.jumpTo(0);
      await tester.pump();

      tester.testTextInput.enterText('c');
      await tester.pump();

      expect(scrollable.position.pixels, scrollable.position.maxScrollExtent);
    });
  });

  group('TerminalView.onKeyInput', () {
    testWidgets('iOS newline action and insertion send one enter per press',
        (tester) async {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(tester, terminal);
      for (var press = 0; press < 2; press++) {
        await tester.testTextInput.receiveAction(TextInputAction.newline);
        tester.testTextInput.enterText('\n');
        await tester.pump();
      }
      tester.testTextInput.enterText('first\nsecond');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(output, ['\r', '\r', 'first\nsecond', '\r']);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets(
        'consumes a soft keyboard enter action without duplicate output',
        (tester) async {
      final output = <String>[];
      final received = <TerminalKey>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        onKeyInput: (key) {
          received.add(key);
          terminal.keyInput(key);
          return true;
        },
      );
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pump();

      expect(received, [TerminalKey.enter]);
      expect(output, ['\r']);
    });

    testWidgets('consumes a backspace key event without duplicate output',
        (tester) async {
      final output = <String>[];
      final received = <TerminalKey>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        onKeyInput: (key) {
          received.add(key);
          terminal.keyInput(key);
          return true;
        },
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      expect(received, [TerminalKey.backspace]);
      expect(output, ['\x7f']);
    });

    testWidgets('consumes soft keyboard deletion without duplicate output',
        (tester) async {
      final output = <String>[];
      final received = <TerminalKey>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        deleteDetection: true,
        onKeyInput: (key) {
          received.add(key);
          terminal.keyInput(key);
          return true;
        },
      );
      tester.testTextInput.enterText(' ');
      await tester.pump();

      expect(received, [TerminalKey.backspace]);
      expect(output, ['\x7f']);
    });

    testWidgets('preserves enter and backspace when no hook is provided',
        (tester) async {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(tester, terminal);
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      expect(output, ['\r', '\x7f']);
    });

    testWidgets('falls back when the key hook returns false', (tester) async {
      final output = <String>[];
      final received = <TerminalKey>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        onKeyInput: (key) {
          received.add(key);
          return false;
        },
      );
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      expect(received, [TerminalKey.enter, TerminalKey.backspace]);
      expect(output, ['\r', '\x7f']);
    });

    testWidgets('preserves hardware ctrl, alt and shift modifiers on fallback',
        (tester) async {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(tester, terminal, onKeyInput: (_) => false);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      expect(output, ['\x03', '\x1b[1;5C', '\x1b[Z']);
    });

    testWidgets('allows the text hook to consume input before the key hook',
        (tester) async {
      final received = <TerminalKey>[];
      final terminal = Terminal();

      await _pumpTerminal(
        tester,
        terminal,
        onTextInput: (_) => true,
        onKeyInput: (key) {
          received.add(key);
          return true;
        },
      );
      tester.testTextInput.enterText('c');
      await tester.pump();

      expect(received, isEmpty);
    });

    testWidgets('routes unconsumed committed character keys through the hook',
        (tester) async {
      final output = <String>[];
      final received = <TerminalKey>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        onTextInput: (_) => false,
        onKeyInput: (key) {
          received.add(key);
          terminal.keyInput(key, ctrl: true);
          return true;
        },
      );
      tester.testTextInput.enterText('c');
      await tester.pump();

      expect(received, [TerminalKey.keyC]);
      expect(output, ['\x03']);
    });

    testWidgets('preserves the higher priority onKeyEvent callback',
        (tester) async {
      final received = <TerminalKey>[];
      final terminal = Terminal();

      await _pumpTerminal(
        tester,
        terminal,
        onKeyEvent: (_, __) => KeyEventResult.handled,
        onKeyInput: (key) {
          received.add(key);
          return true;
        },
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      expect(received, isEmpty);
    });

    testWidgets('does not invoke the key hook for a read-only terminal',
        (tester) async {
      final output = <String>[];
      final received = <TerminalKey>[];
      final terminal = Terminal(onOutput: output.add);

      await _pumpTerminal(
        tester,
        terminal,
        readOnly: true,
        onKeyInput: (key) {
          received.add(key);
          return true;
        },
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      expect(received, isEmpty);
      expect(output, isEmpty);
    });
  });
}

Future<void> _pumpTerminal(
  WidgetTester tester,
  Terminal terminal, {
  bool Function(String text)? onTextInput,
  bool Function(TerminalKey key)? onKeyInput,
  FocusOnKeyEventCallback? onKeyEvent,
  bool readOnly = false,
  bool deleteDetection = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 120,
          child: TerminalView(
            terminal,
            autofocus: true,
            readOnly: readOnly,
            deleteDetection: deleteDetection,
            onTextInput: onTextInput,
            onKeyInput: onKeyInput,
            onKeyEvent: onKeyEvent,
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byType(TerminalView));
  await tester.pump(const Duration(milliseconds: 300));
}
