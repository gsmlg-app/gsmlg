import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/src/plugin_tab.dart';
import 'package:terminal_tabs/src/ssh_host_key_dialog.dart';
import 'package:xterm/xterm.dart' show TerminalCursorType;

class DropdownContextMenu extends StatefulWidget {
  const DropdownContextMenu(this.tabs, {super.key});

  final Tabs tabs;

  @override
  DropdownContextMenuState createState() => DropdownContextMenuState();
}

class DropdownContextMenuState extends State<DropdownContextMenu>
    with ContextMenuStateMixin {
  Tabs get tabs => widget.tabs;

  @override
  void initState() {
    super.initState();
    // Load SSH hosts if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<SshHostBloc>().state;
      if (state is! SshHostLoaded) {
        context.read<SshHostBloc>().add(SshHostLoad());
      }
    });
  }

  TerminalPlugin _createTerminalPlugin(ShellProfile? profile) {
    return TerminalPlugin(
      profileFontSize: profile?.fontSize ?? 14.0,
      profileFontFamily: profile?.fontFamily ?? 'Source Code Pro',
      profileCursorType:
          TerminalCursorType.values[(profile?.cursorStyle ?? 0).clamp(
            0,
            TerminalCursorType.values.length - 1,
          )],
      scrollbackLines: profile?.scrollbackLines ?? 10000,
    );
  }

  void _openLocalTerminal(BuildContext context) {
    handlePressed(context, () {
      // Use default profile settings if available
      ShellProfile? profile;
      final profileState = context.read<ShellProfileBloc>().state;
      if (profileState is ShellProfileLoaded) {
        profile = profileState.defaultProfile;
      }

      final plugin = _createTerminalPlugin(profile);
      String? inheritedWorkingDirectory;
      final tabState = context.read<TerminalTabBloc>().state;
      if (profile?.inheritCurrentState == true &&
          tabState is TerminalTabLoaded &&
          tabState.activeTab is PluginTab) {
        inheritedWorkingDirectory =
            (tabState.activeTab as PluginTab).currentWorkingDirectory;
      }
      final initCommands = profile?.generateInitCommands(
        includeEnvExports: false,
      );
      final manager = PluginManager(
        createDefaultHostSpec(
          name: profile?.name,
          environment: profile?.parsedEnvironmentVariables,
          initCommands: (initCommands != null && initCommands.trim().isNotEmpty)
              ? initCommands
              : null,
          workingDirectory:
              inheritedWorkingDirectory ??
              ((profile?.workingDirectory.isNotEmpty ?? false)
                  ? profile!.workingDirectory
                  : null),
          shellCommand: profile?.parsedShellType.name,
        ),
      );
      final tabItem = PluginTab(plugin, manager, shellProfileId: profile?.id);
      context.read<TerminalTabBloc>().add(TerminalTabOpenTab(tabItem));
    });
  }

  Future<void> _openSSHTerminal(BuildContext context, SshHost host) async {
    // Capture context references before async gap
    final database = context.read<AppDatabase>();
    final terminalBloc = context.read<TerminalTabBloc>();
    final profileState = context.read<ShellProfileBloc>().state;
    final defaultProfile = profileState is ShellProfileLoaded
        ? profileState.defaultProfile
        : null;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final credentials = context.read<SshCredentialRepository>();
    final hostKeys = context.read<SshHostKeyStore>();
    final navigator = Navigator.of(context, rootNavigator: true);

    // Load SSH key if using key authentication
    SshKeyData? keyData;
    final identityType = SshIdentityType.fromValue(host.identityType);
    if (identityType == SshIdentityType.key && host.identityKeyId != null) {
      try {
        keyData = await _loadSshKeyDataWithDb(
          database,
          host.identityKeyId!,
          credentials,
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to load SSH key: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        return;
      }
    }

    if (!context.mounted) return;

    handlePressed(context, () {
      final plugin = _createTerminalPlugin(defaultProfile);
      final manager = PluginManager(
        SSHHostSpec(
          host,
          keyData: keyData,
          passwordProvider: () => credentials.readHostPassword(host),
          verifyHostKey: (type, fingerprint) => hostKeys.verify(
            host.hostname!,
            host.port!,
            type,
            fingerprint,
            onFirstUse: (key) => navigator.mounted
                ? showSshHostKeyConfirmation(navigator.context, key)
                : Future.value(false),
          ),
        ),
      );
      final tabItem = PluginTab(plugin, manager);
      terminalBloc.add(TerminalTabOpenTab(tabItem));
    });
  }

  /// Loads SSH key data from the database by key ID.
  Future<SshKeyData> _loadSshKeyDataWithDb(
    AppDatabase database,
    int keyId,
    SshCredentialRepository credentials,
  ) async {
    final key = await (database.select(
      database.sshKeys,
    )..where((t) => t.id.equals(keyId))).getSingleOrNull();

    if (key == null) {
      throw Exception('SSH key not found');
    }

    return SshKeyData(
      content: await credentials.readPrivateKey(key),
      passphrase: await credentials.readKeyPassphrase(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    return cardBuilder(context, [
      // Local terminal option
      buttonBuilder(
        context,
        ContextMenuButtonConfig(
          'Local',
          icon: const Icon(Icons.computer),
          iconHover: const Icon(Icons.computer_outlined),
          onPressed: () => _openLocalTerminal(context),
        ),
      ),

      // SSH hosts section
      BlocBuilder<SshHostBloc, SshHostState>(
        builder: (context, state) {
          if (state is! SshHostLoaded || state.sshHosts.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 8),
              ...state.sshHosts.map(
                (host) => buttonBuilder(
                  context,
                  ContextMenuButtonConfig(
                    host.host ?? host.hostname ?? 'SSH Host',
                    icon: const Icon(Icons.dns),
                    iconHover: const Icon(Icons.dns_outlined),
                    onPressed: () => _openSSHTerminal(context, host),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ]);
  }
}
