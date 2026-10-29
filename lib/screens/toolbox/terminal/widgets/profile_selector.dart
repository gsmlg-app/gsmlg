import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';

/// Callback when a profile is selected.
typedef ProfileSelectedCallback = void Function(ShellProfile? profile);

/// Shows a dialog to select a shell profile before creating a new session.
///
/// If no profiles exist, calls the callback with null immediately.
/// If only one profile exists and it's the default, uses it automatically.
void showProfileSelector({
  required BuildContext context,
  required ProfileSelectedCallback onProfileSelected,
}) {
  final bloc = context.read<ShellProfileBloc>();
  final state = bloc.state;

  if (state is! ShellProfileLoaded || state.profiles.isEmpty) {
    // No profiles, proceed with default shell
    onProfileSelected(null);
    return;
  }

  final profiles = state.profiles;

  // If there's a default profile and only one profile, use it automatically
  if (profiles.length == 1 && profiles.first.isDefault) {
    onProfileSelected(profiles.first);
    return;
  }

  // Show selector dialog
  showDialog<ShellProfile?>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Select Shell Profile'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Default (no profile) option
              ListTile(
                leading: const Icon(Icons.terminal),
                title: const Text('Default Shell'),
                subtitle: const Text('System default settings'),
                onTap: () => Navigator.of(dialogContext).pop(null),
              ),
              const Divider(),
              // Profile list
              ...profiles.map(
                (profile) => ListTile(
                  leading: profile.isDefault
                      ? const Icon(Icons.star, color: Colors.amber)
                      : const Icon(Icons.person),
                  title: Text(profile.name),
                  subtitle: Text(_getProfileDescription(profile)),
                  onTap: () => Navigator.of(dialogContext).pop(profile),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  ).then((selectedProfile) {
    // Only call callback if dialog wasn't cancelled (user selected something)
    // If cancelled, selectedProfile will be null but we use a separate flag
  });
}

String _getProfileDescription(ShellProfile profile) {
  final shellType = ShellType.fromValue(profile.shellType)?.name ?? 'sh';
  final parts = <String>[shellType];
  if (profile.isDefault) {
    parts.add('default');
  }
  return parts.join(' • ');
}

/// Shows profile selector and opens a new local shell with the selected profile.
///
/// If no profiles exist or user selects "Default Shell", opens with no profile.
/// Otherwise applies the selected profile's environment and init commands.
void selectProfileAndOpenShell({
  required BuildContext context,
  required void Function(ShellProfile?) onProfileSelected,
}) {
  final bloc = context.read<ShellProfileBloc>();
  final state = bloc.state;

  // If no profiles or state not loaded, proceed immediately
  if (state is! ShellProfileLoaded || state.profiles.isEmpty) {
    onProfileSelected(null);
    return;
  }

  // If there's exactly one default profile, use it without prompting
  final defaultProfile = state.defaultProfile;
  if (state.profiles.length == 1 && defaultProfile != null) {
    onProfileSelected(defaultProfile);
    return;
  }

  // Show selection dialog
  showDialog<dynamic>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Select Shell Profile'),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Default option (no profile)
                _ProfileTile(
                  icon: const Icon(Icons.terminal),
                  title: 'Default Shell',
                  subtitle: 'System default settings',
                  onTap: () {
                    Navigator.of(dialogContext).pop(const _DefaultSelected());
                  },
                ),
                const Divider(height: 1),
                // Profile options
                ...state.profiles.map(
                  (profile) => _ProfileTile(
                    icon: profile.isDefault
                        ? const Icon(Icons.star, color: Colors.amber)
                        : const Icon(Icons.person),
                    title: profile.name,
                    subtitle: _getProfileDescription(profile),
                    onTap: () {
                      Navigator.of(dialogContext).pop(profile);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  ).then((result) {
    if (result == null) {
      // Dialog was cancelled
      return;
    }
    if (result is _DefaultSelected) {
      onProfileSelected(null);
    } else if (result is ShellProfile) {
      onProfileSelected(result);
    }
  });
}

/// Marker class to distinguish "Default Shell" selection from cancellation.
class _DefaultSelected {
  const _DefaultSelected();
}

class _ProfileTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
