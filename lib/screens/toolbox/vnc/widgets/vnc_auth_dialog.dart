import 'package:app_locale/app_locale.dart';
import 'package:app_vnc/app_vnc.dart';
import 'package:flutter/material.dart';

/// Prompts the user for VNC credentials during authentication or retry.
class VncAuthDialog extends StatefulWidget {
  const VncAuthDialog({
    super.key,
    required this.requiresUsername,
    this.initialUsername,
    this.subtitle,
    this.usernameOptional = false,
  });

  final bool requiresUsername;
  final String? initialUsername;
  final String? subtitle;
  final bool usernameOptional;

  static Future<VncCredentials?> show(
    BuildContext context, {
    required bool requiresUsername,
    String? initialUsername,
    String? subtitle,
    bool usernameOptional = false,
  }) {
    return showDialog<VncCredentials>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VncAuthDialog(
        requiresUsername: requiresUsername,
        initialUsername: initialUsername,
        subtitle: subtitle,
        usernameOptional: usernameOptional,
      ),
    );
  }

  @override
  State<VncAuthDialog> createState() => _VncAuthDialogState();
}

class _VncAuthDialogState extends State<VncAuthDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.initialUsername ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final username = _usernameController.text.trim();
    Navigator.of(context).pop(
      VncCredentials(
        username: widget.requiresUsername && username.isNotEmpty
            ? username
            : null,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasInitialUsername =
        (widget.initialUsername?.trim().isNotEmpty ?? false);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Text(l10n.vncAuthPromptTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (widget.requiresUsername) ...[
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.vncUsernameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: !hasInitialUsername,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: (value) {
                      if (!widget.usernameOptional &&
                          (value == null || value.trim().isEmpty)) {
                        return '${l10n.vncUsernameLabel} is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.vncPasswordLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  autofocus: !widget.requiresUsername || hasInitialUsername,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.vncConnect)),
      ],
    );
  }
}
