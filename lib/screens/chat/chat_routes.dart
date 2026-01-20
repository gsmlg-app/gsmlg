import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/chat/chat_history_screen.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';
import 'package:gsmlg/screens/chat/chat_settings_screen.dart';

GoRoute chatRoutes() => GoRoute(
      name: ChatScreen.name,
      path: ChatScreen.path,
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          restorationId: state.pageKey.value,
          child: const ChatScreen(),
        );
      },
      routes: [
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
        GoRoute(
          name: ChatSettingsScreen.name,
          path: ChatSettingsScreen.path,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              restorationId: state.pageKey.value,
              child: const ChatSettingsScreen(),
            );
          },
        ),
      ],
    );
