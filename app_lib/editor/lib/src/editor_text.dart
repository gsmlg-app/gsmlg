import 'dart:convert';
import 'dart:typed_data';

import 'editor_file.dart';

/// Keeps the source encoding and line endings outside the editor's LF buffer.
class EditorText {
  const EditorText({
    this.text = '',
    this.hasBom = false,
    this.lineEnding = '\n',
    this.originalBytes,
  });

  factory EditorText.decode(Uint8List bytes) {
    if (bytes.length > editorMaximumFileSize) {
      throw const EditorFileException(EditorFailure.tooLarge);
    }
    final hasBom =
        bytes.length >= 3 &&
        bytes[0] == 0xef &&
        bytes[1] == 0xbb &&
        bytes[2] == 0xbf;
    String source;
    try {
      source = utf8.decode(hasBom ? bytes.sublist(3) : bytes);
    } on FormatException {
      throw const EditorFileException(EditorFailure.unsupportedEncoding);
    }
    if (source.contains('\u0000')) {
      throw const EditorFileException(EditorFailure.binaryFile);
    }
    final firstEnding = RegExp(r'\r\n|\r|\n').firstMatch(source)?.group(0);
    return EditorText(
      text: source.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
      hasBom: hasBom,
      lineEnding: firstEnding ?? '\n',
      originalBytes: bytes,
    );
  }

  final String text;
  final bool hasBom;
  final String lineEnding;
  final Uint8List? originalBytes;

  Uint8List encode(String value) {
    // Save As without editing must not normalize a source with mixed endings.
    if (value == text && originalBytes != null) return originalBytes!;
    final result = Uint8List.fromList([
      if (hasBom) ...[0xef, 0xbb, 0xbf],
      ...utf8.encode(value.replaceAll('\n', lineEnding)),
    ]);
    if (result.length > editorMaximumFileSize) {
      throw const EditorFileException(EditorFailure.tooLarge);
    }
    return result;
  }
}
