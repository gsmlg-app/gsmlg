import 'dart:io';

/// Where `sz` downloads go.
enum ZmodemDownloadMode { saveToFolder, ask }

/// A local file chosen for upload with `rz`.
class ZmodemLocalFile {
  const ZmodemLocalFile({
    required this.path,
    required this.name,
    required this.length,
  });

  final String path;
  final String name;
  final int length;

  Stream<List<int>> read([int start = 0]) => File(path).openRead(start);
}

/// A local file being written by a download.
class ZmodemDownloadTarget {
  ZmodemDownloadTarget(this.path, this.sink);

  final String path;
  final IOSink sink;

  /// Flushes and closes the file, keeping it.
  Future<void> complete() async {
    await sink.flush();
    await sink.close();
  }

  /// Closes and deletes the partial file, ignoring errors.
  Future<void> discard() async {
    try {
      await sink.close();
    } catch (_) {}
    try {
      await File(path).delete();
    } catch (_) {}
  }
}

/// File-system and dialog access used by ZMODEM transfers.
abstract interface class ZmodemFileAccess {
  /// Folder for this `sz` session; null when the user cancelled the picker.
  Future<String?> resolveDownloadDirectory();

  /// Files to upload; null or empty when the user cancelled.
  Future<List<ZmodemLocalFile>?> pickUploadFiles();

  /// Opens a new file in [directory] named after [remoteName], never
  /// overwriting an existing file.
  Future<ZmodemDownloadTarget> createDownload(
    String directory,
    String remoteName,
  );

  /// Shows [path] in the platform file manager.
  Future<void> reveal(String path);
}

/// Reduces a remote path to a safe local file name.
String sanitizeRemoteFileName(String remoteName) {
  final cleaned = remoteName.replaceAll('\u0000', '');
  final name = cleaned.split(RegExp(r'[/\\]')).last.trim();
  if (name.isEmpty || name == '.' || name == '..') return 'download';
  return name;
}

/// Returns [fileName], or a browser-style `name (N).ext` variant that does not
/// exist in [directory].
String uniqueFileName(
  String directory,
  String fileName,
  bool Function(String path) exists,
) {
  if (!exists('$directory/$fileName')) return fileName;
  final dot = fileName.lastIndexOf('.');
  final hasExtension = dot > 0;
  final stem = hasExtension ? fileName.substring(0, dot) : fileName;
  final extension = hasExtension ? fileName.substring(dot) : '';
  for (var counter = 1;; counter++) {
    final candidate = '$stem ($counter)$extension';
    if (!exists('$directory/$candidate')) return candidate;
  }
}
