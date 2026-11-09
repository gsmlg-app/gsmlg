import 'package:test/test.dart';
import 'package:xterm/xterm.dart';

void main() {
  group('Terminal.paste()', () {
    test('converts LF and CRLF line endings to CR', () {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);

      terminal.paste('a\nb\r\nc');

      expect(output, <String>['a\rb\rc']);
    });

    test('strips bracketed paste markers from pasted content', () {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      terminal.write('\x1b[?2004h');

      terminal.paste('x\x1b[201~rm -rf ~\n\x1b[20\x1b[201~0~');

      expect(output, <String>['\x1b[200~xrm -rf ~\r\x1b[201~']);
    });
  });

  group('Buffer.getText() for copy', () {
    test('keeps blank cells between text as spaces', () {
      final terminal = Terminal();
      terminal.write('a\x1b[5Cb');

      expect(terminal.buffer.lines[0].getText(), 'a     b');
    });

    test('trims trailing whitespace at hard line breaks only', () {
      final terminal = Terminal();
      terminal.resize(10, 5);
      terminal.write('ab   \r\nhello world wrap\r\n');

      final text = terminal.buffer.getText(
        BufferRangeLine(CellOffset(0, 0), CellOffset(10, 2)),
      );

      expect(text, 'ab\nhello world wrap');
    });

    test('copies wide characters once', () {
      final terminal = Terminal();
      terminal.write('你好 x');

      expect(terminal.buffer.lines[0].getText(), '你好 x');
    });
  });

  group('mouse motion reporting', () {
    test('reports drag motion in button-event mode with SGR encoding', () {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      terminal.write('\x1b[?1002h\x1b[?1006h');

      terminal.mouseInput(
        TerminalMouseButton.left,
        TerminalMouseButtonState.motion,
        CellOffset(4, 2),
      );

      expect(output, <String>['\x1b[<32;5;3M']);
    });

    test('does not report motion in normal tracking mode', () {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      terminal.write('\x1b[?1000h');

      final handled = terminal.mouseInput(
        TerminalMouseButton.left,
        TerminalMouseButtonState.motion,
        CellOffset(4, 2),
      );

      expect(handled, isFalse);
      expect(output, isEmpty);
    });
  });
}
