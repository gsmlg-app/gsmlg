import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';

/// Resolves which installed local model the active agent should use.
///
/// Prefers the agent's own [ModelConfig.localModelId] when it is installed,
/// then the model the bloc currently has selected, then the first installed
/// model. Returns null when no local model is installed.
String? resolveLocalModelId(
  ChatSettingsState settingsState,
  GemmaModelState modelState,
) {
  final installed = modelState.installedModels;
  final configured = settingsState.config.localModelId;
  if (configured != null && installed.contains(configured)) {
    return configured;
  }
  final selected = modelState.selectedModelId;
  if (selected != null && installed.contains(selected)) {
    return selected;
  }
  return installed.isEmpty ? null : installed.first;
}

/// App bar action that starts or stops the active agent's local model.
///
/// Shown only when the active agent uses local inference. Start loads the
/// agent's own model (falling back to any installed model), Stop unloads it.
class LocalModelActionButton extends StatelessWidget {
  const LocalModelActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
      builder: (context, settingsState) {
        if (settingsState.config.inferenceMode != ChatInferenceMode.local) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<GemmaModelBloc, GemmaModelState>(
          builder: (context, modelState) {
            final isLoading =
                modelState.status == GemmaModelStatus.loading ||
                modelState.status == GemmaModelStatus.checking;
            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final targetModelId = resolveLocalModelId(
              settingsState,
              modelState,
            );
            if (targetModelId == null) {
              // No local model installed; the status banner directs the
              // user to download one.
              return const SizedBox.shrink();
            }

            final isCurrentModelLoaded =
                modelState.status == GemmaModelStatus.ready &&
                modelState.selectedModelId == targetModelId;
            if (isCurrentModelLoaded) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  onPressed: () {
                    context.read<GemmaModelBloc>().add(
                      const GemmaModelUnload(),
                    );
                  },
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                onPressed: () {
                  context.read<GemmaModelBloc>().add(
                    GemmaModelSelect(
                      modelId: targetModelId,
                      config: settingsState.config,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
