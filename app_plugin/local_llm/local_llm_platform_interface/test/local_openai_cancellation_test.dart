import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_local_llm_platform_interface/src/local_openai_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'cancel before response headers returns promptly and client remains usable',
      () async {
    final fixture = await _LocalServer.start();
    final client = LocalOpenAiChatCompletionsClient(baseUri: fixture.baseUri);
    addTearDown(() async {
      client.close(force: true);
      await fixture.close();
    });
    final delivered = <Map<String, Object?>>[];
    final errors = <Object>[];
    final pending = client.streamChatCompletion(
        model: 'pending',
        messages: const []).listen(delivered.add, onError: errors.add);
    await fixture.received('pending');

    await pending.cancel().timeout(const Duration(seconds: 2));
    expect(delivered, isEmpty);
    expect(errors, isEmpty);

    final next = await client
        .streamChatCompletion(model: 'next', messages: const [])
        .toList()
        .timeout(const Duration(seconds: 2));
    expect(next, [
      {
        'choices': [
          {
            'delta': {'content': 'next reply'},
          },
        ],
      },
    ]);
  });

  test('cancel while streaming stops only that response and accepts another',
      () async {
    final fixture = await _LocalServer.start();
    final client = LocalOpenAiChatCompletionsClient(baseUri: fixture.baseUri);
    addTearDown(() async {
      client.close(force: true);
      await fixture.close();
    });
    final first = Completer<void>();
    final chunks = <Map<String, Object?>>[];
    final subscription = client.streamChatCompletion(
        model: 'streaming', messages: const []).listen((chunk) {
      chunks.add(chunk);
      if (!first.isCompleted) first.complete();
    });
    await first.future.timeout(const Duration(seconds: 2));
    await subscription.cancel().timeout(const Duration(seconds: 2));
    final next = await client
        .streamChatCompletion(model: 'next', messages: const [])
        .toList()
        .timeout(const Duration(seconds: 2));
    expect(chunks, hasLength(1));
    expect(next, hasLength(1));
    expect((next.single['choices'] as List).single['delta']['content'],
        'next reply');
  });

  test('immediate cancel handles a request that has not been opened yet',
      () async {
    final fixture = await _LocalServer.start();
    final client = LocalOpenAiChatCompletionsClient(baseUri: fixture.baseUri);
    addTearDown(() async {
      client.close(force: true);
      await fixture.close();
    });
    final subscription = client
        .streamChatCompletion(model: 'pending', messages: const []).listen(
            (_) => fail('cancelled request delivered a chunk'));
    await subscription.cancel().timeout(const Duration(seconds: 2));
    final next = await client
        .streamChatCompletion(model: 'next', messages: const [])
        .toList()
        .timeout(const Duration(seconds: 2));
    expect(next, hasLength(1));
  });
}

class _LocalServer {
  _LocalServer(this.server);
  final HttpServer server;
  final _received = <String, Completer<void>>{};

  static Future<_LocalServer> start() async {
    final fixture =
        _LocalServer(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    fixture.server.listen((request) async {
      final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
      final model = body['model'] as String;
      fixture._received.putIfAbsent(model, Completer<void>.new).complete();
      if (model == 'pending') return;
      request.response
        ..bufferOutput = false
        ..headers.contentType = ContentType('text', 'event-stream')
        ..write('data: ${jsonEncode({
              'choices': [
                {
                  'delta': {'content': '$model reply'},
                },
              ],
            })}\n\n');
      await request.response.flush();
      if (model == 'streaming') return;
      request.response.write('data: [DONE]\n\n');
      await request.response.close();
    });
    return fixture;
  }

  Uri get baseUri => Uri.parse('http://127.0.0.1:${server.port}');
  Future<void> received(String model) => _received
      .putIfAbsent(model, Completer<void>.new)
      .future
      .timeout(const Duration(seconds: 2));
  Future<void> close() async => server.close(force: true);
}
