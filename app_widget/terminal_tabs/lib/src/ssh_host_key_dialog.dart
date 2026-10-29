import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

Future<bool> showSshHostKeyConfirmation(
  BuildContext context,
  SshHostKey key,
) async {
  if (!context.mounted) return false;
  final l10n = context.l10n;
  return await showDmDialog<bool>(
        context: context,
        title: Text(l10n.sshHostKeyTitle),
        content: SingleChildScrollView(
          child: SelectableText(
            l10n.sshHostKeyPrompt(
              key.hostname,
              key.port,
              key.type,
              key.fingerprint,
            ),
          ),
        ),
        actions: [
          DmDialogAction(
            onPressed: (dialogContext) =>
                Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          DmDialogAction(
            onPressed: (dialogContext) => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.sshHostKeyTrust),
          ),
        ],
      ) ??
      false;
}
