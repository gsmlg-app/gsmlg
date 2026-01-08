import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/home/home_screen.dart';
import 'package:gsmlg/screens/service/service_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

class Destinations {
  static List<NavigationDestination> navs(BuildContext context) =>
      <NavigationDestination>[
        NavigationDestination(
          key: const Key(HomeScreen.name),
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: context.l10n.navHome,
        ),
        NavigationDestination(
          key: const Key(ServiceScreen.name),
          icon: const Icon(Icons.miscellaneous_services_outlined),
          selectedIcon: const Icon(Icons.miscellaneous_services),
          label: context.l10n.navService,
        ),
        NavigationDestination(
          key: const Key(ToolboxScreen.name),
          icon: const Icon(Icons.build_outlined),
          selectedIcon: const Icon(Icons.build),
          label: context.l10n.navToolbox,
        ),
        NavigationDestination(
          key: const Key(SettingsScreen.name),
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: context.l10n.navSetting,
        ),
      ];

  static int indexOf(Key key, BuildContext context) {
    return navs(context).indexWhere((element) => element.key == key);
  }

  static void changeHandler(int idx, BuildContext context) {
    void _ = switch (idx) {
      0 => context.goNamed(HomeScreen.name),
      1 => context.goNamed(ServiceScreen.name),
      2 => context.goNamed(ToolboxScreen.name),
      3 => context.goNamed(SettingsScreen.name),
      int() => context.goNamed(HomeScreen.name),
    };
  }
}
