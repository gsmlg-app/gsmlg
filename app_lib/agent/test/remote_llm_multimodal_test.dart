import 'dart:convert';
import 'dart:typed_data';

import 'package:app_agent/app_agent.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

class _FakeSecretReader implements SecretReader {
  @override
  Future<String?> read(String key) async => 'test-api-key';
}

void main() {
  final secrets = _FakeSecretReader();
  final samplePng = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x01,
    0x02,
    0x03,
  ]);
  final sampleB64 = base64Encode(samplePng);

  UserMessage imageMessage() => UserMessage(
    id: 'u1',
    conversationId: 'c1',
    timestamp: DateTime(2026),
    content: 'What is in this screenshot?',
    attachments: [
      ChatAttachment(
        id: 'att1',
        name: 'shot.png',
        mimeType: 'image/png',
        sizeBytes: samplePng.length,
        bytes: samplePng,
      ),
    ],
  );

  test(
    'OpenAI Responses sends multimodal input_text and input_image blocks',
    () async {
      Map<String, dynamic>? sentBody;
      final client = MockClient((request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'output': [
              {
                'type': 'message',
                'content': [
                  {
                    'type': 'output_text',
                    'text': 'It shows a grid of thumbnails.',
                  },
                ],
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = RemoteLlmRepository(secrets: secrets, client: client);
      final chunks = await repo.generateResponse(
        [imageMessage()],
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteApiType: RemoteLlmApiType.openAiResponses,
          remoteAccountId: 1,
          remoteBaseUrl: 'https://example.com/v1',
          remoteModel: 'MiniMax-M3',
          remoteStreamingEnabled: false,
        ),
      ).toList();

      expect(chunks, isNotEmpty);
      final input = sentBody!['input'] as List<dynamic>;
      final userItem = input.single as Map<String, dynamic>;
      expect(userItem['role'], 'user');
      final parts = userItem['content'] as List<dynamic>;
      expect(parts, [
        {'type': 'input_text', 'text': 'What is in this screenshot?'},
        {
          'type': 'input_image',
          'image_url': 'data:image/png;base64,$sampleB64',
        },
      ]);
      expect(jsonEncode(sentBody), isNot(contains('[binary file omitted]')));
    },
  );

  test(
    'OpenAI Chat Completions sends multimodal text and image_url blocks',
    () async {
      Map<String, dynamic>? sentBody;
      final client = MockClient((request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'Seen!'},
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = RemoteLlmRepository(secrets: secrets, client: client);
      await repo.generateResponse(
        [imageMessage()],
        const ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteApiType: RemoteLlmApiType.openAiChatCompletions,
          remoteAccountId: 1,
          remoteBaseUrl: 'https://example.com/v1',
          remoteModel: 'gpt-4o',
          remoteStreamingEnabled: false,
        ),
      ).toList();

      final messages = sentBody!['messages'] as List<dynamic>;
      final userItem = messages.single as Map<String, dynamic>;
      expect(userItem['content'], [
        {'type': 'text', 'text': 'What is in this screenshot?'},
        {
          'type': 'image_url',
          'image_url': {'url': 'data:image/png;base64,$sampleB64'},
        },
      ]);
    },
  );

  test('Anthropic Messages sends base64 image content blocks', () async {
    Map<String, dynamic>? sentBody;
    final client = MockClient((request) async {
      sentBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'content': [
            {'type': 'text', 'text': 'Seen by Claude!'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final repo = RemoteLlmRepository(secrets: secrets, client: client);
    await repo.generateResponse(
      [imageMessage()],
      const ModelConfig(
        inferenceMode: ChatInferenceMode.remote,
        remoteProvider: RemoteLlmProvider.anthropic,
        remoteApiType: RemoteLlmApiType.anthropicMessages,
        remoteAccountId: 1,
        remoteBaseUrl: 'https://api.anthropic.com/v1',
        remoteModel: 'claude-sonnet',
        remoteStreamingEnabled: false,
      ),
    ).toList();

    final messages = sentBody!['messages'] as List<dynamic>;
    final userItem = messages.single as Map<String, dynamic>;
    expect(userItem['content'], [
      {
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': 'image/png',
          'data': sampleB64,
        },
      },
      {'type': 'text', 'text': 'What is in this screenshot?'},
    ]);
  });
}
