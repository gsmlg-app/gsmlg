import 'dart:convert';
import 'dart:typed_data';

import 'package:app_agent/app_agent.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/agents/agent_model_config.dart';
import 'package:gsmlg/screens/chat/widgets/chat_composer_popovers.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';
import 'package:gsmlg/screens/chat/widgets/clipboard_attachments.dart';
import 'package:gsmlg/screens/chat/widgets/system_metrics_indicator.dart';

void main() {
  late FilePickerPlatform previousFilePicker;

  setUp(() {
    previousFilePicker = FilePickerPlatform.instance;
  });

  tearDown(() {
    FilePickerPlatform.instance = previousFilePicker;
    ClipboardAttachments.readerOverride = null;
  });

  testWidgets('selects remote thinking effort from the chat input', (
    tester,
  ) async {
    RemoteThinkingEffort? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              selectedModelName: 'GPT-6.2 Astra',
              thinkingEffort: RemoteThinkingEffort.high,
              onThinkingEffortChanged: (value) => selected = value,
              onSend: (_, {imageBytes, audioBytes, attachments}) {},
              onStop: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Switch), findsNothing);
    expect(find.text('GPT-6.2 Astra'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);

    await tester.tap(find.byTooltip('Thinking: High'));
    await tester.pumpAndSettle();
    expect(find.text('Select effort'), findsOneWidget);
    await tester.tap(find.text('Max').last);
    await tester.pumpAndSettle();

    expect(selected, RemoteThinkingEffort.max);
  });

  testWidgets('selects boolean thinking state from the effort popover', (
    tester,
  ) async {
    bool? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              selectedModelName: 'MiniMax-M3',
              thinkingEnabled: false,
              onThinkingToggle: (value) => selected = value,
              onSend: (_, {imageBytes, audioBytes, attachments}) {},
              onStop: () {},
            ),
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

  testWidgets('attaches a file from the + menu and sends it with the message', (
    tester,
  ) async {
    FilePickerPlatform.instance = _FakeFilePicker([
      _MemoryPlatformFile(
        name: 'notes.txt',
        bytes: Uint8List.fromList(utf8.encode('hello from file')),
      ),
    ]);

    String? sentText;
    List<ChatAttachment>? sentAttachments;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              onSend: (text, {imageBytes, audioBytes, attachments}) {
                sentText = text;
                sentAttachments = attachments;
              },
              onStop: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Files and folders'));
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

  testWidgets('an unreadable picked file remains an error attachment', (
    tester,
  ) async {
    FilePickerPlatform.instance = _FakeFilePicker([
      _MemoryPlatformFile(
        name: 'missing.txt',
        bytes: Uint8List(0),
        unreadable: true,
      ),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              onSend: (text, {imageBytes, audioBytes, attachments}) {},
              onStop: () {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Files and folders'));
    await tester.pump();
    final attachment = tester
        .widget<DmChatInput>(find.byType(DmChatInput))
        .pendingAttachments
        .single;
    expect(attachment.name, 'missing.txt');
    expect(attachment.status, DmChatAttachmentStatus.error);
    expect(attachment.errorMessage, 'Unable to read file');
    expect(tester.takeException(), isNull);
  });

  testWidgets('can change agent when chat input is disabled', (tester) async {
    String? selectedAgentId;
    final agents = [
      AgentDefinition(
        id: 'agent1',
        name: 'Agent 1',
        config: ModelConfig.defaultConfig,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      AgentDefinition(
        id: 'agent2',
        name: 'Agent 2',
        config: ModelConfig.defaultConfig,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
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
      ),
    );

    // Verify it displays Agent 1 in the disabled overlay
    expect(find.text('Agent 1'), findsOneWidget);

    // Tap the agent selector in the overlay
    await tester.tap(find.text('Agent 1'));
    await tester.pumpAndSettle();

    // Verify popup menu is shown with Agent 2
    expect(find.text('Agent 2'), findsOneWidget);

    // Select Agent 2
    await tester.tap(find.text('Agent 2'));
    await tester.pumpAndSettle();

    expect(selectedAgentId, 'agent2');
  });

  testWidgets('does not show system metrics in the chat input controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            onSend: (_, {imageBytes, audioBytes, attachments}) {},
            onStop: () {},
          ),
        ),
      ),
    );

    expect(find.byType(SystemMetricsIndicator), findsNothing);
  });

  testWidgets('removes a completed pending attachment via its remove button', (
    tester,
  ) async {
    FilePickerPlatform.instance = _FakeFilePicker([
      _MemoryPlatformFile(
        name: 'id.pdf',
        bytes: Uint8List.fromList(utf8.encode('%PDF-1.7')),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              onSend: (_, {imageBytes, audioBytes, attachments}) {},
              onStop: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Files and folders'));
    await tester.pumpAndSettle();
    expect(find.text('id.pdf'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('id.pdf'), findsNothing);
  });

  testWidgets('pastes clipboard files via + menu and Cmd/Ctrl+V shortcut', (
    tester,
  ) async {
    ClipboardAttachments.readerOverride = () async => [
      ClipboardAttachmentData(
        name: 'pasted.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList(utf8.encode('pdf-bytes')),
        sizeBytes: 9,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              onSend: (_, {imageBytes, audioBytes, attachments}) {},
              onStop: () {},
            ),
          ),
        ),
      ),
    );

    // 1. Paste via + menu
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paste from clipboard'));
    await tester.pumpAndSettle();
    expect(find.text('pasted.pdf'), findsOneWidget);

    // Remove it first, then paste via keyboard shortcut
    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('pasted.pdf'), findsNothing);

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.text('pasted.pdf'), findsOneWidget);
  });

  testWidgets('selects permission mode from bottom-left pill popover', (
    tester,
  ) async {
    ChatPermissionMode? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              permissionMode: ChatPermissionMode.fullAccess,
              onPermissionModeChanged: (mode) => selected = mode,
              onSend: (_, {imageBytes, audioBytes, attachments}) {},
              onStop: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Full access'), findsOneWidget);
    await tester.tap(find.text('Full access'));
    await tester.pumpAndSettle();

    expect(find.text('How should Agent actions be approved?'), findsOneWidget);
    expect(find.text('Ask for approval'), findsOneWidget);
    expect(find.text('Approve for me'), findsOneWidget);

    await tester.tap(find.text('Approve for me'));
    await tester.pumpAndSettle();
    expect(selected, ChatPermissionMode.approveForMe);
    expect(find.text('Approve for me'), findsOneWidget);
  });

  testWidgets('switches model and thinking effort from right model popover', (
    tester,
  ) async {
    AgentModelChoice? pickedModel;
    RemoteThinkingEffort? pickedEffort;

    const choices = [
      AgentModelChoice(
        title: 'MiniMax-M3',
        subtitle: 'Backplane',
        icon: Icons.cloud_queue,
        config: ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteModel: 'MiniMax-M3',
        ),
      ),
      AgentModelChoice(
        title: 'claude-sonnet',
        subtitle: 'Backplane',
        icon: Icons.cloud_queue,
        config: ModelConfig(
          inferenceMode: ChatInferenceMode.remote,
          remoteModel: 'claude-sonnet',
        ),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              selectedModelName: 'MiniMax-M3',
              modelChoices: choices,
              onModelChoiceSelect: (choice) => pickedModel = choice,
              thinkingEffort: RemoteThinkingEffort.high,
              onThinkingEffortChanged: (effort) => pickedEffort = effort,
              onSend: (_, {imageBytes, audioBytes, attachments}) {},
              onStop: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('MiniMax-M3'));
    await tester.pumpAndSettle();
    expect(find.text('Select effort'), findsOneWidget);

    // Switch thinking effort
    await tester.tap(find.text('Max').last);
    await tester.pumpAndSettle();
    expect(pickedEffort, RemoteThinkingEffort.max);

    // Open inline model picker inside the same popover
    await tester.tap(find.text('MiniMax-M3').last);
    await tester.pumpAndSettle();
    expect(find.text('Select model'), findsOneWidget);
    expect(find.text('claude-sonnet'), findsOneWidget);

    await tester.tap(find.text('claude-sonnet'));
    await tester.pumpAndSettle();
    expect(pickedModel?.title, 'claude-sonnet');
  });

  testWidgets('shows editing banner and supports cancel button and Escape', (
    tester,
  ) async {
    var cancelCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            conversationId: 'conv-1',
            editingMessageId: 'msg-1',
            draft: const ChatDraft(
              text: 'original prompt',
              selectionBase: 15,
              selectionExtent: 15,
            ),
            onCancelEdit: () => cancelCount++,
            onSend: (_, {imageBytes, audioBytes, attachments}) {},
            onStop: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chat-editing-banner')), findsOneWidget);
    expect(find.text('original prompt'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('chat-editing-cancel')));
    await tester.pump();
    expect(cancelCount, 1);

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(cancelCount, 2);
  });

  testWidgets('normalizes oversized pasted images into compact JPEG', (
    tester,
  ) async {
    final bigPng = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 1, 2, 3, 4, 5]);
    // Valid 1x1 white JPEG so Image.memory decodes the preview cleanly.
    final compactJpeg = base64Decode(
      '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////'
      '////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFAAB'
      'AAAAAAAAAAAAAAAAAAAACf/aAAgBAQABPxA=',
    );
    ClipboardAttachments.readerOverride = () async => [
      ClipboardAttachmentData(
        name: 'retina_shot.png',
        mimeType: 'image/png',
        sizeBytes: bigPng.length,
        bytes: bigPng,
      ),
    ];
    ClipboardAttachments.normalizerOverride =
        (
          bytes, {
          int maxDimension = 1568,
          int quality = 82,
          int maxBytes = 512 * 1024,
        }) async => NormalizedImageData(
          bytes: compactJpeg,
          mimeType: 'image/jpeg',
          extension: 'jpg',
        );
    addTearDown(() {
      ClipboardAttachments.readerOverride = null;
      ClipboardAttachments.normalizerOverride = null;
    });

    List<ChatAttachment>? sentAttachments;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              supportsImage: true,
              onSend: (_, {imageBytes, audioBytes, attachments}) {
                sentAttachments = attachments;
              },
              onStop: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paste from clipboard'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Send'));
    await tester.pump();

    expect(sentAttachments, hasLength(1));
    expect(sentAttachments!.single.name, 'retina_shot.jpg');
    expect(sentAttachments!.single.mimeType, 'image/jpeg');
    expect(sentAttachments!.single.bytes, compactJpeg);
  });
}

class _FakeFilePicker extends FilePickerPlatform {
  _FakeFilePicker(this.result);

  final List<PlatformFile> result;

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    return result;
  }
}

final class _MemoryPlatformFile extends PlatformFile {
  _MemoryPlatformFile({
    required this.name,
    required this.bytes,
    this.unreadable = false,
  });

  @override
  final String name;
  final Uint8List bytes;
  final bool unreadable;

  @override
  Uri get uri => Uri.dataFromBytes(bytes);

  @override
  get xFile => throw UnimplementedError();

  @override
  int lengthSync() => bytes.length;

  @override
  Future<int> length() async => bytes.length;

  @override
  Future<Uint8List> readAsBytes() async {
    if (unreadable) throw StateError('File is unreadable');
    return bytes;
  }

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}
