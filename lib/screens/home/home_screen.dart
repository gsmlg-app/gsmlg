import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/chat/chat_history_screen.dart';
import 'package:gsmlg/screens/chat/chat_settings_screen.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';
import 'package:gsmlg/screens/chat/widgets/chat_message_list.dart';
import 'package:gsmlg/screens/chat/widgets/model_status_banner.dart';
import 'package:gsmlg/screens/settings/model_management_screen.dart';

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
    context.read<ChatBloc>().add(ChatNewConversation(
          systemPrompt: settingsState.defaultSystemPrompt,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(HomeScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: AppBar(
          title: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return Text(state.conversation?.title ?? 'Chat');
            },
          ),
          actions: [
            // Model selector chip
            BlocBuilder<GemmaModelBloc, GemmaModelState>(
              builder: (context, modelState) {
                return _buildModelSelector(context, modelState);
              },
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
              onPressed: () => context.goNamed(ChatSettingsScreen.name),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Model status banner
              BlocBuilder<GemmaModelBloc, GemmaModelState>(
                builder: (context, modelState) {
                  return ModelStatusBanner(state: modelState);
                },
              ),
              // Chat messages
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.conversation == null) {
                      return _buildWelcomeView();
                    }
                    return ChatMessageList(
                      messages: state.messages,
                      isStreaming: state.isStreaming,
                    );
                  },
                ),
              ),
              // Input bar
              BlocBuilder<GemmaModelBloc, GemmaModelState>(
                builder: (context, modelState) {
                  return BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, chatState) {
                      final canSend =
                          modelState.isReady && !chatState.isStreaming;
                      return ChatInputBar(
                        enabled: canSend,
                        isStreaming: chatState.isStreaming,
                        onSend: (message) {
                          final settingsState =
                              context.read<ChatSettingsBloc>().state;
                          context.read<ChatBloc>().add(ChatSendMessage(
                                content: message,
                                systemPrompt:
                                    chatState.conversation == null
                                        ? settingsState.defaultSystemPrompt
                                        : null,
                              ));
                        },
                        onStop: () {
                          context
                              .read<ChatBloc>()
                              .add(const ChatStopGeneration());
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
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    );
  }

  Widget _buildModelSelector(BuildContext context, GemmaModelState modelState) {
    final selectedId = modelState.selectedModelId;
    final installed = modelState.installedModels;

    if (installed.isEmpty) {
      return TextButton.icon(
        icon: const Icon(Icons.download, size: 16),
        label: const Text('Get Model'),
        onPressed: () => context.goNamed(ModelManagementScreen.name),
      );
    }

    // Resolve display name via fuzzy match
    String displayName = selectedId ?? installed.first;
    for (final model in GemmaModelInfo.availableModels) {
      if (displayName == model.id ||
          displayName.contains(model.id) ||
          model.id.contains(displayName)) {
        displayName = model.displayName;
        break;
      }
    }

    final statusIcon = switch (modelState.status) {
      GemmaModelStatus.ready => Icons.check_circle,
      GemmaModelStatus.loading => Icons.hourglass_top,
      GemmaModelStatus.error => Icons.error_outline,
      _ => Icons.smart_toy,
    };

    final statusColor = switch (modelState.status) {
      GemmaModelStatus.ready => Colors.green,
      GemmaModelStatus.error => Theme.of(context).colorScheme.error,
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        avatar: Icon(statusIcon, size: 16, color: statusColor),
        label: Text(
          displayName,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () => _showModelPicker(context, modelState),
      ),
    );
  }

  void _showModelPicker(BuildContext context, GemmaModelState modelState) {
    final installed = modelState.installedModels;
    if (installed.isEmpty) {
      context.goNamed(ModelManagementScreen.name);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Select Model',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        context.goNamed(ModelManagementScreen.name);
                      },
                      child: const Text('Manage'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...installed.map((modelId) {
                GemmaModelInfo? info;
                for (final model in GemmaModelInfo.availableModels) {
                  if (modelId == model.id ||
                      modelId.contains(model.id) ||
                      model.id.contains(modelId)) {
                    info = model;
                    break;
                  }
                }
                final displayName = info?.displayName ?? modelId;
                final isSelected = modelState.selectedModelId == modelId;

                return ListTile(
                  leading: Icon(
                    Icons.smart_toy,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(displayName),
                  subtitle: info != null ? Text(info.description) : null,
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  selected: isSelected,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (!isSelected) {
                      context
                          .read<GemmaModelBloc>()
                          .add(GemmaModelSelect(modelId: modelId));
                    }
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a message below to begin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}
