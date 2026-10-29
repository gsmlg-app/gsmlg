import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:gsmlg/screens/toolbox/terminal/widgets/profile_selector.dart';

class MockShellProfileBloc
    extends MockBloc<ShellProfileEvent, ShellProfileState>
    implements ShellProfileBloc {}

/// Helper to create test profiles using the actual ShellProfile class
ShellProfile createTestProfile({
  int id = 1,
  String name = 'Test Profile',
  int shellType = 1,
  String environmentVariables = '{}',
  String aliases = '{}',
  String fontFamily = 'monospace',
  double fontSize = 14.0,
  String colorTheme = 'default',
  String workingDirectory = '',
  String startupCommand = '',
  int cursorStyle = 0,
  int scrollbackLines = 10000,
  bool isDefault = false,
  bool inheritCurrentState = false,
}) {
  return ShellProfile(
    id: id,
    name: name,
    shellType: shellType,
    environmentVariables: environmentVariables,
    aliases: aliases,
    fontFamily: fontFamily,
    fontSize: fontSize,
    colorTheme: colorTheme,
    workingDirectory: workingDirectory,
    startupCommand: startupCommand,
    cursorStyle: cursorStyle,
    scrollbackLines: scrollbackLines,
    isDefault: isDefault,
    inheritCurrentState: inheritCurrentState,
  );
}

void main() {
  late MockShellProfileBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const LoadShellProfiles());
  });

  setUp(() {
    mockBloc = MockShellProfileBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildSubject({required Widget child}) {
    return MaterialApp(
      home: BlocProvider<ShellProfileBloc>.value(value: mockBloc, child: child),
    );
  }

  group('showProfileSelector', () {
    testWidgets('calls callback with null when state is not loaded', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const ShellProfileInitial());

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showProfileSelector(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(callbackCalled, isTrue);
      expect(result, isNull);
    });

    testWidgets('calls callback with null when profiles list is empty', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const ShellProfileLoaded([]));

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showProfileSelector(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(callbackCalled, isTrue);
      expect(result, isNull);
    });

    testWidgets('auto-selects single default profile without showing dialog', (
      tester,
    ) async {
      final singleDefaultProfile = createTestProfile(
        id: 1,
        name: 'Default Profile',
        isDefault: true,
      );
      when(
        () => mockBloc.state,
      ).thenReturn(ShellProfileLoaded([singleDefaultProfile]));

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showProfileSelector(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(callbackCalled, isTrue);
      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result!.name, 'Default Profile');
      // No dialog should be shown
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows dialog when multiple profiles exist', (tester) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Profile 1', isDefault: true),
        createTestProfile(id: 2, name: 'Profile 2', isDefault: false),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showProfileSelector(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Select Shell Profile'), findsOneWidget);
      expect(find.text('Default Shell'), findsOneWidget);
      expect(find.text('Profile 1'), findsOneWidget);
      expect(find.text('Profile 2'), findsOneWidget);
    });

    testWidgets('shows dialog when one profile exists but not default', (
      tester,
    ) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Custom Profile', isDefault: false),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showProfileSelector(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('dialog has cancel button', (tester) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Profile 1', isDefault: false),
        createTestProfile(id: 2, name: 'Profile 2', isDefault: false),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showProfileSelector(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows star icon for default profile', (tester) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Default', isDefault: true),
        createTestProfile(id: 2, name: 'Custom', isDefault: false),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showProfileSelector(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Default profile should have star icon
      expect(find.byIcon(Icons.star), findsOneWidget);
      // Non-default should have person icon
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('selectProfileAndOpenShell', () {
    testWidgets('calls callback with null when no profiles exist', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const ShellProfileInitial());

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(callbackCalled, isTrue);
      expect(result, isNull);
    });

    testWidgets('auto-selects single default profile', (tester) async {
      final defaultProfile = createTestProfile(
        id: 1,
        name: 'My Default',
        isDefault: true,
      );
      when(
        () => mockBloc.state,
      ).thenReturn(ShellProfileLoaded([defaultProfile]));

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(callbackCalled, isTrue);
      expect(result, isNotNull);
      expect(result!.name, 'My Default');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows dialog with profile options', (tester) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Bash', shellType: 2),
        createTestProfile(id: 2, name: 'Zsh', shellType: 3),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Select Shell Profile'), findsOneWidget);
      expect(find.text('Default Shell'), findsOneWidget);
      expect(find.text('Bash'), findsOneWidget);
      expect(find.text('Zsh'), findsOneWidget);
    });

    testWidgets('selecting Default Shell calls callback with null', (
      tester,
    ) async {
      final profiles = [createTestProfile(id: 1, name: 'Custom Profile')];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Default Shell option
      await tester.tap(find.text('Default Shell'));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
      expect(result, isNull);
    });

    testWidgets('selecting a profile calls callback with that profile', (
      tester,
    ) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Profile A'),
        createTestProfile(id: 2, name: 'Profile B'),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Profile B option
      await tester.tap(find.text('Profile B'));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
      expect(result, isNotNull);
      expect(result!.id, 2);
      expect(result!.name, 'Profile B');
    });

    testWidgets('cancel does not call callback', (tester) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Profile 1'),
        createTestProfile(id: 2, name: 'Profile 2'),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(callbackCalled, isFalse);
    });

    testWidgets('shows shell type description for profiles', (tester) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Bash Profile', shellType: 2),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Should show shell type in subtitle
      expect(find.text('bash'), findsOneWidget);
    });

    testWidgets('shows default indicator in profile description', (
      tester,
    ) async {
      final profiles = [
        createTestProfile(
          id: 1,
          name: 'Default Bash',
          shellType: 2,
          isDefault: true,
        ),
        createTestProfile(id: 2, name: 'Custom Zsh', shellType: 3),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Default profile description includes 'default'
      expect(find.text('bash • default'), findsOneWidget);
      // Non-default just shows shell type
      expect(find.text('zsh'), findsOneWidget);
    });
  });

  group('_ProfileTile', () {
    testWidgets('renders icon, title, and subtitle', (tester) async {
      final profiles = [
        createTestProfile(id: 1, name: 'Test Profile', shellType: 1),
      ];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify profile tile content
      expect(find.text('Test Profile'), findsOneWidget);
      expect(find.text('sh'), findsOneWidget); // shellType 1 = sh
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('is tappable via InkWell', (tester) async {
      final profiles = [createTestProfile(id: 1, name: 'Tappable Profile')];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify InkWell exists (for tap feedback)
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('default shell tile has terminal icon', (tester) async {
      final profiles = [createTestProfile(id: 1, name: 'Profile 1')];
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Default Shell option should have terminal icon
      expect(find.byIcon(Icons.terminal), findsOneWidget);
      expect(find.text('System default settings'), findsOneWidget);
    });
  });

  group('edge cases', () {
    testWidgets('handles loading state', (tester) async {
      when(() => mockBloc.state).thenReturn(const ShellProfileLoading());

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      // Loading state is not ShellProfileLoaded, so treats as empty
      expect(callbackCalled, isTrue);
      expect(result, isNull);
    });

    testWidgets('handles error state', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(ShellProfileError(Exception('DB error')));

      ShellProfile? result;
      bool callbackCalled = false;

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {
                    callbackCalled = true;
                    result = profile;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      // Error state is not ShellProfileLoaded, so treats as empty
      expect(callbackCalled, isTrue);
      expect(result, isNull);
    });

    testWidgets('dialog content is scrollable for many profiles', (
      tester,
    ) async {
      final profiles = List.generate(
        10,
        (i) => createTestProfile(id: i + 1, name: 'Profile ${i + 1}'),
      );
      when(() => mockBloc.state).thenReturn(ShellProfileLoaded(profiles));

      await tester.pumpWidget(
        buildSubject(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                selectProfileAndOpenShell(
                  context: context,
                  onProfileSelected: (profile) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Should use SingleChildScrollView for scrollability
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
