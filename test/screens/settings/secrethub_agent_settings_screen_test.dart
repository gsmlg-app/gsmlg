import 'dart:convert';

import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/settings/secrethub_agent/secrethub_agent_config.dart';
import 'package:gsmlg/screens/settings/secrethub_agent/secrethub_agent_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _channel = MethodChannel('secrethub_agent');
const _pem = '-----BEGIN CERTIFICATE-----\nMIIB\n-----END CERTIFICATE-----';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecretHubAgentConfig', () {
    test('round-trips through SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const config = SecretHubAgentConfig(
        coreUrl: ' https://core.example.com:4665 ',
        trust: SecretHubTrust.pinnedCa,
        pinnedCaPem: _pem,
        bindings: [
          SecretHubBinding(
            alias: ' token ',
            path: 'prod.mobile.service_token',
            allowOffline: true,
          ),
        ],
      );

      await config.save(prefs);
      final loaded = SecretHubAgentConfig.load(prefs);

      expect(loaded.coreUrl, 'https://core.example.com:4665');
      expect(loaded.trust, SecretHubTrust.pinnedCa);
      expect(loaded.pinnedCaPem, _pem);
      expect(loaded.bindings, const [
        SecretHubBinding(
          alias: 'token',
          path: 'prod.mobile.service_token',
          allowOffline: true,
        ),
      ]);
    });

    test('missing or corrupt prefs load defaults', () async {
      SharedPreferences.setMockInitialValues({
        SecretHubAgentConfig.prefsKey: '{not json',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(SecretHubAgentConfig.load(prefs).isEmpty, isTrue);
    });

    test('system trust does not persist a pinned CA', () {
      const config = SecretHubAgentConfig(
        coreUrl: 'https://core.example.com',
        pinnedCaPem: _pem,
      );
      expect(config.toJson().containsKey('pinnedCaPem'), isFalse);
    });

    test('validate reports each problem once', () {
      const config = SecretHubAgentConfig(
        coreUrl: 'http://core.example.com',
        trust: SecretHubTrust.pinnedCa,
        pinnedCaPem: 'not a cert',
        bindings: [
          SecretHubBinding(alias: 'a', path: 'x'),
          SecretHubBinding(alias: 'a', path: 'y'),
          SecretHubBinding(alias: '', path: 'z'),
          SecretHubBinding(alias: 'b', path: ' '),
        ],
      );
      expect(config.validate(), [
        SecretHubConfigError.invalidCoreUrl,
        SecretHubConfigError.invalidPinnedCa,
        SecretHubConfigError.duplicateAlias,
        SecretHubConfigError.incompleteBinding,
      ]);
      expect(
        const SecretHubAgentConfig(
          coreUrl: 'https://core.example.com',
        ).validate(),
        isEmpty,
      );
    });
  });

  group('SecretHubAgentSettingsScreen', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            if (call.method == 'getPlatformVersion') return 'iOS 27.2';
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, null);
    });

    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        RepositoryProvider<SharedPreferences>.value(
          value: prefs,
          child: MaterialApp(
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            home: const SecretHubAgentSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows native plugin status and disabled connect/fetch', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('SecretHub Agent'), findsOneWidget);
      expect(find.text('iOS 27.2'), findsOneWidget);
      final connect = tester.widget<ListTile>(
        find.byKey(const Key('secrethub-connect')),
      );
      final fetch = tester.widget<ListTile>(
        find.byKey(const Key('secrethub-fetch')),
      );
      expect(connect.enabled, isFalse);
      expect(fetch.enabled, isFalse);
      expect(
        find.text('Waiting for plugin support (gsmlg-app/secrethub_agent#1)'),
        findsNWidgets(2),
      );
    });

    testWidgets('saves a valid config', (tester) async {
      await pump(tester);

      await tester.enterText(
        find.byKey(const Key('secrethub-core-url')),
        'https://core.example.com:4665',
      );
      await tester.tap(find.byKey(const Key('secrethub-add-secret')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('secrethub-alias-0')), 'tok');
      await tester.enterText(
        find.byKey(const Key('secrethub-path-0')),
        'prod.mobile.service_token',
      );
      await tester.tap(find.byKey(const Key('secrethub-save')));
      await tester.pumpAndSettle();

      expect(find.text('SecretHub Agent settings saved'), findsOneWidget);
      final saved =
          jsonDecode(prefs.getString(SecretHubAgentConfig.prefsKey)!) as Map;
      expect(saved['coreUrl'], 'https://core.example.com:4665');
      expect(saved['bindings'], [
        {
          'alias': 'tok',
          'path': 'prod.mobile.service_token',
          'allowOffline': false,
        },
      ]);
    });

    testWidgets('invalid config shows errors and is not saved', (tester) async {
      await pump(tester);

      await tester.enterText(
        find.byKey(const Key('secrethub-core-url')),
        'http://insecure',
      );
      await tester.tap(find.byKey(const Key('secrethub-save')));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter an https:// Core URL with a host.'),
        findsOneWidget,
      );
      expect(prefs.getString(SecretHubAgentConfig.prefsKey), isNull);
    });

    testWidgets('loads the saved config', (tester) async {
      await const SecretHubAgentConfig(
        coreUrl: 'https://saved.example.com',
        bindings: [SecretHubBinding(alias: 'db', path: 'prod.db.password')],
      ).save(prefs);

      await pump(tester);

      expect(find.text('https://saved.example.com'), findsOneWidget);
      expect(find.text('db'), findsOneWidget);
      expect(find.text('prod.db.password'), findsOneWidget);
    });
  });
}
