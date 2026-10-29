import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';

class TerminalEnvScreen extends StatelessWidget {
  static const name = 'Terminal Environment';
  static const path = 'terminal/environment';

  const TerminalEnvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      destinations: Destinations.navs(context),
      body: (context) => SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            DmNavigationHeader(
              builder: (context, header) => SliverAppBar(
                leading: header.leading,
                leadingWidth: header.leadingWidth,
                automaticallyImplyLeading: header.automaticallyImplyLeading,
                title: Text(context.l10n.terminalEnvironmentTitle),
              ),
            ),
            const SliverFillRemaining(child: EnvSettingsList()),
          ],
        ),
      ),
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }
}
