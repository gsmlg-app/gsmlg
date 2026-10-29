import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terminal_tabs/src/target_platform.dart';

SingleActivator get openSettings {
  return defaultTargetPlatform.isApple
      ? const SingleActivator(LogicalKeyboardKey.comma, meta: true)
      : const SingleActivator(LogicalKeyboardKey.comma, control: true);
}

SingleActivator get openDevTools {
  return const SingleActivator(LogicalKeyboardKey.f12);
}

SingleActivator get openNewWindow {
  return defaultTargetPlatform.isApple
      ? const SingleActivator(LogicalKeyboardKey.keyN, meta: true)
      : const SingleActivator(LogicalKeyboardKey.keyN, control: true);
}

SingleActivator get tabClose {
  return defaultTargetPlatform.isApple
      ? const SingleActivator(LogicalKeyboardKey.keyW, meta: true)
      : const SingleActivator(LogicalKeyboardKey.keyW, meta: true, shift: true);
}

SingleActivator get terminalCopy {
  return defaultTargetPlatform.isApple
      ? const SingleActivator(LogicalKeyboardKey.keyC, meta: true)
      : const SingleActivator(
          LogicalKeyboardKey.keyC,
          control: true,
          shift: true,
        );
}

SingleActivator get terminalPaste {
  return defaultTargetPlatform.isApple
      ? const SingleActivator(LogicalKeyboardKey.keyV, meta: true)
      : const SingleActivator(
          LogicalKeyboardKey.keyV,
          control: true,
          shift: true,
        );
}

SingleActivator get terminalSelectAll {
  return defaultTargetPlatform.isApple
      ? const SingleActivator(LogicalKeyboardKey.keyA, meta: true)
      : const SingleActivator(
          LogicalKeyboardKey.keyA,
          control: true,
          shift: true,
        );
}

SingleActivator get toggleFullscreen {
  return const SingleActivator(LogicalKeyboardKey.f11);
}

SingleActivator get tabNew {
  return defaultTargetPlatform.isApple
      ? const SingleActivator(LogicalKeyboardKey.keyT, meta: true)
      : const SingleActivator(
          LogicalKeyboardKey.keyT,
          control: true,
          shift: true,
        );
}

SingleActivator get tabNext {
  // Shift+] produces } (braceRight)
  return defaultTargetPlatform.isApple
      ? const SingleActivator(
          LogicalKeyboardKey.braceRight,
          meta: true,
          shift: true,
        )
      : const SingleActivator(
          LogicalKeyboardKey.braceRight,
          control: true,
          shift: true,
        );
}

SingleActivator get tabPrevious {
  // Shift+[ produces { (braceLeft)
  return defaultTargetPlatform.isApple
      ? const SingleActivator(
          LogicalKeyboardKey.braceLeft,
          meta: true,
          shift: true,
        )
      : const SingleActivator(
          LogicalKeyboardKey.braceLeft,
          control: true,
          shift: true,
        );
}

const _digitKeys = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];

/// Returns shortcut for go-to-tab. [n] is 1-based (1-9).
SingleActivator tabGoTo(int n) {
  assert(n >= 1 && n <= 9);
  return defaultTargetPlatform.isApple
      ? SingleActivator(_digitKeys[n - 1], meta: true)
      : SingleActivator(_digitKeys[n - 1], control: true);
}
