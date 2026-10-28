import 'dart:typed_data';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/duo/duo_controller.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

import 'chat_history_screen.dart';
import 'chat_settings_screen.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/local_model_action_button.dart';
import 'widgets/model_status_banner.dart';

class ChatScreen extends StatefulWidget {
  static const name = 'Chat';
  static const path = '/chat';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool get _isDuoConnected {
    final duo = DuoDisplayManager.instance;
    return duo != null && !duo.secondary && duo.connected;
  }

  @override
  void initState() {
    super.initState();
    final duo = DuoDisplayManager.instance;
    if (duo != null && !duo.secondary) {
      duo.addListener(_onDuoStateChanged);
      _setupDuoHandlers(duo);
    }

    // Initialize model and load settings
    final settingsBloc = context.read<ChatSettingsBloc>();
    final modelBloc = context.read<GemmaModelBloc>();

    // Load settings first
    settingsBloc.add(const ChatSettingsLoad());

    // Initialize model check
    modelBloc.add(const GemmaModelInitialize());

    // Load conversation history
    final chatBloc = context.read<ChatBloc>();
    chatBloc.add(const ChatLoadHistory());
    if (chatBloc.state.conversation == null) {
      chatBloc.add(const ChatNewConversation());
    }
  }

  @override
  void dispose() {
    final duo = DuoDisplayManager.instance;
    if (duo != null && !duo.secondary) {
      duo.removeListener(_onDuoStateChanged);
      if (duo.onChatSend != null) duo.onChatSend = null;
      duo.onTextInput = null;
      if (duo.onChatStop != null) duo.onChatStop = null;
      if (duo.onChatSelectAgent != null) duo.onChatSelectAgent = null;
      if (duo.onEscKey != null) duo.onEscKey = null;
      duo.updateChatState(null);
    }
    super.dispose();
  }

  void _onDuoStateChanged() {
    if (mounted) setState(() {});
  }

  void _setupDuoHandlers(DuoDisplayManager duo) {
    duo.onTextInput = (text) {
      if (!mounted) return;
      final state = context.read<ChatBloc>().state;
      _updateDraft(
        state.conversation?.id,
        ChatDraft(
          text: text,
          selectionBase: text.length,
          selectionExtent: text.length,
          attachments: state.currentDraft.attachments,
        ),
      );
    };
    duo.onChatSend = (text, {attachments}) {
      if (!mounted) return;
      final settingsState = _sessionSettings(
        context.read<ChatSettingsBloc>().state,
      );
      final chatState = context.read<ChatBloc>().state;
      if (chatState.isBusy) return;
      _sendMessage(
        settingsState,
        chatState,
        text,
        attachments: attachments ?? const [],
      );
    };

    duo.onChatStop = () {
      if (!mounted) return;
      context.read<ChatBloc>().add(
        ChatStopGeneration(
          conversationId: context.read<ChatBloc>().state.conversation?.id,
        ),
      );
    };

    duo.onChatSelectAgent = (agentId) {
      if (!mounted) return;
      _selectAgent(agentId);
    };

    duo.onEscKey = () {
      if (!mounted) return;
      final chatState = context.read<ChatBloc>().state;
      if (chatState.isBusy) {
        context.read<ChatBloc>().add(
          ChatStopGeneration(
            conversationId: context.read<ChatBloc>().state.conversation?.id,
          ),
        );
      }
    };
  }

  ChatSettingsState _sessionSettings(ChatSettingsState defaults) {
    final state = context.read<ChatBloc>().state;
    final id = state.conversation?.id;
    final session = id == null ? null : state.sessionFor(id);
    if (session?.config == null) return defaults;
    return defaults.copyWith(
      config: session!.config,
      activeAgentId: session.agentId,
      clearActiveAgent: session.agentId == null,
      thinkingEnabled: session.thinkingEnabled ?? defaults.thinkingEnabled,
      defaultSystemPrompt: session.systemPrompt,
      clearSystemPrompt: session.systemPrompt == null,
    );
  }

  void _configureSession(
    ChatSettingsState settings, {
    ModelConfig? config,
    bool? thinkingEnabled,
    String? conversationId,
  }) {
    context.read<ChatBloc>().add(
      ChatConfigureSession(
        conversationId:
            conversationId ?? context.read<ChatBloc>().state.conversation?.id,
        config: config ?? settings.config,
        agentId: settings.activeAgentId,
        thinkingEnabled: thinkingEnabled ?? settings.thinkingEnabled,
        systemPrompt: settings.defaultSystemPrompt,
      ),
    );
  }

  void _selectAgent(String agentId) {
    if (context.read<ChatBloc>().state.isBusy) return;
    final settings = context.read<ChatSettingsBloc>().state;
    final agent = settings.agents.where((a) => a.id == agentId).firstOrNull;
    if (agent == null) return;
    context.read<ChatBloc>().add(
      ChatConfigureSession(
        conversationId: context.read<ChatBloc>().state.conversation?.id,
        config: agent.config,
        agentId: agent.id,
        thinkingEnabled: agent.thinkingEnabled,
        systemPrompt: agent.systemPrompt,
      ),
    );
  }

  void _updateDraft(String? conversationId, ChatDraft draft) {
    if (conversationId == null) return;
    context.read<ChatBloc>().add(
      ChatUpdateDraft(
        conversationId: conversationId,
        text: draft.text,
        selectionBase: draft.selectionBase,
        selectionExtent: draft.selectionExtent,
        attachments: draft.attachments,
      ),
    );
  }

  void _addAttachments(
    String? conversationId,
    List<ChatAttachment> attachments,
  ) {
    if (conversationId == null) return;
    final state = context.read<ChatBloc>().state;
    if (!state.sessions.containsKey(conversationId)) return;
    final draft = state.drafts[conversationId] ?? const ChatDraft();
    _updateDraft(
      conversationId,
      ChatDraft(
        text: draft.text,
        selectionBase: draft.selectionBase,
        selectionExtent: draft.selectionExtent,
        attachments: [...draft.attachments, ...attachments],
      ),
    );
  }

  void _startNewConversation() {
    final settingsState = context.read<ChatSettingsBloc>().state;
    context.read<ChatBloc>().add(
      ChatNewConversation(
        systemPrompt: settingsState.defaultSystemPrompt,
        config: settingsState.config,
        agentId: settingsState.activeAgentId,
        thinkingEnabled: settingsState.thinkingEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(const Key(HomeScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          restoreNavigation: true,
          title: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
            builder: (context, globalSettings) {
              context.watch<ChatBloc>();
              final settingsState = _sessionSettings(globalSettings);
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
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) => LocalModelActionButton(
                settings: _sessionSettings(
                  context.watch<ChatSettingsBloc>().state,
                ),
                busy: state.sessions.values.any(
                  (session) =>
                      session.isBusy &&
                      session.config?.inferenceMode == ChatInferenceMode.local,
                ),
              ),
            ),
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
              builder: (context, globalSettings) {
                context.watch<ChatBloc>();
                final settingsState = _sessionSettings(globalSettings);
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
                builder: (context, globalSettings) {
                  context.watch<ChatBloc>();
                  final settingsState = _sessionSettings(globalSettings);
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
              builder: (context, globalSettings) {
                context.watch<ChatBloc>();
                final settingsState = _sessionSettings(globalSettings);
                if (_isDuoConnected) {
                  return _buildDuoFloatingCapsule(context, settingsState);
                }
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
              ChatEditUserMessage(
                conversationId: state.conversation?.id,
                messageId: message.id,
                content: content,
              ),
            );
          },
          onRegenerateResponse: (message) {
            context.read<ChatBloc>().add(
              ChatRegenerateResponse(
                conversationId: state.conversation?.id,
                messageId: message.id,
              ),
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
            final canSend = isCurrentModelLoaded || targetModelId != null;
            return ChatInputBar(
              conversationId: chatState.conversation?.id,
              draft: chatState.currentDraft,
              onDraftChanged: _updateDraft,
              onAttachmentsAdded: _addAttachments,
              isQueued: chatState.status == ChatStatus.queued,
              enabled: canSend,
              isStreaming: chatState.isBusy,
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
                _selectAgent(agentId);
              },
              onModelTap: () => context.goNamed(ChatAgentsSettingsScreen.name),
              onThinkingToggle: (enabled) {
                _configureSession(settingsState, thinkingEnabled: enabled);
              },
              onSend: (message, {imageBytes, audioBytes, attachments}) {
                _sendMessage(
                  settingsState,
                  chatState,
                  message,
                  imageBytes: imageBytes,
                  audioBytes: audioBytes,
                  attachments: attachments ?? const [],
                );
              },
              onStop: () {
                context.read<ChatBloc>().add(
                  ChatStopGeneration(
                    conversationId: context
                        .read<ChatBloc>()
                        .state
                        .conversation
                        ?.id,
                  ),
                );
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
        final canSend = settingsState.config.isRemoteConfigured;
        final isDeepSeek = config.remoteProvider == RemoteLlmProvider.deepSeek;
        return ChatInputBar(
          conversationId: chatState.conversation?.id,
          draft: chatState.currentDraft,
          onDraftChanged: _updateDraft,
          onAttachmentsAdded: _addAttachments,
          isQueued: chatState.status == ChatStatus.queued,
          enabled: canSend,
          isStreaming: chatState.isBusy,
          historyTokenCount: _calculateHistoryTokens(chatState.conversation),
          thinkingEnabled: isDeepSeek
              ? config.remoteThinkingEffort != RemoteThinkingEffort.off
              : settingsState.thinkingEnabled,
          thinkingEffort: isDeepSeek ? config.remoteThinkingEffort : null,
          selectedAgentName: settingsState.activeAgent?.name ?? 'Select agent',
          selectedAgentId: settingsState.activeAgentId,
          agents: settingsState.agents,
          onAgentSelect: (agentId) {
            _selectAgent(agentId);
          },
          onModelTap: () => context.goNamed(ChatAgentsSettingsScreen.name),
          onThinkingEffortChanged: isDeepSeek
              ? (effort) {
                  _configureSession(
                    settingsState,
                    config: config.copyWith(remoteThinkingEffort: effort),
                  );
                }
              : null,
          onThinkingToggle: isDeepSeek
              ? null
              : (enabled) {
                  _configureSession(settingsState, thinkingEnabled: enabled);
                },
          onSend: (message, {imageBytes, audioBytes, attachments}) {
            _sendMessage(
              settingsState,
              chatState,
              message,
              imageBytes: imageBytes,
              audioBytes: audioBytes,
              attachments: attachments ?? const [],
            );
          },
          onStop: () {
            context.read<ChatBloc>().add(
              ChatStopGeneration(
                conversationId: context.read<ChatBloc>().state.conversation?.id,
              ),
            );
          },
        );
      },
    );
  }

  void _sendMessage(
    ChatSettingsState settingsState,
    ChatState chatState,
    String message, {
    Uint8List? imageBytes,
    Uint8List? audioBytes,
    List<ChatAttachment> attachments = const [],
  }) {
    if (!chatState.canSendMessage) return;
    var config = settingsState.config;
    if (config.inferenceMode == ChatInferenceMode.local &&
        config.localModelId == null) {
      config = config.copyWith(
        localModelId: resolveLocalModelId(
          settingsState,
          context.read<GemmaModelBloc>().state,
        ),
      );
    }
    _configureSession(
      settingsState,
      config: config,
      conversationId: chatState.conversation?.id,
    );
    context.read<ChatBloc>().add(
      ChatSendMessage(
        conversationId: chatState.conversation?.id,
        config: config,
        agentId: settingsState.activeAgentId,
        content: message,
        systemPrompt: settingsState.defaultSystemPrompt,
        imageBytes: imageBytes,
        audioBytes: audioBytes,
        attachments: attachments,
      ),
    );
  }

  void _syncDuoChatState({
    required ChatSettingsState settingsState,
    required GemmaModelState modelState,
    required ChatState chatState,
  }) {
    final duo = DuoDisplayManager.instance;
    if (duo == null || duo.secondary || !duo.connected) return;

    final isRemote =
        settingsState.config.inferenceMode == ChatInferenceMode.remote;
    final modelName = isRemote
        ? settingsState.config.remoteModel
        : _localModelDisplayName(settingsState, modelState);

    final canSend =
        (isRemote
            ? settingsState.config.isRemoteConfigured
            : (modelState.status == GemmaModelStatus.ready)) &&
        chatState.canSendMessage;

    final gemmaModelInfo = modelState.selectedModelId != null
        ? GemmaModelInfo.findById(modelState.selectedModelId!)
        : null;

    final duoState = DuoChatState(
      conversationId: chatState.conversation?.id,
      draftText: chatState.currentDraft.text,
      isPreparing: chatState.status == ChatStatus.preparing,
      isStreaming: chatState.isBusy,
      canSend: canSend,
      modelName: modelName,
      activeAgentName:
          settingsState.activeAgent?.name ?? modelName ?? 'Assistant',
      activeAgentId: settingsState.activeAgentId,
      agents: settingsState.agents
          .map((a) => DuoChatAgent(id: a.id, name: a.name))
          .toList(),
      supportsImage: isRemote
          ? true
          : (gemmaModelInfo?.effectiveSupportsMultimodal ?? false),
      supportsAudio: isRemote
          ? false
          : (gemmaModelInfo?.effectiveSupportsAudio ?? false),
      historyTokens: _calculateHistoryTokens(chatState.conversation),
    );

    duo.updateChatState(duoState);
  }

  Widget _buildDuoFloatingCapsule(
    BuildContext context,
    ChatSettingsState settingsState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<GemmaModelBloc, GemmaModelState>(
      builder: (context, modelState) {
        return BlocBuilder<ChatBloc, ChatState>(
          builder: (context, chatState) {
            _syncDuoChatState(
              settingsState: settingsState,
              modelState: modelState,
              chatState: chatState,
            );

            final isRemote =
                settingsState.config.inferenceMode == ChatInferenceMode.remote;
            final modelName = isRemote
                ? settingsState.config.remoteModel
                : _localModelDisplayName(settingsState, modelState);
            final agentName =
                settingsState.activeAgent?.name ?? modelName ?? 'Assistant';

            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: Material(
                    elevation: 2,
                    shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
                    color: colorScheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        DuoDisplayManager.instance?.requestSecondaryFocus();
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (chatState.isStreaming) ...[
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$agentName generating...',
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.stop_circle,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                tooltip: 'Stop generation',
                                onPressed: () {
                                  context.read<ChatBloc>().add(
                                    const ChatStopGeneration(),
                                  );
                                },
                              ),
                            ] else ...[
                              Icon(
                                Icons.keyboard_alt_outlined,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$agentName · Input on Display 6',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Duo Active',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
