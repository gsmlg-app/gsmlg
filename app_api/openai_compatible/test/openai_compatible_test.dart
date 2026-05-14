import 'package:openai_compatible/openai_compatible.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAI-compatible API helpers', () {
    test('resolves chat completions and responses endpoints', () {
      final baseUrl = Uri.parse('https://api.openai.com/v1');

      expect(
        OpenAiCompatibleApiType.chatCompletions.endpoint(baseUrl),
        Uri.parse('https://api.openai.com/v1/chat/completions'),
      );
      expect(
        OpenAiCompatibleApiType.responses.endpoint(baseUrl),
        Uri.parse('https://api.openai.com/v1/responses'),
      );
    });

    test('serializes chat completions request body', () {
      final request = OpenAiChatCompletionsRequest(
        model: 'gpt-5',
        messages: const [OpenAiMessage(role: 'user', content: 'hello')],
        stream: false,
        temperature: 0.7,
        tools: const [
          {
            'type': 'function',
            'function': {'name': 'lookup'},
          },
        ],
      );

      expect(request.toJson(), {
        'model': 'gpt-5',
        'messages': [
          {'role': 'user', 'content': 'hello'},
        ],
        'stream': false,
        'temperature': 0.7,
        'tools': [
          {
            'type': 'function',
            'function': {'name': 'lookup'},
          },
        ],
      });
    });

    test('serializes responses request body with converted tools', () {
      final request = OpenAiResponsesRequest(
        model: 'gpt-5',
        input: const [OpenAiMessage(role: 'user', content: 'hello')],
        stream: true,
        temperature: 0.8,
        tools: OpenAiResponsesTool.fromChatCompletionsTools(const [
          {
            'type': 'function',
            'function': {
              'name': 'lookup',
              'description': 'Lookup data',
              'parameters': {
                'type': 'object',
                'properties': {
                  'query': {'type': 'string'},
                },
              },
            },
          },
        ]),
      );

      expect(request.toJson(), {
        'model': 'gpt-5',
        'input': [
          {'role': 'user', 'content': 'hello'},
        ],
        'stream': true,
        'temperature': 0.8,
        'store': false,
        'tools': [
          {
            'type': 'function',
            'name': 'lookup',
            'description': 'Lookup data',
            'parameters': {
              'type': 'object',
              'properties': {
                'query': {'type': 'string'},
              },
            },
            'strict': false,
          },
        ],
      });
    });
  });
}
