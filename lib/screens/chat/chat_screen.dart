import 'dart:typed_data';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

import 'chat_history_screen.dart';
import 'chat_settings_screen.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/local_model_action_button.dart';
import 'widgets/model_status_banner.dart';
import 'widgets/system_metrics_indicator.dart';

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
          title: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
            builder: (context, settingsState) {
              final modelName =
                  settingsState.config.inferenceMode == ChatInferenceMode.remote
                  ? settingsState.config.remoteModel
                  : _localModelDisplayName(
                      settingsState,
                      context.watch<GemmaModelBloc>().state,
                    );
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
            const SystemMetricsIndicator(),
            const LocalModelActionButton(),
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
              onPressed: () => context.goNamed(ChatAgentsSettingsScreen.name),
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
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
            Expanded(
              child: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
                buildWhen: (prev, curr) =>
                    prev.thinkingEnabled != curr.thinkingEnabled ||
                    prev.config.inferenceMode != curr.config.inferenceMode ||
                    prev.config.remoteThinkingEffort !=
                        curr.config.remoteThinkingEffort,
                builder: (context, settingsState) {
                  if (settingsState.config.inferenceMode ==
                      ChatInferenceMode.local) {
                    return BlocBuilder<GemmaModelBloc, GemmaModelState>(
                      buildWhen: (prev, curr) => prev.status != curr.status,
                      builder: (context, modelState) {
                        if (GemmaModelInfo.platformModels.isEmpty) {
                          return _buildUnavailableView();
                        }
                        return _buildConversationView(settingsState);
                      },
                    );
                  }
                  return _buildConversationView(settingsState);
                },
              ),
            ),
            BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
              builder: (context, settingsState) {
                if (settingsState.config.inferenceMode ==
                    ChatInferenceMode.remote) {
                  return _buildRemoteInputBar(settingsState);
                }
                return _buildLocalInputBar(settingsState);
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _localModelDisplayName(
    ChatSettingsState settingsState,
    GemmaModelState modelState,
  ) {
    final modelId =
        resolveLocalModelId(settingsState, modelState) ??
        settingsState.config.localModelId;
    if (modelId == null) return null;
    return GemmaModelInfo.findById(modelId)?.displayName ?? modelId;
  }

  Widget _buildConversationView(ChatSettingsState settingsState) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.conversation == null) return _buildWelcomeView();
        return ChatMessageList(
          messages: state.messages,
          isStreaming: state.isStreaming,
          showThinking: _shouldShowThinking(settingsState),
          onEditUserMessage: (message, content) {
            context.read<ChatBloc>().add(
              ChatEditUserMessage(messageId: message.id, content: content),
            );
          },
          onRegenerateResponse: (message) {
            context.read<ChatBloc>().add(
              ChatRegenerateResponse(messageId: message.id),
            );
          },
        );
      },
    );
  }

  bool _shouldShowThinking(ChatSettingsState settingsState) {
    final config = settingsState.config;
    if (config.inferenceMode == ChatInferenceMode.remote &&
        config.remoteProvider == RemoteLlmProvider.deepSeek) {
      return config.remoteThinkingEffort != RemoteThinkingEffort.off;
    }
    return settingsState.thinkingEnabled;
  }

  Widget _buildLocalInputBar(ChatSettingsState settingsState) {
    return BlocBuilder<GemmaModelBloc, GemmaModelState>(
      builder: (context, modelState) {
        final targetModelId = resolveLocalModelId(settingsState, modelState);
        final selectedId = modelState.selectedModelId;
        final modelInfo = selectedId != null
            ? GemmaModelInfo.findById(selectedId)
            : null;
        final isCurrentModelLoaded =
            modelState.status == GemmaModelStatus.ready &&
            targetModelId != null &&
            selectedId == targetModelId;
        return BlocBuilder<ChatBloc, ChatState>(
          builder: (context, chatState) {
            final canSend = isCurrentModelLoaded && chatState.canSendMessage;
            return ChatInputBar(
              enabled: canSend,
              isStreaming: chatState.isStreaming,
              historyTokenCount: _calculateHistoryTokens(
                chatState.conversation,
              ),
              supportsImage: modelInfo?.effectiveSupportsMultimodal ?? false,
              supportsAudio: modelInfo?.effectiveSupportsAudio ?? false,
              supportsThinking: modelInfo?.effectiveSupportsThinking ?? false,
              thinkingEnabled: settingsState.thinkingEnabled,
              selectedAgentName:
                  settingsState.activeAgent?.name ?? 'Select agent',
              selectedAgentId: settingsState.activeAgentId,
              agents: settingsState.agents,
              onAgentSelect: (agentId) {
                context.read<ChatSettingsBloc>().add(
                  ChatSettingsSelectAgent(id: agentId),
                );
              },
              onModelTap: () => context.goNamed(ChatAgentsSettingsScreen.name),
              onThinkingToggle: (enabled) {
                context.read<ChatSettingsBloc>().add(
                  ChatSettingsToggleThinking(enabled: enabled),
                );
              },
              onSend: (message, {imageBytes, audioBytes, attachments}) {
                _sendMessage(
                  chatState,
                  message,
                  imageBytes: imageBytes,
                  audioBytes: audioBytes,
                  attachments: attachments ?? const [],
                );
              },
              onStop: () {
                context.read<ChatBloc>().add(const ChatStopGeneration());
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRemoteInputBar(ChatSettingsState settingsState) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, chatState) {
        final config = settingsState.config;
        final canSend =
            settingsState.config.isRemoteConfigured && chatState.canSendMessage;
        final isDeepSeek = config.remoteProvider == RemoteLlmProvider.deepSeek;
        return ChatInputBar(
          enabled: canSend,
          isStreaming: chatState.isStreaming,
          historyTokenCount: _calculateHistoryTokens(chatState.conversation),
          thinkingEnabled: isDeepSeek
              ? config.remoteThinkingEffort != RemoteThinkingEffort.off
              : settingsState.thinkingEnabled,
          thinkingEffort: isDeepSeek ? config.remoteThinkingEffort : null,
          selectedAgentName: settingsState.activeAgent?.name ?? 'Select agent',
          selectedAgentId: settingsState.activeAgentId,
          agents: settingsState.agents,
          onAgentSelect: (agentId) {
            context.read<ChatSettingsBloc>().add(
              ChatSettingsSelectAgent(id: agentId),
            );
          },
          onModelTap: () => context.goNamed(ChatAgentsSettingsScreen.name),
          onThinkingEffortChanged: isDeepSeek
              ? (effort) {
                  context.read<ChatSettingsBloc>().add(
                    ChatSettingsUpdateConfig(
                      config: config.copyWith(remoteThinkingEffort: effort),
                    ),
                  );
                }
              : null,
          onThinkingToggle: isDeepSeek
              ? null
              : (enabled) {
                  context.read<ChatSettingsBloc>().add(
                    ChatSettingsToggleThinking(enabled: enabled),
                  );
                },
          onSend: (message, {imageBytes, audioBytes, attachments}) {
            _sendMessage(
              chatState,
              message,
              imageBytes: imageBytes,
              audioBytes: audioBytes,
              attachments: attachments ?? const [],
            );
          },
          onStop: () {
            context.read<ChatBloc>().add(const ChatStopGeneration());
          },
        );
      },
    );
  }

  void _sendMessage(
    ChatState chatState,
    String message, {
    Uint8List? imageBytes,
    Uint8List? audioBytes,
    List<ChatAttachment> attachments = const [],
  }) {
    if (chatState.conversation == null) {
      _startNewConversation();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatBloc>().add(
          ChatSendMessage(
            content: message,
            imageBytes: imageBytes,
            audioBytes: audioBytes,
            attachments: attachments,
          ),
        );
      });
    } else {
      context.read<ChatBloc>().add(
        ChatSendMessage(
          content: message,
          imageBytes: imageBytes,
          audioBytes: audioBytes,
          attachments: attachments,
        ),
      );
    }
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
            onPressed: () => context.goNamed(ChatAgentsSettingsScreen.name),
            child: const Text('Settings'),
          ),
        ],
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

  int _calculateHistoryTokens(Conversation? conversation) {
    if (conversation == null) return 0;
    var tokens = 0;
    if (conversation.systemPrompt != null) {
      tokens += (conversation.systemPrompt!.length / 4).round();
    }
    for (final msg in conversation.messages) {
      if (msg is UserMessage) {
        tokens += (msg.contentWithAttachments().length / 4).round();
      } else {
        tokens += (msg.content.length / 4).round();
        if (msg is AssistantMessage && msg.thinkingContent != null) {
          tokens += (msg.thinkingContent!.length / 4).round();
        }
      }
    }
    return tokens;
  }
}
