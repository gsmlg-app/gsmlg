import 'dart:convert';

import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/chat_input_bar.dart';
import 'package:gsmlg/screens/chat/widgets/system_metrics_indicator.dart';

void main() {
  const systemMetricsChannel = MethodChannel('app_system_metrics');
  late FilePickerPlatform previousFilePicker;

  setUp(() {
    previousFilePicker = FilePickerPlatform.instance;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(systemMetricsChannel, (call) async {
          if (call.method != 'getData') return null;
          return {
            'platform': 'test',
            'timestamp': DateTime(2026).toIso8601String(),
            'cpuUsage': 0.0,
            'gpuUsage': 0.0,
            'npuUsage': 0.0,
            'memoryUsage': 0.0,
          };
        });
  });

  tearDown(() {
    FilePickerPlatform.instance = previousFilePicker;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(systemMetricsChannel, null);
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
          body: ChatInputBar(
            onSend: (text, {imageBytes, audioBytes, attachments}) {},
            onStop: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Attach'));
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
      ChatAgent(
        id: 'agent1',
        name: 'Agent 1',
        config: ModelConfig.defaultConfig,
      ),
      ChatAgent(
        id: 'agent2',
        name: 'Agent 2',
        config: ModelConfig.defaultConfig,
      ),
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

  testWidgets('shows system metrics in the chat input controls', (
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

    expect(find.byType(SystemMetricsIndicator), findsOneWidget);
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
