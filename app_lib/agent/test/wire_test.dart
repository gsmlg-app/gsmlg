import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:app_agent/app_agent.dart';
import 'package:dart_agent_core/dart_agent_core.dart' as core;
import 'package:flutter_test/flutter_test.dart';

final _t = DateTime.utc(2026, 1, 2, 3, 4, 5, 6, 7);

List<Message> _messages() => [
  UserMessage(
    id: 'u',
    content: 'hi',
    conversationId: 'c',
    timestamp: _t,
    imageBytes: Uint8List.fromList([1, 2]),
    audioBytes: Uint8List.fromList([3]),
    attachments: [
      ChatAttachment(
        id: 'a',
        name: 'n.txt',
        sizeBytes: 3,
        mimeType: 'text/plain',
        bytes: Uint8List.fromList([4, 5, 6]),
      ),
      const ChatAttachment(id: 'b', name: 'x'),
    ],
  ),
  AssistantMessage(
    id: 'a',
    content: 'yo',
    conversationId: 'c',
    timestamp: _t,
    isStreaming: true,
    completedSuccessfully: false,
    tokenCount: 7,
    thinkingContent: 'hmm',
    agentMetadata: const AgentMessageMetadata(model: 'm').encode(),
    responseInfo: const ChatResponseInfo(
      outputTokens: 5,
      duration: Duration(milliseconds: 1500),
      contextTokens: 9,
      maxOutputTokens: 100,
      timeToFirstToken: Duration(milliseconds: 20),
    ),
  ),
  AssistantMessage(id: 'a2', content: '', conversationId: 'c', timestamp: _t),
  SystemMessage(id: 's', content: 'sys', conversationId: 'c', timestamp: _t),
  ToolResponseMessage(
    id: 't',
    content: 'r',
    conversationId: 'c',
    timestamp: _t,
    toolName: 'shell',
    toolCallId: 'call1',
    isError: true,
    agentMetadata: '{}',
  ),
];

final _receipt = ToolInvocationReceipt(
  runId: 'r',
  callId: 'c1',
  invocationId: 'i1',
  toolName: 'shell',
  arguments: '{"a":1}',
  status: InvocationStatus.succeeded,
  result: {'ok': true},
  timestamp: DateTime.utc(2026, 1, 1),
  backend: 'shell',
  durationMs: 12,
);

core.ModelMessage _model() => core.ModelMessage(
  model: 'm',
  textOutput: 'out',
  thought: 'th',
  functionCalls: [core.FunctionCall(id: 'f', name: 'n', arguments: '{}')],
  usage: core.ModelUsage(promptTokens: 1, completionTokens: 2, timestamp: 5),
  timestamp: 9,
);

List<ChatAgentEvent> _events() => [
  AgentRunStartedEvent(
    runId: 'r',
    sessionId: 's',
    inputMessages: [core.UserMessage.text('hello'), core.SystemMessage('sys')],
  ),
  const ModelTurnStartedEvent(
    runId: 'r',
    sessionId: 's',
    turnIndex: 1,
    model: 'm',
  ),
  const ModelChunkReceivedEvent(
    runId: 'r',
    sessionId: 's',
    turnIndex: 1,
    textChunk: 'a',
    thoughtChunk: 'b',
    isFirstToken: true,
  ),
  ModelTurnCompletedEvent(
    runId: 'r',
    sessionId: 's',
    turnIndex: 1,
    modelMessage: _model(),
  ),
  const ToolCallPreparedEvent(
    runId: 'r',
    sessionId: 's',
    callId: 'c',
    toolName: 't',
    arguments: '{}',
  ),
  const ToolCallStartedEvent(
    runId: 'r',
    sessionId: 's',
    callId: 'c',
    toolName: 't',
    arguments: '{}',
  ),
  ToolCallCompletedEvent(
    runId: 'r',
    sessionId: 's',
    callId: 'c',
    toolName: 't',
    arguments: '{}',
    receipt: _receipt,
  ),
  AgentRunCompletedEvent(
    runId: 'r',
    sessionId: 's',
    finalResponse: _model(),
    usage: core.ModelUsage(totalTokens: 3, timestamp: 1),
  ),
  const AgentRunCompletedEvent(runId: 'r', sessionId: 's', finalResponse: null),
  AgentRunFailedEvent(
    runId: 'r',
    sessionId: 's',
    error: StateError('boom'),
    stackTrace: StackTrace.fromString('trace here'),
  ),
  const AgentRunCancelledEvent(runId: 'r', sessionId: 's', reason: 'user'),
];

/// Events carry non-comparable core types; compare their JSON.
Object? _norm(ChatAgentEvent e) => switch (e) {
  AgentRunStartedEvent() => [
    e.runId,
    e.sessionId,
    e.inputMessages.map((m) => m.toJson()).toList(),
  ],
  ModelTurnCompletedEvent() => [e.runId, e.turnIndex, e.modelMessage.toJson()],
  AgentRunCompletedEvent() => [
    e.runId,
    e.finalResponse?.toJson(),
    e.usage?.toJson(),
  ],
  _ => e.props,
};

void _entry(SendPort out) {
  final port = ReceivePort();
  out.send(port.sendPort);
  port.listen((m) {
    final map = Map<String, Object?>.from(m as Map);
    final kind = map['_kind'];
    final payload = (map['payload'] as Map).cast<String, Object?>();
    try {
      final Map<String, Object?> back = switch (kind) {
        'event' => agentEventToWire(agentEventFromWire(payload), ackId: 'x'),
        'start' => StartRun.fromWire(payload).toWire(),
        'ack' => RunAck.fromWire(payload).toWire(),
        'cancel' => CancelRun.fromWire(payload).toWire(),
        'conv' => conversationFromWire(payload).toWire(),
        _ => throw StateError('bad kind'),
      };
      out.send(back);
    } catch (e, s) {
      out.send('ERR $e $s');
    }
  });
}

Future<Object?> _roundTripInIsolate(
  SendPort iso,
  StreamIterator<Object?> it,
  String kind,
  Map<String, Object?> payload,
) async {
  iso.send({'_kind': kind, 'payload': payload});
  expect(await it.moveNext(), isTrue);
  return it.current;
}

void main() {
  group('models', () {
    test('messages round-trip', () {
      for (final m in _messages()) {
        expect(messageFromWire(m.toWire()), m, reason: '${m.runtimeType}');
      }
    });

    test('conversation round-trips', () {
      final c = Conversation(
        id: 'c',
        title: 't',
        createdAt: _t,
        updatedAt: _t,
        messages: _messages(),
        systemPrompt: 'sp',
        titleSource: 'generated',
        titleRevision: 2,
        contentRevision: 3,
        agentId: 'agent1',
      );
      expect(conversationFromWire(c.toWire()), c);
    });

    test('model config, metadata, receipt, log context', () {
      const cfg = ModelConfig.defaultConfig;
      expect(modelConfigFromWire(cfg.toWire()), cfg);
      const md = AgentMessageMetadata(
        toolCalls: [
          {'a': 1},
        ],
        model: 'm',
        isError: true,
        microsecondTimestamp: 5,
      );
      expect(agentMessageMetadataFromWire(md.toWire()).encode(), md.encode());
      expect(toolInvocationReceiptFromWire(_receipt.toWire()), _receipt);
      const ctx = LogContext(conversationId: 'c', runId: 'r', turn: 2);
      expect(logContextFromWire(ctx.toWire()).toJson(), ctx.toJson());
    });
  });

  group('events', () {
    test('every event round-trips', () {
      for (final e in _events()) {
        final back = agentEventFromWire(agentEventToWire(e, ackId: 'k'));
        expect(back.runtimeType, e.runtimeType);
        expect(_norm(back), _norm(e), reason: '${e.runtimeType}');
      }
    });

    test('ack id is carried only by acknowledgeable events', () {
      for (final e in _events()) {
        final w = agentEventToWire(e, ackId: 'k');
        final carries =
            e is ModelTurnCompletedEvent || e is ToolCallCompletedEvent;
        expect(w['ackId'], carries ? 'k' : isNull, reason: '${e.runtimeType}');
      }
    });

    test('acknowledgement completer is attached on decode', () async {
      final c = Completer<void>();
      final e = _events().whereType<ModelTurnCompletedEvent>().first;
      final back =
          agentEventFromWire(
                agentEventToWire(e, ackId: 'k'),
                acknowledgement: c,
              )
              as ModelTurnCompletedEvent;
      expect(identical(back.acknowledgement, c), isTrue);
      back.acknowledge();
      await c.future;
    });

    test('failure error and stack trace survive as strings', () {
      final e = _events().whereType<AgentRunFailedEvent>().first;
      final back =
          agentEventFromWire(agentEventToWire(e)) as AgentRunFailedEvent;
      expect(back.error, isA<RemoteAgentError>());
      final err = back.error as RemoteAgentError;
      expect(err.type, 'StateError');
      expect(err.message, contains('boom'));
      expect(back.stackTrace.toString(), 'trace here');
    });
  });

  group('run messages', () {
    final port = ReceivePort();
    tearDownAll(port.close);

    StartRun start() => StartRun(
      runId: 'r',
      sessionId: 's',
      generationId: 'g',
      history: _messages(),
      userPrompt: _messages().first as UserMessage,
      modelConfig: ModelConfig.defaultConfig,
      apiKey: 'k',
      allowedTools: const ['a', 'b'],
      maxTurns: 4,
      mcpProfiles: const ['p'],
      eventsPort: port.sendPort,
    );

    test('StartRun round-trips', () {
      final s = start();
      final b = StartRun.fromWire(s.toWire());
      expect(b.runId, 'r');
      expect(b.sessionId, 's');
      expect(b.generationId, 'g');
      expect(b.history, s.history);
      expect(b.userPrompt, s.userPrompt);
      expect(b.modelConfig, s.modelConfig);
      expect(b.apiKey, 'k');
      expect(b.allowedTools, ['a', 'b']);
      expect(b.maxTurns, 4);
      expect(b.mcpProfiles, ['p']);
      expect(b.eventsPort, port.sendPort);
      final n = StartRun.fromWire(
        StartRun(
          runId: 'r',
          sessionId: 's',
          generationId: 'g',
          history: const [],
          userPrompt: s.userPrompt,
          modelConfig: s.modelConfig,
          allowedTools: null,
          maxTurns: 1,
          mcpProfiles: const [],
          eventsPort: port.sendPort,
        ).toWire(),
      );
      expect(n.apiKey, isNull);
      expect(n.allowedTools, isNull);
    });

    test('RunAck and CancelRun round-trip', () {
      const ack = RunAck(runId: 'r', ackId: 'a', ok: false, error: 'bad');
      final b = RunAck.fromWire(ack.toWire());
      expect((b.runId, b.ackId, b.ok, b.error), ('r', 'a', false, 'bad'));
      expect(
        CancelRun.fromWire(const CancelRun(runId: 'r').toWire()).runId,
        'r',
      );
    });
  });

  test('encoded maps cross a real isolate and decode there', () async {
    final replies = ReceivePort();
    final it = StreamIterator<Object?>(replies);
    final isolate = await Isolate.spawn(_entry, replies.sendPort);
    expect(await it.moveNext(), isTrue);
    final iso = it.current as SendPort;
    final events = ReceivePort();

    try {
      for (final e in _events()) {
        iso.send({
          '_kind': 'event',
          'payload': agentEventToWire(e, ackId: 'k'),
        });
        expect(await it.moveNext(), isTrue);
        final reply = it.current;
        expect(reply, isA<Map>(), reason: '${e.runtimeType}: $reply');
        final back = agentEventFromWire((reply as Map).cast<String, Object?>());
        expect(_norm(back), _norm(e), reason: '${e.runtimeType}');
      }

      final s = StartRun(
        runId: 'r',
        sessionId: 's',
        generationId: 'g',
        history: _messages(),
        userPrompt: _messages().first as UserMessage,
        modelConfig: ModelConfig.defaultConfig,
        apiKey: 'k',
        allowedTools: const ['a'],
        maxTurns: 4,
        mcpProfiles: const ['p'],
        eventsPort: events.sendPort,
      );
      var r = await _roundTripInIsolate(iso, it, 'start', s.toWire());
      expect(r, isA<Map>(), reason: '$r');
      expect(
        StartRun.fromWire((r as Map).cast<String, Object?>()).history,
        s.history,
      );

      r = await _roundTripInIsolate(
        iso,
        it,
        'ack',
        const RunAck(runId: 'r', ackId: 'a', ok: true).toWire(),
      );
      expect(r, isA<Map>(), reason: '$r');
      r = await _roundTripInIsolate(
        iso,
        it,
        'cancel',
        const CancelRun(runId: 'r').toWire(),
      );
      expect(r, isA<Map>(), reason: '$r');

      final conv = Conversation(
        id: 'c',
        title: 't',
        createdAt: _t,
        updatedAt: _t,
        messages: _messages(),
        agentId: 'x',
      );
      r = await _roundTripInIsolate(iso, it, 'conv', conv.toWire());
      expect(r, isA<Map>(), reason: '$r');
      expect(conversationFromWire((r as Map).cast<String, Object?>()), conv);
    } finally {
      await it.cancel();
      isolate.kill(priority: Isolate.immediate);
      events.close();
    }
  });
}
