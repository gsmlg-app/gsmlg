import 'dart:async';

import '../models/inference.dart';
import '../models/message.dart';
import '../models/model_config.dart';
import '../repositories/gemma_repository.dart';
import '../repositories/local_model_access.dart';

/// On-device model generation.
///
/// The native model lives on the main isolate; agent isolates receive a
/// bridged implementation instead.
abstract interface class LocalLlmGateway {
  Stream<ChatGenerationChunk> generate(
    List<Message> messages, {
    required ModelConfig config,
    List<Map<String, dynamic>> tools,
  });

  Future<void> stop();
}

/// Main-isolate [LocalLlmGateway] backed by [GemmaRepository].
///
/// When [access] is given, each generation holds a FIFO local-model lease
/// from listen until the stream ends or is cancelled.
class GemmaLocalLlmGateway implements LocalLlmGateway {
  GemmaLocalLlmGateway(this._gemma, {LocalModelAccess? access})
    : _access = access;

  final GemmaRepository _gemma;
  final LocalModelAccess? _access;

  @override
  Stream<ChatGenerationChunk> generate(
    List<Message> messages, {
    required ModelConfig config,
    List<Map<String, dynamic>> tools = const [],
  }) {
    final access = _access;
    if (access == null) {
      return _gemma.generateResponse(messages, config: config, tools: tools);
    }
    LocalModelLease? lease;
    StreamSubscription<ChatGenerationChunk>? sub;
    var cancelled = false;
    late final StreamController<ChatGenerationChunk> controller;

    void release() {
      lease?.release();
      lease = null;
    }

    controller = StreamController<ChatGenerationChunk>(
      onListen: () async {
        final acquired = await access.acquire();
        if (cancelled) return acquired.release();
        lease = acquired;
        try {
          sub = _gemma
              .generateResponse(messages, config: config, tools: tools)
              .listen(
                controller.add,
                onError: controller.addError,
                onDone: () {
                  release();
                  controller.close();
                },
              );
        } catch (e, st) {
          release();
          controller.addError(e, st);
          await controller.close();
        }
      },
      // Release immediately: a generator blocked between yields would
      // otherwise hold the lease until its next token.
      onCancel: () {
        cancelled = true;
        release();
        unawaited(sub?.cancel());
        sub = null;
      },
    );
    return controller.stream;
  }

  @override
  Future<void> stop() => _gemma.stopGeneration();
}
