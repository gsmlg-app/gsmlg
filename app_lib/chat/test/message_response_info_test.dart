import 'package:app_chat/src/models/message.dart';
import 'package:test/test.dart';

void main() {
  test('excludes first-token latency from output throughput and equality', () {
    const info = ChatResponseInfo(
      outputTokens: 42,
      duration: Duration(seconds: 2),
      timeToFirstToken: Duration(milliseconds: 500),
    );
    const legacy = ChatResponseInfo(
      outputTokens: 42,
      duration: Duration(seconds: 2),
    );
    expect(info.tokensPerSecond, 28);
    expect(legacy.tokensPerSecond, 21);
    expect(legacy.timeToFirstToken, isNull);
    expect(info, isNot(legacy));
  });

  for (final duration in [Duration.zero, const Duration(milliseconds: 500)]) {
    for (final latency in [
      null,
      Duration.zero,
      const Duration(milliseconds: 500),
      const Duration(seconds: 1),
    ]) {
      test('handles throughput interval $duration minus $latency', () {
        final info = ChatResponseInfo(
          outputTokens: 42,
          duration: duration,
          timeToFirstToken: latency,
        );
        expect(
          info.tokensPerSecond,
          duration > (latency ?? Duration.zero) ? 84 : 0,
        );
      });
    }
  }

  test('assistant messages carry response generation info', () {
    const info = ChatResponseInfo(
      outputTokens: 42,
      contextTokens: 512,
      maxOutputTokens: 2048,
      duration: Duration(seconds: 2),
    );

    final message = AssistantMessage(
      id: 'assistant',
      content: 'hello',
      conversationId: 'conversation',
      timestamp: DateTime(2026),
      responseInfo: info,
    );

    expect(message.responseInfo, info);
    expect(message.responseInfo!.tokensPerSecond, 21);
    expect(message.copyWith(content: 'updated').responseInfo, info);
  });
}
