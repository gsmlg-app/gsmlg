import 'package:dio/dio.dart' show CancelToken;

import 'message.dart';
import 'tool.dart';

/// Tool selection strategy for a model call.
enum ToolChoice { auto, none, required }

/// Provider-facing model parameters for an `AgentRuntime` turn.
class ModelConfig {
  const ModelConfig({required this.model, this.temperature, this.maxTokens});

  final String model;
  final double? temperature;
  final int? maxTokens;
}

/// Provider adapter contract consumed by `AgentRuntime`
/// (analogous to `Sigma.Ai.Provider`).
abstract interface class LLMClient {
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  });

  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  });
}
