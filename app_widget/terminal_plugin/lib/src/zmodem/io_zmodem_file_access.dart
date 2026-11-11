import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'zmodem_file_access.dart';

/// Current download settings.
typedef ZmodemDownloadSettings = ({ZmodemDownloadMode mode, String? directory});

/// [ZmodemFileAccess] backed by dart:io and the system file dialogs.
class IoZmodemFileAccess implements ZmodemFileAccess {
  IoZmodemFileAccess({required this.settings});

  final ZmodemDownloadSettings Function() settings;

  @override
  Future<String?> resolveDownloadDirectory() async {
    final current = settings();
    if (current.mode == ZmodemDownloadMode.ask) {
      return FilePicker.getDirectoryPath();
    }
    final configured = current.directory;
    if (configured != null && configured.isNotEmpty) return configured;
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads.path;
    } catch (_) {}
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.current.path;
    return p.join(home, 'Downloads');
  }

  @override
  Future<List<ZmodemLocalFile>?> pickUploadFiles() async {
    final picked = await FilePicker.pickFiles();
    return [
      for (final file in picked)
        if (file.path case final String path)
          ZmodemLocalFile(
            path: path,
            name: file.name,
            length: File(path).lengthSync(),
          ),
    ];
  }

  @override
  Future<ZmodemDownloadTarget> createDownload(
    String directory,
    String remoteName,
  ) async {
    await Directory(directory).create(recursive: true);
    final name = uniqueFileName(
      directory,
      sanitizeRemoteFileName(remoteName),
      (path) =>
          FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound,
    );
    final path = p.join(directory, name);
    final file = File(path);
    // Create exclusively so a file appearing meanwhile is never overwritten.
    await file.create(exclusive: true);
    return ZmodemDownloadTarget(path, file.openWrite());
  }

  @override
  Future<void> reveal(String path) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', ['-R', path]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', ['/select,$path']);
      } else if (Platform.isLinux) {
        final directory =
            FileSystemEntity.isDirectorySync(path) ? path : p.dirname(path);
        await Process.run('xdg-open', [directory]);
      }
    } catch (_) {}
  }
}
