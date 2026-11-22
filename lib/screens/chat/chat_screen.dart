import 'dart:typed_data';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_agent/app_agent.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/duo/duo_controller.dart';
import 'package:gsmlg/screens/agents/agent_editor_screen.dart';
import 'package:gsmlg/screens/agents/agent_model_config.dart';
import 'package:gsmlg/screens/agents/agents_screen.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

import 'chat_history_screen.dart';
import 'widgets/agent_activity_panel.dart';
import 'widgets/chat_composer_popovers.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_list.dart';
import 'widgets/clipboard_attachments.dart';
import 'widgets/local_model_action_button.dart';
import 'widgets/model_status_banner.dart';

class ChatScreen extends StatefulWidget {
  static const name = 'Chat';
  static const path = 'conversation';

  /// Conversation to open (deep link `?id=`); null keeps the current one.
  const ChatScreen({super.key, this.conversationId});

  final String? conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatPermissionMode _permissionMode = ChatPermissionMode.fullAccess;
  String? _editingConversationId;
  UserMessage? _editingMessage;
  ChatDraft? _draftBeforeEdit;

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
    final conversationId = widget.conversationId;
    if (conversationId != null &&
        chatBloc.state.conversation?.id != conversationId) {
      chatBloc.add(ChatLoadConversation(id: conversationId));
    } else if (chatBloc.state.conversation == null) {
      _startConversationWhenSettingsReady(settingsBloc);
    }
    _followOwner();
  }

  /// Makes the owner of the selected conversation the active agent, so the
  /// label, input bar, model banner and Duo status describe the owner.
  void _followOwner() {
    final owner = _ownerAgent();
    final settingsBloc = context.read<ChatSettingsBloc>();
    if (owner != null && owner.id != settingsBloc.state.activeAgentId) {
      settingsBloc.add(ChatSettingsSelectAgent(id: owner.id));
    }
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final conversationId = widget.conversationId;
    if (conversationId != null &&
        conversationId != oldWidget.conversationId &&
        context.read<ChatBloc>().state.conversation?.id != conversationId) {
      context.read<ChatBloc>().add(ChatLoadConversation(id: conversationId));
    }
  }

  /// With nothing selected, starts a conversation with the active agent once
  /// the settings (and so the active agent) are known.
  Future<void> _startConversationWhenSettingsReady(
    ChatSettingsBloc settingsBloc,
  ) async {
    if (!settingsBloc.state.isLoaded) {
      await settingsBloc.stream.firstWhere(
        (state) => state.isLoaded || state.status == ChatSettingsStatus.error,
      );
    }
    if (!mounted || context.read<ChatBloc>().state.conversation != null) {
      return;
    }
    _startNewConversation();
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
      if (_editingMessage != null) {
        _cancelEditingMessage();
        return;
      }
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
    // An owned conversation keeps its agent; selecting another one starts a
    // new conversation for it (handled by ChatBloc).
    context.read<ChatBloc>().add(
      ChatSelectAgent(
        agent: agent,
        conversationId: context.read<ChatBloc>().state.conversation?.id,
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

  bool _isEditingIn(String? conversationId) =>
      _editingMessage != null && _editingConversationId == conversationId;

  List<ChatAttachment> _editableAttachments(UserMessage message) {
    final result = List<ChatAttachment>.from(message.attachments);
    final image = message.imageBytes;
    if (image != null &&
        !result.any((a) => a.isImage || identical(a.bytes, image))) {
      result.add(
        ChatAttachment(
          id: '${message.id}-image',
          name: 'image.png',
          mimeType: 'image/png',
          sizeBytes: image.length,
          bytes: image,
        ),
      );
    }
    final audio = message.audioBytes;
    if (audio != null &&
        !result.any((a) => a.isAudio || identical(a.bytes, audio))) {
      result.add(
        ChatAttachment(
          id: '${message.id}-audio',
          name: 'audio.wav',
          mimeType: 'audio/wav',
          sizeBytes: audio.length,
          bytes: audio,
        ),
      );
    }
    return result;
  }

  void _beginEditingUserMessage(ChatState chatState, UserMessage message) {
    if (chatState.isBusy) return;
    final conversationId = chatState.conversation?.id;
    if (conversationId == null) return;
    final priorDraft = _isEditingIn(conversationId)
        ? _draftBeforeEdit
        : chatState.currentDraft;
    setState(() {
      _editingConversationId = conversationId;
      _editingMessage = message;
      _draftBeforeEdit = priorDraft;
    });
    final initialAttachments = _editableAttachments(message);
    _updateDraft(
      conversationId,
      ChatDraft(
        text: message.content,
        selectionBase: message.content.length,
        selectionExtent: message.content.length,
        attachments: initialAttachments,
      ),
    );
    if (initialAttachments.any(
      (a) => a.isImage && (a.bytes?.length ?? 0) > 512 * 1024,
    )) {
      _normalizeEditedDraftImages(conversationId, message.id);
    }
  }

  Future<void> _normalizeEditedDraftImages(
    String conversationId,
    String messageId,
  ) async {
    final bloc = context.read<ChatBloc>();
    final draft = bloc.state.drafts[conversationId];
    if (draft == null) return;
    var changed = false;
    final updated = <ChatAttachment>[];
    for (final attachment in draft.attachments) {
      final bytes = attachment.bytes;
      if (attachment.isImage && bytes != null && bytes.length > 512 * 1024) {
        final normalized = await ClipboardAttachments.normalizeImage(bytes);
        if (normalized != null) {
          changed = true;
          updated.add(
            attachment.copyWith(
              name: ClipboardAttachments.replaceExtension(
                attachment.name,
                normalized.extension,
              ),
              mimeType: normalized.mimeType,
              sizeBytes: normalized.bytes.length,
              bytes: normalized.bytes,
            ),
          );
          continue;
        }
      }
      updated.add(attachment);
    }
    if (!mounted || !changed) return;
    if (_editingConversationId != conversationId ||
        _editingMessage?.id != messageId) {
      return;
    }
    final latest = bloc.state.drafts[conversationId] ?? draft;
    _updateDraft(
      conversationId,
      ChatDraft(
        text: latest.text,
        selectionBase: latest.selectionBase,
        selectionExtent: latest.selectionExtent,
        attachments: updated,
      ),
    );
  }

  void _cancelEditingMessage() {
    final conversationId = _editingConversationId;
    final priorDraft = _draftBeforeEdit;
    if (_editingMessage == null) return;
    setState(() {
      _editingConversationId = null;
      _editingMessage = null;
      _draftBeforeEdit = null;
    });
    if (conversationId != null) {
      _updateDraft(conversationId, priorDraft ?? const ChatDraft());
    }
  }

  List<Message> _messagesForDisplay(ChatState state) {
    final editing = _editingMessage;
    if (editing == null || _editingConversationId != state.conversation?.id) {
      return state.messages;
    }
    final index = state.messages.indexWhere((m) => m.id == editing.id);
    if (index < 0) return state.messages;
    return state.messages.sublist(0, index);
  }

  /// The existing agent owning the selected conversation, if any.
  AgentDefinition? _ownerAgent() {
    final ownerId = context.read<ChatBloc>().state.conversation?.agentId;
    if (ownerId == null) return null;
    return context
        .read<ChatSettingsBloc>()
        .state
        .agents
        .where((agent) => agent.id == ownerId)
        .firstOrNull;
  }

  /// Edits the owner agent of an owned conversation; otherwise opens the
  /// agents home.
  void _openAgentSettings() {
    final owner = _ownerAgent();
    if (owner == null) {
      context.goNamed(AgentsScreen.name);
    } else {
      context.goNamed(
        AgentEditorScreen.name,
        pathParameters: {'agentId': owner.id},
      );
    }
  }

  void _startNewConversation() {
    final owner = _ownerAgent();
    if (owner != null) {
      context.read<ChatBloc>().add(
        ChatNewConversation(
          systemPrompt: owner.instructions,
          config: owner.config,
          agentId: owner.id,
          thinkingEnabled: owner.thinkingEnabled,
        ),
      );
      return;
    }
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
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listenWhen: (previous, current) =>
              previous.conversation?.id != current.conversation?.id ||
              previous.conversation?.agentId != current.conversation?.agentId,
          listener: (_, current) {
            if (_editingMessage != null &&
                _editingConversationId != current.conversation?.id) {
              _cancelEditingMessage();
            }
            _followOwner();
          },
        ),
        // The owner may only be known once the agents are loaded.
        BlocListener<ChatSettingsBloc, ChatSettingsState>(
          listenWhen: (previous, current) => previous.agents != current.agents,
          listener: (_, _) => _followOwner(),
        ),
      ],
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
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
              icon: const Icon(Icons.tune),
              tooltip: context.l10n.agentEditorEditTitle,
              onPressed: _openAgentSettings,
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
        final session = state.currentSession;
        final toolActivities = session?.toolActivities ?? const [];
        final subAgents = session?.subAgents ?? const [];
        return Column(
          children: [
            Expanded(
              child: ChatMessageList(
                messages: _messagesForDisplay(state),
                isStreaming: state.isStreaming,
                showThinking: _shouldShowThinking(settingsState),
                onEditUserMessage: (message) =>
                    _beginEditingUserMessage(state, message),
                onRegenerateResponse: (message) {
                  context.read<ChatBloc>().add(
                    ChatRegenerateResponse(
                      conversationId: state.conversation?.id,
                      messageId: message.id,
                    ),
                  );
                },
                onForkConversation: (message) {
                  context.read<ChatBloc>().add(
                    ChatForkConversation(
                      conversationId: state.conversation?.id,
                      messageId: message.id,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Forked conversation')),
                  );
                },
              ),
            ),
            if (toolActivities.isNotEmpty || subAgents.isNotEmpty)
              AgentActivityPanel(
                toolActivities: toolActivities,
                subAgents: subAgents,
                isStreaming: state.isStreaming,
              ),
          ],
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

  List<AgentModelChoice> _availableModelChoices(BuildContext context) {
    try {
      return configuredAgentModels(context);
    } catch (_) {
      return const [];
    }
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
              editingMessageId: _isEditingIn(chatState.conversation?.id)
                  ? _editingMessage?.id
                  : null,
              onCancelEdit: _cancelEditingMessage,
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
              permissionMode: _permissionMode,
              onPermissionModeChanged: (mode) =>
                  setState(() => _permissionMode = mode),
              selectedModelName: _localModelDisplayName(
                settingsState,
                modelState,
              ),
              selectedModelId: targetModelId,
              modelChoices: _availableModelChoices(context),
              onModelChoiceSelect: (choice) {
                _configureSession(
                  settingsState,
                  config: applyModelChoice(settingsState.config, choice),
                );
              },
              selectedAgentName: _agentLabel(settingsState),
              selectedAgentId: settingsState.activeAgentId,
              agents: settingsState.agents,
              onAgentSelect: _selectAgent,
              onModelTap: _openAgentSettings,
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
        return ChatInputBar(
          conversationId: chatState.conversation?.id,
          draft: chatState.currentDraft,
          editingMessageId: _isEditingIn(chatState.conversation?.id)
              ? _editingMessage?.id
              : null,
          onCancelEdit: _cancelEditingMessage,
          onDraftChanged: _updateDraft,
          onAttachmentsAdded: _addAttachments,
          isQueued: chatState.status == ChatStatus.queued,
          enabled: canSend,
          isStreaming: chatState.isBusy,
          supportsImage: true,
          historyTokenCount: _calculateHistoryTokens(chatState.conversation),
          thinkingEnabled:
              config.remoteThinkingEffort != RemoteThinkingEffort.off,
          thinkingEffort: config.remoteThinkingEffort,
          permissionMode: _permissionMode,
          onPermissionModeChanged: (mode) =>
              setState(() => _permissionMode = mode),
          selectedModelName: config.remoteModel,
          modelChoices: _availableModelChoices(context),
          onModelChoiceSelect: (choice) {
            _configureSession(
              settingsState,
              config: applyModelChoice(config, choice),
            );
          },
          selectedAgentName: _agentLabel(settingsState),
          selectedAgentId: settingsState.activeAgentId,
          agents: settingsState.agents,
          onAgentSelect: _selectAgent,
          onModelTap: _openAgentSettings,
          onThinkingEffortChanged: (effort) {
            _configureSession(
              settingsState,
              config: config.copyWith(remoteThinkingEffort: effort),
              thinkingEnabled: effort != RemoteThinkingEffort.off,
            );
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

  String _agentLabel(ChatSettingsState settingsState) {
    final agent = settingsState.activeAgent;
    if (agent == null) return context.l10n.agentsTitle;
    final avatar = agent.avatar;
    return avatar == null ? agent.name : '$avatar ${agent.name}';
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
    final editing = _editingMessage;
    if (editing != null &&
        _editingConversationId == chatState.conversation?.id) {
      setState(() {
        _editingMessage = null;
        _editingConversationId = null;
        _draftBeforeEdit = null;
      });
      context.read<ChatBloc>().add(
        ChatEditUserMessage(
          conversationId: chatState.conversation?.id,
          messageId: editing.id,
          content: message,
          imageBytes: imageBytes,
          audioBytes: audioBytes,
          attachments: attachments,
        ),
      );
      return;
    }
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
            onPressed: _openAgentSettings,
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
