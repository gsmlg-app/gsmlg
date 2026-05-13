import 'package:app_chat/src/models/message.dart';
import 'package:app_chat/src/repositories/llama_request_adapter.dart';
import 'package:lib_llama_cpp/lib_llama_cpp.dart' as llama;
import 'package:test/test.dart';

void main() {
  test('local generation maps OpenAI tool definitions to llama.cpp tools', () {
    final command = buildLlamaGenerateCommand(
      messages: [
        UserMessage(
          id: 'user',
          content: 'Search for llama.cpp',
          conversationId: 'conversation',
          timestamp: DateTime(2026),
        ),
      ],
      tools: const [
        {
          'type': 'function',
          'function': {
            'name': 'web_search',
            'description': 'Search the web',
            'parameters': {
              'type': 'object',
              'properties': {
                'query': {'type': 'string'},
              },
              'required': ['query'],
            },
          },
        },
      ],
      maxTokens: 128,
      temperature: 0.7,
      stop: const ['<end_of_turn>'],
    );

    expect(command, isA<llama.LlamaGenerateMessagesCommand>());
    final messagesCommand = command as llama.LlamaGenerateMessagesCommand;
    expect(messagesCommand.tools.single.name, 'web_search');
    expect(messagesCommand.tools.single.description, 'Search the web');
    expect(messagesCommand.messages.single.role, 'user');
    expect(messagesCommand.maxTokens, 128);
  });

  test(
    'local generation keeps plain prompt path when no tools are available',
    () {
      final command = buildLlamaGenerateCommand(
        messages: [
          SystemMessage(
            id: 'system',
            content: 'Be concise.',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
          ),
          UserMessage(
            id: 'user',
            content: 'Hello',
            conversationId: 'conversation',
            timestamp: DateTime(2026),
          ),
        ],
        tools: const [],
        maxTokens: 128,
        temperature: 0.7,
        stop: const ['<end_of_turn>'],
      );

      expect(command, isA<llama.LlamaGenerateCommand>());
      final promptCommand = command as llama.LlamaGenerateCommand;
      expect(promptCommand.prompt, contains('Be concise.'));
      expect(promptCommand.prompt, contains('Hello'));
    },
  );
}
