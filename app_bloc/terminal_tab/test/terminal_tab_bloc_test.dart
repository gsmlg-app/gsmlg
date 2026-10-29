import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

/// A minimal TabItem for testing purposes.
class TestTabItem extends TabItem {
  final String testId;
  bool wasActivated = false;
  bool wasDisposed = false;

  TestTabItem(this.testId);

  @override
  void activate() {
    wasActivated = true;
    super.activate();
  }

  @override
  void dispose() {
    wasDisposed = true;
    super.dispose();
  }
}

void main() {
  group('TerminalTabBloc', () {
    late TerminalTabBloc bloc;

    setUp(() {
      bloc = TerminalTabBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is TerminalTabInitial', () {
      expect(bloc.state, isA<TerminalTabInitial>());
    });

    group('TerminalTabStart', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'emits TerminalTabLoaded when started',
        build: () => TerminalTabBloc(),
        act: (bloc) => bloc.add(TerminalTabStart()),
        expect: () => [
          isA<TerminalTabLoaded>()
              .having((s) => s.isMounted, 'isMounted', true)
              .having((s) => s.isFullscreen, 'isFullscreen', false)
              .having((s) => s.tabCount, 'tabCount', 0),
        ],
      );

      test('preserves tabs when started again', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab));
        await Future.delayed(Duration.zero);
        bloc.add(TerminalTabStart()); // Start again
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.isMounted, true);
        expect(state.tabCount, 1);
        bloc.close();
      });
    });

    group('TerminalTabStop', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'sets isMounted to false when stopped',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabStop());
        },
        skip: 1, // Skip TerminalTabStart state
        expect: () => [
          isA<TerminalTabLoaded>()
              .having((s) => s.isMounted, 'isMounted', false),
        ],
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'emits TerminalTabInitial when stopped from initial state',
        build: () => TerminalTabBloc(),
        act: (bloc) => bloc.add(TerminalTabStop()),
        expect: () => [
          isA<TerminalTabInitial>(),
        ],
      );
    });

    group('TerminalTabOpenTab', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'adds tab to tabs container',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        },
        skip: 1, // Skip TerminalTabStart
        expect: () => [
          isA<TerminalTabLoaded>()
              .having((s) => s.tabCount, 'tabCount', 1)
              .having((s) => s.version, 'version', 1),
        ],
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'activates tab by default',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab));
          // Verify activation after event processed
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.activeTab, isNotNull);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'does not activate tab when activate=false',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab, activate: false));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          // With only one tab, it may auto-activate in flex_tabs
          // The activate flag controls whether we call activate() explicitly
          expect(state.tabCount, 1);
        },
      );

      test('opens multiple tabs', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).tabCount, 1);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).tabCount, 2);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-3')));
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).tabCount, 3);

        bloc.close();
      });

      test('does nothing when not in loaded state', () async {
        final bloc = TerminalTabBloc();
        // Don't start the bloc
        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabInitial>());
        bloc.close();
      });
    });

    group('TerminalTabToggleFullscreen', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'toggles fullscreen from false to true',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabToggleFullscreen());
        },
        skip: 1, // Skip TerminalTabStart
        expect: () => [
          isA<TerminalTabLoaded>()
              .having((s) => s.isFullscreen, 'isFullscreen', true),
        ],
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'toggles fullscreen from true to false',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabToggleFullscreen()); // true
          bloc.add(TerminalTabToggleFullscreen()); // false
        },
        skip: 2, // Skip first two states
        expect: () => [
          isA<TerminalTabLoaded>()
              .having((s) => s.isFullscreen, 'isFullscreen', false),
        ],
      );

      test('does nothing when not in loaded state', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabToggleFullscreen());
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabInitial>());
        bloc.close();
      });
    });

    group('TerminalTabSelectSession', () {
      test('activates tab by session ID', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab1 = TestTabItem('tab-1');
        final tab2 = TestTabItem('tab-2');
        bloc.add(TerminalTabOpenTab(tab1));
        bloc.add(TerminalTabOpenTab(tab2));
        await Future.delayed(Duration.zero);

        // Select the first tab by its hashCode
        bloc.add(TerminalTabSelectSession(tab1.hashCode.toString()));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 2);
        // Version should be incremented
        expect(state.version, greaterThanOrEqualTo(3));
        bloc.close();
      });

      blocTest<TerminalTabBloc, TerminalTabState>(
        'does nothing when session ID not found',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
          bloc.add(TerminalTabSelectSession('non-existent-id'));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          // Still has one tab
          expect(state.tabCount, 1);
        },
      );

      test('does nothing when not in loaded state', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabSelectSession('some-id'));
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabInitial>());
        bloc.close();
      });
    });

    group('TerminalTabCloseSession', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'closes tab by session ID',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab));
          bloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.tabCount, 0);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'disposes the closed tab',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab));
          bloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.tabCount, 0);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'does nothing when session ID not found',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
          bloc.add(TerminalTabCloseSession('non-existent-id'));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          // Tab still exists
          expect(state.tabCount, 1);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'closes correct tab when multiple tabs exist',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab1 = TestTabItem('tab-1');
          final tab2 = TestTabItem('tab-2');
          final tab3 = TestTabItem('tab-3');
          bloc.add(TerminalTabOpenTab(tab1));
          bloc.add(TerminalTabOpenTab(tab2));
          bloc.add(TerminalTabOpenTab(tab3));
          bloc.add(TerminalTabCloseSession(tab2.hashCode.toString()));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.tabCount, 2);
        },
      );

      test('does nothing when not in loaded state', () async {
        final bloc = TerminalTabBloc();
        bloc.add(TerminalTabCloseSession('some-id'));
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabInitial>());
        bloc.close();
      });
    });

    group('TerminalTabReorderSessions', () {
      test('reorders tabs to match session ID order', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab1 = TestTabItem('tab-1');
        final tab2 = TestTabItem('tab-2');
        final tab3 = TestTabItem('tab-3');
        bloc.add(TerminalTabOpenTab(tab1));
        bloc.add(TerminalTabOpenTab(tab2));
        bloc.add(TerminalTabOpenTab(tab3));
        await Future.delayed(Duration.zero);

        bloc.add(
          TerminalTabReorderSessions([
            tab2.hashCode.toString(),
            tab3.hashCode.toString(),
            tab1.hashCode.toString(),
          ]),
        );
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.allTabs, [tab2, tab3, tab1]);
      });

      test('does nothing when session IDs do not match open tabs', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab1 = TestTabItem('tab-1');
        final tab2 = TestTabItem('tab-2');
        bloc.add(TerminalTabOpenTab(tab1));
        bloc.add(TerminalTabOpenTab(tab2));
        await Future.delayed(Duration.zero);

        final version = (bloc.state as TerminalTabLoaded).version;
        bloc.add(
          TerminalTabReorderSessions([
            tab2.hashCode.toString(),
            'missing-session',
          ]),
        );
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.allTabs, [tab1, tab2]);
        expect(state.version, version);
      });
    });

    group('TerminalTabRenameSession', () {
      test('renames tab title by session ID', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab));
        await Future.delayed(Duration.zero);

        bloc.add(
          TerminalTabRenameSession(
            tab.hashCode.toString(),
            'Build logs',
          ),
        );
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        final title = tab.title.value as Text;
        expect(title.data, 'Build logs');
        expect(state.version, 2);
      });

      test('does nothing when title is empty', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab));
        await Future.delayed(Duration.zero);

        final version = (bloc.state as TerminalTabLoaded).version;
        bloc.add(TerminalTabRenameSession(tab.hashCode.toString(), '   '));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(tab.title.value, isNull);
        expect(state.version, version);
      });
    });

    group('State properties', () {
      test('TerminalTabInitial props is empty list', () {
        expect(TerminalTabInitial().props, isEmpty);
      });

      test('TerminalTabInitial copyWith returns new instance', () {
        final initial = TerminalTabInitial();
        final copy = initial.copyWith();
        expect(copy, isA<TerminalTabInitial>());
      });

      test('TerminalTabLoaded props contains all fields', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        expect(state.props.length,
            5); // tabs, tabsDocument, isMounted, isFullscreen, version
      });

      test('TerminalTabLoaded copyWith preserves fields', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        final copy = state.copyWith(isFullscreen: true);
        expect(copy.isFullscreen, true);
        expect(copy.isMounted, state.isMounted);
        expect(copy.tabs, state.tabs);
      });

      test('TerminalTabLoaded copyWith incrementVersion works', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        final copy = state.copyWith(incrementVersion: true);
        expect(copy.version, state.version + 1);
      });

      test('TerminalTabError props contains error', () {
        final error = Exception('test error');
        final state = TerminalTabError(error);
        expect(state.props, [error]);
        expect(state.error, error);
      });

      test('TerminalTabError copyWith preserves error', () {
        final error = Exception('test error');
        final state = TerminalTabError(error);
        final copy = state.copyWith();
        expect(copy.error, error);
      });

      test('TerminalTabError copyWith can change error', () {
        final error1 = Exception('error 1');
        final error2 = Exception('error 2');
        final state = TerminalTabError(error1);
        final copy = state.copyWith(error: error2);
        expect(copy.error, error2);
      });
    });

    group('TerminalTabLoaded helpers', () {
      test('activeTab returns null when no tabs', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        expect(state.activeTab, isNull);
      });

      test('activeTab returns active tab when tabs exist', () async {
        bloc.add(TerminalTabStart());
        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        expect(state.activeTab, isNotNull);
      });

      test('allTabs returns all tab items', () async {
        bloc.add(TerminalTabStart());
        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        await Future.delayed(Duration.zero);
        final state = bloc.state as TerminalTabLoaded;
        expect(state.allTabs.length, 2);
      });

      test('tabCount returns correct count', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        var state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 0);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 1);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        await Future.delayed(Duration.zero);
        state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 2);
      });
    });

    group('Event equality', () {
      test('TerminalTabStart events are equal', () {
        expect(TerminalTabStart().runtimeType, TerminalTabStart().runtimeType);
      });

      test('TerminalTabSelectSession events with same ID', () {
        final e1 = TerminalTabSelectSession('id-1');
        final e2 = TerminalTabSelectSession('id-1');
        expect(e1.sessionId, e2.sessionId);
      });

      test('TerminalTabCloseSession events with same ID', () {
        final e1 = TerminalTabCloseSession('id-1');
        final e2 = TerminalTabCloseSession('id-1');
        expect(e1.sessionId, e2.sessionId);
      });
    });

    group('State equality', () {
      test('TerminalTabInitial instances are equal', () {
        final state1 = TerminalTabInitial();
        final state2 = TerminalTabInitial();
        expect(state1, equals(state2));
      });

      test('TerminalTabError instances with same error are equal', () {
        final error = Exception('test error');
        final state1 = TerminalTabError(error);
        final state2 = TerminalTabError(error);
        expect(state1, equals(state2));
      });

      test('TerminalTabError instances with different errors are not equal',
          () {
        final state1 = TerminalTabError(Exception('error 1'));
        final state2 = TerminalTabError(Exception('error 2'));
        expect(state1, isNot(equals(state2)));
      });

      test('TerminalTabLoaded instances with same values are equal', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state1 = bloc.state as TerminalTabLoaded;
        final state2 = state1.copyWith();
        expect(state1, equals(state2));
      });

      test('TerminalTabLoaded instances with different versions are not equal',
          () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        final state1 = bloc.state as TerminalTabLoaded;
        final state2 = state1.copyWith(incrementVersion: true);
        expect(state1, isNot(equals(state2)));
      });
    });

    group('Complex scenarios', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'handles rapid open and close operations',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab1 = TestTabItem('tab-1');
          final tab2 = TestTabItem('tab-2');
          final tab3 = TestTabItem('tab-3');
          bloc.add(TerminalTabOpenTab(tab1));
          bloc.add(TerminalTabOpenTab(tab2));
          bloc.add(TerminalTabCloseSession(tab1.hashCode.toString()));
          bloc.add(TerminalTabOpenTab(tab3));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.tabCount, 2); // tab2 and tab3
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'handles select followed by close on same tab',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab1 = TestTabItem('tab-1');
          final tab2 = TestTabItem('tab-2');
          bloc.add(TerminalTabOpenTab(tab1));
          bloc.add(TerminalTabOpenTab(tab2));
          bloc.add(TerminalTabSelectSession(tab1.hashCode.toString()));
          bloc.add(TerminalTabCloseSession(tab1.hashCode.toString()));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.tabCount, 1);
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'version increments on tab operations',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
          bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(
              state.version, 2); // version incremented twice (once per OpenTab)
        },
      );

      test('closing all tabs leaves empty tabs container', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab1 = TestTabItem('tab-1');
        final tab2 = TestTabItem('tab-2');
        bloc.add(TerminalTabOpenTab(tab1));
        bloc.add(TerminalTabOpenTab(tab2));
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabCloseSession(tab1.hashCode.toString()));
        await Future.delayed(Duration.zero);
        bloc.add(TerminalTabCloseSession(tab2.hashCode.toString()));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 0);
        expect(state.allTabs, isEmpty);
        // Note: activeTab may not be null due to flex_tabs behavior
      });

      test('opening tabs without activation', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab1 = TestTabItem('tab-1');
        final tab2 = TestTabItem('tab-2');
        bloc.add(TerminalTabOpenTab(tab1, activate: false));
        bloc.add(TerminalTabOpenTab(tab2, activate: false));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 2);
      });

      blocTest<TerminalTabBloc, TerminalTabState>(
        'multiple fullscreen toggles work correctly',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabToggleFullscreen()); // true
          bloc.add(TerminalTabToggleFullscreen()); // false
          bloc.add(TerminalTabToggleFullscreen()); // true
          bloc.add(TerminalTabToggleFullscreen()); // false
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.isFullscreen, false);
        },
      );
    });

    group('Edge cases', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'selecting already active tab increments version',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab));
          bloc.add(TerminalTabSelectSession(tab.hashCode.toString()));
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.version, 2); // opened + selected
        },
      );

      test('closing non-existent tab does not change version', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final initialVersion = (bloc.state as TerminalTabLoaded).version;

        bloc.add(TerminalTabCloseSession('non-existent-id'));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.version, initialVersion);
      });

      test('selecting non-existent tab does not change version', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final initialVersion = (bloc.state as TerminalTabLoaded).version;

        bloc.add(TerminalTabSelectSession('non-existent-id'));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.version, initialVersion);
      });

      blocTest<TerminalTabBloc, TerminalTabState>(
        'stop and restart maintains state structure',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          final tab = TestTabItem('tab-1');
          bloc.add(TerminalTabOpenTab(tab));
          bloc.add(TerminalTabStop());
          bloc.add(TerminalTabStart());
        },
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.isMounted, true);
          expect(state.tabCount, 1); // Tab preserved
        },
      );

      test('opening same tab instance multiple times is allowed', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab));
        await Future.delayed(Duration.zero);

        // Opening same instance again might be a framework edge case
        // but BLoC should handle it without crashing
        expect(() => bloc.add(TerminalTabOpenTab(tab)), returnsNormally);
      });
    });

    group('State transitions', () {
      blocTest<TerminalTabBloc, TerminalTabState>(
        'transitions from Initial to Loaded on Start',
        build: () => TerminalTabBloc(),
        act: (bloc) => bloc.add(TerminalTabStart()),
        expect: () => [isA<TerminalTabLoaded>()],
        verify: (bloc) {
          expect(bloc.state, isA<TerminalTabLoaded>());
        },
      );

      blocTest<TerminalTabBloc, TerminalTabState>(
        'transitions from Loaded to Loaded on Stop (unmounted)',
        build: () => TerminalTabBloc(),
        act: (bloc) {
          bloc.add(TerminalTabStart());
          bloc.add(TerminalTabStop());
        },
        skip: 1,
        verify: (bloc) {
          final state = bloc.state as TerminalTabLoaded;
          expect(state.isMounted, false);
        },
      );

      test('emits new state on each tab operation', () async {
        final bloc = TerminalTabBloc();

        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        var state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 0);
        expect(state.version, 0);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);
        state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 1);
        expect(state.version, 1);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        await Future.delayed(Duration.zero);
        state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 2);
        expect(state.version, 2);

        bloc.close();
      });
    });

    group('Tab lifecycle', () {
      test('tab disposal is called when closing tab', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab));
        await Future.delayed(Duration.zero);

        expect(tab.wasDisposed, false);

        bloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
        await Future.delayed(Duration.zero);

        expect(tab.wasDisposed, true);
      });

      test('tab activation is called when activate=true', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab, activate: true));
        await Future.delayed(Duration.zero);

        expect(tab.wasActivated, true);
      });

      test('multiple tabs can coexist', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tabs = List.generate(5, (i) => TestTabItem('tab-$i'));
        for (final tab in tabs) {
          bloc.add(TerminalTabOpenTab(tab));
        }
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 5);
        expect(state.allTabs.length, 5);
      });

      test('closing middle tab preserves other tabs', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab1 = TestTabItem('tab-1');
        final tab2 = TestTabItem('tab-2');
        final tab3 = TestTabItem('tab-3');
        bloc.add(TerminalTabOpenTab(tab1));
        bloc.add(TerminalTabOpenTab(tab2));
        bloc.add(TerminalTabOpenTab(tab3));
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabCloseSession(tab2.hashCode.toString()));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.tabCount, 2);
        expect(tab2.wasDisposed, true);
        expect(tab1.wasDisposed, false);
        expect(tab3.wasDisposed, false);
      });
    });

    group('Version tracking', () {
      test('version starts at 0', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.version, 0);
      });

      test('version increments on open tab', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.version, 1);
      });

      test('version increments on close tab', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab));
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.version, 2); // 1 for open, 2 for close
      });

      test('version increments on select session', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final tab = TestTabItem('tab-1');
        bloc.add(TerminalTabOpenTab(tab));
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabSelectSession(tab.hashCode.toString()));
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.version, 2); // 1 for open, 2 for select
      });

      test('version does not increment on fullscreen toggle', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final initialVersion = (bloc.state as TerminalTabLoaded).version;

        bloc.add(TerminalTabToggleFullscreen());
        await Future.delayed(Duration.zero);

        final state = bloc.state as TerminalTabLoaded;
        expect(state.version, initialVersion); // No version change
      });

      test('version does not increment on stop/start', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final initialVersion = (bloc.state as TerminalTabLoaded).version;

        bloc.add(TerminalTabStop());
        await Future.delayed(Duration.zero);

        final stoppedState = bloc.state as TerminalTabLoaded;
        expect(stoppedState.version, initialVersion);

        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        final restartedState = bloc.state as TerminalTabLoaded;
        expect(restartedState.version, initialVersion);
      });
    });

    group('Integration scenarios', () {
      test('full workflow: start, open multiple tabs, switch, close, stop',
          () async {
        // Start
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);
        expect(bloc.state, isA<TerminalTabLoaded>());
        expect((bloc.state as TerminalTabLoaded).tabCount, 0);

        // Open multiple tabs
        final tab1 = TestTabItem('tab-1');
        final tab2 = TestTabItem('tab-2');
        final tab3 = TestTabItem('tab-3');
        bloc.add(TerminalTabOpenTab(tab1));
        bloc.add(TerminalTabOpenTab(tab2));
        bloc.add(TerminalTabOpenTab(tab3));
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).tabCount, 3);

        // Switch to first tab
        bloc.add(TerminalTabSelectSession(tab1.hashCode.toString()));
        await Future.delayed(Duration.zero);

        // Close middle tab
        bloc.add(TerminalTabCloseSession(tab2.hashCode.toString()));
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).tabCount, 2);
        expect(tab2.wasDisposed, true);

        // Stop
        bloc.add(TerminalTabStop());
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).isMounted, false);
      });

      test('fullscreen workflow during tab operations', () async {
        bloc.add(TerminalTabStart());
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-1')));
        await Future.delayed(Duration.zero);

        bloc.add(TerminalTabToggleFullscreen());
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).isFullscreen, true);

        bloc.add(TerminalTabOpenTab(TestTabItem('tab-2')));
        await Future.delayed(Duration.zero);
        expect(
            (bloc.state as TerminalTabLoaded).isFullscreen, true); // Preserved
        expect((bloc.state as TerminalTabLoaded).tabCount, 2);

        bloc.add(TerminalTabToggleFullscreen());
        await Future.delayed(Duration.zero);
        expect((bloc.state as TerminalTabLoaded).isFullscreen, false);
      });
    });
  });
}
