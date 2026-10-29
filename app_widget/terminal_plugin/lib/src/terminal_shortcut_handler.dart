import 'package:flutter/widgets.dart';

/// Provides a key event handler and focus control to descendant terminal views.
///
/// Place this above terminal content in the widget tree. The [TerminalTabView]
/// picks up the handler and passes it to [TerminalView.onKeyEvent], which has
/// higher priority than the terminal's own key input handler.
///
/// Call [focusNotifier] to signal descendant terminal views to request focus.
class TerminalShortcutHandler extends InheritedWidget {
  const TerminalShortcutHandler({
    super.key,
    required this.onKeyEvent,
    required this.focusNotifier,
    required super.child,
  });

  final FocusOnKeyEventCallback onKeyEvent;

  /// Increment this to signal the active terminal view to request focus.
  final ValueNotifier<int> focusNotifier;

  static TerminalShortcutHandler? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TerminalShortcutHandler>();
  }

  @override
  bool updateShouldNotify(TerminalShortcutHandler oldWidget) {
    return onKeyEvent != oldWidget.onKeyEvent ||
        focusNotifier != oldWidget.focusNotifier;
  }
}
