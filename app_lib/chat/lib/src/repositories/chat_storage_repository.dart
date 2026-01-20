import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

import '../models/conversation.dart';
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
    final rows = await (_db.select(_db.chatConversationTable)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    return rows.map(_conversationFromRow).toList();
  }

  /// Loads a single conversation by ID, including all its messages.
  Future<Conversation?> loadConversation(String id) async {
    final row = await (_db.select(_db.chatConversationTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (row == null) return null;

    final messages = await loadMessages(id);
    return _conversationFromRow(row).copyWith(messages: messages);
  }

  /// Saves a new conversation or updates an existing one.
  Future<void> saveConversation(Conversation conversation) async {
    await _db.into(_db.chatConversationTable).insertOnConflictUpdate(
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
    await (_db.update(_db.chatConversationTable)
          ..where((t) => t.id.equals(id)))
        .write(ChatConversationTableCompanion(
          title: Value(title),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Deletes a conversation and all its messages.
  Future<void> deleteConversation(String id) async {
    await (_db.delete(_db.chatMessageTable)
          ..where((t) => t.conversationId.equals(id)))
        .go();
    await (_db.delete(_db.chatConversationTable)
          ..where((t) => t.id.equals(id)))
        .go();
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
    final rows = await (_db.select(_db.chatMessageTable)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();

    return rows.map(_messageFromRow).toList();
  }

  /// Saves a new message or updates an existing one.
  Future<void> saveMessage(Message message) async {
    int? tokenCount;
    if (message is AssistantMessage) {
      tokenCount = message.tokenCount;
    }

    await _db.into(_db.chatMessageTable).insertOnConflictUpdate(
          ChatMessageTableCompanion(
            id: Value(message.id),
            conversationId: Value(message.conversationId),
            role: Value(message.role),
            content: Value(message.content),
            tokenCount: Value(tokenCount),
            timestamp: Value(message.timestamp),
          ),
        );

    // Update conversation's updatedAt
    await (_db.update(_db.chatConversationTable)
          ..where((t) => t.id.equals(message.conversationId)))
        .write(ChatConversationTableCompanion(
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Updates the content of an existing message.
  Future<void> updateMessageContent(String id, String content) async {
    await (_db.update(_db.chatMessageTable)..where((t) => t.id.equals(id)))
        .write(ChatMessageTableCompanion(content: Value(content)));
  }

  /// Deletes a message by ID.
  Future<void> deleteMessage(String id) async {
    await (_db.delete(_db.chatMessageTable)..where((t) => t.id.equals(id)))
        .go();
  }

  /// Deletes all messages in a conversation.
  Future<void> clearConversationMessages(String conversationId) async {
    await (_db.delete(_db.chatMessageTable)
          ..where((t) => t.conversationId.equals(conversationId)))
        .go();
  }

  // ==========================================================================
  // Settings
  // ==========================================================================

  /// Loads the model configuration from the database.
  Future<ModelConfig> loadSettings() async {
    final row = await (_db.select(_db.chatSettingsTable)
          ..where((t) => t.key.equals('default')))
        .getSingleOrNull();

    if (row == null) {
      return ModelConfig.defaultConfig;
    }

    return ModelConfig(
      modelType: _parseModelType(row.modelType),
      customModelPath: row.customModelPath,
      maxTokens: row.maxTokens,
      temperature: row.temperatureX100 / 100.0,
      topK: row.topK,
      backend: _parseBackend(row.backend),
    );
  }

  /// Saves the model configuration to the database.
  Future<void> saveSettings(ModelConfig config) async {
    await _db.into(_db.chatSettingsTable).insertOnConflictUpdate(
          ChatSettingsTableCompanion(
            key: const Value('default'),
            modelType: Value(_modelTypeToString(config.modelType)),
            customModelPath: Value(config.customModelPath),
            maxTokens: Value(config.maxTokens),
            temperatureX100: Value((config.temperature * 100).round()),
            topK: Value(config.topK),
            backend: Value(_backendToString(config.backend)),
          ),
        );
  }

  /// Loads the default system prompt from settings.
  Future<String?> loadDefaultSystemPrompt() async {
    final row = await (_db.select(_db.chatSettingsTable)
          ..where((t) => t.key.equals('default')))
        .getSingleOrNull();

    return row?.defaultSystemPrompt;
  }

  /// Saves the default system prompt to settings.
  Future<void> saveDefaultSystemPrompt(String? prompt) async {
    await _db.into(_db.chatSettingsTable).insertOnConflictUpdate(
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
        ),
      'assistant' => AssistantMessage(
          id: row.id,
          content: row.content,
          conversationId: row.conversationId,
          timestamp: row.timestamp,
          tokenCount: row.tokenCount,
        ),
      'system' => SystemMessage(
          id: row.id,
          content: row.content,
          conversationId: row.conversationId,
          timestamp: row.timestamp,
        ),
      _ => UserMessage(
          id: row.id,
          content: row.content,
          conversationId: row.conversationId,
          timestamp: row.timestamp,
        ),
    };
  }

  GemmaModelType _parseModelType(String value) {
    return switch (value) {
      'gemma2bIt' => GemmaModelType.gemma2bIt,
      'gemma7bIt' => GemmaModelType.gemma7bIt,
      'custom' => GemmaModelType.custom,
      _ => GemmaModelType.gemma2bIt,
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
    return switch (value) {
      'gpu' => GemmaBackend.gpu,
      'cpu' => GemmaBackend.cpu,
      _ => GemmaBackend.gpu,
    };
  }

  String _backendToString(GemmaBackend backend) {
    return switch (backend) {
      GemmaBackend.gpu => 'gpu',
      GemmaBackend.cpu => 'cpu',
    };
  }
}
