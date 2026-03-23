import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';
import 'package:settings_ui/settings_ui.dart';
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
                  const SliverAppBar(title: Text('AI Models')),
                  SliverFillRemaining(
                    child: SettingsList(
                      sections: [
                        _buildDownloadedSection(context, state),
                        if (state.downloadingModelId != null)
                          _buildDownloadingSection(context, state),
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
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
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
      BuildContext context, GemmaModelState state) {
    final installedIds = state.installedModels;

    if (installedIds.isEmpty) {
      return SettingsSection(
        title: const Text('Available Models'),
        tiles: [
          SettingsTile(
            title: const Text('No models downloaded'),
            description:
                const Text('Download a model below to start chatting.'),
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
              ? const Icon(Icons.check)
              : IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () =>
                      _showDeleteDialog(context, modelId, displayName),
                ),
          onPressed: (_) {
            context
                .read<GemmaModelBloc>()
                .add(GemmaModelSelect(modelId: modelId));
          },
        ),
      );
    }

    return SettingsSection(
      title: const Text('Available Models'),
      tiles: tiles,
    );
  }

  // ---------------------------------------------------------------------------
  // Downloading
  // ---------------------------------------------------------------------------

  SettingsSection _buildDownloadingSection(
      BuildContext context, GemmaModelState state) {
    final modelId = state.downloadingModelId!;
    final info = GemmaModelInfo.findById(modelId);
    final displayName = info?.displayName ?? modelId;
    final category = info?.category ?? ModelCategory.other;

    return SettingsSection(
      title: const Text('Downloading'),
      tiles: [
        SettingsTile(
          leading: Icon(_categoryIcon(category)),
          title: Text(displayName),
          description: info != null ? Text(info.description) : null,
          trailing: SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: state.downloadProgress / 100,
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.downloadProgress.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
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
      BuildContext context, GemmaModelState state) {
    final sections = <SettingsSection>[];

    final isDownloading = state.status == GemmaModelStatus.downloading;

    for (final category in ModelCategory.values) {
      final models = GemmaModelInfo.platformModels
          .where((m) => m.category == category)
          .where((m) => !_isInstalled(m, state.installedModels))
          .where((m) => m.id != state.downloadingModelId)
          .toList();

      if (models.isEmpty) continue;

      final tiles = <SettingsTile>[];
      for (final model in models) {
        tiles.add(
          SettingsTile(
            leading: Icon(_categoryIcon(category)),
            title: Text(model.displayName),
            description: Text(model.description),
            trailing: Text(model.sizeLabel),
            onPressed: isDownloading
                ? null
                : (_) => _installModel(context, model),
          ),
        );
      }

      sections.add(SettingsSection(
        title: Text(_categoryTitle(category)),
        tiles: tiles,
      ));
    }

    return sections;
  }

  bool _isInstalled(GemmaModelInfo model, List<String> installedIds) {
    return installedIds.any((id) =>
        id == model.id || id.contains(model.id) || model.id.contains(id));
  }

  void _installModel(BuildContext context, GemmaModelInfo model) {
    if (model.isBundled) {
      context.read<GemmaModelBloc>().add(GemmaModelInstallFromAsset(
            modelId: model.id,
            assetPath: model.assetPath!,
          ));
    } else if (model.needsAuth) {
      _showTokenDialog(context, model);
    } else {
      context.read<GemmaModelBloc>().add(GemmaModelInstall(
            nativeModelType: model.modelType,
            url: model.url,
            modelId: model.id,
          ));
    }
  }

  static const _hfTokenKey = 'huggingface_token';

  void _showTokenDialog(BuildContext context, GemmaModelInfo model) {
    final prefs = context.read<SharedPreferences>();
    final savedToken = prefs.getString(_hfTokenKey) ?? '';
    final controller = TextEditingController(text: savedToken);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('HuggingFace Token Required'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${model.displayName} requires a HuggingFace access token. '
                  'You can create one at huggingface.co/settings/tokens.',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Access Token',
                    hintText: 'hf_...',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
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
                final token = controller.text.trim();
                if (token.isEmpty) return;
                prefs.setString(_hfTokenKey, token);
                context.read<GemmaModelBloc>().add(GemmaModelInstall(
                      nativeModelType: model.modelType,
                      url: model.url,
                      modelId: model.id,
                      token: token,
                    ));
                Navigator.pop(dialogContext);
              },
              child: const Text('Download'),
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
      BuildContext context, GemmaModelState state) {
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
                    context
                        .read<GemmaModelBloc>()
                        .add(const GemmaModelSetProxy());
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
                  context
                      .read<GemmaModelBloc>()
                      .add(const GemmaModelSetProxy());
                } else {
                  prefs.setString(_proxyKey, value);
                  context
                      .read<GemmaModelBloc>()
                      .add(GemmaModelSetProxy(proxyUrl: value));
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
      BuildContext context, String modelId, String displayName) {
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
                context
                    .read<GemmaModelBloc>()
                    .add(GemmaModelDeleteById(modelId: modelId));
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
