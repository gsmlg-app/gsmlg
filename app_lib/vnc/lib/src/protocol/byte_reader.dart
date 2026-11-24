import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import '../models/vnc_exceptions.dart';

/// Asynchronous buffered byte reader over a [Stream] of [Uint8List] chunks.
///
/// Uses a [Queue] of chunks with a cursor offset to avoid quadratic buffer
/// reallocations when reading small RFB protocol fields.
class BufferedByteReader {
  BufferedByteReader(Stream<Uint8List> stream) {
    _subscription = stream.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  final Queue<Uint8List> _chunks = Queue<Uint8List>();
  int _chunkOffset = 0;
  int _bufferedLength = 0;

  late final StreamSubscription<Uint8List> _subscription;
  bool _closed = false;
  bool _disposed = false;
  Future<void>? _disposeFuture;
  Object? _error;

  Completer<Uint8List>? _readWaiter;
  int _readNeeded = 0;

  Completer<void>? _skipWaiter;
  int _skipRemaining = 0;

  bool get _hasPendingOp => _readWaiter != null || _skipWaiter != null;

  void _onData(Uint8List chunk) {
    if (chunk.isEmpty || _disposed) {
      return;
    }

    final skipWaiter = _skipWaiter;
    if (skipWaiter != null) {
      if (chunk.length <= _skipRemaining) {
        _skipRemaining -= chunk.length;
        if (_skipRemaining == 0) {
          _skipWaiter = null;
          skipWaiter.complete();
        }
        return;
      }
      // Chunk extends past the skipped region: drop the skipped prefix
      // directly and queue only the unread tail.
      final skipNow = _skipRemaining;
      _skipRemaining = 0;
      _skipWaiter = null;
      _chunks.addLast(chunk);
      _chunkOffset = skipNow;
      _bufferedLength = chunk.length - skipNow;
      skipWaiter.complete();
      return;
    }

    _chunks.addLast(chunk);
    _bufferedLength += chunk.length;
    _tryFulfillReadWaiter();
  }

  void _onError(Object error, StackTrace stackTrace) {
    if (_disposed) {
      return;
    }
    _error = error;
    _closed = true;
    _failWaiterIfInsufficient();
  }

  void _onDone() {
    if (_disposed) {
      return;
    }
    _closed = true;
    _failWaiterIfInsufficient();
  }

  void _tryFulfillReadWaiter() {
    final waiter = _readWaiter;
    if (waiter == null || _bufferedLength < _readNeeded) {
      return;
    }
    final count = _readNeeded;
    _readWaiter = null;
    _readNeeded = 0;
    waiter.complete(_consume(count));
  }

  void _failWaiterIfInsufficient() {
    final readWaiter = _readWaiter;
    if (readWaiter != null && _bufferedLength < _readNeeded) {
      final needed = _readNeeded;
      _readWaiter = null;
      _readNeeded = 0;
      readWaiter.completeError(_closedException(needed));
    }

    final skipWaiter = _skipWaiter;
    if (skipWaiter != null && _skipRemaining > 0) {
      final remaining = _skipRemaining;
      _skipWaiter = null;
      _skipRemaining = 0;
      skipWaiter.completeError(_closedException(remaining));
    }
  }

  VncConnectionException _closedException(int needed) {
    if (_error != null) {
      return VncConnectionException(
        'VNC stream error while reading $needed bytes',
        _error,
      );
    }
    if (_disposed) {
      return VncConnectionException(
        'VNC reader disposed while reading $needed bytes',
      );
    }
    return VncConnectionException(
      'VNC stream closed with only $_bufferedLength of $needed bytes available',
    );
  }

  Uint8List _consume(int count) {
    final out = Uint8List(count);
    var written = 0;
    while (written < count) {
      final chunk = _chunks.first;
      final available = chunk.length - _chunkOffset;
      final remaining = count - written;
      final toCopy = available < remaining ? available : remaining;
      out.setRange(written, written + toCopy, chunk, _chunkOffset);
      written += toCopy;
      _chunkOffset += toCopy;
      _bufferedLength -= toCopy;
      if (_chunkOffset == chunk.length) {
        _chunks.removeFirst();
        _chunkOffset = 0;
      }
    }
    return out;
  }

  void _discard(int count) {
    var remaining = count;
    while (remaining > 0) {
      final chunk = _chunks.first;
      final available = chunk.length - _chunkOffset;
      final toSkip = available < remaining ? available : remaining;
      remaining -= toSkip;
      _chunkOffset += toSkip;
      _bufferedLength -= toSkip;
      if (_chunkOffset == chunk.length) {
        _chunks.removeFirst();
        _chunkOffset = 0;
      }
    }
  }

  /// Reads exactly [count] bytes from the stream.
  Future<Uint8List> readBytes(int count) async {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Must be non-negative');
    }
    if (_disposed) {
      throw _closedException(count);
    }
    if (_hasPendingOp) {
      throw StateError(
        'Concurrent reads on BufferedByteReader are not allowed',
      );
    }
    if (count == 0) {
      return Uint8List(0);
    }
    if (_bufferedLength >= count) {
      return _consume(count);
    }
    if (_closed) {
      throw _closedException(count);
    }

    final completer = Completer<Uint8List>();
    _readWaiter = completer;
    _readNeeded = count;
    return completer.future;
  }

  /// Reads an unsigned 8-bit integer.
  Future<int> readUint8() async {
    final bytes = await readBytes(1);
    return bytes[0];
  }

  /// Reads an unsigned 16-bit big-endian integer.
  Future<int> readUint16() async {
    final bytes = await readBytes(2);
    return (bytes[0] << 8) | bytes[1];
  }

  /// Reads an unsigned 32-bit big-endian integer.
  Future<int> readUint32() async {
    final bytes = await readBytes(4);
    return ByteData.sublistView(bytes).getUint32(0, Endian.big);
  }

  /// Reads a signed 32-bit big-endian integer.
  Future<int> readInt32() async {
    final bytes = await readBytes(4);
    return ByteData.sublistView(bytes).getInt32(0, Endian.big);
  }

  /// Skips exactly [count] bytes from the stream without buffering incoming
  /// skipped chunks in memory.
  Future<void> skip(int count) async {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Must be non-negative');
    }
    if (_disposed) {
      throw _closedException(count);
    }
    if (_hasPendingOp) {
      throw StateError(
        'Concurrent reads on BufferedByteReader are not allowed',
      );
    }
    if (count == 0) {
      return;
    }
    if (_bufferedLength >= count) {
      _discard(count);
      return;
    }
    if (_closed) {
      throw _closedException(count);
    }

    final remaining = count - _bufferedLength;
    if (_bufferedLength > 0) {
      _discard(_bufferedLength);
    }

    final completer = Completer<void>();
    _skipWaiter = completer;
    _skipRemaining = remaining;
    return completer.future;
  }

  /// Releases the underlying stream subscription and fails any pending read or
  /// skip. Concurrent calls await the same cancellation future.
  Future<void> dispose() {
    if (_disposeFuture != null) {
      return _disposeFuture!;
    }
    _disposed = true;
    _closed = true;

    final readWaiter = _readWaiter;
    final readNeeded = _readNeeded;
    _readWaiter = null;
    _readNeeded = 0;

    final skipWaiter = _skipWaiter;
    final skipRemaining = _skipRemaining;
    _skipWaiter = null;
    _skipRemaining = 0;

    _chunks.clear();
    _chunkOffset = 0;
    _bufferedLength = 0;

    if (readWaiter != null) {
      readWaiter.completeError(_closedException(readNeeded));
    }
    if (skipWaiter != null) {
      skipWaiter.completeError(_closedException(skipRemaining));
    }

    final future = _subscription.cancel();
    _disposeFuture = future;
    return future;
  }
}
