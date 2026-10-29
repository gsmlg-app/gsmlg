import 'package:app_provider/src/terminal_session_bloc.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

class _SessionTab extends TabItem {
  int disposedCount = 0;

  @override
  void didDispose() {
    disposedCount++;
    super.didDispose();
  }
}

void main() {
  test(
    'app teardown disposes open sessions after draining pending tab events',
    () async {
      final bloc = TerminalSessionBloc();
      final tab = _SessionTab();
      bloc.add(TerminalTabStart());
      await bloc.stream.firstWhere((state) => state is TerminalTabLoaded);
      bloc.add(TerminalTabOpenTab(tab));
      await bloc.close();
      expect(tab.disposedCount, 1);
    },
  );

  test(
    'route start/stop preserves a session until explicitly closed',
    () async {
      final bloc = TerminalSessionBloc();
      addTearDown(bloc.close);
      final tab = _SessionTab();
      bloc.add(TerminalTabStart());
      await bloc.stream.firstWhere((state) => state is TerminalTabLoaded);
      bloc.add(TerminalTabOpenTab(tab));
      await bloc.stream.firstWhere(
        (state) => state is TerminalTabLoaded && state.allTabs.isNotEmpty,
      );
      bloc.add(TerminalTabStop());
      await bloc.stream.firstWhere(
        (state) => state is TerminalTabLoaded && !state.isMounted,
      );
      bloc.add(TerminalTabStart());
      final state =
          await bloc.stream.firstWhere(
                (state) => state is TerminalTabLoaded && state.isMounted,
              )
              as TerminalTabLoaded;
      expect(state.allTabs.single, same(tab));
      expect(tab.disposedCount, 0);
      bloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
      await bloc.stream.firstWhere(
        (state) => state is TerminalTabLoaded && state.allTabs.isEmpty,
      );
      expect(tab.disposedCount, 1);
    },
  );
}
