import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModelStatusBanner extends StatelessWidget {
  const ModelStatusBanner({
    super.key,
    required this.state,
  });

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
      GemmaModelStatus.checking =>
        _buildCheckingContent(context),
      GemmaModelStatus.notInstalled => _buildNotInstalledContent(context),
      GemmaModelStatus.downloading => _buildDownloadingContent(context),
      GemmaModelStatus.installed => _buildInstalledContent(context),
      GemmaModelStatus.loading => _buildLoadingContent(context),
      GemmaModelStatus.error => _buildErrorContent(context),
      GemmaModelStatus.ready => const SizedBox.shrink(),
    };
  }

  Widget _buildCheckingContent(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Checking model status...'),
      ],
    );
  }

  Widget _buildNotInstalledContent(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.download, size: 20),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('Model not installed. Download to start chatting.'),
        ),
        TextButton(
          onPressed: () => _showDownloadDialog(context),
          child: const Text('Download'),
        ),
      ],
    );
  }

  Widget _buildDownloadingContent(BuildContext context) {
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
            Text('Downloading model... ${state.downloadProgress.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: state.downloadProgress / 100,
        ),
      ],
    );
  }

  Widget _buildInstalledContent(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 20),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('Model installed. Load to start chatting.'),
        ),
        TextButton(
          onPressed: () {
            final settingsState = context.read<ChatSettingsBloc>().state;
            context
                .read<GemmaModelBloc>()
                .add(GemmaModelLoad(config: settingsState.config));
          },
          child: const Text('Load'),
        ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Loading model...'),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.error_outline, size: 20, color: colorScheme.error),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            state.errorMessage ?? 'An error occurred',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () {
            context
                .read<GemmaModelBloc>()
                .add(GemmaModelInitialize(modelType: state.modelType));
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Download Model'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a model to download:'),
            SizedBox(height: 16),
            Text(
              'Gemma 2B-IT is recommended for most devices. '
              'It requires about 1.5GB of storage.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GemmaModelBloc>().add(const GemmaModelInstall(
                    modelType: GemmaModelType.gemma2bIt,
                    url:
                        'https://huggingface.co/google/gemma-3-2b-it/resolve/main/gemma-3-2b-it-gpu-int8.task',
                  ));
            },
            child: const Text('Download Gemma 2B'),
          ),
        ],
      ),
    );
  }
}
