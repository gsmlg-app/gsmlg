import 'dart:async';
import 'dart:convert';

import 'package:app_components/app_components.dart';
import 'package:app_editor/app_editor.dart';
import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart' as dm;
import 'package:editor_bloc/editor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/toolbox/editor/editor_screen.dart';
import 'package:gsmlg/screens/toolbox/toolbox_routes.dart';

void main() {
  late _Files files;
  late EditorCubit cubit;
  late GoRouter router;

  setUp(() {
    files = _Files();
    cubit = EditorCubit(files);
    router = GoRouter(
      initialLocation: '/toolbox/editor',
      routes: [
        toolboxRoutes(),
        GoRoute(
          name: 'other',
          path: '/other',
          builder: (_, _) => const Scaffold(body: Text('Other page')),
        ),
      ],
    );
  });

  tearDown(() async {
    router.dispose();
    await cubit.close();
    files.dispose();
  });

  Future<void> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      RepositoryProvider<EditorFileService>.value(
        value: files,
        child: BlocProvider.value(
          value: cubit,
          child: MaterialApp.router(
            theme: brightness == Brightness.dark
                ? dm.DmThemeData.moonlight()
                : dm.DmThemeData.sunshine(),
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> action(WidgetTester tester, String tooltip) async {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pump();
  }

  for (final brightness in Brightness.values) {
    testWidgets('bounded editor renders on narrow ${brightness.name} screen', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await mount(tester, brightness: brightness);
      expect(find.byType(dm.DmCodeEditor), findsOneWidget);
      final editor = tester.widget<dm.DmCodeEditor>(
        find.byType(dm.DmCodeEditor),
      );
      expect(editor.lineNumbers, isTrue);
      expect(
        tester.getSize(find.byType(dm.DmCodeEditor)).height,
        greaterThan(100),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('production Editor tile opens the nested route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    router.go('/toolbox');
    await mount(tester);
    final tile = find.ancestor(
      of: find.text('Editor'),
      matching: find.byType(AppGridTile),
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(router.namedLocation(EditorScreen.name), '/toolbox/editor');
    expect(find.byType(EditorScreen), findsOneWidget);
  });

  testWidgets(
    'route Cancel keeps dirty text; Discard restores snapshot and exits',
    (tester) async {
      await mount(tester);
      cubit.updateText('keep me');
      await tester.pump();
      router.goNamed('other');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(EditorScreen), findsOneWidget);
      expect(cubit.state.text, 'keep me');
      expect(cubit.state.isDirty, isTrue);
      router.goNamed('other');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Other page'), findsOneWidget);
      expect(cubit.state.text, '');
      expect(cubit.state.isDirty, isFalse);
    },
  );

  testWidgets('route Save writes before exiting', (tester) async {
    await mount(tester);
    cubit.updateText('save me');
    files.destination = _file('saved.txt', '');
    await tester.pump();
    router.goNamed('other');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Other page'), findsOneWidget);
    expect(utf8.decode(files.written!), 'save me');
    expect(cubit.state.isDirty, isFalse);
  });

  testWidgets(
    'failed Save and cancelled Save As retain dirty document and route',
    (tester) async {
      await mount(tester);
      cubit.updateText('valuable edits');
      files.failSave = true;
      await tester.pump();
      router.goNamed('other');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.byType(EditorScreen), findsOneWidget);
      expect(
        find.text('The file could not be saved. Your changes have been kept.'),
        findsOneWidget,
      );
      expect(cubit.state.text, 'valuable edits');
      expect(cubit.state.isDirty, isTrue);
      files.failSave = false;
      await action(tester, 'Save As');
      expect(cubit.state.text, 'valuable edits');
      expect(cubit.state.isDirty, isTrue);
    },
  );

  testWidgets('discard followed by cancelled picker retains dirty text', (
    tester,
  ) async {
    await mount(tester);
    cubit.updateText('unsaved');
    await tester.pump();
    await action(tester, 'Open');
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(files.picks, 1);
    expect(cubit.state.text, 'unsaved');
    expect(cubit.state.isDirty, isTrue);
  });

  testWidgets('New Cancel retains document; New Discard resets it', (
    tester,
  ) async {
    await mount(tester);
    cubit.updateText('unsaved');
    await tester.pump();
    await action(tester, 'New');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cubit.state.text, 'unsaved');
    await action(tester, 'New');
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(cubit.state.text, '');
    expect(cubit.state.isDirty, isFalse);
  });

  testWidgets(
    'external files guard dirty text and continue queue after Cancel',
    (tester) async {
      await mount(tester);
      cubit.updateText('unsaved');
      await tester.pump();
      files.receiveFiles(['first.dart', 'second.json']);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cubit.state.text, 'unsaved');
      expect(find.text('Save changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(files.reads, ['second.json']);
      expect(cubit.state.name, 'second.json');
      expect(cubit.state.text, '{}');
      expect(
        tester.widget<dm.DmCodeEditor>(find.byType(dm.DmCodeEditor)).language,
        'json',
      );
    },
  );

  testWidgets(
    'busy save detaches focused IME and keeps its document snapshot',
    (tester) async {
      await mount(tester);
      final controller = tester
          .widget<dm.DmCodeEditor>(find.byType(dm.DmCodeEditor))
          .controller!;
      controller.insertText('save this');
      await tester.pump();
      await tester.tap(find.byType(dm.DmCodeEditor));
      await tester.pump();
      expect(tester.testTextInput.hasAnyClients, isTrue);

      final gate = Completer<void>();
      files.saveGate = gate;
      files.destination = _file('saved.txt', '');
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      await tester.pump();
      expect(cubit.state.busy, isTrue);
      expect(tester.testTextInput.hasAnyClients, isFalse);

      // Simulate a late platform update after the input connection was closed.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'late IME input',
          selection: TextSelection.collapsed(offset: 14),
        ),
      );
      await tester.pump();
      expect(controller.text, 'save this');
      expect(cubit.state.text, 'save this');

      gate.complete();
      await tester.pump();
      await tester.pump();
      expect(cubit.state.busy, isFalse);
      expect(cubit.state.isDirty, isFalse);
      expect(utf8.decode(files.written!), 'save this');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('external request waits for existing route confirmation', (
    tester,
  ) async {
    await mount(tester);
    cubit.updateText('unsaved');
    await tester.pump();
    router.goNamed('other');
    await tester.pumpAndSettle();
    files.receiveFiles(['next.json']);
    await tester.pump();
    expect(files.hasPendingFiles, isTrue);
    expect(files.reads, isEmpty);
    expect(find.text('Save changes?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cubit.state.text, 'unsaved');
    expect(find.text('Save changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(files.reads, ['next.json']);
    expect(cubit.state.name, 'next.json');
    expect(files.hasPendingFiles, isFalse);
  });

  for (final failSave in [false, true]) {
    testWidgets(
      'external request resumes after exit Save ${failSave ? 'fails' : 'is cancelled'}',
      (tester) async {
        await mount(tester);
        cubit.updateText('unsaved');
        final gate = Completer<void>();
        files.saveGate = gate;
        files.failSave = failSave;
        addTearDown(() {
          if (!gate.isCompleted) gate.complete();
        });
        await tester.pump();
        router.goNamed('other');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pump();
        expect(cubit.state.busy, isTrue);
        files.receiveFiles(['after-save.json']);
        await tester.pump();
        expect(files.hasPendingFiles, isTrue);
        expect(files.reads, isEmpty);

        gate.complete();
        await tester.pumpAndSettle();
        expect(find.byType(EditorScreen), findsOneWidget);
        expect(find.text('Save changes?'), findsOneWidget);
        expect(cubit.state.text, 'unsaved');
        expect(cubit.state.isDirty, isTrue);
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();
        expect(files.reads, ['after-save.json']);
        expect(cubit.state.name, 'after-save.json');
        expect(files.hasPendingFiles, isFalse);
      },
    );
  }

  testWidgets(
    'successful route exit hands pending external file to a new Editor',
    (tester) async {
      await mount(tester);
      cubit.updateText('unsaved');
      await tester.pump();
      final previousEditor = tester.state(find.byType(EditorScreen));
      List<String>? readsWhenExitCommitted;
      void recordExit() {
        if (router.routerDelegate.currentConfiguration.uri.path == '/other') {
          readsWhenExitCommitted = List.of(files.reads);
        }
      }

      router.routerDelegate.addListener(recordExit);
      addTearDown(() => router.routerDelegate.removeListener(recordExit));
      router.goNamed('other');
      await tester.pumpAndSettle();
      files.receiveFiles(['handoff.json']);
      await tester.pump();
      expect(files.hasPendingFiles, isTrue);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(previousEditor.mounted, isFalse);
      expect(readsWhenExitCommitted, isEmpty);
      expect(router.routeInformationProvider.value.uri.path, '/toolbox/editor');
      expect(find.byType(EditorScreen), findsOneWidget);
      expect(files.reads, ['handoff.json']);
      expect(cubit.state.name, 'handoff.json');
      expect(files.hasPendingFiles, isFalse);
    },
  );

  testWidgets('editor undo/redo and keyboard save use the existing engine', (
    tester,
  ) async {
    await mount(tester);
    final controller = tester
        .widget<dm.DmCodeEditor>(find.byType(dm.DmCodeEditor))
        .controller!;
    controller.insertText('hello');
    await tester.pump();
    expect(cubit.state.text, 'hello');
    await action(tester, 'Undo');
    expect(cubit.state.text, '');
    await action(tester, 'Redo');
    expect(cubit.state.text, 'hello');
    files.destination = _file('saved.txt', '');
    await tester.tap(find.byType(dm.DmCodeEditor));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(utf8.decode(files.written!), 'hello');
    expect(cubit.state.isDirty, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

EditorFile _file(String name, String text) => EditorFile(
  uri: name,
  name: name,
  bytes: Uint8List.fromList(utf8.encode(text)),
);

class _Files extends EditorFileService {
  _Files() : super(nativeDocuments: false);
  EditorFile? destination;
  Uint8List? written;
  bool failSave = false;
  Completer<void>? saveGate;
  int picks = 0;
  final reads = <String>[];

  @override
  Future<EditorFile?> pickFile() async {
    picks++;
    return null;
  }

  @override
  Future<EditorFile> readFile(String uri) async {
    reads.add(uri);
    return _file(uri, '{}');
  }

  @override
  Future<EditorFile?> saveFileAs(String name, Uint8List bytes) async {
    if (saveGate != null) await saveGate!.future;
    if (failSave) throw StateError('sensitive native payload');
    if (destination == null) return null;
    written = bytes;
    return destination;
  }

  @override
  Future<void> writeFile(EditorFile file, Uint8List bytes) async {
    if (failSave) throw StateError('sensitive native payload');
    written = bytes;
  }
}
