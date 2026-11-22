import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/xterm.dart';

const _composition = TextEditingValue(
  text: 'ni',
  selection: TextSelection.collapsed(offset: 2),
  composing: TextRange(start: 0, end: 2),
);

void main() {
  final desktopPlatforms = TargetPlatformVariant({
    TargetPlatform.macOS,
    TargetPlatform.linux,
    TargetPlatform.windows,
  });

  for (final endComposition in ['focus loss', 'input connection closure']) {
    testWidgets(
      'restores terminal keys after composition ends through $endComposition',
      variant: desktopPlatforms,
      (tester) async {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        final focusNode = FocusNode();
        addTearDown(terminal.dispose);
        addTearDown(focusNode.dispose);
        await _pumpTerminal(tester, terminal, focusNode);
        tester.testTextInput.updateEditingValue(_composition);
        await tester.pump();

        if (endComposition == 'focus loss') {
          focusNode.unfocus();
          await tester.pump();
          focusNode.requestFocus();
        } else {
          tester.testTextInput.closeConnection();
        }
        await tester.pump();
        expect(output, isEmpty);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        expect(output, ['\x1b[1;2D']);

        await tester.tap(find.byType(TerminalView));
        await tester.pump();
        tester.testTextInput.enterText('好');
        await tester.pump();
        expect(output, ['\x1b[1;2D', '好']);
      },
    );
  }

  testWidgets(
    'Ctrl+/ sends the terminal control byte without a text commit',
    variant: desktopPlatforms,
    (tester) async {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      final focusNode = FocusNode();
      addTearDown(terminal.dispose);
      addTearDown(focusNode.dispose);
      await _pumpTerminal(tester, terminal, focusNode);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash, character: '/');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      expect(output, ['\x1f']);
      tester.testTextInput.enterText('/');
      await tester.pump();
      expect(output, ['\x1f', '/']);
    },
  );

  testWidgets(
    'unhandled keys remain with the IME until text is committed',
    variant: desktopPlatforms,
    (tester) async {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      final focusNode = FocusNode();
      addTearDown(terminal.dispose);
      addTearDown(focusNode.dispose);
      await _pumpTerminal(tester, terminal, focusNode);
      tester.testTextInput.updateEditingValue(_composition);
      await tester.pump();

      for (final key in [
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.backspace,
      ]) {
        await tester.sendKeyEvent(key);
      }
      expect(output, isEmpty);

      tester.testTextInput.enterText('你');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(output, ['你', '\x1b[D']);
    },
  );
}

Future<void> _pumpTerminal(
  WidgetTester tester,
  Terminal terminal,
  FocusNode focusNode,
) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: TerminalView(
        terminal,
        focusNode: focusNode,
        autofocus: true,
      ),
    ),
  ));
  await tester.pump();
}
