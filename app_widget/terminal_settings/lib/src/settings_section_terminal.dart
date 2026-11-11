import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_locale/app_locale.dart';
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

        final optionKeyBehavior = state is TerminalSettingsLoaded
            ? state.optionKeyBehavior
            : kTerminalDefaultOptionKeyBehavior;

        final isMacOS =
            !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

        final isDesktop = !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.windows);

        final downloadMode = state is TerminalSettingsLoaded
            ? state.downloadMode
            : TerminalDownloadMode.saveToFolder;

        final downloadDirectory =
            state is TerminalSettingsLoaded ? state.downloadDirectory : null;

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
            if (isMacOS) _optionKeyBehaviorTile(context, optionKeyBehavior),
            if (isDesktop) _downloadModeTile(context, downloadMode),
            if (isDesktop) _downloadDirectoryTile(context, downloadDirectory),
          ],
        );
      },
    );
  }
}

SettingsTile _optionKeyBehaviorTile(
  BuildContext context,
  TerminalOptionKeyBehavior value,
) {
  return SettingsTile(
    leading: const Icon(Icons.keyboard_option_key),
    title: Text(context.l10n.optionKeyBehavior),
    description: Text(context.l10n.optionKeyBehaviorDescription),
    trailing: DropdownButton<TerminalOptionKeyBehavior>(
      key: const Key('optionKeyBehaviorDropdown'),
      value: value,
      underline: const SizedBox(),
      items: TerminalOptionKeyBehavior.values
          .map(
            (TerminalOptionKeyBehavior behavior) =>
                DropdownMenuItem<TerminalOptionKeyBehavior>(
              value: behavior,
              child: Text(_optionKeyBehaviorLabel(context, behavior)),
            ),
          )
          .toList(),
      onChanged: (TerminalOptionKeyBehavior? behavior) {
        if (behavior != null) {
          context.read<TerminalSettingsBloc>().add(
                TerminalSettingsUpdateOptionKeyBehavior(
                  optionKeyBehavior: behavior,
                ),
              );
        }
      },
    ),
  );
}

SettingsTile _downloadModeTile(
  BuildContext context,
  TerminalDownloadMode value,
) {
  return SettingsTile(
    leading: const Icon(Icons.download),
    title: Text(context.l10n.zmodemDownloads),
    trailing: DropdownButton<TerminalDownloadMode>(
      key: const Key('downloadModeDropdown'),
      value: value,
      underline: const SizedBox(),
      items: [
        DropdownMenuItem<TerminalDownloadMode>(
          value: TerminalDownloadMode.saveToFolder,
          child: Text(context.l10n.zmodemDownloadModeFolder),
        ),
        DropdownMenuItem<TerminalDownloadMode>(
          value: TerminalDownloadMode.ask,
          child: Text(context.l10n.zmodemDownloadModeAsk),
        ),
      ],
      onChanged: (TerminalDownloadMode? mode) {
        if (mode != null) {
          context.read<TerminalSettingsBloc>().add(
                TerminalSettingsUpdateDownloadMode(downloadMode: mode),
              );
        }
      },
    ),
  );
}

SettingsTile _downloadDirectoryTile(BuildContext context, String? directory) {
  final bloc = context.read<TerminalSettingsBloc>();
  return SettingsTile(
    key: const Key('downloadDirectoryTile'),
    leading: const Icon(Icons.folder_open),
    title: Text(context.l10n.zmodemDownloadFolder),
    description: Text(directory ?? context.l10n.zmodemSystemDownloads),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () async {
            final chosen = await FilePicker.getDirectoryPath(
              initialDirectory: directory,
            );
            if (chosen != null) {
              bloc.add(
                TerminalSettingsUpdateDownloadDirectory(
                  downloadDirectory: chosen,
                ),
              );
            }
          },
          child: Text(context.l10n.zmodemChooseFolder),
        ),
        if (directory != null)
          TextButton(
            onPressed: () => bloc.add(
              const TerminalSettingsUpdateDownloadDirectory(
                downloadDirectory: null,
              ),
            ),
            child: Text(context.l10n.zmodemReset),
          ),
      ],
    ),
  );
}

String _optionKeyBehaviorLabel(
  BuildContext context,
  TerminalOptionKeyBehavior behavior,
) {
  switch (behavior) {
    case TerminalOptionKeyBehavior.leftMeta:
      return context.l10n.optionKeyBehaviorLeftMeta;
    case TerminalOptionKeyBehavior.bothMeta:
      return context.l10n.optionKeyBehaviorBothMeta;
    case TerminalOptionKeyBehavior.normal:
      return context.l10n.optionKeyBehaviorNormal;
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
