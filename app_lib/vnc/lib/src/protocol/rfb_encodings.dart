/// RFB (VNC) encoding and pseudo-encoding identifiers (RFC 6143 and extensions).
abstract final class RfbEncoding {
  static const int raw = 0;
  static const int copyRect = 1;
  static const int hextile = 5;
  static const int zrle = 16;
  static const int desktopSize = -223;
  static const int lastRect = -224;
  static const int cursor = -239;
  static const int extendedDesktopSize = -308;

  /// Default preferred encodings advertised to the server during handshake.
  static const List<int> defaultEncodings = [
    zrle,
    copyRect,
    hextile,
    raw,
    desktopSize,
    extendedDesktopSize,
    cursor,
    lastRect,
  ];
}

/// RFB (VNC) security type identifiers (RFC 6143 and Apple Remote Desktop).
abstract final class RfbSecurityType {
  static const int invalid = 0;
  static const int none = 1;
  static const int vncAuth = 2;
  static const int appleArd = 30;
}
