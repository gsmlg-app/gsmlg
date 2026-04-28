import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/chat/chat_history_screen.dart';
import 'package:gsmlg/screens/chat/chat_settings_screen.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';
import 'package:gsmlg/screens/chat/widgets/chat_message_list.dart';
import 'package:gsmlg/screens/chat/widgets/model_status_banner.dart';

class HomeScreen extends StatefulWidget {
  static const name = 'Home';
  static const path = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings and conversation history.
    // Model initialization is handled by the chat screen, not here.
    context.read<ChatSettingsBloc>().add(const ChatSettingsLoad());
    context.read<ChatBloc>().add(const ChatLoadHistory());

    // Initialize model (check installed models and load selected model).
    context.read<GemmaModelBloc>().add(const GemmaModelInitialize());
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
          title: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return Text(state.conversation?.title ?? 'Chat');
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
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
                buildWhen: (previous, current) =>
                    previous.config.inferenceMode !=
                        current.config.inferenceMode ||
                    previous.config.remoteAccountId !=
                        current.config.remoteAccountId ||
                    previous.config.remoteBaseUrl !=
                        current.config.remoteBaseUrl ||
                    previous.config.remoteModel != current.config.remoteModel,
                builder: (context, settingsState) {
                  if (settingsState.config.inferenceMode ==
                      ChatInferenceMode.remote) {
                    return _buildRemoteStatusBanner(settingsState.config);
                  }

                  return BlocBuilder<GemmaModelBloc, GemmaModelState>(
                    builder: (context, modelState) {
                      return ModelStatusBanner(state: modelState);
                    },
                  );
                },
              ),
              // Chat messages
              Expanded(
                child: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
                  buildWhen: (previous, current) =>
                      previous.thinkingEnabled != current.thinkingEnabled,
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
                ),
              ),
              BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
                builder: (context, settingsState) {
                  if (settingsState.config.inferenceMode ==
                      ChatInferenceMode.remote) {
                    return BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, chatState) {
                        final canSend =
                            settingsState.config.isRemoteConfigured &&
                            chatState.canSendMessage;
                        return ChatInputBar(
                          enabled: canSend,
                          isStreaming: chatState.isStreaming,
                          thinkingEnabled: settingsState.thinkingEnabled,
                          selectedModelName:
                              'Remote: ${settingsState.config.remoteModel}',
                          onModelTap: () =>
                              context.goNamed(ChatSettingsScreen.name),
                          onThinkingToggle: (enabled) {
                            context.read<ChatSettingsBloc>().add(
                              ChatSettingsToggleThinking(enabled: enabled),
                            );
                          },
                          onSend:
                              (message, {imageBytes, audioBytes, attachments}) {
                                context.read<ChatBloc>().add(
                                  ChatSendMessage(
                                    content: message,
                                    imageBytes: imageBytes,
                                    audioBytes: audioBytes,
                                    attachments: attachments ?? const [],
                                    systemPrompt: chatState.conversation == null
                                        ? settingsState.defaultSystemPrompt
                                        : null,
                                  ),
                                );
                              },
                          onStop: () {
                            context.read<ChatBloc>().add(
                              const ChatStopGeneration(),
                            );
                          },
                        );
                      },
                    );
                  }

                  return BlocBuilder<GemmaModelBloc, GemmaModelState>(
                    builder: (context, modelState) {
                      final selectedId = modelState.selectedModelId;
                      final modelInfo = selectedId != null
                          ? GemmaModelInfo.findById(selectedId)
                          : null;
                      return BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, chatState) {
                          final canSend =
                              modelState.isReady && chatState.canSendMessage;
                          return ChatInputBar(
                            enabled: canSend,
                            isStreaming: chatState.isStreaming,
                            supportsImage:
                                modelInfo?.effectiveSupportsMultimodal ?? false,
                            supportsAudio:
                                modelInfo?.effectiveSupportsAudio ?? false,
                            supportsThinking:
                                modelInfo?.effectiveSupportsThinking ?? false,
                            thinkingEnabled: settingsState.thinkingEnabled,
                            selectedModelName: modelInfo?.displayName,
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
                            onSend:
                                (
                                  message, {
                                  imageBytes,
                                  audioBytes,
                                  attachments,
                                }) {
                                  context.read<ChatBloc>().add(
                                    ChatSendMessage(
                                      content: message,
                                      imageBytes: imageBytes,
                                      audioBytes: audioBytes,
                                      attachments: attachments ?? const [],
                                      systemPrompt:
                                          chatState.conversation == null
                                          ? settingsState.defaultSystemPrompt
                                          : null,
                                    ),
                                  );
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
      ),
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
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

  Widget _buildRemoteStatusBanner(ModelConfig config) {
    if (config.isRemoteConfigured) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colorScheme.tertiaryContainer,
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Remote LLM needs an account, base URL, and model.'),
          ),
          TextButton(
            onPressed: () => context.goNamed(ChatSettingsScreen.name),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}
