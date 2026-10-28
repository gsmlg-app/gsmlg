import 'dart:io';
import 'dart:ffi';
import 'package:app_chat/app_chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lib_llama_cpp_server/lib_llama_cpp_server.dart';

/// Opt-in actual inference: no fake backend and no networking APIs.
/// TITLE_MODEL_PATH and TITLE_LIBRARY_PATH must point at installed/package files.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final model = Platform.environment['TITLE_MODEL_PATH'];
  final library = Platform.environment['TITLE_LIBRARY_PATH'];
  test(
    'pinned MiniCPM generates a title using the official GGUF template offline',
    () async {
      final backend = MiniCpmTitleBackend(
        modelPath: model,
        libraryPath: library,
      );
      final generator = EmbeddedConversationTitleGenerator(
        backend,
        timeout: const Duration(seconds: 60),
      );
      addTearDown(generator.dispose);
      final conversation = Conversation.create(id: 'offline').copyWith(
        messages: [
          UserMessage(
            id: 'u',
            content: '如何设计可复用的 Flutter 手柄组件？',
            conversationId: 'offline',
            timestamp: DateTime(2026),
          ),
          AssistantMessage(
            id: 'a',
            content: '用独立 controller 管理状态，自定义 Widget 展示手柄按钮。',
            conversationId: 'offline',
            timestamp: DateTime(2026),
          ),
        ],
      );
      final timer = Stopwatch()..start();
      final title = await generator.generate(conversation);
      // This is model behavior, not a hardcoded topic mapping.
      expect(title, isNotNull);
      expect(title, contains('Flutter'));
      expect(title, anyOf(contains('组件'), contains('手柄')));
      expect(title, isNot(contains('\n')));
      // ignore: avoid_print
      print(
        'MiniCPM native title=$title cold_total_ms=${timer.elapsedMilliseconds}',
      );
    },
    skip: model == null || library == null,
    timeout: const Timeout(Duration(minutes: 2)),
  );
  test(
    'title engine teardown preserves an independently loaded chat engine',
    () async {
      final primary = LlcsEngine.open(
        library: DynamicLibrary.open(library!),
        config: LlcsEngineConfig(
          modelPath: model!,
          nCtx: 2048,
          nGpuLayers: 0,
          nThreads: 4,
          nThreadsBatch: 4,
          nBatch: 128,
          nUbatch: 64,
          useJinja: true,
        ),
      );
      addTearDown(primary.close);
      Future<String> reply() async {
        final text = StringBuffer();
        await for (final event in primary.stream({
          'messages': [
            {'role': 'user', 'content': 'Say hello in English.'},
          ],
          'stream': true,
          'max_tokens': 16,
          'temperature': 0.0,
          'seed': 42,
          'chat_template_kwargs': {'enable_thinking': false},
        })) {
          for (final choice in event['choices'] as List? ?? const []) {
            final delta = choice['delta'];
            if (delta is Map && delta['content'] is String) {
              text.write(delta['content']);
            }
          }
        }
        return text.toString();
      }

      final before = await reply();
      expect(before, isNotEmpty);
      final backend = MiniCpmTitleBackend(
        modelPath: model,
        libraryPath: library,
      );
      final title = await backend.infer([
        {
          'role': 'user',
          'content': 'Return one short title about Flutter widgets.',
        },
      ]);
      expect(title, isNotEmpty);
      await backend.dispose();
      expect(await reply(), before);
    },
    skip: model == null || library == null,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
