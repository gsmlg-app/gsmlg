import 'dart:typed_data';

const editorMaximumFileSize = 16 * 1024 * 1024;

enum EditorFailure {
  unsupportedEncoding,
  binaryFile,
  tooLarge,
  readFailed,
  writeFailed,
}

class EditorFileException implements Exception {
  const EditorFileException(this.failure);

  final EditorFailure failure;
}

/// The original document identity, including a content URI on Android.
class EditorFile {
  const EditorFile({
    required this.uri,
    required this.name,
    required this.bytes,
    this.writable = true,
  });

  final String uri;
  final String name;
  final Uint8List bytes;
  final bool writable;
}
