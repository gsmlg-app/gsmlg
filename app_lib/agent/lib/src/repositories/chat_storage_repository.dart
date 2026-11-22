import 'dart:convert';

import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart';

import '../models/agent_metadata.dart';
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
  /// When [agentId] is given, only that agent's conversations are returned.
  Future<List<Conversation>> loadConversations({String? agentId}) async {
    final rows =
        await (_db.select(_db.chatConversationTable)
              ..where(
                (t) => agentId == null
                    ? const Constant(true)
                    : t.agentId.equals(agentId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();

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
    await _db.transaction(() async {
      await _db
          .into(_db.chatConversationTable)
          .insert(
            ChatConversationTableCompanion(
              id: Value(conversation.id),
              title: Value(conversation.title),
              titleSource: Value(conversation.titleSource),
              systemPrompt: Value(conversation.systemPrompt),
              agentId: Value(conversation.agentId),
              createdAt: Value(conversation.createdAt),
              updatedAt: Value(conversation.updatedAt),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      // Persist immediate fallbacks, but never replace generated/manual titles.
      if (conversation.titleSource == 'fallback') {
        await (_db.update(_db.chatConversationTable)..where(
              (t) =>
                  t.id.equals(conversation.id) &
                  t.titleSource.equals('fallback') &
                  t.titleRevision.equals(0),
            ))
            .write(
              ChatConversationTableCompanion(title: Value(conversation.title)),
            );
      }
      // Existing generated/manual titles belong exclusively to conditional title updates.
      await (_db.update(
        _db.chatConversationTable,
      )..where((t) => t.id.equals(conversation.id))).write(
        ChatConversationTableCompanion(
          systemPrompt: Value(conversation.systemPrompt),
          updatedAt: Value(conversation.updatedAt),
        ),
      );
      // An unowned (legacy) conversation is claimed once; an existing owner
      // is never replaced.
      if (conversation.agentId != null) {
        await (_db.update(_db.chatConversationTable)
              ..where((t) => t.id.equals(conversation.id) & t.agentId.isNull()))
            .write(
              ChatConversationTableCompanion(
                agentId: Value(conversation.agentId),
              ),
            );
      }
    });
  }

  /// Manual title writes do not change activity ordering.
  Future<void> updateConversationTitle(String id, String title) async {
    await _db.customUpdate(
      "UPDATE chat_conversation_table SET title = ?, title_source = 'manual', title_revision = title_revision + 1 WHERE id = ?",
      variables: [Variable.withString(title), Variable.withString(id)],
      updates: {_db.chatConversationTable},
    );
  }

  /// Never inserts, and rejects changed content or manually managed titles.
  Future<bool> updateAutomaticTitle(Conversation snapshot, String title) async {
    if (!snapshot.hasAutomaticTitle || snapshot.title == title) return false;
    final changed = await _db.customUpdate(
      "UPDATE chat_conversation_table SET title = ?, title_source = 'generated', title_revision = title_revision + 1 "
      "WHERE id = ? AND content_revision = ? AND title_revision = ? AND title_source IN ('fallback', 'generated') AND title != ?",
      variables: [
        Variable.withString(title),
        Variable.withString(snapshot.id),
        Variable.withInt(snapshot.contentRevision),
        Variable.withInt(snapshot.titleRevision),
        Variable.withString(title),
      ],
      updates: {_db.chatConversationTable},
    );
    return changed == 1;
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
    Uint8List? primaryImageBytes;
    String? metadata;
    if (message is AssistantMessage) {
      tokenCount = message.tokenCount;
      responseInfo = message.responseInfo;
      metadata = message.agentMetadata;
    } else if (message is ToolResponseMessage) {
      metadata = message.agentMetadata;
    } else if (message is UserMessage) {
      primaryImageBytes =
          message.imageBytes ?? message.inlineImages.firstOrNull?.bytes;
      metadata = _encodeUserAttachments(message.attachments, primaryImageBytes);
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
            completedSuccessfully: Value(
              message is AssistantMessage &&
                  message.completedSuccessfully &&
                  !message.isStreaming,
            ),
            responseOutputTokens: Value(responseInfo?.outputTokens),
            responseContextTokens: Value(responseInfo?.contextTokens),
            responseMaxOutputTokens: Value(responseInfo?.maxOutputTokens),
            responseDurationMs: Value(responseInfo?.duration.inMilliseconds),
            responseTimeToFirstTokenMs: Value(
              responseInfo?.timeToFirstToken?.inMilliseconds,
            ),
            imageBytes: Value(primaryImageBytes),
            toolName: Value(
              message is ToolResponseMessage ? message.toolName : null,
            ),
            agentMetadata: Value(metadata),
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
      remoteAuthType: _parseRemoteAuthType(row.remoteAuthType),
      remoteAuthHeaderName: row.remoteAuthHeaderName,
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
            remoteAuthType: Value(
              _remoteAuthTypeToString(config.remoteAuthType),
            ),
            remoteAuthHeaderName: Value(config.remoteAuthHeaderName),
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
      titleSource: row.titleSource,
      titleRevision: row.titleRevision,
      contentRevision: row.contentRevision,
      systemPrompt: row.systemPrompt,
      agentId: row.agentId,
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
        attachments: _decodeUserAttachments(row.agentMetadata, row.imageBytes),
      ),
      'assistant' => () {
        final meta = AgentMessageMetadata.decode(row.agentMetadata);
        return AssistantMessage(
          completedSuccessfully: row.completedSuccessfully,
          id: row.id,
          content: row.content,
          conversationId: row.conversationId,
          timestamp: row.timestamp,
          tokenCount: row.tokenCount,
          thinkingContent: meta?.thought,
          responseInfo: _responseInfoFromRow(row),
          agentMetadata: row.agentMetadata,
        );
      }(),
      'system' => SystemMessage(
        id: row.id,
        content: row.content,
        conversationId: row.conversationId,
        timestamp: row.timestamp,
      ),
      'tool_response' => () {
        final meta = AgentMessageMetadata.decode(row.agentMetadata);
        return ToolResponseMessage(
          id: row.id,
          content: row.content,
          conversationId: row.conversationId,
          timestamp: row.timestamp,
          toolName: row.toolName ?? meta?.toolName ?? 'unknown',
          toolCallId: meta?.toolCallId,
          isError: meta?.isError ?? false,
          agentMetadata: row.agentMetadata,
        );
      }(),
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
      timeToFirstToken: row.responseTimeToFirstTokenMs == null
          ? null
          : Duration(milliseconds: row.responseTimeToFirstTokenMs!),
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

  RemoteAuthType _parseRemoteAuthType(String value) {
    return switch (value) {
      'bearerToken' => RemoteAuthType.bearerToken,
      'xApiKey' => RemoteAuthType.xApiKey,
      'customHeader' => RemoteAuthType.customHeader,
      _ => RemoteAuthType.providerDefault,
    };
  }

  String _remoteAuthTypeToString(RemoteAuthType authType) {
    return switch (authType) {
      RemoteAuthType.providerDefault => 'providerDefault',
      RemoteAuthType.bearerToken => 'bearerToken',
      RemoteAuthType.xApiKey => 'xApiKey',
      RemoteAuthType.customHeader => 'customHeader',
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

  static const int _maxPersistedInlineAttachmentBytes = 16 * 1024 * 1024;

  String? _encodeUserAttachments(
    List<ChatAttachment> attachments,
    Uint8List? primaryImageBytes,
  ) {
    if (attachments.isEmpty) return null;
    var usedPrimaryImageBytes = false;
    final encoded = <Map<String, dynamic>>[];

    for (final attachment in attachments) {
      final bytes = attachment.bytes;
      final item = <String, dynamic>{
        'id': attachment.id,
        'name': attachment.name,
        if (attachment.mimeType != null) 'mimeType': attachment.mimeType,
        if (attachment.sizeBytes != null)
          'sizeBytes': attachment.sizeBytes
        else if (bytes != null)
          'sizeBytes': bytes.length,
      };
      if (bytes != null && bytes.isNotEmpty) {
        if (!usedPrimaryImageBytes &&
            primaryImageBytes != null &&
            identical(bytes, primaryImageBytes)) {
          item['usesImageBytes'] = true;
          usedPrimaryImageBytes = true;
        } else if (bytes.length <= _maxPersistedInlineAttachmentBytes) {
          item['bytesBase64'] = base64Encode(bytes);
        }
      }
      encoded.add(item);
    }

    return jsonEncode({'version': 1, 'attachments': encoded});
  }

  List<ChatAttachment> _decodeUserAttachments(
    String? rawMetadata,
    Uint8List? imageBytes,
  ) {
    if (rawMetadata == null || rawMetadata.isEmpty) return const [];
    try {
      final decoded = jsonDecode(rawMetadata);
      if (decoded is! Map<String, dynamic>) return const [];
      final rawList = decoded['attachments'];
      if (rawList is! List) return const [];

      final attachments = <ChatAttachment>[];
      for (final entry in rawList) {
        if (entry is! Map) continue;
        final id = entry['id'];
        final name = entry['name'];
        if (id is! String || name is! String) continue;

        Uint8List? bytes;
        if (entry['usesImageBytes'] == true) {
          bytes = imageBytes;
        } else {
          final b64 = entry['bytesBase64'];
          if (b64 is String && b64.isNotEmpty) {
            try {
              bytes = base64Decode(b64);
            } on FormatException {
              bytes = null;
            }
          }
        }

        final sizeBytes = entry['sizeBytes'] is int
            ? entry['sizeBytes'] as int
            : bytes?.length;
        final mimeType = entry['mimeType'] is String
            ? entry['mimeType'] as String
            : null;

        attachments.add(
          ChatAttachment(
            id: id,
            name: name,
            sizeBytes: sizeBytes,
            mimeType: mimeType,
            bytes: bytes,
          ),
        );
      }
      return attachments;
    } on FormatException {
      return const [];
    }
  }
}
