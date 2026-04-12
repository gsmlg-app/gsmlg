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

    // Only check installed models — no auto-download.
    context.read<GemmaModelBloc>().add(const GemmaModelListInstalled());
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
                  final selectedId = modelState.selectedModelId;
                  final modelInfo = selectedId != null
                      ? GemmaModelInfo.findById(selectedId)
                      : null;
                  return BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, chatState) {
                      final canSend =
                          modelState.isReady && !chatState.isStreaming;
                      return ChatInputBar(
                        enabled: canSend,
                        isStreaming: chatState.isStreaming,
                        supportsImage:
                            modelInfo?.supportsMultimodal ?? false,
                        supportsAudio:
                            modelInfo?.supportsAudio ?? false,
                        onSend: (message, {imageBytes, audioBytes}) {
                          final settingsState =
                              context.read<ChatSettingsBloc>().state;
                          context.read<ChatBloc>().add(ChatSendMessage(
                                content: message,
                                imageBytes: imageBytes,
                                audioBytes: audioBytes,
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
