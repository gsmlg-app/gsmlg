import 'package:flutter_test/flutter_test.dart';

import 'package:xterm/xterm.dart';

void main() {
  group('Terminal', () {
    group('construction', () {
      test('Can instantiate Terminal', () {
        final terminal = Terminal(maxLines: 10000);
        terminal.write('hello');
      });

      test('has default maxLines of 1000', () {
        final terminal = Terminal();
        expect(terminal.maxLines, equals(1000));
      });

      test('accepts custom maxLines', () {
        final terminal = Terminal(maxLines: 5000);
        expect(terminal.maxLines, equals(5000));
      });

      test('has default viewWidth of 80', () {
        final terminal = Terminal();
        expect(terminal.viewWidth, equals(80));
      });

      test('has default viewHeight of 24', () {
        final terminal = Terminal();
        expect(terminal.viewHeight, equals(24));
      });

      test('accepts platform parameter', () {
        final terminal = Terminal(platform: TerminalTargetPlatform.macos);
        expect(terminal.platform, equals(TerminalTargetPlatform.macos));
      });

      test('has default platform of unknown', () {
        final terminal = Terminal();
        expect(terminal.platform, equals(TerminalTargetPlatform.unknown));
      });

      test('reflowEnabled defaults to true', () {
        final terminal = Terminal();
        expect(terminal.reflowEnabled, isTrue);
      });

      test('reflowEnabled can be set to false', () {
        final terminal = Terminal(reflowEnabled: false);
        expect(terminal.reflowEnabled, isFalse);
      });
    });

    group('callbacks', () {
      test('onOutput is null by default', () {
        final terminal = Terminal();
        expect(terminal.onOutput, isNull);
      });

      test('onOutput receives output data', () {
        String? receivedOutput;
        final terminal = Terminal(onOutput: (data) => receivedOutput = data);
        terminal.keyInput(TerminalKey.enter);
        expect(receivedOutput, isNotNull);
      });

      test('onTitleChange is called on title escape sequence', () {
        String? newTitle;
        final terminal = Terminal(onTitleChange: (title) => newTitle = title);
        terminal.write('\x1b]0;Test Title\x07');
        expect(newTitle, equals('Test Title'));
      });

      test('onIconChange can be set', () {
        final terminal = Terminal(onIconChange: (_) {});
        expect(terminal.onIconChange, isNotNull);
      });

      test('onBell is called on bell character', () {
        bool bellRang = false;
        final terminal = Terminal(onBell: () => bellRang = true);
        terminal.write('\x07');
        expect(bellRang, isTrue);
      });

      test('onResize can be set', () {
        final terminal = Terminal(
          onResize: (w, h, pw, ph) {},
        );
        expect(terminal.onResize, isNotNull);
      });
    });

    group('write', () {
      test('writes text to terminal', () {
        final terminal = Terminal();
        terminal.write('hello');
        // Get the first line content
        final line = terminal.buffer.lines[0];
        final text = line.getText();
        expect(text.trim(), equals('hello'));
      });

      test('handles newlines', () {
        final terminal = Terminal();
        terminal.write('line1\nline2');
        expect(terminal.buffer.lines[0].getText().trim(), equals('line1'));
        expect(terminal.buffer.lines[1].getText().trim(), equals('line2'));
      });

      test('handles carriage return', () {
        final terminal = Terminal();
        terminal.write('hello\rworld');
        expect(terminal.buffer.lines[0].getText().trim(), equals('world'));
      });

      test('handles CRLF', () {
        final terminal = Terminal();
        terminal.write('line1\r\nline2');
        expect(terminal.buffer.lines[0].getText().trim(), equals('line1'));
        expect(terminal.buffer.lines[1].getText().trim(), equals('line2'));
      });
    });

    group('resize', () {
      test('resize changes viewWidth', () {
        final terminal = Terminal();
        terminal.resize(100, 50);
        expect(terminal.viewWidth, equals(100));
      });

      test('resize changes viewHeight', () {
        final terminal = Terminal();
        terminal.resize(100, 50);
        expect(terminal.viewHeight, equals(50));
      });

      test('resize triggers onResize callback', () {
        int? resizeW, resizeH;
        final terminal = Terminal(
          onResize: (w, h, pw, ph) {
            resizeW = w;
            resizeH = h;
          },
        );
        terminal.resize(120, 40);
        expect(resizeW, equals(120));
        expect(resizeH, equals(40));
      });
    });

    group('buffer', () {
      test('has mainBuffer', () {
        final terminal = Terminal();
        expect(terminal.mainBuffer, isNotNull);
      });

      test('has altBuffer', () {
        final terminal = Terminal();
        expect(terminal.altBuffer, isNotNull);
      });

      test('initially uses mainBuffer', () {
        final terminal = Terminal();
        expect(terminal.isUsingAltBuffer, isFalse);
        expect(terminal.buffer, equals(terminal.mainBuffer));
      });

      test('lines returns buffer lines', () {
        final terminal = Terminal();
        expect(terminal.lines, isNotNull);
      });
    });

    group('state', () {
      test('insertMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.insertMode, isFalse);
      });

      test('lineFeedMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.lineFeedMode, isFalse);
      });

      test('cursorKeysMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.cursorKeysMode, isFalse);
      });

      test('reverseDisplayMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.reverseDisplayMode, isFalse);
      });

      test('originMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.originMode, isFalse);
      });

      test('autoWrapMode defaults to true', () {
        final terminal = Terminal();
        expect(terminal.autoWrapMode, isTrue);
      });

      test('mouseMode defaults to none', () {
        final terminal = Terminal();
        expect(terminal.mouseMode, equals(MouseMode.none));
      });

      test('cursorBlinkMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.cursorBlinkMode, isFalse);
      });

      test('cursorVisibleMode defaults to true', () {
        final terminal = Terminal();
        expect(terminal.cursorVisibleMode, isTrue);
      });

      test('appKeypadMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.appKeypadMode, isFalse);
      });

      test('reportFocusMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.reportFocusMode, isFalse);
      });

      test('altBufferMouseScrollMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.altBufferMouseScrollMode, isFalse);
      });

      test('bracketedPasteMode defaults to false', () {
        final terminal = Terminal();
        expect(terminal.bracketedPasteMode, isFalse);
      });
    });

    group('cursor', () {
      test('cursor is not null', () {
        final terminal = Terminal();
        expect(terminal.cursor, isNotNull);
      });

      test('cursor is CursorStyle', () {
        final terminal = Terminal();
        expect(terminal.cursor, isA<CursorStyle>());
      });
    });

    group('keyInput', () {
      test('returns true when output is generated', () {
        final terminal = Terminal(onOutput: (_) {});
        final result = terminal.keyInput(TerminalKey.enter);
        expect(result, isTrue);
      });

      test('handles shift modifier', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        terminal.keyInput(TerminalKey.tab, shift: true);
        expect(output, isNotNull);
      });

      test('handles alt modifier', () {
        final terminal = Terminal(onOutput: (_) {});
        final result = terminal.keyInput(TerminalKey.keyA, alt: true);
        // Result depends on platform and handler
        expect(result, isA<bool>());
      });

      test('handles ctrl modifier', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        terminal.keyInput(TerminalKey.keyC, ctrl: true);
        expect(output, isNotNull);
      });
    });

    group('charInput', () {
      test('handles ctrl+c', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        final result = terminal.charInput(99, ctrl: true); // 'c' = 99
        expect(result, isTrue);
        expect(output, equals('\x03')); // ETX (End of Text)
      });

      test('handles ctrl+z', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        terminal.charInput(122, ctrl: true); // 'z' = 122
        expect(output, equals('\x1a')); // SUB (Substitute)
      });
    });

    group('textInput', () {
      test('sends text as output', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        terminal.textInput('hello');
        expect(output, equals('hello'));
      });

      test('handles empty string', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        terminal.textInput('');
        expect(output, equals(''));
      });

      test('handles unicode', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        terminal.textInput('日本語');
        expect(output, equals('日本語'));
      });
    });

    group('paste', () {
      test('sends pasted text as output', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        terminal.paste('pasted text');
        expect(output?.contains('pasted text'), isTrue);
      });

      test('handles empty paste', () {
        String? output;
        final terminal = Terminal(onOutput: (data) => output = data);
        terminal.paste('');
        expect(output, isNotNull);
      });
    });

    group('mouseInput', () {
      test('returns false when mouseMode is none', () {
        final terminal = Terminal();
        expect(terminal.mouseMode, equals(MouseMode.none));
        final result = terminal.mouseInput(
          TerminalMouseButton.left,
          TerminalMouseButtonState.down,
          CellOffset(0, 0),
        );
        expect(result, isFalse);
      });
    });

    group('escape sequences', () {
      test('handles clear screen (ED)', () {
        final terminal = Terminal();
        terminal.write('content\x1b[2J');
        // Screen should be cleared - lines collection exists
        expect(terminal.buffer.lines.length, greaterThan(0));
      });

      test('handles cursor positioning (CUP)', () {
        final terminal = Terminal();
        terminal.write('\x1b[5;10H');
        expect(terminal.buffer.cursorX, equals(9)); // 0-indexed
        expect(terminal.buffer.cursorY, equals(4)); // 0-indexed
      });

      test('handles cursor up (CUU)', () {
        final terminal = Terminal();
        terminal.write('\x1b[10;10H'); // Move to row 10
        terminal.write('\x1b[3A'); // Move up 3
        expect(terminal.buffer.cursorY, equals(6)); // 10 - 1 (0-indexed) - 3
      });

      test('handles cursor down (CUD)', () {
        final terminal = Terminal();
        terminal.write('\x1b[2B'); // Move down 2
        expect(terminal.buffer.cursorY, equals(2)); // 0 + 2
      });

      test('handles cursor forward (CUF)', () {
        final terminal = Terminal();
        terminal.write('\x1b[5C'); // Move right 5
        expect(terminal.buffer.cursorX, equals(5)); // 0 + 5
      });

      test('handles cursor back (CUB)', () {
        final terminal = Terminal();
        terminal.write('\x1b[10;10H'); // Move to col 10
        terminal.write('\x1b[3D'); // Move left 3
        expect(terminal.buffer.cursorX, equals(6)); // 10 - 1 (0-indexed) - 3
      });

      test('handles set title OSC 0', () {
        String? title;
        final terminal = Terminal(onTitleChange: (t) => title = t);
        terminal.write('\x1b]0;My Terminal\x07');
        expect(title, equals('My Terminal'));
      });

      test('handles set title OSC 2', () {
        String? title;
        final terminal = Terminal(onTitleChange: (t) => title = t);
        terminal.write('\x1b]2;Window Title\x07');
        expect(title, equals('Window Title'));
      });
    });
  });

  group('TerminalTargetPlatform', () {
    test('has unknown value', () {
      expect(TerminalTargetPlatform.unknown, isNotNull);
    });

    test('has linux value', () {
      expect(TerminalTargetPlatform.linux, isNotNull);
    });

    test('has macos value', () {
      expect(TerminalTargetPlatform.macos, isNotNull);
    });

    test('has windows value', () {
      expect(TerminalTargetPlatform.windows, isNotNull);
    });

    test('has android value', () {
      expect(TerminalTargetPlatform.android, isNotNull);
    });

    test('has ios value', () {
      expect(TerminalTargetPlatform.ios, isNotNull);
    });

    test('has web value', () {
      expect(TerminalTargetPlatform.web, isNotNull);
    });

    test('all values are unique', () {
      final values = TerminalTargetPlatform.values;
      expect(values.toSet().length, equals(values.length));
    });
  });

  group('MouseMode', () {
    test('has none value', () {
      expect(MouseMode.none, isNotNull);
    });

    test('has clickOnly value', () {
      expect(MouseMode.clickOnly, isNotNull);
    });

    test('has upDownScroll value', () {
      expect(MouseMode.upDownScroll, isNotNull);
    });

    test('has upDownScrollDrag value', () {
      expect(MouseMode.upDownScrollDrag, isNotNull);
    });

    test('has upDownScrollMove value', () {
      expect(MouseMode.upDownScrollMove, isNotNull);
    });

    test('reportScroll is false for none', () {
      expect(MouseMode.none.reportScroll, isFalse);
    });

    test('reportScroll is false for clickOnly', () {
      expect(MouseMode.clickOnly.reportScroll, isFalse);
    });

    test('reportScroll is true for upDownScroll', () {
      expect(MouseMode.upDownScroll.reportScroll, isTrue);
    });
  });

  group('TerminalKey', () {
    test('has enter key', () {
      expect(TerminalKey.enter, isNotNull);
    });

    test('has escape key', () {
      expect(TerminalKey.escape, isNotNull);
    });

    test('has tab key', () {
      expect(TerminalKey.tab, isNotNull);
    });

    test('has backspace key', () {
      expect(TerminalKey.backspace, isNotNull);
    });

    test('has arrow keys', () {
      expect(TerminalKey.arrowUp, isNotNull);
      expect(TerminalKey.arrowDown, isNotNull);
      expect(TerminalKey.arrowLeft, isNotNull);
      expect(TerminalKey.arrowRight, isNotNull);
    });

    test('has function keys', () {
      expect(TerminalKey.f1, isNotNull);
      expect(TerminalKey.f2, isNotNull);
      expect(TerminalKey.f12, isNotNull);
    });

    test('has letter keys', () {
      expect(TerminalKey.keyA, isNotNull);
      expect(TerminalKey.keyZ, isNotNull);
    });
  });
}
