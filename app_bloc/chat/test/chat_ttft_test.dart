import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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
}

class _Fixture {
  _Fixture() {
    bloc = ChatBloc(
      gemmaRepository: repository,
      remoteRepository: _UnusedRemoteRepository(),
      storageRepository: storage,
      toolExecutor: tools,
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
  Future<List<Conversation>> loadConversations() async =>
      conversations.values.toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WaitingTools extends ToolExecutor {
  final started = StreamController<void>.broadcast();
  Completer<Map<String, dynamic>>? result;

  @override
  Future<Map<String, dynamic>> execute(String name, Map<String, dynamic> args) {
    result = Completer<Map<String, dynamic>>();
    started.add(null);
    return result!.future;
  }
}
