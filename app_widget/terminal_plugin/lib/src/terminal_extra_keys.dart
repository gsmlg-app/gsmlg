import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

/// Touch keys for terminal input without moving focus away from the terminal.
class TerminalExtraKeys extends StatelessWidget {
  const TerminalExtraKeys({
    super.key,
    required this.ctrlPressed,
    required this.altPressed,
    required this.onToggleCtrl,
    required this.onToggleAlt,
    required this.onKey,
    required this.onText,
    required this.onHideKeyboard,
  });

  final bool ctrlPressed;
  final bool altPressed;
  final VoidCallback onToggleCtrl;
  final VoidCallback onToggleAlt;
  final ValueChanged<TerminalKey> onKey;
  final ValueChanged<String> onText;
  final VoidCallback onHideKeyboard;

  static const _keys = <(String, TerminalKey?)>[
    ('ESC', TerminalKey.escape),
    ('TAB', TerminalKey.tab),
    ('CTRL', null),
    ('ALT', null),
    ('HOME', TerminalKey.home),
    ('END', TerminalKey.end),
    ('PGUP', TerminalKey.pageUp),
    ('←', TerminalKey.arrowLeft),
    ('↓', TerminalKey.arrowDown),
    ('↑', TerminalKey.arrowUp),
    ('→', TerminalKey.arrowRight),
    ('PGDN', TerminalKey.pageDown),
    ('-', null),
    ('HIDE', null),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ExcludeFocus(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= _keys.length * 48 ? _keys.length : 7;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var start = 0; start < _keys.length; start += columns)
                  Row(
                    children: [
                      for (final (label, terminalKey)
                          in _keys.skip(start).take(columns))
                        Expanded(
                          child: _buildKey(context, label, terminalKey),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKey(
    BuildContext context,
    String label,
    TerminalKey? terminalKey,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isHideKeyboard = label == 'HIDE';
    final keyLabel = isHideKeyboard ? context.l10n.hide : label;
    final bool? toggled = switch (label) {
      'CTRL' => ctrlPressed,
      'ALT' => altPressed,
      _ => null,
    };
    final onPressed = terminalKey != null
        ? () => onKey(terminalKey)
        : switch (label) {
            'CTRL' => onToggleCtrl,
            'ALT' => onToggleAlt,
            '-' => () => onText('-'),
            _ => onHideKeyboard,
          };

    return Semantics(
      label: keyLabel,
      button: true,
      toggled: toggled,
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: keyLabel,
        excludeFromSemantics: true,
        child: Ink(
          color: toggled == true
              ? colors.secondaryContainer
              : colors.surfaceContainerLow,
          child: InkWell(
            canRequestFocus: false,
            excludeFromSemantics: true,
            onTap: onPressed,
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: isHideKeyboard
                      ? Icon(Icons.keyboard_hide, color: colors.onSurface)
                      : Text(
                          label,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: toggled == true
                                        ? colors.onSecondaryContainer
                                        : colors.onSurface,
                                    fontWeight: toggled == true
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
