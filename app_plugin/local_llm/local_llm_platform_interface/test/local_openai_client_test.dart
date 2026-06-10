import 'dart:convert';
import 'dart:io';

import 'package:app_local_llm_platform_interface/app_local_llm_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Map<String, Object?> capturedBody;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    capturedBody = {};
    server.listen((request) async {
      expect(request.method, 'POST');
      expect(request.uri.path, '/v1/chat/completions');
      capturedBody = (jsonDecode(await utf8.decodeStream(request)) as Map)
          .cast<String, Object?>();

      request.response.headers.contentType = ContentType(
        'text',
        'event-stream',
        charset: 'utf-8',
      );
      request.response.write(
        'data: {"choices":[{"delta":{"role":"assistant"}}]}\n\n',
      );
      request.response.write(
        'data: {"choices":[{"delta":{"content":"hello"}}]}\n\n',
      );
      request.response.write('data: [DONE]\n\n');
      await request.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('streams OpenAI chat completion chunks from a local server', () async {
    final client = LocalOpenAiChatCompletionsClient(
      baseUri: Uri.parse('http://127.0.0.1:${server.port}'),
    );
    addTearDown(client.close);

    final chunks = await client
        .streamChatCompletion(
          model: 'local-model',
          messages: const [
            {'role': 'user', 'content': 'hello'},
          ],
          maxTokens: 32,
          temperature: 0.2,
          topK: 40,
          stop: const ['<end_of_turn>'],
        )
        .toList();

    expect(capturedBody['model'], 'local-model');
    expect(capturedBody['stream'], isTrue);
    expect(capturedBody['max_tokens'], 32);
    expect(capturedBody['temperature'], 0.2);
    expect(capturedBody['top_k'], 40);
    expect(capturedBody['stop'], ['<end_of_turn>']);
    expect(chunks, hasLength(2));
    expect((chunks.last['choices'] as List).first['delta']['content'], 'hello');
  });
}
