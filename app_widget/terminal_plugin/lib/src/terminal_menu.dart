import 'package:context_menus/context_menus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:file_manager_plugin/file_manager_plugin.dart';
import 'package:starter_plugin/starter_plugin.dart';
import 'package:terminal_plugin/src/terminal_plugin.dart';
import 'package:xterm/xterm.dart';

class TerminalContextMenu extends StatefulWidget {
  const TerminalContextMenu({
    super.key,
    required this.plugin,
  });

  final TerminalPlugin plugin;

  @override
  State<TerminalContextMenu> createState() => TerminalContextMenuState();
}

class TerminalContextMenuState extends State<TerminalContextMenu>
    with ContextMenuStateMixin {
  TerminalPlugin get plugin => widget.plugin;

  Terminal get terminal => plugin.terminal;

  TerminalController get terminalController => plugin.terminalController;

  @override
  void initState() {
    terminalController.addListener(_onSelectionChanged);
    super.initState();
  }

  @override
  void dispose() {
    terminalController.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TerminalContextMenu oldWidget) {
    if (oldWidget.plugin.terminalController !=
        widget.plugin.terminalController) {
      oldWidget.plugin.terminalController.removeListener(_onSelectionChanged);
      widget.plugin.terminalController.addListener(_onSelectionChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onSelectionChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isApple = defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final tabsService = context.read<TabsService?>();

    return cardBuilder(
      context,
      [
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            'Copy',
            icon: const Icon(Icons.copy),
            shortcutLabel: isApple ? 'Cmd+C' : 'Ctrl+Shift+C',
            onPressed: terminalController.selection != null
                ? () => handlePressed(context, _handleCopy)
                : null,
          ),
        ),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            'Paste',
            icon: const Icon(Icons.paste),
            shortcutLabel: isApple ? 'Cmd+V' : 'Ctrl+Shift+V',
            onPressed: () => handlePressed(context, _handlePaste),
          ),
        ),
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            'Select All',
            icon: const Icon(Icons.select_all),
            shortcutLabel: isApple ? 'Cmd+A' : 'Ctrl+Shift+A',
            onPressed: () => handlePressed(context, _handleSelectAll),
          ),
        ),
        if (tabsService != null) ...[
          buildDivider(),
          buttonBuilder(
            context,
            ContextMenuButtonConfig(
              'File Manager',
              icon: const Icon(Icons.folder_open),
              shortcutLabel: 'Ctrl+Shift+F',
              onPressed: () => handlePressed(context, _handleOpenFileManager),
            ),
          ),
          buttonBuilder(
            context,
            ContextMenuButtonConfig(
              'Uptime',
              icon: const Icon(Icons.keyboard_double_arrow_up_outlined),
              onPressed: () => handlePressed(context, _handleStarterPlugin),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleCopy() async {
    final selection = terminalController.selection;

    if (selection == null) {
      return;
    }

    final text = terminal.buffer.getText(selection);

    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);

    if (data == null) {
      return;
    }

    final text = data.text;

    if (text == null) {
      return;
    }

    terminal.paste(text);
  }

  Future<void> _handleSelectAll() async {
    if (terminal.buffer.lines.length == 0) return;
    terminalController.setSelection(
      terminal.buffer.createAnchor(0, 0),
      terminal.buffer.createAnchor(
        terminal.viewWidth,
        terminal.buffer.lines.length - 1,
      ),
      mode: SelectionMode.line,
    );
  }

  Future<void> _handleOpenFileManager() async {
    context.read<TabsService?>()?.openPlugin(
          plugin.hostSpec,
          FileManagerPlugin(),
        );
  }

  Future<void> _handleStarterPlugin() async {
    context.read<TabsService?>()?.openPlugin(
          plugin.hostSpec,
          StarterPlugin(),
        );
  }
}
