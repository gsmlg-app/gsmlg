import 'package:lib_llama_cpp/lib_llama_cpp.dart' as llama;

import '../models/message.dart';

llama.LlamaCommand buildLlamaGenerateCommand({
  required List<Message> messages,
  required List<Map<String, dynamic>> tools,
  required int maxTokens,
  required double temperature,
  required List<String> stop,
}) {
  final llamaTools = llamaToolsFromOpenAiTools(tools);
  if (llamaTools.isEmpty) {
    return llama.LlamaGenerateCommand(
      prompt: buildGemmaPrompt(messages),
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

String buildGemmaPrompt(List<Message> messages) {
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

  final prompt = StringBuffer();
  for (var i = 0; i < chatMessages.length; i += 1) {
    final message = chatMessages[i];
    var content = switch (message) {
      final UserMessage user => user.contentWithAttachments(),
      ToolResponseMessage(:final toolName, :final content) =>
        'Tool response from $toolName:\n$content',
      _ => message.content,
    };

    if (i == 0 && message is UserMessage && systemPrompt != null) {
      content = '$systemPrompt\n\n$content';
    }

    final role = message is AssistantMessage ? 'model' : 'user';
    if (content.trim().isEmpty) continue;
    prompt
      ..write('<start_of_turn>')
      ..write(role)
      ..write('\n')
      ..write(content.trim())
      ..writeln('<end_of_turn>');
  }

  prompt.write('<start_of_turn>model\n');
  return prompt.toString();
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
