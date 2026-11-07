import 'dart:async';
import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';

import '../models/inference.dart';
import '../models/message.dart' as app_msg;
import '../models/model_config.dart' as app_cfg;
import '../repositories/gemma_repository.dart';
import '../repositories/local_model_access.dart';
import '../repositories/remote_llm_repository.dart';

/// Adapts GSMLG model repositories (RemoteLlmRepository, GemmaRepository)
/// into a dart_agent_core LLMClient with request-scoped local model lease protection.
class RepositoryAgentLlmClient implements LLMClient {
  RepositoryAgentLlmClient({
    required this.config,
    this.remoteRepository,
    this.gemmaRepository,
    this.localModelAccess,
    this.conversationId,
    this.generationId,
    this.onFirstToken,
    List<app_msg.Message>? initialMessages,
    List<Map<String, dynamic>> initialTools = const [],
  }) {
    if (initialMessages != null && initialMessages.isNotEmpty) {
      _primeFirstTurn(initialMessages, initialTools);
    }
  }

  final app_cfg.ModelConfig config;
  final RemoteLlmRepository? remoteRepository;
  final GemmaRepository? gemmaRepository;
  final LocalModelAccess? localModelAccess;
  final String? conversationId;
  final String? generationId;
  final void Function()? onFirstToken;

  StreamController<ChatGenerationChunk>? _primedBuffer;
  StreamSubscription<ChatGenerationChunk>? _primedSub;

  void _primeFirstTurn(List<app_msg.Message> messages, List<Map<String, dynamic>> tools) {
    final effectiveGenId = generationId ?? 'gen_${DateTime.now().microsecondsSinceEpoch}';
    final Stream<ChatGenerationChunk> raw;
    if (_isLocal && gemmaRepository != null) {
      raw = gemmaRepository!.generateResponse(
        messages,
        config: config,
        tools: tools,
      );
    } else if (remoteRepository != null) {
      raw = remoteRepository!.generateResponse(
        messages,
        config,
        tools: tools,
        generationId: effectiveGenId,
      );
    } else {
      return;
    }

    final buffer = StreamController<ChatGenerationChunk>();
    _primedBuffer = buffer;
    _primedSub = raw.listen(
      (chunk) {
        if (!buffer.isClosed) buffer.add(chunk);
      },
      onError: (err, st) {
        if (!buffer.isClosed) buffer.addError(err, st);
      },
      onDone: () {
        if (!buffer.isClosed) buffer.close();
      },
      cancelOnError: true,
    );
  }

  LocalModelAccess? get _localModelAccess => localModelAccess;

  bool get _isLocal => config.inferenceMode == ChatInferenceMode.local;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    final streamResponse = await stream(
      messages,
      tools: tools,
      toolChoice: toolChoice,
      modelConfig: modelConfig,
      jsonOutput: jsonOutput,
      cancelToken: cancelToken,
    );

    final textBuffer = StringBuffer();
    final thoughtBuffer = StringBuffer();
    final functionCalls = <FunctionCall>[];

    await for (final msg in streamResponse) {
      final modelMsg = msg.modelMessage;
      if (modelMsg == null) continue;
      if (modelMsg.textOutput != null) {
        textBuffer.write(modelMsg.textOutput);
      }
      if (modelMsg.thought != null) {
        thoughtBuffer.write(modelMsg.thought);
      }
      if (modelMsg.functionCalls.isNotEmpty) {
        functionCalls.addAll(modelMsg.functionCalls);
      }
    }

    final text = textBuffer.toString();
    final thought = thoughtBuffer.toString();

    return ModelMessage(
      model: modelConfig.model,
      textOutput: text.isNotEmpty ? text : null,
      thought: thought.isNotEmpty ? thought : null,
      functionCalls: functionCalls,
      stopReason: functionCalls.isNotEmpty ? 'tool_calls' : 'stop',
    );
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    final appMessages = _convertToAppMessages(messages);
    final openAiTools = tools != null
        ? tools.map((t) => {
            'type': 'function',
            'function': {
              'name': t.name,
              'description': t.description,
              'parameters': t.parameters,
            },
          }).toList(growable: false)
        : const <Map<String, dynamic>>[];

    LocalModelLease? lease;
    final access = _localModelAccess;
    if (_isLocal && access != null) {
      lease = await access.acquire();
    }

    try {
      final Stream<ChatGenerationChunk> rawStream;
      if (_primedBuffer != null) {
        rawStream = _primedBuffer!.stream;
        _primedBuffer = null;
        _primedSub = null;
      } else {
        final effectiveGenId = generationId ?? 'gen_${DateTime.now().microsecondsSinceEpoch}';
        if (_isLocal && gemmaRepository != null) {
          rawStream = gemmaRepository!.generateResponse(
            appMessages,
            config: config,
            tools: openAiTools,
          );
        } else if (remoteRepository != null) {
          rawStream = remoteRepository!.generateResponse(
            appMessages,
            config,
            tools: openAiTools,
            generationId: effectiveGenId,
          );
        } else {
          throw StateError('No LLM repository available to handle request');
        }
      }

      StreamSubscription<ChatGenerationChunk>? rawSub;
      late final StreamController<StreamingMessage> controller;

      Future<void> cleanup() async {
        try {
          rawSub?.cancel();
        } catch (_) {}
        try {
          _primedSub?.cancel();
        } catch (_) {}
        lease?.release();
        lease = null;
      }

      controller = StreamController<StreamingMessage>(
        sync: true,
        onCancel: cleanup,
      );

      // Link cancel token
      if (cancelToken != null) {
        cancelToken.whenCancel.then((_) async {
          await cleanup();
          if (!controller.isClosed) {
            controller.addError(cancelToken.cancelError ?? Exception('Cancelled'));
            controller.close();
          }
        });
      }

      var callIndex = 0;
      var hasFunctionCalls = false;

      rawSub = rawStream.listen(
        (chunk) {
          switch (chunk) {
            case ChatTextChunk(:final text):
              if (text.isNotEmpty) {
                onFirstToken?.call();
              }
              controller.add(StreamingMessage(
                modelMessage: ModelMessage(
                  model: modelConfig.model,
                  textOutput: text,
                ),
              ));
            case ChatThinkingChunk(:final content):
              if (content.isNotEmpty) {
                onFirstToken?.call();
              }
              controller.add(StreamingMessage(
                modelMessage: ModelMessage(
                  model: modelConfig.model,
                  thought: content,
                ),
              ));
            case ChatFunctionCallChunk(:final name, :final args, :final id, :final index):
              hasFunctionCalls = true;
              final callId = id ?? 'call_${index ?? callIndex++}';
              controller.add(StreamingMessage(
                modelMessage: ModelMessage(
                  model: modelConfig.model,
                  functionCalls: [
                    FunctionCall(
                      id: callId,
                      name: name,
                      arguments: jsonEncode(args),
                    ),
                  ],
                  stopReason: 'tool_calls',
                ),
              ));
              // In tool-calling turns, function calls complete the model turn.
              // Closing in a microtask ensures all concurrent function calls in the turn
              // are collected before unblocking tool execution in StatefulAgent.
              scheduleMicrotask(() {
                if (!controller.isClosed) {
                  controller.close();
                }
              });
          }
        },
        onError: (err, st) {
          cleanup();
          if (!controller.isClosed) {
            controller.addError(err, st);
            controller.close();
          }
        },
        onDone: () {
          if (!controller.isClosed) {
            controller.add(StreamingMessage(
              modelMessage: ModelMessage(
                model: modelConfig.model,
                stopReason: hasFunctionCalls ? 'tool_calls' : 'stop',
              ),
            ));
            scheduleMicrotask(() {
              if (!controller.isClosed) {
                controller.close();
              }
            });
          }
          cleanup();
        },
        cancelOnError: true,
      );

      return controller.stream;
    } catch (_) {
      lease?.release();
      rethrow;
    }
  }

  List<app_msg.Message> _convertToAppMessages(List<LLMMessage> messages) {
    final result = <app_msg.Message>[];
    final now = DateTime.now();
    final targetConvId = conversationId ?? 'agent_loop';
    var idx = 0;

    for (final msg in messages) {
      final msgId = 'msg_${now.millisecondsSinceEpoch}_${idx++}';
      if (msg is SystemMessage) {
        result.add(app_msg.UserMessage(
          id: msgId,
          conversationId: targetConvId,
          timestamp: now,
          content: 'System instruction: ${msg.content}',
        ));
      } else if (msg is UserMessage) {
        final textParts = <String>[];
        for (final part in msg.contents) {
          if (part is TextPart) {
            textParts.add(part.text);
          }
        }
        result.add(app_msg.UserMessage(
          id: msgId,
          conversationId: targetConvId,
          timestamp: now,
          content: textParts.join('\n'),
        ));
      } else if (msg is ModelMessage) {
        result.add(app_msg.AssistantMessage(
          id: msgId,
          conversationId: targetConvId,
          timestamp: now,
          content: msg.textOutput ?? '',
          thinkingContent: msg.thought,
        ));
      } else if (msg is FunctionExecutionResultMessage) {
        for (final res in msg.results) {
          final textParts = <String>[];
          for (final part in res.content) {
            if (part is TextPart) {
              textParts.add(part.text);
            }
          }
          result.add(app_msg.ToolResponseMessage(
            id: 'tool_${now.millisecondsSinceEpoch}_${idx++}',
            conversationId: targetConvId,
            timestamp: now,
            toolName: res.name,
            toolCallId: res.id,
            content: textParts.isNotEmpty ? textParts.join('\n') : jsonEncode(res.toJson()),
            isError: res.isError,
          ));
        }
      }
    }

    return result;
  }
}
