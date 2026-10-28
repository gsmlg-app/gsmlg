import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/duo/duo_controller.dart';
import 'package:gsmlg/duo/secondary_app.dart';

class _FakeDuoBridge implements DuoBridge {
  final _controller = StreamController<Object?>.broadcast();
  _FakeDuoBridge? peer;

  @override
  Stream<Object?> get messages => _controller.stream;

  @override
  void start() {}

  @override
  void send(String message) {
    peer?._controller.add(message);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class _FakeDuoPlatform implements DuoDisplayPlatform {
  @override
  Stream<void> get changes => const Stream.empty();

  @override
  Future<List<int>> presentationDisplays() async => [6];

  @override
  Future<bool> show(int displayId) async => true;

  @override
  Future<bool> hide(int displayId) async => true;
}

void main() {
  group('DuoChatState serialization', () {
    test('serializes and deserializes chat state accurately', () {
      const state = DuoChatState(
        isStreaming: true,
        canSend: false,
        modelName: 'Gemma 2B',
        activeAgentName: 'Code Assistant',
        activeAgentId: 'agent-42',
        agents: [
          DuoChatAgent(id: 'agent-42', name: 'Code Assistant'),
          DuoChatAgent(id: 'agent-1', name: 'General'),
        ],
        supportsImage: true,
        supportsAudio: false,
        historyTokens: 256,
      );

      final json = state.toJson();
      final restored = DuoChatState.fromJson(json);

      expect(restored.isStreaming, isTrue);
      expect(restored.canSend, isFalse);
      expect(restored.modelName, 'Gemma 2B');
      expect(restored.activeAgentName, 'Code Assistant');
      expect(restored.activeAgentId, 'agent-42');
      expect(restored.agents.length, 2);
      expect(restored.agents.first.id, 'agent-42');
      expect(restored.agents.first.name, 'Code Assistant');
      expect(restored.supportsImage, isTrue);
      expect(restored.supportsAudio, isFalse);
      expect(restored.historyTokens, 256);
    });

    test('serializes and deserializes attachment data with bytes', () {
      final attachment = ChatAttachment(
        id: 'att-1',
        name: 'test.png',
        sizeBytes: 4,
        mimeType: 'image/png',
        bytes: Uint8List.fromList([1, 2, 3, 4]),
      );

      final data = DuoChatAttachmentData.fromChatAttachment(attachment);
      final json = data.toJson();
      final restoredData = DuoChatAttachmentData.fromJson(json);
      final restoredAttachment = restoredData.toChatAttachment();

      expect(restoredAttachment.id, 'att-1');
      expect(restoredAttachment.name, 'test.png');
      expect(restoredAttachment.sizeBytes, 4);
      expect(restoredAttachment.mimeType, 'image/png');
      expect(restoredAttachment.bytes, Uint8List.fromList([1, 2, 3, 4]));
    });
  });

  group('DuoDisplayManager chat relay', () {
    late _FakeDuoBridge primaryBridge;
    late _FakeDuoBridge secondaryBridge;
    late DuoDisplayManager primary;
    late DuoDisplayManager secondary;

    setUp(() {
      primaryBridge = _FakeDuoBridge();
      secondaryBridge = _FakeDuoBridge();
      primaryBridge.peer = secondaryBridge;
      secondaryBridge.peer = primaryBridge;

      primary = DuoDisplayManager(
        secondary: false,
        platform: _FakeDuoPlatform(),
        bridge: primaryBridge,
      );
      secondary = DuoDisplayManager(
        secondary: true,
        platform: _FakeDuoPlatform(),
        bridge: secondaryBridge,
      );

      primary.start();
      secondary.start();

      // Handshake to establish connection
      secondary.bridge.send(jsonEncode({'type': 'hello'}));
    });

    tearDown(() {
      primary.dispose();
      secondary.dispose();
    });

    testWidgets(
      'publishes chat snapshots during build without rebuilding the sender',
      (tester) async {
        await tester.pump();
        expect(primary.connected, isTrue);
        expect(secondary.connected, isTrue);

        const chatState = DuoChatState(
          isStreaming: false,
          canSend: true,
          modelName: 'Gemma 2B',
          activeAgentName: 'Helper',
        );
        late StateSetter rebuild;
        var primaryNotifications = 0;
        var secondaryNotifications = 0;
        void onPrimaryChanged() {
          primaryNotifications++;
          rebuild(() {});
        }

        void onSecondaryChanged() {
          secondaryNotifications++;
        }

        primary.addListener(onPrimaryChanged);
        secondary.addListener(onSecondaryChanged);
        addTearDown(() {
          primary.removeListener(onPrimaryChanged);
          secondary.removeListener(onSecondaryChanged);
        });

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return Builder(
                builder: (context) {
                  primary.updateChatState(chatState);
                  return const SizedBox();
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(primaryNotifications, 0);
        expect(primary.chatState, same(chatState));
        expect(secondaryNotifications, 1);
        expect(secondary.chatState?.modelName, 'Gemma 2B');
        expect(secondary.chatState?.canSend, isTrue);

        primary.updateChatState(null);
        await tester.pump();

        expect(primaryNotifications, 0);
        expect(primary.chatState, isNull);
        expect(secondaryNotifications, 2);
        expect(secondary.chatState, isNull);
      },
    );

    test(
      'rejects delayed chat commands for a previously selected session',
      () async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        primary.updateChatState(const DuoChatState(conversationId: 'b'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        var stopped = false;
        String? sent;
        primary.onChatStop = () => stopped = true;
        primary.onChatSend = (text, {attachments}) => sent = text;
        secondaryBridge.send(
          jsonEncode({'type': 'chat_stop', 'conversationId': 'a'}),
        );
        secondaryBridge.send(
          jsonEncode({
            'type': 'chat_send',
            'conversationId': 'a',
            'text': 'stale',
          }),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(stopped, isFalse);
        expect(sent, isNull);
        secondary.sendChatSend('current');
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(sent, 'current');
      },
    );

    test('relays chat state from primary to secondary', () async {
      await Future<void>.delayed(const Duration(milliseconds: 20));

      const chatState = DuoChatState(
        isStreaming: false,
        canSend: true,
        modelName: 'Gemma 2B',
        activeAgentName: 'Helper',
        activeAgentId: 'agent-1',
        agents: [DuoChatAgent(id: 'agent-1', name: 'Helper')],
        historyTokens: 100,
      );

      primary.updateChatState(chatState);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(secondary.chatState, isNotNull);
      expect(secondary.chatState?.modelName, 'Gemma 2B');
      expect(secondary.chatState?.activeAgentName, 'Helper');
      expect(secondary.chatState?.historyTokens, 100);
    });

    test(
      'relays chat send, stop, and select agent from secondary to primary',
      () async {
        await Future<void>.delayed(const Duration(milliseconds: 20));

        String? sentText;
        List<ChatAttachment>? sentAttachments;
        var stopCalled = false;
        String? selectedAgent;

        primary.onChatSend = (text, {attachments}) {
          sentText = text;
          sentAttachments = attachments;
        };
        primary.onChatStop = () {
          stopCalled = true;
        };
        primary.onChatSelectAgent = (agentId) {
          selectedAgent = agentId;
        };

        secondary.sendChatSend(
          'Hello Primary',
          attachments: [
            ChatAttachment(
              id: 'test-1',
              name: 'doc.txt',
              mimeType: 'text/plain',
              bytes: Uint8List.fromList(utf8.encode('file contents')),
            ),
          ],
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(sentText, 'Hello Primary');
        expect(sentAttachments?.length, 1);
        expect(sentAttachments?.first.name, 'doc.txt');

        secondary.sendChatStop();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(stopCalled, isTrue);

        secondary.sendChatSelectAgent('agent-99');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(selectedAgent, 'agent-99');
      },
    );
  });

  group('DuoCompanionScaffold Chat Companion Pad Widget', () {
    late _FakeDuoBridge bridge;
    late _FakeDuoBridge primaryBridge;
    late DuoDisplayManager manager;

    setUp(() {
      bridge = _FakeDuoBridge();
      primaryBridge = _FakeDuoBridge();
      bridge.peer = primaryBridge;
      primaryBridge.peer = bridge;

      manager = DuoDisplayManager(
        secondary: true,
        platform: _FakeDuoPlatform(),
        bridge: bridge,
      );
      manager.start();
    });

    tearDown(() {
      manager.dispose();
    });

    testWidgets(
      'preparing preserves the companion draft until actual acceptance',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: DuoCompanionScaffold(manager: manager)),
        );
        Future<void> snapshot({
          bool busy = false,
          bool preparing = false,
          String text = 'keep draft',
        }) async {
          primaryBridge.send(
            jsonEncode({
              'type': 'snapshot',
              'currentRoute': '/chat',
              'chatState': DuoChatState(
                conversationId: 'a',
                draftText: text,
                isStreaming: busy,
                isPreparing: preparing,
              ).toJson(),
            }),
          );
          await tester.pump();
        }

        await snapshot();
        String inputText() => tester
            .widget<EditableText>(find.byType(EditableText).first)
            .controller
            .text;
        expect(inputText(), 'keep draft');
        await snapshot(busy: true, preparing: true);
        expect(inputText(), 'keep draft');
        await snapshot(); // readiness failure
        expect(inputText(), 'keep draft');
        await snapshot(busy: true, preparing: true);
        await snapshot(busy: true, text: ''); // accepted by primary
        expect(inputText(), isEmpty);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('renders chat companion pad when current route is /chat', (
      tester,
    ) async {
      // Simulate route snapshot from primary
      primaryBridge.send(
        jsonEncode({
          'type': 'snapshot',
          'selectedIndex': 0,
          'currentRoute': '/chat',
          'isDark': false,
          'chatState': const DuoChatState(
            isStreaming: false,
            modelName: 'Gemma 2B Local',
            activeAgentName: 'Super Agent',
            activeAgentId: 'agent-42',
            agents: [DuoChatAgent(id: 'agent-42', name: 'Super Agent')],
            historyTokens: 50,
          ).toJson(),
        }),
      );

      await tester.pumpWidget(
        MaterialApp(home: DuoCompanionScaffold(manager: manager)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Super Agent'), findsOneWidget);
      expect(find.text('Gemma 2B Local'), findsOneWidget);
      expect(find.text('Send to Display 0'), findsOneWidget);
      expect(find.text('Type a message to Display 0...'), findsOneWidget);
    });

    testWidgets('shows stop button when isStreaming is true on /chat', (
      tester,
    ) async {
      primaryBridge.send(
        jsonEncode({
          'type': 'snapshot',
          'selectedIndex': 0,
          'currentRoute': '/chat',
          'isDark': false,
          'chatState': const DuoChatState(
            isStreaming: true,
            modelName: 'Gemma 2B Local',
            activeAgentName: 'Super Agent',
            activeAgentId: 'agent-42',
          ).toJson(),
        }),
      );

      await tester.pumpWidget(
        MaterialApp(home: DuoCompanionScaffold(manager: manager)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stop Generation (ESC)'), findsOneWidget);
    });
  });
}
