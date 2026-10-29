import 'package:flutter/material.dart';
import 'package:terminal_tabs/src/shortcut/intents.dart';
import 'package:terminal_tabs/src/shortcuts.dart' as shortcuts;

class GlobalShortcuts extends StatelessWidget {
  const GlobalShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        shortcuts.openNewWindow: const NewWindowIntent(),
        shortcuts.toggleFullscreen: const ToggleFullscreenIntent(),
      },
      child: child,
    );
  }
}
