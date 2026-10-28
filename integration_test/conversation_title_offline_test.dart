import 'dart:io';
import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'installed bundle generates a title with Dart networking disabled',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Offline title smoke test')),
        ),
      );
      final backend = MiniCpmTitleBackend();
      final generator = EmbeddedConversationTitleGenerator(backend);
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
      final title = await HttpOverrides.runZoned(
        () => generator.generate(conversation),
        createHttpClient: (_) =>
            throw StateError('Networking is disabled in this smoke test'),
      );
      expect(title, isNotNull);
      expect(title, contains('Flutter'));
      expect(title, anyOf(contains('组件'), contains('手柄')));
      expect(title, isNot(contains('\n')));
      // ignore: avoid_print
      print(
        'BUNDLED_TITLE_SMOKE platform=${Platform.operatingSystem} title=$title total_ms=${timer.elapsedMilliseconds}',
      );
    },
  );
}
