import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

import 'chat_history_screen.dart';
import 'chat_settings_screen.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/model_status_banner.dart';

class ChatScreen extends StatefulWidget {
  static const name = 'Chat';
  static const path = '/chat';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize model and load settings
    final settingsBloc = context.read<ChatSettingsBloc>();
    final modelBloc = context.read<GemmaModelBloc>();

    // Load settings first
    settingsBloc.add(const ChatSettingsLoad());

    // Initialize model check
    modelBloc.add(const GemmaModelInitialize());

    // Load conversation history
    context.read<ChatBloc>().add(const ChatLoadHistory());
  }

  /// Extract a short display name from an installed model filename.
  String _shortModelName(String modelId) {
    // Strip file extension and common suffixes
    var name = modelId;
    for (final ext in ['.litertlm', '.task', '.bin']) {
      if (name.endsWith(ext)) name = name.substring(0, name.length - ext.length);
    }
    // Strip common suffixes like _multi-prefill-seq_q8_ekv4096
    final suffixIdx = name.indexOf('_multi-prefill');
    if (suffixIdx > 0) name = name.substring(0, suffixIdx);
    return name;
  }

  void _startNewConversation() {
    final settingsState = context.read<ChatSettingsBloc>().state;
    context.read<ChatBloc>().add(
      ChatNewConversation(systemPrompt: settingsState.defaultSystemPrompt),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key(HomeScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          title: BlocBuilder<GemmaModelBloc, GemmaModelState>(
            builder: (context, modelState) {
              final selectedId = modelState.selectedModelId;
              final modelInfo = selectedId != null
                  ? GemmaModelInfo.findById(selectedId)
                  : null;
              final modelName = modelInfo?.displayName;
              return BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  final title = state.conversation?.title ?? 'Chat';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16)),
                      if (modelName != null)
                        Text(
                          modelName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'History',
              onPressed: () => context.goNamed(ChatHistoryScreen.name),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Chat',
              onPressed: _startNewConversation,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () => context.goNamed(ChatSettingsScreen.name),
            ),
          ],
        ),
        body: Column(
          children: [
            // Model status banner
            BlocBuilder<GemmaModelBloc, GemmaModelState>(
              builder: (context, modelState) {
                return ModelStatusBanner(state: modelState);
              },
            ),
            // Chat messages
            Expanded(
              child: BlocBuilder<GemmaModelBloc, GemmaModelState>(
                buildWhen: (prev, curr) => prev.status != curr.status,
                builder: (context, modelState) {
                  if (GemmaModelInfo.platformModels.isEmpty) {
                    return _buildUnavailableView();
                  }
                  return BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
                    buildWhen: (prev, curr) =>
                        prev.thinkingEnabled != curr.thinkingEnabled,
                    builder: (context, settingsState) {
                      return BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          if (state.conversation == null) {
                            return _buildWelcomeView();
                          }
                          return ChatMessageList(
                            messages: state.messages,
                            isStreaming: state.isStreaming,
                            showThinking: settingsState.thinkingEnabled,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Input bar
            BlocBuilder<GemmaModelBloc, GemmaModelState>(
              builder: (context, modelState) {
                final selectedId = modelState.selectedModelId;
                final modelInfo = selectedId != null
                    ? GemmaModelInfo.findById(selectedId)
                    : null;
                return BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
                  buildWhen: (prev, curr) =>
                      prev.thinkingEnabled != curr.thinkingEnabled,
                  builder: (context, settingsState) {
                    return BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, chatState) {
                        final canSend =
                            modelState.isReady && chatState.canSendMessage;
                        return ChatInputBar(
                          enabled: canSend,
                          isStreaming: chatState.isStreaming,
                          supportsImage: modelInfo?.effectiveSupportsMultimodal ?? false,
                          supportsAudio: modelInfo?.effectiveSupportsAudio ?? false,
                          supportsThinking:
                              modelInfo?.effectiveSupportsThinking ?? false,
                          thinkingEnabled: settingsState.thinkingEnabled,
                          selectedModelName: modelInfo?.displayName ??
                              (selectedId != null ? _shortModelName(selectedId) : null),
                          selectedModelId: selectedId,
                          installedModels: modelState.installedModels,
                          onModelSelect: (modelId) {
                            context.read<GemmaModelBloc>().add(
                              GemmaModelSelect(modelId: modelId),
                            );
                          },
                          onModelTap: () =>
                              context.goNamed(ChatSettingsScreen.name),
                          onThinkingToggle: (enabled) {
                            context.read<ChatSettingsBloc>().add(
                              ChatSettingsToggleThinking(enabled: enabled),
                            );
                          },
                          onSend: (message, {imageBytes, audioBytes}) {
                            if (chatState.conversation == null) {
                              _startNewConversation();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context.read<ChatBloc>().add(
                                  ChatSendMessage(
                                    content: message,
                                    imageBytes: imageBytes,
                                    audioBytes: audioBytes,
                                  ),
                                );
                              });
                            } else {
                              context.read<ChatBloc>().add(
                                ChatSendMessage(
                                  content: message,
                                  imageBytes: imageBytes,
                                  audioBytes: audioBytes,
                                ),
                              );
                            }
                          },
                          onStop: () {
                            context.read<ChatBloc>().add(
                              const ChatStopGeneration(),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableView() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.desktop_access_disabled,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'On-device AI is not available on this device',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'On-device models require Apple Silicon (arm64) on macOS.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a new conversation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a message below to begin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
