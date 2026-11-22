import 'package:test/test.dart';
import 'package:xterm/xterm.dart';

void main() {
  group('Codex terminal queries', () {
    test('reports the home cursor using one-based coordinates', () {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      addTearDown(terminal.dispose);

      terminal.write('\x1b[6n');

      expect(output, ['\x1b[1;1R']);
    });

    test('reports the cursor after a move using row then column', () {
      final output = <String>[];
      final terminal = Terminal(onOutput: output.add);
      addTearDown(terminal.dispose);

      terminal.write('\x1b[7;12H\x1b[6n');

      expect(output, ['\x1b[7;12R']);
    });
  });

  test('can render Codex history after reverse-index scrolling', () {
    final terminal = Terminal();
    addTearDown(terminal.dispose);
    terminal.resize(100, 32);

    terminal.write('\x1b[1;32r\x1b[1;1H${'\x1bM' * 6}\x1b[r');
    terminal.write(
      '\x1b[1;6r\x1b[1;1H'
      '\r\n\x1b[K'
      '\r\n\x1b[K  >_ OpenAI Codex'
      '\r\n\x1b[K  workspace'
      '\r\n\x1b[K'
      '\r\n\x1b[K  Tip:'
      '\r\n\x1b[K  details'
      '\x1b[r',
    );

    expect(terminal.buffer.getText(), contains('OpenAI Codex'));
    for (var row = 0; row < terminal.buffer.lines.length; row++) {
      final line = terminal.buffer.lines[row];
      expect(line.attached, isTrue, reason: 'row $row');
      expect(line.index, row);
    }
  });
}
