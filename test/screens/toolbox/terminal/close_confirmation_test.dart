import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:gsmlg/screens/toolbox/terminal/close_confirmation.dart';
import 'package:gsmlg/screens/toolbox/terminal/terminal_screen.dart';

class _FakeVaultRepository implements VaultRepository {
  final Map<String, String> _storage = <String, String>{};

  @override
  Future<bool> containsKey({required String key}) async =>
      _storage.containsKey(key);

  @override
  Future<void> delete({required String key}) async => _storage.remove(key);

  @override
  Future<void> deleteAll() async => _storage.clear();

  @override
  Future<String?> read({required String key}) async => _storage[key];

  @override
  Future<Map<String, String>> readAll() async => Map.of(_storage);

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }
}

class _Session implements ExecutionSession, ForegroundProcessAware {
  _Session({required this.busy});

  bool busy;
  final Completer<int> _exitCode = Completer<int>();

  @override
  Future<bool> hasForegroundProcess() async => busy;

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  Stream<Uint8List> get output => const Stream<Uint8List>.empty();

  @override
  Future<void> close() async {
    if (!_exitCode.isCompleted) _exitCode.complete(0);
  }

  @override
  void ackRead() {}

  @override
  Future<void> resize(int width, int height) async {}

  @override
  Future<void> write(Uint8List data) async {}
}

class _Host extends Fake implements Host {
  _Host({required this.busy});

  final bool busy;
  final Completer<void> _done = Completer<void>();

  @override
  Future<void> get done => _done.future;

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async => _Session(busy: busy);

  @override
  Future<void> disconnect() async {
    if (!_done.isCompleted) _done.complete();
  }
}

class _Connector extends HostConnector<_Host> {
  _Connector(this.fakeHost);

  final _Host fakeHost;

  @override
  Future<_Host> createHost() async => fakeHost;
}

class _Spec implements HostSpec {
  _Spec({required this.busy});

  final bool busy;

  @override
  String get name => busy ? 'busy' : 'idle';

  @override
  HostConnector createConnector() => _Connector(_Host(busy: busy));
}

PluginTab _tabWithSession({required bool busy}) {
  final plugin = TerminalPlugin()..session = _Session(busy: busy);
  return PluginTab(plugin, PluginManager(_Spec(busy: busy)));
}

void _disposeTab(PluginTab tab) {
  final plugin = tab.plugin as TerminalPlugin;
  tab.dispose();
  plugin.terminal.dispose();
}

Future<AppExitResponse> _requestAppExit(WidgetTester tester) async {
  final completer = Completer<AppExitResponse>();
  const codec = JSONMethodCodec();
  unawaited(
    tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.platform.name,
      codec.encodeMethodCall(const MethodCall('System.requestAppExit')),
      (ByteData? reply) {
        final result = codec.decodeEnvelope(reply!) as Map<String, Object?>;
        completer.complete(
          AppExitResponse.values.byName(result['response']! as String),
        );
      },
    ),
  );
  return completer.future;
}

void main() {
  group('confirmCloseTab', () {
    Future<ValueNotifier<bool?>> pumpCloser(
      WidgetTester tester,
      PluginTab tab,
    ) async {
      final result = ValueNotifier<bool?>(null);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () async {
                result.value = await confirmCloseTab(context, tab);
              },
              child: const Text('close'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('close'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('closes an idle shell without asking', (tester) async {
      final tab = _tabWithSession(busy: false);
      addTearDown(() => _disposeTab(tab));

      final result = await pumpCloser(tester, tab);

      expect(find.byType(AlertDialog), findsNothing);
      expect(result.value, isTrue);
    });

    testWidgets('asks before closing a busy tab and honours cancel', (
      tester,
    ) async {
      final tab = _tabWithSession(busy: true);
      addTearDown(() => _disposeTab(tab));

      final result = await pumpCloser(tester, tab);

      expect(find.text('Close Tab?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(result.value, isFalse);
    });

    testWidgets('closes a busy tab once confirmed', (tester) async {
      final tab = _tabWithSession(busy: true);
      addTearDown(() => _disposeTab(tab));

      final result = await pumpCloser(tester, tab);

      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();
      expect(result.value, isTrue);
    });
  });

  group('confirmCloseGroup', () {
    Future<ValueNotifier<bool?>> pumpGroupCloser(
      WidgetTester tester,
      List<PluginTab> tabs,
    ) async {
      final result = ValueNotifier<bool?>(null);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () async {
                result.value = await confirmCloseGroup(context, tabs);
              },
              child: const Text('close group'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('close group'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('returns true without a dialog when no tab is busy', (
      tester,
    ) async {
      final tabs = [_tabWithSession(busy: false), _tabWithSession(busy: false)];
      addTearDown(() => tabs.forEach(_disposeTab));

      final result = await pumpGroupCloser(tester, tabs);

      expect(find.byType(AlertDialog), findsNothing);
      expect(result.value, isTrue);
    });

    testWidgets('lists busy tabs once and returns false on Cancel', (
      tester,
    ) async {
      final tabs = [
        _tabWithSession(busy: true),
        _tabWithSession(busy: false),
        _tabWithSession(busy: true),
      ];
      addTearDown(() => tabs.forEach(_disposeTab));

      final result = await pumpGroupCloser(tester, tabs);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Close Group?'), findsOneWidget);
      expect(
        find.textContaining('2 tabs in this group have running programs'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(result.value, isFalse);
    });

    testWidgets('returns true once confirmed', (tester) async {
      final tabs = [_tabWithSession(busy: true)];
      addTearDown(() => tabs.forEach(_disposeTab));

      final result = await pumpGroupCloser(tester, tabs);

      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();
      expect(result.value, isTrue);
    });
  });

  group('AppExitGuard', () {
    late TerminalTabBloc tabBloc;
    late List<PluginTab> tabs;

    Future<void> pumpGuard(WidgetTester tester, List<bool> busy) async {
      tabBloc = TerminalTabBloc()..add(TerminalTabStart());
      addTearDown(tabBloc.close);
      await tester.pump();
      tabs = <PluginTab>[
        for (final isBusy in busy) _tabWithSession(busy: isBusy),
      ];
      for (final tab in tabs) {
        tabBloc.add(TerminalTabOpenTab(tab, activate: false));
      }
      addTearDown(() {
        for (final tab in tabs) {
          _disposeTab(tab);
        }
      });
      await tester.pump();

      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        BlocProvider<TerminalTabBloc>.value(
          value: tabBloc,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            builder: (BuildContext context, Widget? child) =>
                AppExitGuard(navigatorKey: navigatorKey, child: child!),
            home: const SizedBox.shrink(),
          ),
        ),
      );
    }

    testWidgets('quits without asking when every shell is idle', (
      tester,
    ) async {
      await pumpGuard(tester, <bool>[false, false]);

      final response = _requestAppExit(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(await response, AppExitResponse.exit);
    });

    testWidgets('lists busy tabs and cancels the quit', (tester) async {
      await pumpGuard(tester, <bool>[true, false, true]);

      final response = _requestAppExit(tester);
      await tester.pumpAndSettle();

      expect(find.text('Quit GSMLG?'), findsOneWidget);
      final message = tester
          .widget<Text>(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.textContaining('running programs'),
            ),
          )
          .data!;
      expect(message, contains('2 tabs have running programs'));
      expect(message, contains(tabs[0].displayTitle));
      expect(message, isNot(contains(tabs[1].displayTitle)));
      expect(message, contains(tabs[2].displayTitle));

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(await response, AppExitResponse.cancel);
    });

    testWidgets('quits once the user confirms', (tester) async {
      await pumpGuard(tester, <bool>[true]);

      final response = _requestAppExit(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Quit'));
      await tester.pumpAndSettle();

      expect(await response, AppExitResponse.exit);
    });
  });

  group('Cmd+W', () {
    Future<TerminalTabBloc> pumpScreen(
      WidgetTester tester, {
      required bool busy,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting();
      addTearDown(database.close);
      final tabBloc = TerminalTabBloc()..add(TerminalTabStart());
      addTearDown(tabBloc.close);
      await tester.pump();
      final tab = PluginTab(TerminalPlugin(), PluginManager(_Spec(busy: busy)));
      tabBloc.add(TerminalTabOpenTab(tab));
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        final state = tabBloc.state;
        if (state is TerminalTabLoaded) {
          for (final tab in state.allTabs.whereType<PluginTab>()) {
            _disposeTab(tab);
          }
        }
        await tester.pump();
      });

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: <RepositoryProvider<Object>>[
            RepositoryProvider<SharedPreferences>.value(value: prefs),
            RepositoryProvider<AppDatabase>.value(value: database),
          ],
          child: MultiBlocProvider(
            providers: <BlocProvider<Object?>>[
              BlocProvider<TerminalTabBloc>.value(value: tabBloc),
              BlocProvider<TerminalSettingsBloc>(
                create: (BuildContext context) =>
                    TerminalSettingsBloc(vault: _FakeVaultRepository()),
              ),
              BlocProvider<ShellProfileBloc>(
                create: (BuildContext context) => ShellProfileBloc(database),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocale.localizationsDelegates,
              supportedLocales: AppLocale.supportedLocales,
              home: const TerminalScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final plugin = tab.plugin as TerminalPlugin;
      expect(plugin.session, isNotNull);
      return tabBloc;
    }

    Future<void> pressCmdW(WidgetTester tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();
      await tester.pump();
    }

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    int tabCount(TerminalTabBloc bloc) =>
        (bloc.state as TerminalTabLoaded).tabCount;

    testWidgets(
      'closes an idle tab without asking',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        final tabBloc = await pumpScreen(tester, busy: false);

        await pressCmdW(tester);

        expect(find.byType(AlertDialog), findsNothing);
        expect(tabCount(tabBloc), 0);
      },
    );

    testWidgets(
      'asks before closing a busy tab and keeps it on cancel',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        final tabBloc = await pumpScreen(tester, busy: true);

        await pressCmdW(tester);
        await settle(tester);

        expect(find.text('Close Tab?'), findsOneWidget);
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await settle(tester);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tabCount(tabBloc), 1);

        await pressCmdW(tester);
        await settle(tester);
        await tester.tap(find.widgetWithText(TextButton, 'Close'));
        await settle(tester);
        expect(tabCount(tabBloc), 0);
      },
    );
  });
}
