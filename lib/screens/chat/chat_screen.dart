import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  void _startNewConversation() {
    final settingsState = context.read<ChatSettingsBloc>().state;
    context.read<ChatBloc>().add(ChatNewConversation(
          systemPrompt: settingsState.defaultSystemPrompt,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  final canSend = modelState.isReady && chatState.canSendMessage;
                  return ChatInputBar(
                    enabled: canSend,
                    isStreaming: chatState.isStreaming,
                    onSend: (message) {
                      // Start new conversation if none exists
                      if (chatState.conversation == null) {
                        _startNewConversation();
                        // Wait for next frame then send
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context
                              .read<ChatBloc>()
                              .add(ChatSendMessage(content: message));
                        });
                      } else {
                        context
                            .read<ChatBloc>()
                            .add(ChatSendMessage(content: message));
                      }
                    },
                    onStop: () {
                      context.read<ChatBloc>().add(const ChatStopGeneration());
                    },
                  );
                },
              );
            },
          ),
        ],
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
