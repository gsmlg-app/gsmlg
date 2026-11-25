import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_vnc/app_vnc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_hosts_screen.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_launch_config.dart';
import 'package:gsmlg/screens/toolbox/vnc/vnc_session_screen.dart';
import 'package:gsmlg/screens/toolbox/vnc/widgets/vnc_auth_dialog.dart';
import 'package:gsmlg/screens/toolbox/vnc/widgets/vnc_host_form_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:vnc_host_bloc/vnc_host_bloc.dart';
import 'package:vnc_session_bloc/vnc_session_bloc.dart';
import 'package:vnc_viewer_widgets/vnc_viewer_widgets.dart';

class MockVncHostBloc extends MockBloc<VncHostEvent, VncHostState>
    implements VncHostBloc {}

class MockSshHostBloc extends MockBloc<SshHostEvent, SshHostState>
    implements SshHostBloc {}

class FakeVncSessionClient implements VncSessionClient {
  final StreamController<VncClientEvent> _eventsController =
      StreamController<VncClientEvent>.broadcast();

  final List<VncConnectionConfig> connectCalls = [];
  final List<VncCredentials> submittedCredentials = [];
  final List<VncScreenInfo?> activeRegionCalls = [];
  final List<int?> selectDisplayCalls = [];
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
  void setActiveRegion(VncScreenInfo? region) {
    activeRegionCalls.add(region);
  }

  @override
  void selectDisplay(int? displayId) {
    selectDisplayCalls.add(displayId);
  }

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

    testWidgets(
      'tapping a saved host with a missing SSH tunnel host shows error SnackBar and does not navigate',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final now = DateTime(2026, 11, 24);
        final danglingHost = VncHost(
          id: 42,
          name: 'Dangling Tunnel Box',
          host: '10.0.0.25',
          port: 5901,
          authType: VncHostAuthType.vncPassword.value,
          username: null,
          passwordRef: null,
          sshHostId: 999,
          viewOnly: false,
          createdAt: now,
          lastConnectedAt: null,
        );

        whenListen(
          vncHostBloc,
          const Stream<VncHostState>.empty(),
          initialState: VncHostState(hosts: [danglingHost]),
        );
        whenListen(
          sshHostBloc,
          const Stream<SshHostState>.empty(),
          initialState: const SshHostLoaded([]),
        );

        var sessionRouteOpened = false;
        final router = GoRouter(
          initialLocation: '/vnc',
          routes: [
            GoRoute(
              name: VncScreen.name,
              path: '/vnc',
              builder: (_, _) => const VncScreen(autoDiscover: false),
              routes: [
                GoRoute(
                  name: VncSessionScreen.name,
                  path: VncSessionScreen.path,
                  builder: (_, _) {
                    sessionRouteOpened = true;
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          RepositoryProvider<SharedPreferences>.value(
            value: sharedPrefs,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<DmThemeBloc>.value(value: themeBloc),
                BlocProvider<VncHostBloc>.value(value: vncHostBloc),
                BlocProvider<SshHostBloc>.value(value: sshHostBloc),
              ],
              child: MaterialApp.router(
                localizationsDelegates: AppLocale.localizationsDelegates,
                supportedLocales: AppLocale.supportedLocales,
                routerConfig: router,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Dangling Tunnel Box'));
        await tester.pumpAndSettle();

        expect(sessionRouteOpened, isFalse);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.textContaining('Configured SSH tunnel host was not found'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'VncHostFormDialog rejects malformed host:port and bracket inputs',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        VncHostFormResult? result;
        await tester.pumpWidget(
          wrapWithApp(
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () async {
                      result = await VncHostFormDialog.show(
                        context,
                        mode: VncHostFormMode.quickConnect,
                      );
                    },
                    child: const Text('Open Form'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Form'));
        await tester.pumpAndSettle();

        final hostField = find.widgetWithText(TextFormField, 'Host');
        final connectButton = find.widgetWithText(FilledButton, 'Connect');

        for (final malformed in const [
          '192.168.1.10:99999',
          'host:abc',
          ':5900',
          '[]',
          '[::1]:99999',
          '[::1]:abc',
          'host:0',
          'host:',
          '[::1',
        ]) {
          await tester.enterText(hostField, malformed);
          await tester.tap(connectButton);
          await tester.pumpAndSettle();

          expect(
            find.byType(VncHostFormDialog),
            findsOneWidget,
            reason: 'Expected "$malformed" to be rejected',
          );
          expect(
            result,
            isNull,
            reason: 'Expected no result for malformed input "$malformed"',
          );
        }

        // Valid [ipv6]:port syntax is accepted and parsed cleanly.
        await tester.enterText(hostField, '[::1]:5901');
        await tester.tap(connectButton);
        await tester.pumpAndSettle();

        expect(find.byType(VncHostFormDialog), findsNothing);
        expect(result, isNotNull);
        expect(result!.host, '::1');
        expect(result!.port, 5901);
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

    testWidgets(
      'Display Switcher lists ExtendedDesktopSize screens and calls setActiveRegion',
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
          title: 'Dual Monitor Mac',
          config: VncConnectionConfig(host: '192.168.1.70', port: 5900),
        );

        await tester.pumpWidget(
          wrapWithApp(
            VncSessionScreen(launchConfig: launch, blocOverride: sessionBloc),
          ),
        );
        await tester.pump();
        await tester.pump();

        const display1 = VncScreenInfo(
          id: 1,
          x: 0,
          y: 0,
          width: 2560,
          height: 1440,
        );
        const display2 = VncScreenInfo(
          id: 2,
          x: 2560,
          y: 0,
          width: 1920,
          height: 1440,
        );

        fakeClient.emitEvent(
          const VncConnectedEvent(
            VncDesktopInfo(
              name: 'Dual Monitor Mac',
              width: 4480,
              height: 1440,
              protocolVersion: 'RFB 003.008',
              securityType: 2,
            ),
          ),
        );
        fakeClient.emitEvent(
          const VncResizedEvent(
            width: 4480,
            height: 1440,
            screens: [display1, display2],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('4480×1440'), findsOneWidget);
        final switcher = find.byTooltip('Select Display');
        expect(switcher, findsOneWidget);

        await tester.tap(switcher);
        await tester.pumpAndSettle();

        expect(find.text('All Displays'), findsOneWidget);
        expect(find.text('Display 1 (2560×1440)'), findsOneWidget);
        expect(find.text('Display 2 (1920×1440)'), findsOneWidget);

        await tester.tap(find.text('Display 2 (1920×1440)'));
        await tester.pumpAndSettle();

        expect(fakeClient.activeRegionCalls, contains(display2));
        expect(fakeClient.activeRegionCalls.last, display2);
        expect(find.text('1920×1440'), findsOneWidget);
      },
    );

    testWidgets(
      'Display Switcher offers Left Half / Right Half fallback for ultrawide framebuffers without screen metadata',
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
          title: 'macOS Dual Screen',
          config: VncConnectionConfig(host: '192.168.1.71', port: 5900),
        );

        await tester.pumpWidget(
          wrapWithApp(
            VncSessionScreen(launchConfig: launch, blocOverride: sessionBloc),
          ),
        );
        await tester.pump();
        await tester.pump();

        fakeClient.emitEvent(
          const VncConnectedEvent(
            VncDesktopInfo(
              name: 'macOS Dual Screen',
              width: 3840,
              height: 1080,
              protocolVersion: 'RFB 003.008',
              securityType: 30,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('3840×1080'), findsOneWidget);
        final switcher = find.byTooltip('Select Display');
        expect(switcher, findsOneWidget);

        await tester.tap(switcher);
        await tester.pumpAndSettle();

        expect(find.text('All Displays'), findsOneWidget);
        expect(find.text('Left Half (1920×1080)'), findsOneWidget);
        expect(find.text('Right Half (1920×1080)'), findsOneWidget);

        await tester.tap(find.text('Right Half (1920×1080)'));
        await tester.pumpAndSettle();

        const expectedRightHalf = VncScreenInfo(
          id: -2,
          x: 1920,
          y: 0,
          width: 1920,
          height: 1080,
        );
        expect(fakeClient.activeRegionCalls.last, expectedRightHalf);
        expect(find.text('1920×1080'), findsOneWidget);
      },
    );

    testWidgets(
      'Apple 003.889 mode lists 3 displays, calls selectDisplay instead of setActiveRegion, and keeps VncViewerCanvas.activeRegion null',
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
          title: 'Mac Studio Triple Display',
          config: VncConnectionConfig(host: '192.168.1.72', port: 5900),
        );

        await tester.pumpWidget(
          wrapWithApp(
            VncSessionScreen(launchConfig: launch, blocOverride: sessionBloc),
          ),
        );
        await tester.pump();
        await tester.pump();

        const builtIn = VncScreenInfo(
          id: 1,
          x: 0,
          y: 0,
          width: 1728,
          height: 1117,
          flags: 1,
        );
        const landscape4k = VncScreenInfo(
          id: 2,
          x: 1728,
          y: 0,
          width: 3840,
          height: 2160,
        );
        const portrait4k = VncScreenInfo(
          id: 3,
          x: 5568,
          y: 0,
          width: 2160,
          height: 3840,
        );

        fakeClient.emitEvent(
          const VncConnectedEvent(
            VncDesktopInfo(
              name: 'Mac Studio Triple Display',
              width: 7728,
              height: 3840,
              protocolVersion: 'RFB 003.889',
              securityType: 30,
              isApple889: true,
            ),
          ),
        );
        fakeClient.emitEvent(
          const VncResizedEvent(
            width: 7728,
            height: 3840,
            screens: [builtIn, landscape4k, portrait4k],
            hasCurrentDisplayId: true,
            currentDisplayId: null,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('7728×3840'), findsOneWidget);
        final switcher = find.byTooltip('Select Display');
        expect(switcher, findsOneWidget);

        await tester.tap(switcher);
        await tester.pumpAndSettle();

        expect(find.text('All Displays'), findsOneWidget);
        expect(find.text('Display 1 (1728×1117)'), findsOneWidget);
        expect(find.text('Display 2 (3840×2160)'), findsOneWidget);
        expect(find.text('Display 3 (2160×3840)'), findsOneWidget);

        await tester.tap(find.text('Display 3 (2160×3840)'));
        await tester.pumpAndSettle();

        expect(fakeClient.selectDisplayCalls, equals([3]));
        expect(fakeClient.activeRegionCalls, isEmpty);

        var canvas = tester.widget<VncViewerCanvas>(
          find.byType(VncViewerCanvas),
        );
        expect(canvas.activeRegion, isNull);

        // Confirming AppleDisplayLayout arrives for Display 3.
        fakeClient.emitEvent(
          const VncResizedEvent(
            width: 2160,
            height: 3840,
            screens: [builtIn, landscape4k, portrait4k],
            hasCurrentDisplayId: true,
            currentDisplayId: 3,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('2160×3840'), findsOneWidget);
        canvas = tester.widget<VncViewerCanvas>(find.byType(VncViewerCanvas));
        expect(canvas.activeRegion, isNull);
      },
    );

    testWidgets(
      'narrow iPhone viewport renders VncScreen and VncSessionScreen with zero overflow and working Display Switcher & Overflow menu',
      (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // 1. VncScreen with saved + discovered hosts on 375x812 iPhone.
        final vncHostBloc = MockVncHostBloc();
        final sshHostBloc = MockSshHostBloc();
        addTearDown(() async {
          await vncHostBloc.close();
          await sshHostBloc.close();
        });

        final now = DateTime(2026, 11, 24);
        whenListen(
          vncHostBloc,
          const Stream<VncHostState>.empty(),
          initialState: VncHostState(
            hosts: [
              VncHost(
                id: 1,
                name: 'Engineering Mac Studio Ultra Workstation',
                host: '192.168.100.200',
                port: 5900,
                authType: VncHostAuthType.appleArd.value,
                username: 'alice',
                passwordRef: null,
                sshHostId: null,
                viewOnly: false,
                createdAt: now,
                lastConnectedAt: now,
              ),
            ],
            discoveredHosts: const [
              VncDiscoveredHost(
                name: 'Conference Room MacBook Pro 16-inch',
                host: 'conference-room-macbook-pro.local',
                port: 5900,
                addresses: ['fe80::1c2b:3c4d:5e6f:7a8b'],
              ),
            ],
          ),
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

        expect(tester.takeException(), isNull);
        // Narrow AppBar uses compact IconButton with Icons.bolt for Quick Connect.
        expect(find.byIcon(Icons.bolt), findsOneWidget);
        expect(find.text('Quick Connect'), findsNothing);
        expect(
          find.text('Conference Room MacBook Pro 16-inch'),
          findsOneWidget,
        );
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Connect'), findsOneWidget);

        // 2. VncSessionScreen connected with 3 displays on 375x812 iPhone.
        final fakeClient = FakeVncSessionClient();
        final sessionBloc = VncSessionBloc(clientFactory: () => fakeClient);
        addTearDown(() async {
          await sessionBloc.close();
          await fakeClient.dispose();
        });

        const launch = VncLaunchConfig(
          title: 'Engineering Mac Studio Ultra Workstation',
          config: VncConnectionConfig(host: '192.168.100.200', port: 5900),
        );

        await tester.pumpWidget(
          wrapWithApp(
            VncSessionScreen(launchConfig: launch, blocOverride: sessionBloc),
          ),
        );
        await tester.pump();
        await tester.pump();

        const d1 = VncScreenInfo(id: 1, x: 0, y: 0, width: 1728, height: 1117);
        const d2 = VncScreenInfo(
          id: 2,
          x: 1728,
          y: 0,
          width: 3840,
          height: 2160,
        );
        const d3 = VncScreenInfo(
          id: 3,
          x: 5568,
          y: 0,
          width: 2160,
          height: 3840,
        );

        fakeClient.emitEvent(
          const VncConnectedEvent(
            VncDesktopInfo(
              name: 'Engineering Mac Studio Ultra Workstation',
              width: 7728,
              height: 3840,
              protocolVersion: 'RFB 003.889',
              securityType: 30,
              isApple889: true,
            ),
          ),
        );
        fakeClient.emitEvent(
          const VncResizedEvent(
            width: 7728,
            height: 3840,
            screens: [d1, d2, d3],
            hasCurrentDisplayId: true,
            currentDisplayId: null,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Display Switcher is directly tappable on narrow viewport.
        final switcher = find.byTooltip('Select Display');
        expect(switcher, findsOneWidget);
        await tester.tap(switcher);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Display 2 (3840×2160)'), findsOneWidget);
        await tester.tap(find.text('Display 2 (3840×2160)'));
        await tester.pumpAndSettle();
        expect(fakeClient.selectDisplayCalls, equals([2]));

        // Overflow menu (Icons.more_vert) opens and executes actions cleanly.
        final overflow = find.byIcon(Icons.more_vert);
        expect(overflow, findsOneWidget);
        await tester.tap(overflow);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('View Only'), findsOneWidget);
        expect(find.text('Hide toolbar'), findsOneWidget);

        await tester.tap(find.text('View Only'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(sessionBloc.state.viewOnly, isTrue);

        // Open overflow menu again and hide toolbar, then restore via SafeArea button.
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hide toolbar'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      },
    );

    testWidgets(
      'notched iPhone 11 portrait & landscape SafeArea, Display badge, Fullscreen, ShortcutBar, and Dialogs render with zero overflow',
      (tester) async {
        // Simulate iPhone 11 portrait (414x896 pt, top notch 48, home bar 34).
        tester.view.physicalSize = const Size(414, 896);
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = const FakeViewPadding(top: 48, bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(top: 48, bottom: 34);
        addTearDown(tester.view.reset);

        final fakeClient = FakeVncSessionClient();
        final sessionBloc = VncSessionBloc(clientFactory: () => fakeClient);
        addTearDown(() async {
          await sessionBloc.close();
          await fakeClient.dispose();
        });

        const launch = VncLaunchConfig(
          title: 'MacBook Pro M3',
          config: VncConnectionConfig(host: '10.100.10.44', port: 5900),
        );

        await tester.pumpWidget(
          wrapWithApp(
            VncSessionScreen(launchConfig: launch, blocOverride: sessionBloc),
          ),
        );
        await tester.pump();
        await tester.pump();

        const d1 = VncScreenInfo(id: 1, x: 0, y: 0, width: 3024, height: 1964);
        const d2 = VncScreenInfo(
          id: 2,
          x: 3024,
          y: 0,
          width: 3840,
          height: 2160,
        );
        const d3 = VncScreenInfo(
          id: 3,
          x: 6864,
          y: 0,
          width: 2160,
          height: 3840,
        );

        fakeClient.emitEvent(
          const VncConnectedEvent(
            VncDesktopInfo(
              name: 'MacBook Pro M3',
              width: 9024,
              height: 3840,
              protocolVersion: 'RFB 003.889',
              securityType: 30,
              isApple889: true,
            ),
          ),
        );
        fakeClient.emitEvent(
          const VncResizedEvent(
            width: 9024,
            height: 3840,
            screens: [d1, d2, d3],
            hasCurrentDisplayId: true,
            currentDisplayId: null,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        // Back button must sit cleanly below the 48pt iPhone notch.
        expect(
          tester.getTopLeft(find.byIcon(Icons.arrow_back)).dy,
          greaterThanOrEqualTo(48.0),
        );
        // Display switcher badge shows "All" initially.
        expect(find.text('All'), findsOneWidget);

        // Select Display 2 and verify badge updates to "2" after layout confirms.
        await tester.tap(find.byTooltip('Select Display'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Display 2 (3840×2160)'));
        await tester.pumpAndSettle();
        expect(fakeClient.selectDisplayCalls, equals([2]));

        fakeClient.emitEvent(
          const VncResizedEvent(
            width: 3840,
            height: 2160,
            screens: [d1, d2, d3],
            hasCurrentDisplayId: true,
            currentDisplayId: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3840×2160'), findsOneWidget);

        // Open shortcut bar and verify it clears the 34pt iPhone home indicator.
        await tester.tap(find.byIcon(Icons.keyboard_outlined));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getBottomLeft(find.text('Esc')).dy,
          lessThanOrEqualTo(896.0 - 34.0),
        );

        // Toggle fullscreen via overflow menu -> auto-hides toolbar cleanly.
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Fullscreen'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
        expect(
          tester.getTopLeft(find.byIcon(Icons.keyboard_arrow_down)).dy,
          greaterThanOrEqualTo(48.0),
        );

        // Restore toolbar while still fullscreen -> toolbar still clears notch!
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getTopLeft(find.byIcon(Icons.arrow_back)).dy,
          greaterThanOrEqualTo(48.0),
        );

        // Rotate to iPhone 11 landscape (896x414) with left/right notch insets
        // and simulate soft keyboard open (viewInsets.bottom = 180) with AuthDialog.
        tester.view.physicalSize = const Size(896, 414);
        tester.view.padding = const FakeViewPadding(
          left: 48,
          right: 48,
          bottom: 21,
        );
        tester.view.viewPadding = const FakeViewPadding(
          left: 48,
          right: 48,
          bottom: 21,
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 180);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Trigger VncAuthDialog in landscape with keyboard open: must scroll, no overflow.
        fakeClient.emitEvent(
          const VncAuthRequiredEvent(securityType: 30, requiresUsername: true),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(find.byType(VncAuthDialog), findsOneWidget);
      },
    );
  });
}
