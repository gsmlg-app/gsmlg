import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:app_secure_storage/vault_repository.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _timeout = Duration(seconds: 5);

void main() {
  for (final api in [
    RemoteLlmApiType.openAiChatCompletions,
    RemoteLlmApiType.openAiResponses,
    RemoteLlmApiType.anthropicMessages,
  ]) {
    for (final beforeHeaders in [true, false]) {
      test('stop ${api.name} beforeHeaders=$beforeHeaders preserves B',
          () async {
        final fixture = await _Fixture.create(api);
        addTearDown(fixture.close);
        await fixture.start('a');
        await fixture.start('b');
        if (!beforeHeaders) await fixture.chunk('a', 'partial a');
        await fixture.chunk('b', 'first b');
        await fixture.event(const ChatStopGeneration(conversationId: 'a'),
            (s) => s.sessionFor('a')?.status == ChatStatus.stopped);
        final stopped = fixture.bloc.state.sessionFor('a')!;
        expect(stopped.errorMessage, isNull);
        expect(stopped.isBusy, isFalse);
        final assistant =
            stopped.conversation.messages.whereType<AssistantMessage>().single;
        expect(assistant.content, beforeHeaders ? '' : 'partial a');
        expect(assistant.isStreaming, isFalse);
        expect(fixture.storage.messages[assistant.id], assistant);
        expect(fixture.bloc.state.sessionFor('b')!.isStreaming, isTrue);
        await fixture.chunk('b', ' second b');
        await fixture.finish('b');
        expect(fixture.assistant('b').content, 'first b second b');
        expect(fixture.bloc.state.sessionFor('a')!.status, ChatStatus.stopped);
        expect(fixture.bloc.state.runningCount, 0);
      });
    }
  }
  for (final delete in [false, true]) {
    test(
        '${delete ? 'delete' : 'clear'} cancels HTTP and completes storage cleanup',
        () async {
      final fixture = await _Fixture.create(RemoteLlmApiType.openAiResponses);
      addTearDown(fixture.close);
      await fixture.start('a');
      await fixture.start('b');
      await fixture.chunk('a', 'partial');
      if (delete) {
        await fixture.event(const ChatDeleteConversation(id: 'a'),
            (s) => !s.sessions.containsKey('a'));
        expect(fixture.storage.conversations.containsKey('a'), isFalse);
      } else {
        await fixture.event(const ChatClearConversation(conversationId: 'a'),
            (s) => s.sessionFor('a')?.status == ChatStatus.ready);
        expect(
            fixture.bloc.state.sessionFor('a')!.conversation.messages, isEmpty);
        expect(fixture.storage.conversations.containsKey('a'), isTrue);
      }
      expect(await fixture.storage.loadMessages('a'), isEmpty);
      await fixture.chunk('b', 'survived');
      await fixture.finish('b');
      expect(fixture.assistant('b').content, 'survived');
      expect(await fixture.storage.loadMessages('a'), isEmpty);
      expect(fixture.bloc.state.runningCount, 0);
    });
  }
  test('close aborts both real HTTP generations and completes', () async {
    final fixture = await _Fixture.create(RemoteLlmApiType.openAiResponses);
    addTearDown(fixture.close);
    await fixture.start('a');
    await fixture.start('b');
    await fixture.chunk('a', 'partial');
    await fixture.bloc.close().timeout(_timeout);
    expect(fixture.bloc.isClosed, isTrue);
    await expectLater(
        fixture.remote
            .generateResponse([], fixture.config('after-close')).toList(),
        throwsStateError);
  });
  test('unexpected stream and storage errors remain visible', () async {
    final fixture =
        await _Fixture.create(RemoteLlmApiType.openAiChatCompletions);
    addTearDown(fixture.close);
    await fixture.start('a');
    final failed =
        fixture.wait((s) => s.sessionFor('a')?.status == ChatStatus.error);
    final response = await fixture.responseFor('a');
    response.write('data: invalid json\n\n');
    await response.flush();
    await failed;
    expect(fixture.bloc.state.sessionFor('a')!.errorMessage, isNotEmpty);
    await fixture.start('b');
    fixture.storage.failWrites = true;
    await fixture.event(const ChatStopGeneration(conversationId: 'b'),
        (s) => s.sessionFor('b')?.status == ChatStatus.error);
    expect(fixture.bloc.state.sessionFor('b')!.errorMessage,
        contains('storage unavailable'));
  });
}

class _Fixture {
  _Fixture(this.server, this.api) {
    remote = RemoteLlmRepository(vault: _UnusedVault());
    bloc = ChatBloc(
        gemmaRepository: GemmaRepository(),
        remoteRepository: remote,
        storageRepository: storage,
        toolExecutor: ToolExecutor());
    server.listen((request) async {
      final body = jsonDecode(await utf8.decoder.bind(request).join())
          as Map<String, dynamic>;
      request.response
        ..bufferOutput = false
        ..headers.contentType = ContentType('text', 'event-stream');
      _responses
          .putIfAbsent(body['model'] as String, Completer<HttpResponse>.new)
          .complete(request.response);
    });
  }
  final HttpServer server;
  final RemoteLlmApiType api;
  final storage = _Storage();
  final _responses = <String, Completer<HttpResponse>>{};
  late final RemoteLlmRepository remote;
  late final ChatBloc bloc;
  static Future<_Fixture> create(RemoteLlmApiType api) async =>
      _Fixture(await HttpServer.bind(InternetAddress.loopbackIPv4, 0), api);
  ModelConfig config(String id) => ModelConfig(
      inferenceMode: ChatInferenceMode.remote,
      remoteApiType: api,
      remoteAccountId: ModelConfig.dummyRemoteAccountId,
      remoteBaseUrl: 'http://127.0.0.1:${server.port}/v1',
      remoteModel: id);
  Future<HttpResponse> responseFor(String id) => _responses
      .putIfAbsent(id, Completer<HttpResponse>.new)
      .future
      .timeout(_timeout);
  Future<void> start(String id) async {
    await storage.saveConversation(Conversation.create(id: id));
    await event(ChatLoadConversation(id: id), (s) => s.conversation?.id == id);
    await event(
        ChatSendMessage(conversationId: id, content: id, config: config(id)),
        (s) => s.sessionFor(id)?.isStreaming ?? false);
    await responseFor(id);
  }

  AssistantMessage assistant(String id) => bloc.state
      .sessionFor(id)!
      .conversation
      .messages
      .whereType<AssistantMessage>()
      .last;
  void write(HttpResponse response, String text) {
    final body = switch (api) {
      RemoteLlmApiType.openAiResponses => {
          'type': 'response.output_text.delta',
          'delta': text
        },
      RemoteLlmApiType.anthropicMessages => {
          'type': 'content_block_delta',
          'delta': {'type': 'text_delta', 'text': text},
        },
      RemoteLlmApiType.openAiChatCompletions => {
          'choices': [
            {
              'delta': {'content': text}
            }
          ],
        },
    };
    response.write('data: ${jsonEncode(body)}\n\n');
  }

  Future<void> chunk(String id, String text) async {
    final previous = assistant(id).content;
    final received = wait((s) =>
        s
            .sessionFor(id)!
            .conversation
            .messages
            .whereType<AssistantMessage>()
            .last
            .content ==
        '$previous$text');
    final response = await responseFor(id);
    write(response, text);
    await response.flush();
    await received;
  }

  Future<void> finish(String id) async {
    final completed = wait((s) => s.sessionFor(id)?.status == ChatStatus.ready);
    final response = await responseFor(id);
    response.write('data: [DONE]\n\n');
    await response.close();
    await completed;
  }

  Future<ChatState> wait(bool Function(ChatState) predicate) =>
      bloc.stream.firstWhere(predicate).timeout(_timeout);
  Future<void> event(
      ChatEvent event, bool Function(ChatState) predicate) async {
    final result = wait(predicate);
    bloc.add(event);
    await result;
  }

  Future<void> close() async {
    if (!bloc.isClosed) await bloc.close();
    await remote.dispose();
    await server.close(force: true);
  }
}

class _UnusedVault implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Storage implements ChatStorageRepository {
  final conversations = <String, Conversation>{};
  final messages = <String, Message>{};
  bool failWrites = false;
  @override
  Future<ModelConfig> loadSettings() async => ModelConfig.defaultConfig;
  @override
  Future<void> saveConversation(Conversation conversation) async {
    if (failWrites) throw StateError('storage unavailable');
    conversations[conversation.id] = conversation.copyWith(messages: const []);
  }

  @override
  Future<void> saveMessage(Message message) async {
    if (failWrites) throw StateError('storage unavailable');
    messages[message.id] = message;
  }

  @override
  Future<void> deleteConversation(String id) async {
    conversations.remove(id);
    await clearConversationMessages(id);
  }

  @override
  Future<void> clearConversationMessages(String id) async =>
      messages.removeWhere((key, message) => message.conversationId == id);
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
