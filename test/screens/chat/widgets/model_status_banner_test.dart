import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/model_status_banner.dart';

void main() {
  testWidgets('marks model loading as expected system memory use', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ModelStatusBanner(
            state: GemmaModelState(
              status: GemmaModelStatus.loading,
              selectedModelId: 'gemma-4-E4B-it',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Loading Gemma 4 E4B IT...'), findsOneWidget);
    expect(find.text('Uses system memory while loaded'), findsOneWidget);
    expect(find.textContaining('large-memory model'), findsNothing);
  });
}
