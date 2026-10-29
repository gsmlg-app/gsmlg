import 'package:test/test.dart';
import 'package:xterm/src/core/input/keytab/keytab.dart';
import 'package:xterm/xterm.dart';

void main() {
  group('defaultInputHandler', () {
    group('numpad keys', () {
      test('supports numpad enter', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.numpadEnter);
        expect(output, ['\r']);
      });

      // Note: numpad arithmetic keys (multiply, add, subtract, decimal, divide)
      // are not handled by the default input handler as they require special
      // application mode handling. They can be tested with custom keytab handlers.
    });

    group('basic keys', () {
      test('supports enter', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.enter);
        expect(output, ['\r']);
      });

      test('supports backspace', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.backspace);
        expect(output, ['\x7f']);
      });

      test('supports tab', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.tab);
        expect(output, ['\t']);
      });

      test('supports escape', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.escape);
        expect(output, ['\x1b']);
      });
    });

    group('arrow keys', () {
      test('supports up arrow', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.arrowUp);
        expect(output, ['\x1b[A']);
      });

      test('supports down arrow', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.arrowDown);
        expect(output, ['\x1b[B']);
      });

      test('supports right arrow', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.arrowRight);
        expect(output, ['\x1b[C']);
      });

      test('supports left arrow', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.arrowLeft);
        expect(output, ['\x1b[D']);
      });
    });

    group('navigation keys', () {
      test('supports home', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.home);
        expect(output, ['\x1b[H']);
      });

      test('supports end', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.end);
        expect(output, ['\x1b[F']);
      });

      test('supports page up', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.pageUp);
        expect(output, ['\x1b[5~']);
      });

      test('supports page down', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.pageDown);
        expect(output, ['\x1b[6~']);
      });

      test('supports insert', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.insert);
        expect(output, ['\x1b[2~']);
      });

      test('supports delete', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.delete);
        expect(output, ['\x1b[3~']);
      });
    });

    group('function keys', () {
      test('supports F1', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f1);
        expect(output, ['\x1bOP']);
      });

      test('supports F2', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f2);
        expect(output, ['\x1bOQ']);
      });

      test('supports F3', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f3);
        expect(output, ['\x1bOR']);
      });

      test('supports F4', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f4);
        expect(output, ['\x1bOS']);
      });

      test('supports F5', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f5);
        expect(output, ['\x1b[15~']);
      });

      test('supports F6', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f6);
        expect(output, ['\x1b[17~']);
      });

      test('supports F7', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f7);
        expect(output, ['\x1b[18~']);
      });

      test('supports F8', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f8);
        expect(output, ['\x1b[19~']);
      });

      test('supports F9', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f9);
        expect(output, ['\x1b[20~']);
      });

      test('supports F10', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f10);
        expect(output, ['\x1b[21~']);
      });

      test('supports F11', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f11);
        expect(output, ['\x1b[23~']);
      });

      test('supports F12', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.f12);
        expect(output, ['\x1b[24~']);
      });
    });

    group('modifier combinations', () {
      test('supports ctrl+c', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.keyC, ctrl: true);
        expect(output, ['\x03']);
      });

      test('supports ctrl+d', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.keyD, ctrl: true);
        expect(output, ['\x04']);
      });

      test('supports ctrl+z', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.keyZ, ctrl: true);
        expect(output, ['\x1a']);
      });

      test('supports ctrl+a', () {
        final output = <String>[];
        final terminal = Terminal(onOutput: output.add);
        terminal.keyInput(TerminalKey.keyA, ctrl: true);
        expect(output, ['\x01']);
      });
    });
  });

  group('KeytabInputHandler', () {
    test('can insert modifier code', () {
      final handler = KeytabInputHandler(
        Keytab.parse(r'key Home +AnyMod : "\E[1;*H"'),
      );

      final terminal = Terminal(inputHandler: handler);

      late String output;

      terminal.onOutput = (data) {
        output = data;
      };

      terminal.keyInput(TerminalKey.home, ctrl: true);

      expect(output, '\x1b[1;5H');

      terminal.keyInput(TerminalKey.home, shift: true);

      expect(output, '\x1b[1;2H');
    });

    test('can handle custom key binding', () {
      final handler = KeytabInputHandler(
        Keytab.parse(r'key End : "\E[4~"'),
      );

      final terminal = Terminal(inputHandler: handler);

      late String output;

      terminal.onOutput = (data) {
        output = data;
      };

      terminal.keyInput(TerminalKey.end);

      expect(output, '\x1b[4~');
    });

    test('modifier code 2 for shift', () {
      final handler = KeytabInputHandler(
        Keytab.parse(r'key Up +AnyMod : "\E[1;*A"'),
      );

      final terminal = Terminal(inputHandler: handler);

      late String output;

      terminal.onOutput = (data) {
        output = data;
      };

      terminal.keyInput(TerminalKey.arrowUp, shift: true);

      expect(output, '\x1b[1;2A');
    });

    test('modifier code 3 for alt', () {
      final handler = KeytabInputHandler(
        Keytab.parse(r'key Up +AnyMod : "\E[1;*A"'),
      );

      final terminal = Terminal(inputHandler: handler);

      late String output;

      terminal.onOutput = (data) {
        output = data;
      };

      terminal.keyInput(TerminalKey.arrowUp, alt: true);

      expect(output, '\x1b[1;3A');
    });

    test('modifier code 5 for ctrl', () {
      final handler = KeytabInputHandler(
        Keytab.parse(r'key Up +AnyMod : "\E[1;*A"'),
      );

      final terminal = Terminal(inputHandler: handler);

      late String output;

      terminal.onOutput = (data) {
        output = data;
      };

      terminal.keyInput(TerminalKey.arrowUp, ctrl: true);

      expect(output, '\x1b[1;5A');
    });
  });

  group('TerminalKey enum', () {
    test('has expected basic keys', () {
      expect(TerminalKey.enter, isNotNull);
      expect(TerminalKey.escape, isNotNull);
      expect(TerminalKey.backspace, isNotNull);
      expect(TerminalKey.tab, isNotNull);
    });

    test('has expected arrow keys', () {
      expect(TerminalKey.arrowUp, isNotNull);
      expect(TerminalKey.arrowDown, isNotNull);
      expect(TerminalKey.arrowLeft, isNotNull);
      expect(TerminalKey.arrowRight, isNotNull);
    });

    test('has expected function keys', () {
      expect(TerminalKey.f1, isNotNull);
      expect(TerminalKey.f2, isNotNull);
      expect(TerminalKey.f3, isNotNull);
      expect(TerminalKey.f4, isNotNull);
      expect(TerminalKey.f5, isNotNull);
      expect(TerminalKey.f6, isNotNull);
      expect(TerminalKey.f7, isNotNull);
      expect(TerminalKey.f8, isNotNull);
      expect(TerminalKey.f9, isNotNull);
      expect(TerminalKey.f10, isNotNull);
      expect(TerminalKey.f11, isNotNull);
      expect(TerminalKey.f12, isNotNull);
    });

    test('has expected numpad keys', () {
      expect(TerminalKey.numpadEnter, isNotNull);
      expect(TerminalKey.numpadMultiply, isNotNull);
      expect(TerminalKey.numpadAdd, isNotNull);
      expect(TerminalKey.numpadSubtract, isNotNull);
      expect(TerminalKey.numpadDecimal, isNotNull);
      expect(TerminalKey.numpadDivide, isNotNull);
    });
  });
}
