import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:app_locale/app_locale.dart';
import 'package:app_editor/app_editor.dart';
import 'package:app_logging/app_logging.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_bloc/navigation_bloc.dart';
import 'package:theme_bloc/theme_bloc.dart';

import 'core/usage/usage_tracker.dart';
import 'destination.dart';
import 'duo/duo_chat_fallback.dart';
import 'duo/duo_controller.dart';
import 'router.dart';
import 'screens/toolbox/bluetooth/bluetooth_scanner_screen.dart';
import 'screens/toolbox/editor/editor_screen.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    this.arguments = const [],
    this.flushLogs,
    this.onExit,
  });

  final List<String> arguments;

  /// Flushes buffered log records; awaited before the app exits and also
  /// triggered (not awaited) when the app is hidden or paused.
  final Future<void> Function()? flushLogs;

  /// Releases app-wide resources (the isolate hub); awaited after the final
  /// [flushLogs] once an exit is confirmed.
  final Future<void> Function()? onExit;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isOpenWindow = true;
  late final DuoDisplayManager _duoManager;
  StreamSubscription<DmThemeState>? _themeSub;
  StreamSubscription<void>? _editorSub;
  late final AppLifecycleListener _exitListener;
  late final UsageTracker _usage;

  Future<void> _flushLogs() async {
    try {
      await widget.flushLogs?.call();
    } catch (error, stackTrace) {
      AppLogger().e('Log flush failed', error, stackTrace);
    }
  }

  Future<void> _shutdown() async {
    try {
      await widget.onExit?.call();
    } catch (error, stackTrace) {
      AppLogger().e('Shutdown failed', error, stackTrace);
    }
  }

  /// Closes the open screen visit, then flushes without blocking the
  /// lifecycle callback (the OS may suspend the app soon after).
  void _onBackground() {
    _usage.onBackground();
    unawaited(_flushLogs());
  }

  Future<AppExitResponse> _confirmExit() async {
    final navigationContext = AppRouter.key.currentContext;
    if (navigationContext == null) return AppExitResponse.exit;
    return await EditorScreen.confirmExit(navigationContext)
        ? AppExitResponse.exit
        : AppExitResponse.cancel;
  }

  @override
  void initState() {
    super.initState();
    final navBloc = context.read<NavigationBloc>();
    final themeBloc = context.read<DmThemeBloc>();
    final editorFiles = context.read<EditorFileService>();
    _editorSub = editorFiles.openRequests.listen((_) => _openEditor());
    _usage = UsageTracker()..start();
    _exitListener = AppLifecycleListener(
      onResume: () => _usage.onForeground(),
      onDetach: () => _usage.onBackground(),
      onHide: _onBackground,
      onPause: _onBackground,
      onExitRequested: () async {
        final response = await _confirmExit();
        // Close the session before flushing so session_end is persisted.
        if (response == AppExitResponse.exit) _usage.dispose();
        await _flushLogs();
        if (response == AppExitResponse.exit) await _shutdown();
        return response;
      },
    );
    unawaited(
      editorFiles
          .initialize(widget.arguments)
          .then((_) {
            if (editorFiles.hasPendingFiles) _openEditor();
          })
          .catchError((Object error, StackTrace stackTrace) {
            AppLogger().e(
              'Editor file-open initialization failed',
              error,
              stackTrace,
            );
          }),
    );

    _duoManager = DuoDisplayManager(
      secondary: false,
      platform: defaultDisplayPlatform(),
      bridge: defaultBridge(secondary: false),
      routeKeyboard: true,
    );

    _duoManager.onConnectionChanged = (connected) {
      navBloc.add(NavigationDuoConnectionChanged(connected));
      _syncDuoState();
    };

    _duoManager.onSelectTab = (idx) {
      final navContext = AppRouter.key.currentContext;
      if (navContext != null) {
        Destinations.changeHandler(idx, navContext);
      }
    };

    _duoManager.onNavigateRoute = (routeName) {
      try {
        final target = switch (routeName) {
          'Bluetooth' => BluetoothScannerScreen.name,
          _ => routeName,
        };
        AppRouter.router.goNamed(target);
      } catch (_) {}
    };

    DuoChatFallback(
      chatBloc: context.read<ChatBloc>(),
      settingsBloc: context.read<ChatSettingsBloc>(),
      router: AppRouter.router,
    ).install(_duoManager);

    _duoManager.onToggleTheme = () {
      final mode = themeBloc.state.themeMode;
      final isDark =
          mode == ThemeMode.dark ||
          (mode == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);
      themeBloc.add(DmSetThemeMode(isDark ? ThemeMode.light : ThemeMode.dark));
    };

    _duoManager.start();
    _themeSub = themeBloc.stream.listen((_) => _syncDuoState());
    AppRouter.router.routerDelegate.addListener(_syncDuoState);
    AppRouter.router.routerDelegate.addListener(_trackRoute);
    _trackRoute();
  }

  void _trackRoute() {
    final configuration = AppRouter.router.routerDelegate.currentConfiguration;
    if (configuration.isEmpty) return;
    _usage.onRouteChanged(
      configuration.uri,
      configuration.last.route.name,
      routeTemplate: configuration.fullPath,
    );
  }

  void _openEditor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppRouter.router.routeInformationProvider.value.uri.path ==
          AppRouter.router.namedLocation(EditorScreen.name)) {
        return;
      }
      AppRouter.router.goNamed(EditorScreen.name);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _syncDuoState() {
    if (!mounted) return;
    final themeBloc = context.read<DmThemeBloc>();
    final mode = themeBloc.state.themeMode;
    final isDark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    final route = AppRouter.router.routerDelegate.currentConfiguration.uri
        .toString();
    var idx = 0;
    if (route.startsWith('/service')) {
      idx = 1;
    } else if (route.startsWith('/toolbox')) {
      idx = 2;
    } else if (route.startsWith('/settings')) {
      idx = 3;
    }

    _duoManager.updatePrimaryState(
      selectedIndex: idx,
      currentRoute: route,
      isDark: isDark,
    );
  }

  @override
  void dispose() {
    _editorSub?.cancel();
    _exitListener.dispose();
    _themeSub?.cancel();
    AppRouter.router.routerDelegate.removeListener(_syncDuoState);
    AppRouter.router.routerDelegate.removeListener(_trackRoute);
    _usage.dispose();
    _duoManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<DmThemeBloc>();

    return BlocBuilder<DmThemeBloc, DmThemeState>(
      bloc: themeBloc,
      builder: (context, state) {
        final router = AppRouter.router;
        final entry = state.entry;
        return MaterialApp.router(
          key: const Key('app'),
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          onGenerateTitle: (context) => context.l10n.appName,
          theme: entry.light,
          darkTheme: entry.dark,
          themeMode: state.themeMode,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
        );
      },
    );
  }
}
