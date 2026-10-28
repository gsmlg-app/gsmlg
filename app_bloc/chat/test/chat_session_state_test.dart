import 'dart:async';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _remoteConfig = ModelConfig(
    inferenceMode: ChatInferenceMode.remote,
    remoteBaseUrl: 'http://localhost:8000/v1',
    remoteModel: 'model');

void main() {
  test(
      'remote sessions run concurrently and stopping one leaves the other live',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.start('a', config: _remoteConfig);
    await fixture.start('b', config: _remoteConfig);
    expect(fixture.bloc.state.runningCount, 2);
    expect(fixture.bloc.state.conversation?.id, 'b');
    fixture.remote.controllers['a']!.add(const ChatTextChunk('answer a'));
    fixture.remote.controllers['b']!.add(const ChatThinkingChunk('thinking b'));
    await _flush();
    expect(fixture.assistant('a').content, 'answer a');
    expect(fixture.assistant('b').thinkingContent, 'thinking b');
    await fixture.sendAndWait(const ChatStopGeneration(conversationId: 'a'),
        (s) => s.sessionFor('a')?.status == ChatStatus.stopped);
    expect(fixture.bloc.state.runningCount, 1);
    expect(fixture.bloc.state.isStreaming, isTrue);
    expect(fixture.remote.stopped, [fixture.remote.ids['a']]);
    fixture.remote.controllers['b']!.add(const ChatTextChunk('answer b'));
    await fixture.finish('b');
    expect(fixture.assistant('b').content, 'answer b');
    expect(fixture.bloc.state.sessionFor('a')!.hasUnreadResponse, isFalse);
    expect(fixture.assistant('a').isStreaming, isFalse);
  });

  test(
      'background failure does not replace selected status and reports unread result',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.start('a', config: _remoteConfig);
    await fixture.start('b', config: _remoteConfig);
    final failed = _wait(
        fixture.bloc, (s) => s.sessionFor('a')?.status == ChatStatus.error);
    fixture.remote.controllers['a']!.addError(StateError('a failed'));
    await failed;
    expect(fixture.bloc.state.conversation?.id, 'b');
    expect(fixture.bloc.state.status, ChatStatus.streaming);
    expect(fixture.bloc.state.errorMessage, isNull);
    expect(fixture.bloc.state.sessionFor('a')!.hasUnreadResponse, isTrue);
    await fixture.sendAndWait(
        const ChatLoadConversation(id: 'a'), (s) => s.conversation?.id == 'a');
    expect(fixture.bloc.state.errorMessage, contains('a failed'));
    expect(fixture.bloc.state.sessionFor('a')!.hasUnreadResponse, isFalse);
  });

  test('local sessions execute FIFO; cancelled queued session never starts',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.start('a');
    await fixture.start('b', expected: ChatStatus.queued);
    await fixture.start('c', expected: ChatStatus.queued);
    expect(fixture.local.started, ['a']);
    expect(fixture.bloc.state.sessionFor('b')!.queuePosition, 1);
    expect(fixture.bloc.state.sessionFor('c')!.queuePosition, 2);
    await fixture.sendAndWait(const ChatStopGeneration(conversationId: 'b'),
        (s) => s.sessionFor('b')?.status == ChatStatus.stopped);
    expect(fixture.bloc.state.sessionFor('c')!.queuePosition, 1);
    final cStarted =
        _wait(fixture.bloc, (s) => s.sessionFor('c')?.isStreaming ?? false);
    fixture.local.controllers['a']!.addError(StateError('a failed'));
    await cStarted;
    expect(fixture.local.started, ['a', 'c']);
    expect(fixture.bloc.state.sessionFor('a')!.status, ChatStatus.error);
    expect(fixture.bloc.state.queuedCount, 0);
  });

  test(
      'duplicate sends reserve the original target before asynchronous readiness',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.load('a');
    fixture.remote.readiness = Completer<bool>();
    fixture.bloc
        .add(const ChatSendMessage(content: 'first', config: _remoteConfig));
    fixture.bloc.add(
        const ChatSendMessage(content: 'duplicate', config: _remoteConfig));
    await _flush();
    expect(fixture.bloc.state.status, ChatStatus.preparing);
    await fixture.load('b');
    final aStarted =
        _wait(fixture.bloc, (s) => s.sessionFor('a')?.isStreaming ?? false);
    fixture.remote.readiness!.complete(true);
    await aStarted;
    expect(fixture.bloc.state.conversation?.id, 'b');
    expect(fixture.bloc.state.canSendMessage, isTrue);
    expect(
        fixture.bloc.state
            .sessionFor('a')!
            .conversation
            .messages
            .whereType<UserMessage>()
            .single
            .content,
        'first');
    expect(fixture.remote.started, ['a']);
  });

  test(
      'drafts retain text, selection and attachments independently and survive readiness failure',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.load('a');
    final attachment = ChatAttachment(
        id: 'file', name: 'note.txt', bytes: Uint8List.fromList([1, 2]));
    fixture.bloc.add(ChatUpdateDraft(
        conversationId: 'a',
        text: 'draft a',
        selectionBase: 2,
        selectionExtent: 5,
        attachments: [attachment]));
    await _flush();
    await fixture.load('b');
    fixture.bloc
        .add(const ChatUpdateDraft(conversationId: 'b', text: 'draft b'));
    await _flush();
    await fixture.load('a');
    expect(fixture.bloc.state.currentDraft.text, 'draft a');
    expect(fixture.bloc.state.currentDraft.selectionExtent, 5);
    expect(fixture.bloc.state.currentDraft.attachments.single.bytes, [1, 2]);
    fixture.remote.ready = false;
    await fixture.sendAndWait(
        const ChatSendMessage(
            conversationId: 'a', content: 'draft a', config: _remoteConfig),
        (s) => s.sessionFor('a')?.status == ChatStatus.error);
    expect(fixture.bloc.state.currentDraft.text, 'draft a');
    expect(fixture.bloc.state.drafts['b']!.text, 'draft b');
    fixture.remote.ready = true;
    await fixture.sendAndWait(
        ChatSendMessage(
            conversationId: 'a',
            content: 'draft a',
            config: _remoteConfig,
            attachments: [attachment]),
        (s) => s.sessionFor('a')?.isStreaming ?? false);
    expect(fixture.bloc.state.currentDraft.isEmpty, isTrue);
    expect(fixture.bloc.state.drafts['b']!.text, 'draft b');
  });

  test('newer edits during readiness are not cleared by accepted send',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.load('a');
    fixture.bloc.add(const ChatUpdateDraft(text: 'submitted'));
    await _flush();
    fixture.remote.readiness = Completer<bool>();
    fixture.bloc.add(
        const ChatSendMessage(content: 'submitted', config: _remoteConfig));
    await _flush();
    fixture.bloc.add(const ChatUpdateDraft(text: 'next draft'));
    await _flush();
    final started = _wait(fixture.bloc, (s) => s.isStreaming);
    fixture.remote.readiness!.complete(true);
    await started;
    expect(fixture.bloc.state.currentDraft.text, 'next draft');
  });

  test(
      'delete while a tool is pending ignores its late result and does not revive storage',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.start('a', config: _remoteConfig);
    final called = fixture.tools.started.future;
    fixture.remote.controllers['a']!
        .add(const ChatFunctionCallChunk(name: 'wait', args: {}));
    await called;
    await fixture.sendAndWait(const ChatDeleteConversation(id: 'a'),
        (s) => !s.sessions.containsKey('a'));
    fixture.tools.result.complete({'late': true});
    await _flush();
    expect(fixture.remote.started, ['a']);
    expect(fixture.storage.conversations.containsKey('a'), isFalse);
    expect(await fixture.storage.loadMessages('a'), isEmpty);
    expect(fixture.bloc.state.runningCount, 0);
  });

  test('deletion drains an in-flight response write before removing storage',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.start('a', config: _remoteConfig);
    fixture.remote.controllers['a']!.add(const ChatTextChunk('done'));
    await _flush();
    fixture.storage.blockAssistantWrite = Completer<void>();
    final writing = fixture.storage.assistantWriting.future;
    unawaited(fixture.remote.controllers['a']!.close());
    await writing;
    fixture.bloc.add(const ChatDeleteConversation(id: 'a'));
    await _flush();
    expect(fixture.storage.conversations.containsKey('a'), isTrue);
    final deleted = _wait(fixture.bloc, (s) => !s.sessions.containsKey('a'));
    fixture.storage.blockAssistantWrite!.complete();
    await deleted;
    expect(fixture.storage.conversations.containsKey('a'), isFalse);
    expect(await fixture.storage.loadMessages('a'), isEmpty);
  });

  test(
      'configured local jobs queue during model loading and cancellation retains the slot',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    const config = ModelConfig(localModelId: 'gemma-4-E2B-it');
    fixture.local.activationGate = Completer<void>();
    await fixture.load('a');
    fixture.bloc.add(const ChatSendMessage(content: 'a', config: config));
    await fixture.local.activating.future;
    await fixture.start('b', config: config, expected: ChatStatus.queued);
    final stopped = _wait(
        fixture.bloc, (s) => s.sessionFor('a')?.status == ChatStatus.stopped);
    fixture.bloc.add(const ChatStopGeneration(conversationId: 'a'));
    await _flush();
    expect(fixture.local.activationCount, 1);
    expect(fixture.local.started, isEmpty);
    expect(fixture.bloc.state.sessionFor('b')!.status, ChatStatus.queued);
    final bStarted =
        _wait(fixture.bloc, (s) => s.sessionFor('b')?.isStreaming ?? false);
    fixture.local.activationGate!.complete();
    await stopped;
    await bStarted;
    expect(fixture.local.activationCount, 2);
    expect(fixture.local.started, ['b']);
  });

  test(
      'configuration is fixed during a run and switching agents clears the old system prompt',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.load('a');
    fixture.bloc.add(const ChatConfigureSession(
        config: _remoteConfig,
        agentId: 'first',
        systemPrompt: 'old instructions',
        thinkingEnabled: true));
    await _flush();
    await fixture.sendAndWait(
        const ChatSendMessage(content: 'hello'), (s) => s.isStreaming);
    expect(fixture.remote.configs['a']!.remoteModel, 'model');
    expect(
        fixture.remote.messages['a']!.whereType<SystemMessage>().single.content,
        'old instructions');
    fixture.bloc.add(ChatConfigureSession(
        config: _remoteConfig.copyWith(remoteModel: 'different'),
        agentId: 'second',
        systemPrompt: 'new instructions'));
    await _flush();
    expect(fixture.bloc.state.currentSession!.agentId, 'first');
    fixture.remote.controllers['a']!.add(const ChatTextChunk('done'));
    await fixture.finish('a');
    fixture.bloc.add(ChatConfigureSession(
        config: _remoteConfig.copyWith(remoteModel: 'different')));
    await _flush();
    expect(fixture.bloc.state.currentSession!.agentId, isNull);
    expect(fixture.bloc.state.currentSession!.systemPrompt, isNull);
    await fixture.sendAndWait(
        const ChatSendMessage(content: 'next'), (s) => s.isStreaming);
    expect(fixture.remote.messages['a']!.whereType<SystemMessage>(), isEmpty);
    expect((await fixture.storage.loadMessages('a')).whereType<SystemMessage>(),
        isEmpty);
    expect(fixture.remote.configs['a']!.remoteModel, 'different');
  });

  test('delete requested while stopping a local load is honored after cleanup',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    fixture.local.activationGate = Completer<void>();
    await fixture.load('a');
    fixture.bloc.add(const ChatSendMessage(
        content: 'a', config: ModelConfig(localModelId: 'gemma-4-E2B-it')));
    await fixture.local.activating.future;
    fixture.bloc.add(const ChatStopGeneration(conversationId: 'a'));
    await _flush();
    fixture.bloc.add(const ChatDeleteConversation(id: 'a'));
    await _flush();
    final deleted = _wait(fixture.bloc, (s) => !s.sessions.containsKey('a'));
    fixture.local.activationGate!.complete();
    await deleted;
    expect(fixture.storage.conversations.containsKey('a'), isFalse);
    expect(await fixture.storage.loadMessages('a'), isEmpty);
    expect(fixture.local.started, isEmpty);
  });

  test(
      'model lifecycle waits for local generation using the shared repository lease',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    SharedPreferences.setMockInitialValues({});
    final model = GemmaModelBloc(
        repository: fixture.local,
        preferences: await SharedPreferences.getInstance());
    addTearDown(model.close);
    await fixture.start('a');
    model.add(const GemmaModelUnload());
    await _flush();
    expect(fixture.local.unloadCount, 0);
    final unloaded = fixture.local.unloading.future;
    await fixture.sendAndWait(const ChatStopGeneration(conversationId: 'a'),
        (s) => s.sessionFor('a')?.status == ChatStatus.stopped);
    await unloaded;
    expect(fixture.local.unloadCount, 1);
  });

  test('local generation waits for an earlier model lifecycle operation',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    SharedPreferences.setMockInitialValues({});
    final model = GemmaModelBloc(
        repository: fixture.local,
        preferences: await SharedPreferences.getInstance());
    addTearDown(model.close);
    fixture.local.unloadGate = Completer<void>();
    model.add(const GemmaModelUnload());
    await fixture.local.unloading.future;
    await fixture.load('a');
    fixture.bloc.add(const ChatSendMessage(
        content: 'hello', config: ModelConfig(localModelId: 'gemma-4-E2B-it')));
    await _flush();
    expect(fixture.local.activationCount, 0);
    expect(fixture.local.started, isEmpty);
    await fixture.start('b',
        config: const ModelConfig(localModelId: 'gemma-4-E2B-it'),
        expected: ChatStatus.queued);
    expect(fixture.bloc.state.sessionFor('a')!.queuePosition, 1);
    expect(fixture.bloc.state.sessionFor('b')!.queuePosition, 2);
    final running =
        _wait(fixture.bloc, (s) => s.sessionFor('a')?.isStreaming ?? false);
    fixture.local.unloadGate!.complete();
    await running;
    expect(fixture.local.activationCount, 1);
    expect(fixture.local.started, ['a']);
    expect(fixture.bloc.state.sessionFor('b')!.queuePosition, 1);
  });

  test(
      'cancelling a chat waiting for model access does not stop its owner or leak access',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    SharedPreferences.setMockInitialValues({});
    final model = GemmaModelBloc(
        repository: fixture.local,
        preferences: await SharedPreferences.getInstance());
    addTearDown(model.close);
    fixture.local.unloadGate = Completer<void>();
    model.add(const GemmaModelUnload());
    await fixture.local.unloading.future;
    await fixture.load('a');
    fixture.bloc.add(const ChatSendMessage(
        content: 'hello', config: ModelConfig(localModelId: 'gemma-4-E2B-it')));
    await _flush();
    final stopped = _wait(
        fixture.bloc, (s) => s.sessionFor('a')?.status == ChatStatus.stopped);
    fixture.bloc.add(const ChatStopGeneration(conversationId: 'a'));
    await _flush();
    expect(fixture.local.stopCount, 0);
    await fixture.start('remote', config: _remoteConfig);
    expect(fixture.bloc.state.runningCount, 1);
    fixture.local.unloadGate!.complete();
    await stopped;
    expect(fixture.local.started, isEmpty);
    await LocalModelAccess.forResource(fixture.local).run(() async {});
    expect(fixture.bloc.state.sessionFor('remote')!.isStreaming, isTrue);
  });

  test('model access is FIFO and lease release is idempotent', () async {
    final access = LocalModelAccess();
    final first = await access.acquire();
    final order = <String>[];
    final second = access.acquire().then((lease) {
      order.add('second');
      return lease;
    });
    final third = access.acquire().then((lease) {
      order.add('third');
      return lease;
    });
    await _flush();
    expect(order, isEmpty);
    first.release();
    first.release();
    final secondLease = await second;
    await _flush();
    expect(order, ['second']);
    secondLease.release();
    final thirdLease = await third;
    expect(order, ['second', 'third']);
    thirdLease.release();
    await expectLater(access.run<void>(() async {
      throw StateError('operation failed');
    }), throwsStateError);
    await access.run(() async {});
  });

  test(
      'persisted streaming reply is interrupted without starting a new request',
      () async {
    final fixture = _Fixture();
    addTearDown(fixture.close);
    await fixture.storage.saveConversation(Conversation.create(id: 'old'));
    await fixture.storage.saveMessage(AssistantMessage(
        id: 'old-answer',
        content: 'partial',
        conversationId: 'old',
        timestamp: DateTime.now(),
        isStreaming: true));
    await fixture.load('old');
    expect(fixture.bloc.state.status, ChatStatus.stopped);
    expect(fixture.assistant('old').content, 'partial');
    expect(fixture.assistant('old').isStreaming, isFalse);
    expect(fixture.remote.started, isEmpty);
    expect(fixture.local.started, isEmpty);
  });
}

class _Fixture {
  _Fixture() {
    bloc = ChatBloc(
        gemmaRepository: local,
        remoteRepository: remote,
        storageRepository: storage,
        toolExecutor: tools);
  }
  final storage = _Storage();
  final local = _Local();
  final remote = _Remote();
  final tools = _Tools();
  late final ChatBloc bloc;
  AssistantMessage assistant(String id) => bloc.state
      .sessionFor(id)!
      .conversation
      .messages
      .whereType<AssistantMessage>()
      .last;
  Future<void> load(String id) async {
    if (!storage.conversations.containsKey(id)) {
      await storage.saveConversation(Conversation.create(id: id));
    }
    await sendAndWait(
        ChatLoadConversation(id: id), (s) => s.conversation?.id == id);
  }

  Future<void> start(String id,
      {ModelConfig? config, ChatStatus expected = ChatStatus.streaming}) async {
    await load(id);
    await sendAndWait(
        ChatSendMessage(
            conversationId: id, content: 'hello $id', config: config),
        (s) => s.sessionFor(id)?.status == expected);
  }

  Future<void> sendAndWait(
      ChatEvent event, bool Function(ChatState) predicate) async {
    final result = _wait(bloc, predicate);
    bloc.add(event);
    await result;
  }

  Future<void> finish(String id) async {
    final done =
        _wait(bloc, (s) => s.sessionFor(id)?.status == ChatStatus.ready);
    await remote.controllers[id]!.close();
    await done;
  }

  Future<void> close() async {
    await bloc.close();
    await remote.closeControllers();
    await local.dispose();
    if (!tools.result.isCompleted) tools.result.complete({});
  }
}

Future<ChatState> _wait(ChatBloc bloc, bool Function(ChatState) predicate) =>
    bloc.stream.firstWhere(predicate).timeout(const Duration(seconds: 5));
Future<void> _flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _Remote implements RemoteLlmRepository {
  final controllers = <String, StreamController<ChatGenerationChunk>>{};
  final ids = <String, String?>{};
  final configs = <String, ModelConfig>{};
  final messages = <String, List<Message>>{};
  final started = <String>[];
  final stopped = <String?>[];
  bool ready = true;
  Completer<bool>? readiness;
  @override
  Future<bool> isReady(ModelConfig config) async => readiness?.future ?? ready;
  @override
  Stream<ChatGenerationChunk> generateResponse(
      List<Message> messages, ModelConfig config,
      {List<Map<String, dynamic>> tools = const [], String? generationId}) {
    final id = messages.first.conversationId;
    started.add(id);
    ids[id] = generationId;
    configs[id] = config;
    this.messages[id] = messages;
    final controller = StreamController<ChatGenerationChunk>(sync: true);
    controllers[id] = controller;
    return controller.stream;
  }

  @override
  Future<void> stopGeneration({String? generationId}) async {
    stopped.add(generationId);
  }

  @override
  Future<void> dispose() async {}
  Future<void> closeControllers() async {
    for (final c in controllers.values) {
      if (!c.isClosed) await c.close();
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Local extends GemmaRepository {
  final controllers = <String, StreamController<ChatGenerationChunk>>{};
  final started = <String>[];
  bool ready = true;
  Completer<void>? activationGate;
  final activating = Completer<void>();
  int activationCount = 0;
  int unloadCount = 0;
  int stopCount = 0;
  Completer<void>? unloadGate;
  final unloading = Completer<void>();
  @override
  bool get isReady => ready;
  @override
  Future<void> activateModel(GemmaModelInfo info) async {
    activationCount++;
    ready = false;
    if (!activating.isCompleted) {
      activating.complete();
    }
    await activationGate?.future;
  }

  @override
  Future<void> loadModel(ModelConfig config,
      {bool supportImage = false,
      bool supportAudio = false,
      bool isThinking = false,
      bool supportsFunctionCalls = false,
      String? downloadProxyUrl}) async {
    ready = true;
  }

  @override
  Stream<ChatGenerationChunk> generateResponse(List<Message> messages,
      {List<Map<String, dynamic>> tools = const [], ModelConfig? config}) {
    final id = messages.first.conversationId;
    started.add(id);
    final controller = StreamController<ChatGenerationChunk>(sync: true);
    controllers[id] = controller;
    return controller.stream;
  }

  @override
  Future<void> stopGeneration() async {
    stopCount++;
  }

  @override
  Future<void> unloadModel() async {
    unloadCount++;
    ready = false;
    if (!unloading.isCompleted) {
      unloading.complete();
    }
    await unloadGate?.future;
  }

  @override
  Future<void> dispose() async {
    for (final c in controllers.values) {
      if (!c.isClosed) await c.close();
    }
  }
}

class _Tools extends ToolExecutor {
  final started = Completer<void>();
  final result = Completer<Map<String, dynamic>>();
  @override
  Future<Map<String, dynamic>> execute(String name, Map<String, dynamic> args) {
    started.complete();
    return result.future;
  }
}

class _Storage implements ChatStorageRepository {
  final conversations = <String, Conversation>{};
  final messages = <String, Message>{};
  Completer<void>? blockAssistantWrite;
  final assistantWriting = Completer<void>();
  @override
  Future<ModelConfig> loadSettings() async => ModelConfig.defaultConfig;
  @override
  Future<void> saveConversation(Conversation conversation) async {
    conversations[conversation.id] = conversation.copyWith(messages: const []);
  }

  @override
  Future<void> saveMessage(Message message) async {
    if (message is AssistantMessage &&
        !message.isStreaming &&
        blockAssistantWrite != null) {
      if (!assistantWriting.isCompleted) assistantWriting.complete();
      await blockAssistantWrite!.future;
    }
    messages[message.id] = message;
  }

  @override
  Future<void> deleteMessage(String id) async {
    messages.remove(id);
  }

  @override
  Future<void> deleteConversation(String id) async {
    conversations.remove(id);
    messages.removeWhere((key, value) => value.conversationId == id);
  }

  @override
  Future<void> clearConversationMessages(String id) async {
    messages.removeWhere((key, value) => value.conversationId == id);
  }

  @override
  Future<List<Message>> loadMessages(String id) async =>
      messages.values.where((message) => message.conversationId == id).toList();
  @override
  Future<Conversation?> loadConversation(String id) async =>
      conversations[id]?.copyWith(messages: await loadMessages(id));
  @override
  Future<List<Conversation>> loadConversations() async =>
      conversations.values.toList();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
