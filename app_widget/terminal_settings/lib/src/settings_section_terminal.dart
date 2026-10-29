import 'package:flutter/material.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';

/// Settings section for terminal configuration including environment variables.
class SettingsSectionTerminal extends AbstractSettingsSection {
  /// Screen name for terminal environment settings.
  final String envSettingsScreenName;

  /// Callback when environment settings tile is pressed.
  final void Function(BuildContext context) onEnvSettingsPressed;

  /// Callback when shell profiles tile is pressed (optional).
  final void Function(BuildContext context)? onShellProfilesPressed;

  const SettingsSectionTerminal({
    super.key,
    required this.envSettingsScreenName,
    required this.onEnvSettingsPressed,
    this.onShellProfilesPressed,
  }) : super(tiles: const []);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalSettingsBloc, TerminalSettingsState>(
      builder: (context, state) {
        final envCount = state is TerminalSettingsLoaded
            ? state.environmentVariables.length
            : 0;

        final maxShells = state is TerminalSettingsLoaded
            ? state.maxOpenShells
            : kTerminalDefaultMaxOpenShells;

        final restoreTabs =
            state is TerminalSettingsLoaded ? state.restoreTerminalTabs : false;

        return SettingsSection(
          title: const Text('Terminal'),
          tiles: <Widget>[
            SettingsTile.navigation(
              leading: const Icon(Icons.settings_applications),
              title: const Text('Environment Variables'),
              description: Text(
                envCount > 0
                    ? '$envCount custom variable${envCount > 1 ? 's' : ''}'
                    : 'No custom variables',
              ),
              onPressed: onEnvSettingsPressed,
            ),
            if (onShellProfilesPressed != null)
              _ShellProfilesTile(onPressed: onShellProfilesPressed!),
            SettingsTile(
              leading: const Icon(Icons.tab),
              title: const Text('Max Open Sessions'),
              description: Text(
                  '$maxShells concurrent session${maxShells > 1 ? 's' : ''}'),
              trailing: DropdownButton<int>(
                value: maxShells,
                underline: const SizedBox(),
                items: [1, 3, 5, 10, 15, 20, 30, 50]
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<TerminalSettingsBloc>().add(
                          TerminalSettingsUpdateMaxOpenShells(
                              maxOpenShells: value),
                        );
                  }
                },
              ),
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.restore_page),
              title: const Text('Restore Open Tabs'),
              description: const Text('Reopen terminal tabs after restart'),
              initialValue: restoreTabs,
              onToggle: (value) {
                context.read<TerminalSettingsBloc>().add(
                      TerminalSettingsUpdateRestoreTabs(
                        restoreTerminalTabs: value,
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}

/// A settings tile that shows shell profiles count with ShellProfileBloc.
class _ShellProfilesTile extends AbstractSettingsTile {
  const _ShellProfilesTile({
    required void Function(BuildContext context) onPressed,
  }) : super(
          title: const Text('Shell Profiles'),
          tileType: SettingsTileType.navigationTile,
          onPressed: onPressed,
        );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellProfileBloc, ShellProfileState>(
      builder: (context, state) {
        final profileCount =
            state is ShellProfileLoaded ? state.profiles.length : 0;
        final defaultProfile =
            state is ShellProfileLoaded ? state.defaultProfile : null;

        return SettingsTile.navigation(
          leading: const Icon(Icons.person),
          title: const Text('Shell Profiles'),
          description: Text(
            profileCount > 0
                ? '$profileCount profile${profileCount > 1 ? 's' : ''}${defaultProfile != null ? ' (default: ${defaultProfile.name})' : ''}'
                : 'No profiles configured',
          ),
          onPressed: onPressed,
        );
      },
    );
  }
}
