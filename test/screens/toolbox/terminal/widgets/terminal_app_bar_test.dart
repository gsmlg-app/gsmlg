import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/terminal_app_bar.dart';

void main() {
  late TerminalTabBloc realBloc;
  late bool localShellCalled;
  late bool tabSwitcherCalled;
  late List<SessionInfo> testSessions;

  setUp(() {
    realBloc = TerminalTabBloc();
    localShellCalled = false;
    tabSwitcherCalled = false;
    testSessions = [
      const SessionInfo(id: 'session-1', name: 'Local Shell 1'),
      const SessionInfo(id: 'session-2', name: 'SSH: server.example.com'),
      const SessionInfo(id: 'session-3', name: 'Local Shell 2'),
    ];
  });

  tearDown(() {
    realBloc.close();
  });

  Widget buildTestWidget({
    String currentSessionName = 'Local Shell 1',
    List<SessionInfo>? sessions,
    bool startBloc = true,
    VoidCallback? onShowTabSwitcher,
  }) {
    if (startBloc) {
      realBloc.add(TerminalTabStart());
    }

    return MaterialApp(
      home: BlocProvider<TerminalTabBloc>.value(
        value: realBloc,
        child: Scaffold(
          appBar: TerminalAppBar(
            currentSessionName: currentSessionName,
            sessions: sessions ?? testSessions,
            onShowTabSwitcher:
                onShowTabSwitcher ?? () => tabSwitcherCalled = true,
            onNewLocalShell: () => localShellCalled = true,
            onNewSshSession: () {},
            onNewSftpSession: () {},
          ),
          body: const SizedBox(),
        ),
      ),
    );
  }

  group('TerminalAppBar Tests', () {
    testWidgets('renders current session name in title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(currentSessionName: 'My Shell'));
      await tester.pumpAndSettle();

      expect(find.text('My Shell'), findsOneWidget);
    });

    testWidgets('shows "Terminal" when no sessions exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(currentSessionName: 'Terminal', sessions: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('Terminal'), findsOneWidget);
    });

    testWidgets('shows fullscreen icon when not in fullscreen mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen_exit), findsNothing);
    });

    testWidgets('fullscreen button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify fullscreen button is present and tappable
      final fullscreenButton = find.byIcon(Icons.fullscreen);
      expect(fullscreenButton, findsOneWidget);

      // Tap should not throw
      await tester.tap(fullscreenButton);
      await tester.pump();

      // Verify the bloc received the event by checking state changed
      final state = realBloc.state;
      expect(state, isA<TerminalTabLoaded>());
      expect((state as TerminalTabLoaded).isFullscreen, isTrue);
    });

    testWidgets('fullscreen button has correct tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Check tooltip via IconButton
      final iconButton = tester.widget<IconButton>(
        find.byType(IconButton).first,
      );
      expect(iconButton.tooltip, equals('Enter fullscreen'));
    });

    testWidgets('shows dropdown arrow next to session name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('opens tab switcher when title tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Local Shell 1'));
      await tester.pumpAndSettle();

      expect(tabSwitcherCalled, isTrue);
    });

    testWidgets('does not open tab switcher when no sessions exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(currentSessionName: 'Terminal', sessions: []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terminal'));
      await tester.pumpAndSettle();

      expect(tabSwitcherCalled, isFalse);
    });

    testWidgets('renders SessionMenu with add button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('SessionMenu opens and shows options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Local Shell'), findsOneWidget);
      expect(find.text('SSH Shell'), findsOneWidget);
    });

    testWidgets('passes callbacks correctly to SessionMenu', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Local Shell'));
      await tester.pumpAndSettle();

      expect(localShellCalled, isTrue);
    });

    testWidgets('has correct preferred size', (WidgetTester tester) async {
      const appBar = TerminalAppBar(
        currentSessionName: 'Test',
        sessions: [],
        onShowTabSwitcher: _noOpCallback,
        onNewLocalShell: _noOpCallback,
        onNewSshSession: _noOpCallback,
        onNewSftpSession: _noOpCallback,
      );

      expect(
        appBar.preferredSize,
        equals(const Size.fromHeight(kToolbarHeight)),
      );
    });

    testWidgets('handles long session names with overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          currentSessionName:
              'Very Long Session Name That Should Be Truncated With Ellipsis',
        ),
      );
      await tester.pumpAndSettle();

      // Should still render without error
      expect(
        find.text(
          'Very Long Session Name That Should Be Truncated With Ellipsis',
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not show session selector when sessions is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(currentSessionName: 'Terminal', sessions: []),
      );
      await tester.pumpAndSettle();

      // With no sessions, tapping "Terminal" should not open a popup
      await tester.tap(find.text('Terminal'));
      await tester.pump();

      // Should not find popup menu items
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      expect(tabSwitcherCalled, isFalse);
    });
  });

  group('SessionInfo Tests', () {
    test('SessionInfo holds correct values', () {
      final sessionInfo = SessionInfo(
        id: 'test-id',
        name: 'Test Session',
        onClose: () {},
      );

      expect(sessionInfo.id, equals('test-id'));
      expect(sessionInfo.name, equals('Test Session'));
      expect(sessionInfo.onClose, isNotNull);
    });

    test('SessionInfo onClose is optional', () {
      const sessionInfo = SessionInfo(id: 'test-id', name: 'Test Session');

      expect(sessionInfo.id, equals('test-id'));
      expect(sessionInfo.name, equals('Test Session'));
      expect(sessionInfo.onClose, isNull);
    });
  });
}

void _noOpCallback() {}
