import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

/// Owns terminal tabs for the application, independently of route widgets.
class TerminalSessionBloc extends TerminalTabBloc {
  @override
  Future<void> close() async {
    // Drain pending tab events before disposing the final session snapshot.
    await super.close();
    final current = state;
    if (current is TerminalTabLoaded) {
      for (final tab in current.allTabs.toList()) {
        tab.dispose();
      }
    }
  }
}
