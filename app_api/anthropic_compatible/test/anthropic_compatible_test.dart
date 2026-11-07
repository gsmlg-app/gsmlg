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

    test('serializes tool_use and tool_result blocks in messages', () {
      final messages = [
        const AnthropicMessage(role: 'user', content: 'What is the weather?'),
        const AnthropicMessage(
          role: 'assistant',
          content: [
            {
              'type': 'text',
              'text': 'Checking weather...',
            },
            {
              'type': 'tool_use',
              'id': 'toolu_1',
              'name': 'get_weather',
              'input': {'location': 'Tokyo'},
            },
          ],
        ),
        const AnthropicMessage(
          role: 'user',
          content: [
            {
              'type': 'tool_result',
              'tool_use_id': 'toolu_1',
              'content': 'Sunny, 22C',
            },
          ],
        ),
      ];

      expect(messages.map((m) => m.toJson()).toList(), [
        {'role': 'user', 'content': 'What is the weather?'},
        {
          'role': 'assistant',
          'content': [
            {'type': 'text', 'text': 'Checking weather...'},
            {
              'type': 'tool_use',
              'id': 'toolu_1',
              'name': 'get_weather',
              'input': {'location': 'Tokyo'},
            },
          ],
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'tool_result',
              'tool_use_id': 'toolu_1',
              'content': 'Sunny, 22C',
            },
          ],
        },
      ]);
    });
  });
}
