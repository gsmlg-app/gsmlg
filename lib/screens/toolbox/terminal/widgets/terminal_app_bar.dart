import 'package:flutter/material.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

import 'session_menu.dart';

/// AppBar for the terminal screen with session management controls.
///
/// Features:
/// - Title showing current session name with tab switcher trigger
/// - Left action: fullscreen toggle
/// - Right action: plus menu for creating new sessions
class TerminalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TerminalAppBar({
    super.key,
    required this.currentSessionName,
    required this.sessions,
    required this.onShowTabSwitcher,
    required this.onNewLocalShell,
    required this.onNewSshSession,
    required this.onNewSftpSession,
  });

  /// Name of the currently active session
  final String currentSessionName;

  /// List of all sessions with their names and IDs
  final List<SessionInfo> sessions;

  /// Called when user opens the terminal tab switcher.
  final VoidCallback onShowTabSwitcher;

  /// Called when user requests a new local shell session
  final VoidCallback onNewLocalShell;

  /// Called when user requests a new SSH session
  final VoidCallback onNewSshSession;

  /// Called when user requests a new SFTP session
  final VoidCallback onNewSftpSession;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return DmNavigationHeader(
      builder: (context, header) => AppBar(
        leading: header.leading,
        leadingWidth: header.leadingWidth,
        automaticallyImplyLeading: header.automaticallyImplyLeading,
        title: _buildSessionSelector(context),
        centerTitle: true,
        actions: [
          _buildFullscreenToggle(context),
          SessionMenu(
            onNewLocalShell: onNewLocalShell,
            onNewSshSession: onNewSshSession,
            onNewSftpSession: onNewSftpSession,
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenToggle(BuildContext context) {
    return BlocBuilder<TerminalTabBloc, TerminalTabState>(
      buildWhen: (previous, current) {
        if (previous is TerminalTabLoaded && current is TerminalTabLoaded) {
          return previous.isFullscreen != current.isFullscreen;
        }
        return true;
      },
      builder: (context, state) {
        final isFullscreen = state is TerminalTabLoaded
            ? state.isFullscreen
            : false;
        return Semantics(
          label: isFullscreen
              ? 'Exit fullscreen mode'
              : 'Enter fullscreen mode',
          hint: isFullscreen
              ? 'Double tap to show navigation'
              : 'Double tap to hide navigation and maximize terminal',
          button: true,
          child: IconButton(
            icon: Icon(isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            tooltip: isFullscreen ? 'Exit fullscreen' : 'Enter fullscreen',
            onPressed: () {
              context.read<TerminalTabBloc>().add(
                TerminalTabToggleFullscreen(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSessionSelector(BuildContext context) {
    if (sessions.isEmpty) {
      return Semantics(
        label: 'Terminal',
        header: true,
        child: const Text('Terminal'),
      );
    }

    final sessionCount = sessions.length;
    return Semantics(
      label:
          'Current session: $currentSessionName. $sessionCount session${sessionCount == 1 ? '' : 's'} open.',
      hint: 'Double tap to open tab switcher',
      button: true,
      child: Tooltip(
        message: 'Switch tab',
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onShowTabSwitcher,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    currentSessionName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Information about a terminal session for the session selector.
class SessionInfo {
  const SessionInfo({
    required this.id,
    required this.name,
    this.onClose,
    this.isRunning = false,
  });

  /// Unique identifier for the session
  final String id;

  /// Display name for the session
  final String name;

  /// Callback when user requests to close this session
  final VoidCallback? onClose;

  /// Whether this session has an active running process
  final bool isRunning;
}
