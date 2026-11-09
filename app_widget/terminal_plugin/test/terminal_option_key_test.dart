import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:xterm/xterm.dart';

class _FakeTerminalSettingsBloc
    extends Bloc<TerminalSettingsEvent, TerminalSettingsState>
    implements TerminalSettingsBloc {
  _FakeTerminalSettingsBloc(super.initialState) {
    on<TerminalSettingsUpdateOptionKeyBehavior>(
      (
        TerminalSettingsUpdateOptionKeyBehavior event,
        Emitter<TerminalSettingsState> emit,
      ) {
        emit(
          (state as TerminalSettingsLoaded).copyWith(
            optionKeyBehavior: event.optionKeyBehavior,
          ),
        );
      },
    );
  }
}

void main() {
  Future<TerminalPlugin> pumpTerminal(
    WidgetTester tester, {
    TerminalSettingsBloc? bloc,
  }) async {
    final plugin = TerminalPlugin();
    addTearDown(plugin.terminal.dispose);
    final Widget app = MaterialApp(
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      home: Scaffold(body: TerminalTabView(plugin)),
    );
    await tester.pumpWidget(
      bloc == null
          ? app
          : BlocProvider<TerminalSettingsBloc>.value(value: bloc, child: app),
    );
    await tester.pump();
    return plugin;
  }

  MacOptionKeyBehavior viewBehavior(WidgetTester tester) {
    return tester
        .widget<TerminalView>(find.byType(TerminalView))
        .macOptionKeyBehavior;
  }

  testWidgets(
    'macOS terminal uses the macOS platform and leftMeta by default',
    (WidgetTester tester) async {
      final plugin = await pumpTerminal(tester);

      expect(plugin.terminal.platform, TerminalTargetPlatform.macos);
      expect(viewBehavior(tester), MacOptionKeyBehavior.leftMeta);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'Option key behavior follows the terminal settings',
    (WidgetTester tester) async {
      final bloc = _FakeTerminalSettingsBloc(
        const TerminalSettingsLoaded(
          optionKeyBehavior: TerminalOptionKeyBehavior.normal,
        ),
      );
      addTearDown(bloc.close);

      await pumpTerminal(tester, bloc: bloc);
      expect(viewBehavior(tester), MacOptionKeyBehavior.normal);

      bloc.add(
        const TerminalSettingsUpdateOptionKeyBehavior(
          optionKeyBehavior: TerminalOptionKeyBehavior.bothMeta,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(viewBehavior(tester), MacOptionKeyBehavior.bothMeta);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'non-macOS terminal keeps the unknown platform',
    (WidgetTester tester) async {
      final plugin = await pumpTerminal(tester);

      expect(plugin.terminal.platform, TerminalTargetPlatform.unknown);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}
