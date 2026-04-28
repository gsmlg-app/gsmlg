// ignore_for_file: depend_on_referenced_packages

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/account_screen.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelManagementScreen extends StatefulWidget {
  static const name = 'ModelManagement';
  static const path = 'models';

  const ModelManagementScreen({super.key});

  @override
  State<ModelManagementScreen> createState() => _ModelManagementScreenState();
}

class _ModelManagementScreenState extends State<ModelManagementScreen> {
  static const _proxyKey = 'gemma_model_proxy_url';

  @override
  void initState() {
    super.initState();
    context.read<GemmaModelBloc>().add(const GemmaModelListInstalled());
    _loadProxy();
  }

  void _loadProxy() {
    final prefs = context.read<SharedPreferences>();
    final saved = prefs.getString(_proxyKey);
    if (saved != null && saved.isNotEmpty) {
      context.read<GemmaModelBloc>().add(GemmaModelSetProxy(proxyUrl: saved));
    }
  }

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
          child: BlocBuilder<GemmaModelBloc, GemmaModelState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: <Widget>[
                  const SliverAppBar(title: Text('Local Models')),
                  SliverFillRemaining(
                    child: SettingsList(
                      sections: [
                        _buildDownloadedSection(context, state),
                        if (state.isDownloading)
                          _buildDownloadingSection(context, state),
                        if (state.failedDownloads.isNotEmpty)
                          _buildFailedSection(context, state),
                        ..._buildAvailableSections(context, state),
                        _buildProxySection(context, state),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }

  // ---------------------------------------------------------------------------
  // Available Models
  // ---------------------------------------------------------------------------

  IconData _categoryIcon(ModelCategory category) {
    return switch (category) {
      ModelCategory.gemma => Icons.smart_toy,
      ModelCategory.qwen => Icons.psychology,
      ModelCategory.deepSeek => Icons.auto_awesome,
      ModelCategory.phi => Icons.memory,
      ModelCategory.other => Icons.model_training,
    };
  }

  SettingsSection _buildDownloadedSection(
    BuildContext context,
    GemmaModelState state,
  ) {
    final installedIds = state.installedModels;

    if (installedIds.isEmpty) {
      return SettingsSection(
        title: const Text('Available Models'),
        tiles: [
          SettingsTile(
            title: const Text('No models downloaded'),
            description: const Text(
              'Download a model below to start chatting.',
            ),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      );
    }

    final tiles = <SettingsTile>[];
    for (final modelId in installedIds) {
      final info = _findModelInfoByInstalledId(modelId);
      final displayName = info?.displayName ?? modelId;
      final isSelected = state.selectedModelId == modelId;
      final category = info?.category ?? ModelCategory.other;

      tiles.add(
        SettingsTile(
          leading: Icon(_categoryIcon(category)),
          title: Text(displayName),
          description: info != null ? Text(info.description) : null,
          trailing: isSelected
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Deselect model',
                      onPressed: () {
                        context.read<GemmaModelBloc>().add(
                          const GemmaModelDeselect(),
                        );
                      },
                    ),
                  ],
                )
              : IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () =>
                      _showDeleteDialog(context, modelId, displayName),
                ),
          onPressed: (_) {
            context.read<GemmaModelBloc>().add(
              GemmaModelSelect(modelId: modelId),
            );
          },
        ),
      );
    }

    return SettingsSection(title: const Text('Available Models'), tiles: tiles);
  }

  // ---------------------------------------------------------------------------
  // Downloading
  // ---------------------------------------------------------------------------

  SettingsSection _buildDownloadingSection(
    BuildContext context,
    GemmaModelState state,
  ) {
    final tiles = <SettingsTile>[];

    for (final download in state.activeDownloads) {
      final info = GemmaModelInfo.findById(download.modelId);
      final displayName = info?.displayName ?? download.modelId;
      final category = info?.category ?? ModelCategory.other;

      tiles.add(
        SettingsTile(
          leading: Icon(_categoryIcon(category)),
          title: Text(displayName),
          description: info != null ? Text(info.description) : null,
          trailing: SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: download.progress / 100),
                const SizedBox(height: 4),
                Text(
                  '${download.progress.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SettingsSection(
      title: Text('Downloading (${state.activeDownloads.length}/3)'),
      tiles: tiles,
    );
  }

  // ---------------------------------------------------------------------------
  // Failed Downloads
  // ---------------------------------------------------------------------------

  SettingsSection _buildFailedSection(
    BuildContext context,
    GemmaModelState state,
  ) {
    final tiles = <SettingsTile>[];

    for (final failed in state.failedDownloads) {
      final info = GemmaModelInfo.findById(failed.modelId);
      final displayName = info?.displayName ?? failed.modelId;

      tiles.add(
        SettingsTile(
          leading: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(displayName),
          description: Text(
            failed.errorMessage,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Retry',
                onPressed: () {
                  if (info != null) {
                    _installModel(context, info);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Dismiss',
                onPressed: () {
                  context.read<GemmaModelBloc>().add(
                    GemmaModelDismissFailure(modelId: failed.modelId),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return SettingsSection(
      title: Text(
        'Failed Downloads',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      tiles: tiles,
    );
  }

  // ---------------------------------------------------------------------------
  // Available Models (grouped by category)
  // ---------------------------------------------------------------------------

  String _categoryTitle(ModelCategory category) {
    return switch (category) {
      ModelCategory.gemma => 'Gemma Models',
      ModelCategory.qwen => 'Qwen Models',
      ModelCategory.deepSeek => 'DeepSeek Models',
      ModelCategory.phi => 'Phi Models',
      ModelCategory.other => 'Other Models',
    };
  }

  List<SettingsSection> _buildAvailableSections(
    BuildContext context,
    GemmaModelState state,
  ) {
    final sections = <SettingsSection>[];

    for (final category in ModelCategory.values) {
      final models = GemmaModelInfo.platformModels
          .where((m) => m.category == category)
          .where((m) => !state.isModelDownloading(m.id))
          .toList();

      if (models.isEmpty) continue;

      final tiles = <SettingsTile>[];
      for (final model in models) {
        final installed = _isInstalled(model, state.installedModels);
        tiles.add(
          SettingsTile(
            leading: Icon(_categoryIcon(category)),
            title: Text(model.displayName),
            description: Text(model.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (installed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                Text(model.effectiveSizeLabel),
              ],
            ),
            onPressed: (_) =>
                _showDownloadConfirmDialog(context, model, installed),
          ),
        );
      }

      sections.add(
        SettingsSection(title: Text(_categoryTitle(category)), tiles: tiles),
      );
    }

    return sections;
  }

  bool _isInstalled(GemmaModelInfo model, List<String> installedIds) {
    return installedIds.any(
      (id) => id == model.id || id.contains(model.id) || model.id.contains(id),
    );
  }

  void _showDownloadConfirmDialog(
    BuildContext context,
    GemmaModelInfo model,
    bool isInstalled,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isInstalled ? 'Model Already Downloaded' : 'Download Model',
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(model.description),
                const SizedBox(height: 8),
                Text('Size: ${model.effectiveSizeLabel}'),
                if (model.needsAuth) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Requires HuggingFace authentication.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (isInstalled) ...[
                  const SizedBox(height: 12),
                  Text(
                    'This model is already downloaded. '
                    'Would you like to force re-download?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
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
                Navigator.pop(dialogContext);
                _installModel(context, model);
              },
              child: Text(isInstalled ? 'Re-download' : 'Download'),
            ),
          ],
        );
      },
    );
  }

  void _installModel(BuildContext context, GemmaModelInfo model) {
    if (model.isBundled) {
      context.read<GemmaModelBloc>().add(
        GemmaModelInstallFromAsset(
          modelId: model.id,
          assetPath: model.assetPath!,
        ),
      );
    } else if (model.needsAuth) {
      _installWithHuggingFaceToken(context, model);
    } else {
      context.read<GemmaModelBloc>().add(
        GemmaModelInstall(
          nativeModelType: model.modelType,
          url: model.downloadUrl,
          modelId: model.id,
        ),
      );
    }
  }

  Future<void> _installWithHuggingFaceToken(
    BuildContext context,
    GemmaModelInfo model,
  ) async {
    final accountsState = context.read<AccountsBloc>().state;
    if (accountsState is! AccountsLoaded) return;

    final hfAccounts = accountsState.byProvider(ServiceProvider.huggingface);

    if (hfAccounts.isEmpty) {
      _showNoHuggingFaceAccountDialog(context);
      return;
    }

    // Use the first HuggingFace account
    final account = hfAccounts.first;
    final token = await context.read<AccountsBloc>().getApiKey(account.id);

    if (token == null || token.isEmpty) {
      if (context.mounted) _showNoHuggingFaceAccountDialog(context);
      return;
    }

    if (context.mounted) {
      context.read<GemmaModelBloc>().add(
        GemmaModelInstall(
          nativeModelType: model.modelType,
          url: model.downloadUrl,
          modelId: model.id,
          token: token,
        ),
      );
    }
  }

  void _showNoHuggingFaceAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('HuggingFace Account Required'),
          content: const SizedBox(
            width: 400,
            child: Text(
              'This model requires a HuggingFace access token. '
              'Please add a HuggingFace account in Settings > Accounts first.\n\n'
              'You can create a token at huggingface.co/settings/tokens.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.goNamed(AccountScreen.name);
              },
              child: const Text('Go to Accounts'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Download Settings (proxy)
  // ---------------------------------------------------------------------------

  SettingsSection _buildProxySection(
    BuildContext context,
    GemmaModelState state,
  ) {
    final proxy = state.proxyUrl;
    final hasProxy = proxy != null && proxy.isNotEmpty;

    return SettingsSection(
      title: const Text('Download Settings'),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.vpn_key),
          title: const Text('Download Proxy'),
          description: hasProxy
              ? Text(proxy)
              : const Text('No proxy configured (direct download)'),
          trailing: hasProxy
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    final prefs = context.read<SharedPreferences>();
                    prefs.remove(_proxyKey);
                    context.read<GemmaModelBloc>().add(
                      const GemmaModelSetProxy(),
                    );
                  },
                )
              : null,
          onPressed: (_) => _showProxyDialog(context, state.proxyUrl),
        ),
      ],
    );
  }

  void _showProxyDialog(BuildContext context, String? currentProxy) {
    final controller = TextEditingController(text: currentProxy ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Download Proxy'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set an HTTP proxy for model downloads. '
                  'Leave empty for direct download.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Proxy URL',
                    hintText: 'http://proxy.example.com:8080',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
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
                final value = controller.text.trim();
                final prefs = context.read<SharedPreferences>();
                if (value.isEmpty) {
                  prefs.remove(_proxyKey);
                  context.read<GemmaModelBloc>().add(
                    const GemmaModelSetProxy(),
                  );
                } else {
                  prefs.setString(_proxyKey, value);
                  context.read<GemmaModelBloc>().add(
                    GemmaModelSetProxy(proxyUrl: value),
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Delete dialog
  // ---------------------------------------------------------------------------

  void _showDeleteDialog(
    BuildContext context,
    String modelId,
    String displayName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Model?'),
          content: Text('Delete "$displayName"? You can reinstall it later.'),
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
                context.read<GemmaModelBloc>().add(
                  GemmaModelDeleteById(modelId: modelId),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  GemmaModelInfo? _findModelInfoByInstalledId(String installedId) {
    for (final model in GemmaModelInfo.availableModels) {
      if (installedId == model.id ||
          installedId.contains(model.id) ||
          model.id.contains(installedId)) {
        return model;
      }
    }
    return null;
  }
}
