import 'package:app_chat/app_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';

void main() {
  testWidgets('selects remote thinking effort from the chat input', (
    tester,
  ) async {
    RemoteThinkingEffort? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            thinkingEffort: RemoteThinkingEffort.high,
            onThinkingEffortChanged: (value) => selected = value,
            onSend: (_, {imageBytes, audioBytes}) {},
            onStop: () {},
          ),
        ),
      ),
    );

    expect(find.text('High'), findsOneWidget);

    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Max').last);
    await tester.pumpAndSettle();

    expect(selected, RemoteThinkingEffort.max);
  });
}
