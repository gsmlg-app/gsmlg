import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xterm/xterm.dart';

@GenerateNiceMocks([MockSpec<EscapeHandler>()])
import 'parser_test.mocks.dart';

void main() {
  group('EscapeParser', () {
    late EscapeParser parser;
    late MockEscapeHandler handler;

    setUp(() {
      handler = MockEscapeHandler();
      parser = EscapeParser(handler);
    });

    group('window manipulation', () {
      test('can parse window manipulation', () {
        parser.write('\x1b[8;24;80t');
        verify(handler.resize(80, 24));
      });

      test('can parse resize with different dimensions', () {
        parser.write('\x1b[8;50;120t');
        verify(handler.resize(120, 50));
      });
    });

    group('cursor positioning', () {
      test('parses cursor position (CUP)', () {
        parser.write('\x1b[5;10H');
        verify(handler.setCursor(9, 4)); // 0-indexed
      });

      test('parses cursor position with default values', () {
        parser.write('\x1b[H');
        verify(handler.setCursor(0, 0));
      });

      test('parses horizontal cursor position (CHA)', () {
        parser.write('\x1b[15G');
        verify(handler.setCursorX(14)); // 0-indexed
      });

      test('parses vertical cursor position (VPA)', () {
        parser.write('\x1b[10d');
        verify(handler.setCursorY(9)); // 0-indexed
      });
    });

    group('cursor movement', () {
      test('parses cursor up (CUU)', () {
        parser.write('\x1b[5A');
        verify(handler.moveCursorY(-5));
      });

      test('parses cursor down (CUD)', () {
        parser.write('\x1b[3B');
        verify(handler.moveCursorY(3));
      });

      test('parses cursor forward (CUF)', () {
        parser.write('\x1b[7C');
        verify(handler.moveCursorX(7));
      });

      test('parses cursor backward (CUB)', () {
        parser.write('\x1b[4D');
        verify(handler.moveCursorX(-4));
      });

      test('parses cursor next line (CNL)', () {
        parser.write('\x1b[2E');
        verify(handler.cursorNextLine(2));
      });

      test('parses cursor preceding line (CPL)', () {
        parser.write('\x1b[3F');
        verify(handler.cursorPrecedingLine(3));
      });
    });

    group('erase operations', () {
      test('parses erase display below (ED 0)', () {
        parser.write('\x1b[0J');
        verify(handler.eraseDisplayBelow());
      });

      test('parses erase display above (ED 1)', () {
        parser.write('\x1b[1J');
        verify(handler.eraseDisplayAbove());
      });

      test('parses erase entire display (ED 2)', () {
        parser.write('\x1b[2J');
        verify(handler.eraseDisplay());
      });

      test('parses erase scrollback only (ED 3)', () {
        parser.write('\x1b[3J');
        verify(handler.eraseScrollbackOnly());
      });

      test('parses erase line right (EL 0)', () {
        parser.write('\x1b[0K');
        verify(handler.eraseLineRight());
      });

      test('parses erase line left (EL 1)', () {
        parser.write('\x1b[1K');
        verify(handler.eraseLineLeft());
      });

      test('parses erase entire line (EL 2)', () {
        parser.write('\x1b[2K');
        verify(handler.eraseLine());
      });

      test('parses erase characters (ECH)', () {
        parser.write('\x1b[5X');
        verify(handler.eraseChars(5));
      });
    });

    group('line operations', () {
      test('parses insert lines (IL)', () {
        parser.write('\x1b[3L');
        verify(handler.insertLines(3));
      });

      test('parses delete lines (DL)', () {
        parser.write('\x1b[2M');
        verify(handler.deleteLines(2));
      });

      test('parses delete characters (DCH)', () {
        parser.write('\x1b[4P');
        verify(handler.deleteChars(4));
      });

      test('parses insert blank chars (ICH)', () {
        parser.write('\x1b[6@');
        verify(handler.insertBlankChars(6));
      });
    });

    group('scroll operations', () {
      test('parses scroll up (SU)', () {
        parser.write('\x1b[3S');
        verify(handler.scrollUp(3));
      });

      test('parses scroll down (SD)', () {
        parser.write('\x1b[2T');
        verify(handler.scrollDown(2));
      });
    });

    group('single byte controls', () {
      test('parses bell', () {
        parser.write('\x07');
        verify(handler.bell());
      });

      test('parses backspace', () {
        parser.write('\x08');
        verify(handler.backspaceReturn());
      });

      test('parses tab', () {
        parser.write('\x09');
        verify(handler.tab());
      });

      test('parses line feed', () {
        parser.write('\x0a');
        verify(handler.lineFeed());
      });

      test('parses carriage return', () {
        parser.write('\x0d');
        verify(handler.carriageReturn());
      });
    });

    group('cursor save/restore', () {
      test('parses save cursor (DECSC)', () {
        parser.write('\x1b7');
        verify(handler.saveCursor());
      });

      test('parses restore cursor (DECRC)', () {
        parser.write('\x1b8');
        verify(handler.restoreCursor());
      });
    });

    group('index operations', () {
      test('parses index (IND)', () {
        parser.write('\x1bD');
        verify(handler.index());
      });

      test('parses next line (NEL)', () {
        parser.write('\x1bE');
        verify(handler.nextLine());
      });

      test('parses reverse index (RI)', () {
        parser.write('\x1bM');
        verify(handler.reverseIndex());
      });
    });

    group('tab stop operations', () {
      test('parses set tab stop (HTS)', () {
        parser.write('\x1bH');
        verify(handler.setTapStop());
      });

      test('parses clear tab stop under cursor (TBC 0)', () {
        parser.write('\x1b[0g');
        verify(handler.clearTabStopUnderCursor());
      });

      test('parses clear all tab stops (TBC 3)', () {
        parser.write('\x1b[3g');
        verify(handler.clearAllTabStops());
      });
    });

    group('device attributes', () {
      test('parses primary device attributes request', () {
        parser.write('\x1b[c');
        verify(handler.sendPrimaryDeviceAttributes());
      });

      test('parses secondary device attributes request', () {
        parser.write('\x1b[>c');
        verify(handler.sendSecondaryDeviceAttributes());
      });

      test('parses operating status request (DSR 5)', () {
        parser.write('\x1b[5n');
        verify(handler.sendOperatingStatus());
      });

      test('parses cursor position request (DSR 6)', () {
        parser.write('\x1b[6n');
        verify(handler.sendCursorPosition());
      });
    });

    group('margin operations', () {
      test('parses set scrolling margins (DECSTBM)', () {
        parser.write('\x1b[5;20r');
        verify(handler.setMargins(4, 19)); // 0-indexed
      });

      test('parses reset scrolling margins', () {
        parser.write('\x1b[r');
        verify(handler.setMargins(0, null));
      });
    });

    group('SGR - text styling', () {
      test('parses reset style (SGR 0)', () {
        parser.write('\x1b[0m');
        verify(handler.resetCursorStyle());
      });

      test('parses bold (SGR 1)', () {
        parser.write('\x1b[1m');
        verify(handler.setCursorBold());
      });

      test('parses faint (SGR 2)', () {
        parser.write('\x1b[2m');
        verify(handler.setCursorFaint());
      });

      test('parses italic (SGR 3)', () {
        parser.write('\x1b[3m');
        verify(handler.setCursorItalic());
      });

      test('parses underline (SGR 4)', () {
        parser.write('\x1b[4m');
        verify(handler.setCursorUnderline());
      });

      test('parses blink (SGR 5)', () {
        parser.write('\x1b[5m');
        verify(handler.setCursorBlink());
      });

      test('parses inverse (SGR 7)', () {
        parser.write('\x1b[7m');
        verify(handler.setCursorInverse());
      });

      test('parses invisible (SGR 8)', () {
        parser.write('\x1b[8m');
        verify(handler.setCursorInvisible());
      });

      test('parses strikethrough (SGR 9)', () {
        parser.write('\x1b[9m');
        verify(handler.setCursorStrikethrough());
      });
    });

    group('SGR - unset text styling', () {
      test('parses unset bold (SGR 21)', () {
        parser.write('\x1b[21m');
        verify(handler.unsetCursorBold());
      });

      test('parses unset faint (SGR 22)', () {
        parser.write('\x1b[22m');
        verify(handler.unsetCursorFaint());
      });

      test('parses unset italic (SGR 23)', () {
        parser.write('\x1b[23m');
        verify(handler.unsetCursorItalic());
      });

      test('parses unset underline (SGR 24)', () {
        parser.write('\x1b[24m');
        verify(handler.unsetCursorUnderline());
      });

      test('parses unset blink (SGR 25)', () {
        parser.write('\x1b[25m');
        verify(handler.unsetCursorBlink());
      });

      test('parses unset inverse (SGR 27)', () {
        parser.write('\x1b[27m');
        verify(handler.unsetCursorInverse());
      });

      test('parses unset invisible (SGR 28)', () {
        parser.write('\x1b[28m');
        verify(handler.unsetCursorInvisible());
      });

      test('parses unset strikethrough (SGR 29)', () {
        parser.write('\x1b[29m');
        verify(handler.unsetCursorStrikethrough());
      });
    });

    group('SGR - foreground colors', () {
      test('parses foreground color 16 (SGR 30-37)', () {
        parser.write('\x1b[31m'); // Red
        verify(handler.setForegroundColor16(1));
      });

      test('parses reset foreground (SGR 39)', () {
        parser.write('\x1b[39m');
        verify(handler.resetForeground());
      });

      test('parses foreground color 256', () {
        parser.write('\x1b[38;5;196m');
        verify(handler.setForegroundColor256(196));
      });

      test('parses foreground color RGB', () {
        parser.write('\x1b[38;2;255;128;64m');
        verify(handler.setForegroundColorRgb(255, 128, 64));
      });
    });

    group('SGR - background colors', () {
      test('parses background color 16 (SGR 40-47)', () {
        parser.write('\x1b[44m'); // Blue
        verify(handler.setBackgroundColor16(4));
      });

      test('parses reset background (SGR 49)', () {
        parser.write('\x1b[49m');
        verify(handler.resetBackground());
      });

      test('parses background color 256', () {
        parser.write('\x1b[48;5;231m');
        verify(handler.setBackgroundColor256(231));
      });

      test('parses background color RGB', () {
        parser.write('\x1b[48;2;0;100;200m');
        verify(handler.setBackgroundColorRgb(0, 100, 200));
      });
    });

    group('OSC - operating system commands', () {
      test('parses set title (OSC 0)', () {
        parser.write('\x1b]0;My Title\x07');
        verify(handler.setTitle('My Title'));
      });

      test('parses set title (OSC 2)', () {
        parser.write('\x1b]2;Window Title\x07');
        verify(handler.setTitle('Window Title'));
      });

      test('parses set icon name (OSC 1)', () {
        parser.write('\x1b]1;Icon\x07');
        verify(handler.setIconName('Icon'));
      });
    });

    group('DEC private modes', () {
      test('parses cursor keys mode set', () {
        parser.write('\x1b[?1h');
        verify(handler.setCursorKeysMode(true));
      });

      test('parses cursor keys mode reset', () {
        parser.write('\x1b[?1l');
        verify(handler.setCursorKeysMode(false));
      });

      test('parses auto wrap mode set', () {
        parser.write('\x1b[?7h');
        verify(handler.setAutoWrapMode(true));
      });

      test('parses auto wrap mode reset', () {
        parser.write('\x1b[?7l');
        verify(handler.setAutoWrapMode(false));
      });

      test('parses cursor visible mode set', () {
        parser.write('\x1b[?25h');
        verify(handler.setCursorVisibleMode(true));
      });

      test('parses cursor visible mode reset', () {
        parser.write('\x1b[?25l');
        verify(handler.setCursorVisibleMode(false));
      });

      test('parses alternate buffer switch', () {
        parser.write('\x1b[?1049h');
        verify(handler.useAltBuffer());
      });

      test('parses main buffer switch', () {
        parser.write('\x1b[?1049l');
        verify(handler.useMainBuffer());
      });

      test('parses bracketed paste mode set', () {
        parser.write('\x1b[?2004h');
        verify(handler.setBracketedPasteMode(true));
      });

      test('parses bracketed paste mode reset', () {
        parser.write('\x1b[?2004l');
        verify(handler.setBracketedPasteMode(false));
      });
    });

    group('character writing', () {
      test('writes printable characters', () {
        parser.write('A');
        verify(handler.writeChar(65));
      });

      test('writes multiple characters', () {
        parser.write('ABC');
        verify(handler.writeChar(65));
        verify(handler.writeChar(66));
        verify(handler.writeChar(67));
      });
    });

    group('repeat character', () {
      test('parses repeat previous character (REP)', () {
        parser.write('\x1b[5b');
        verify(handler.repeatPreviousCharacter(5));
      });
    });
  });
}
