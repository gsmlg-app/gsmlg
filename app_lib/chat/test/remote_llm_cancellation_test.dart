import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_chat/src/models/inference.dart';
import 'package:app_chat/src/models/model_config.dart';
import 'package:app_chat/src/repositories/remote_llm_repository.dart';
import 'package:app_secure_storage/vault_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:test/test.dart';

void main() {
  test(
    'stopping A aborts its socket stream while B and discovery continue',
    () async {
      final server = await _GenerationServer.start();
      final client = IOClient();
      final repository = RemoteLlmRepository(
        vault: _UnusedVault(),
        client: client,
      );
      addTearDown(() async {
        await repository.dispose();
        client.close();
        await server.close();
      });
      final chunksA = <ChatGenerationChunk>[];
      final chunksB = <ChatGenerationChunk>[];
      final firstA = Completer<void>();
      final firstB = Completer<void>();
      final doneA = Completer<void>();
      final doneB = Completer<void>();
      Object? errorA;
      Object? errorB;
      repository
          .generateResponse([], server.config('A'), generationId: 'A')
          .listen(
            (chunk) {
              chunksA.add(chunk);
              if (!firstA.isCompleted) firstA.complete();
            },
            onError: (Object error) => errorA = error,
            onDone: doneA.complete,
          );
      repository
          .generateResponse([], server.config('B'), generationId: 'B')
          .listen(
            (chunk) {
              chunksB.add(chunk);
              if (!firstB.isCompleted) firstB.complete();
            },
            onError: (Object error) => errorB = error,
            onDone: doneB.complete,
          );
      final responseA = await server.responseFor('A');
      final responseB = await server.responseFor('B');
      await _writeChunk(responseA, 'a-first');
      await _writeChunk(responseB, 'b-first');
      await Future.wait([firstA.future, firstB.future]).timeout(_timeout);

      await repository.stopGeneration(generationId: 'A');
      await doneA.future.timeout(_timeout);
      expect(errorA, isNull);
      expect(chunksA, [const ChatTextChunk('a-first')]);

      await _writeChunk(responseB, 'b-second');
      responseB.write('data: [DONE]\n\n');
      await responseB.close();
      await doneB.future.timeout(_timeout);
      expect(errorB, isNull);
      expect(chunksB, [
        const ChatTextChunk('b-first'),
        const ChatTextChunk('b-second'),
      ]);
      expect(await repository.listModels(server.config('models')), [
        'test-model',
      ]);

      // A completed generation removes its key; reusing it is safe.
      final reused = repository
          .generateResponse([], server.config('reused'), generationId: 'A')
          .toList();
      final reusedResponse = await server.responseFor('reused');
      await _writeChunk(reusedResponse, 'new-run');
      reusedResponse.write('data: [DONE]\n\n');
      await reusedResponse.close();
      expect(await reused.timeout(_timeout), [const ChatTextChunk('new-run')]);
    },
  );

  test(
    'cancels a request before response headers without closing other requests',
    () async {
      final server = await _GenerationServer.start();
      final repository = RemoteLlmRepository(vault: _UnusedVault());
      addTearDown(() async {
        await repository.dispose();
        await server.close();
      });
      final pending = repository
          .generateResponse(
            [],
            server.config('pending'),
            generationId: 'pending',
          )
          .toList();
      final aborted = expectLater(pending, completion(isEmpty));
      await server.responseFor('pending');
      await repository.stopGeneration(generationId: 'pending');
      await aborted.timeout(_timeout);
      expect(await repository.listModels(server.config('models')), [
        'test-model',
      ]);
    },
  );

  test(
    'dispose aborts active requests and preserves an injected client',
    () async {
      final server = await _GenerationServer.start();
      final client = IOClient();
      final repository = RemoteLlmRepository(
        vault: _UnusedVault(),
        client: client,
      );
      addTearDown(() async {
        await repository.dispose();
        client.close();
        await server.close();
      });
      final active = repository
          .generateResponse([], server.config('active'), generationId: 'active')
          .toList();
      final aborted = expectLater(active, completion(isEmpty));
      await server.responseFor('active');
      await repository.dispose();
      await aborted.timeout(_timeout);
      final models = await client.get(Uri.parse('${server.baseUrl}/models'));
      expect(models.statusCode, 200);
      await expectLater(
        repository
            .generateResponse([], server.config('after-dispose'))
            .toList(),
        throwsStateError,
      );
    },
  );

  test('unsolicited RequestAbortedException remains an error', () async {
    final repository = RemoteLlmRepository(
      vault: _UnusedVault(),
      client: _AbortedClient(),
    );
    addTearDown(repository.dispose);
    await expectLater(
      repository
          .generateResponse(
            [],
            const ModelConfig(
              inferenceMode: ChatInferenceMode.remote,
              remoteAccountId: ModelConfig.dummyRemoteAccountId,
              remoteBaseUrl: 'http://localhost/v1',
            ),
          )
          .toList(),
      throwsA(isA<http.RequestAbortedException>()),
    );
  });
}

const _timeout = Duration(seconds: 5);

Future<void> _writeChunk(HttpResponse response, String text) async {
  response.write(
    'data: ${jsonEncode({
      'choices': [
        {
          'delta': {'content': text},
        },
      ],
    })}\n\n',
  );
  await response.flush();
}

class _GenerationServer {
  _GenerationServer(this.server);

  final HttpServer server;
  final _responses = <String, Completer<HttpResponse>>{};

  static Future<_GenerationServer> start() async {
    final fixture = _GenerationServer(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    );
    fixture.server.listen((request) async {
      if (request.method == 'GET') {
        request.response
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'data': [
                {'id': 'test-model'},
              ],
            }),
          );
        await request.response.close();
        return;
      }
      final body =
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>;
      request.response.bufferOutput = false;
      request.response.headers.contentType = ContentType(
        'text',
        'event-stream',
      );
      fixture._responses
          .putIfAbsent(body['model'] as String, Completer<HttpResponse>.new)
          .complete(request.response);
    });
    return fixture;
  }

  String get baseUrl => 'http://127.0.0.1:${server.port}/v1';

  ModelConfig config(String model) => ModelConfig(
    inferenceMode: ChatInferenceMode.remote,
    remoteProvider: RemoteLlmProvider.openAiCompatible,
    remoteAccountId: ModelConfig.dummyRemoteAccountId,
    remoteBaseUrl: baseUrl,
    remoteModel: model,
  );

  Future<HttpResponse> responseFor(String model) => _responses
      .putIfAbsent(model, Completer<HttpResponse>.new)
      .future
      .timeout(_timeout);

  Future<void> close() => server.close(force: true);
}

class _UnusedVault implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AbortedClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      throw http.RequestAbortedException(request.url);
}
