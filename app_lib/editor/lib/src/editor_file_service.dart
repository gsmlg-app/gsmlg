import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:file_selector/file_selector.dart' as selector;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import 'editor_file.dart';

/// Document I/O and a lossless queue for system file-open requests.
class EditorFileService {
  EditorFileService({MethodChannel? channel, bool? nativeDocuments})
    : _channel = channel ?? const MethodChannel('gsmlg/editor'),
      _nativeDocuments =
          nativeDocuments ??
          (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  final MethodChannel _channel;
  final bool _nativeDocuments;
  final _requests = StreamController<void>.broadcast(sync: true);
  final _pending = Queue<String>();
  Future<void>? _initialization;
  bool _disposed = false;

  Stream<void> get openRequests => _requests.stream;
  bool get hasPendingFiles => _pending.isNotEmpty;
  String? takePendingFile() => _pending.isEmpty ? null : _pending.removeFirst();

  Future<void> initialize(List<String> arguments) =>
      _initialization ??= _initialize(arguments);

  Future<void> _initialize(List<String> arguments) async {
    if (_nativeDocuments) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'openFiles') {
          receiveFiles((call.arguments as List).cast<String>());
        }
      });
      final initial = await _channel.invokeListMethod<String>('ready');
      receiveFiles(initial ?? const []);
    }
    // Windows/Linux runners already deliver filenames as Dart entrypoint args.
    if (Platform.isWindows || Platform.isLinux || !_nativeDocuments) {
      var afterSeparator = false;
      receiveFiles(
        arguments.where((argument) {
          if (argument == '--') {
            afterSeparator = true;
            return false;
          }
          return argument.isNotEmpty &&
              (afterSeparator || !argument.startsWith('-'));
        }),
      );
    }
  }

  void receiveFiles(Iterable<String> uris) {
    if (_disposed) return;
    var changed = false;
    for (final uri in uris) {
      if (uri.isNotEmpty && !_pending.contains(uri)) {
        _pending.add(uri);
        changed = true;
      }
    }
    if (changed) _requests.add(null);
  }

  Future<EditorFile?> pickFile() async {
    if (_nativeDocuments) {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'pickFile',
      );
      return result == null ? null : _fromMap(result);
    }
    final selected = await selector.openFile();
    return selected == null ? null : readFile(selected.path);
  }

  Future<EditorFile> readFile(String uri) async {
    if (_nativeDocuments) {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'readFile',
        {'uri': uri},
      );
      if (result == null) {
        throw const EditorFileException(EditorFailure.readFailed);
      }
      return _fromMap(result);
    }
    final file = _localFile(uri);
    if (await file.length() > editorMaximumFileSize) {
      throw const EditorFileException(EditorFailure.tooLarge);
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > editorMaximumFileSize) {
      throw const EditorFileException(EditorFailure.tooLarge);
    }
    return EditorFile(
      uri: file.absolute.uri.toString(),
      name: path.basename(file.path),
      bytes: bytes,
      writable: ((await file.stat()).mode & 0x92) != 0,
    );
  }

  Future<void> writeFile(EditorFile file, Uint8List bytes) async {
    if (_nativeDocuments) {
      await _channel.invokeMethod<bool>('writeFile', {
        'uri': file.uri,
        'bytes': bytes,
      });
      return;
    }
    final destination = _localFile(file.uri);
    // Resolve symlinks so saving edits the selected file rather than the link.
    final target = File(await destination.resolveSymbolicLinks());
    if (((await target.stat()).mode & 0x92) == 0) {
      throw const EditorFileException(EditorFailure.writeFailed);
    }
    // Write the same inode to retain executable bits, private mode and ACLs.
    await target.writeAsBytes(bytes, flush: true);
  }

  Future<EditorFile?> saveFileAs(String name, Uint8List bytes) async {
    if (_nativeDocuments) {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'saveFileAs',
        {'name': name, 'bytes': bytes},
      );
      return result == null ? null : _fromMap(result, fallbackBytes: bytes);
    }
    final location = await selector.getSaveLocation(suggestedName: name);
    if (location == null) return null;
    final file = File(location.path);
    // XFile.saveTo handles both new files and replacement selected by the user.
    await selector.XFile.fromData(bytes, name: name).saveTo(file.path);
    return EditorFile(
      uri: file.absolute.uri.toString(),
      name: path.basename(file.path),
      bytes: bytes,
    );
  }

  EditorFile _fromMap(Map<String, Object?> result, {Uint8List? fallbackBytes}) {
    final bytes = (result['bytes'] as Uint8List?) ?? fallbackBytes;
    if (bytes == null) {
      throw const EditorFileException(EditorFailure.readFailed);
    }
    if (bytes.length > editorMaximumFileSize) {
      throw const EditorFileException(EditorFailure.tooLarge);
    }
    return EditorFile(
      uri: result['uri'] as String,
      name: result['name'] as String,
      writable: result['writable'] as bool? ?? false,
      bytes: bytes,
    );
  }

  File _localFile(String value) =>
      value.startsWith('file:') ? File.fromUri(Uri.parse(value)) : File(value);

  void dispose() {
    _disposed = true;
    if (_nativeDocuments) _channel.setMethodCallHandler(null);
    unawaited(_requests.close());
  }
}
