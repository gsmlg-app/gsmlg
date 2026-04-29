import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/settings/accent_color_settings_screen.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/app_settings_screen.dart';
import 'package:gsmlg/screens/settings/appearance_settings_screen.dart';
import 'package:gsmlg/screens/settings/device/device_info_screen.dart';
import 'package:gsmlg/screens/settings/device/wifi_info_screen.dart';
import 'package:gsmlg/screens/settings/local_tools_settings_screen.dart';
import 'package:gsmlg/screens/settings/model_management_screen.dart';
import 'package:gsmlg/screens/settings/remote_model_settings_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';

GoRoute settingsRoutes() => GoRoute(
  name: SettingsScreen.name,
  path: SettingsScreen.path,
  pageBuilder: (context, state) {
    return NoTransitionPage<void>(
      key: state.pageKey,
      restorationId: state.pageKey.value,
      child: const SettingsScreen(),
    );
  },
  routes: [
    GoRoute(
      name: AppSettingsScreen.name,
      path: AppSettingsScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const AppSettingsScreen(),
        );
      },
    ),
    GoRoute(
      name: AccountScreen.name,
      path: AccountScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const AccountScreen(),
        );
      },
    ),
    GoRoute(
      name: ModelManagementScreen.name,
      path: ModelManagementScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const ModelManagementScreen(),
        );
      },
    ),
    GoRoute(
      name: RemoteModelSettingsScreen.name,
      path: RemoteModelSettingsScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const RemoteModelSettingsScreen(),
        );
      },
    ),
    GoRoute(
      name: LocalToolsSettingsScreen.name,
      path: LocalToolsSettingsScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const LocalToolsSettingsScreen(),
        );
      },
    ),
    GoRoute(
      name: AppearanceSettingsScreen.name,
      path: AppearanceSettingsScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const AppearanceSettingsScreen(),
        );
      },
    ),
    GoRoute(
      name: AccentColorSettingsScreen.name,
      path: AccentColorSettingsScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const AccentColorSettingsScreen(),
        );
      },
    ),
    GoRoute(
      name: DeviceInfoScreen.name,
      path: DeviceInfoScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const DeviceInfoScreen(),
        );
      },
    ),
    GoRoute(
      name: WifiInfoScreen.name,
      path: WifiInfoScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const WifiInfoScreen(),
        );
      },
    ),
  ],
);
