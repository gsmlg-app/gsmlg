import 'dart:convert';
import 'dart:io';

import 'package:app_editor/app_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test('UTF-8 BOM, Unicode, and CRLF survive an edited roundtrip', () {
    final source = Uint8List.fromList([
      0xef,
      0xbb,
      0xbf,
      ...utf8.encode('你好\r\n🙂\r\n'),
    ]);
    final text = EditorText.decode(source);
    expect(text.text, '你好\n🙂\n');
    expect(text.encode(text.text), source);
    expect(text.encode('${text.text}end\n'), [
      0xef,
      0xbb,
      0xbf,
      ...utf8.encode('你好\r\n🙂\r\nend\r\n'),
    ]);
  });

  test('plain UTF-8 and empty files remain valid text', () {
    for (final value in ['', 'a\nb\n', 'a\rb\r', 'a\nb\r\nc\rd']) {
      final source = Uint8List.fromList(utf8.encode(value));
      final decoded = EditorText.decode(source);
      expect(decoded.encode(decoded.text), source);
    }
  });

  test('invalid encoding, binary data and oversized files are rejected', () {
    for (final entry in [
      (Uint8List.fromList([0xff, 0xfe]), EditorFailure.unsupportedEncoding),
      (Uint8List.fromList([65, 0, 66]), EditorFailure.binaryFile),
      (Uint8List(editorMaximumFileSize + 1), EditorFailure.tooLarge),
    ]) {
      expect(
        () => EditorText.decode(entry.$1),
        throwsA(
          isA<EditorFileException>().having(
            (e) => e.failure,
            'failure',
            entry.$2,
          ),
        ),
      );
    }
    expect(
      () => const EditorText(
        hasBom: true,
      ).encode('a' * (editorMaximumFileSize - 2)),
      throwsA(
        isA<EditorFileException>().having(
          (e) => e.failure,
          'failure',
          EditorFailure.tooLarge,
        ),
      ),
    );
  });

  test('incoming requests survive before a screen subscribes', () async {
    final service = EditorFileService(nativeDocuments: false);
    addTearDown(service.dispose);
    await service.initialize(['/tmp/one.txt', '/tmp/two.json']);
    service.receiveFiles(['/tmp/two.json', '/tmp/three.md']);
    expect(service.takePendingFile(), '/tmp/one.txt');
    expect(service.takePendingFile(), '/tmp/two.json');
    expect(service.takePendingFile(), '/tmp/three.md');
    expect(service.hasPendingFiles, isFalse);
  });

  test('ready and running-app native requests use the same queue', () async {
    const channel = MethodChannel('gsmlg/editor-test');
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      expect(call.method, 'ready');
      return ['content://files/initial'];
    });
    final service = EditorFileService(channel: channel, nativeDocuments: true);
    addTearDown(() {
      service.dispose();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });
    await service.initialize([]);
    expect(service.takePendingFile(), 'content://files/initial');
    final delivered = service.openRequests.first;
    // ignore: deprecated_member_use
    binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('openFiles', ['content://files/running']),
      ),
      (_) {},
    );
    await delivered;
    expect(service.takePendingFile(), 'content://files/running');
  });

  test(
    'native save-as preserves original URI and cancellation is null',
    () async {
      const channel = MethodChannel('gsmlg/editor-save-test');
      final bytes = Uint8List.fromList(utf8.encode('edited'));
      final calls = <MethodCall>[];
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        if (call.method == 'saveFileAs') {
          return {
            'uri': 'content://provider/document/42',
            'name': 'saved.txt',
            'writable': true,
          };
        }
        return null;
      });
      final service = EditorFileService(
        channel: channel,
        nativeDocuments: true,
      );
      addTearDown(() {
        service.dispose();
        binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
      });
      expect(await service.pickFile(), isNull);
      final file = await service.saveFileAs('untitled.txt', bytes);
      expect(file?.uri, 'content://provider/document/42');
      expect(file?.bytes, bytes);
      await service.writeFile(file!, bytes);
      expect((calls.last.arguments as Map)['uri'], file.uri);
      expect((calls.last.arguments as Map)['bytes'], bytes);
    },
  );

  test(
    'desktop save replaces contents of original and follows a symlink',
    () async {
      final directory = await Directory.systemTemp.createTemp('gsmlg-editor-');
      addTearDown(() => directory.delete(recursive: true));
      final original = File('${directory.path}/source.txt');
      await original.writeAsString('a longer original document');
      final link = Link('${directory.path}/alias.txt');
      await link.create(original.path);
      final service = EditorFileService(nativeDocuments: false);
      addTearDown(service.dispose);
      final file = await service.readFile(link.path);
      await service.writeFile(file, Uint8List.fromList(utf8.encode('short')));
      expect(await original.readAsString(), 'short');
      expect(await link.exists(), isTrue);
      expect(await link.target(), original.path);
      expect(await directory.list().length, 2);
    },
    skip: Platform.isWindows ? 'Symlinks require Windows privileges' : false,
  );

  test(
    'desktop save preserves file mode and rejects newly read-only files',
    () async {
      final directory = await Directory.systemTemp.createTemp('gsmlg-mode-');
      addTearDown(() => directory.delete(recursive: true));
      final source = File('${directory.path}/source.txt');
      await source.writeAsString('original');
      final service = EditorFileService(nativeDocuments: false);
      addTearDown(service.dispose);
      for (final mode in ['600', '755']) {
        expect((await Process.run('chmod', [mode, source.path])).exitCode, 0);
        final before = (await source.stat()).mode;
        final file = await service.readFile(source.path);
        await service.writeFile(
          file,
          Uint8List.fromList(utf8.encode('edited')),
        );
        expect((await source.stat()).mode, before);
      }
      final file = await service.readFile(source.path);
      expect((await Process.run('chmod', ['444', source.path])).exitCode, 0);
      await expectLater(
        service.writeFile(file, Uint8List.fromList(utf8.encode('rejected'))),
        throwsA(isA<EditorFileException>()),
      );
      expect(await source.readAsString(), 'edited');
    },
    skip: Platform.isWindows ? 'POSIX file modes' : false,
  );
}
