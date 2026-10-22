import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_editor/app_editor.dart';
import 'package:editor_bloc/editor_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFiles extends EditorFileService {
  FakeFiles() : super(nativeDocuments: false);
  EditorFile? selected;
  EditorFile? saved;
  Object? readError;
  Object? writeError;
  Uint8List? written;
  String? writtenUri;
  Completer<void>? savePending;

  @override
  Future<EditorFile?> pickFile() async => selected;
  @override
  Future<EditorFile> readFile(String uri) async {
    if (readError != null) throw readError!;
    return selected!;
  }

  @override
  Future<void> writeFile(EditorFile file, Uint8List bytes) async {
    if (savePending != null) await savePending!.future;
    if (writeError != null) throw writeError!;
    written = bytes;
    writtenUri = file.uri;
  }

  @override
  Future<EditorFile?> saveFileAs(String name, Uint8List bytes) async {
    if (writeError != null) throw writeError!;
    if (saved != null) written = bytes;
    return saved;
  }
}

EditorFile document(
  String text, {
  String uri = 'content://docs/original',
  bool writable = true,
}) => EditorFile(
  uri: uri,
  name: 'test.txt',
  bytes: Uint8List.fromList(utf8.encode(text)),
  writable: writable,
);

void main() {
  late FakeFiles files;
  late EditorCubit cubit;
  setUp(() {
    files = FakeFiles();
    cubit = EditorCubit(files);
  });
  tearDown(() async {
    await cubit.close();
    files.dispose();
  });

  test(
    'dirty follows saved content including undo back to the snapshot',
    () async {
      files.selected = document('original');
      expect(await cubit.openFile(), isTrue);
      cubit.updateText('changed');
      expect(cubit.state.isDirty, isTrue);
      cubit.updateText('original');
      expect(cubit.state.isDirty, isFalse);
    },
  );

  test('new file save cancellation preserves text and dirty state', () async {
    cubit.updateText('unsaved');
    expect(await cubit.save(), isFalse);
    expect(cubit.state.text, 'unsaved');
    expect(cubit.state.isDirty, isTrue);
    expect(cubit.state.file, isNull);
    files.saved = document('unsaved', uri: 'content://docs/new');
    expect(await cubit.save(), isTrue);
    expect(cubit.state.file?.uri, 'content://docs/new');
    expect(cubit.state.isDirty, isFalse);
  });

  test('save writes to original URI and restores CRLF and BOM', () async {
    files.selected = EditorFile(
      uri: 'content://docs/original',
      name: 'text.txt',
      bytes: Uint8List.fromList([0xef, 0xbb, 0xbf, ...utf8.encode('a\r\nb')]),
    );
    await cubit.openFile();
    cubit.updateText('a\nb\nc');
    expect(await cubit.save(), isTrue);
    expect(files.writtenUri, 'content://docs/original');
    expect(files.written, [0xef, 0xbb, 0xbf, ...utf8.encode('a\r\nb\r\nc')]);
    expect(cubit.state.isDirty, isFalse);
  });

  test('read-only source saves as a new document', () async {
    files.selected = document('readonly', writable: false);
    await cubit.openFile();
    cubit.updateText('my edits');
    files.saved = document('my edits', uri: 'content://docs/copy');
    expect(await cubit.save(), isTrue);
    expect(files.writtenUri, isNull);
    expect(cubit.state.file?.uri, 'content://docs/copy');
  });

  test('failed writes preserve text, identity and dirty snapshot', () async {
    files.selected = document('original');
    await cubit.openFile();
    cubit.updateText('keep this');
    files.writeError = Exception('provider denied access');
    expect(await cubit.save(), isFalse);
    expect(cubit.state.failure, EditorFailure.writeFailed);
    expect(cubit.state.text, 'keep this');
    expect(cubit.state.savedText, 'original');
    expect(cubit.state.file?.uri, 'content://docs/original');
    expect(cubit.state.isDirty, isTrue);
  });

  test(
    'cancelled picker and failed external open preserve unsaved buffer',
    () async {
      cubit.updateText('do not lose');
      expect(await cubit.openFile(), isFalse);
      files.readError = Exception('missing');
      expect(await cubit.openFile('file:///missing'), isFalse);
      expect(cubit.state.text, 'do not lose');
      expect(cubit.state.isDirty, isTrue);
      expect(cubit.state.failure, EditorFailure.readFailed);
    },
  );

  test('invalid UTF-8 cannot replace the current buffer', () async {
    cubit.updateText('keep');
    files.selected = EditorFile(
      uri: 'file:///binary',
      name: 'binary',
      bytes: Uint8List.fromList([0xff]),
    );
    expect(await cubit.openFile(), isFalse);
    expect(cubit.state.text, 'keep');
    expect(cubit.state.failure, EditorFailure.unsupportedEncoding);
  });

  test('second operation cannot race with a pending save', () async {
    files.selected = document('original');
    await cubit.openFile();
    cubit.updateText('new');
    files.savePending = Completer<void>();
    final saving = cubit.save();
    expect(cubit.state.busy, isTrue);
    expect(await cubit.openFile(), isFalse);
    cubit.newDocument();
    expect(cubit.state.text, 'new');
    files.savePending!.complete();
    expect(await saving, isTrue);
    expect(cubit.state.isDirty, isFalse);
  });
}
