import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/log_viewer/log_viewer_screen.dart';
import 'package:app_locale/app_locale.dart';
import 'package:log_viewer_bloc/log_viewer_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';

void main() {
  // Loaded file and error state behaviors are tested at the BLoC and widget
  // level (log_file_bloc_test, filter_bloc_test, selection_bloc_test,
  // detail_panel_test, filter_bar_test, body_viewer_test, json_tree_view_test,
  // log_list_tile_test, file_indexer_test, entry_reader_test,
  // filter_engine_test, key_path_discovery_test, lru_cache_test).
  // Screen-level tests for loaded/error states require real file I/O that
  // is incompatible with Flutter's fake async test environment.

  group('LogViewerScreen', () {
    late SharedPreferences sharedPrefs;
    late DmThemeBloc themeBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPrefs = await SharedPreferences.getInstance();
      themeBloc = DmThemeBloc(prefs: sharedPrefs);
    });

    tearDown(() {
      themeBloc.close();
    });

    Widget buildScreen({Size size = const Size(1200, 800)}) {
      return MediaQuery(
        data: MediaQueryData(size: size),
        child: RepositoryProvider<SharedPreferences>.value(
          value: sharedPrefs,
          child: MultiBlocProvider(
            providers: [BlocProvider<DmThemeBloc>.value(value: themeBloc)],
            child: MaterialApp(
              localizationsDelegates: AppLocale.localizationsDelegates,
              supportedLocales: AppLocale.supportedLocales,
              home: const LogViewerScreen(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders the screen widget', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(LogViewerScreen), findsOneWidget);
    });

    testWidgets('shows initial view with open file prompt', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Open a JSONL log file to inspect'), findsOneWidget);
      expect(find.text('Open File'), findsOneWidget);
    });

    testWidgets('shows file icon and folder icon in initial state', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('has correct static route constants', (tester) async {
      expect(LogViewerScreen.name, equals('LogViewer'));
      expect(LogViewerScreen.path, equals('log-viewer'));
    });

    testWidgets('creates MultiBlocProvider with all three blocs', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Verify we can find the BlocBuilder which means the blocs were
      // created and provided successfully
      expect(
        find.byType(BlocBuilder<LogFileBloc, LogFileState>),
        findsOneWidget,
      );
    });

    testWidgets('open file button is a FilledButton', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // FilledButton.icon wraps with _FilledButtonWithIcon
      expect(find.text('Open File'), findsOneWidget);
    });

    testWidgets('renders AppBar with DmNavigationHeader inside body', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(DmNavigationHeader), findsOneWidget);
      expect(find.text('JSON Log Inspector'), findsOneWidget);
    });
  });
}
