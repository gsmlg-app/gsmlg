// ignore_for_file: depend_on_referenced_packages

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_theme/duskmoon_theme.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/chat/chat_settings_screen.dart';
import 'package:gsmlg/screens/settings/accent_color_settings_screen.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/app_settings_screen.dart';
import 'package:gsmlg/screens/settings/appearance_settings_screen.dart';
import 'package:gsmlg/screens/settings/device/device_info_screen.dart';
import 'package:gsmlg/screens/settings/device/wifi_info_screen.dart';
import 'package:gsmlg/screens/settings/local_tools_settings_screen.dart';
import 'package:gsmlg/screens/settings/model_management_screen.dart';
import 'package:gsmlg/screens/settings/remote_model_settings_screen.dart';
import 'package:gsmlg/screens/settings/remote_tools_settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';

class SettingsScreen extends StatefulWidget {
  static const name = 'Settings';
  static const path = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatSettingsBloc>().add(const ChatSettingsLoad());
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      destinations: Destinations.navs(context),
      body: (context) {
        final themeBloc = context.read<DmThemeBloc>();

        return SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(title: Text(context.l10n.settingsTitle)),
              SliverFillRemaining(
                child: BlocBuilder<DmThemeBloc, DmThemeState>(
                  bloc: themeBloc,
                  builder: (context, state) {
                    return SettingsList(
                      sections: [
                        SettingsSection(
                          title: Text(context.l10n.account),
                          tiles: <SettingsTile>[
                            SettingsTile.navigation(
                              leading: const Icon(Icons.manage_accounts),
                              title: const Text('Service Accounts'),
                              value: BlocBuilder<AccountsBloc, AccountsState>(
                                builder: (context, accountsState) {
                                  if (accountsState is AccountsLoaded) {
                                    final count = accountsState.accounts.length;
                                    return Text(
                                      '$count account${count == 1 ? '' : 's'} configured',
                                    );
                                  }
                                  return const Text('Manage API accounts');
                                },
                              ),
                              onPressed: (context) {
                                context.goNamed(AccountScreen.name);
                              },
                            ),
                          ],
                        ),
                        SettingsSection(
                          title: const Text('AI Models'),
                          tiles: <SettingsTile>[
                            SettingsTile.navigation(
                              leading: const Icon(Icons.smart_toy),
                              title: const Text('Local Models'),
                              value: BlocBuilder<GemmaModelBloc, GemmaModelState>(
                                builder: (context, modelState) {
                                  final selectedId = modelState.selectedModelId;
                                  if (selectedId != null) {
                                    final info = GemmaModelInfo.findById(
                                      selectedId,
                                    );
                                    if (info != null) {
                                      return Text(info.displayName);
                                    }
                                    return Text(selectedId);
                                  }
                                  final count =
                                      modelState.installedModels.length;
                                  return Text(
                                    '$count model${count == 1 ? '' : 's'} installed',
                                  );
                                },
                              ),
                              onPressed: (context) {
                                context.goNamed(ModelManagementScreen.name);
                              },
                            ),
                            SettingsTile.navigation(
                              leading: const Icon(Icons.cloud_queue),
                              title: const Text('Remote Models'),
                              value:
                                  BlocBuilder<
                                    ChatSettingsBloc,
                                    ChatSettingsState
                                  >(
                                    builder: (context, settingsState) {
                                      final config = settingsState.config;
                                      if (!config.isRemoteConfigured) {
                                        return const Text('Not configured');
                                      }
                                      return Text(config.remoteModel);
                                    },
                                  ),
                              onPressed: (context) {
                                context.goNamed(RemoteModelSettingsScreen.name);
                              },
                            ),
                            SettingsTile.navigation(
                              leading: const Icon(Icons.people_alt_outlined),
                              title: const Text('Agents'),
                              value:
                                  BlocBuilder<
                                    ChatSettingsBloc,
                                    ChatSettingsState
                                  >(
                                    builder: (context, settingsState) {
                                      final count = settingsState.agents.length;
                                      return Text(
                                        '$count agent${count == 1 ? '' : 's'} configured',
                                      );
                                    },
                                  ),
                              onPressed: (context) {
                                context.goNamed(ChatAgentsSettingsScreen.name);
                              },
                            ),
                            SettingsTile.navigation(
                              leading: const Icon(Icons.build_circle_outlined),
                              title: const Text('Local Tools'),
                              value: Builder(
                                builder: (context) {
                                  final count = context
                                      .read<ToolExecutor>()
                                      .toolDefinitions
                                      .length;
                                  return Text(
                                    '$count tool${count == 1 ? '' : 's'} available',
                                  );
                                },
                              ),
                              onPressed: (context) {
                                context.goNamed(LocalToolsSettingsScreen.name);
                              },
                            ),
                            SettingsTile.navigation(
                              leading: const Icon(Icons.hub_outlined),
                              title: const Text('Remote Tools'),
                              value: Builder(
                                builder: (context) {
                                  final count =
                                      context
                                          .read<SharedPreferences>()
                                          .getStringList('remote_mcp_profiles')
                                          ?.length ??
                                      0;
                                  return Text(
                                    '$count service${count == 1 ? '' : 's'} configured',
                                  );
                                },
                              ),
                              onPressed: (context) {
                                context.goNamed(RemoteToolsSettingsScreen.name);
                              },
                            ),
                          ],
                        ),
                        SettingsSection(
                          title: Text('App Setting'),
                          tiles: <SettingsTile>[
                            SettingsTile.navigation(
                              leading: const Icon(Icons.api),
                              title: Text('App Setting'),
                              onPressed: (context) {
                                context.goNamed(AppSettingsScreen.name);
                              },
                            ),
                          ],
                        ),
                        SettingsSection(
                          title: Text(context.l10n.smenuTheme),
                          tiles: <SettingsTile>[
                            SettingsTile.navigation(
                              leading: const Icon(Icons.brightness_medium),
                              title: Text(context.l10n.appearance),
                              value: state.themeMode.icon,
                              onPressed: (context) {
                                context.goNamed(AppearanceSettingsScreen.name);
                              },
                            ),
                            SettingsTile.navigation(
                              leading: const Icon(Icons.palette),
                              title: Text(context.l10n.accentColor),
                              value: Text(state.themeName),
                              onPressed: (context) {
                                context.goNamed(AccentColorSettingsScreen.name);
                              },
                            ),
                          ],
                        ),
                        SettingsSection(
                          title: Text('Device'),
                          tiles: <SettingsTile>[
                            SettingsTile.navigation(
                              leading: const Icon(Icons.devices_rounded),
                              title: Text(context.l10n.deviceInfo),
                              onPressed: (context) {
                                context.goNamed(DeviceInfoScreen.name);
                              },
                            ),
                            SettingsTile.navigation(
                              leading: const Icon(Icons.wifi_sharp),
                              title: Text(context.l10n.wifiInfo),
                              onPressed: (context) {
                                context.goNamed(WifiInfoScreen.name);
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }
}
