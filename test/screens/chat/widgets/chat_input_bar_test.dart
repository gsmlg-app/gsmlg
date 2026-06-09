import 'dart:convert';
import 'dart:typed_data';

import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';

void main() {
  FilePicker? previousFilePicker;

  setUp(() {
    try {
      previousFilePicker = FilePicker.platform;
    } catch (_) {
      previousFilePicker = null;
    }
  });

  tearDown(() {
    if (previousFilePicker != null) {
      FilePicker.platform = previousFilePicker!;
    }
  });

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
            onSend: (_, {imageBytes, audioBytes, attachments}) {},
            onStop: () {},
          ),
        ),
      ),
    );

    expect(find.byType(Switch), findsNothing);
    expect(find.text('High'), findsNothing);

    await tester.tap(find.byTooltip('Thinking: High'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Max').last);
    await tester.pumpAndSettle();

    expect(selected, RemoteThinkingEffort.max);
  });

  testWidgets('selects boolean thinking state from the thinking icon', (
    tester,
  ) async {
    bool? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            thinkingEnabled: false,
            onThinkingToggle: (value) => selected = value,
            onSend: (_, {imageBytes, audioBytes, attachments}) {},
            onStop: () {},
          ),
        ),
      ),
    );

    expect(find.byType(Switch), findsNothing);

    await tester.tap(find.byTooltip('Thinking: Off'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On').last);
    await tester.pumpAndSettle();

    expect(selected, isTrue);
  });

  testWidgets('attaches a file and sends it with the message', (tester) async {
    FilePicker.platform = _FakeFilePicker(
      FilePickerResult([
        PlatformFile(
          name: 'notes.txt',
          size: 15,
          bytes: Uint8List.fromList(utf8.encode('hello from file')),
        ),
      ]),
    );

    String? sentText;
    List<ChatAttachment>? sentAttachments;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            onSend: (text, {imageBytes, audioBytes, attachments}) {
              sentText = text;
              sentAttachments = attachments;
            },
            onStop: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Attach'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('notes.txt'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'summarize');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();

    expect(sentText, 'summarize');
    expect(sentAttachments, hasLength(1));
    expect(sentAttachments!.single.name, 'notes.txt');
    expect(utf8.decode(sentAttachments!.single.bytes!), 'hello from file');
  });

  testWidgets('can change agent when chat input is disabled', (tester) async {
    String? selectedAgentId;
    final agents = [
      ChatAgent(id: 'agent1', name: 'Agent 1', config: ModelConfig.defaultConfig),
      ChatAgent(id: 'agent2', name: 'Agent 2', config: ModelConfig.defaultConfig),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            enabled: false,
            selectedAgentName: 'Agent 1',
            selectedAgentId: 'agent1',
            agents: agents,
            onAgentSelect: (id) => selectedAgentId = id,
            onSend: (_, {imageBytes, audioBytes, attachments}) {},
            onStop: () {},
          ),
        ),
      ),
    );

    // Verify it displays Agent 1
    expect(find.text('Agent 1'), findsNWidgets(2));

    // Tap the agent selector in the overlay
    await tester.tap(find.text('Agent 1').last);
    await tester.pumpAndSettle();

    // Verify popup menu is shown with Agent 2
    expect(find.text('Agent 2'), findsOneWidget);

    // Select Agent 2
    await tester.tap(find.text('Agent 2'));
    await tester.pumpAndSettle();

    expect(selectedAgentId, 'agent2');
  });
}

class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.result);

  final FilePickerResult? result;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return result;
  }
}
