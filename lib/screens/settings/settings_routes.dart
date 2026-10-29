import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/chat/chat_settings_screen.dart';
import 'package:gsmlg/screens/settings/accent_color_settings_screen.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/app_settings_screen.dart';
import 'package:gsmlg/screens/settings/appearance_settings_screen.dart';
import 'package:gsmlg/screens/settings/audio_settings_screen.dart';
import 'package:gsmlg/screens/settings/backplane_settings_screen.dart';
import 'package:gsmlg/screens/settings/device/activity_monitor_screen.dart';
import 'package:gsmlg/screens/settings/device/device_info_screen.dart';
import 'package:gsmlg/screens/settings/device/wifi_info_screen.dart';
import 'package:gsmlg/screens/settings/local_tools_settings_screen.dart';
import 'package:gsmlg/screens/settings/model_management_screen.dart';
import 'package:gsmlg/screens/settings/remote_model_settings_screen.dart';
import 'package:gsmlg/screens/settings/remote_tools_settings_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:gsmlg/screens/settings/terminal/host_management.dart';
import 'package:gsmlg/screens/settings/terminal/shell_profile_edit_screen.dart';
import 'package:gsmlg/screens/settings/terminal/shell_profile_screen.dart';
import 'package:gsmlg/screens/settings/terminal/ssh_key_management.dart';
import 'package:gsmlg/screens/settings/terminal/terminal_env_screen.dart';
import 'package:gsmlg/screens/settings/terminal/terminal_preferences_screen.dart';

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
    if (!kIsWeb) ...[
      GoRoute(
        name: TerminalPreferencesScreen.name,
        path: TerminalPreferencesScreen.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const TerminalPreferencesScreen(),
        ),
      ),
      GoRoute(
        name: TerminalEnvScreen.name,
        path: TerminalEnvScreen.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const TerminalEnvScreen(),
        ),
      ),
      GoRoute(
        name: SettingsHost.name,
        path: SettingsHost.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const SettingsHost(),
        ),
      ),
      GoRoute(
        name: SettingsSSHKey.name,
        path: SettingsSSHKey.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const SettingsSSHKey(),
        ),
      ),
      GoRoute(
        name: ShellProfileScreen.name,
        path: ShellProfileScreen.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const ShellProfileScreen(),
        ),
        routes: [
          GoRoute(
            name: ShellProfileEditScreen.name,
            path: ShellProfileEditScreen.path,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: ShellProfileEditScreen(
                profileId: int.tryParse(state.uri.queryParameters['id'] ?? ''),
              ),
            ),
          ),
        ],
      ),
    ],
    GoRoute(
      name: AudioSettingsScreen.name,
      path: AudioSettingsScreen.path,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: const AudioSettingsScreen(),
      ),
    ),
    GoRoute(
      name: BackplaneSettingsScreen.name,
      path: BackplaneSettingsScreen.path,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: const BackplaneSettingsScreen(),
      ),
    ),
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
      name: ChatAgentsSettingsScreen.name,
      path: ChatAgentsSettingsScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const ChatAgentsSettingsScreen(),
        );
      },
      routes: [
        GoRoute(
          name: ChatAgentSettingsScreen.name,
          path: ChatAgentSettingsScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: ChatAgentSettingsScreen(
                agentId: state.pathParameters['agentId']!,
              ),
            );
          },
        ),
      ],
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
      name: RemoteToolsSettingsScreen.name,
      path: RemoteToolsSettingsScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const RemoteToolsSettingsScreen(),
        );
      },
      routes: [
        GoRoute(
          name: RemoteToolSettingsScreen.name,
          path: RemoteToolSettingsScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: RemoteToolSettingsScreen(
                profileId: state.pathParameters['profileId']!,
              ),
            );
          },
        ),
      ],
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
      name: ActivityMonitorScreen.name,
      path: ActivityMonitorScreen.path,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: const ActivityMonitorScreen(),
      ),
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
