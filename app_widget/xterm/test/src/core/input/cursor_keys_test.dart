import 'package:test/test.dart';
import 'package:xterm/xterm.dart';

void main() {
  const arrowKeys = <TerminalKey, String>{
    TerminalKey.arrowUp: 'A',
    TerminalKey.arrowDown: 'B',
    TerminalKey.arrowRight: 'C',
    TerminalKey.arrowLeft: 'D',
  };

  group('cursor key mode', () {
    for (final cursorMode in [false, true]) {
      for (final keypadMode in [false, true]) {
        for (final entry in arrowKeys.entries) {
          test(
            '${entry.key} uses cursor=$cursorMode independently of keypad=$keypadMode',
            () {
              final output = <String>[];
              final terminal = Terminal(onOutput: output.add);
              addTearDown(terminal.dispose);

              terminal.setAppKeypadMode(keypadMode);
              terminal.write(cursorMode ? '\x1b[?1h' : '\x1b[?1l');

              expect(terminal.cursorKeysMode, cursorMode);
              expect(terminal.appKeypadMode, keypadMode);
              expect(terminal.keyInput(entry.key), isTrue);
              expect(output, ['\x1b${cursorMode ? 'O' : '['}${entry.value}']);
            },
          );
        }
      }

      test('preserves modified arrow encoding with cursor=$cursorMode', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        addTearDown(terminal.dispose);
        terminal.write(cursorMode ? '\x1b[?1h' : '\x1b[?1l');

        for (final key in arrowKeys.keys) {
          expect(terminal.keyInput(key, ctrl: true), isTrue);
        }

        expect(
          output,
          arrowKeys.values.map((suffix) => '\x1b[1;5$suffix').toList(),
        );
      });

      for (final modifiers in [
        (alt: true, ctrl: false, code: 3),
        (alt: false, ctrl: true, code: 5),
        (alt: true, ctrl: true, code: 7),
      ]) {
        test(
          'encodes Alt=${modifiers.alt} Ctrl=${modifiers.ctrl} vertical arrows with cursor=$cursorMode',
          () {
            final output = <String>[];
            final terminal = Terminal(
              onOutput: output.add,
              platform: TerminalTargetPlatform.macos,
            );
            addTearDown(terminal.dispose);
            terminal.write(cursorMode ? '\x1b[?1h' : '\x1b[?1l');

            for (final key in arrowKeys.keys.take(2)) {
              expect(
                terminal.keyInput(
                  key,
                  alt: modifiers.alt,
                  ctrl: modifiers.ctrl,
                ),
                isTrue,
              );
            }

            expect(
              output,
              arrowKeys.values
                  .take(2)
                  .map((suffix) => '\x1b[1;${modifiers.code}$suffix')
                  .toList(),
            );
          },
        );
      }
    }

    test('returns to normal cursor encoding after application mode is reset',
        () {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      addTearDown(terminal.dispose);

      terminal.write('\x1b[?1h');
      terminal.keyInput(TerminalKey.arrowUp);
      terminal.write('\x1b[?1l');
      terminal.keyInput(TerminalKey.arrowUp);

      expect(output, ['\x1bOA', '\x1b[A']);
    });
  });
}
