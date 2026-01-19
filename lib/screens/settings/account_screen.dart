import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:app_locale/app_locale.dart';
import 'package:auth_bloc/auth_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_bloc/github_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/app/splash_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:settings_ui/settings_ui.dart';

class AccountScreen extends StatelessWidget {
  static const name = 'Account';
  static const path = 'account';

  const AccountScreen({super.key});

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
        return SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(title: Text(context.l10n.account)),
              SliverFillRemaining(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    return BlocBuilder<GitHubBloc, GitHubState>(
                      builder: (context, githubState) {
                        return SettingsList(
                          sections: [
                            SettingsSection(
                              title: Text(context.l10n.account),
                              tiles: <SettingsTile>[
                                SettingsTile(
                                  leading: const Icon(Icons.person),
                                  title: const Text('Username'),
                                  value: Text(
                                    (authState is AuthSuccess)
                                        ? authState.user['username'] ?? 'Unknown'
                                        : 'Not signed in',
                                  ),
                                ),
                                SettingsTile(
                                  leading: const Icon(Icons.email),
                                  title: const Text('Email'),
                                  value: Text(
                                    (authState is AuthSuccess)
                                        ? authState.user['email'] ?? 'N/A'
                                        : 'N/A',
                                  ),
                                ),
                              ],
                            ),
                            _buildGitHubSection(context, githubState),
                            SettingsSection(
                              title: const Text('Actions'),
                              tiles: <SettingsTile>[
                                SettingsTile(
                                  leading: Icon(
                                    Icons.logout,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  title: Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  onPressed: (context) {
                                    _showSignOutDialog(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    );
  }

  SettingsSection _buildGitHubSection(BuildContext context, GitHubState state) {
    if (state is GitHubLoading) {
      return SettingsSection(
        title: const Text('GitHub'),
        tiles: [
          SettingsTile(
            leading: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: const Text('Loading...'),
          ),
        ],
      );
    }

    if (state is GitHubConnected) {
      final user = state.user;
      return SettingsSection(
        title: const Text('GitHub'),
        tiles: [
          SettingsTile(
            leading: user.avatarUrl != null
                ? CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(user.avatarUrl!),
                  )
                : const Icon(Icons.account_circle),
            title: Text(user.displayName),
            value: Text('@${user.login}'),
          ),
          if (user.email != null)
            SettingsTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              value: Text(user.email!),
            ),
          if (user.publicRepos != null)
            SettingsTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Public Repos'),
              value: Text('${user.publicRepos}'),
            ),
          if (user.followers != null)
            SettingsTile(
              leading: const Icon(Icons.people_outlined),
              title: const Text('Followers'),
              value: Text('${user.followers}'),
            ),
          SettingsTile(
            leading: Icon(
              Icons.link_off,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Disconnect GitHub',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: (context) => _showDisconnectGitHubDialog(context),
          ),
        ],
      );
    }

    if (state is GitHubError) {
      return SettingsSection(
        title: const Text('GitHub'),
        tiles: [
          SettingsTile(
            leading: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            title: const Text('Connection Error'),
            value: Text(
              state.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          SettingsTile(
            leading: const Icon(Icons.add_link),
            title: const Text('Connect GitHub'),
            onPressed: (context) => _showConnectGitHubDialog(context),
          ),
        ],
      );
    }

    // GitHubDisconnected or GitHubInitial
    return SettingsSection(
      title: const Text('GitHub'),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.add_link),
          title: const Text('Connect GitHub'),
          description: const Text('Add a Personal Access Token to connect'),
          onPressed: (context) => _showConnectGitHubDialog(context),
        ),
      ],
    );
  }

  void _showConnectGitHubDialog(BuildContext context) {
    final controller = TextEditingController();

    showAdaptiveDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog.adaptive(
          title: const Text('Connect GitHub'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your GitHub Personal Access Token (PAT).\n\n'
                'You can create one at:\nGitHub → Settings → Developer settings → Personal access tokens',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Personal Access Token',
                  hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Connect'),
              onPressed: () {
                final pat = controller.text.trim();
                if (pat.isNotEmpty) {
                  context.read<GitHubBloc>().add(GitHubConnect(pat: pat));
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDisconnectGitHubDialog(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog.adaptive(
          title: const Text('Disconnect GitHub?'),
          content: const Text(
            'This will remove your Personal Access Token from secure storage.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Disconnect'),
              onPressed: () {
                context.read<GitHubBloc>().add(const GitHubDisconnect());
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog.adaptive(
          title: const Text('Are you sure you want to sign out?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                try {
                  context.goNamed(SplashScreen.name);
                } catch (e) {
                  showErrorToast(
                    context: context,
                    message: e.toString(),
                  );
                }
              },
            ),
            CupertinoDialogAction(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }
}
