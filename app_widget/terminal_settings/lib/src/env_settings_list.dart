import 'package:flutter/material.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';

/// Screen for managing environment variables.
class EnvSettingsList extends StatelessWidget {
  const EnvSettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalSettingsBloc, TerminalSettingsState>(
      builder: (context, state) {
        if (state is! TerminalSettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final envVars = state.environmentVariables;
        final sortedKeys = envVars.keys.toList()..sort();

        return SettingsList(
          sections: [
            SettingsSection(
              title: const Text('Custom Environment Variables'),
              tiles: [
                ...sortedKeys.map((key) => SettingsTile(
                      leading: const Icon(Icons.code),
                      title: Text(key),
                      description: Text(
                        envVars[key] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, key),
                      ),
                      onPressed: (context) =>
                          _editEnvVar(context, key, envVars[key] ?? ''),
                    )),
                SettingsTile(
                  leading: const Icon(Icons.add, color: Colors.green),
                  title: const Text('Add Variable'),
                  onPressed: (context) => _addEnvVar(context),
                ),
              ],
            ),
            if (envVars.isNotEmpty)
              SettingsSection(
                title: const Text('Actions'),
                tiles: [
                  SettingsTile(
                    leading:
                        const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Clear All'),
                    onPressed: (context) => _confirmClearAll(context),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Future<void> _addEnvVar(BuildContext context) async {
    final result = await _showEnvVarDialog(context, '', '');
    if (result != null && result.key.isNotEmpty && context.mounted) {
      context.read<TerminalSettingsBloc>().add(
            TerminalSettingsUpdateEnvVar(key: result.key, value: result.value),
          );
    }
  }

  Future<void> _editEnvVar(
      BuildContext context, String key, String value) async {
    final result =
        await _showEnvVarDialog(context, key, value, isEditing: true);
    if (result != null && context.mounted) {
      // If key changed, remove old key first
      if (result.key != key) {
        context.read<TerminalSettingsBloc>().add(
              TerminalSettingsRemoveEnvVar(key: key),
            );
      }
      context.read<TerminalSettingsBloc>().add(
            TerminalSettingsUpdateEnvVar(key: result.key, value: result.value),
          );
    }
  }

  Future<void> _confirmDelete(BuildContext context, String key) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Variable'),
        content: Text('Are you sure you want to delete "$key"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<TerminalSettingsBloc>().add(
            TerminalSettingsRemoveEnvVar(key: key),
          );
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Variables'),
        content: const Text(
            'Are you sure you want to delete all custom environment variables?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<TerminalSettingsBloc>().add(TerminalSettingsClearEnvVars());
    }
  }

  Future<({String key, String value})?> _showEnvVarDialog(
    BuildContext context,
    String initialKey,
    String initialValue, {
    bool isEditing = false,
  }) async {
    final keyController = TextEditingController(text: initialKey);
    final valueController = TextEditingController(text: initialValue);

    return showDialog<({String key, String value})>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Variable' : 'Add Variable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., MY_VAR',
              ),
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'e.g., some_value',
              ),
              autofocus: isEditing,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final key = keyController.text.trim();
              final value = valueController.text;
              if (key.isNotEmpty) {
                Navigator.of(context).pop((key: key, value: value));
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }
}
