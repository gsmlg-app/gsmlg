import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_theme/duskmoon_theme.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:theme_bloc/theme_bloc.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  static const name = 'Appearance Settings';
  static const path = 'appearance';

  const AppearanceSettingsScreen({super.key});

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
              SliverAppBar(title: Text(context.l10n.appearance)),
              SliverFillRemaining(
                child: BlocBuilder<DmThemeBloc, DmThemeState>(
                  bloc: themeBloc,
                  builder: (context, state) {
                    return SettingsList(
                      sections: [
                        SettingsSection(
                          title: Text(context.l10n.appearance),
                          tiles: <SettingsTile>[
                            for (final mode in ThemeMode.values)
                              SettingsTile(
                                leading: mode.icon,
                                title: Text(mode.title),
                                trailing: state.themeMode == mode
                                    ? const Icon(Icons.check)
                                    : null,
                                onPressed: (context) {
                                  themeBloc.add(DmSetThemeMode(mode));
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
