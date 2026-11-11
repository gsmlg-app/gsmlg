import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:zmodem/zmodem.dart';

import 'zmodem_file_access.dart';

enum ZmodemDirection { download, upload }

@immutable
class ZmodemProgress {
  const ZmodemProgress({
    required this.direction,
    required this.fileName,
    required this.bytesDone,
    this.totalBytes,
    required this.fileIndex,
    this.fileCount,
  });

  final ZmodemDirection direction;
  final String fileName;
  final int bytesDone;
  final int? totalBytes;

  /// 1-based index of the current file.
  final int fileIndex;
  final int? fileCount;
}

sealed class ZmodemTransferResult {}

final class ZmodemDownloadCompleted extends ZmodemTransferResult {
  ZmodemDownloadCompleted(this.paths);

  final List<String> paths;
}

final class ZmodemUploadCompleted extends ZmodemTransferResult {
  ZmodemUploadCompleted(this.count, {this.skipped = const []});

  final int count;

  /// Names the receiver declined, such as files that already exist.
  final List<String> skipped;
}

final class ZmodemTransferCancelled extends ZmodemTransferResult {}

final class ZmodemTransferFailed extends ZmodemTransferResult {
  ZmodemTransferFailed(this.reason);

  final String reason;
}

/// ZPAD ZPAD ZDLE 'B' '0': start of a ZRQINIT/ZRINIT hex header.
const _signature = [0x2a, 0x2a, 0x18, 0x42, 0x30];

/// `**` ZDLE `B` + 14 hex digits + CR + LF.
const _hexHeaderLength = 4 + 14 + 2;

const _zrqinit = 0x00;
const _zrinit = 0x01;

/// 8×CAN then 8×BS: the conventional ZMODEM abort.
final _abortSequence = Uint8List.fromList([
  ...List.filled(8, 0x18),
  ...List.filled(8, 0x08),
]);

const _flushThreshold = 512 * 1024;

/// Upload writes are split into slices this small, with a yield between
/// them, so XOFF from the receiver's terminal is noticed before its input
/// queue overflows (the tty discards input past its high-water mark).
const _uploadSlice = 1024;

/// How long to honour an XOFF without a following XON.
const _xoffTimeout = Duration(seconds: 3);
const _xon = 0x11;
const _xoff = 0x13;
const _uploadChunk = 8 * 1024;

/// Uploads ask for an acknowledgement (ZCRCQ) this often and never have
/// more than [_uploadWindow] unacknowledged, which bounds memory and keeps
/// cancel responsive on transports whose writes never block (SSH).
const _ackInterval = 64 * 1024;
const _uploadWindow = 256 * 1024;

/// After a cancel or failure the remote may keep sending for a while; that
/// output is discarded until it has been quiet this long (at most
/// [_drainMax]) so binary data never reaches the terminal.
const _drainQuiet = Duration(milliseconds: 400);
const _drainMax = Duration(seconds: 5);
const _splitHoldTime = Duration(milliseconds: 50);
const _progressInterval = Duration(milliseconds: 100);

/// Sits between a terminal session and the terminal: passes ordinary output
/// through and runs ZMODEM transfers (`sz` / `rz`) when the remote starts one.
class ZmodemTransferController {
  ZmodemTransferController({
    required this.onTerminalOutput,
    required this.writeToSession,
    required this.files,
    this.supported = true,
    this.handshakeTimeout = const Duration(seconds: 10),
    this.idleTimeout = const Duration(seconds: 30),
  });

  final void Function(Uint8List bytes) onTerminalOutput;
  final Future<void> Function(Uint8List bytes) writeToSession;
  final ZmodemFileAccess files;
  final bool supported;
  final Duration handshakeTimeout;

  /// A running transfer fails when the remote side sends nothing this long.
  final Duration idleTimeout;

  final _progress = ValueNotifier<ZmodemProgress?>(null);
  final _results = StreamController<ZmodemTransferResult>.broadcast();

  ValueListenable<ZmodemProgress?> get progress => _progress;
  Stream<ZmodemTransferResult> get results => _results.stream;

  _Transfer? _transfer;
  bool get isActive => _transfer != null;

  /// Output held back because it may be the start of a split handshake.
  Uint8List _held = Uint8List(0);
  Timer? _heldTimer;

  /// Leading 'O' bytes of the sender's "OO" to drop after a download.
  int _swallowOverAndOut = 0;

  bool _disposed = false;

  /// Bytes received but not yet written to disk.
  @visibleForTesting
  int get bufferedBytes => _transfer?.bufferedBytes ?? 0;

  /// Feeds session output. The returned future, if any, completes once the
  /// chunk has been processed; acknowledge the chunk to the session then.
  FutureOr<void> handleSessionOutput(Uint8List chunk) {
    if (_disposed) return null;
    final transfer = _transfer;
    if (transfer != null) return transfer.enqueue(chunk);
    if (_draining) {
      if (_drainClock.elapsed < _drainMax) {
        _restartDrainTimer();
        return null;
      }
      _endDrain();
    }
    _scan(chunk);
    return null;
  }

  bool _draining = false;

  /// Whether output is being discarded after a cancelled or failed transfer.
  bool get isDraining => _draining;
  final _drainClock = Stopwatch();
  Timer? _drainTimer;

  /// Discards output until the remote side has been quiet for a moment.
  void _startDrain() {
    _draining = true;
    _drainClock
      ..reset()
      ..start();
    _restartDrainTimer();
  }

  void _restartDrainTimer() {
    _drainTimer?.cancel();
    _drainTimer = Timer(_drainQuiet, () {
      _endDrain();
      // Ask the shell for a fresh prompt; the old one may have been eaten.
      if (!_disposed) unawaited(writeToSession(Uint8List.fromList([0x0d])));
    });
  }

  void _endDrain() {
    _draining = false;
    _drainTimer?.cancel();
    _drainTimer = null;
    _drainClock.stop();
  }

  /// Returns true when [bytes] were consumed by an active transfer.
  bool handleKeyboardInput(Uint8List bytes) {
    final transfer = _transfer;
    if (transfer == null) return false;
    if (bytes.contains(0x03)) unawaited(cancel());
    return true;
  }

  Future<void> cancel() async {
    final transfer = _transfer;
    if (transfer == null) return;
    await _abort(transfer, ZmodemTransferCancelled(), sendAbort: true);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    final transfer = _transfer;
    if (transfer != null) {
      await _abort(transfer, ZmodemTransferCancelled(), sendAbort: true);
    }
    _disposed = true;
    _heldTimer?.cancel();
    _endDrain();
    _progress.dispose();
    await _results.close();
  }

  // --- passthrough and handshake detection ---------------------------------

  void _scan(Uint8List chunk) {
    _heldTimer?.cancel();
    _heldTimer = null;
    var data = _held.isEmpty ? chunk : Uint8List.fromList([..._held, ...chunk]);
    _held = Uint8List(0);

    if (_swallowOverAndOut > 0) {
      var skip = 0;
      while (skip < data.length &&
          skip < _swallowOverAndOut &&
          data[skip] == 0x4f) {
        skip++;
      }
      _swallowOverAndOut = 0;
      data = Uint8List.sublistView(data, skip);
    }

    var from = 0;
    while (true) {
      final start = _indexOfSignature(data, from);
      if (start < 0) {
        final keep = _signaturePrefixAtEnd(data, from);
        _emit(Uint8List.sublistView(data, from, data.length - keep));
        _hold(Uint8List.sublistView(data, data.length - keep));
        return;
      }
      if (data.length - start < _hexHeaderLength) {
        _emit(Uint8List.sublistView(data, from, start));
        _hold(Uint8List.sublistView(data, start));
        return;
      }
      final type = _validHeaderType(data, start);
      if (type == null) {
        // Not a real handshake: show it and keep looking after it.
        _emit(Uint8List.sublistView(data, from, start + 1));
        from = start + 1;
        continue;
      }
      _emit(Uint8List.sublistView(data, from, start));
      _start(type, Uint8List.sublistView(data, start));
      return;
    }
  }

  void _emit(Uint8List bytes) {
    if (bytes.isNotEmpty) onTerminalOutput(Uint8List.fromList(bytes));
  }

  void _hold(Uint8List bytes) {
    if (bytes.isEmpty) return;
    _held = Uint8List.fromList(bytes);
    _heldTimer = Timer(_splitHoldTime, () {
      _heldTimer = null;
      final held = _held;
      _held = Uint8List(0);
      _emit(held);
    });
  }

  static int _indexOfSignature(Uint8List data, int from) {
    outer:
    for (var i = from; i <= data.length - _signature.length; i++) {
      for (var j = 0; j < _signature.length; j++) {
        if (data[i + j] != _signature[j]) continue outer;
      }
      return i;
    }
    return -1;
  }

  /// Length of the longest suffix of [data] that is a proper prefix of the
  /// signature.
  static int _signaturePrefixAtEnd(Uint8List data, int from) {
    for (var length = _signature.length - 1; length > 0; length--) {
      final start = data.length - length;
      if (start < from) continue;
      var matches = true;
      for (var j = 0; j < length; j++) {
        if (data[start + j] != _signature[j]) {
          matches = false;
          break;
        }
      }
      if (matches) return length;
    }
    return 0;
  }

  /// Returns ZRQINIT/ZRINIT when a complete, CRC-valid hex header starts at
  /// [start], otherwise null.
  static int? _validHeaderType(Uint8List data, int start) {
    final fields = <int>[];
    for (var i = 0; i < 7; i++) {
      final high = _hexValue(data[start + 4 + i * 2]);
      final low = _hexValue(data[start + 5 + i * 2]);
      if (high == null || low == null) return null;
      fields.add(high * 16 + low);
    }
    final cr = data[start + 18];
    final lf = data[start + 19];
    if (cr != 0x0d && cr != 0x8d) return null;
    if (lf != 0x0a && lf != 0x8a) return null;
    final type = fields[0];
    if (type != _zrqinit && type != _zrinit) return null;
    final crc = _crc16(fields.sublist(0, 5));
    if (crc != ((fields[5] << 8) | fields[6])) return null;
    return type;
  }

  static int? _hexValue(int char) {
    if (char >= 0x30 && char <= 0x39) return char - 0x30;
    if (char >= 0x61 && char <= 0x66) return char - 0x61 + 10;
    if (char >= 0x41 && char <= 0x46) return char - 0x41 + 10;
    return null;
  }

  static int _crc16(List<int> bytes) {
    var crc = 0;
    for (final byte in [...bytes, 0, 0]) {
      for (var bit = 7; bit >= 0; bit--) {
        final carry = crc & 0x8000;
        crc = ((crc << 1) | ((byte >> bit) & 1)) & 0xffff;
        if (carry != 0) crc ^= 0x1021;
      }
    }
    return crc;
  }

  // --- transfers -------------------------------------------------------------

  void _start(int type, Uint8List initial) {
    if (!supported) {
      unawaited(writeToSession(Uint8List.fromList(_abortSequence)));
      onTerminalOutput(
        Uint8List.fromList(
          '\r\nZMODEM transfers are not supported on this device\r\n'.codeUnits,
        ),
      );
      // The sender may already be streaming; keep it off the screen.
      _startDrain();
      return;
    }
    final transfer = _Transfer(
      this,
      type == _zrqinit ? ZmodemDirection.download : ZmodemDirection.upload,
    );
    _transfer = transfer;
    _armHandshakeTimer(transfer);
    transfer.touch();
    unawaited(transfer.enqueue(initial));
  }

  /// Fails the transfer if the remote side never gets past the handshake.
  void _armHandshakeTimer(_Transfer transfer) {
    transfer.handshakeTimer?.cancel();
    transfer.handshakeTimer = Timer(handshakeTimeout, () {
      if (identical(_transfer, transfer) && !transfer.handshakeDone) {
        unawaited(
          _abort(
            transfer,
            ZmodemTransferFailed('No response from the remote side'),
            sendAbort: true,
          ),
        );
      }
    });
  }

  void _setProgress(ZmodemProgress? value) {
    if (_disposed) return;
    _progress.value = value;
  }

  void _finish(_Transfer transfer, ZmodemTransferResult result) {
    if (!identical(_transfer, transfer)) return;
    transfer.close();
    _transfer = null;
    _setProgress(null);
    if (transfer.direction == ZmodemDirection.download) _swallowOverAndOut = 2;
    if (!_results.isClosed) _results.add(result);
  }

  Future<void> _abort(
    _Transfer transfer,
    ZmodemTransferResult result, {
    required bool sendAbort,
  }) async {
    if (!identical(_transfer, transfer)) return;
    transfer.close();
    _transfer = null;
    _setProgress(null);
    _startDrain();
    await transfer.discardCurrent();
    if (sendAbort) {
      try {
        await writeToSession(Uint8List.fromList(_abortSequence));
      } catch (_) {}
    }
    if (!_results.isClosed) _results.add(result);
  }
}

/// One ZMODEM session: owns the protocol core and processes received chunks
/// strictly in order.
class _Transfer {
  _Transfer(this.owner, this.direction);

  final ZmodemTransferController owner;
  final ZmodemDirection direction;
  final core = ZModemCore();

  final _queue = Queue<(Uint8List, Completer<void>)>();
  bool _processing = false;
  bool _closed = false;

  Timer? handshakeTimer;
  bool handshakeDone = false;

  int _queuedBytes = 0;
  int _unflushedBytes = 0;
  int get bufferedBytes => _queuedBytes + _unflushedBytes;

  // Download state.
  String? _directory;
  bool _directoryResolved = false;
  ZmodemDownloadTarget? _target;
  final _paths = <String>[];
  int _fileIndex = 0;
  String _fileName = '';
  int? _fileLength;
  int _bytesDone = 0;
  final _progressClock = Stopwatch()..start();

  // Upload state.
  List<ZmodemLocalFile>? _uploads;
  int _uploadIndex = -1;
  final _uploadedFiles = <int>{};
  final _skippedUploads = <String>[];
  Future<void>? _uploading;
  bool _uploadActive = false;
  int? _repositionTo;
  int _sentOffset = 0;
  int _ackedOffset = 0;

  Timer? _idleTimer;
  bool _idlePaused = false;

  /// Restarts the no-progress timeout; called whenever the remote speaks.
  void touch() {
    _idleTimer?.cancel();
    if (_closed || _idlePaused) return;
    _idleTimer = Timer(owner.idleTimeout, () {
      unawaited(
        owner._abort(
          this,
          ZmodemTransferFailed('No response from the remote side'),
          sendAbort: true,
        ),
      );
    });
  }

  /// Runs [dialog] without counting the time against the idle timeout.
  Future<T> _whileWaitingForUser<T>(Future<T> Function() dialog) async {
    _idlePaused = true;
    _idleTimer?.cancel();
    try {
      return await dialog();
    } finally {
      _idlePaused = false;
      touch();
    }
  }

  void close() {
    _closed = true;
    handshakeTimer?.cancel();
    _idleTimer?.cancel();
    for (final (_, done) in _queue) {
      if (!done.isCompleted) done.complete();
    }
    _queue.clear();
    _queuedBytes = 0;
  }

  Future<void> enqueue(Uint8List chunk) {
    final done = Completer<void>();
    if (_closed) {
      done.complete();
      return done.future;
    }
    if (direction == ZmodemDirection.upload) _trackFlowControl(chunk);
    touch();
    _queue.add((Uint8List.fromList(chunk), done));
    _queuedBytes += chunk.length;
    if (!_processing) unawaited(_drain());
    return done.future;
  }

  Future<void> _drain() async {
    _processing = true;
    try {
      while (_queue.isNotEmpty && !_closed) {
        final (chunk, done) = _queue.removeFirst();
        _queuedBytes -= chunk.length;
        try {
          await _process(chunk);
        } catch (error) {
          await owner._abort(
            this,
            ZmodemTransferFailed(_describe(error)),
            sendAbort: true,
          );
        } finally {
          if (!done.isCompleted) done.complete();
        }
      }
    } finally {
      _processing = false;
    }
  }

  static String _describe(Object error) =>
      error is ZModemException ? error.message : error.toString();

  Future<void> _send() async {
    final out = core.dataToSend();
    if (out.isNotEmpty && !_closed) await owner.writeToSession(out);
  }

  Future<void> _process(Uint8List chunk) async {
    if (direction == ZmodemDirection.download && !_directoryResolved) {
      // Ask before answering the handshake: the sender only retries its
      // ZRQINIT meanwhile, which the core tolerates. The handshake timeout
      // is paused while the user picks a folder.
      handshakeTimer?.cancel();
      _directory =
          await _whileWaitingForUser(owner.files.resolveDownloadDirectory);
      _directoryResolved = true;
      if (_closed) return;
      owner._armHandshakeTimer(this);
    }
    final events = core.receive(chunk).toList();
    await _send();
    for (final event in events) {
      if (_closed) return;
      await _handle(event);
      await _send();
    }
  }

  Future<void> _handle(ZModemEvent event) async {
    switch (event) {
      case ZFileOfferedEvent(:final fileInfo):
        handshakeDone = true;
        await _onFileOffered(fileInfo);
      case ZFileDataEvent(:final data):
        await _onFileData(data);
      case ZFileEndEvent():
        await _onFileEnd();
      case ZReadyToSendEvent():
        handshakeDone = true;
        await _onReadyToSend();
      case ZFileAcceptedEvent(:final offset):
        _ackedOffset = offset;
        _startUpload(offset, announce: false);
      case ZFileAckEvent(:final offset):
        if (offset > _ackedOffset) _ackedOffset = offset;
      case ZFileRepositionEvent(:final offset):
        if (_uploadActive) {
          _repositionTo = offset;
        } else {
          // The receiver asked for a resend after our ZEOF.
          _startUpload(offset, announce: true);
        }
      case ZFileSkippedEvent():
        final uploads = _uploads;
        if (uploads != null && _uploadIndex < uploads.length) {
          _skippedUploads.add(uploads[_uploadIndex].name);
        }
        await _offerNext();
      case ZSessionFinishedEvent():
        await _uploading;
        owner._finish(this, _result());
      case ZSessionCancelledEvent():
        await owner._abort(
          this,
          ZmodemTransferFailed('Cancelled by the remote side'),
          sendAbort: false,
        );
    }
  }

  ZmodemTransferResult _result() {
    if (direction == ZmodemDirection.download) {
      return _paths.isEmpty
          ? ZmodemTransferCancelled()
          : ZmodemDownloadCompleted(List.unmodifiable(_paths));
    }
    return _uploadedFiles.isEmpty && _skippedUploads.isEmpty
        ? ZmodemTransferCancelled()
        : ZmodemUploadCompleted(
            _uploadedFiles.length,
            skipped: List.unmodifiable(_skippedUploads),
          );
  }

  // Downloads.

  Future<void> _onFileOffered(ZModemFileInfo info) async {
    final directory = _directory;
    if (directory == null) {
      core.skipFile();
      return;
    }
    _target = await owner.files.createDownload(directory, info.pathname);
    if (_closed) {
      await discardCurrent();
      return;
    }
    _fileIndex++;
    _fileName = sanitizeRemoteFileName(info.pathname);
    _fileLength = info.length;
    _bytesDone = 0;
    _reportProgress(force: true);
    core.acceptFile(0);
  }

  Future<void> _onFileData(List<int> data) async {
    final target = _target;
    if (target == null) return;
    target.sink.add(data);
    _bytesDone += data.length;
    _unflushedBytes += data.length;
    if (_unflushedBytes >= _flushThreshold) {
      await target.sink.flush();
      _unflushedBytes = 0;
    }
    _reportProgress();
  }

  Future<void> _onFileEnd() async {
    final target = _target;
    _target = null;
    if (target == null) return;
    await target.complete();
    _unflushedBytes = 0;
    _paths.add(target.path);
    _reportProgress(force: true);
  }

  Future<void> discardCurrent() async {
    final target = _target;
    _target = null;
    _unflushedBytes = 0;
    await target?.discard();
  }

  void _reportProgress({bool force = false}) {
    if (!force && _progressClock.elapsed < _progressInterval) return;
    _progressClock.reset();
    owner._setProgress(
      ZmodemProgress(
        direction: direction,
        fileName: _fileName,
        bytesDone: _bytesDone,
        totalBytes: _fileLength,
        fileIndex: _fileIndex == 0 ? 1 : _fileIndex,
        fileCount: _uploads?.length,
      ),
    );
  }

  // Uploads.

  /// Set while the receiver's terminal has sent XOFF.
  bool _peerPaused = false;

  /// Applies XON/XOFF as soon as they arrive, ahead of queued chunks.
  void _trackFlowControl(Uint8List chunk) {
    for (final byte in chunk) {
      if (byte == _xoff) {
        _peerPaused = true;
      } else if (byte == _xon) {
        _peerPaused = false;
      }
    }
  }

  Future<void> _waitWhilePeerPaused() async {
    final clock = Stopwatch()..start();
    while (_peerPaused && !_closed) {
      if (clock.elapsed > _xoffTimeout) {
        _peerPaused = false;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }

  /// Sends queued protocol data in small slices, honouring flow control.
  Future<void> _sendPaced() async {
    final out = core.dataToSend();
    for (var i = 0; i < out.length && !_closed; i += _uploadSlice) {
      await _waitWhilePeerPaused();
      // Data queued before a ZRPOS is stale; the resend starts with a new
      // ZDATA header.
      if (_closed || _repositionTo != null) return;
      final end = i + _uploadSlice > out.length ? out.length : i + _uploadSlice;
      await owner.writeToSession(Uint8List.sublistView(out, i, end));
      // Let incoming XOFF/XON be delivered before the next slice.
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<void> _onReadyToSend() async {
    if (_uploads == null) {
      _uploads =
          await _whileWaitingForUser(owner.files.pickUploadFiles) ?? const [];
      if (_closed) return;
    }
    await _uploading;
    await _offerNext();
  }

  Future<void> _offerNext() async {
    final uploads = _uploads ?? const [];
    _uploadIndex++;
    if (_uploadIndex >= uploads.length) {
      core.finishSession();
      return;
    }
    final file = uploads[_uploadIndex];
    _fileIndex = _uploadIndex + 1;
    _fileName = file.name;
    _fileLength = file.length;
    _bytesDone = 0;
    _reportProgress(force: true);
    core.offerFile(ZModemFileInfo(pathname: file.name, length: file.length));
  }

  void _startUpload(int offset, {required bool announce}) {
    final file = _uploads![_uploadIndex];
    _uploading = _upload(file, offset, announce: announce).catchError(
      (Object error) => owner._abort(
        this,
        ZmodemTransferFailed(_describe(error)),
        sendAbort: true,
      ),
    );
  }

  /// Waits until less than [_uploadWindow] is unacknowledged.
  Future<void> _waitForWindow() async {
    while (!_closed &&
        _repositionTo == null &&
        _sentOffset - _ackedOffset >= _uploadWindow) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }

  Future<void> _upload(
    ZmodemLocalFile file,
    int offset, {
    required bool announce,
  }) async {
    _uploadActive = true;
    try {
      var position = offset;
      var needsHeader = announce;
      while (!_closed) {
        _repositionTo = null;
        _sentOffset = position;
        if (needsHeader) {
          if (_ackedOffset > position) _ackedOffset = position;
          core.repositionTo(position);
          await _sendPaced();
        }
        needsHeader = true;
        var sinceAck = 0;
        int? restartAt;
        await for (final chunk in file.read(position)) {
          for (var i = 0; i < chunk.length; i += _uploadChunk) {
            await _waitForWindow();
            if (_closed) return;
            restartAt = _repositionTo;
            if (restartAt != null) break;
            final end = i + _uploadChunk > chunk.length
                ? chunk.length
                : i + _uploadChunk;
            sinceAck += end - i;
            final ack = sinceAck >= _ackInterval;
            if (ack) sinceAck = 0;
            core.sendFileData(
              Uint8List.fromList(chunk.sublist(i, end)),
              ack: ack,
            );
            position += end - i;
            _sentOffset = position;
            await _sendPaced();
            _bytesDone = position;
            _reportProgress();
            restartAt = _repositionTo;
            if (restartAt != null || _closed) break;
          }
          if (restartAt != null || _closed) break;
        }
        if (_closed) return;
        if (restartAt == null) break;
        position = restartAt;
        _ackedOffset = position;
      }
      if (_closed) return;
      core.finishSending(position);
      await _sendPaced();
      _uploadedFiles.add(_uploadIndex);
      _reportProgress(force: true);
    } finally {
      _uploadActive = false;
    }
  }
}
