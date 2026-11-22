import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists assistant response info with chat messages', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    final repository = ChatStorageRepository(database);
    await repository.saveConversation(
      Conversation.create(id: 'conversation-1'),
    );

    const responseInfo = ChatResponseInfo(
      outputTokens: 42,
      contextTokens: 512,
      maxOutputTokens: 2048,
      duration: Duration(milliseconds: 2000),
      timeToFirstToken: Duration(milliseconds: 500),
    );
    final message = AssistantMessage(
      id: 'message-1',
      content: 'done',
      conversationId: 'conversation-1',
      timestamp: DateTime(2026, 5, 13, 10),
      tokenCount: 42,
      responseInfo: responseInfo,
    );

    await repository.saveMessage(message);

    final messages = await repository.loadMessages('conversation-1');
    final restored = messages.single as AssistantMessage;
    expect(restored.responseInfo, responseInfo);
    expect(restored.responseInfo?.tokensPerSecond, 28);
    final row = await database.select(database.chatMessageTable).getSingle();
    expect(row.responseTimeToFirstTokenMs, 500);
  });

  test(
    'roundtrips unknown first-token latency and absent response info',
    () async {
      final database = AppDatabase.forTesting();
      addTearDown(database.close);
      final repository = ChatStorageRepository(database);
      await repository.saveConversation(Conversation.create(id: 'history'));
      for (final info in [
        const ChatResponseInfo(
          outputTokens: 42,
          duration: Duration(seconds: 2),
        ),
        null,
      ]) {
        await repository.saveMessage(
          AssistantMessage(
            id: 'legacy',
            content: 'history',
            conversationId: 'history',
            timestamp: DateTime(2026),
            responseInfo: info,
          ),
        );
        final restored =
            (await repository.loadMessages('history')).single
                as AssistantMessage;
        expect(restored.responseInfo, info);
        expect(restored.responseInfo?.timeToFirstToken, isNull);
        expect(
          (await database.select(database.chatMessageTable).getSingle())
              .responseTimeToFirstTokenMs,
          isNull,
        );
      }
    },
  );

  test(
    'persists remote API type and thinking effort with chat settings',
    () async {
      final database = AppDatabase.forTesting();
      addTearDown(database.close);

      final repository = ChatStorageRepository(database);
      const config = ModelConfig(
        inferenceMode: ChatInferenceMode.remote,
        remoteProvider: RemoteLlmProvider.deepSeek,
        remoteApiType: RemoteLlmApiType.anthropicMessages,
        remoteAccountId: ModelConfig.dummyRemoteAccountId,
        remoteBaseUrl: 'https://api.deepseek.com/v1',
        remoteModel: 'deepseek-v4-pro',
        remoteAuthType: RemoteAuthType.customHeader,
        remoteAuthHeaderName: 'X-DeepSeek-Key',
        remoteThinkingEffort: RemoteThinkingEffort.max,
      );

      await repository.saveSettings(config);

      expect(await repository.loadSettings(), config);
    },
  );

  test('persists llama.cpp backend with chat settings', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    final repository = ChatStorageRepository(database);
    final backend = supportedGemmaBackendsForCurrentPlatform().last;
    final config = ModelConfig(backend: backend);

    await repository.saveSettings(config);

    expect((await repository.loadSettings()).backend, backend);
  });

  test('maps legacy gpu backend setting to Metal', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);

    await database
        .into(database.chatSettingsTable)
        .insert(
          const ChatSettingsTableCompanion(
            key: Value('default'),
            backend: Value('gpu'),
          ),
        );

    final repository = ChatStorageRepository(database);

    expect(
      (await repository.loadSettings()).backend,
      defaultGemmaBackendForCurrentPlatform(),
    );
  });

  test(
    'persists user message image and file attachments across reloads',
    () async {
      final database = AppDatabase.forTesting();
      addTearDown(database.close);

      final repository = ChatStorageRepository(database);
      await repository.saveConversation(Conversation.create(id: 'conv-att'));

      final pngBytes = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x42,
        0x99,
      ]);
      final pdfBytes = Uint8List.fromList('%PDF-1.4\nhello'.codeUnits);

      final original = UserMessage(
        id: 'user-att-1',
        content: 'Check these files',
        conversationId: 'conv-att',
        timestamp: DateTime(2026, 5, 13, 12),
        attachments: [
          ChatAttachment(
            id: 'att-img',
            name: 'screenshot.png',
            mimeType: 'image/png',
            sizeBytes: pngBytes.length,
            bytes: pngBytes,
          ),
          ChatAttachment(
            id: 'att-pdf',
            name: 'spec.pdf',
            mimeType: 'application/pdf',
            sizeBytes: pdfBytes.length,
            bytes: pdfBytes,
          ),
        ],
      );

      await repository.saveMessage(original);

      final loaded = await repository.loadMessages('conv-att');
      final restored = loaded.single as UserMessage;
      expect(restored.imageBytes, pngBytes);
      expect(restored.attachments, hasLength(2));
      expect(restored.attachments[0].id, 'att-img');
      expect(restored.attachments[0].name, 'screenshot.png');
      expect(restored.attachments[0].mimeType, 'image/png');
      expect(restored.attachments[0].bytes, pngBytes);
      expect(restored.attachments[1].id, 'att-pdf');
      expect(restored.attachments[1].name, 'spec.pdf');
      expect(restored.attachments[1].mimeType, 'application/pdf');
      expect(restored.attachments[1].bytes, pdfBytes);
      expect(restored.inlineImages, hasLength(1));
      expect(restored.inlineImages.single.bytes, pngBytes);
      expect(restored.inlineImages.single.mimeType, 'image/png');
    },
  );
}
