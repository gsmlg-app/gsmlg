import 'package:app_vnc/app_vnc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vnc_viewer_widgets/vnc_viewer_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KeysymMapper.fromLogicalKey', () {
    test('maps macOS Command, Option, Control, Shift, and CapsLock', () {
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.metaLeft),
        X11Keysym.superL,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.metaRight),
        X11Keysym.superR,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.altLeft),
        X11Keysym.altL,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.altRight),
        X11Keysym.altR,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.controlLeft),
        X11Keysym.controlL,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.controlRight),
        X11Keysym.controlR,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.shiftLeft),
        X11Keysym.shiftL,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.shiftRight),
        X11Keysym.shiftR,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.capsLock),
        X11Keysym.capsLock,
      );
    });

    test('maps function keys F1 through F12', () {
      final pairs = <LogicalKeyboardKey, int>{
        LogicalKeyboardKey.f1: X11Keysym.f1,
        LogicalKeyboardKey.f2: X11Keysym.f2,
        LogicalKeyboardKey.f3: X11Keysym.f3,
        LogicalKeyboardKey.f4: X11Keysym.f4,
        LogicalKeyboardKey.f5: X11Keysym.f5,
        LogicalKeyboardKey.f6: X11Keysym.f6,
        LogicalKeyboardKey.f7: X11Keysym.f7,
        LogicalKeyboardKey.f8: X11Keysym.f8,
        LogicalKeyboardKey.f9: X11Keysym.f9,
        LogicalKeyboardKey.f10: X11Keysym.f10,
        LogicalKeyboardKey.f11: X11Keysym.f11,
        LogicalKeyboardKey.f12: X11Keysym.f12,
      };
      for (final entry in pairs.entries) {
        expect(
          KeysymMapper.fromLogicalKey(entry.key),
          entry.value,
          reason: 'Expected ${entry.key.debugName} -> ${entry.value}',
        );
      }
    });

    test('maps arrow, navigation, and editing keys before character check', () {
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.arrowLeft),
        X11Keysym.left,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.arrowUp),
        X11Keysym.up,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.arrowRight),
        X11Keysym.right,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.arrowDown),
        X11Keysym.down,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.home),
        X11Keysym.home,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.end),
        X11Keysym.end,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.pageUp),
        X11Keysym.pageUp,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.pageDown),
        X11Keysym.pageDown,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.insert),
        X11Keysym.insert,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.delete),
        X11Keysym.delete,
      );
      expect(
        KeysymMapper.fromLogicalKey(
          LogicalKeyboardKey.backspace,
          character: '\b',
        ),
        X11Keysym.backSpace,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.tab, character: '\t'),
        X11Keysym.tab,
      );
      expect(
        KeysymMapper.fromLogicalKey(
          LogicalKeyboardKey.escape,
          character: '\x1b',
        ),
        X11Keysym.escape,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.enter, character: '\r'),
        X11Keysym.returnKey,
      );
      expect(
        KeysymMapper.fromLogicalKey(
          LogicalKeyboardKey.numpadEnter,
          character: '\r',
        ),
        X11Keysym.returnKey,
      );
    });

    test('maps printable ASCII and Unicode characters', () {
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.keyA, character: 'a'),
        0x61,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.keyA, character: 'A'),
        0x41,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.space, character: ' '),
        0x20,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.digit1, character: '!'),
        0x21,
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.keyZ, character: '中'),
        0x01004E2D,
      );
    });

    test('falls back to keyLabel when character is null or control char', () {
      // macOS Cmd+C has character == null and keyLabel == 'C'
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.keyC),
        'c'.codeUnitAt(0),
      );
      expect(
        KeysymMapper.fromLogicalKey(
          LogicalKeyboardKey.keyC,
          shiftPressed: true,
        ),
        'C'.codeUnitAt(0),
      );
      // Ctrl+C may supply control character '\x03' which unicodeToKeysym rejects
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.keyC, character: '\x03'),
        'c'.codeUnitAt(0),
      );
      expect(
        KeysymMapper.fromLogicalKey(LogicalKeyboardKey.digit5),
        '5'.codeUnitAt(0),
      );
    });
  });

  group('KeysymMapper.fromKeyEvent', () {
    test(
      'maps KeyDownEvent with character and KeyUpEvent without character',
      () {
        const down = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyC,
          logicalKey: LogicalKeyboardKey.keyC,
          character: 'c',
          timeStamp: Duration.zero,
        );
        const up = KeyUpEvent(
          physicalKey: PhysicalKeyboardKey.keyC,
          logicalKey: LogicalKeyboardKey.keyC,
          timeStamp: Duration(milliseconds: 10),
        );
        const cmdDown = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.metaLeft,
          logicalKey: LogicalKeyboardKey.metaLeft,
          timeStamp: Duration.zero,
        );

        expect(KeysymMapper.fromKeyEvent(down), 'c'.codeUnitAt(0));
        expect(KeysymMapper.fromKeyEvent(up), 'c'.codeUnitAt(0));
        expect(KeysymMapper.fromKeyEvent(cmdDown), X11Keysym.superL);
      },
    );
  });
}
