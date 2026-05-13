import 'package:app_chat/src/models/message.dart';
import 'package:test/test.dart';

void main() {
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
