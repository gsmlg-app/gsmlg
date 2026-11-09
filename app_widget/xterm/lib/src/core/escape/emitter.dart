class EscapeEmitter {
  const EscapeEmitter();

  String primaryDeviceAttributes() {
    return '\x1b[?1;2c';
  }

  String secondaryDeviceAttributes() {
    const model = 0;
    const version = 0;
    return '\x1b[>$model;$version;0c';
  }

  String tertiaryDeviceAttributes() {
    return '\x1bP!|00000000\x1b\\';
  }

  String operatingStatus() {
    return '\x1b[0n';
  }

  String cursorPosition(int x, int y) {
    return '\x1b[$y;${x}R';
  }

  String bracketedPaste(String text) {
    return '\x1b[200~${stripBracketedPasteGuards(text)}\x1b[201~';
  }

  /// Removes bracketed paste start/end markers from [text] so pasted content
  /// cannot terminate the paste early and inject commands.
  static String stripBracketedPasteGuards(String text) {
    final guards = RegExp(r'\x1b\[20[01]~');
    var result = text;
    while (guards.hasMatch(result)) {
      result = result.replaceAll(guards, '');
    }
    return result;
  }

  String size(int rows, int cols) {
    return '\x1b[8;$rows;${cols}t';
  }
}
