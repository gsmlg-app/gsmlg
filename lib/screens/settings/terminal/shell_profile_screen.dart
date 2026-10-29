import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:gsmlg/screens/settings/terminal/shell_profile_edit_screen.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:gsmlg/destination.dart';

/// Screen for managing shell profiles.
class ShellProfileScreen extends StatelessWidget {
  static const name = 'Shell Profiles';
  static const path = 'terminal/profiles';

  static const String fullPath = '${SettingsScreen.path}/$path';

  const ShellProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final bloc = context.read<ShellProfileBloc>();
      if (bloc.state is ShellProfileInitial) {
        bloc.add(const LoadShellProfiles());
      }
    });

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
                title: Text(context.l10n.shellProfilesTitle),
                actions: _getActions(context),
              ),
            ),
            BlocBuilder<ShellProfileBloc, ShellProfileState>(
              builder: (context, state) {
                return SliverFillRemaining(
                  child: SettingsList(
                    sections: [_buildSection(context, state)],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SettingsSection _buildSection(BuildContext context, ShellProfileState state) {
    if (state is ShellProfileInitial || state is ShellProfileLoading) {
      return SettingsSection(
        title: Text(context.l10n.shellProfilesTitle),
        tiles: <SettingsTile>[
          SettingsTile(
            title: const Text('Loading...'),
            leading: const CircularProgressIndicator.adaptive(),
          ),
        ],
      );
    }
    if (state is ShellProfileError) {
      return SettingsSection(
        title: Text(context.l10n.shellProfilesTitle),
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
                    child: const Text('Reload'),
                    onPressed: () {
                      context.read<ShellProfileBloc>().add(
                        const LoadShellProfiles(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    final profiles = (state as ShellProfileLoaded).profiles;
    return profiles.isNotEmpty
        ? SettingsSection(
            title: Text(context.l10n.shellProfilesTitle),
            tiles: <SettingsTile>[
              for (final profile in profiles)
                SettingsTile.navigation(
                  title: Text(profile.name),
                  leading: profile.isDefault
                      ? const Icon(Icons.star, color: Colors.amber)
                      : const Icon(Icons.person),
                  description: Text(_getProfileDescription(profile)),
                  onPressed: (c) {
                    _navigateToEditScreen(c, profile: profile);
                  },
                ),
            ],
          )
        : SettingsSection(
            title: Text(context.l10n.shellProfilesTitle),
            tiles: <SettingsTile>[
              SettingsTile(
                title: const Text('Add Profile'),
                leading: const Icon(Icons.add),
                onPressed: (context) {
                  _navigateToEditScreen(context);
                },
              ),
            ],
          );
  }

  String _getProfileDescription(ShellProfile profile) {
    final shellType = ShellType.fromValue(profile.shellType)?.name ?? 'sh';
    final parts = <String>[shellType];
    parts.add('${profile.fontSize.round()}px ${profile.fontFamily}');
    final cursor = CursorStyleType.fromValue(profile.cursorStyle);
    parts.add(cursor.name);
    if (profile.isDefault) {
      parts.add('default');
    }
    return parts.join(' | ');
  }

  void _navigateToEditScreen(BuildContext context, {ShellProfile? profile}) {
    context.goNamed(
      ShellProfileEditScreen.name,
      queryParameters: profile != null
          ? {'id': profile.id.toString()}
          : const {},
    );
  }

  List<Widget> _getActions(BuildContext context) {
    return [
      AppAdaptiveActionList(
        actions: [
          AppAdaptiveAction(
            icon: Icons.add,
            title: 'Add',
            onPressed: () {
              _navigateToEditScreen(context);
            },
          ),
        ],
      ),
    ];
  }
}
