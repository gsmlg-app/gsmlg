import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:gsmlg/destination.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:app_security/app_security.dart';

class SettingsSSHKey extends StatefulWidget {
  static const name = 'SSH Key Management';
  static const path = 'terminal/keys';

  static const String fullPath = '${SettingsScreen.path}/$path';

  const SettingsSSHKey({super.key});

  @override
  State<SettingsSSHKey> createState() => _SettingsSSHKeyState();
}

class _SettingsSSHKeyState extends State<SettingsSSHKey> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SshKeyBloc>().add(SshKeyLoad());
    });
  }

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
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            DmNavigationHeader(
              builder: (context, header) => SliverAppBar(
                leading: header.leading,
                leadingWidth: header.leadingWidth,
                automaticallyImplyLeading: header.automaticallyImplyLeading,
                title: Text(context.l10n.titleSSHKey),
                actions: getActions(context),
              ),
            ),
            BlocBuilder<SshKeyBloc, SshKeyState>(
              builder: (context, state) {
                return SliverFillRemaining(
                  child: SettingsList(sections: [buildSection(context, state)]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SettingsSection buildSection(BuildContext context, SshKeyState state) {
    if (state is SshKeyInitial) {
      return SettingsSection(
        title: Text(context.l10n.sshKey),
        tiles: <SettingsTile>[
          SettingsTile(
            title: const Text('...'),
            leading: const Icon(Icons.vpn_key),
          ),
        ],
      );
    }
    if (state is SshKeyError) {
      return SettingsSection(
        title: Text(context.l10n.sshKey),
        tiles: <SettingsTile>[
          SettingsTile(
            title: Text(
              'Error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            leading: const Icon(Icons.error),
            description: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.errorContainer,
              ),
              child: Column(
                children: [
                  Text(
                    state.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  ElevatedButton(
                    child: Text(context.l10n.reload),
                    onPressed: () {
                      context.read<SshKeyBloc>().add(SshKeyLoad());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    final sshKeys = (state as SshKeyLoaded).sshKeys;
    return sshKeys.isNotEmpty
        ? SettingsSection(
            title: Text(context.l10n.sshKey),
            tiles: <SettingsTile>[
              for (final sshKey in sshKeys)
                SettingsTile(
                  title: Text(sshKey.name ?? 'N/A'),
                  leading: const Icon(Icons.vpn_key),
                  onPressed: (c) {
                    showDmBottomSheetActionList(
                      showBackdrop: false,
                      context: c,
                      actions: [
                        DmBottomSheetAction(
                          title: Text(context.l10n.showPublicKey),
                          onTap: () async {
                            String content;
                            try {
                              final pem = await context
                                  .read<SshCredentialRepository>()
                                  .readPrivateKey(sshKey);
                              content = RsaKeyHelper().getSshPublicKey(pem);
                            } catch (error) {
                              content = error.toString();
                            }
                            if (!context.mounted) return;
                            showAdaptiveDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog.adaptive(
                                  title: Text(context.l10n.publicKey),
                                  content: SingleChildScrollView(
                                    child: SelectionArea(child: Text(content)),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(context.l10n.close),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: content),
                                        );
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Text(context.l10n.copy),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        DmBottomSheetAction(
                          title: Text(context.l10n.delete),
                          onTap: () {
                            showAdaptiveDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog.adaptive(
                                  title: Text(context.l10n.delete),
                                  content: Text(
                                    context.l10n.deleteSshKeyMessage,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(context.l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.read<SshKeyBloc>().add(
                                          SshKeyDelete(sshKey),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(context.l10n.delete),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        DmBottomSheetAction(
                          title: Text(context.l10n.cancel),
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
            ],
          )
        : SettingsSection(
            title: Text(context.l10n.sshKey),
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text(context.l10n.add),
                leading: const Icon(Icons.add),
                onPressed: (context) {
                  showSshKeyForm(context: context);
                },
              ),
            ],
          );
  }

  List<Widget> getActions(BuildContext context) {
    return [
      AppAdaptiveActionList(
        actions: [
          AppAdaptiveAction(
            icon: Icons.add,
            title: context.l10n.add,
            onPressed: () {
              showSshKeyForm(context: context);
            },
          ),
        ],
      ),
    ];
  }
}
