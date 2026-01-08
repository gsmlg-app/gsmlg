import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:app_locale/app_locale.dart';
import 'package:auth_bloc/auth_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                ),
              ),
            ],
          ),
        );
      },
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
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
