import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:vnc_host_bloc/vnc_host_bloc.dart';

/// Mode for [VncHostFormDialog].
enum VncHostFormMode { quickConnect, add, edit }

/// Typed form result returned by [VncHostFormDialog].
@immutable
class VncHostFormResult {
  const VncHostFormResult({
    required this.name,
    required this.host,
    required this.port,
    required this.authType,
    this.username,
    this.password,
    this.clearPassword = false,
    this.sshHostId,
    this.viewOnly = false,
  });

  final String name;
  final String host;
  final int port;
  final VncHostAuthType authType;
  final String? username;
  final String? password;
  final bool clearPassword;
  final int? sshHostId;
  final bool viewOnly;
}

/// Dialog for quick-connecting to a VNC host or adding/editing a saved host.
class VncHostFormDialog extends StatefulWidget {
  const VncHostFormDialog({
    super.key,
    required this.mode,
    this.initialHost,
    this.prefillName,
    this.prefillHost,
    this.prefillPort,
    this.prefillAuthType,
    this.sshHosts = const [],
  });

  final VncHostFormMode mode;
  final VncHost? initialHost;
  final String? prefillName;
  final String? prefillHost;
  final int? prefillPort;
  final VncHostAuthType? prefillAuthType;
  final List<SshHost> sshHosts;

  static Future<VncHostFormResult?> show(
    BuildContext context, {
    required VncHostFormMode mode,
    VncHost? initialHost,
    String? prefillName,
    String? prefillHost,
    int? prefillPort,
    VncHostAuthType? prefillAuthType,
    List<SshHost> sshHosts = const [],
  }) {
    return showDialog<VncHostFormResult>(
      context: context,
      builder: (_) => VncHostFormDialog(
        mode: mode,
        initialHost: initialHost,
        prefillName: prefillName,
        prefillHost: prefillHost,
        prefillPort: prefillPort,
        prefillAuthType: prefillAuthType,
        sshHosts: sshHosts,
      ),
    );
  }

  @override
  State<VncHostFormDialog> createState() => _VncHostFormDialogState();
}

class _VncHostFormDialogState extends State<VncHostFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  final _passwordController = TextEditingController();

  late VncHostAuthType _authType;
  int? _sshHostId;
  late bool _viewOnly;
  bool _obscurePassword = true;
  bool _clearPassword = false;

  bool get _hasExistingPassword =>
      widget.mode == VncHostFormMode.edit &&
      widget.initialHost?.passwordRef != null;

  bool get _showNameField => widget.mode != VncHostFormMode.quickConnect;

  bool get _showUsernameField =>
      _authType == VncHostAuthType.auto ||
      _authType == VncHostAuthType.appleArd;

  bool get _showPasswordField => _authType != VncHostAuthType.none;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialHost;
    _nameController = TextEditingController(
      text: initial?.name ?? widget.prefillName ?? '',
    );
    _hostController = TextEditingController(
      text: initial?.host ?? widget.prefillHost ?? '',
    );
    _portController = TextEditingController(
      text: '${initial?.port ?? widget.prefillPort ?? 5900}',
    );
    _usernameController = TextEditingController(text: initial?.username ?? '');
    _authType = initial != null
        ? VncHostAuthType.fromValue(initial.authType)
        : (widget.prefillAuthType ?? VncHostAuthType.auto);

    final initialSshId = initial?.sshHostId;
    final hasMatchingSshHost =
        initialSshId != null &&
        widget.sshHosts.any((h) => h.id == initialSshId);
    _sshHostId = hasMatchingSshHost ? initialSshId : null;
    _viewOnly = initial?.viewOnly ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _whitespace = RegExp(r'\s');

  bool _isValidIpv6Literal(String value) {
    final percentIdx = value.indexOf('%');
    final addressPart = percentIdx >= 0
        ? value.substring(0, percentIdx)
        : value;
    if (percentIdx >= 0) {
      final zone = value.substring(percentIdx + 1);
      if (zone.isEmpty || zone.contains(':')) {
        return false;
      }
    }
    try {
      Uri.parseIPv6Address(addressPart);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// Strictly parses a host field supporting `hostname`, `ipv4`, bare `ipv6`,
  /// `host:port`, and `[ipv6]:port`, returning a validation error on malformed
  /// inline port or bracket syntax.
  ({String? host, int? port, String? error}) _parseHostAndPort(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return (host: null, port: null, error: 'required');
    }
    if (_whitespace.hasMatch(trimmed)) {
      return (host: null, port: null, error: 'Invalid host');
    }

    if (trimmed.contains('[') || trimmed.contains(']')) {
      final openIdx = trimmed.indexOf('[');
      final closeIdx = trimmed.indexOf(']');
      final hasSingleBrackets =
          openIdx == 0 &&
          closeIdx > 1 &&
          trimmed.lastIndexOf('[') == openIdx &&
          trimmed.lastIndexOf(']') == closeIdx;
      if (!hasSingleBrackets) {
        return (host: null, port: null, error: 'Invalid bracketed host');
      }
      final hostPart = trimmed.substring(1, closeIdx);
      if (hostPart.isEmpty ||
          (hostPart.contains(':') && !_isValidIpv6Literal(hostPart))) {
        return (host: null, port: null, error: 'Invalid IPv6 host');
      }
      final rest = trimmed.substring(closeIdx + 1);
      if (rest.isEmpty) {
        return (host: hostPart, port: null, error: null);
      }
      if (!rest.startsWith(':')) {
        return (host: null, port: null, error: 'Invalid host:port syntax');
      }
      final portPart = rest.substring(1);
      if (!_digitsOnly.hasMatch(portPart)) {
        return (host: null, port: null, error: 'Port must be 1-65535');
      }
      final parsedPort = int.tryParse(portPart);
      if (parsedPort == null || parsedPort < 1 || parsedPort > 65535) {
        return (host: null, port: null, error: 'Port must be 1-65535');
      }
      return (host: hostPart, port: parsedPort, error: null);
    }

    final firstColon = trimmed.indexOf(':');
    if (firstColon == -1) {
      return (host: trimmed, port: null, error: null);
    }

    final lastColon = trimmed.lastIndexOf(':');
    if (firstColon == lastColon) {
      final hostPart = trimmed.substring(0, firstColon);
      final portPart = trimmed.substring(firstColon + 1);
      if (hostPart.isEmpty) {
        return (host: null, port: null, error: 'Host is required before port');
      }
      if (!_digitsOnly.hasMatch(portPart)) {
        return (host: null, port: null, error: 'Port must be 1-65535');
      }
      final parsedPort = int.tryParse(portPart);
      if (parsedPort == null || parsedPort < 1 || parsedPort > 65535) {
        return (host: null, port: null, error: 'Port must be 1-65535');
      }
      return (host: hostPart, port: parsedPort, error: null);
    }

    // Multiple colons without brackets: only valid as a bare IPv6 literal.
    if (_isValidIpv6Literal(trimmed)) {
      return (host: trimmed, port: null, error: null);
    }
    return (host: null, port: null, error: 'Invalid host or IPv6 address');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parsed = _parseHostAndPort(_hostController.text);
    final parsedHost = parsed.host;
    if (parsed.error != null || parsedHost == null) {
      return;
    }
    final fieldPort = int.tryParse(_portController.text.trim()) ?? 5900;
    final effectivePort = parsed.port ?? fieldPort;
    final effectiveName = _showNameField
        ? _nameController.text.trim()
        : '$parsedHost:$effectivePort';

    final usernameText = _usernameController.text.trim();
    final effectiveUsername = _showUsernameField && usernameText.isNotEmpty
        ? usernameText
        : null;

    final rawPassword = _passwordController.text;
    final shouldClearPassword =
        widget.mode == VncHostFormMode.edit &&
        ((_hasExistingPassword && _clearPassword) ||
            (_hasExistingPassword && _authType == VncHostAuthType.none));
    final effectivePassword =
        (!_showPasswordField || shouldClearPassword || rawPassword.isEmpty)
        ? null
        : rawPassword;

    Navigator.of(context).pop(
      VncHostFormResult(
        name: effectiveName,
        host: parsedHost,
        port: effectivePort,
        authType: _authType,
        username: effectiveUsername,
        password: effectivePassword,
        clearPassword: shouldClearPassword,
        sshHostId: _sshHostId,
        viewOnly: _viewOnly,
      ),
    );
  }

  String _authTypeLabel(BuildContext context, VncHostAuthType type) {
    final l10n = context.l10n;
    return switch (type) {
      VncHostAuthType.auto => l10n.vncAuthAuto,
      VncHostAuthType.appleArd => l10n.vncAuthAppleArd,
      VncHostAuthType.vncPassword => l10n.vncAuthPassword,
      VncHostAuthType.none => l10n.vncAuthNone,
    };
  }

  String _sshHostLabel(SshHost host) {
    final alias = host.host?.trim();
    final hostname = host.hostname?.trim();
    final user = host.username?.trim();
    final port = host.port ?? 22;
    final address = (hostname != null && hostname.isNotEmpty)
        ? hostname
        : (alias ?? '');
    final endpoint = user != null && user.isNotEmpty
        ? '$user@$address:$port'
        : '$address:$port';
    if (alias != null && alias.isNotEmpty && alias != address) {
      return '$alias ($endpoint)';
    }
    return endpoint;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (widget.mode) {
      VncHostFormMode.quickConnect => l10n.vncQuickConnect,
      VncHostFormMode.add => l10n.vncAddHost,
      VncHostFormMode.edit => l10n.vncEditHost,
    };
    final submitLabel = widget.mode == VncHostFormMode.quickConnect
        ? l10n.vncConnect
        : l10n.vncSaveHost;

    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showNameField) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.vncNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    autofocus: widget.mode == VncHostFormMode.add,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '${l10n.vncNameLabel} is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _hostController,
                        decoration: InputDecoration(
                          labelText: l10n.vncHostLabel,
                          hintText: '192.168.1.10',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofocus: widget.mode == VncHostFormMode.quickConnect,
                        validator: (value) {
                          final parsed = _parseHostAndPort(value ?? '');
                          if (parsed.error == 'required') {
                            return '${l10n.vncHostLabel} is required';
                          }
                          if (parsed.error != null) {
                            return parsed.error;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _portController,
                        decoration: InputDecoration(
                          labelText: l10n.vncPortLabel,
                          hintText: '5900',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          final parsed = _parseHostAndPort(
                            _hostController.text,
                          );
                          if (parsed.error == null && parsed.port != null) {
                            return null;
                          }
                          final text = value?.trim() ?? '';
                          final port = int.tryParse(text);
                          if (port == null || port < 1 || port > 65535) {
                            return '1-65535';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<VncHostAuthType>(
                  initialValue: _authType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.vncAuthTypeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final type in const [
                      VncHostAuthType.auto,
                      VncHostAuthType.appleArd,
                      VncHostAuthType.vncPassword,
                      VncHostAuthType.none,
                    ])
                      DropdownMenuItem(
                        value: type,
                        child: Text(_authTypeLabel(context, type)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _authType = value;
                      if (_authType == VncHostAuthType.none) {
                        _passwordController.clear();
                      }
                    });
                  },
                ),
                if (_showUsernameField) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.vncUsernameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                ],
                if (_showPasswordField) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_clearPassword,
                    decoration: InputDecoration(
                      labelText: l10n.vncPasswordLabel,
                      hintText: _hasExistingPassword
                          ? l10n.vncPasswordKeepHint
                          : null,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: _clearPassword
                            ? null
                            : () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_hasExistingPassword)
                    CheckboxListTile(
                      value: _clearPassword,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(l10n.vncClearPassword),
                      onChanged: (checked) {
                        setState(() {
                          _clearPassword = checked ?? false;
                          if (_clearPassword) {
                            _passwordController.clear();
                          }
                        });
                      },
                    ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _sshHostId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.vncSshTunnelLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.vncSshTunnelNone),
                    ),
                    for (final sshHost in widget.sshHosts)
                      DropdownMenuItem<int?>(
                        value: sshHost.id,
                        child: Text(
                          _sshHostLabel(sshHost),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _sshHostId = value),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _viewOnly,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.vncViewOnlyLabel),
                  onChanged: (value) => setState(() => _viewOnly = value),
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
        FilledButton(onPressed: _submit, child: Text(submitLabel)),
      ],
    );
  }
}
