import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_vnc/app_vnc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_hosts_screen.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_launch_config.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_session_screen.dart';
import 'package:gsmlg/screens/toolbox/vnc/widgets/vnc_auth_dialog.dart';
import 'package:gsmlg/screens/toolbox/vnc/widgets/vnc_host_form_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:vnc_host_bloc/vnc_host_bloc.dart';
import 'package:vnc_session_bloc/vnc_session_bloc.dart';

class MockVncHostBloc extends MockBloc<VncHostEvent, VncHostState>
    implements VncHostBloc {}

class MockSshHostBloc extends MockBloc<SshHostEvent, SshHostState>
    implements SshHostBloc {}

class FakeVncSessionClient implements VncSessionClient {
  final StreamController<VncClientEvent> _eventsController =
      StreamController<VncClientEvent>.broadcast();

  final List<VncConnectionConfig> connectCalls = [];
  final List<VncCredentials> submittedCredentials = [];
  int cancelCredentialsCount = 0;
  int disconnectCount = 0;

  void emitEvent(VncClientEvent event) {
    if (!_eventsController.isClosed) {
      _eventsController.add(event);
    }
  }

  @override
  Stream<VncClientEvent> get events => _eventsController.stream;

  @override
  Future<void> connect(VncConnectionConfig config) async {
    connectCalls.add(config);
    emitEvent(const VncConnectingEvent());
  }

  @override
  void submitCredentials(VncCredentials credentials) {
    submittedCredentials.add(credentials);
  }

  @override
  void cancelCredentials() {
    cancelCredentialsCount++;
  }

  @override
  void sendPointerEvent(int x, int y, int buttonMask) {}

  @override
  void sendKeyEvent(int keysym, {required bool down}) {}

  @override
  void sendClipboardText(String text) {}

  @override
  void setViewOnly(bool viewOnly) {}

  @override
  void requestFullRefresh() {}

  @override
  Future<void> disconnect() async {
    disconnectCount++;
  }

  Future<void> dispose() async {
    if (!_eventsController.isClosed) {
      await _eventsController.close();
    }
  }
}

void main() {
  late SharedPreferences sharedPrefs;
  late DmThemeBloc themeBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
    themeBloc = DmThemeBloc(prefs: sharedPrefs);
  });

  tearDown(() async {
    await themeBloc.close();
  });

  Widget wrapWithApp(
    Widget child, {
    List<BlocProvider<dynamic>> extraProviders = const [],
  }) {
    return RepositoryProvider<SharedPreferences>.value(
      value: sharedPrefs,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DmThemeBloc>.value(value: themeBloc),
          ...extraProviders,
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: child,
        ),
      ),
    );
  }

  group('VncScreen', () {
    late MockVncHostBloc vncHostBloc;
    late MockSshHostBloc sshHostBloc;

    setUp(() {
      vncHostBloc = MockVncHostBloc();
      sshHostBloc = MockSshHostBloc();
    });

    tearDown(() async {
      await vncHostBloc.close();
      await sshHostBloc.close();
    });

    testWidgets(
      'renders saved hosts (ARD badge, SSH tunnel badge, dangling sshHostId) and LAN-discovered hosts',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final now = DateTime(2026, 11, 24);
        final savedHosts = [
          VncHost(
            id: 1,
            name: 'Mac Studio',
            host: '192.168.1.50',
            port: 5900,
            authType: VncHostAuthType.appleArd.value,
            username: 'alice',
            passwordRef: 'vnc_host:1:password:abc',
            sshHostId: 10,
            viewOnly: false,
            createdAt: now,
            lastConnectedAt: now,
          ),
          VncHost(
            id: 2,
            name: 'Dangling Tunnel Box',
            host: '10.0.0.25',
            port: 5901,
            authType: VncHostAuthType.vncPassword.value,
            username: null,
            passwordRef: null,
            sshHostId: 999,
            viewOnly: true,
            createdAt: now,
            lastConnectedAt: null,
          ),
        ];

        final discoveredHosts = [
          const VncDiscoveredHost(
            name: 'Office Mac mini',
            host: 'office-mac.local',
            port: 5900,
            addresses: ['192.168.1.88'],
          ),
        ];

        final sshHosts = [
          SshHost(
            id: 10,
            host: 'bastion',
            hostname: 'bastion.example.com',
            port: 22,
            username: 'ops',
            password: null,
            salt: null,
            identityKeyId: null,
            identityType: SshIdentityType.password.value,
            createdAt: now,
          ),
        ];

        whenListen(
          vncHostBloc,
          const Stream<VncHostState>.empty(),
          initialState: VncHostState(
            hosts: savedHosts,
            discoveredHosts: discoveredHosts,
          ),
        );
        whenListen(
          sshHostBloc,
          const Stream<SshHostState>.empty(),
          initialState: SshHostLoaded(sshHosts),
        );

        await tester.pumpWidget(
          wrapWithApp(
            const VncScreen(autoDiscover: false),
            extraProviders: [
              BlocProvider<VncHostBloc>.value(value: vncHostBloc),
              BlocProvider<SshHostBloc>.value(value: sshHostBloc),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Mac Studio'), findsOneWidget);
        expect(find.text('192.168.1.50:5900'), findsOneWidget);
        expect(find.text('macOS (ARD)'), findsOneWidget);
        expect(find.text('SSH Tunnel: bastion'), findsOneWidget);

        // Dangling sshHostId (999) renders without crashing and omits tunnel badge.
        expect(find.text('Dangling Tunnel Box'), findsOneWidget);
        expect(find.text('10.0.0.25:5901'), findsOneWidget);
        expect(find.text('VNC Password'), findsOneWidget);
        expect(find.text('View Only'), findsOneWidget);

        // Bonjour LAN-discovered host renders with Connect and Save actions.
        expect(find.text('Office Mac mini'), findsOneWidget);
        expect(find.text('192.168.1.88:5900'), findsOneWidget);
        expect(find.text('Connect'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Quick Connect opens VncHostFormDialog and validates required host field',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        whenListen(
          vncHostBloc,
          const Stream<VncHostState>.empty(),
          initialState: const VncHostState(),
        );
        whenListen(
          sshHostBloc,
          const Stream<SshHostState>.empty(),
          initialState: const SshHostLoaded([]),
        );

        await tester.pumpWidget(
          wrapWithApp(
            const VncScreen(autoDiscover: false),
            extraProviders: [
              BlocProvider<VncHostBloc>.value(value: vncHostBloc),
              BlocProvider<SshHostBloc>.value(value: sshHostBloc),
            ],
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Quick Connect'));
        await tester.pumpAndSettle();

        expect(find.byType(VncHostFormDialog), findsOneWidget);
        // Name field is omitted in quickConnect mode.
        expect(find.text('Name'), findsNothing);
        expect(find.text('Host'), findsOneWidget);

        // Submitting without a host triggers validation error and keeps dialog open.
        await tester.tap(find.widgetWithText(FilledButton, 'Connect'));
        await tester.pumpAndSettle();

        expect(find.text('Host is required'), findsOneWidget);
        expect(find.byType(VncHostFormDialog), findsOneWidget);
      },
    );
  });

  group('VncSessionScreen', () {
    testWidgets(
      'shows VncAuthDialog with Username field on VncAuthRequiredEvent(30, requiresUsername: true) and submits credentials',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeClient = FakeVncSessionClient();
        final sessionBloc = VncSessionBloc(clientFactory: () => fakeClient);
        addTearDown(() async {
          await sessionBloc.close();
          await fakeClient.dispose();
        });

        const launch = VncLaunchConfig(
          title: 'Mac Studio',
          config: VncConnectionConfig(
            host: '192.168.1.50',
            port: 5900,
            authPreference: VncAuthPreference.appleArd,
          ),
        );

        await tester.pumpWidget(
          wrapWithApp(
            VncSessionScreen(launchConfig: launch, blocOverride: sessionBloc),
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(fakeClient.connectCalls, hasLength(1));

        fakeClient.emitEvent(
          const VncAuthRequiredEvent(securityType: 30, requiresUsername: true),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(VncAuthDialog), findsOneWidget);
        expect(find.text('VNC Authentication Required'), findsOneWidget);

        final usernameField = find.widgetWithText(TextFormField, 'Username');
        final passwordField = find.widgetWithText(TextFormField, 'Password');
        expect(usernameField, findsOneWidget);
        expect(passwordField, findsOneWidget);

        await tester.enterText(usernameField, 'alice');
        await tester.enterText(passwordField, 's3cr3t');
        await tester.tap(find.widgetWithText(FilledButton, 'Connect'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(VncAuthDialog), findsNothing);
        expect(fakeClient.submittedCredentials, hasLength(1));
        expect(
          fakeClient.submittedCredentials.single,
          const VncCredentials(username: 'alice', password: 's3cr3t'),
        );
      },
    );

    testWidgets(
      'displays vncMacosSharingHint when VncUnsupportedSecurityTypeException occurs',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeClient = FakeVncSessionClient();
        final sessionBloc = VncSessionBloc(clientFactory: () => fakeClient);
        addTearDown(() async {
          await sessionBloc.close();
          await fakeClient.dispose();
        });

        const launch = VncLaunchConfig(
          title: 'MacBook Pro',
          config: VncConnectionConfig(host: '192.168.1.60', port: 5900),
        );

        await tester.pumpWidget(
          wrapWithApp(
            VncSessionScreen(launchConfig: launch, blocOverride: sessionBloc),
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(fakeClient.connectCalls, hasLength(1));

        fakeClient.emitEvent(
          VncErrorEvent(VncUnsupportedSecurityTypeException(const [35, 36])),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Tip: On macOS, open System Settings → General → Sharing → Screen Sharing (or Remote Management) and ensure access is enabled for your user account.',
          ),
          findsOneWidget,
        );
        expect(find.text('Offered security types: 35, 36'), findsOneWidget);
        expect(find.text('Reconnect'), findsOneWidget);
      },
    );
  });
}
