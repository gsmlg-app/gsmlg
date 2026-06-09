// ignore_for_file: depend_on_referenced_packages

import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
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
              return BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
                builder: (context, settingsState) {
                  return CustomScrollView(
                    slivers: <Widget>[
                      const SliverAppBar(title: Text('Local Models')),
                      SliverFillRemaining(
                        child: SettingsList(
                          sections: [
                            _buildPresetDownloadSection(context, state),
                            _buildDownloadedSection(context, state),
                            _buildDownloadingSection(context, state),
                            if (state.pausedDownloads.isNotEmpty)
                              _buildPausedSection(context, state),
                            if (state.failedDownloads.isNotEmpty)
                              _buildFailedSection(context, state),
                            _buildBackendSection(context, settingsState.config),
                            _buildProxySection(context, state),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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

  String get _targetOperatingSystem {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.linux => 'linux',
      TargetPlatform.windows => 'windows',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  String _modelSourceLine(GemmaModelInfo model) {
    final operatingSystem = _targetOperatingSystem;
    return '${model.formatLabelForOperatingSystem(operatingSystem)} from '
        '${model.downloadSourceNameForOperatingSystem(operatingSystem)}: '
        '${model.downloadSourceLabelForOperatingSystem(operatingSystem)}';
  }

  SettingsSection _buildDownloadedSection(
    BuildContext context,
    GemmaModelState state,
  ) {
    final installedIds = state.installedModels;

    if (installedIds.isEmpty) {
      return SettingsSection(
        title: const Text('Downloaded Models'),
        tiles: [
          SettingsTile(
            title: const Text('No models downloaded'),
            description: const Text(
              'Download one of the preset Gemma 4 models for this platform.',
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
          description: info != null
              ? Text(
                  '${info.descriptionForOperatingSystem(_targetOperatingSystem)}\n'
                  '${info.formatLabelForOperatingSystem(_targetOperatingSystem)}\n'
                  '${info.memoryRequirementLabel}',
                )
              : null,
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
            final blockReason = info?.localInferenceBlockReason;
            if (blockReason != null) {
              _showImportMessage(context, blockReason);
              return;
            }
            context.read<GemmaModelBloc>().add(
              GemmaModelSelect(modelId: modelId),
            );
          },
        ),
      );
    }

    return SettingsSection(
      title: const Text('Downloaded Models'),
      tiles: tiles,
    );
  }

  // ---------------------------------------------------------------------------
  // Downloading
  // ---------------------------------------------------------------------------

  SettingsSection _buildDownloadingSection(
    BuildContext context,
    GemmaModelState state,
  ) {
    if (state.activeDownloads.isEmpty) {
      return SettingsSection(
        title: const Text('Downloading Models'),
        tiles: [
          SettingsTile(
            title: const Text('No active downloads'),
            description: const Text(
              'Download speed and progress appear here while models download.',
            ),
            leading: const Icon(Icons.downloading_outlined),
          ),
        ],
      );
    }

    final tiles = <SettingsTile>[];

    for (final download in state.activeDownloads) {
      final info = GemmaModelInfo.findByIdForOperatingSystem(
        download.modelId,
        _targetOperatingSystem,
      );
      final displayName = info?.displayName ?? download.modelId;
      final category = info?.category ?? ModelCategory.other;
      final progressValue = download.progress > 0
          ? (download.progress / 100).clamp(0.0, 1.0)
          : null;

      tiles.add(
        SettingsTile(
          leading: Icon(_categoryIcon(category)),
          title: Text(displayName),
          description: Text(
            [
              if (info != null)
                info.descriptionForOperatingSystem(_targetOperatingSystem),
              _downloadTransferLabel(download),
            ].join('\n'),
          ),
          trailing: SizedBox(
            width: 220,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 112,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(value: progressValue),
                      const SizedBox(height: 4),
                      Text(
                        '${download.progress.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _downloadSpeedLabel(download),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  tooltip: 'Pause download',
                  onPressed: info == null
                      ? null
                      : () => _pauseDownload(context, info),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  tooltip: 'Cancel download',
                  onPressed: info == null
                      ? null
                      : () => _cancelDownload(context, info),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SettingsSection(
      title: Text('Downloading Models (${state.activeDownloads.length}/3)'),
      tiles: tiles,
    );
  }

  // ---------------------------------------------------------------------------
  // Paused Downloads
  // ---------------------------------------------------------------------------

  SettingsSection _buildPausedSection(
    BuildContext context,
    GemmaModelState state,
  ) {
    final tiles = <SettingsTile>[];

    for (final download in state.pausedDownloads) {
      final info = GemmaModelInfo.findByIdForOperatingSystem(
        download.modelId,
        _targetOperatingSystem,
      );
      final displayName = info?.displayName ?? download.modelId;
      final category = info?.category ?? ModelCategory.other;

      tiles.add(
        SettingsTile(
          leading: Icon(_categoryIcon(category)),
          title: Text(displayName),
          description: Text(
            [
              if (info != null)
                info.descriptionForOperatingSystem(_targetOperatingSystem),
              _downloadTransferLabel(download),
            ].join('\n'),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Resume download',
                onPressed: info == null
                    ? null
                    : () => _installModel(context, info),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: 'Cancel download',
                onPressed: info == null
                    ? null
                    : () => _cancelDownload(context, info),
              ),
            ],
          ),
        ),
      );
    }

    return SettingsSection(
      title: Text('Paused Downloads (${state.pausedDownloads.length})'),
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
      final info = GemmaModelInfo.findByIdForOperatingSystem(
        failed.modelId,
        _targetOperatingSystem,
      );
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
  // Preset downloads
  // ---------------------------------------------------------------------------

  SettingsSection _buildPresetDownloadSection(
    BuildContext context,
    GemmaModelState state,
  ) {
    final operatingSystem = _targetOperatingSystem;
    final models = GemmaModelInfo.platformModels
        .where(
          (model) =>
              model.isFourBitArtifactForOperatingSystem(operatingSystem) &&
              !state.isModelDownloading(model.id) &&
              !state.isModelPaused(model.id) &&
              !_isInstalled(model, state.installedModels),
        )
        .toList(growable: false);

    return SettingsSection(
      title: const Text('Available to Download'),
      tiles: [
        if (models.isEmpty)
          SettingsTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('No models available to download'),
            description: const Text(
              'Gemma 4 E4B and E2B are already downloaded or downloading.',
            ),
          ),
        for (final model in models)
          SettingsTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: Text(
              model == GemmaModelInfo.defaultModel
                  ? '${model.displayName} (Default)'
                  : model.displayName,
            ),
            description: Text(
              '${model.descriptionForOperatingSystem(operatingSystem)}\n'
              '${_modelSourceLine(model)}\n'
              '${model.memoryRequirementLabel}',
            ),
            trailing: Text(model.sizeLabelForOperatingSystem(operatingSystem)),
            onPressed: (_) => _showDownloadConfirmDialog(context, model, false),
          ),
      ],
    );
  }

  String _downloadDialogNote(GemmaModelInfo model) {
    if (model.isHuggingFaceDownloadForOperatingSystem(_targetOperatingSystem)) {
      return 'Uses your configured Hugging Face token when available.';
    }
    return 'Uses the preset download URL bundled with the app.';
  }

  bool _isInstalled(GemmaModelInfo model, List<String> installedIds) {
    return installedIds.any(
      (id) => id == model.id || id.contains(model.id) || model.id.contains(id),
    );
  }

  String _downloadTransferLabel(ModelDownloadProgress download) {
    final received = download.receivedBytes;
    final total = download.totalBytes;
    if (received != null && total != null && total > 0) {
      return '${_formatBytes(received)} / ${_formatBytes(total)}';
    }
    if (received != null && received > 0) {
      return _formatBytes(received);
    }
    return 'Starting download';
  }

  String _downloadSpeedLabel(ModelDownloadProgress download) {
    final speed = download.bytesPerSecond;
    if (speed == null || speed <= 0) return '--/s';
    return '${_formatBytes(speed.round())}/s';
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    final digits = value >= 10 || unitIndex == 0 ? 0 : 1;
    return '${value.toStringAsFixed(digits)} ${units[unitIndex]}';
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
                Text(
                  model.descriptionForOperatingSystem(_targetOperatingSystem),
                ),
                const SizedBox(height: 8),
                Text(
                  'Size: ${model.sizeLabelForOperatingSystem(_targetOperatingSystem)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Format: ${model.formatLabelForOperatingSystem(_targetOperatingSystem)}',
                ),
                const SizedBox(height: 8),
                Text('Memory: ${model.memoryRequirementLabel}'),
                const SizedBox(height: 8),
                Text(
                  'Source: ${model.downloadSourceNameForOperatingSystem(_targetOperatingSystem)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Repository: ${model.downloadSourceLabelForOperatingSystem(_targetOperatingSystem)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'File: ${model.downloadFileNameForOperatingSystem(_targetOperatingSystem)}',
                ),
                const SizedBox(height: 8),
                Text(
                  _downloadDialogNote(model),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (model.needsAuth) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Requires Hugging Face authentication.',
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
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _pickLocalModelFile(context, model);
              },
              icon: const Icon(Icons.folder_open),
              label: Text(
                'Add Local ${model.formatLabelForOperatingSystem(_targetOperatingSystem)} File',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _installModel(context, model);
              },
              child: Text(
                isInstalled
                    ? 'Re-download from Hugging Face'
                    : 'Download from Hugging Face',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickLocalModelFile(
    BuildContext context,
    GemmaModelInfo model,
  ) async {
    final operatingSystem = _targetOperatingSystem;
    final isAndroid = operatingSystem == 'android';
    final result = await FilePicker.platform.pickFiles(
      dialogTitle:
          'Select ${model.downloadFileNameForOperatingSystem(operatingSystem)}',
      type: isAndroid ? FileType.any : FileType.custom,
      allowedExtensions: isAndroid
          ? null
          : model.fileExtensionsForOperatingSystem(operatingSystem),
      allowMultiple: false,
      withData: false,
    );
    if (!context.mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final filePath = file.path;
    if (filePath == null || filePath.isEmpty) {
      _showImportMessage(context, 'Selected file has no readable path.');
      return;
    }
    if (!_isSupportedModelFile(file.name, model) &&
        !_isSupportedModelFile(filePath, model)) {
      _showImportMessage(
        context,
        'Selected file is not a ${model.formatLabelForOperatingSystem(operatingSystem)} model.',
      );
      return;
    }

    context.read<GemmaModelBloc>().add(
      GemmaModelImportFromFile(modelId: model.id, filePath: filePath),
    );
  }

  bool _isSupportedModelFile(String path, GemmaModelInfo model) {
    final lower = path.toLowerCase();
    return model
        .fileExtensionsForOperatingSystem(_targetOperatingSystem)
        .any((extension) => lower.endsWith('.$extension'));
  }

  void _showImportMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _installModel(BuildContext context, GemmaModelInfo model) {
    if (model.isHuggingFaceDownloadForOperatingSystem(_targetOperatingSystem)) {
      _installWithHuggingFaceToken(
        context,
        model,
        tokenRequired: model.needsAuth,
      );
    } else {
      _installFromNetwork(context, model);
    }
  }

  Future<void> _installWithHuggingFaceToken(
    BuildContext context,
    GemmaModelInfo model, {
    required bool tokenRequired,
  }) async {
    final accountsState = context.read<AccountsBloc>().state;
    if (accountsState is! AccountsLoaded) {
      if (tokenRequired) {
        _showNoHuggingFaceAccountDialog(context);
      } else {
        _installFromNetwork(context, model);
      }
      return;
    }

    final hfAccounts = accountsState.byProvider(ServiceProvider.huggingface);

    if (hfAccounts.isEmpty) {
      if (tokenRequired) {
        _showNoHuggingFaceAccountDialog(context);
      } else {
        _installFromNetwork(context, model);
      }
      return;
    }

    // Use the first HuggingFace account
    final account = hfAccounts.first;
    final token = await context.read<AccountsBloc>().getApiKey(account.id);

    if (token == null || token.isEmpty) {
      if (!context.mounted) return;
      if (tokenRequired) {
        _showNoHuggingFaceAccountDialog(context);
      } else {
        _installFromNetwork(context, model);
      }
      return;
    }

    if (context.mounted) {
      _installFromNetwork(context, model, token: token);
    }
  }

  void _installFromNetwork(
    BuildContext context,
    GemmaModelInfo model, {
    String? token,
  }) {
    context.read<GemmaModelBloc>().add(
      GemmaModelInstall(
        url: model.downloadUrlForOperatingSystem(_targetOperatingSystem),
        modelId: model.id,
        token: token,
      ),
    );
  }

  void _pauseDownload(BuildContext context, GemmaModelInfo model) {
    context.read<GemmaModelBloc>().add(
      GemmaModelPauseDownload(
        url: model.downloadUrlForOperatingSystem(_targetOperatingSystem),
        modelId: model.id,
      ),
    );
  }

  void _cancelDownload(BuildContext context, GemmaModelInfo model) {
    context.read<GemmaModelBloc>().add(
      GemmaModelCancelDownload(
        url: model.downloadUrlForOperatingSystem(_targetOperatingSystem),
        modelId: model.id,
      ),
    );
  }

  void _showNoHuggingFaceAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hugging Face Account Required'),
          content: const SizedBox(
            width: 400,
            child: Text(
              'This model requires a Hugging Face access token. '
              'Please add a Hugging Face account in Settings > Accounts first.\n\n'
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
  // Inference Settings
  // ---------------------------------------------------------------------------

  SettingsSection _buildBackendSection(
    BuildContext context,
    ModelConfig config,
  ) {
    if (_targetOperatingSystem == 'android') {
      return SettingsSection(
        title: const Text('Inference Settings'),
        tiles: [
          SettingsTile(
            leading: const Icon(Icons.memory),
            title: const Text('Runtime'),
            description: const Text('Android LiteRT-LM inference.'),
            trailing: const Text('LiteRT-LM'),
          ),
        ],
      );
    }

    final effectiveConfig = config.withSupportedBackendForCurrentPlatform();
    return SettingsSection(
      title: const Text('Inference Settings'),
      tiles: [
        SettingsTile(
          leading: const Icon(Icons.memory),
          title: const Text('Backend'),
          description: Text(_backendDescription(effectiveConfig.backend)),
          trailing: Text(effectiveConfig.backend.displayName),
          onPressed: (_) => _showBackendDialog(context, effectiveConfig),
        ),
      ],
    );
  }

  Future<void> _showBackendDialog(BuildContext context, ModelConfig config) {
    final supportedBackends = supportedGemmaBackendsForCurrentPlatform();
    final effectiveConfig = config.withSupportedBackendForCurrentPlatform();
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Backend'),
          content: SizedBox(
            width: 420,
            child: RadioGroup<GemmaBackend>(
              groupValue: effectiveConfig.backend,
              onChanged: (value) {
                if (value == null) return;
                context.read<ChatSettingsBloc>().add(
                  ChatSettingsUpdateConfig(
                    config: effectiveConfig.copyWith(backend: value),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final backend in supportedBackends)
                    RadioListTile<GemmaBackend>(
                      title: Text(backend.displayName),
                      subtitle: Text(_backendDescription(backend)),
                      value: backend,
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
          ],
        );
      },
    );
  }

  String _backendDescription(GemmaBackend backend) {
    return switch (backend) {
      GemmaBackend.cpu => 'CPU-only inference.',
      GemmaBackend.metal => 'Apple Metal acceleration.',
      GemmaBackend.cuda => 'NVIDIA CUDA acceleration.',
      GemmaBackend.vulkan => 'Vulkan acceleration.',
      GemmaBackend.npu => 'NPU acceleration.',
    };
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
    return GemmaModelInfo.findByIdForOperatingSystem(
      installedId,
      _targetOperatingSystem,
    );
  }
}
