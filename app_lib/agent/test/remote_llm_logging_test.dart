import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_agent/app_agent.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_secure_storage/vault_repository.dart';
import 'package:dart_agent_core/dart_agent_core.dart' as dac;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

class _Sink implements LogSink {
  final api = <ApiExchangeRecord>[];
  @override
  void writeApi(ApiExchangeRecord r) => api.add(r);
  @override
  void writeAgent(AgentLogEvent e) {}
  @override
  void writeUsage(UsageEvent e) {}
}

class _UnusedVault implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _timeout = Duration(seconds: 5);

const _anthropicConfig = ModelConfig(
  inferenceMode: ChatInferenceMode.remote,
  remoteProvider: RemoteLlmProvider.anthropic,
  remoteApiType: RemoteLlmApiType.anthropicMessages,
  remoteAccountId: ModelConfig.dummyRemoteAccountId,
  remoteBaseUrl: 'https://API.Anthropic.com/v1',
  remoteModel: 'claude-sonnet-4-5',
);

String _anthropicSse(String text) => [
  'event: content_block_start',
  'data: ${jsonEncode({
    'type': 'content_block_start',
    'index': 0,
    'content_block': {'type': 'text', 'text': ''},
  })}',
  '',
  'event: content_block_delta',
  'data: ${jsonEncode({
    'type': 'content_block_delta',
    'index': 0,
    'delta': {'type': 'text_delta', 'text': text},
  })}',
  '',
  'event: message_stop',
  'data: ${jsonEncode({'type': 'message_stop'})}',
].join('\n');

MockClient _sseClient(String body) => MockClient(
  (request) async => http.Response(
    body,
    200,
    headers: {'content-type': 'text/event-stream; charset=utf-8'},
  ),
);

List<String>? _header(HttpMessageCapture? m, String name) {
  for (final e in m!.headers.entries) {
    if (e.key.toLowerCase() == name.toLowerCase()) return e.value;
  }
  return null;
}

void main() {
  late _Sink sink;
  setUp(() {
    sink = _Sink();
    LogCapture.instance.attach(sink);
  });
  tearDown(() => LogCapture.instance.attach(null));

  group('RemoteLlmRepository.llmCategory', () {
    test('uses the lowercase base url host', () {
      expect(
        RemoteLlmRepository.llmCategory(_anthropicConfig),
        'llm:api.anthropic.com',
      );
    });

    test('falls back to the provider name without a host', () {
      expect(
        RemoteLlmRepository.llmCategory(
          const ModelConfig(
            inferenceMode: ChatInferenceMode.remote,
            remoteProvider: RemoteLlmProvider.openAiCompatible,
            remoteBaseUrl: '',
          ),
        ),
        'llm:openAiCompatible',
      );
    });
  });

  test('streaming anthropic generation yields the same chunks and records '
      'request + response with context', () async {
    final repository = RemoteLlmRepository(
      vault: _UnusedVault(),
      client: _sseClient(_anthropicSse('hello')),
    );
    addTearDown(repository.dispose);

    final chunks = await repository
        .generateResponse(
          const [],
          _anthropicConfig,
          generationId: 'gen-1',
          logContext: const LogContext(
            conversationId: 'conv-1',
            runId: 'run-1',
            generationId: 'gen-1',
            turn: 1,
          ),
        )
        .toList();

    expect(chunks, [const ChatTextChunk('hello')]);
    expect(sink.api.map((r) => r.recordType), ['request', 'response']);
    for (final r in sink.api) {
      expect(r.category, 'llm:api.anthropic.com');
      expect(r.apiType, 'anthropicMessages');
      expect(r.context?.runId, 'run-1');
      expect(r.context?.conversationId, 'conv-1');
      expect(r.context?.turn, 1);
    }
    final request = sink.api.first.request!;
    expect(request.method, 'POST');
    expect(_header(request, 'x-api-key'), ['[REDACTED]']);
    final response = sink.api.last;
    expect(response.aborted, isFalse);
    expect(response.response!.status, 200);
    expect(response.response!.body, _anthropicSse('hello'));
  });

  test('custom auth header value is stored as [REDACTED]', () async {
    final repository = RemoteLlmRepository(
      vault: _UnusedVault(),
      client: MockClient(
        (request) async => http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'role': 'assistant', 'content': 'hi'},
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    addTearDown(repository.dispose);

    final chunks = await repository
        .generateResponse(
          const [],
          const ModelConfig(
            inferenceMode: ChatInferenceMode.remote,
            remoteProvider: RemoteLlmProvider.openAiCompatible,
            remoteAccountId: ModelConfig.dummyRemoteAccountId,
            remoteBaseUrl: 'https://llm.example.com/v1',
            remoteModel: 'm',
            remoteAuthType: RemoteAuthType.customHeader,
            remoteAuthHeaderName: 'X-Secret',
            remoteStreamingEnabled: false,
          ),
        )
        .toList();

    expect(chunks, [const ChatTextChunk('hi')]);
    expect(sink.api, hasLength(1));
    final r = sink.api.single;
    expect(r.recordType, 'exchange');
    expect(r.category, 'llm:llm.example.com');
    expect(_header(r.request, 'X-Secret'), ['[REDACTED]']);
    expect(jsonEncode(r.toJson()), isNot(contains('dummy')));
  });

  test('listModels 500 records an exchange with the full body', () async {
    final longBody = 'upstream exploded: ${'x' * 2000}';
    final repository = RemoteLlmRepository(
      vault: _UnusedVault(),
      client: MockClient(
        (request) async => http.Response(
          longBody,
          500,
          headers: {'content-type': 'text/plain'},
        ),
      ),
    );
    addTearDown(repository.dispose);

    await expectLater(
      repository.listModels(_anthropicConfig),
      throwsA(isA<RemoteLlmException>()),
    );

    expect(sink.api, hasLength(1));
    final r = sink.api.single;
    expect(r.recordType, 'exchange');
    expect(r.category, 'llm:api.anthropic.com');
    expect(r.apiType, 'anthropicMessages');
    expect(r.request!.method, 'GET');
    expect(r.response!.status, 500);
    expect(r.response!.body, longBody);
  });

  test(
    'RepositoryAgentLlmClient tags each model call with run and turn',
    () async {
      final repository = RemoteLlmRepository(
        vault: _UnusedVault(),
        client: _sseClient(_anthropicSse('ok')),
      );
      addTearDown(repository.dispose);
      final client = RepositoryAgentLlmClient(
        config: _anthropicConfig,
        remoteRepository: repository,
        conversationId: 'conv-9',
        runId: 'run-9',
        generationId: 'gen-9',
        initialMessages: [
          UserMessage(
            id: 'u',
            conversationId: 'conv-9',
            timestamp: DateTime(2026),
            content: 'hello',
          ),
        ],
      );

      final modelConfig = dac.ModelConfig(model: 'claude-sonnet-4-5');
      await (await client.stream(const [], modelConfig: modelConfig)).toList();
      await (await client.stream(const [], modelConfig: modelConfig)).toList();

      final contexts = sink.api
          .where((r) => r.recordType == 'request')
          .map((r) => r.context!)
          .toList();
      expect(contexts.map((c) => c.turn), [1, 2]);
      for (final c in contexts) {
        expect(c.runId, 'run-9');
        expect(c.conversationId, 'conv-9');
        expect(c.generationId, 'gen-9');
      }
    },
  );

  test('stopGeneration mid-stream over a real socket completes normally and '
      'records an aborted response with the first chunk', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final responseReady = Completer<HttpResponse>();
    server.listen((request) async {
      await request.drain<void>();
      request.response
        ..bufferOutput = false
        ..headers.contentType = ContentType('text', 'event-stream');
      responseReady.complete(request.response);
    });
    final client = http.Client();
    final repository = RemoteLlmRepository(
      vault: _UnusedVault(),
      client: client,
    );
    addTearDown(() async {
      await repository.dispose();
      client.close();
      await server.close(force: true);
    });

    final firstChunk =
        'data: ${jsonEncode({
          'choices': [
            {
              'delta': {'content': 'first'},
            },
          ],
        })}\n\n';

    final chunks = <ChatGenerationChunk>[];
    final first = Completer<void>();
    final done = Completer<void>();
    Object? error;
    repository
        .generateResponse(
          const [],
          ModelConfig(
            inferenceMode: ChatInferenceMode.remote,
            remoteProvider: RemoteLlmProvider.openAiCompatible,
            remoteAccountId: ModelConfig.dummyRemoteAccountId,
            remoteBaseUrl: 'http://127.0.0.1:${server.port}/v1',
            remoteModel: 'm',
          ),
          generationId: 'gen-abort',
          logContext: const LogContext(generationId: 'gen-abort'),
        )
        .listen(
          (c) {
            chunks.add(c);
            if (!first.isCompleted) first.complete();
          },
          onError: (Object e) => error = e,
          onDone: done.complete,
        );

    final response = await responseReady.future.timeout(_timeout);
    response.write(firstChunk);
    await response.flush();
    await first.future.timeout(_timeout);

    await repository.stopGeneration(generationId: 'gen-abort');
    await done.future.timeout(_timeout);

    expect(error, isNull);
    expect(chunks, [const ChatTextChunk('first')]);
    expect(sink.api.map((r) => r.recordType), ['request', 'response']);
    final r = sink.api.last;
    expect(r.aborted, isTrue);
    expect(r.error, isNull);
    expect(r.category, 'llm:127.0.0.1');
    expect(r.context?.generationId, 'gen-abort');
    expect(r.response!.body, firstChunk);
  });

  test('normal SSE completion over a real socket that stays open after the '
      'end marker is recorded as not aborted with no error', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final serverDone = Completer<void>();
    server.listen((request) async {
      await request.drain<void>();
      final response = request.response
        ..bufferOutput = false
        ..headers.contentType = ContentType('text', 'event-stream');
      response.write(
        'data: ${jsonEncode({
          'choices': [
            {
              'delta': {'content': 'hi'},
            },
          ],
        })}\n\n'
        'data: [DONE]\n\n',
      );
      await response.flush();
      // Keep the connection open briefly after the end marker.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      try {
        await response.close();
      } catch (_) {}
      serverDone.complete();
    });
    final client = http.Client();
    final repository = RemoteLlmRepository(
      vault: _UnusedVault(),
      client: client,
    );
    addTearDown(() async {
      await serverDone.future.timeout(_timeout);
      await repository.dispose();
      client.close();
      await server.close(force: true);
    });

    final chunks = await repository
        .generateResponse(
          const [],
          ModelConfig(
            inferenceMode: ChatInferenceMode.remote,
            remoteProvider: RemoteLlmProvider.openAiCompatible,
            remoteAccountId: ModelConfig.dummyRemoteAccountId,
            remoteBaseUrl: 'http://127.0.0.1:${server.port}/v1',
            remoteModel: 'm',
          ),
          generationId: 'gen-done',
        )
        .toList()
        .timeout(_timeout);

    expect(chunks, [const ChatTextChunk('hi')]);
    expect(sink.api.map((r) => r.recordType), ['request', 'response']);
    final r = sink.api.last;
    expect(r.aborted, isFalse);
    expect(r.error, isNull);
    expect(r.method, 'POST');
    expect(r.host, '127.0.0.1:${server.port}');
  });
}
