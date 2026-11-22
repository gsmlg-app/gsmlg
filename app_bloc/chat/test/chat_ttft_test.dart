import 'dart:async';
import 'dart:typed_data';

import 'package:app_agent/app_agent.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_agent_repository.dart';

void main() {
  for (final firstChunk in [
    const ChatTextChunk('first'),
    const ChatThinkingChunk('reasoning'),
    const ChatTextChunk(' '),
  ]) {
    test('captures $firstChunk before Bloc processing and freezes it',
        () async {
      final fixture = _Fixture();
      addTearDown(fixture.close);
      await fixture.start(const ChatSendMessage(content: 'hello'));
      fixture.repository.controller.add(const ChatTextChunk(''));
      fixture.repository.controller.add(const ChatThinkingChunk(''));
      await _flush();
      expect(fixture.assistant.responseInfo?.timeToFirstToken, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 30));
      final beforeChunk = fixture.repository.clock.elapsed;
      fixture.repository.controller.add(firstChunk);
      final queueDelay = Stopwatch()..start();
      while (queueDelay.elapsedMilliseconds < 150) {}
      await _flush();
      final firstInfo = fixture.assistant.responseInfo!;
      expect(firstInfo.timeToFirstToken, isNotNull);
      expect(firstInfo.timeToFirstToken!, greaterThanOrEqualTo(beforeChunk));
      expect(firstInfo.timeToFirstToken!,
          lessThan(beforeChunk + const Duration(milliseconds: 100)));
      expect(firstInfo.duration, greaterThan(firstInfo.timeToFirstToken!));

      fixture.repository.controller.add(const ChatTextChunk('answer'));
      fixture.repository.controller.add(const ChatThinkingChunk('thought'));
      await _flush();
      expect(fixture.assistant.responseInfo?.timeToFirstToken,
          firstInfo.timeToFirstToken);
      await fixture.finish();
      final completed = fixture.assistant;
      expect(
          completed.responseInfo?.timeToFirstToken, firstInfo.timeToFirstToken);
      final responseText = [completed.content, completed.thinkingContent!]
          .where((part) => part.trim().isNotEmpty)
          .join('\n');
      expect(completed.responseInfo?.outputTokens,
          (responseText.trim().length / 4).ceil());
      final stored = await fixture.storedAssistant();
      expect(stored.responseInfo?.timeToFirstToken?.inMilliseconds,
          firstInfo.timeToFirstToken?.inMilliseconds);
      expect(stored.responseInfo?.duration.inMilliseconds,
          completed.responseInfo?.duration.inMilliseconds);
    });
  }

  for (final fail in [false, true]) {
    for (final tokenArrived in [false, true]) {
      test('persists TTFT on error=$fail after token=$tokenArrived', () async {
        final fixture = _Fixture();
        addTearDown(fixture.close);
        await fixture.start(const ChatSendMessage(content: 'hello'));
        if (tokenArrived) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          fixture.repository.controller
              .add(const ChatThinkingChunk('thinking'));
          await _flush();
        }
        final latency = fixture.assistant.responseInfo?.timeToFirstToken;
        final terminal = _wait(
            fixture.bloc,
            (state) =>
                state.status == (fail ? ChatStatus.error : ChatStatus.stopped));
        if (fail) {
          fixture.repository.controller.addError(StateError('failed'));
        } else {
          fixture.bloc.add(const ChatStopGeneration());
        }
        await terminal;
        expect(fixture.assistant.responseInfo?.timeToFirstToken, latency);
        final stored = await fixture.storedAssistant();
        expect(stored.responseInfo?.timeToFirstToken?.inMilliseconds,
            latency?.inMilliseconds);
        expect(stored.responseInfo, isNotNull);
        expect(stored.isStreaming, isFalse);
      });
    }
  }

  for (final tokenBeforeTool in [false, true]) {
    test(
        'keeps metrics through tool loops, first token before tool=$tokenBeforeTool',
        () async {
      final fixture = _Fixture();
      addTearDown(fixture.close);
      await fixture.start(const ChatSendMessage(content: 'hello'));
      if (tokenBeforeTool) {
        fixture.repository.controller.add(const ChatTextChunk('first'));
        await _flush();
      }
      final latency = fixture.assistant.responseInfo?.timeToFirstToken;
      final beforeTools = fixture.repository.clock.elapsed;
      for (var loop = 0; loop < 2; loop++) {
        final toolStarted = fixture.tools.started.stream.first;
        fixture.repository.controller
            .add(const ChatFunctionCallChunk(name: 'tool', args: {}));
        await fixture.repository.controller.close();
        await toolStarted;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        final resumed = fixture.repository.generations.stream.first;
        fixture.tools.result!.complete({'ok': true});
        await resumed;
        expect(fixture.assistant.responseInfo?.timeToFirstToken, latency);
      }
      final toolWait = fixture.repository.clock.elapsed - beforeTools;
      fixture.repository.controller.add(const ChatThinkingChunk('after tools'));
      await _flush();
      final afterTools = fixture.assistant.responseInfo!;
      if (tokenBeforeTool) {
        expect(afterTools.timeToFirstToken, latency);
      } else {
        expect(afterTools.timeToFirstToken!, greaterThanOrEqualTo(toolWait));
      }
      expect(afterTools.duration, greaterThanOrEqualTo(toolWait));
      await fixture.finish();
      expect(fixture.assistant.responseInfo?.timeToFirstToken,
          afterTools.timeToFirstToken);
    });
  }

  for (final action in ['send', 'edit', 'regenerate']) {
    test('resets TTFT for $action generation', () async {
      final fixture = _Fixture();
      addTearDown(fixture.close);
      await fixture.start(const ChatSendMessage(content: 'hello'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      fixture.repository.controller.add(const ChatTextChunk('original'));
      await _flush();
      expect(fixture.assistant.responseInfo?.timeToFirstToken, isNotNull);
      await fixture.finish();
      final user = fixture.bloc.state.messages.whereType<UserMessage>().first;
      await fixture.start(switch (action) {
        'edit' => ChatEditUserMessage(messageId: user.id, content: 'edited'),
        'regenerate' => const ChatRegenerateResponse(),
        _ => const ChatSendMessage(content: 'again'),
      });
      fixture.repository.controller.add(const ChatTextChunk(''));
      await _flush();
      expect(fixture.assistant.responseInfo?.timeToFirstToken, isNull);
      final beforeToken = fixture.assistant.responseInfo!.duration;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      fixture.repository.controller.add(const ChatTextChunk('new'));
      await _flush();
      expect(fixture.assistant.responseInfo!.timeToFirstToken!,
          greaterThan(beforeToken));
      await fixture.finish();
    });
  }

  test('keeps TTFT on original response when navigating away and back',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.start(const ChatSendMessage(content: 'hello'));
    final originalId = fixture.bloc.state.conversation!.id;
    await fixture.storage.saveConversation(Conversation.create(id: 'other'));
    final switched =
        _wait(fixture.bloc, (state) => state.conversation?.id == 'other');
    fixture.bloc.add(const ChatLoadConversation(id: 'other'));
    await switched;
    fixture.repository.controller.add(const ChatTextChunk('original response'));
    await _flush();
    expect(fixture.bloc.state.messages, isEmpty);
    final returned =
        _wait(fixture.bloc, (state) => state.conversation?.id == originalId);
    fixture.bloc.add(ChatLoadConversation(id: originalId));
    await returned;
    final latency = fixture.assistant.responseInfo!.timeToFirstToken;
    expect(latency, isNotNull);
    final switchedAgain =
        _wait(fixture.bloc, (state) => state.conversation?.id == 'other');
    fixture.bloc.add(const ChatLoadConversation(id: 'other'));
    await switchedAgain;
    await fixture.finish();
    expect(fixture.bloc.state.messages, isEmpty);
    final saved = await fixture.storage.loadConversation(originalId);
    expect(
        saved!.messages
            .whereType<AssistantMessage>()
            .single
            .responseInfo
            ?.timeToFirstToken
            ?.inMilliseconds,
        latency?.inMilliseconds);
  });

  test(
      'editing a user message replaces attachments, drops later turns, and clears draft',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);

    // Turn 1
    await fixture.start(const ChatSendMessage(content: 'turn 1'));
    fixture.repository.controller.add(const ChatTextChunk('answer 1'));
    await fixture.finish();

    // Turn 2
    await fixture.start(const ChatSendMessage(content: 'turn 2'));
    fixture.repository.controller.add(const ChatTextChunk('answer 2'));
    await fixture.finish();

    final convId = fixture.bloc.state.conversation!.id;
    final turn1User =
        fixture.bloc.state.messages.whereType<UserMessage>().first;
    final newImg = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x01]);
    final newAtt = ChatAttachment(
      id: 'att-new',
      name: 'new.png',
      mimeType: 'image/png',
      sizeBytes: newImg.length,
      bytes: newImg,
    );

    // Simulate user editing turn 1 in the composer draft
    fixture.bloc.add(ChatUpdateDraft(
      conversationId: convId,
      text: 'turn 1 revised',
      attachments: [newAtt],
    ));
    await _flush();
    expect(fixture.bloc.state.currentDraft.text, 'turn 1 revised');

    await fixture.start(ChatEditUserMessage(
      conversationId: convId,
      messageId: turn1User.id,
      content: 'turn 1 revised',
      imageBytes: newImg,
      attachments: [newAtt],
    ));
    fixture.repository.controller.add(const ChatTextChunk('new answer 1'));
    await fixture.finish();

    // Draft is cleared, turn 2 is dropped, and turn 1 has updated content + attachment
    expect(fixture.bloc.state.currentDraft.isEmpty, isTrue);
    final users = fixture.bloc.state.messages.whereType<UserMessage>().toList();
    expect(users, hasLength(1));
    expect(users.single.id, turn1User.id);
    expect(users.single.content, 'turn 1 revised');
    expect(users.single.imageBytes, newImg);
    expect(users.single.attachments, [newAtt]);

    final assistants =
        fixture.bloc.state.messages.whereType<AssistantMessage>().toList();
    expect(assistants, hasLength(1));
    expect(assistants.single.content, 'new answer 1');
  });

  test(
      'forking from an assistant response clones prefix into a new conversation and preserves the original',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);

    // Turn 1
    await fixture.start(const ChatSendMessage(content: 'turn 1'));
    fixture.repository.controller.add(const ChatTextChunk('answer 1'));
    await fixture.finish();

    // Turn 2
    await fixture.start(const ChatSendMessage(content: 'turn 2'));
    fixture.repository.controller.add(const ChatTextChunk('answer 2'));
    await fixture.finish();

    final originalId = fixture.bloc.state.conversation!.id;
    final originalMessages = List<Message>.from(fixture.bloc.state.messages);
    final turn1Assistant = originalMessages.whereType<AssistantMessage>().first;

    final forkedReady = _wait(
      fixture.bloc,
      (state) =>
          state.conversation != null && state.conversation!.id != originalId,
    );
    fixture.bloc.add(ChatForkConversation(
      conversationId: originalId,
      messageId: turn1Assistant.id,
    ));
    await forkedReady;
    await _flush();

    final forkedConv = fixture.bloc.state.conversation!;
    expect(forkedConv.id, isNot(originalId));
    expect(forkedConv.title, endsWith('(Fork)'));

    // Forked conversation only contains turn 1 (with fresh message IDs)
    final forkedUsers = forkedConv.messages.whereType<UserMessage>().toList();
    final forkedAssistants =
        forkedConv.messages.whereType<AssistantMessage>().toList();
    expect(forkedUsers, hasLength(1));
    expect(forkedUsers.single.content, 'turn 1');
    expect(forkedAssistants, hasLength(1));
    expect(forkedAssistants.single.content, 'answer 1');
    expect(forkedAssistants.single.id, isNot(turn1Assistant.id));
    expect(forkedAssistants.single.conversationId, forkedConv.id);

    // Original conversation remains intact in storage with both turns
    final storedOriginal = await fixture.storage.loadConversation(originalId);
    expect(storedOriginal!.messages.whereType<UserMessage>(), hasLength(2));
    final storedFork = await fixture.storage.loadConversation(forkedConv.id);
    expect(storedFork!.messages.whereType<UserMessage>(), hasLength(1));
    expect(storedFork.messages.whereType<AssistantMessage>(), hasLength(1));
  });
}

class _Fixture {
  _Fixture() {
    bloc = ChatBloc(
      gemmaRepository: repository,
      remoteRepository: _UnusedRemoteRepository(),
      storageRepository: storage,
      agentRepository: FakeAgentRepository(),
      toolExecutor: tools,
      agentRunner: InProcessAgentRunner(
        ChatAgentRuntime(
          toolExecutor: tools,
          remoteRepository: _UnusedRemoteRepository(),
          gemmaRepository: repository,
          storageRepository: storage,
        ),
      ),
    );
  }

  final repository = _StreamingRepository();
  final tools = _WaitingTools();
  final storage = _MemoryStorage();
  late final ChatBloc bloc;

  AssistantMessage get assistant =>
      bloc.state.messages.whereType<AssistantMessage>().last;

  Future<void> start(ChatEvent event) async {
    final generated = repository.generations.stream.first;
    bloc.add(event);
    await generated.timeout(const Duration(seconds: 5));
    await _flush();
  }

  Future<void> finish() async {
    final completed = _wait(bloc, (state) => state.status == ChatStatus.ready);
    await repository.controller.close();
    await completed;
  }

  Future<AssistantMessage> storedAssistant() async =>
      (await storage.loadMessages(bloc.state.conversation!.id))
          .whereType<AssistantMessage>()
          .last;

  Future<void> close() async {
    await bloc.close();
    await repository.dispose();
    await tools.started.close();
  }
}

Future<void> _flush() async {
  for (var turn = 0; turn < 5; turn++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<ChatState> _wait(ChatBloc bloc, bool Function(ChatState) predicate) =>
    bloc.stream.firstWhere(predicate).timeout(const Duration(seconds: 5));

class _StreamingRepository extends GemmaRepository {
  late StreamController<ChatGenerationChunk> controller;
  final generations = StreamController<void>.broadcast();
  final clock = Stopwatch();

  @override
  bool get isReady => true;

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages, {
    List<Map<String, dynamic>> tools = const [],
    ModelConfig? config,
  }) {
    if (!clock.isRunning) clock.start();
    controller = StreamController<ChatGenerationChunk>(sync: true);
    generations.add(null);
    return controller.stream;
  }

  @override
  Future<void> stopGeneration() async {}

  @override
  Future<void> dispose() async {
    if (!controller.isClosed) await controller.close();
    await generations.close();
  }
}

class _UnusedRemoteRepository implements RemoteLlmRepository {
  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryStorage implements ChatStorageRepository {
  final conversations = <String, Conversation>{};
  final messages = <String, Message>{};

  @override
  Future<ModelConfig> loadSettings() async => ModelConfig.defaultConfig;

  @override
  Future<void> saveConversation(Conversation conversation) async {
    conversations[conversation.id] = conversation.copyWith(messages: const []);
  }

  @override
  Future<void> saveMessage(Message message) async {
    messages[message.id] = message;
  }

  @override
  Future<void> deleteMessage(String id) async {
    messages.remove(id);
  }

  @override
  Future<List<Message>> loadMessages(String conversationId) async =>
      messages.values
          .where((message) => message.conversationId == conversationId)
          .toList();

  @override
  Future<Conversation?> loadConversation(String id) async =>
      conversations[id]?.copyWith(messages: await loadMessages(id));

  @override
  Future<List<Conversation>> loadConversations({String? agentId}) async =>
      conversations.values.toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WaitingTools extends ToolExecutor {
  final started = StreamController<void>.broadcast();
  Completer<Map<String, dynamic>>? result;

  @override
  List<ChatToolDefinition> get toolDefinitions => const [
        ChatToolDefinition(
            name: 'tool', description: 'test tool', parameters: {}),
      ];

  @override
  Future<Map<String, dynamic>> execute(String name, Map<String, dynamic> args) {
    result = Completer<Map<String, dynamic>>();
    started.add(null);
    return result!.future;
  }
}
