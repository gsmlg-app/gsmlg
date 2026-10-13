import 'dart:async';

import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation_bloc/navigation_bloc.dart';
import 'package:theme_bloc/theme_bloc.dart';

import 'destination.dart';
import 'duo/duo_controller.dart';
import 'router.dart';
import 'screens/home/home_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isOpenWindow = true;
  late final DuoDisplayManager _duoManager;
  StreamSubscription<DmThemeState>? _themeSub;

  @override
  void initState() {
    super.initState();
    final navBloc = context.read<NavigationBloc>();
    final themeBloc = context.read<DmThemeBloc>();

    _duoManager = DuoDisplayManager(
      secondary: false,
      platform: defaultDisplayPlatform(),
      bridge: defaultBridge(secondary: false),
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
        AppRouter.router.goNamed(routeName);
      } catch (_) {}
    };

    _duoManager.onFallbackTextSubmit = (text) {
      try {
        AppRouter.router.goNamed(HomeScreen.name);
        context.read<ChatBloc>().add(ChatSendMessage(content: text));
      } catch (_) {}
    };

    _duoManager.onToggleTheme = () {
      final mode = themeBloc.state.themeMode;
      final isDark = mode == ThemeMode.dark ||
          (mode == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);
      themeBloc.add(DmSetThemeMode(isDark ? ThemeMode.light : ThemeMode.dark));
    };

    _duoManager.start();
    _themeSub = themeBloc.stream.listen((_) => _syncDuoState());
    AppRouter.router.routerDelegate.addListener(_syncDuoState);
  }

  void _syncDuoState() {
    if (!mounted) return;
    final themeBloc = context.read<DmThemeBloc>();
    final mode = themeBloc.state.themeMode;
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    final route =
        AppRouter.router.routerDelegate.currentConfiguration.uri.toString();
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
    _themeSub?.cancel();
    AppRouter.router.routerDelegate.removeListener(_syncDuoState);
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
