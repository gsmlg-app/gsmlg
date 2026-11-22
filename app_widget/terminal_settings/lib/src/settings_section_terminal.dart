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
  final void Function(BuildContext context)? onSessionSnapshotsPressed;

  const SettingsSectionTerminal({
    super.key,
    required this.envSettingsScreenName,
    required this.onEnvSettingsPressed,
    this.onShellProfilesPressed,
    this.onSessionSnapshotsPressed,
  }) : super(tiles: const []);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalSettingsBloc, TerminalSettingsState>(
      builder: (context, state) {
        final envCount = state is TerminalSettingsLoaded
            ? state.environmentVariables.length
            : 0;

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
            if (state is TerminalSettingsLoaded &&
                state.preferenceError != null)
              SettingsTile(
                leading: const Icon(Icons.error_outline),
                title: Text(context.l10n.sessionPreferenceError),
                trailing: TextButton(
                    onPressed: () => context
                        .read<TerminalSettingsBloc>()
                        .add(const TerminalSettingsLoad()),
                    child: Text(context.l10n.retry)),
              ),
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
            if (onSessionSnapshotsPressed != null)
              SettingsTile.navigation(
                leading: const Icon(Icons.bookmarks_outlined),
                title: Text(context.l10n.sessionSnapshots),
                onPressed: onSessionSnapshotsPressed,
              ),
            if (onShellProfilesPressed != null)
              _ShellProfilesTile(onPressed: onShellProfilesPressed!),
            if (isMacOS) _optionKeyBehaviorTile(context, optionKeyBehavior),
            SettingsTile(
              leading: const Icon(Icons.content_paste),
              title: Text(context.l10n.remoteClipboardAllow),
              description: Text(context.l10n.remoteClipboardDescription),
              trailing: Switch(
                key: const Key('remoteClipboardSwitch'),
                value: state is TerminalSettingsLoaded &&
                    state.allowRemoteClipboardWrites,
                onChanged: state is TerminalSettingsLoaded
                    ? (allowed) => context.read<TerminalSettingsBloc>().add(
                          TerminalSettingsUpdateRemoteClipboard(
                            allowed: allowed,
                          ),
                        )
                    : null,
              ),
            ),
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
