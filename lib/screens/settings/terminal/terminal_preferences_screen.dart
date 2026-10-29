import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:gsmlg/screens/settings/terminal/terminal_env_screen.dart';
import 'package:terminal_settings/terminal_settings.dart';

class TerminalPreferencesScreen extends StatelessWidget {
  static const name = 'Terminal Preferences';
  static const path = 'terminal/preferences';

  const TerminalPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) => AppAdaptiveScaffold(
    navigationRestoreInHeader: true,
    selectedIndex: Destinations.indexOf(
      const Key(SettingsScreen.name),
      context,
    ),
    destinations: Destinations.navs(context),
    onSelectedIndexChange: (index) =>
        Destinations.changeHandler(index, context),
    body: (context) => SafeArea(
      child: CustomScrollView(
        slivers: [
          DmNavigationHeader(
            builder: (context, header) => SliverAppBar(
              leading: header.leading,
              leadingWidth: header.leadingWidth,
              automaticallyImplyLeading: header.automaticallyImplyLeading,
              title: Text(context.l10n.terminalPreferencesTitle),
            ),
          ),
          SliverFillRemaining(
            child: SettingsList(
              sections: [
                SettingsSectionTerminal(
                  envSettingsScreenName: TerminalEnvScreen.name,
                  onEnvSettingsPressed: (context) =>
                      context.goNamed(TerminalEnvScreen.name),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
  );
}
