import 'dart:async';
import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized().handleAppLifecycleStateChanged(
    AppLifecycleState.resumed,
  );
  test(
    'fallback is immediate; successful response asynchronously updates current and history titles',
    () async {
      final f = Fixture();
      addTearDown(f.close);
      await f.start();
      expect(f.bloc.state.conversation!.title, 'Flutter controller design');
      expect(
        (await f.storage.loadConversation(f.id))!.title,
        'Flutter controller design',
      );
      expect(f.titles.calls, 0);
      await f.finish();
      await eventually(() => f.titles.calls == 1);
      expect(f.bloc.state.status, ChatStatus.ready);
      f.titles.pending.complete('Flutter Controller Architecture');
      await eventually(
        () =>
            f.bloc.state.conversation?.title ==
            'Flutter Controller Architecture',
      );
      expect(
        f.bloc.state.conversationHistory.single.title,
        'Flutter Controller Architecture',
      );
      expect(
        (await f.storage.loadConversation(f.id))!.title,
        'Flutter Controller Architecture',
      );
    },
  );
  for (final failed in [false, true]) {
    test(
      'stopped or failed response does not generate: failed=$failed',
      () async {
        final f = Fixture();
        addTearDown(f.close);
        await f.start();
        if (failed) {
          f.remote.controller.addError(StateError('failure'));
        } else {
          f.bloc.add(const ChatStopGeneration());
        }
        await eventually(() => !f.bloc.state.isBusy);
        expect(f.titles.calls, 0);
        expect(
          (await f.storage.loadMessages(
            f.id,
          )).whereType<AssistantMessage>().single.completedSuccessfully,
          isFalse,
        );
      },
    );
  }
  test('explicit manual title is preserved on first message', () async {
    final f = Fixture();
    addTearDown(f.close);
    f.bloc.add(const ChatNewConversation(title: 'My project'));
    await eventually(() => f.bloc.state.conversation != null);
    await f.start();
    await f.finish();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(f.titles.calls, 0);
    expect(f.bloc.state.conversation!.title, 'My project');
  });
  test('navigation keeps result attached to its source conversation', () async {
    final f = Fixture();
    addTearDown(f.close);
    await f.start();
    await f.finish();
    final original = f.id;
    await eventually(() => f.titles.calls == 1);
    f.bloc.add(const ChatNewConversation(title: 'Other'));
    await eventually(() => f.id != original);
    f.titles.pending.complete('Flutter Controller Architecture');
    await eventually(
      () => f.bloc.state.conversationHistory.any(
        (c) => c.id == original && c.title == 'Flutter Controller Architecture',
      ),
    );
    expect(f.bloc.state.conversation!.title, 'Other');
  });
  test('deleted conversations reject delayed results', () async {
    final f = Fixture();
    addTearDown(f.close);
    await f.start();
    await f.finish();
    final original = f.id;
    await eventually(() => f.titles.calls == 1);
    f.bloc.add(ChatDeleteConversation(id: original));
    await eventually(() => f.bloc.state.conversation == null);
    f.titles.pending.complete('Delayed title');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await f.storage.loadConversation(original), isNull);
  });
  test('manual rename rejects an in-flight automatic result', () async {
    final f = Fixture();
    addTearDown(f.close);
    await f.start();
    await f.finish();
    await eventually(() => f.titles.calls == 1);
    f.bloc.add(ChatRenameConversation(id: f.id, title: 'My title.'));
    await eventually(() => f.bloc.state.conversation!.title == 'My title.');
    f.titles.pending.complete('Stale title');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect((await f.storage.loadConversation(f.id))!.title, 'My title.');
  });
  test('inference failure leaves successful chat intact', () async {
    final f = Fixture();
    addTearDown(f.close);
    await f.start();
    await f.finish();
    await eventually(() => f.titles.calls == 1);
    f.titles.pending.completeError(StateError('OOM'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(f.bloc.state.status, ChatStatus.ready);
    expect(f.bloc.state.conversation!.title, 'Flutter controller design');
  });
  test(
    'local chat model remains loaded and receives no title prompts',
    () async {
      final f = Fixture();
      addTearDown(f.close);
      await f.start(local: true);
      await f.finish(local: true);
      await eventually(() => f.titles.calls == 1);
      f.titles.pending.complete('Flutter Controller Architecture');
      await eventually(
        () =>
            f.bloc.state.conversation!.title ==
            'Flutter Controller Architecture',
      );
      expect(f.gemma.generations, 1);
      expect(f.gemma.unloads, 0);
      expect(f.gemma.isReady, isTrue);
    },
  );
  test(
    'unchanged refinement avoids title writes; changed topics update at the next interval',
    () async {
      final f = Fixture();
      addTearDown(f.close);
      await f.start();
      await f.finish();
      await eventually(() => f.titles.calls == 1);
      f.titles.pending.complete('Flutter Controller Architecture');
      await eventually(
        () =>
            f.bloc.state.conversation!.title ==
            'Flutter Controller Architecture',
      );
      final revision = (await f.storage.loadConversation(f.id))!.titleRevision;
      for (var i = 0; i < 3; i++) {
        await f.start();
        await f.finish();
      }
      await eventually(() => f.titles.calls == 2);
      f.titles.pending.complete('Flutter Controller Architecture');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect((await f.storage.loadConversation(f.id))!.titleRevision, revision);
      for (var i = 0; i < 3; i++) {
        await f.start(content: 'SSH handshake failures');
        await f.finish();
      }
      await eventually(() => f.titles.calls == 3);
      f.titles.pending.complete('SSH Key Exchange Debugging');
      await eventually(
        () => f.bloc.state.conversation!.title == 'SSH Key Exchange Debugging',
      );
    },
  );
  test(
    'clear rejects an in-flight title without recreating messages',
    () async {
      final f = Fixture();
      addTearDown(f.close);
      await f.start();
      await f.finish();
      await eventually(() => f.titles.calls == 1);
      f.bloc.add(const ChatClearConversation());
      await eventually(() => f.bloc.state.messages.isEmpty);
      f.titles.pending.complete('Stale title');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect((await f.storage.loadConversation(f.id))!.messages, isEmpty);
      expect(f.bloc.state.conversation!.title, isNot('Stale title'));
    },
  );
  for (final edit in [true, false]) {
    test('editing or regenerating discards stale title: edit=$edit', () async {
      final f = Fixture();
      addTearDown(f.close);
      await f.start();
      await f.finish();
      await eventually(() => f.titles.calls == 1);
      final stale = f.titles.pending;
      if (edit) {
        f.bloc.add(
          ChatEditUserMessage(
            messageId: f.bloc.state.messages.whereType<UserMessage>().first.id,
            content: 'SSH handshake failures',
          ),
        );
      } else {
        f.bloc.add(const ChatRegenerateResponse());
      }
      await eventually(() => f.bloc.state.status == ChatStatus.streaming);
      stale.complete('Obsolete Flutter Title');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(
        (await f.storage.loadConversation(f.id))!.title,
        isNot('Obsolete Flutter Title'),
      );
      await f.finish();
      await eventually(() => f.titles.calls == 2);
      f.titles.pending.complete('Fresh Topic Title');
      await eventually(
        () => f.bloc.state.conversation!.title == 'Fresh Topic Title',
      );
    });
  }
  test('backgrounding discards an active result', () async {
    final f = Fixture();
    addTearDown(f.close);
    await f.start();
    await f.finish();
    await eventually(() => f.titles.calls == 1);
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.hidden,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    f.titles.pending.complete('Background result');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(f.bloc.state.conversation!.title, isNot('Background result'));
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.hidden,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await eventually(() => f.titles.calls == 2);
    f.titles.pending.complete('Resumed Title');
    await eventually(() => f.bloc.state.conversation!.title == 'Resumed Title');
  });
}

Future<void> eventually(bool Function() predicate) async {
  final end = DateTime.now().add(const Duration(seconds: 5));
  while (!predicate()) {
    if (DateTime.now().isAfter(end)) {
      throw TimeoutException('Condition not met');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

class Fixture {
  Fixture() {
    storage = ChatStorageRepository(db);
    bloc = ChatBloc(
      gemmaRepository: gemma,
      remoteRepository: remote,
      storageRepository: storage,
      toolExecutor: ToolExecutor(),
      titleGenerator: titles,
    );
  }
  final db = AppDatabase.forTesting();
  final remote = Remote();
  final gemma = Local();
  final titles = Titles();
  late final ChatStorageRepository storage;
  late final ChatBloc bloc;
  String get id => bloc.state.conversation!.id;
  Future<void> start({
    bool local = false,
    String content = 'Flutter controller design',
  }) async {
    bloc.add(
      ChatSendMessage(
        content: content,
        config: ModelConfig(
          remoteAccountId: 1,
          inferenceMode: local
              ? ChatInferenceMode.local
              : ChatInferenceMode.remote,
        ),
      ),
    );
    await eventually(() => bloc.state.status == ChatStatus.streaming);
  }

  Future<void> finish({bool local = false}) async {
    final controller = local ? gemma.controller : remote.controller;
    controller.add(const ChatTextChunk('Use a reusable Flutter controller'));
    await controller.close();
    await eventually(() => bloc.state.status == ChatStatus.ready);
  }

  Future<void> close() async {
    if (titles.calls > 0 && !titles.pending.isCompleted) {
      titles.pending.complete(null);
    }
    await bloc.close();
    await db.close();
    await remote.dispose();
    await gemma.dispose();
  }
}

class Titles implements ConversationTitleGenerator {
  int calls = 0;
  late Completer<String?> pending;
  @override
  Future<String?> generate(Conversation c) {
    calls++;
    pending = Completer<String?>();
    return pending.future;
  }

  // Deliberately ignores cancellation to exercise caller stale-result guards.
  @override
  Future<void> cancel() async {}
  @override
  Future<void> dispose() async {}
}

class Remote implements RemoteLlmRepository {
  var controller = StreamController<ChatGenerationChunk>.broadcast();
  @override
  Future<bool> isReady(ModelConfig config) async => true;
  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages,
    ModelConfig config, {
    List<Map<String, dynamic>> tools = const [],
    String? generationId,
  }) {
    if (controller.isClosed) {
      controller = StreamController<ChatGenerationChunk>.broadcast();
    }
    return controller.stream;
  }

  @override
  Future<void> stopGeneration({String? generationId}) async {}
  @override
  Future<void> dispose() async {
    if (!controller.isClosed) await controller.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Local extends GemmaRepository {
  var controller = StreamController<ChatGenerationChunk>.broadcast();
  int generations = 0;
  int unloads = 0;
  @override
  bool get isReady => true;
  @override
  Stream<ChatGenerationChunk> generateResponse(
    List<Message> messages, {
    List<Map<String, dynamic>> tools = const [],
    ModelConfig? config,
  }) {
    generations++;
    return controller.stream;
  }

  @override
  Future<void> unloadModel() async {
    unloads++;
  }

  @override
  Future<void> stopGeneration() async {}
  @override
  Future<void> dispose() async {
    if (!controller.isClosed) await controller.close();
  }
}
