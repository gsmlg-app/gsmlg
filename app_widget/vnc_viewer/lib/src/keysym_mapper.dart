import 'package:app_vnc/app_vnc.dart';
import 'package:flutter/services.dart';

/// Maps Flutter keyboard events and logical keys to X11 keysyms for RFB.
abstract final class KeysymMapper {
  static final Map<LogicalKeyboardKey, int> _specialKeys = {
    // Modifiers (macOS Command -> Super, Option -> Alt)
    LogicalKeyboardKey.metaLeft: X11Keysym.superL,
    LogicalKeyboardKey.metaRight: X11Keysym.superR,
    LogicalKeyboardKey.meta: X11Keysym.superL,
    LogicalKeyboardKey.altLeft: X11Keysym.altL,
    LogicalKeyboardKey.altRight: X11Keysym.altR,
    LogicalKeyboardKey.alt: X11Keysym.altL,
    LogicalKeyboardKey.controlLeft: X11Keysym.controlL,
    LogicalKeyboardKey.controlRight: X11Keysym.controlR,
    LogicalKeyboardKey.control: X11Keysym.controlL,
    LogicalKeyboardKey.shiftLeft: X11Keysym.shiftL,
    LogicalKeyboardKey.shiftRight: X11Keysym.shiftR,
    LogicalKeyboardKey.shift: X11Keysym.shiftL,
    LogicalKeyboardKey.capsLock: X11Keysym.capsLock,

    // Editing & control keys
    LogicalKeyboardKey.enter: X11Keysym.returnKey,
    LogicalKeyboardKey.numpadEnter: X11Keysym.returnKey,
    LogicalKeyboardKey.backspace: X11Keysym.backSpace,
    LogicalKeyboardKey.delete: X11Keysym.delete,
    LogicalKeyboardKey.tab: X11Keysym.tab,
    LogicalKeyboardKey.escape: X11Keysym.escape,
    LogicalKeyboardKey.insert: X11Keysym.insert,

    // Navigation keys
    LogicalKeyboardKey.home: X11Keysym.home,
    LogicalKeyboardKey.end: X11Keysym.end,
    LogicalKeyboardKey.pageUp: X11Keysym.pageUp,
    LogicalKeyboardKey.pageDown: X11Keysym.pageDown,
    LogicalKeyboardKey.arrowLeft: X11Keysym.left,
    LogicalKeyboardKey.arrowUp: X11Keysym.up,
    LogicalKeyboardKey.arrowRight: X11Keysym.right,
    LogicalKeyboardKey.arrowDown: X11Keysym.down,

    // Function keys
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

  /// Maps a Flutter [KeyEvent] to an X11 keysym, or `null` if unmapped.
  static int? fromKeyEvent(KeyEvent event) {
    return fromLogicalKey(
      event.logicalKey,
      character: event.character,
      shiftPressed: HardwareKeyboard.instance.isShiftPressed,
    );
  }

  /// Maps a [LogicalKeyboardKey] and optional [character] to an X11 keysym.
  ///
  /// Special keys are resolved before [character] so control/editing keys
  /// (such as Enter, Tab, Backspace, Escape) always map to their X11 keysym.
  /// When [character] is `null` or non-printable (e.g. `KeyUpEvent` or
  /// macOS `Cmd+C`/`Ctrl+C`), falls back to [LogicalKeyboardKey.keyLabel],
  /// lowercasing ASCII `A-Z` unless [shiftPressed] is `true`.
  static int? fromLogicalKey(
    LogicalKeyboardKey key, {
    String? character,
    bool shiftPressed = false,
  }) {
    final special = _specialKeys[key];
    if (special != null) return special;

    if (character != null && character.isNotEmpty) {
      final keysym = unicodeToKeysym(character.runes.first);
      if (keysym != 0) return keysym;
    }

    final label = key.keyLabel;
    if (label.runes.length == 1) {
      var codePoint = label.runes.first;
      if (!shiftPressed && codePoint >= 0x41 && codePoint <= 0x5A) {
        codePoint += 0x20;
      }
      final keysym = unicodeToKeysym(codePoint);
      if (keysym != 0) return keysym;
    }

    return null;
  }
}
