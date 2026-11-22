import 'package:test/test.dart';
import 'package:xterm/xterm.dart';

void main() {
  late Terminal terminal;
  late List<List<Object>> events;

  setUp(() {
    events = [];
    terminal = Terminal(onPrivateOSC: (code, args) => events.add([code, args]));
  });
  tearDown(() => terminal.dispose());

  for (final terminator in ['\x07', '\x1b\\']) {
    test('OSC 52 survives every possible two-chunk split with $terminator', () {
      final sequence = '\x1b]52;c;aGVsbG8=$terminator';
      for (var split = 1; split < sequence.length; split++) {
        events.clear();
        terminal.write(sequence.substring(0, split));
        expect(events, isEmpty);
        terminal.write(sequence.substring(split));
        expect(events, [
          [
            '52',
            ['c', 'aGVsbG8=']
          ]
        ]);
      }
      expect(terminal.buffer.getText().trim(), isEmpty);
    });
  }

  test('discards oversized and unterminated OSC without showing its contents',
      () {
    terminal.write('\x1b]52;c;');
    for (var count = 0; count < 300; count++) {
      terminal.write('A' * 1024);
    }
    terminal.write('\x1b');
    terminal.write('\\after');
    expect(events, isEmpty);
    expect(terminal.buffer.getText().trim(), 'after');
  });

  test('CAN and SUB cancel OSC without a clipboard event', () {
    terminal.write('\x1b]52;c;abc\x18A\x1b]52;c;abc\x1aB');
    expect(events, isEmpty);
    expect(terminal.buffer.getText().trim(), 'AB');
  });

  test('an ESC in a split OSC starts a fresh CSI without losing input', () {
    terminal.write('A\x1b]52;c;invalid\x1b');
    terminal.write('[');
    terminal.write('31mB');
    expect(events, isEmpty);
    expect(terminal.buffer.getText().trim(), 'AB');
  });

  test('consecutive ESC after aborted OSC starts a fresh OSC cleanly', () {
    terminal.write('A\x1b]52;c;aborted\x1b\x1b]52;c;aGVsbG8=\x07B');
    expect(events, [
      [
        '52',
        ['c', 'aGVsbG8=']
      ]
    ]);
    expect(terminal.buffer.getText().trim(), 'AB');
  });

  for (final terminator in ['\x07', '\x1b\\']) {
    test('tmux passthrough OSC 52 survives every two-chunk split ($terminator)',
        () {
      final inner =
          '\x1b]52;c;aGVsbG8=$terminator'.replaceAll('\x1b', '\x1b\x1b');
      final sequence = '\x1bPtmux;$inner\x1b\\';
      for (var split = 1; split < sequence.length; split++) {
        events.clear();
        terminal.write(sequence.substring(0, split));
        expect(events, isEmpty);
        terminal.write(sequence.substring(split));
        expect(events, [
          [
            '52',
            ['c', 'aGVsbG8=']
          ]
        ]);
      }
      expect(terminal.buffer.getText().trim(), isEmpty);
    });
  }

  test('malformed OSC cannot invoke a partially collected clipboard command',
      () {
    terminal.write('\x1b]52;c;aGVsbG8=\x1b[31mred');
    expect(events, isEmpty);
    expect(terminal.buffer.getText().trim(), 'red');
  });

  test('oversized tmux envelope is discarded through its terminator', () {
    terminal.write('\x1bPtmux;\x1b\x1b]52;c;');
    terminal.write('A' * (EscapeParser.maxControlStringLength + 1));
    terminal.write('\x1b\x1b\\\x1b\\after');
    expect(events, isEmpty);
    expect(terminal.buffer.getText().trim(), 'after');
  });

  test('tmux passthrough does not execute other commands or print their bodies',
      () {
    terminal.write('\x1bPtmux;\x1b\x1b]0;hidden\x07\x1b\\');
    terminal.write('\x1bPtmux;\x1b\x1b]52;c;aA==\x07hidden\x1b\\');
    terminal.write('\x1bPtmux;\x1b\x1b]52;c;aA==\x1b\\');
    expect(events, isEmpty);
    expect(terminal.buffer.getText().trim(), isEmpty);
  });

  test('session input reset drops incomplete OSC and preserves history', () {
    terminal.write('history\x1b]52;c;old');
    terminal.resetInput();
    terminal.write('\x1b]52;c;bmV3\x07');
    expect(events, [
      [
        '52',
        ['c', 'bmV3']
      ]
    ]);
    expect(terminal.buffer.getText().trim(), 'history');
  });
}
