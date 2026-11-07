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

    test(
      'serializes assistant message with tool calls and tool result message',
      () {
        final assistantMsg = OpenAiMessage(
          role: 'assistant',
          content: 'I will lookup the data.',
          toolCalls: [
            {
              'id': 'call_123',
              'type': 'function',
              'function': {'name': 'lookup', 'arguments': '{"query":"test"}'},
            },
          ],
        );

        final toolMsg = OpenAiMessage(
          role: 'tool',
          toolCallId: 'call_123',
          content: '{"result":"found"}',
        );

        expect(assistantMsg.toJson(), {
          'role': 'assistant',
          'content': 'I will lookup the data.',
          'tool_calls': [
            {
              'id': 'call_123',
              'type': 'function',
              'function': {'name': 'lookup', 'arguments': '{"query":"test"}'},
            },
          ],
        });

        expect(toolMsg.toJson(), {
          'role': 'tool',
          'tool_call_id': 'call_123',
          'content': '{"result":"found"}',
        });
      },
    );

    test(
      'maps messages to Responses input format via OpenAiResponsesInput',
      () {
        final messages = [
          const OpenAiMessage(role: 'user', content: 'hello'),
          const OpenAiMessage(
            role: 'assistant',
            content: 'calling tool',
            toolCalls: [
              {
                'id': 'call_abc',
                'type': 'function',
                'function': {
                  'name': 'query_dns',
                  'arguments': '{"zone":"example.com"}',
                },
              },
            ],
          ),
          const OpenAiMessage(
            role: 'tool',
            toolCallId: 'call_abc',
            content: 'zone records...',
          ),
        ];

        final input = OpenAiResponsesInput.fromMessages(messages);

        expect(input, [
          {'role': 'user', 'content': 'hello'},
          {'role': 'assistant', 'content': 'calling tool'},
          {
            'type': 'function_call',
            'call_id': 'call_abc',
            'name': 'query_dns',
            'arguments': '{"zone":"example.com"}',
          },
          {
            'type': 'function_call_output',
            'call_id': 'call_abc',
            'output': 'zone records...',
          },
        ]);
      },
    );

    test(
      'omits empty assistant message when assistant only made tool calls',
      () {
        final messages = [
          const OpenAiMessage(role: 'user', content: 'check status'),
          const OpenAiMessage(
            role: 'assistant',
            content: '',
            toolCalls: [
              {
                'id': 'call_xyz',
                'type': 'function',
                'function': {'name': 'check_status', 'arguments': '{}'},
              },
            ],
          ),
          const OpenAiMessage(
            role: 'tool',
            toolCallId: 'call_xyz',
            content: 'all systems normal',
          ),
        ];

        final input = OpenAiResponsesInput.fromMessages(messages);

        expect(input, [
          {'role': 'user', 'content': 'check status'},
          {
            'type': 'function_call',
            'call_id': 'call_xyz',
            'name': 'check_status',
            'arguments': '{}',
          },
          {
            'type': 'function_call_output',
            'call_id': 'call_xyz',
            'output': 'all systems normal',
          },
        ]);
      },
    );

    test(
      'OpenAiResponsesRequest automatically encodes OpenAiMessage list with OpenAiResponsesInput',
      () {
        final request = OpenAiResponsesRequest(
          model: 'gpt-6-luna',
          input: const [
            OpenAiMessage(role: 'user', content: 'ping'),
            OpenAiMessage(
              role: 'assistant',
              toolCalls: [
                {'id': 'call_1', 'name': 'ping_tool', 'arguments': '{}'},
              ],
            ),
            OpenAiMessage(role: 'tool', toolCallId: 'call_1', content: 'pong'),
          ],
          stream: true,
          temperature: 0.5,
        );

        final json = request.toJson();
        expect(json['input'], [
          {'role': 'user', 'content': 'ping'},
          {
            'type': 'function_call',
            'call_id': 'call_1',
            'name': 'ping_tool',
            'arguments': '{}',
          },
          {
            'type': 'function_call_output',
            'call_id': 'call_1',
            'output': 'pong',
          },
        ]);
      },
    );
  });
}
