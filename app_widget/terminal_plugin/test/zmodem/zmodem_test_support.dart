import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:terminal_plugin/src/zmodem/zmodem_file_access.dart';
import 'package:zmodem/zmodem.dart';

/// [ZmodemFileAccess] over a temp directory with scripted dialogs.
class FakeFileAccess implements ZmodemFileAccess {
  FakeFileAccess(this.directory);

  final Directory directory;

  /// Returned by [resolveDownloadDirectory]; defaults to [directory].
  String? Function()? downloadDirectory;

  /// Returned by [pickUploadFiles].
  List<ZmodemLocalFile>? uploads;

  final revealed = <String>[];

  /// When set, [resolveDownloadDirectory] waits for it (a slow dialog).
  Completer<void>? folderDialog;

  @override
  Future<String?> resolveDownloadDirectory() async {
    await folderDialog?.future;
    return downloadDirectory == null ? directory.path : downloadDirectory!();
  }

  @override
  Future<List<ZmodemLocalFile>?> pickUploadFiles() async => uploads;

  @override
  Future<ZmodemDownloadTarget> createDownload(
    String dir,
    String remoteName,
  ) async {
    final name = uniqueFileName(
      dir,
      sanitizeRemoteFileName(remoteName),
      (path) => File(path).existsSync(),
    );
    final path = '$dir/$name';
    return ZmodemDownloadTarget(path, File(path).openWrite());
  }

  @override
  Future<void> reveal(String path) async => revealed.add(path);
}

/// The remote side of a transfer, played by a second [ZModemCore].
class FakePeer {
  FakePeer.sender(this.files) : core = ZModemCore() {
    core.initiateSend();
  }

  FakePeer.receiver()
      : files = const {},
        core = ZModemCore() {
    core.initiateReceive();
  }

  final ZModemCore core;

  /// Files a sending peer offers, by name.
  final Map<String, Uint8List> files;

  /// Files a receiving peer got, by name.
  final received = <String, BytesBuilder>{};

  /// Every byte the controller wrote to this peer.
  final written = BytesBuilder(copy: true);

  late void Function(Uint8List bytes) toController;

  final skipped = <String>[];

  /// Offered files a receiving peer declines, like rz for existing files.
  final refuse = <String>{};
  final finished = Completer<void>();
  final cancelled = Completer<void>();
  late final Iterator<MapEntry<String, Uint8List>> _pending =
      files.entries.iterator;
  String? _receiving;

  /// Stops sending data after this many bytes of the current file, to
  /// simulate a slow or stalled sender.
  int? stallAfter;

  void start() => _flush();

  void _flush() {
    final out = core.dataToSend();
    if (out.isNotEmpty) toController(out);
  }

  /// Delivers bytes the controller wrote.
  void receive(Uint8List bytes) {
    written.add(bytes);
    if (core.isFinished) return;
    for (final event in core.receive(bytes)) {
      if (event is ZReadyToSendEvent) {
        if (_pending.moveNext()) {
          final file = _pending.current;
          core.offerFile(
            ZModemFileInfo(pathname: file.key, length: file.value.length),
          );
        } else {
          core.finishSession();
        }
      } else if (event is ZFileAcceptedEvent) {
        final data = _pending.current.value;
        final end = stallAfter ?? data.length;
        for (var i = event.offset; i < end; i += 4096) {
          core.sendFileData(
            Uint8List.sublistView(data, i, i + 4096 > end ? end : i + 4096),
          );
          _flush();
        }
        if (stallAfter == null) core.finishSending(data.length);
      } else if (event is ZFileSkippedEvent) {
        skipped.add(_pending.current.key);
        if (_pending.moveNext()) {
          final file = _pending.current;
          core.offerFile(
            ZModemFileInfo(pathname: file.key, length: file.value.length),
          );
        } else {
          core.finishSession();
        }
      } else if (event is ZFileOfferedEvent) {
        if (refuse.contains(event.fileInfo.pathname)) {
          core.skipFile();
        } else {
          _receiving = event.fileInfo.pathname;
          received[_receiving!] = BytesBuilder();
          core.acceptFile(0);
        }
      } else if (event is ZFileDataEvent) {
        received[_receiving!]!.add(event.data);
      } else if (event is ZSessionFinishedEvent) {
        if (!finished.isCompleted) finished.complete();
      } else if (event is ZSessionCancelledEvent) {
        if (!cancelled.isCompleted) cancelled.complete();
      }
      _flush();
    }
    _flush();
  }
}
