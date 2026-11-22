import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:terminal_plugin/src/terminal_plugin.dart';

enum _ClipboardAction { copy, paste, selectAll, selectText, trust }

/// Native actions outside the terminal's mouse-reporting surface.
class TerminalClipboardMenu extends StatelessWidget {
  const TerminalClipboardMenu({super.key, required this.plugin});

  final TerminalPlugin plugin;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ClipboardAction>(
      tooltip: context.l10n.terminalClipboardActions,
      icon: const Icon(Icons.content_paste),
      onSelected: (action) async {
        switch (action) {
          case _ClipboardAction.copy:
            await plugin.copySelection();
          case _ClipboardAction.paste:
            await plugin.pasteClipboard();
          case _ClipboardAction.selectAll:
            plugin.selectAll();
          case _ClipboardAction.selectText:
            plugin.terminalController.setSuspendPointerInput(
              !plugin.terminalController.suspendedPointerInputs,
            );
          case _ClipboardAction.trust:
            plugin.setRemoteClipboardTrusted(!plugin.remoteClipboard.trusted);
        }
      },
      itemBuilder: (context) => [
        if (!plugin.isolatedTerminalEnabled) ...[
          PopupMenuItem(
            value: _ClipboardAction.copy,
            enabled: plugin.terminalController.selection != null,
            child: Text(MaterialLocalizations.of(context).copyButtonLabel),
          ),
          PopupMenuItem(
            value: _ClipboardAction.paste,
            child: Text(MaterialLocalizations.of(context).pasteButtonLabel),
          ),
          PopupMenuItem(
            value: _ClipboardAction.selectAll,
            child: Text(MaterialLocalizations.of(context).selectAllButtonLabel),
          ),
          CheckedPopupMenuItem(
            value: _ClipboardAction.selectText,
            checked: plugin.terminalController.suspendedPointerInputs,
            child: Text(context.l10n.terminalSelectText),
          ),
          const PopupMenuDivider(),
        ],
        CheckedPopupMenuItem(
          value: _ClipboardAction.trust,
          enabled: plugin.remoteClipboard.sessionActive &&
              plugin.remoteClipboard.writesAllowed(),
          checked: plugin.remoteClipboard.trusted,
          child: Text(plugin.remoteClipboard.trusted
              ? context.l10n.remoteClipboardRevoke
              : context.l10n.remoteClipboardTrust),
        ),
        if (!plugin.remoteClipboard.writesAllowed())
          PopupMenuItem(
            enabled: false,
            child: Text(context.l10n.remoteClipboardEnableFirst),
          ),
      ],
    );
  }
}
