import 'dart:async';

import 'package:dio/dio.dart' show CancelToken;

import 'agent_loop.dart';
import 'message.dart';
import 'state.dart';

/// How tool arguments are passed to [Tool.executable].
enum ToolParameterMode { object, positional }

/// Output returned by a [Tool] invocation.
class AgentToolResult {
  const AgentToolResult({
    this.content,
    this.contents,
    this.metadata = const {},
  });

  final UserContentPart? content;
  final List<UserContentPart>? contents;
  final Map<String, dynamic> metadata;

  bool get isError => metadata['isError'] == true;

  List<UserContentPart> toContentParts() {
    if (contents != null && contents!.isNotEmpty) return contents!;
    if (content != null) return [content!];
    return const [TextPart('')];
  }
}

/// Zone-scoped context exposed to executing tools during a turn.
class AgentCallToolContext {
  const AgentCallToolContext({
    required this.state,
    required this.agent,
    required this.batchCallId,
    this.cancelToken,
  });

  static final zoneKey = #AgentCallToolContext;

  static AgentCallToolContext? get current {
    return Zone.current[zoneKey] as AgentCallToolContext?;
  }

  final AgentState state;
  final AgentRuntime agent;
  final String batchCallId;
  final CancelToken? cancelToken;
}

/// Callable tool exposed to the model inside [AgentRuntime].
class Tool {
  const Tool({
    required this.name,
    required this.description,
    required this.parameters,
    required this.executable,
    this.parameterMode = ToolParameterMode.object,
  });

  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final ToolParameterMode parameterMode;
  final FutureOr<dynamic> Function(Map<String, dynamic> args) executable;
}
