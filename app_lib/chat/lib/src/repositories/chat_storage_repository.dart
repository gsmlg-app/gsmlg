import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

import '../models/conversation.dart';
import '../models/inference.dart';
import '../models/message.dart';
import '../models/model_config.dart';

/// Repository for persisting chat data using Drift database.
class ChatStorageRepository {
  ChatStorageRepository(this._db);

  final AppDatabase _db;

  // ==========================================================================
  // Conversations
  // ==========================================================================

  /// Loads all conversations ordered by most recently updated.
  Future<List<Conversation>> loadConversations() async {
    final rows = await (_db.select(
      _db.chatConversationTable,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();

    return rows.map(_conversationFromRow).toList();
  }

  /// Loads a single conversation by ID, including all its messages.
  Future<Conversation?> loadConversation(String id) async {
    final row = await (_db.select(
      _db.chatConversationTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    if (row == null) return null;

    final messages = await loadMessages(id);
    return _conversationFromRow(row).copyWith(messages: messages);
  }

  /// Saves a new conversation or updates an existing one.
  Future<void> saveConversation(Conversation conversation) async {
    await _db
        .into(_db.chatConversationTable)
        .insertOnConflictUpdate(
          ChatConversationTableCompanion(
            id: Value(conversation.id),
            title: Value(conversation.title),
            systemPrompt: Value(conversation.systemPrompt),
            createdAt: Value(conversation.createdAt),
            updatedAt: Value(conversation.updatedAt),
          ),
        );
  }

  /// Updates only the conversation title.
  Future<void> updateConversationTitle(String id, String title) async {
    await (_db.update(
      _db.chatConversationTable,
    )..where((t) => t.id.equals(id))).write(
      ChatConversationTableCompanion(
        title: Value(title),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a conversation and all its messages.
  Future<void> deleteConversation(String id) async {
    await (_db.delete(
      _db.chatMessageTable,
    )..where((t) => t.conversationId.equals(id))).go();
    await (_db.delete(
      _db.chatConversationTable,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all conversations and messages.
  Future<void> deleteAllConversations() async {
    await _db.delete(_db.chatMessageTable).go();
    await _db.delete(_db.chatConversationTable).go();
  }

  // ==========================================================================
  // Messages
  // ==========================================================================

  /// Loads all messages for a conversation ordered by timestamp.
  Future<List<Message>> loadMessages(String conversationId) async {
    final rows =
        await (_db.select(_db.chatMessageTable)
              ..where((t) => t.conversationId.equals(conversationId))
              ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
            .get();

    return rows.map(_messageFromRow).toList();
  }

  /// Saves a new message or updates an existing one.
  Future<void> saveMessage(Message message) async {
    int? tokenCount;
    ChatResponseInfo? responseInfo;
    if (message is AssistantMessage) {
      tokenCount = message.tokenCount;
      responseInfo = message.responseInfo;
    }

    await _db
        .into(_db.chatMessageTable)
        .insertOnConflictUpdate(
          ChatMessageTableCompanion(
            id: Value(message.id),
            conversationId: Value(message.conversationId),
            role: Value(message.role),
            content: Value(message.content),
            tokenCount: Value(tokenCount),
            responseOutputTokens: Value(responseInfo?.outputTokens),
            responseContextTokens: Value(responseInfo?.contextTokens),
            responseMaxOutputTokens: Value(responseInfo?.maxOutputTokens),
            responseDurationMs: Value(responseInfo?.duration.inMilliseconds),
            imageBytes: Value(
              message is UserMessage ? message.imageBytes : null,
            ),
            toolName: Value(
              message is ToolResponseMessage ? message.toolName : null,
            ),
            timestamp: Value(message.timestamp),
          ),
        );

    // Update conversation's updatedAt
    await (_db.update(
      _db.chatConversationTable,
    )..where((t) => t.id.equals(message.conversationId))).write(
      ChatConversationTableCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  /// Updates the content of an existing message.
  Future<void> updateMessageContent(String id, String content) async {
    await (_db.update(_db.chatMessageTable)..where((t) => t.id.equals(id)))
        .write(ChatMessageTableCompanion(content: Value(content)));
  }

  /// Deletes a message by ID.
  Future<void> deleteMessage(String id) async {
    await (_db.delete(
      _db.chatMessageTable,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all messages in a conversation.
  Future<void> clearConversationMessages(String conversationId) async {
    await (_db.delete(
      _db.chatMessageTable,
    )..where((t) => t.conversationId.equals(conversationId))).go();
  }

  // ==========================================================================
  // Settings
  // ==========================================================================

  /// Loads the model configuration from the database.
  Future<ModelConfig> loadSettings() async {
    final row = await (_db.select(
      _db.chatSettingsTable,
    )..where((t) => t.key.equals('default'))).getSingleOrNull();

    if (row == null) {
      return ModelConfig.platformDefaultConfig;
    }

    return ModelConfig(
      inferenceMode: _parseInferenceMode(row.inferenceMode),
      modelType: _parseModelType(row.modelType),
      customModelPath: row.customModelPath,
      localModelId: row.localModelId,
      maxTokens: row.maxTokens,
      temperature: row.temperatureX100 / 100.0,
      topK: row.topK,
      backend: _parseBackend(row.backend),
      remoteProvider: _parseRemoteProvider(row.remoteProvider),
      remoteApiType: _parseRemoteApiType(
        row.remoteApiType,
        providerName: row.remoteProvider,
      ),
      remoteAccountId: row.remoteAccountId,
      remoteBaseUrl: row.remoteBaseUrl,
      remoteModel: row.remoteModel,
      remoteStreamingEnabled: row.remoteStreamingEnabled,
      remoteThinkingEffort: _parseRemoteThinkingEffort(
        row.remoteThinkingEffort,
      ),
    ).withSupportedBackendForCurrentPlatform();
  }

  /// Saves the model configuration to the database.
  Future<void> saveSettings(ModelConfig config) async {
    await _db
        .into(_db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            key: const Value('default'),
            inferenceMode: Value(_inferenceModeToString(config.inferenceMode)),
            modelType: Value(_modelTypeToString(config.modelType)),
            customModelPath: Value(config.customModelPath),
            localModelId: Value(config.localModelId),
            maxTokens: Value(config.maxTokens),
            temperatureX100: Value((config.temperature * 100).round()),
            topK: Value(config.topK),
            backend: Value(_backendToString(config.backend)),
            remoteProvider: Value(
              _remoteProviderToString(config.remoteProvider),
            ),
            remoteApiType: Value(_remoteApiTypeToString(config.remoteApiType)),
            remoteAccountId: Value(config.remoteAccountId),
            remoteBaseUrl: Value(config.remoteBaseUrl),
            remoteModel: Value(config.remoteModel),
            remoteStreamingEnabled: Value(config.remoteStreamingEnabled),
            remoteThinkingEffort: Value(
              _remoteThinkingEffortToString(config.remoteThinkingEffort),
            ),
          ),
        );
  }

  /// Loads the default system prompt from settings.
  Future<String?> loadDefaultSystemPrompt() async {
    final row = await (_db.select(
      _db.chatSettingsTable,
    )..where((t) => t.key.equals('default'))).getSingleOrNull();

    return row?.defaultSystemPrompt;
  }

  /// Saves the default system prompt to settings.
  Future<void> saveDefaultSystemPrompt(String? prompt) async {
    await _db
        .into(_db.chatSettingsTable)
        .insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            key: const Value('default'),
            defaultSystemPrompt: Value(prompt),
          ),
        );
  }

  // ==========================================================================
  // Helpers
  // ==========================================================================

  Conversation _conversationFromRow(ChatConversationTableData row) {
    return Conversation(
      id: row.id,
      title: row.title,
      systemPrompt: row.systemPrompt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Message _messageFromRow(ChatMessageTableData row) {
    return switch (row.role) {
      'user' => UserMessage(
        id: row.id,
        content: row.content,
        conversationId: row.conversationId,
        timestamp: row.timestamp,
        imageBytes: row.imageBytes,
      ),
      'assistant' => AssistantMessage(
        id: row.id,
        content: row.content,
        conversationId: row.conversationId,
        timestamp: row.timestamp,
        tokenCount: row.tokenCount,
        responseInfo: _responseInfoFromRow(row),
      ),
      'system' => SystemMessage(
        id: row.id,
        content: row.content,
        conversationId: row.conversationId,
        timestamp: row.timestamp,
      ),
      'tool_response' => ToolResponseMessage(
        id: row.id,
        content: row.content,
        conversationId: row.conversationId,
        timestamp: row.timestamp,
        toolName: row.toolName ?? 'unknown',
      ),
      _ => UserMessage(
        id: row.id,
        content: row.content,
        conversationId: row.conversationId,
        timestamp: row.timestamp,
      ),
    };
  }

  ChatResponseInfo? _responseInfoFromRow(ChatMessageTableData row) {
    final outputTokens = row.responseOutputTokens;
    final durationMs = row.responseDurationMs;
    if (outputTokens == null || durationMs == null) return null;

    return ChatResponseInfo(
      outputTokens: outputTokens,
      contextTokens: row.responseContextTokens,
      maxOutputTokens: row.responseMaxOutputTokens,
      duration: Duration(milliseconds: durationMs),
    );
  }

  GemmaModelType _parseModelType(String value) {
    return switch (value) {
      'gemma2bIt' => GemmaModelType.gemma2bIt,
      'gemma7bIt' => GemmaModelType.gemma7bIt,
      'custom' => GemmaModelType.custom,
      _ => GemmaModelType.gemma2bIt,
    };
  }

  ChatInferenceMode _parseInferenceMode(String value) {
    return switch (value) {
      'remote' => ChatInferenceMode.remote,
      _ => ChatInferenceMode.local,
    };
  }

  String _inferenceModeToString(ChatInferenceMode mode) {
    return switch (mode) {
      ChatInferenceMode.local => 'local',
      ChatInferenceMode.remote => 'remote',
    };
  }

  RemoteLlmProvider _parseRemoteProvider(String value) {
    return switch (value) {
      'openAiCompatible' => RemoteLlmProvider.openAiCompatible,
      'openAi' => RemoteLlmProvider.openAi,
      'anthropic' => RemoteLlmProvider.anthropic,
      'openRouter' => RemoteLlmProvider.openRouter,
      'groq' => RemoteLlmProvider.groq,
      'deepSeek' => RemoteLlmProvider.deepSeek,
      _ => RemoteLlmProvider.openAiCompatible,
    };
  }

  String _remoteProviderToString(RemoteLlmProvider provider) {
    return switch (provider) {
      RemoteLlmProvider.openAiCompatible => 'openAiCompatible',
      RemoteLlmProvider.openAi => 'openAi',
      RemoteLlmProvider.anthropic => 'anthropic',
      RemoteLlmProvider.openRouter => 'openRouter',
      RemoteLlmProvider.groq => 'groq',
      RemoteLlmProvider.deepSeek => 'deepSeek',
    };
  }

  RemoteLlmApiType _parseRemoteApiType(
    String value, {
    required String providerName,
  }) {
    return switch (value) {
      'openAiChatCompletions' => RemoteLlmApiType.openAiChatCompletions,
      'openAiResponses' => RemoteLlmApiType.openAiResponses,
      'anthropicMessages' => RemoteLlmApiType.anthropicMessages,
      _ => _parseRemoteProvider(providerName).defaultApiType,
    };
  }

  String _remoteApiTypeToString(RemoteLlmApiType apiType) {
    return switch (apiType) {
      RemoteLlmApiType.openAiChatCompletions => 'openAiChatCompletions',
      RemoteLlmApiType.openAiResponses => 'openAiResponses',
      RemoteLlmApiType.anthropicMessages => 'anthropicMessages',
    };
  }

  RemoteThinkingEffort _parseRemoteThinkingEffort(String value) {
    return switch (value) {
      'high' => RemoteThinkingEffort.high,
      'max' => RemoteThinkingEffort.max,
      _ => RemoteThinkingEffort.off,
    };
  }

  String _remoteThinkingEffortToString(RemoteThinkingEffort effort) {
    return switch (effort) {
      RemoteThinkingEffort.off => 'off',
      RemoteThinkingEffort.high => 'high',
      RemoteThinkingEffort.max => 'max',
    };
  }

  String _modelTypeToString(GemmaModelType type) {
    return switch (type) {
      GemmaModelType.gemma2bIt => 'gemma2bIt',
      GemmaModelType.gemma7bIt => 'gemma7bIt',
      GemmaModelType.custom => 'custom',
    };
  }

  GemmaBackend _parseBackend(String value) {
    final backend = switch (value) {
      'cpu' => GemmaBackend.cpu,
      'metal' || 'gpu' => GemmaBackend.metal,
      'cuda' => GemmaBackend.cuda,
      'vulkan' => GemmaBackend.vulkan,
      _ => defaultGemmaBackendForCurrentPlatform(),
    };
    return backend.isSupportedOnCurrentPlatform
        ? backend
        : defaultGemmaBackendForCurrentPlatform();
  }

  String _backendToString(GemmaBackend backend) {
    return backend.name;
  }
}
