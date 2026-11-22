import 'package:test/test.dart';
import 'package:xterm/src/core/input/keys.dart';
import 'package:xterm/src/core/platform.dart';
import 'package:xterm/src/terminal.dart';

void main() {
  for (final platform in [
    TerminalTargetPlatform.macos,
    TerminalTargetPlatform.linux,
    TerminalTargetPlatform.windows,
  ]) {
    for (final alternateScreen in [false, true]) {
      for (final cursorMode in [false, true]) {
        test(
          'Shift horizontal arrows with $platform alternate=$alternateScreen cursor=$cursorMode',
          () {
            final output = <String>[];
            final terminal = Terminal(platform: platform, onOutput: output.add);
            addTearDown(terminal.dispose);
            if (alternateScreen) terminal.write('\x1b[?1049h');
            if (cursorMode) terminal.write('\x1b[?1h');

            expect(
              terminal.keyInput(TerminalKey.arrowLeft, shift: true),
              isTrue,
            );
            expect(
              terminal.keyInput(TerminalKey.arrowRight, shift: true),
              isTrue,
            );
            expect(output, ['\x1b[1;2D', '\x1b[1;2C']);
          },
        );
      }
    }
  }

  for (final modifiers in [
    (alt: true, ctrl: false, code: 4),
    (alt: false, ctrl: true, code: 6),
    (alt: true, ctrl: true, code: 8),
  ]) {
    test('Shift horizontal arrows retain modifier ${modifiers.code}', () {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      addTearDown(terminal.dispose);

      for (final key in [TerminalKey.arrowLeft, TerminalKey.arrowRight]) {
        expect(
          terminal.keyInput(
            key,
            shift: true,
            alt: modifiers.alt,
            ctrl: modifiers.ctrl,
          ),
          isTrue,
        );
      }

      expect(output, [
        '\x1b[1;${modifiers.code}D',
        '\x1b[1;${modifiers.code}C',
      ]);
    });
  }
}
