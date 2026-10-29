import 'dart:async';
import 'dart:convert';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_locale/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:terminal_settings/terminal_settings.dart';

final class _MemoryFile extends PlatformFile {
  _MemoryFile(this.readBytes);

  final Future<Uint8List> Function() readBytes;
  int readCount = 0;

  @override
  String get name => 'servers';

  @override
  Uri get uri => Uri.parse('content://test.documents/document/servers');

  @override
  Never get xFile => throw UnsupportedError('Use readAsBytes');

  @override
  int? lengthSync() => null;

  @override
  Future<int?> length() async => null;

  @override
  Future<Uint8List> readAsBytes() {
    readCount++;
    return readBytes();
  }

  @override
  Stream<Uint8List> readAsByteStream() async* {
    yield await readAsBytes();
  }
}

class _FilePicker extends FilePickerPlatform {
  Future<PlatformFile?> Function() pick = () async => null;
  FileType? requestedType;
  List<String>? requestedExtensions;

  @override
  Future<PlatformFile?> pickFile({
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
  }) {
    requestedType = type;
    requestedExtensions = allowedExtensions;
    return pick();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late SshKeyBloc keys;
  late SshKeyFormBloc form;
  late _FilePicker picker;
  late FilePickerPlatform originalPicker;

  setUp(() {
    database = AppDatabase.forTesting();
    keys = SshKeyBloc(database);
    form = SshKeyFormBloc(keys);
    originalPicker = FilePickerPlatform.instance;
    picker = _FilePicker();
    FilePickerPlatform.instance = picker;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final asset = utf8.decode(message!.buffer.asUint8List());
      if (asset == 'AssetManifest.bin') {
        return const StandardMessageCodec().encodeMessage({
          'RobotoMono-Regular.ttf': [
            {'asset': 'RobotoMono-Regular.ttf'},
          ],
        });
      }
      if (asset == 'RobotoMono-Regular.ttf') return ByteData(0);
      return null;
    });
  });

  tearDown(() async {
    FilePickerPlatform.instance = originalPicker;
    await form.close();
    await keys.close();
    await database.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  Future<void> openForm(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SshKeyBloc>.value(value: keys),
          BlocProvider<SshKeyFormBloc>.value(value: form),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showSshKeyForm(context: context),
                child: const Text('Open key form'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open key form'));
    await tester.pumpAndSettle();
  }

  Future<void> enterExistingValues(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'My phone');
    await tester.ensureVisible(find.byType(TextField).last);
    await tester.enterText(
        find.byType(TextField).last, 'existing test content');
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Import from file'));
    await tester.pumpAndSettle();
  }

  void expectExistingValues() {
    expect(form.name.value, 'My phone');
    expect(form.content.value, 'existing test content');
    expect(find.text('My phone'), findsOneWidget);
    expect(find.text('existing test content'), findsOneWidget);
  }

  testWidgets('imports an extensionless content URI and uses its filename',
      (tester) async {
    const content = 'synthetic test key\n第二行\n';
    final file =
        _MemoryFile(() async => Uint8List.fromList(utf8.encode(content)));
    picker.pick = () async => file;
    await openForm(tester);

    expect(find.text('Import from file'), findsOneWidget);
    await tester.tap(find.text('Import from file'));
    await tester.pumpAndSettle();

    expect(file.path, isNull);
    expect(file.extension, isNull);
    expect(file.readCount, 1);
    expect(picker.requestedType, FileType.any);
    expect(picker.requestedExtensions, isNull);
    expect(form.content.value, content);
    expect(form.name.value, 'servers');
    expect(find.text(content), findsOneWidget);
    expect(find.text('servers'), findsOneWidget);
  });

  testWidgets('preserves a name entered before importing', (tester) async {
    picker.pick = () async => _MemoryFile(
          () async => Uint8List.fromList(utf8.encode('imported test content')),
        );
    await openForm(tester);
    await tester.enterText(find.byType(TextField).first, 'My phone');

    await tester.tap(find.text('Import from file'));
    await tester.pumpAndSettle();

    expect(form.name.value, 'My phone');
    expect(form.content.value, 'imported test content');
    expect(find.text('My phone'), findsOneWidget);
    expect(find.text('imported test content'), findsOneWidget);
  });

  testWidgets('canceling the picker leaves existing values unchanged',
      (tester) async {
    await openForm(tester);
    await enterExistingValues(tester);

    await tester.tap(find.text('Import from file'));
    await tester.pumpAndSettle();

    expectExistingValues();
    expect(find.byType(SnackBar), findsNothing);
  });

  for (final failDuringPick in [false, true]) {
    testWidgets(
        '${failDuringPick ? 'picker' : 'read'} failure preserves input and shows a localized error',
        (tester) async {
      picker.pick = () async {
        if (failDuringPick) throw StateError('Synthetic picker failure');
        return _MemoryFile(
          () async => throw StateError('Synthetic file read failure'),
        );
      };
      await openForm(tester);
      await enterExistingValues(tester);
      final errorMessage = AppLocalizations.of(
        tester.element(find.text('Import from file')),
      ).sshKeyImportError;

      await tester.tap(find.text('Import from file'));
      await tester.pumpAndSettle();

      expectExistingValues();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });
  }

  for (final invalidContent in <String, List<int>>{
    'empty file': [],
    'whitespace-only file': utf8.encode(' \r\n\t '),
    'invalid UTF-8': [0xff, 0xfe],
  }.entries) {
    testWidgets('${invalidContent.key} preserves input and shows an error',
        (tester) async {
      picker.pick = () async => _MemoryFile(
            () async => Uint8List.fromList(invalidContent.value),
          );
      await openForm(tester);
      await enterExistingValues(tester);
      final errorMessage = AppLocalizations.of(
        tester.element(find.text('Import from file')),
      ).sshKeyImportError;

      await tester.tap(find.text('Import from file'));
      await tester.pumpAndSettle();

      expectExistingValues();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });
  }

  testWidgets('a picker result after the form closes cannot update its values',
      (tester) async {
    final picked = Completer<PlatformFile?>();
    picker.pick = () => picked.future;
    await openForm(tester);
    await enterExistingValues(tester);
    await tester.tap(find.text('Import from file'));
    await tester.pump();
    expect(picker.requestedType, FileType.any);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    picked.complete(_MemoryFile(
      () async => Uint8List.fromList(utf8.encode('late test content')),
    ));
    await tester.pumpAndSettle();

    expect(form.name.value, 'My phone');
    expect(form.content.value, 'existing test content');
    expect(find.text('Open key form'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a file read finishing after the form closes cannot update it',
      (tester) async {
    final bytes = Completer<Uint8List>();
    final file = _MemoryFile(() => bytes.future);
    picker.pick = () async => file;
    await openForm(tester);
    await enterExistingValues(tester);
    await tester.tap(find.text('Import from file'));
    await tester.pump();
    expect(file.readCount, 1);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    bytes.complete(Uint8List.fromList(utf8.encode('late test content')));
    await tester.pumpAndSettle();

    expect(form.name.value, 'My phone');
    expect(form.content.value, 'existing test content');
    expect(find.text('Open key form'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
