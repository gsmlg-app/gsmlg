import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/agents/agent_editor_screen.dart';
import 'package:gsmlg/screens/agents/agent_sessions_screen.dart';
import 'package:gsmlg/screens/agents/agents_screen.dart';
import 'package:gsmlg/screens/chat/chat_history_screen.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';

GoRoute chatRoutes() => GoRoute(
  name: AgentsScreen.name,
  path: AgentsScreen.path,
  pageBuilder: (context, state) {
    return NoTransitionPage<void>(
      key: state.pageKey,
      restorationId: state.pageKey.value,
      child: const AgentsScreen(),
    );
  },
  routes: [
    GoRoute(
      name: ChatScreen.name,
      path: ChatScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: ChatScreen(conversationId: state.uri.queryParameters['id']),
        );
      },
    ),
    GoRoute(
      name: ChatHistoryScreen.name,
      path: ChatHistoryScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const ChatHistoryScreen(),
        );
      },
    ),
    // Must precede the `agents/:agentId` route so "new" is not an id.
    GoRoute(
      name: AgentEditorScreen.createName,
      path: AgentEditorScreen.createPath,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const AgentEditorScreen(),
        );
      },
    ),
    GoRoute(
      name: AgentSessionsScreen.name,
      path: AgentSessionsScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: AgentSessionsScreen(agentId: state.pathParameters['agentId']!),
        );
      },
      routes: [
        GoRoute(
          name: AgentEditorScreen.name,
          path: AgentEditorScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: AgentEditorScreen(
                agentId: state.pathParameters['agentId'],
              ),
            );
          },
        ),
      ],
    ),
  ],
);
