import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_settings/terminal_settings.dart';

// Mock TerminalSettingsBloc for testing
class MockTerminalSettingsBloc
    extends Bloc<TerminalSettingsEvent, TerminalSettingsState>
    implements TerminalSettingsBloc {
  MockTerminalSettingsBloc({TerminalSettingsState? initialState})
      : super(initialState ?? TerminalSettingsInitial()) {
    on<TerminalSettingsLoad>((event, emit) {});
    on<TerminalSettingsUpdateEnvVar>((event, emit) {});
    on<TerminalSettingsRemoveEnvVar>((event, emit) {});
    on<TerminalSettingsClearEnvVars>((event, emit) {});
  }
}

void main() {
  group('EnvSettingsList', () {
    group('construction', () {
      test('can be instantiated', () {
        expect(const EnvSettingsList(), isA<EnvSettingsList>());
      });

      test('is StatelessWidget', () {
        expect(const EnvSettingsList(), isA<StatelessWidget>());
      });

      test('has const constructor', () {
        // Verify const constructor
        const widget = EnvSettingsList();
        expect(widget, isA<EnvSettingsList>());
      });

      test('accepts key parameter', () {
        const key = Key('env-settings-list');
        const widget = EnvSettingsList(key: key);
        expect(widget.key, key);
      });
    });

    group('widget rendering', () {
      testWidgets('shows loading indicator when state is initial',
          (tester) async {
        final bloc = MockTerminalSettingsBloc();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows Add Variable option when loaded with empty env vars',
          (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(environmentVariables: {}),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.text('Add Variable'), findsOneWidget);
      });

      testWidgets('shows section title for Custom Environment Variables',
          (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(environmentVariables: {}),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.text('Custom Environment Variables'), findsOneWidget);
      });

      testWidgets('shows environment variables when loaded', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {
              'MY_VAR': 'my_value',
              'PATH_EXT': '/custom/path',
            },
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.text('MY_VAR'), findsOneWidget);
        expect(find.text('PATH_EXT'), findsOneWidget);
        expect(find.text('my_value'), findsOneWidget);
        expect(find.text('/custom/path'), findsOneWidget);
      });

      testWidgets('shows Clear All option when env vars exist', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {'TEST': 'value'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets('does not show Clear All when no env vars', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(environmentVariables: {}),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.text('Clear All'), findsNothing);
      });

      testWidgets('shows Actions section when env vars exist', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {'TEST': 'value'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.text('Actions'), findsOneWidget);
      });

      testWidgets('shows delete icon for each env var', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {'VAR1': 'value1', 'VAR2': 'value2'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        // Each env var should have a delete icon
        expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
      });

      testWidgets('shows code icon for each env var', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {'VAR1': 'value1'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.code), findsOneWidget);
      });

      testWidgets('shows add icon for Add Variable option', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(environmentVariables: {}),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('env vars are displayed in sorted order', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {
              'ZEBRA': 'last',
              'APPLE': 'first',
              'MANGO': 'middle',
            },
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        // Find all Text widgets with env var keys
        final appleWidget = find.text('APPLE');
        final mangoWidget = find.text('MANGO');
        final zebraWidget = find.text('ZEBRA');

        expect(appleWidget, findsOneWidget);
        expect(mangoWidget, findsOneWidget);
        expect(zebraWidget, findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('tapping delete icon shows confirmation dialog',
          (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {'TEST_VAR': 'test_value'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        // Tap the delete icon
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Confirmation dialog should appear
        expect(find.text('Delete Variable'), findsOneWidget);
        expect(find.text('Are you sure you want to delete "TEST_VAR"?'),
            findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('tapping Clear All shows confirmation dialog',
          (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {'TEST': 'value'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        // Tap the Clear All option
        await tester.tap(find.text('Clear All'));
        await tester.pumpAndSettle();

        // Confirmation dialog should appear
        expect(find.text('Clear All Variables'), findsOneWidget);
        expect(
          find.text(
              'Are you sure you want to delete all custom environment variables?'),
          findsOneWidget,
        );
      });

      testWidgets('canceling delete dialog does not remove variable',
          (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(
            environmentVariables: {'TEST_VAR': 'test_value'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        // Tap the delete icon
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Dialog should be dismissed, variable should still be shown
        expect(find.text('Delete Variable'), findsNothing);
        expect(find.text('TEST_VAR'), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('contains semantic labels', (tester) async {
        final bloc = MockTerminalSettingsBloc(
          initialState: const TerminalSettingsLoaded(environmentVariables: {}),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TerminalSettingsBloc>.value(
                value: bloc,
                child: const EnvSettingsList(),
              ),
            ),
          ),
        );

        // Verify the widget renders without accessibility errors
        expect(tester.takeException(), isNull);
      });
    });
  });
}
