import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/settings/model_management_screen.dart';

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
          child: Text('No model available. Download one to start chatting.'),
        ),
        TextButton(
          onPressed: () => context.goNamed(ModelManagementScreen.name),
          child: const Text('Get Models'),
        ),
      ],
    );
  }

  Widget _buildDownloadingContent(BuildContext context) {
    final downloadId = state.downloadingModelId;
    final info = downloadId != null ? GemmaModelInfo.findById(downloadId) : null;
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
            Text('Downloading $modelName... ${state.downloadProgress.toStringAsFixed(1)}%'),
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
    // Auto-load the model so the user doesn't have to press a button.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final settingsState = context.read<ChatSettingsBloc>().state;
      context
          .read<GemmaModelBloc>()
          .add(GemmaModelLoad(config: settingsState.config));
    });

    final selectedId = state.selectedModelId;
    final info = selectedId != null ? GemmaModelInfo.findById(selectedId) : null;
    final modelName = info?.displayName ?? 'Model';

    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Loading $modelName...'),
        ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    final selectedId = state.selectedModelId;
    final info = selectedId != null ? GemmaModelInfo.findById(selectedId) : null;
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
          onPressed: () => context.goNamed(ModelManagementScreen.name),
          child: const Text('Manage'),
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

}
