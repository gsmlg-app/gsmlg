import 'dart:async';
import 'dart:convert';

import 'package:app_agent/app_agent.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gsmlg/duo/duo_chat_fallback.dart';
import 'package:gsmlg/duo/duo_controller.dart';
import 'package:gsmlg/screens/agents/agents_screen.dart';
import 'package:gsmlg/screens/chat/chat_screen.dart';

import '../screens/agents/agents_test_support.dart';

class _FakeDuoBridge implements DuoBridge {
  final _controller = StreamController<Object?>.broadcast();
  _FakeDuoBridge? peer;

  @override
  Stream<Object?> get messages => _controller.stream;

  @override
  void start() {}

  @override
  void send(String message) => peer?._controller.add(message);

  @override
  void dispose() => _controller.close();
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
  setUpAll(() => registerFallbackValue(const ChatLoadHistory()));

  testWidgets('companion send on the agents home starts a conversation with '
      'the active agent and shows it', (tester) async {
    final h = await RealChatHarness.create(tester);
    final primaryBridge = _FakeDuoBridge();
    final secondaryBridge = _FakeDuoBridge()..peer = primaryBridge;
    primaryBridge.peer = secondaryBridge;
    final primary = DuoDisplayManager(
      secondary: false,
      platform: _FakeDuoPlatform(),
      bridge: primaryBridge,
    );
    final secondary = DuoDisplayManager(
      secondary: true,
      platform: _FakeDuoPlatform(),
      bridge: secondaryBridge,
    );

    final router = await h.pump(tester, '/chat');
    DuoChatFallback(
      chatBloc: () => h.chatBloc,
      settingsBloc: () => h.settingsBloc,
      router: router,
    ).install(primary);
    primary.start();
    secondary.start();
    secondaryBridge.send(jsonEncode({'type': 'hello'}));
    await h.settle(
      tester,
      () => find.byType(AgentsScreen).evaluate().isNotEmpty,
    );
    expect(h.chatBloc.state.conversation, isNull);
    expect(primary.onChatSend, isNull);

    secondary.sendChatSend('Draft the release notes');
    await h.settle(
      tester,
      () =>
          h.chatBloc.state.conversation?.messages.any(
            (m) => m.content == 'Draft the release notes',
          ) ??
          false,
    );

    final conversation = h.chatBloc.state.conversation!;
    expect(conversation.id, isNot('c1'));
    expect(conversation.agentId, 'a1');
    expect(h.chatBloc.state.sessionFor(conversation.id)?.agentId, 'a1');
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/chat/conversation',
    );

    // Heartbeat timers belong to the managers.
    await tester.pumpWidget(const SizedBox());
    primary.dispose();
    secondary.dispose();
  });

  test('a send for a local agent without a model resolves an installed '
      'model like the chat screen', () {
    final chat = MockChatBloc();
    final settings = MockChatSettingsBloc();
    final models = MockGemmaModelBloc();
    final local = AgentDefinition(
      id: 'l1',
      name: 'Local',
      config: const ModelConfig(),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    when(() => chat.state).thenReturn(const ChatState());
    when(() => settings.state).thenReturn(
      ChatSettingsState(
        status: ChatSettingsStatus.loaded,
        agents: [local],
        activeAgentId: 'l1',
      ),
    );
    when(
      () => models.state,
    ).thenReturn(const GemmaModelState(installedModels: ['gemma-4-E2B-it']));
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: ChatScreen.name,
          builder: (_, _) => const SizedBox(),
        ),
      ],
    );
    addTearDown(router.dispose);

    DuoChatFallback(
      chatBloc: () => chat,
      settingsBloc: () => settings,
      modelBloc: () => models,
      router: router,
    ).send('hello');

    final sent = verify(
      () => chat.add(captureAny()),
    ).captured.whereType<ChatSendMessage>().single;
    expect(sent.config?.localModelId, 'gemma-4-E2B-it');
    expect(sent.agentId, 'l1');
  });

  test('intents are ignored while the chat blocs are unavailable', () {
    var resolved = 0;
    final fallback = DuoChatFallback(
      chatBloc: () {
        resolved++;
        return null;
      },
      settingsBloc: () => null,
      router: GoRouter(routes: []),
    );

    fallback.send('hello');
    fallback.stop();
    fallback.selectAgent('a1');

    expect(resolved, 3);
  });
}
