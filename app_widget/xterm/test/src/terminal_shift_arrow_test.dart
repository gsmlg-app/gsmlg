import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/xterm.dart';

void main() {
  for (final alternateScreen in [false, true]) {
    testWidgets(
      'forwards Shift horizontal arrows with alternate=$alternateScreen',
      (tester) async {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        final controller = TerminalController();
        addTearDown(terminal.dispose);
        addTearDown(controller.dispose);
        if (alternateScreen) terminal.write('\x1b[?1049h');

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminal,
              controller: controller,
              autofocus: true,
            ),
          ),
        ));
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

        expect(output, ['\x1b[1;2D', '\x1b[1;2C']);
        expect(controller.selection, isNull);
        expect(terminal.isUsingAltBuffer, alternateScreen);
      },
      variant: TargetPlatformVariant({
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows,
      }),
    );
  }
}
