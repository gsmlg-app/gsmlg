import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

export 'dart:io' show Platform;

class PlatformExt {
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isAIM =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

extension PlatformExtension on Platform {
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isAIM =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}
