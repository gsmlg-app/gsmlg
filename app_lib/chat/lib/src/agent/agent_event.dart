import 'dart:async';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:equatable/equatable.dart';

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
  });

  final int turnIndex;
  final String model;

  @override
  List<Object?> get props => [...super.props, turnIndex, model];
}

final class ModelChunkReceivedEvent extends ChatAgentEvent {
  const ModelChunkReceivedEvent({
    required super.runId,
    required super.sessionId,
    required this.turnIndex,
    this.textChunk,
    this.thoughtChunk,
    this.isFirstToken = false,
  });

  final int turnIndex;
  final String? textChunk;
  final String? thoughtChunk;
  final bool isFirstToken;

  @override
  List<Object?> get props => [
    ...super.props,
    turnIndex,
    textChunk,
    thoughtChunk,
    isFirstToken,
  ];
}

final class ModelTurnCompletedEvent extends ChatAgentEvent {
  ModelTurnCompletedEvent({
    required super.runId,
    required super.sessionId,
    required this.turnIndex,
    required this.modelMessage,
    Completer<void>? acknowledgement,
  }) : acknowledgement = acknowledgement ?? Completer<void>();

  final int turnIndex;
  final ModelMessage modelMessage;
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
  List<Object?> get props => [...super.props, turnIndex, modelMessage];
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
    Completer<void>? acknowledgement,
  }) : acknowledgement = acknowledgement ?? Completer<void>();

  final String callId;
  final String toolName;
  final String arguments;
  final ToolInvocationReceipt receipt;
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
  });

  final Object error;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [...super.props, error.toString()];
}

final class AgentRunCancelledEvent extends ChatAgentEvent {
  const AgentRunCancelledEvent({
    required super.runId,
    required super.sessionId,
    required this.reason,
  });

  final String reason;

  @override
  List<Object?> get props => [...super.props, reason];
}
