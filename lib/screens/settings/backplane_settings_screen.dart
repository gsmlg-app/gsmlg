// ignore_for_file: depend_on_referenced_packages

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';

class BackplaneSettingsScreen extends StatefulWidget {
  static const name = 'Backplane';
  static const path = 'backplane';

  const BackplaneSettingsScreen({super.key});

  @override
  State<BackplaneSettingsScreen> createState() =>
      _BackplaneSettingsScreenState();
}

class _BackplaneSettingsScreenState extends State<BackplaneSettingsScreen> {
  late final TextEditingController _url;
  int? _accountId;
  RemoteLlmApiType _apiType = RemoteLlmApiType.openAiResponses;
  bool _mcpEnabled = false;
  bool _modelsExpanded = false;
  bool _toolsExpanded = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<BackplaneSettingsBloc>().state.settings;
    _url = TextEditingController(text: settings.serviceUrl)
      ..addListener(_refresh);
    _accountId = settings.accountId;
    _apiType = settings.apiType;
    _mcpEnabled = settings.mcpEnabled;
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _url.removeListener(_refresh);
    _url.dispose();
    super.dispose();
  }

  bool _dirty(BackplaneSettings settings) =>
      _url.text.trim() != settings.serviceUrl ||
      _accountId != settings.accountId ||
      _apiType != settings.apiType ||
      _mcpEnabled != settings.mcpEnabled;

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (index) =>
          Destinations.changeHandler(index, context),
      destinations: Destinations.navs(context),
      body: (context) => SafeArea(
        child: BlocBuilder<BackplaneSettingsBloc, BackplaneSettingsState>(
          builder: (context, state) {
            final accountsState = context.watch<AccountsBloc>().state;
            final accounts = accountsState is AccountsLoaded
                ? accountsState.accounts
                : const <ServiceAccountTableData>[];
            final selectedAccountExists =
                _accountId == null ||
                accounts.any((account) => account.id == _accountId);
            final selectedAccountHasSecret =
                accountsState is AccountsLoaded &&
                _accountId != null &&
                !accountsState.missingSecretAccountIds.contains(_accountId) &&
                selectedAccountExists;
            final dirty = _dirty(state.settings);
            final canDiscover = !dirty && selectedAccountHasSecret;
            final urlError = BackplaneSettings.validateUrl(_url.text);

            return CustomScrollView(
              slivers: [
                DmNavigationHeader(
                  builder: (context, header) => SliverAppBar(
                    leading: header.leading,
                    leadingWidth: header.leadingWidth,
                    automaticallyImplyLeading: header.automaticallyImplyLeading,
                    title: Text(context.l10n.backplaneTitle),
                  ),
                ),
                SliverFillRemaining(
                  child: SettingsList(
                    sections: [
                      SettingsSection(
                        title: Text(context.l10n.backplaneTitle),
                        tiles: [
                          SettingsTile(
                            title: Text(context.l10n.backplaneServiceUrl),
                            description: TextField(
                              controller: _url,
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                labelText: context.l10n.backplaneServiceUrl,
                                errorText: urlError == null
                                    ? null
                                    : context.l10n.backplaneInvalidUrl,
                              ),
                            ),
                          ),
                          SettingsTile(
                            title: Text(context.l10n.backplaneAccount),
                            description: DropdownButton<int?>(
                              value: selectedAccountExists ? _accountId : null,
                              isExpanded: true,
                              hint: Text(context.l10n.backplaneSelectAccount),
                              items: [
                                DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text(
                                    context.l10n.backplaneSelectAccount,
                                  ),
                                ),
                                for (final account in accounts)
                                  DropdownMenuItem<int?>(
                                    value: account.id,
                                    child: Text(account.name),
                                  ),
                              ],
                              onChanged: (id) =>
                                  setState(() => _accountId = id),
                            ),
                          ),
                          if (!selectedAccountExists ||
                              (_accountId != null && !selectedAccountHasSecret))
                            SettingsTile(
                              title: Text(context.l10n.backplaneMissingAccount),
                            ),
                          SettingsTile.navigation(
                            title: Text(context.l10n.backplaneManageAccounts),
                            onPressed: (_) =>
                                context.goNamed(AccountScreen.name),
                          ),
                          SettingsTile(
                            title: Text(context.l10n.backplaneProtocol),
                            description: DropdownButton<RemoteLlmApiType>(
                              value: _apiType,
                              items: [
                                DropdownMenuItem(
                                  value: RemoteLlmApiType.openAiResponses,
                                  child: Text(context.l10n.backplaneResponses),
                                ),
                                DropdownMenuItem(
                                  value: RemoteLlmApiType.openAiChatCompletions,
                                  child: Text(
                                    context.l10n.backplaneCompletions,
                                  ),
                                ),
                              ],
                              onChanged: (value) => setState(() {
                                if (value != null) _apiType = value;
                              }),
                            ),
                          ),
                          SettingsTile.switchTile(
                            title: Text(context.l10n.backplaneMcpEnabled),
                            initialValue: _mcpEnabled,
                            onToggle: (value) =>
                                setState(() => _mcpEnabled = value),
                          ),
                          SettingsTile(
                            title: Text(context.l10n.backplaneSave),
                            description: state.saveError == null
                                ? null
                                : Text(context.l10n.backplaneInvalidUrl),
                            onPressed: urlError == null
                                ? (_) {
                                    context.read<BackplaneSettingsBloc>().add(
                                      BackplaneSave(
                                        serviceUrl: _url.text,
                                        accountId: _accountId,
                                        apiType: _apiType,
                                        mcpEnabled: _mcpEnabled,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                      _buildDiscoverySection(
                        context: context,
                        sectionTitle: context.l10n.backplaneModels,
                        actionTitle: context.l10n.backplaneLoadModels,
                        loading: state.modelsLoading,
                        error: state.modelsError,
                        errorPrefix: context.l10n.backplaneModelsLoadFailed,
                        emptyText: context.l10n.backplaneNoModels,
                        dirty: dirty,
                        canDiscover: canDiscover,
                        items: state.settings.models,
                        expanded: _modelsExpanded,
                        onToggleExpanded: () =>
                            setState(() => _modelsExpanded = !_modelsExpanded),
                        onDiscover: () => context
                            .read<BackplaneSettingsBloc>()
                            .add(const BackplaneLoadModels()),
                      ),
                      _buildDiscoverySection(
                        context: context,
                        sectionTitle: context.l10n.backplaneTools,
                        actionTitle: context.l10n.backplaneRefreshTools,
                        loading: state.toolsLoading,
                        error: state.toolsError,
                        errorPrefix: context.l10n.backplaneToolsRefreshFailed,
                        emptyText: context.l10n.backplaneNoTools,
                        dirty: dirty,
                        canDiscover: canDiscover,
                        items: [
                          for (final tool in state.settings.tools)
                            if (tool['name']?.toString().isNotEmpty ?? false)
                              tool['name'].toString(),
                        ],
                        expanded: _toolsExpanded,
                        onToggleExpanded: () =>
                            setState(() => _toolsExpanded = !_toolsExpanded),
                        onDiscover: () => context
                            .read<BackplaneSettingsBloc>()
                            .add(const BackplaneRefreshTools()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }

  SettingsSection _buildDiscoverySection({
    required BuildContext context,
    required String sectionTitle,
    required String actionTitle,
    required bool loading,
    required String? error,
    required String errorPrefix,
    required String emptyText,
    required bool dirty,
    required bool canDiscover,
    required List<String> items,
    required bool expanded,
    required VoidCallback onToggleExpanded,
    required VoidCallback onDiscover,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasItems = error == null && !dirty && items.isNotEmpty;

    Widget? description;
    if (error != null) {
      description = Text(
        '$errorPrefix: $error',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colorScheme.error),
      );
    } else if (dirty) {
      description = Text(
        context.l10n.backplaneSaveBeforeDiscovery,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else if (items.isEmpty) {
      description = Text(
        emptyText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return SettingsSection(
      title: Text(sectionTitle),
      tiles: [
        SettingsTile(
          title: Text(actionTitle),
          leading: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          value: hasItems ? Text('${items.length}') : null,
          description: description,
          onPressed: canDiscover && !loading ? (_) => onDiscover() : null,
        ),
        if (hasItems)
          CustomSettingsTile(
            child: _DiscoveredItemsTile(
              items: items,
              expanded: expanded,
              onToggle: onToggleExpanded,
            ),
          ),
      ],
    );
  }
}

class _DiscoveredItemsTile extends StatelessWidget {
  const _DiscoveredItemsTile({
    required this.items,
    required this.expanded,
    required this.onToggle,
  });

  final List<String> items;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtleStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    items.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: subtleStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in items)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 260),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.6,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      child: Text(
                        item,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
