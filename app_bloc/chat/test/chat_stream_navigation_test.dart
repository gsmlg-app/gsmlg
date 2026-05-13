import 'dart:async';

import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps streaming tokens attached to their original conversation',
      () async {
    final gemmaRepository = _FakeGemmaRepository();
    final storageRepository = _FakeChatStorageRepository();
    final bloc = ChatBloc(
      gemmaRepository: gemmaRepository,
      remoteRepository: _FakeRemoteLlmRepository(),
      storageRepository: storageRepository,
      toolExecutor: ToolExecutor(),
    );
    addTearDown(bloc.close);
    addTearDown(gemmaRepository.dispose);

    await storageRepository.saveConversation(_conversation('conversation-a'));
    await storageRepository.saveConversation(_conversation('conversation-b'));

    bloc.add(const ChatLoadConversation(id: 'conversation-a'));
    await _flushBloc();
    bloc.add(const ChatSendMessage(content: 'write something'));
    await _flushBloc();

    bloc.add(const ChatLoadConversation(id: 'conversation-b'));
    await _flushBloc();
    expect(bloc.state.conversation?.id, 'conversation-b');

    gemmaRepository.emitText('generated for a');
    await _flushBloc();

    expect(bloc.state.conversation?.id, 'conversation-b');
    expect(bloc.state.conversation?.messages, isEmpty);

    await gemmaRepository.complete();
    await _flushBloc();

    final conversationA =
        await storageRepository.loadConversation('conversation-a');
    final conversationB =
        await storageRepository.loadConversation('conversation-b');
    final assistant =
        conversationA!.messages.whereType<AssistantMessage>().single;

    expect(assistant.content, 'generated for a');
    expect(assistant.isStreaming, isFalse);
    expect(conversationB?.messages, isEmpty);
    expect(bloc.state.conversation?.id, 'conversation-b');
  });
}

Conversation _conversation(String id) {
  return Conversation(
    id: id,
    title: id,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

Future<void> _flushBloc() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeGemmaRepository extends GemmaRepository {
  final _controller = StreamController<ChatGenerationChunk>();

  @override
  bool get isReady => true;

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages, {
    List<Map<String, dynamic>> tools = const [],
  }) {
    return _controller.stream;
  }

  void emitText(String text) {
    _controller.add(ChatTextChunk(text));
  }

  Future<void> complete() async {
    await _controller.close();
  }

  @override
  Future<void> dispose() async {
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}

class _FakeRemoteLlmRepository implements RemoteLlmRepository {
  @override
  Future<bool> isReady(ModelConfig config) async => true;

  @override
  Future<List<String>> listModels(ModelConfig config) async => const [];

  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
  }) {
    return const Stream.empty();
  }

  @override
  Future<void> stopGeneration() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeChatStorageRepository implements ChatStorageRepository {
  final _conversations = <String, Conversation>{};
  final _messages = <String, List<Message>>{};
  ModelConfig _settings = ModelConfig.defaultConfig;
  String? _defaultSystemPrompt;

  @override
  Future<List<Conversation>> loadConversations() async {
    return _conversations.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Conversation?> loadConversation(String id) async {
    final conversation = _conversations[id];
    if (conversation == null) return null;
    return conversation.copyWith(messages: await loadMessages(id));
  }

  @override
  Future<void> saveConversation(Conversation conversation) async {
    _conversations[conversation.id] = conversation.copyWith(messages: const []);
  }

  @override
  Future<void> updateConversationTitle(String id, String title) async {
    final conversation = _conversations[id];
    if (conversation == null) return;
    _conversations[id] = conversation.copyWith(
      title: title,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteConversation(String id) async {
    _conversations.remove(id);
    _messages.remove(id);
  }

  @override
  Future<void> deleteAllConversations() async {
    _conversations.clear();
    _messages.clear();
  }

  @override
  Future<List<Message>> loadMessages(String conversationId) async {
    return [...?_messages[conversationId]]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<void> saveMessage(Message message) async {
    final messages = _messages.putIfAbsent(message.conversationId, () => []);
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
  }

  @override
  Future<void> updateMessageContent(String id, String content) async {
    for (final messages in _messages.values) {
      final index = messages.indexWhere((message) => message.id == id);
      if (index == -1) continue;
      final message = messages[index];
      messages[index] = switch (message) {
        final UserMessage user => user.copyWith(content: content),
        final AssistantMessage assistant =>
          assistant.copyWith(content: content),
        final SystemMessage system => system.copyWith(content: content),
        final ToolResponseMessage tool => tool.copyWith(content: content),
      };
      return;
    }
  }

  @override
  Future<void> deleteMessage(String id) async {
    for (final messages in _messages.values) {
      messages.removeWhere((message) => message.id == id);
    }
  }

  @override
  Future<void> clearConversationMessages(String conversationId) async {
    _messages.remove(conversationId);
  }

  @override
  Future<ModelConfig> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(ModelConfig config) async {
    _settings = config;
  }

  @override
  Future<String?> loadDefaultSystemPrompt() async => _defaultSystemPrompt;

  @override
  Future<void> saveDefaultSystemPrompt(String? prompt) async {
    _defaultSystemPrompt = prompt;
  }
}
