import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:xterm/src/terminal.dart';
import 'package:xterm/src/ui/controller.dart';
import 'package:xterm/src/ui/selection_mode.dart';

class TerminalActions extends StatelessWidget {
  const TerminalActions({
    super.key,
    required this.terminal,
    required this.controller,
    required this.child,
    this.onPaste,
  });

  final Terminal terminal;

  final TerminalController controller;

  final Widget child;

  /// Called after clipboard text has been pasted into [terminal].
  final VoidCallback? onPaste;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        PasteTextIntent: CallbackAction<PasteTextIntent>(
          onInvoke: (intent) async {
            try {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              final text = data?.text;
              if (text != null) {
                terminal.paste(text);
                controller.clearSelection();
                onPaste?.call();
              }
            } catch (_) {
              // Clipboard access may be unavailable while the terminal stays usable.
            }
            return null;
          },
        ),
        CopySelectionTextIntent: CallbackAction<CopySelectionTextIntent>(
          onInvoke: (intent) async {
            final selection = controller.selection;

            if (selection == null) {
              return null;
            }

            final text = terminal.buffer.getText(selection);

            try {
              await Clipboard.setData(ClipboardData(text: text));
            } catch (_) {
              // Clipboard access may be unavailable while the terminal stays usable.
            }

            return null;
          },
        ),
        SelectAllTextIntent: CallbackAction<SelectAllTextIntent>(
          onInvoke: (intent) {
            if (terminal.buffer.height == 0) {
              return null;
            }
            controller.setSelection(
              terminal.buffer.createAnchor(0, 0),
              terminal.buffer.createAnchor(
                terminal.viewWidth,
                terminal.buffer.height - 1,
              ),
              mode: SelectionMode.line,
            );
            return null;
          },
        ),
      },
      child: child,
    );
  }
}
