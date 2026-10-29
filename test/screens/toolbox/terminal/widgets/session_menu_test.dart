import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/session_menu.dart';

void main() {
  group('SessionMenu', () {
    group('construction', () {
      test('can be constructed', () {
        final menu = SessionMenu(
          onNewLocalShell: () {},
          onNewSshSession: () {},
          onNewSftpSession: () {},
        );
        expect(menu, isA<SessionMenu>());
      });

      test('is a StatelessWidget', () {
        final menu = SessionMenu(
          onNewLocalShell: () {},
          onNewSshSession: () {},
          onNewSftpSession: () {},
        );
        expect(menu, isA<StatelessWidget>());
      });

      test('accepts key parameter', () {
        const key = Key('session_menu');
        final menu = SessionMenu(
          key: key,
          onNewLocalShell: () {},
          onNewSshSession: () {},
          onNewSftpSession: () {},
        );
        expect(menu.key, equals(key));
      });

      test('stores callback parameters', () {
        var localCalled = false;
        var sshCalled = false;
        var sftpCalled = false;

        final menu = SessionMenu(
          onNewLocalShell: () => localCalled = true,
          onNewSshSession: () => sshCalled = true,
          onNewSftpSession: () => sftpCalled = true,
        );

        menu.onNewLocalShell();
        menu.onNewSshSession();
        menu.onNewSftpSession();

        expect(localCalled, isTrue);
        expect(sshCalled, isTrue);
        expect(sftpCalled, isTrue);
      });
    });

    group('widget tests', () {
      late bool localShellCalled;
      late bool sshSessionCalled;
      late bool sftpSessionCalled;

      setUp(() {
        localShellCalled = false;
        sshSessionCalled = false;
        sftpSessionCalled = false;
      });

      Widget buildTestWidget() {
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SessionMenu(
                  onNewLocalShell: () => localShellCalled = true,
                  onNewSshSession: () => sshSessionCalled = true,
                  onNewSftpSession: () => sftpSessionCalled = true,
                ),
              ],
            ),
            body: const SizedBox(),
          ),
        );
      }

      testWidgets('renders add button icon', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('renders PopupMenuButton', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Use widgetWithText to find PopupMenuButton without specifying exact type
        expect(
          find.byWidgetPredicate((w) => w is PopupMenuButton),
          findsOneWidget,
        );
      });

      testWidgets('has correct tooltip', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        final popupButton = tester.widget<PopupMenuButton>(
          find.byWidgetPredicate((w) => w is PopupMenuButton),
        );
        expect(popupButton.tooltip, equals('New session'));
      });

      testWidgets('opens popup menu on tap', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('Local Shell'), findsOneWidget);
        expect(find.text('SSH Shell'), findsOneWidget);
        expect(find.text('SFTP Server'), findsOneWidget);
      });

      testWidgets('shows correct subtitles in menu', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('Open a terminal on this device'), findsOneWidget);
        expect(find.text('Connect to a remote server'), findsOneWidget);
        expect(find.text('Browse remote files (coming soon)'), findsOneWidget);
      });

      testWidgets('shows correct icons in menu', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.terminal), findsOneWidget);
        expect(find.byIcon(Icons.cloud), findsOneWidget);
        expect(find.byIcon(Icons.folder), findsOneWidget);
      });

      testWidgets('calls onNewLocalShell when Local Shell selected', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Local Shell'));
        await tester.pumpAndSettle();

        expect(localShellCalled, isTrue);
        expect(sshSessionCalled, isFalse);
        expect(sftpSessionCalled, isFalse);
      });

      testWidgets('calls onNewSshSession when SSH Shell selected', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text('SSH Shell'));
        await tester.pumpAndSettle();

        expect(localShellCalled, isFalse);
        expect(sshSessionCalled, isTrue);
        expect(sftpSessionCalled, isFalse);
      });

      testWidgets('SFTP option is disabled', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Tap on SFTP - since it's disabled, callback should not be called
        await tester.tap(find.text('SFTP Server'));
        await tester.pumpAndSettle();

        // SFTP is disabled so callback not called
        expect(sftpSessionCalled, isFalse);
      });

      testWidgets('menu closes after selection', (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('Local Shell'), findsOneWidget);

        await tester.tap(find.text('Local Shell'));
        await tester.pumpAndSettle();

        // Menu should be closed
        expect(find.text('Open a terminal on this device'), findsNothing);
      });
    });

    group('accessibility', () {
      testWidgets('has Semantics wrapper', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  SessionMenu(
                    onNewLocalShell: () {},
                    onNewSshSession: () {},
                    onNewSftpSession: () {},
                  ),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Find the Semantics widget inside SessionMenu
        final sessionMenuFinder = find.byType(SessionMenu);
        expect(sessionMenuFinder, findsOneWidget);

        // Find Semantics descendants
        final semanticsFinder = find.descendant(
          of: sessionMenuFinder,
          matching: find.byType(Semantics),
        );
        expect(semanticsFinder, findsWidgets);
      });

      testWidgets('menu items use ListTile with text', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  SessionMenu(
                    onNewLocalShell: () {},
                    onNewSshSession: () {},
                    onNewSftpSession: () {},
                  ),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Each menu item should have a ListTile
        expect(find.byType(ListTile), findsNWidgets(3));

        // Verify each title exists
        expect(find.text('Local Shell'), findsOneWidget);
        expect(find.text('SSH Shell'), findsOneWidget);
        expect(find.text('SFTP Server'), findsOneWidget);
      });
    });

    group('PopupMenuButton configuration', () {
      testWidgets('icon is inside SessionMenu', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  SessionMenu(
                    onNewLocalShell: () {},
                    onNewSshSession: () {},
                    onNewSftpSession: () {},
                  ),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        );

        final iconFinder = find.byIcon(Icons.add);
        expect(iconFinder, findsOneWidget);

        // Icon should be descendant of SessionMenu
        expect(
          find.ancestor(of: iconFinder, matching: find.byType(SessionMenu)),
          findsOneWidget,
        );
      });

      testWidgets('has 3 menu items', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  SessionMenu(
                    onNewLocalShell: () {},
                    onNewSshSession: () {},
                    onNewSftpSession: () {},
                  ),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Count ListTile items (each menu option has one)
        expect(find.byType(ListTile), findsNWidgets(3));
      });

      testWidgets('each ListTile has leading icon', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  SessionMenu(
                    onNewLocalShell: () {},
                    onNewSshSession: () {},
                    onNewSftpSession: () {},
                  ),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Verify all menu item icons exist
        expect(find.byIcon(Icons.terminal), findsOneWidget);
        expect(find.byIcon(Icons.cloud), findsOneWidget);
        expect(find.byIcon(Icons.folder), findsOneWidget);
      });
    });
  });
}
