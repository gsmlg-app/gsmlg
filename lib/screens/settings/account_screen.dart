import 'dart:convert';

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_database/app_database.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/destination.dart';
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
          child: BlocConsumer<AccountsBloc, AccountsState>(
            listener: (context, state) {
              if (state is AccountsLoaded && state.error != null) {
                showErrorToast(context: context, message: state.error!);
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(title: Text(context.l10n.account)),
                  if (state is AccountsLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is AccountsLoaded)
                    SliverFillRemaining(
                      child: _buildProviderSections(context, state.accounts),
                    )
                  else if (state is AccountsError)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error,
                                color: Theme.of(context).colorScheme.error),
                            const SizedBox(height: 8),
                            Text(state.message),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => context
                                  .read<AccountsBloc>()
                                  .add(const AccountsLoad()),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverFillRemaining(
                      child: _buildProviderSections(context, []),
                    ),
                ],
              );
            },
          ),
        );
      },
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    );
  }

  Widget _buildProviderSections(
      BuildContext context, List<ServiceAccountTableData> accounts) {
    final sections = ServiceProvider.values.map((provider) {
      final providerAccounts =
          accounts.where((a) => a.provider == provider).toList();

      return SettingsSection(
        title: Row(
          children: [
            Icon(_providerIcon(provider), size: 18),
            const SizedBox(width: 8),
            Text(_providerLabel(provider)),
          ],
        ),
        tiles: [
          ...providerAccounts.map((account) => SettingsTile(
                leading: Icon(_providerIcon(account.provider)),
                title: Text(account.name),
                description: account.description.isNotEmpty
                    ? Text(account.description)
                    : null,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        _showEditDialog(context, account);
                      case 'update_key':
                        _showUpdateApiKeyDialog(context, account);
                      case 'delete':
                        _showDeleteDialog(context, account);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'update_key',
                      child: ListTile(
                        leading: const Icon(Icons.key),
                        title: Text(account.provider == ServiceProvider.aws
                            ? 'Update Credentials'
                            : 'Update API Key'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete,
                            color: Theme.of(context).colorScheme.error),
                        title: Text('Delete',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              )),
          SettingsTile(
            leading: const Icon(Icons.add),
            title: Text('Add ${_providerLabel(provider)} Account'),
            onPressed: (_) => _showAddDialog(context, provider),
          ),
        ],
      );
    }).toList();

    return SettingsList(sections: sections);
  }

  void _showAddDialog(BuildContext context, ServiceProvider provider) {
    if (provider == ServiceProvider.aws) {
      _showAddAwsDialog(context);
    } else {
      _showAddGenericDialog(context, provider);
    }
  }

  void _showAddGenericDialog(BuildContext context, ServiceProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final apiKeyController = TextEditingController();
    bool obscureKey = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text('Add ${_providerLabel(provider)} Account'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'e.g. Personal, Work',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Optional description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: apiKeyController,
                        obscureText: obscureKey,
                        decoration: InputDecoration(
                          labelText: _apiKeyLabel(provider),
                          hintText: _apiKeyHint(provider),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(obscureKey
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => obscureKey = !obscureKey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final apiKey = apiKeyController.text.trim();
                    if (name.isEmpty || apiKey.isEmpty) return;

                    context.read<AccountsBloc>().add(AccountsAdd(
                          provider: provider,
                          name: name,
                          description: descController.text.trim(),
                          apiKey: apiKey,
                        ));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddAwsDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final regionController = TextEditingController(text: 'us-east-1');
    final accessKeyIdController = TextEditingController();
    final secretKeyController = TextEditingController();
    bool obscureSecret = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Add AWS Account'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'e.g. Personal, Work',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Optional description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: regionController,
                        decoration: const InputDecoration(
                          labelText: 'Region',
                          hintText: 'us-east-1',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: accessKeyIdController,
                        decoration: const InputDecoration(
                          labelText: 'Access Key ID',
                          hintText: 'AKIAIOSFODNN7EXAMPLE',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: secretKeyController,
                        obscureText: obscureSecret,
                        decoration: InputDecoration(
                          labelText: 'Secret Access Key',
                          hintText: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(obscureSecret
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => obscureSecret = !obscureSecret),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final region = regionController.text.trim();
                    final accessKeyId = accessKeyIdController.text.trim();
                    final secretKey = secretKeyController.text.trim();
                    if (name.isEmpty ||
                        region.isEmpty ||
                        accessKeyId.isEmpty ||
                        secretKey.isEmpty) {
                      return;
                    }

                    final credential = jsonEncode({
                      'region': region,
                      'accessKeyId': accessKeyId,
                      'secretAccessKey': secretKey,
                    });

                    context.read<AccountsBloc>().add(AccountsAdd(
                          provider: ServiceProvider.aws,
                          name: name,
                          description: descController.text.trim(),
                          apiKey: credential,
                        ));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(
      BuildContext context, ServiceAccountTableData account) {
    final nameController = TextEditingController(text: account.name);
    final descController = TextEditingController(text: account.description);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Account'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                context.read<AccountsBloc>().add(AccountsUpdate(
                      id: account.id,
                      name: name,
                      description: descController.text.trim(),
                    ));
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateApiKeyDialog(
      BuildContext context, ServiceAccountTableData account) {
    if (account.provider == ServiceProvider.aws) {
      _showUpdateAwsKeyDialog(context, account);
    } else {
      _showUpdateGenericKeyDialog(context, account);
    }
  }

  void _showUpdateGenericKeyDialog(
      BuildContext context, ServiceAccountTableData account) {
    final controller = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title:
                  Text('Update ${_providerLabel(account.provider)} Key'),
              content: TextField(
                controller: controller,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: _apiKeyLabel(account.provider),
                  hintText: _apiKeyHint(account.provider),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final apiKey = controller.text.trim();
                    if (apiKey.isEmpty) return;
                    context.read<AccountsBloc>().add(
                          AccountsUpdateApiKey(
                              id: account.id, apiKey: apiKey),
                        );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateAwsKeyDialog(
      BuildContext context, ServiceAccountTableData account) {
    final regionController = TextEditingController(text: 'us-east-1');
    final accessKeyIdController = TextEditingController();
    final secretKeyController = TextEditingController();
    bool obscureSecret = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Update AWS Credentials'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: regionController,
                        decoration: const InputDecoration(
                          labelText: 'Region',
                          hintText: 'us-east-1',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: accessKeyIdController,
                        decoration: const InputDecoration(
                          labelText: 'Access Key ID',
                          hintText: 'AKIAIOSFODNN7EXAMPLE',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: secretKeyController,
                        obscureText: obscureSecret,
                        decoration: InputDecoration(
                          labelText: 'Secret Access Key',
                          hintText:
                              'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(obscureSecret
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => obscureSecret = !obscureSecret),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final region = regionController.text.trim();
                    final accessKeyId = accessKeyIdController.text.trim();
                    final secretKey = secretKeyController.text.trim();
                    if (region.isEmpty ||
                        accessKeyId.isEmpty ||
                        secretKey.isEmpty) {
                      return;
                    }

                    final credential = jsonEncode({
                      'region': region,
                      'accessKeyId': accessKeyId,
                      'secretAccessKey': secretKey,
                    });

                    context.read<AccountsBloc>().add(
                          AccountsUpdateApiKey(
                              id: account.id, apiKey: credential),
                        );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, ServiceAccountTableData account) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: Text(
            'Delete "${account.name}"? The API key will be removed from secure storage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                context
                    .read<AccountsBloc>()
                    .add(AccountsDelete(id: account.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

IconData _providerIcon(ServiceProvider provider) {
  return switch (provider) {
    ServiceProvider.github => Icons.code,
    ServiceProvider.vultr => Icons.cloud,
    ServiceProvider.aws => Icons.cloud_queue,
    ServiceProvider.cloudflare => Icons.shield,
  };
}

String _providerLabel(ServiceProvider provider) {
  return switch (provider) {
    ServiceProvider.github => 'GitHub',
    ServiceProvider.vultr => 'Vultr',
    ServiceProvider.aws => 'AWS',
    ServiceProvider.cloudflare => 'Cloudflare',
  };
}

String _apiKeyLabel(ServiceProvider provider) {
  return switch (provider) {
    ServiceProvider.github => 'Personal Access Token',
    ServiceProvider.vultr => 'API Key',
    ServiceProvider.aws => 'Access Key ID',
    ServiceProvider.cloudflare => 'API Token',
  };
}

String _apiKeyHint(ServiceProvider provider) {
  return switch (provider) {
    ServiceProvider.github => 'ghp_xxxxxxxxxxxxxxxxxxxx',
    ServiceProvider.vultr => 'Enter your Vultr API key',
    ServiceProvider.aws => 'AKIAIOSFODNN7EXAMPLE',
    ServiceProvider.cloudflare => 'Enter your Cloudflare API token',
  };
}
