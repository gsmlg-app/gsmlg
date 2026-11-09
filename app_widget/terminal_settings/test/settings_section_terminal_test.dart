import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';

class _RecordingTerminalSettingsBloc
    extends Bloc<TerminalSettingsEvent, TerminalSettingsState>
    implements TerminalSettingsBloc {
  _RecordingTerminalSettingsBloc() : super(const TerminalSettingsLoaded()) {
    on<TerminalSettingsUpdateOptionKeyBehavior>(
      (
        TerminalSettingsUpdateOptionKeyBehavior event,
        Emitter<TerminalSettingsState> emit,
      ) {
        events.add(event);
        emit(
          (state as TerminalSettingsLoaded).copyWith(
            optionKeyBehavior: event.optionKeyBehavior,
          ),
        );
      },
    );
  }

  final List<TerminalSettingsEvent> events = <TerminalSettingsEvent>[];
}

Future<void> _pumpSection(
  WidgetTester tester,
  TerminalSettingsBloc bloc,
) async {
  await tester.pumpWidget(
    BlocProvider<TerminalSettingsBloc>.value(
      value: bloc,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(
          body: SettingsList(
            sections: <AbstractSettingsSection>[
              SettingsSectionTerminal(
                envSettingsScreenName: 'env',
                onEnvSettingsPressed: (_) {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SettingsSectionTerminal', () {
    group('construction', () {
      test('can be instantiated', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
        );
        expect(section, isA<SettingsSectionTerminal>());
      });

      test('extends AbstractSettingsSection', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
        );
        expect(section, isA<AbstractSettingsSection>());
      });

      test('accepts optional key', () {
        const key = Key('terminal-settings');
        final section = SettingsSectionTerminal(
          key: key,
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
        );
        expect(section.key, key);
      });

      test('accepts optional onShellProfilesPressed', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
          onShellProfilesPressed: (_) {},
        );
        expect(section.onShellProfilesPressed, isNotNull);
      });

      test('stores envSettingsScreenName', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'test-env',
          onEnvSettingsPressed: (_) {},
        );
        expect(section.envSettingsScreenName, 'test-env');
      });

      test('stores onEnvSettingsPressed', () {
        void callback(BuildContext context) {}
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: callback,
        );
        expect(section.onEnvSettingsPressed, callback);
      });

      test('onShellProfilesPressed is null by default', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
        );
        expect(section.onShellProfilesPressed, isNull);
      });

      test('stores onShellProfilesPressed when provided', () {
        void callback(BuildContext context) {}
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
          onShellProfilesPressed: callback,
        );
        expect(section.onShellProfilesPressed, callback);
      });
    });

    group('properties', () {
      test('envSettingsScreenName is accessible', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'environment-settings',
          onEnvSettingsPressed: (_) {},
        );
        expect(section.envSettingsScreenName, 'environment-settings');
      });

      test('different envSettingsScreenNames are stored correctly', () {
        final section1 = SettingsSectionTerminal(
          envSettingsScreenName: 'env1',
          onEnvSettingsPressed: (_) {},
        );
        final section2 = SettingsSectionTerminal(
          envSettingsScreenName: 'env2',
          onEnvSettingsPressed: (_) {},
        );
        expect(section1.envSettingsScreenName, 'env1');
        expect(section2.envSettingsScreenName, 'env2');
        expect(section1.envSettingsScreenName != section2.envSettingsScreenName,
            isTrue);
      });

      test('callback functions are properly stored', () {
        bool envPressed = false;
        bool shellPressed = false;

        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {
            envPressed = true;
          },
          onShellProfilesPressed: (_) {
            shellPressed = true;
          },
        );

        // Callbacks should be stored but not yet called
        expect(envPressed, isFalse);
        expect(shellPressed, isFalse);
        expect(section.onEnvSettingsPressed, isNotNull);
        expect(section.onShellProfilesPressed, isNotNull);
      });
    });

    group('type checks', () {
      test('is a Widget', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
        );
        expect(section, isA<Widget>());
      });

      test('is a StatelessWidget', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
        );
        expect(section, isA<StatelessWidget>());
      });

      test('is an AbstractSettingsSection', () {
        final section = SettingsSectionTerminal(
          envSettingsScreenName: 'env',
          onEnvSettingsPressed: (_) {},
        );
        expect(section, isA<AbstractSettingsSection>());
      });
    });
  });

  group('Option key behavior', () {
    testWidgets('is shown on macOS and dispatches the selected value',
        (WidgetTester tester) async {
      final bloc = _RecordingTerminalSettingsBloc();
      addTearDown(bloc.close);

      await _pumpSection(tester, bloc);

      expect(find.text('Option Key Behavior'), findsOneWidget);
      expect(find.text('Left Meta'), findsOneWidget);

      await tester.tap(find.byKey(const Key('optionKeyBehaviorDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Both Meta').last);
      await tester.pumpAndSettle();

      expect(bloc.events, <TerminalSettingsEvent>[
        const TerminalSettingsUpdateOptionKeyBehavior(
          optionKeyBehavior: TerminalOptionKeyBehavior.bothMeta,
        ),
      ]);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('is hidden on other platforms', (WidgetTester tester) async {
      final bloc = _RecordingTerminalSettingsBloc();
      addTearDown(bloc.close);

      await _pumpSection(tester, bloc);

      expect(find.text('Option Key Behavior'), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  });
}
