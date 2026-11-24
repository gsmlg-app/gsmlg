import 'dart:async';
import 'dart:typed_data';

import 'package:app_vnc/app_vnc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vnc_session_bloc/vnc_session_bloc.dart';

class FakeVncSessionClient implements VncSessionClient {
  FakeVncSessionClient({
    this.connectError,
    this.emitConnectingOnConnect = true,
  });

  final Object? connectError;
  final bool emitConnectingOnConnect;

  final StreamController<VncClientEvent> _eventsController =
      StreamController<VncClientEvent>.broadcast();

  final List<VncConnectionConfig> connectCalls = [];
  final List<VncCredentials> submittedCredentials = [];
  int cancelCredentialsCount = 0;
  final List<({int x, int y, int buttonMask})> pointerEvents = [];
  final List<({int keysym, bool down})> keyEvents = [];
  final List<String> clipboardTexts = [];
  int fullRefreshCount = 0;
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
    if (emitConnectingOnConnect) {
      emitEvent(const VncConnectingEvent());
    }
    if (connectError != null) {
      throw connectError!;
    }
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
  void sendPointerEvent(int x, int y, int buttonMask) {
    pointerEvents.add((x: x, y: y, buttonMask: buttonMask));
  }

  @override
  void sendKeyEvent(int keysym, {required bool down}) {
    keyEvents.add((keysym: keysym, down: down));
  }

  @override
  void sendClipboardText(String text) {
    clipboardTexts.add(text);
  }

  @override
  void requestFullRefresh() {
    fullRefreshCount++;
  }

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
  const testConfig = VncConnectionConfig(host: '192.168.1.50', port: 5900);
  const testDesktop = VncDesktopInfo(
    name: 'MacBook Pro',
    width: 1920,
    height: 1080,
    protocolVersion: 'RFB 003.008',
    securityType: 30,
  );

  group('VncSessionBloc', () {
    late List<FakeVncSessionClient> createdClients;

    VncSessionBloc buildBloc({Object? nextConnectError}) {
      createdClients = [];
      return VncSessionBloc(
        clientFactory: () {
          final client = FakeVncSessionClient(connectError: nextConnectError);
          createdClients.add(client);
          return client;
        },
      );
    }

    tearDown(() async {
      for (final client in createdClients) {
        await client.dispose();
      }
    });

    test('initial state is idle with no latest frame', () async {
      final bloc = buildBloc();
      expect(bloc.state, const VncSessionState());
      expect(bloc.state.status, VncSessionStatus.idle);
      expect(bloc.latestFrame, isNull);
      await bloc.close();
    });

    test(
      'full flow: connecting -> authRequired -> submitCredentials -> connected',
      () async {
        final bloc = buildBloc();
        final emitted = <VncSessionState>[];
        final sub = bloc.stream.listen(emitted.add);

        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);

        expect(createdClients, hasLength(1));
        final client = createdClients.single;
        expect(client.connectCalls, [testConfig]);
        expect(bloc.state.status, VncSessionStatus.connecting);
        expect(bloc.state.config, testConfig);

        client.emitEvent(
          const VncAuthRequiredEvent(securityType: 30, requiresUsername: true),
        );
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, VncSessionStatus.authRequired);
        expect(bloc.state.authSecurityType, 30);
        expect(bloc.state.authRequiresUsername, isTrue);

        const creds = VncCredentials(username: 'alice', password: 'secret');
        bloc.add(const VncSessionSubmitCredentials(creds));
        await Future<void>.delayed(Duration.zero);

        expect(client.submittedCredentials, [creds]);
        expect(bloc.state.status, VncSessionStatus.connecting);
        expect(bloc.state.authSecurityType, isNull);
        expect(bloc.state.authRequiresUsername, isFalse);
        expect(bloc.state.config?.credentials, creds);

        client.emitEvent(const VncConnectedEvent(testDesktop));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, VncSessionStatus.connected);
        expect(bloc.state.desktopInfo, testDesktop);
        expect(bloc.state.width, 1920);
        expect(bloc.state.height, 1080);

        expect(emitted.map((s) => s.status).toList(), [
          VncSessionStatus.connecting,
          VncSessionStatus.authRequired,
          VncSessionStatus.connecting,
          VncSessionStatus.connected,
        ]);

        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'VncSessionCancelAuth forwards cancelCredentials during auth',
      () async {
        final bloc = buildBloc();
        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);

        final client = createdClients.single;
        // Calling cancelAuth before authRequired should be ignored.
        bloc.add(const VncSessionCancelAuth());
        await Future<void>.delayed(Duration.zero);
        expect(client.cancelCredentialsCount, 0);

        client.emitEvent(
          const VncAuthRequiredEvent(securityType: 2, requiresUsername: false),
        );
        await Future<void>.delayed(Duration.zero);

        bloc.add(const VncSessionCancelAuth());
        await Future<void>.delayed(Duration.zero);
        expect(client.cancelCredentialsCount, 1);

        await bloc.close();
      },
    );

    test(
      'VncFrameEvent pushes to bloc.frames and updates latestFrame without emitting state',
      () async {
        final bloc = buildBloc();
        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);

        final client = createdClients.single;
        client.emitEvent(const VncConnectedEvent(testDesktop));
        await Future<void>.delayed(Duration.zero);

        final statesAfterConnected = <VncSessionState>[];
        final stateSub = bloc.stream.listen(statesAfterConnected.add);
        final receivedFrames = <VncFrameData>[];
        final frameSub = bloc.frames.listen(receivedFrames.add);

        final frame1 = VncFrameData(
          frameId: 1,
          width: 2,
          height: 2,
          rgbaPixels: Uint8List(16),
        );
        final frame2 = VncFrameData(
          frameId: 2,
          width: 2,
          height: 2,
          rgbaPixels: Uint8List(16)..fillRange(0, 16, 255),
        );

        client.emitEvent(VncFrameEvent(frame1));
        client.emitEvent(VncFrameEvent(frame2));
        await Future<void>.delayed(Duration.zero);

        expect(receivedFrames, [frame1, frame2]);
        expect(bloc.latestFrame, frame2);
        expect(statesAfterConnected, isEmpty);

        await frameSub.cancel();
        await stateSub.cancel();
        await bloc.close();
      },
    );

    test(
      'handles VncResizedEvent, VncCursorEvent, and repeated VncClipboardEvent',
      () async {
        final bloc = buildBloc();
        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);

        final client = createdClients.single;
        client.emitEvent(const VncConnectedEvent(testDesktop));
        await Future<void>.delayed(Duration.zero);

        final emitted = <VncSessionState>[];
        final sub = bloc.stream.listen(emitted.add);

        client.emitEvent(const VncResizedEvent(width: 2560, height: 1440));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.width, 2560);
        expect(bloc.state.height, 1440);

        final cursor = VncCursorData(
          width: 16,
          height: 16,
          hotspotX: 1,
          hotspotY: 2,
          rgbaPixels: Uint8List(16 * 16 * 4),
        );
        client.emitEvent(VncCursorEvent(cursor));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.cursor, cursor);

        client.emitEvent(const VncClipboardEvent('hello world'));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.lastRemoteClipboard, 'hello world');
        expect(bloc.state.clipboardSeq, 1);

        // Identical text again must still emit with incremented clipboardSeq.
        client.emitEvent(const VncClipboardEvent('hello world'));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.lastRemoteClipboard, 'hello world');
        expect(bloc.state.clipboardSeq, 2);

        expect(emitted, hasLength(4));

        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'VncSessionToggleViewOnly blocks pointer and key events while allowing clipboard and refresh',
      () async {
        final bloc = buildBloc();
        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);

        final client = createdClients.single;
        // Not connected yet: pointer/key/clipboard/refresh are ignored.
        bloc.add(const VncSessionSendPointer(x: 1, y: 2, buttonMask: 1));
        bloc.add(const VncSessionSendKey(keysym: 0x0061, down: true));
        bloc.add(const VncSessionSendClipboard('early'));
        bloc.add(const VncSessionRequestRefresh());
        await Future<void>.delayed(Duration.zero);

        expect(client.pointerEvents, isEmpty);
        expect(client.keyEvents, isEmpty);
        expect(client.clipboardTexts, isEmpty);
        expect(client.fullRefreshCount, 0);

        // Connect session.
        client.emitEvent(const VncConnectedEvent(testDesktop));
        await Future<void>.delayed(Duration.zero);

        // Interactive mode: event-based inputs forwarded in order.
        bloc.add(const VncSessionSendPointer(x: 10, y: 20, buttonMask: 1));
        bloc.add(const VncSessionSendKey(keysym: 0x0061, down: true));
        bloc.add(const VncSessionSendClipboard('copied-1'));
        bloc.add(const VncSessionRequestRefresh());
        await Future<void>.delayed(Duration.zero);

        // Low-latency direct helpers forward synchronously in order.
        bloc.sendPointer(15, 25, 0);
        bloc.sendKey(0x0061, down: false);

        expect(client.pointerEvents, [
          (x: 10, y: 20, buttonMask: 1),
          (x: 15, y: 25, buttonMask: 0),
        ]);
        expect(client.keyEvents, [
          (keysym: 0x0061, down: true),
          (keysym: 0x0061, down: false),
        ]);
        expect(client.clipboardTexts, ['copied-1']);
        expect(client.fullRefreshCount, 1);

        // Toggle view-only on.
        bloc.add(const VncSessionToggleViewOnly());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.viewOnly, isTrue);

        // Pointer and key blocked; clipboard and refresh still allowed.
        bloc.add(const VncSessionSendPointer(x: 30, y: 40, buttonMask: 1));
        bloc.sendPointer(35, 45, 1);
        bloc.add(const VncSessionSendKey(keysym: 0x0062, down: true));
        bloc.sendKey(0x0062, down: false);
        bloc.add(const VncSessionSendClipboard('copied-2'));
        bloc.add(const VncSessionRequestRefresh());
        await Future<void>.delayed(Duration.zero);

        expect(client.pointerEvents, hasLength(2));
        expect(client.keyEvents, hasLength(2));
        expect(client.clipboardTexts, ['copied-1', 'copied-2']);
        expect(client.fullRefreshCount, 2);

        // Toggle view-only back off.
        bloc.add(const VncSessionToggleViewOnly());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.viewOnly, isFalse);

        bloc.add(const VncSessionSendPointer(x: 50, y: 60, buttonMask: 1));
        await Future<void>.delayed(Duration.zero);
        expect(client.pointerEvents, hasLength(3));

        await bloc.close();
      },
    );

    test(
      'VncErrorEvent(VncAuthenticationException) preserves config and VncSessionReconnect replaces credentials',
      () async {
        final bloc = buildBloc();
        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);

        final firstClient = createdClients.single;
        const authError = VncAuthenticationException('Invalid password');
        firstClient.emitEvent(const VncErrorEvent(authError));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, VncSessionStatus.error);
        expect(bloc.state.error, authError);
        expect(bloc.state.config, testConfig);

        const retryCreds = VncCredentials(
          username: 'admin',
          password: 'new-password',
        );
        bloc.add(const VncSessionReconnect(overrideCredentials: retryCreds));
        await Future<void>.delayed(Duration.zero);

        expect(firstClient.disconnectCount, 1);
        expect(createdClients, hasLength(2));
        final secondClient = createdClients.last;
        expect(secondClient.connectCalls, hasLength(1));
        expect(secondClient.connectCalls.single.host, testConfig.host);
        expect(secondClient.connectCalls.single.port, testConfig.port);
        expect(secondClient.connectCalls.single.credentials, retryCreds);
        expect(bloc.state.status, VncSessionStatus.connecting);
        expect(bloc.state.error, isNull);
        expect(bloc.state.config?.credentials, retryCreds);

        await bloc.close();
      },
    );

    test(
      'VncErrorEvent(VncUnsupportedSecurityTypeException) preserves typed error',
      () async {
        final bloc = buildBloc();
        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);

        final client = createdClients.single;
        final unsupported = VncUnsupportedSecurityTypeException([35, 36]);
        client.emitEvent(VncErrorEvent(unsupported));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, VncSessionStatus.error);
        expect(bloc.state.error, isA<VncUnsupportedSecurityTypeException>());
        final typedError =
            bloc.state.error! as VncUnsupportedSecurityTypeException;
        expect(typedError.offeredTypes, [35, 36]);

        await bloc.close();
      },
    );

    test(
      'connect failure transitions to error and disconnects client',
      () async {
        final bloc = buildBloc(
          nextConnectError: const VncConnectionException('Connection refused'),
        );
        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);

        expect(createdClients, hasLength(1));
        expect(createdClients.single.disconnectCount, 1);
        expect(bloc.state.status, VncSessionStatus.error);
        expect(bloc.state.error, isA<VncConnectionException>());
        expect(bloc.state.config, testConfig);

        await bloc.close();
      },
    );

    test(
      'stale generation events after reconnect or disconnect are ignored',
      () async {
        final bloc = buildBloc();
        final receivedFrames = <VncFrameData>[];
        final frameSub = bloc.frames.listen(receivedFrames.add);

        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);
        final firstClient = createdClients[0];

        // Reconnect creates second client and advances generation.
        bloc.add(const VncSessionReconnect());
        await Future<void>.delayed(Duration.zero);
        expect(createdClients, hasLength(2));
        final secondClient = createdClients[1];

        // Events & frames from firstClient must be completely ignored.
        firstClient.emitEvent(const VncConnectedEvent(testDesktop));
        firstClient.emitEvent(
          VncFrameEvent(
            VncFrameData(
              frameId: 99,
              width: 1,
              height: 1,
              rgbaPixels: Uint8List(4),
            ),
          ),
        );
        firstClient.emitEvent(
          const VncErrorEvent(VncConnectionException('Stale error')),
        );
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, VncSessionStatus.connecting);
        expect(bloc.state.error, isNull);
        expect(bloc.latestFrame, isNull);
        expect(receivedFrames, isEmpty);

        // Events from secondClient work normally.
        secondClient.emitEvent(const VncConnectedEvent(testDesktop));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.status, VncSessionStatus.connected);

        // Disconnect advances generation and tears down secondClient.
        bloc.add(const VncSessionDisconnect());
        await Future<void>.delayed(Duration.zero);
        expect(secondClient.disconnectCount, 1);
        expect(bloc.state.status, VncSessionStatus.disconnected);

        // Late events from secondClient after disconnect are ignored.
        secondClient.emitEvent(const VncResizedEvent(width: 800, height: 600));
        secondClient.emitEvent(
          const VncErrorEvent(VncProtocolException('Late error')),
        );
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, VncSessionStatus.disconnected);
        expect(bloc.state.error, isNull);

        await frameSub.cancel();
        await bloc.close();
      },
    );

    test(
      'bloc.close() disconnects active client and closes frames stream cleanly',
      () async {
        final bloc = buildBloc();
        var framesDone = false;
        final frameSub = bloc.frames.listen(
          (_) {},
          onDone: () {
            framesDone = true;
          },
        );

        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);
        final client = createdClients.single;

        await bloc.close();

        expect(client.disconnectCount, 1);
        expect(framesDone, isTrue);

        await frameSub.cancel();
      },
    );

    blocTest<VncSessionBloc, VncSessionState>(
      'emits disconnected with reason on VncDisconnectedEvent',
      build: () => buildBloc(),
      act: (bloc) async {
        bloc.add(const VncSessionConnect(testConfig));
        await Future<void>.delayed(Duration.zero);
        createdClients.single.emitEvent(const VncConnectedEvent(testDesktop));
        await Future<void>.delayed(Duration.zero);
        createdClients.single.emitEvent(
          const VncDisconnectedEvent(reason: 'Server closed connection'),
        );
      },
      expect: () => [
        const VncSessionState(
          status: VncSessionStatus.connecting,
          config: testConfig,
        ),
        const VncSessionState(
          status: VncSessionStatus.connected,
          config: testConfig,
          desktopInfo: testDesktop,
          width: 1920,
          height: 1080,
        ),
        const VncSessionState(
          status: VncSessionStatus.disconnected,
          config: testConfig,
          desktopInfo: testDesktop,
          width: 1920,
          height: 1080,
          disconnectReason: 'Server closed connection',
        ),
      ],
    );

    test('VncSessionState.copyWith clear flags reset nullable fields', () {
      final cursor = VncCursorData(
        width: 4,
        height: 4,
        hotspotX: 0,
        hotspotY: 0,
        rgbaPixels: Uint8List(64),
      );
      final populated = VncSessionState(
        status: VncSessionStatus.error,
        config: testConfig,
        desktopInfo: testDesktop,
        width: 1920,
        height: 1080,
        authSecurityType: 30,
        authRequiresUsername: true,
        cursor: cursor,
        error: const VncConnectionException('boom'),
        disconnectReason: 'bye',
      );

      final cleared = populated.copyWith(
        clearError: true,
        clearAuth: true,
        clearDisconnectReason: true,
        clearCursor: true,
      );

      expect(cleared.error, isNull);
      expect(cleared.authSecurityType, isNull);
      expect(cleared.authRequiresUsername, isFalse);
      expect(cleared.disconnectReason, isNull);
      expect(cleared.cursor, isNull);
      expect(cleared.config, testConfig);
      expect(cleared.desktopInfo, testDesktop);
    });
  });
}
