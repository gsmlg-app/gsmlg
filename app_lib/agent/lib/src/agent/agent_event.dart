import 'dart:async';

import 'package:agent_runtime/agent_runtime.dart';
import 'package:equatable/equatable.dart';

import '../models/message.dart' as app_msg;
import 'agent_invocation.dart';

sealed class ChatAgentEvent extends Equatable {
  const ChatAgentEvent({required this.runId, required this.sessionId});

  final String runId;
  final String sessionId;

  @override
  List<Object?> get props => [runId, sessionId];
}

final class AgentRunStartedEvent extends ChatAgentEvent {
  const AgentRunStartedEvent({
    required super.runId,
    required super.sessionId,
    required this.inputMessages,
  });

  final List<LLMMessage> inputMessages;

  @override
  List<Object?> get props => [...super.props, inputMessages];
}

final class ModelTurnStartedEvent extends ChatAgentEvent {
  const ModelTurnStartedEvent({
    required super.runId,
    required super.sessionId,
    required this.turnIndex,
    required this.model,
    this.messageId,
  });

  final int turnIndex;
  final String model;

  /// Canonical message ID owned by the agent for this model turn.
  final String? messageId;

  @override
  List<Object?> get props => [...super.props, turnIndex, model, messageId];
}

final class ModelChunkReceivedEvent extends ChatAgentEvent {
  const ModelChunkReceivedEvent({
    required super.runId,
    required super.sessionId,
    required this.turnIndex,
    this.messageId,
    this.textChunk,
    this.thoughtChunk,
    this.isFirstToken = false,
    this.timeToFirstToken,
  });

  final int turnIndex;
  final String? messageId;
  final String? textChunk;
  final String? thoughtChunk;
  final bool isFirstToken;
  final Duration? timeToFirstToken;

  @override
  List<Object?> get props => [
    ...super.props,
    turnIndex,
    messageId,
    textChunk,
    thoughtChunk,
    isFirstToken,
    timeToFirstToken,
  ];
}

final class ModelTurnCompletedEvent extends ChatAgentEvent {
  ModelTurnCompletedEvent({
    required super.runId,
    required super.sessionId,
    required this.turnIndex,
    required this.modelMessage,
    this.message,
    this.persisted = false,
    Completer<void>? acknowledgement,
  }) : acknowledgement = acknowledgement ?? Completer<void>();

  final int turnIndex;
  final ModelMessage modelMessage;

  /// Canonical [AssistantMessage] constructed (and persisted when [persisted]
  /// is true) by the agent for this turn.
  final app_msg.AssistantMessage? message;

  /// Whether the agent has already persisted [message] to its session store.
  final bool persisted;

  final Completer<void> acknowledgement;

  void acknowledge() {
    if (!acknowledgement.isCompleted) {
      acknowledgement.complete();
    }
  }

  void reject(Object error, [StackTrace? stackTrace]) {
    if (!acknowledgement.isCompleted) {
      acknowledgement.completeError(error, stackTrace);
    }
  }

  @override
  List<Object?> get props => [
    ...super.props,
    turnIndex,
    modelMessage,
    message,
    persisted,
  ];
}

final class ToolCallPreparedEvent extends ChatAgentEvent {
  const ToolCallPreparedEvent({
    required super.runId,
    required super.sessionId,
    required this.callId,
    required this.toolName,
    required this.arguments,
  });

  final String callId;
  final String toolName;
  final String arguments;

  @override
  List<Object?> get props => [...super.props, callId, toolName, arguments];
}

final class ToolCallStartedEvent extends ChatAgentEvent {
  const ToolCallStartedEvent({
    required super.runId,
    required super.sessionId,
    required this.callId,
    required this.toolName,
    required this.arguments,
  });

  final String callId;
  final String toolName;
  final String arguments;

  @override
  List<Object?> get props => [...super.props, callId, toolName, arguments];
}

final class ToolCallCompletedEvent extends ChatAgentEvent {
  ToolCallCompletedEvent({
    required super.runId,
    required super.sessionId,
    required this.callId,
    required this.toolName,
    required this.arguments,
    required this.receipt,
    this.message,
    this.persisted = false,
    Completer<void>? acknowledgement,
  }) : acknowledgement = acknowledgement ?? Completer<void>();

  final String callId;
  final String toolName;
  final String arguments;
  final ToolInvocationReceipt receipt;

  /// Canonical [ToolResponseMessage] constructed (and persisted when
  /// [persisted] is true) by the agent for this tool call.
  final app_msg.ToolResponseMessage? message;

  /// Whether the agent has already persisted [message] to its session store.
  final bool persisted;

  final Completer<void> acknowledgement;

  void acknowledge() {
    if (!acknowledgement.isCompleted) {
      acknowledgement.complete();
    }
  }

  void reject(Object error, [StackTrace? stackTrace]) {
    if (!acknowledgement.isCompleted) {
      acknowledgement.completeError(error, stackTrace);
    }
  }

  @override
  List<Object?> get props => [
    ...super.props,
    callId,
    toolName,
    arguments,
    receipt,
    message,
    persisted,
  ];
}

final class AgentRunCompletedEvent extends ChatAgentEvent {
  const AgentRunCompletedEvent({
    required super.runId,
    required super.sessionId,
    required this.finalResponse,
    this.usage,
  });

  final ModelMessage? finalResponse;
  final ModelUsage? usage;

  @override
  List<Object?> get props => [...super.props, finalResponse, usage];
}

final class AgentRunFailedEvent extends ChatAgentEvent {
  const AgentRunFailedEvent({
    required super.runId,
    required super.sessionId,
    required this.error,
    this.stackTrace,
    this.errorMessage,
  });

  final Object error;
  final StackTrace? stackTrace;

  /// Canonical error [app_msg.AssistantMessage] persisted by the agent, if any.
  final app_msg.AssistantMessage? errorMessage;

  @override
  List<Object?> get props => [...super.props, error.toString(), errorMessage];
}

final class AgentRunCancelledEvent extends ChatAgentEvent {
  const AgentRunCancelledEvent({
    required super.runId,
    required super.sessionId,
    required this.reason,
    this.partialMessage,
  });

  final String reason;

  /// Partial assistant turn persisted by the agent before stopping, if any.
  final app_msg.AssistantMessage? partialMessage;

  @override
  List<Object?> get props => [...super.props, reason, partialMessage];
}

final class SubAgentUpdatedEvent extends ChatAgentEvent {
  const SubAgentUpdatedEvent({
    required super.runId,
    required super.sessionId,
    required this.taskId,
    required this.parentRunId,
    required this.childRunId,
    required this.workerName,
    required this.goal,
    required this.status,
    required this.depth,
    this.summary,
    this.error,
    this.durationMs,
  });

  final String taskId;
  final String parentRunId;
  final String childRunId;
  final String workerName;
  final String goal;
  final String status;
  final int depth;
  final String? summary;
  final String? error;
  final int? durationMs;

  @override
  List<Object?> get props => [
    ...super.props,
    taskId,
    parentRunId,
    childRunId,
    workerName,
    goal,
    status,
    depth,
    summary,
    error,
    durationMs,
  ];
}
