import 'dart:convert';

import 'package:lib_llama_cpp/lib_llama_cpp.dart' as llama;

import '../models/message.dart';

llama.LlamaCommand buildLlamaGenerateCommand({
  required List<Message> messages,
  required List<Map<String, dynamic>> tools,
  required int maxTokens,
  required double temperature,
  required List<String> stop,
  bool useStreamingToolPrompt = false,
}) {
  final llamaTools = llamaToolsFromOpenAiTools(tools);
  if (llamaTools.isEmpty || useStreamingToolPrompt) {
    return llama.LlamaGenerateCommand(
      prompt: buildGemmaPrompt(
        messages,
        tools: useStreamingToolPrompt ? llamaTools : const [],
      ),
      maxTokens: maxTokens,
      temperature: temperature,
      stop: stop,
    );
  }

  return llama.LlamaGenerateMessagesCommand(
    messages: llamaMessagesFromChatMessages(messages),
    maxTokens: maxTokens,
    temperature: temperature,
    stop: stop,
    tools: llamaTools,
  );
}

String buildGemmaPrompt(
  List<Message> messages, {
  List<llama.LlamaTool> tools = const [],
}) {
  String? systemPrompt;
  final chatMessages = <Message>[];
  for (final message in messages) {
    if (message is SystemMessage) {
      systemPrompt = message.content;
    } else if (message is AssistantMessage && message.isStreaming) {
      continue;
    } else {
      chatMessages.add(message);
    }
  }

  final toolInstructions = buildGemmaToolInstructions(tools);
  final prompt = StringBuffer();
  for (var i = 0; i < chatMessages.length; i += 1) {
    final message = chatMessages[i];
    var content = switch (message) {
      final UserMessage user => user.contentWithAttachments(),
      ToolResponseMessage(:final toolName, :final content) =>
        'Tool response from $toolName:\n$content',
      _ => message.content,
    };

    if (i == 0 && message is UserMessage) {
      final prefixes = [
        if (systemPrompt != null && systemPrompt.trim().isNotEmpty)
          systemPrompt.trim(),
        if (toolInstructions.isNotEmpty) toolInstructions,
      ];
      if (prefixes.isNotEmpty) {
        content = '${prefixes.join('\n\n')}\n\n$content';
      }
    }

    final role = message is AssistantMessage ? 'model' : 'user';
    if (content.trim().isEmpty) continue;
    prompt
      ..write('<|turn>')
      ..write(role)
      ..write('\n')
      ..write(content.trim())
      ..writeln('<turn|>');
  }

  prompt.write('<|turn>model\n');
  return prompt.toString();
}

String buildGemmaToolInstructions(List<llama.LlamaTool> tools) {
  if (tools.isEmpty) return '';

  final buffer = StringBuffer()
    ..writeln('You can call tools when needed.')
    ..writeln('To call a tool, respond with exactly one call in this format:')
    ..writeln('<|tool_call>call:tool_name{"arg":"value"}<tool_call>')
    ..writeln('Do not add prose around a tool call.')
    ..writeln('Available tools:');

  for (final tool in tools) {
    buffer
      ..write('- ')
      ..write(tool.name);
    if (tool.description.isNotEmpty) {
      buffer
        ..write(': ')
        ..write(tool.description);
    }
    buffer.writeln();
    if (tool.parameters.isNotEmpty) {
      buffer
        ..write('  parameters: ')
        ..writeln(jsonEncode(tool.parameters));
    }
  }

  return buffer.toString().trimRight();
}

List<llama.LlamaMessage> llamaMessagesFromChatMessages(List<Message> messages) {
  final result = <llama.LlamaMessage>[];
  for (final message in messages) {
    if (message is AssistantMessage && message.isStreaming) continue;

    final (role, content) = switch (message) {
      SystemMessage(:final content) => ('system', content),
      final UserMessage user => ('user', user.contentWithAttachments()),
      AssistantMessage(:final content) => ('assistant', content),
      ToolResponseMessage(:final toolName, :final content) => (
        'user',
        'Tool result for $toolName:\n$content',
      ),
    };

    if (content.trim().isEmpty) continue;
    result.add(llama.LlamaMessage(role: role, content: content.trim()));
  }
  return result;
}

List<llama.LlamaTool> llamaToolsFromOpenAiTools(
  List<Map<String, dynamic>> tools,
) {
  final result = <llama.LlamaTool>[];
  for (final tool in tools) {
    try {
      result.add(llama.LlamaTool.fromJson(tool));
    } on ArgumentError {
      continue;
    }
  }
  return result;
}

/// Converts app [Message] list to a [LlamaResponseInputItem] list suitable
/// for [LlamaOpenAIClient.responses.stream].
///
/// Returns a tuple of (input items, system instruction).  The first
/// [SystemMessage] is extracted into the `instructions` parameter instead of
/// being included as a separate input item.
(List<llama.LlamaResponseInputItem>, String?) llamaResponseInputFromMessages(
  List<Message> messages,
) {
  String? systemInstruction;
  final inputItems = <llama.LlamaResponseInputItem>[];

  for (final message in messages) {
    if (message is SystemMessage) {
      systemInstruction ??= message.content;
      continue;
    }
    if (message is AssistantMessage && message.isStreaming) continue;

    final (role, content) = switch (message) {
      final UserMessage user => ('user', user.contentWithAttachments()),
      AssistantMessage(:final content) => ('assistant', content),
      ToolResponseMessage(:final toolName, :final content) => (
        'user',
        'Tool result for $toolName:\n$content',
      ),
      _ => ('user', message.content),
    };

    if (content.trim().isEmpty) continue;
    inputItems.add(
      llama.LlamaResponseInputItem(
        role: role,
        content: [llama.LlamaTextPart(content.trim())],
      ),
    );
  }

  return (inputItems, systemInstruction);
}
