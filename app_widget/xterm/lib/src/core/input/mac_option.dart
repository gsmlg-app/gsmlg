/// How the Option keys behave on macOS.
enum MacOptionKeyBehavior {
  /// Left Option acts as Meta, right Option types composed characters.
  leftMeta,

  /// Both Option keys act as Meta.
  bothMeta,

  /// Both Option keys type composed characters.
  normal,
}

extension MacOptionKeyBehaviorMeta on MacOptionKeyBehavior {
  /// Whether the currently pressed Option key(s) should act as Meta.
  bool sendsMeta({required bool leftOption, required bool rightOption}) {
    switch (this) {
      case MacOptionKeyBehavior.leftMeta:
        return leftOption;
      case MacOptionKeyBehavior.bothMeta:
        return leftOption || rightOption;
      case MacOptionKeyBehavior.normal:
        return false;
    }
  }
}

const _usShiftedCharacters = <String, String>{
  '`': '~',
  '1': '!',
  '2': '@',
  '3': '#',
  '4': r'$',
  '5': '%',
  '6': '^',
  '7': '&',
  '8': '*',
  '9': '(',
  '0': ')',
  '-': '_',
  '=': '+',
  '[': '{',
  ']': '}',
  r'\': '|',
  ';': ':',
  "'": '"',
  ',': '<',
  '.': '>',
  '/': '?',
};

/// Builds the Meta sequence (ESC followed by the character) for a key whose
/// unmodified character is [baseCodePoint]. Returns null if the key does not
/// produce a printable character.
///
/// [baseCodePoint] is the character the key produces without any modifier,
/// as reported by the logical key of the event. When [shift] is pressed,
/// letters are upper-cased and US punctuation is shifted.
String? macOptionMetaInput(int baseCodePoint, {required bool shift}) {
  if (baseCodePoint < 0x20 ||
      baseCodePoint == 0x7f ||
      baseCodePoint > 0x10ffff ||
      (baseCodePoint >= 0x80 && baseCodePoint < 0xa0)) {
    return null;
  }

  final base = String.fromCharCode(baseCodePoint);
  final character = shift ? _shifted(base) : base;
  return '\x1b$character';
}

String _shifted(String base) {
  final upper = base.toUpperCase();
  if (upper != base && upper.runes.length == 1) {
    return upper;
  }
  return _usShiftedCharacters[base] ?? base;
}
