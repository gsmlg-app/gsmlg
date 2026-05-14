import 'package:anthropic_compatible/anthropic_compatible.dart';
import 'package:test/test.dart';

void main() {
  group('Anthropic-compatible API helpers', () {
    test('resolves messages endpoint and auth headers', () {
      final baseUrl = Uri.parse('https://api.anthropic.com/v1');

      expect(
        AnthropicMessagesApi.endpoint(baseUrl),
        Uri.parse('https://api.anthropic.com/v1/messages'),
      );
      expect(AnthropicMessagesApi.headers(apiKey: 'secret', stream: true), {
        'x-api-key': 'secret',
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json; charset=utf-8',
        'accept': 'text/event-stream',
      });
    });

    test('serializes messages request body', () {
      final request = AnthropicMessagesRequest(
        model: 'claude-sonnet-4-5',
        maxTokens: 1024,
        system: 'Be brief.',
        messages: const [AnthropicMessage(role: 'user', content: 'hello')],
        stream: false,
        temperature: 0.4,
        tools: const [
          AnthropicTool(
            name: 'lookup',
            description: 'Lookup data',
            inputSchema: {
              'type': 'object',
              'properties': {
                'query': {'type': 'string'},
              },
            },
          ),
        ],
      );

      expect(request.toJson(), {
        'model': 'claude-sonnet-4-5',
        'max_tokens': 1024,
        'system': 'Be brief.',
        'messages': [
          {'role': 'user', 'content': 'hello'},
        ],
        'stream': false,
        'temperature': 0.4,
        'tools': [
          {
            'name': 'lookup',
            'description': 'Lookup data',
            'input_schema': {
              'type': 'object',
              'properties': {
                'query': {'type': 'string'},
              },
            },
          },
        ],
      });
    });

    test('converts OpenAI function tools to Anthropic tools', () {
      final tools = AnthropicTool.fromOpenAiTools(const [
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
      ]);

      expect(tools.map((tool) => tool.toJson()).toList(), [
        {
          'name': 'lookup',
          'description': 'Lookup data',
          'input_schema': {
            'type': 'object',
            'properties': {
              'query': {'type': 'string'},
            },
          },
        },
      ]);
    });
  });
}
