import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/secrethub_agent/secrethub_agent_config.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:secrethub_agent/secrethub_agent.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings for the embedded SecretHub mobile Agent.
///
/// Configures the Core URL, server trust and alias→path secret bindings. The
/// plugin does not yet expose `AgentConfig`/`start()`/`read()`, so connecting
/// and fetching are shown but disabled.
// TODO(upstream): gsmlg-app/secrethub_agent#1 — wire connect/fetch to
// SecretHubAgent(config:).start()/read() once the plugin implements them.
class SecretHubAgentSettingsScreen extends StatefulWidget {
  static const name = 'SecretHub Agent';
  static const path = 'secrethub-agent';

  const SecretHubAgentSettingsScreen({super.key, this.agent});

  /// Plugin entry point; injectable for tests.
  final SecretHubAgent? agent;

  @override
  State<SecretHubAgentSettingsScreen> createState() =>
      _SecretHubAgentSettingsScreenState();
}

class _BindingRow {
  _BindingRow(SecretHubBinding binding)
    : alias = TextEditingController(text: binding.alias),
      path = TextEditingController(text: binding.path),
      allowOffline = binding.allowOffline;

  final TextEditingController alias;
  final TextEditingController path;
  bool allowOffline;

  SecretHubBinding toBinding() => SecretHubBinding(
    alias: alias.text,
    path: path.text,
    allowOffline: allowOffline,
  );

  void dispose() {
    alias.dispose();
    path.dispose();
  }
}

class _SecretHubAgentSettingsScreenState
    extends State<SecretHubAgentSettingsScreen> {
  late final SharedPreferences _prefs;
  late final TextEditingController _coreUrl;
  late final TextEditingController _pinnedCa;
  late SecretHubTrust _trust;
  final List<_BindingRow> _rows = [];
  late final Future<String?> _platformVersion;
  List<SecretHubConfigError> _errors = const [];

  @override
  void initState() {
    super.initState();
    _prefs = context.read<SharedPreferences>();
    final config = SecretHubAgentConfig.load(_prefs);
    _coreUrl = TextEditingController(text: config.coreUrl);
    _pinnedCa = TextEditingController(text: config.pinnedCaPem ?? '');
    _trust = config.trust;
    _rows.addAll(config.bindings.map(_BindingRow.new));
    _platformVersion = _loadPlatformVersion();
  }

  Future<String?> _loadPlatformVersion() async {
    try {
      return await (widget.agent ?? SecretHubAgent()).getPlatformVersion();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _coreUrl.dispose();
    _pinnedCa.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  SecretHubAgentConfig get _config => SecretHubAgentConfig(
    coreUrl: _coreUrl.text,
    trust: _trust,
    pinnedCaPem: _trust == SecretHubTrust.pinnedCa ? _pinnedCa.text : null,
    bindings: [for (final row in _rows) row.toBinding()],
  );

  Future<void> _save() async {
    final config = _config;
    final errors = config.validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    await config.save(_prefs);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.secrethubSaved)));
  }

  String _errorText(SecretHubConfigError error) => switch (error) {
    SecretHubConfigError.invalidCoreUrl => context.l10n.secrethubErrorCoreUrl,
    SecretHubConfigError.invalidPinnedCa => context.l10n.secrethubErrorPinnedCa,
    SecretHubConfigError.incompleteBinding =>
      context.l10n.secrethubErrorBinding,
    SecretHubConfigError.duplicateAlias => context.l10n.secrethubErrorDuplicate,
  };

  @override
  Widget build(BuildContext context) => AppAdaptiveScaffold(
    navigationRestoreInHeader: true,
    selectedIndex: Destinations.indexOf(
      const Key(SettingsScreen.name),
      context,
    ),
    onSelectedIndexChange: (index) =>
        Destinations.changeHandler(index, context),
    destinations: Destinations.navs(context),
    body: (context) => SafeArea(
      child: CustomScrollView(
        slivers: [
          DmNavigationHeader(
            builder: (context, header) => SliverAppBar(
              leading: header.leading,
              leadingWidth: header.leadingWidth,
              automaticallyImplyLeading: header.automaticallyImplyLeading,
              title: Text(context.l10n.secrethubAgentTitle),
              actions: [
                TextButton(
                  key: const Key('secrethub-save'),
                  onPressed: _save,
                  child: Text(context.l10n.save),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(children: _form(context)),
          ),
        ],
      ),
    ),
    smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
  );

  List<Widget> _form(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return [
      if (_errors.isNotEmpty)
        Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final error in _errors)
                  Text(
                    _errorText(error),
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 8),
      TextField(
        key: const Key('secrethub-core-url'),
        controller: _coreUrl,
        keyboardType: TextInputType.url,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: l10n.secrethubCoreUrl,
          hintText: 'https://core.example.com:4665',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      Text(l10n.secrethubTrust, style: theme.textTheme.titleSmall),
      RadioGroup<SecretHubTrust>(
        groupValue: _trust,
        onChanged: (value) {
          if (value != null) setState(() => _trust = value);
        },
        child: Column(
          children: [
            RadioListTile<SecretHubTrust>(
              value: SecretHubTrust.system,
              title: Text(l10n.secrethubTrustSystem),
            ),
            RadioListTile<SecretHubTrust>(
              key: const Key('secrethub-trust-pinned'),
              value: SecretHubTrust.pinnedCa,
              title: Text(l10n.secrethubTrustPinned),
            ),
          ],
        ),
      ),
      if (_trust == SecretHubTrust.pinnedCa)
        TextField(
          key: const Key('secrethub-pinned-ca'),
          controller: _pinnedCa,
          minLines: 4,
          maxLines: 10,
          autocorrect: false,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: InputDecoration(
            labelText: l10n.secrethubPinnedCa,
            border: const OutlineInputBorder(),
          ),
        ),
      const SizedBox(height: 24),
      Text(l10n.secrethubSecrets, style: theme.textTheme.titleMedium),
      Text(l10n.secrethubSecretsHint, style: theme.textTheme.bodySmall),
      const SizedBox(height: 8),
      for (final (index, row) in _rows.indexed)
        _bindingCard(context, index, row),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          key: const Key('secrethub-add-secret'),
          onPressed: () => setState(
            () => _rows.add(
              _BindingRow(const SecretHubBinding(alias: '', path: '')),
            ),
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.secrethubAddSecret),
        ),
      ),
      const SizedBox(height: 24),
      Text(l10n.secrethubStatus, style: theme.textTheme.titleMedium),
      FutureBuilder<String?>(
        future: _platformVersion,
        builder: (context, snapshot) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.memory),
          title: Text(l10n.secrethubNativePlugin),
          subtitle: Text(
            snapshot.connectionState != ConnectionState.done
                ? '…'
                : snapshot.data ?? l10n.secrethubNativeUnavailable,
          ),
        ),
      ),
      // TODO(upstream): gsmlg-app/secrethub_agent#1 — enable once the plugin
      // provides start()/states/read().
      ListTile(
        key: const Key('secrethub-connect'),
        contentPadding: EdgeInsets.zero,
        enabled: false,
        leading: const Icon(Icons.link),
        title: Text(l10n.secrethubConnect),
        subtitle: Text(l10n.secrethubPendingPlugin),
      ),
      ListTile(
        key: const Key('secrethub-fetch'),
        contentPadding: EdgeInsets.zero,
        enabled: false,
        leading: const Icon(Icons.key),
        title: Text(l10n.secrethubFetch),
        subtitle: Text(l10n.secrethubPendingPlugin),
      ),
    ];
  }

  Widget _bindingCard(BuildContext context, int index, _BindingRow row) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 4),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: Key('secrethub-alias-$index'),
                    controller: row.alias,
                    autocorrect: false,
                    decoration: InputDecoration(labelText: l10n.secrethubAlias),
                  ),
                ),
                IconButton(
                  key: Key('secrethub-remove-$index'),
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() {
                    _rows.removeAt(index).dispose();
                  }),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextField(
                key: Key('secrethub-path-$index'),
                controller: row.path,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.secrethubPath,
                  hintText: 'prod.mobile.service_token',
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.only(right: 8),
              title: Text(l10n.secrethubAllowOffline),
              value: row.allowOffline,
              onChanged: (value) => setState(() => row.allowOffline = value),
            ),
          ],
        ),
      ),
    );
  }
}
