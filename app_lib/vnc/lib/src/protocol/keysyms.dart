abstract final class X11Keysym {
  static const int backSpace = 0xFF08;
  static const int tab = 0xFF09;
  static const int returnKey = 0xFF0D;
  static const int escape = 0xFF1B;
  static const int insert = 0xFF63;
  static const int delete = 0xFFFF;
  static const int home = 0xFF50;
  static const int left = 0xFF51;
  static const int up = 0xFF52;
  static const int right = 0xFF53;
  static const int down = 0xFF54;
  static const int pageUp = 0xFF55;
  static const int pageDown = 0xFF56;
  static const int end = 0xFF57;

  static const int f1 = 0xFFBE;
  static const int f2 = 0xFFBF;
  static const int f3 = 0xFFC0;
  static const int f4 = 0xFFC1;
  static const int f5 = 0xFFC2;
  static const int f6 = 0xFFC3;
  static const int f7 = 0xFFC4;
  static const int f8 = 0xFFC5;
  static const int f9 = 0xFFC6;
  static const int f10 = 0xFFC7;
  static const int f11 = 0xFFC8;
  static const int f12 = 0xFFC9;

  static const int shiftL = 0xFFE1;
  static const int shiftR = 0xFFE2;
  static const int controlL = 0xFFE3;
  static const int controlR = 0xFFE4;
  static const int capsLock = 0xFFE5;
  static const int metaL = 0xFFE7;
  static const int metaR = 0xFFE8;
  static const int altL = 0xFFE9;
  static const int altR = 0xFFEA;
  static const int superL = 0xFFEB; // macOS Left Command
  static const int superR = 0xFFEC; // macOS Right Command
}

/// Converts a Unicode scalar value to an X11 keysym per RFC 6143 §7.5.4.
int unicodeToKeysym(int codePoint) {
  if (codePoint >= 0xD800 && codePoint <= 0xDFFF) return 0;
  if (codePoint >= 0x0020 && codePoint <= 0x007E) return codePoint;
  if (codePoint >= 0x00A0 && codePoint <= 0x00FF) return codePoint;
  if (codePoint >= 0x0100 && codePoint <= 0x10FFFF) {
    return 0x01000000 | codePoint;
  }
  return 0;
}
