import 'package:equatable/equatable.dart';

import 'message.dart';

/// Represents a chat conversation with metadata and messages.
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.systemPrompt,
  });

  /// Creates a new empty conversation.
  factory Conversation.create({
    required String id,
    String? title,
    String? systemPrompt,
  }) {
    final now = DateTime.now();
    return Conversation(
      id: id,
      title: title ?? 'New Conversation',
      createdAt: now,
      updatedAt: now,
      systemPrompt: systemPrompt,
    );
  }

  /// Unique identifier for the conversation.
  final String id;

  /// The display title of the conversation.
  final String title;

  /// When the conversation was created.
  final DateTime createdAt;

  /// When the conversation was last updated.
  final DateTime updatedAt;

  /// The messages in this conversation, ordered by timestamp.
  final List<Message> messages;

  /// Optional system prompt for this conversation.
  final String? systemPrompt;

  @override
  List<Object?> get props =>
      [id, title, createdAt, updatedAt, messages, systemPrompt];

  /// Returns the last message in the conversation, if any.
  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Returns user, assistant, and tool response messages (excludes system).
  List<Message> get chatMessages => messages
      .where((m) =>
          m is UserMessage || m is AssistantMessage || m is ToolResponseMessage)
      .toList();

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    String? systemPrompt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }

  /// Adds a message to the conversation and updates the timestamp.
  Conversation addMessage(Message message) {
    return copyWith(
      messages: [...messages, message],
      updatedAt: DateTime.now(),
    );
  }

  /// Updates the last message in the conversation.
  Conversation updateLastMessage(Message message) {
    if (messages.isEmpty) return this;
    return copyWith(
      messages: [...messages.sublist(0, messages.length - 1), message],
      updatedAt: DateTime.now(),
    );
  }
}
