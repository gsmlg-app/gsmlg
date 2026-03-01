import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_theme/app_theme.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/accent_color_settings_screen.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/app_settings_screen.dart';
import 'package:gsmlg/screens/settings/appearance_settings_screen.dart';
import 'package:gsmlg/screens/settings/device/device_info_screen.dart';
import 'package:gsmlg/screens/settings/device/wifi_info_screen.dart';
import 'package:gsmlg/screens/settings/model_management_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:theme_bloc/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  static const name = 'Settings';
  static const path = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key(name), context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      destinations: Destinations.navs(context),
      body: (context) {
        final themeBloc = context.read<ThemeBloc>();

        return SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(title: Text(context.l10n.settingsTitle)),
              SliverFillRemaining(
                child: BlocBuilder<ThemeBloc, ThemeState>(
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
                                    return Text('$count account${count == 1 ? '' : 's'} configured');
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
                              title: const Text('AI Models'),
                              value: BlocBuilder<GemmaModelBloc,
                                  GemmaModelState>(
                                builder: (context, modelState) {
                                  final selectedId =
                                      modelState.selectedModelId;
                                  if (selectedId != null) {
                                    final info =
                                        GemmaModelInfo.findById(selectedId);
                                    if (info != null) {
                                      return Text(info.displayName);
                                    }
                                    return Text(selectedId);
                                  }
                                  final count =
                                      modelState.installedModels.length;
                                  return Text(
                                      '$count model${count == 1 ? '' : 's'} installed');
                                },
                              ),
                              onPressed: (context) {
                                context
                                    .goNamed(ModelManagementScreen.name);
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
                              value: Text(state.theme.name),
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
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    );
  }
}
