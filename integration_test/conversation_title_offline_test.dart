import 'dart:io';
import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    testWidgets('Windows platform plugins return real UTC and version data', (
      tester,
    ) async {
      for (final name in ['app_client_info', 'app_system_metrics']) {
        final channel = MethodChannel(name);
        final data = await channel.invokeMapMethod<String, dynamic>('getData');
        expect(data, isNotNull);
        expect(data!['platform'], 'windows');
        final timestamp = DateTime.parse(data['timestamp'] as String);
        expect(timestamp.isUtc, isTrue);
        expect(
          DateTime.now().difference(timestamp).abs(),
          lessThan(const Duration(minutes: 1)),
        );
        final details = data['additionalData'] as Map;
        expect(details['majorVersion'], greaterThanOrEqualTo(10));
        expect(details['minorVersion'], greaterThanOrEqualTo(0));
        expect(details['buildNumber'], greaterThan(0));
        expect(details['numberOfProcessors'], greaterThan(0));
        expect(details['totalPhysicalMemory'], greaterThan(0));
        await channel.invokeMethod<void>('refresh');
        final refreshed = await channel.invokeMapMethod<String, dynamic>(
          'getData',
        );
        expect(
          (refreshed!['additionalData'] as Map)['buildNumber'],
          details['buildNumber'],
        );
        // ignore: avoid_print
        print(
          'WINDOWS_PLATFORM_SMOKE channel=$name build=${details['buildNumber']} utc=$timestamp '
          'cpu_count=${details['numberOfProcessors']} total_memory_bytes=${details['totalPhysicalMemory']}',
        );
      }
    });
  }
  testWidgets('installed bundle generates a title with Dart networking disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Offline title smoke test'))),
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
    timer.stop();
    expect(ProcessInfo.maxRss, greaterThan(0));
    // ignore: avoid_print
    print(
      'BUNDLED_TITLE_SMOKE platform=${Platform.operatingSystem} title=$title total_ms=${timer.elapsedMilliseconds} '
      'peak_rss_bytes=${ProcessInfo.maxRss} current_rss_bytes=${ProcessInfo.currentRss} '
      'cpu_count=${Platform.numberOfProcessors}',
    );
    final repeated = Stopwatch()..start();
    final repeatedTitle = await HttpOverrides.runZoned(
      () => generator.generate(conversation),
      createHttpClient: (_) =>
          throw StateError('Networking is disabled in this smoke test'),
    );
    repeated.stop();
    expect(repeatedTitle, title);
    // ignore: avoid_print
    print(
      'BUNDLED_TITLE_REPEAT platform=${Platform.operatingSystem} repeat_total_ms=${repeated.elapsedMilliseconds} '
      'peak_rss_bytes=${ProcessInfo.maxRss} current_rss_bytes=${ProcessInfo.currentRss}',
    );
  });
}
