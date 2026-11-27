import 'dart:async';

import 'agent_loop.dart';
import 'exception.dart';
import 'message.dart';
import 'provider.dart';
import 'tool.dart';

/// Request snapshot passed to [AgentHook.beforeModelCall].
class ModelCallRequest {
  const ModelCallRequest({
    required this.messages,
    required this.tools,
    required this.modelConfig,
    this.toolChoice,
  });

  final List<LLMMessage> messages;
  final List<Tool> tools;
  final ModelConfig modelConfig;
  final ToolChoice? toolChoice;

  ModelCallRequest copyWith({
    List<LLMMessage>? messages,
    List<Tool>? tools,
    ModelConfig? modelConfig,
    ToolChoice? toolChoice,
  }) => ModelCallRequest(
    messages: messages ?? this.messages,
    tools: tools ?? this.tools,
    modelConfig: modelConfig ?? this.modelConfig,
    toolChoice: toolChoice ?? this.toolChoice,
  );
}

class ModelCallHookContext {
  const ModelCallHookContext({
    required this.agent,
    required this.turnIndex,
    required this.request,
  });

  final AgentRuntime agent;
  final int turnIndex;
  final ModelCallRequest request;
}

enum HookAction { proceed, skip, abort }

class ModelCallHookResult {
  const ModelCallHookResult._({
    required this.action,
    this.request,
    this.reason,
    this.error,
  });

  const ModelCallHookResult.proceed({ModelCallRequest? request})
    : this._(action: HookAction.proceed, request: request);

  const ModelCallHookResult.abort({String? reason, Object? error})
    : this._(action: HookAction.abort, reason: reason, error: error);

  final HookAction action;
  final ModelCallRequest? request;
  final String? reason;
  final Object? error;
}

class ModelResponseHookContext {
  const ModelResponseHookContext({
    required this.agent,
    required this.turnIndex,
    required this.response,
  });

  final AgentRuntime agent;
  final int turnIndex;
  final ModelMessage response;
}

class ModelResponseHookResult {
  const ModelResponseHookResult._({
    required this.action,
    this.response,
    this.reason,
    this.error,
  });

  const ModelResponseHookResult.proceed(ModelMessage response)
    : this._(action: HookAction.proceed, response: response);

  const ModelResponseHookResult.abort({String? reason, Object? error})
    : this._(action: HookAction.abort, reason: reason, error: error);

  final HookAction action;
  final ModelMessage? response;
  final String? reason;
  final Object? error;
}

class ToolCallHookContext {
  const ToolCallHookContext({
    required this.agent,
    required this.turnIndex,
    required this.call,
  });

  final AgentRuntime agent;
  final int turnIndex;
  final FunctionCall call;
}

class ToolCallHookResult {
  const ToolCallHookResult._({
    required this.action,
    this.call,
    this.reason,
    this.error,
  });

  const ToolCallHookResult.proceed(FunctionCall call)
    : this._(action: HookAction.proceed, call: call);

  const ToolCallHookResult.abort({String? reason, Object? error})
    : this._(action: HookAction.abort, reason: reason, error: error);

  final HookAction action;
  final FunctionCall? call;
  final String? reason;
  final Object? error;
}

enum StatePersistenceHookAction { proceed, skip, abort }

class StatePersistenceHookContext {
  const StatePersistenceHookContext(
    this.agent, {
    required this.reason,
    this.runError,
  });

  final AgentRuntime agent;
  final String reason;
  final AgentException? runError;
}

class StatePersistenceHookResult {
  const StatePersistenceHookResult._({
    required this.action,
    this.reason,
    this.error,
  });

  const StatePersistenceHookResult.proceed()
    : this._(action: StatePersistenceHookAction.proceed);

  const StatePersistenceHookResult.skip()
    : this._(action: StatePersistenceHookAction.skip);

  const StatePersistenceHookResult.abort({String? reason, Object? error})
    : this._(
        action: StatePersistenceHookAction.abort,
        reason: reason,
        error: error,
      );

  final StatePersistenceHookAction action;
  final String? reason;
  final Object? error;
}

/// Extensible lifecycle hook for [AgentRuntime] turns, tool calls, and state
/// persistence.
abstract class AgentHook {
  FutureOr<ModelCallHookResult> beforeModelCall(ModelCallHookContext context) =>
      ModelCallHookResult.proceed(request: context.request);

  FutureOr<ModelResponseHookResult> afterModelCall(
    ModelResponseHookContext context,
  ) => ModelResponseHookResult.proceed(context.response);

  FutureOr<ToolCallHookResult> beforeToolCall(ToolCallHookContext context) =>
      ToolCallHookResult.proceed(context.call);

  FutureOr<StatePersistenceHookResult> beforePersistState(
    StatePersistenceHookContext context,
  ) => const StatePersistenceHookResult.proceed();

  FutureOr<void> afterPersistState(StatePersistenceHookContext context) {}
}
