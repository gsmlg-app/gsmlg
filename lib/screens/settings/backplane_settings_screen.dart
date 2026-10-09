// ignore_for_file: depend_on_referenced_packages

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
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
                      SettingsSection(
                        title: Text(context.l10n.backplaneModels),
                        tiles: [
                          SettingsTile(
                            title: Text(context.l10n.backplaneLoadModels),
                            leading: state.modelsLoading
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.refresh),
                            description: Text(
                              state.modelsError == null
                                  ? (dirty
                                        ? context
                                              .l10n
                                              .backplaneSaveBeforeDiscovery
                                        : state.settings.models.isEmpty
                                        ? context.l10n.backplaneNoModels
                                        : state.settings.models.join(', '))
                                  : '${context.l10n.backplaneModelsLoadFailed}: ${state.modelsError}',
                            ),
                            onPressed: canDiscover && !state.modelsLoading
                                ? (_) => context
                                      .read<BackplaneSettingsBloc>()
                                      .add(const BackplaneLoadModels())
                                : null,
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(context.l10n.backplaneTools),
                        tiles: [
                          SettingsTile(
                            title: Text(context.l10n.backplaneRefreshTools),
                            leading: state.toolsLoading
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.refresh),
                            description: Text(
                              state.toolsError == null
                                  ? (dirty
                                        ? context
                                              .l10n
                                              .backplaneSaveBeforeDiscovery
                                        : state.settings.tools.isEmpty
                                        ? context.l10n.backplaneNoTools
                                        : state.settings.tools
                                              .map((tool) => tool['name'])
                                              .join(', '))
                                  : '${context.l10n.backplaneToolsRefreshFailed}: ${state.toolsError}',
                            ),
                            onPressed: canDiscover && !state.toolsLoading
                                ? (_) => context
                                      .read<BackplaneSettingsBloc>()
                                      .add(const BackplaneRefreshTools())
                                : null,
                          ),
                        ],
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
}
