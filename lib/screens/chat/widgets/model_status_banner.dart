import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/chat/chat_settings_screen.dart';

class ModelStatusBanner extends StatelessWidget {
  const ModelStatusBanner({super.key, required this.state});

  final GemmaModelState state;

  @override
  Widget build(BuildContext context) {
    // Don't show anything if model is ready
    if (state.isReady) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _getBackgroundColor(colorScheme),
      child: _buildContent(context),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    return switch (state.status) {
      GemmaModelStatus.error => colorScheme.errorContainer,
      GemmaModelStatus.notInstalled => colorScheme.tertiaryContainer,
      _ => colorScheme.primaryContainer,
    };
  }

  Widget _buildContent(BuildContext context) {
    return switch (state.status) {
      GemmaModelStatus.initial ||
      GemmaModelStatus.checking => _buildCheckingContent(context),
      GemmaModelStatus.notInstalled => _buildNotInstalledContent(context),
      GemmaModelStatus.downloading => _buildDownloadingContent(context),
      GemmaModelStatus.installed => _buildInstalledContent(context),
      GemmaModelStatus.loading => _buildLoadingContent(context),
      GemmaModelStatus.error => _buildErrorContent(context),
      GemmaModelStatus.ready => const SizedBox.shrink(),
    };
  }

  String? get _selectedModelName {
    final selectedId = state.selectedModelId;
    if (selectedId == null) return null;
    return GemmaModelInfo.findById(selectedId)?.displayName;
  }

  Widget _buildCheckingContent(BuildContext context) {
    final modelName = _selectedModelName;
    final text = modelName != null
        ? 'Checking $modelName...'
        : 'Checking model status...';
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildNotInstalledContent(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.info_outline, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'No model available. Go to Settings > AI Models to download one.',
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadingContent(BuildContext context) {
    final downloads = state.activeDownloads;
    if (downloads.isEmpty) return const SizedBox.shrink();

    if (downloads.length == 1) {
      final d = downloads.first;
      final info = GemmaModelInfo.findById(d.modelId);
      final modelName = info?.displayName ?? 'model';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Downloading $modelName... ${d.progress.toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: d.progress / 100),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Downloading ${downloads.length} models...'),
          ],
        ),
        const SizedBox(height: 8),
        for (final d in downloads) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  GemmaModelInfo.findById(d.modelId)?.displayName ?? d.modelId,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${d.progress.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: d.progress / 100),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _buildInstalledContent(BuildContext context) {
    // Auto-load the model so the user doesn't have to press a button.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final settingsState = context.read<ChatSettingsBloc>().state;
      context.read<GemmaModelBloc>().add(
        GemmaModelLoad(config: settingsState.config),
      );
    });

    final selectedId = state.selectedModelId;
    final info = selectedId != null
        ? GemmaModelInfo.findById(selectedId)
        : null;
    final modelName = info?.displayName ?? 'Model';

    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('Loading $modelName...')),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    final selectedId = state.selectedModelId;
    final info = selectedId != null
        ? GemmaModelInfo.findById(selectedId)
        : null;
    final modelName = info?.displayName ?? 'model';

    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text('Loading $modelName...'),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final modelName = _selectedModelName;
    final errorMessage = state.errorMessage ?? 'An error occurred';
    return Row(
      children: [
        Icon(Icons.error_outline, size: 20, color: colorScheme.error),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText.rich(
            TextSpan(
              children: [
                if (modelName != null)
                  TextSpan(
                    text: '$modelName\n',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                TextSpan(
                  text: errorMessage,
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.goNamed(ChatSettingsScreen.name),
          child: const Text('Change'),
        ),
        TextButton(
          onPressed: () {
            context.read<GemmaModelBloc>().add(
              GemmaModelInitialize(modelType: state.modelType),
            );
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
