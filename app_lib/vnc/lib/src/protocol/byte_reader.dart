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
  Object? _error;

  Completer<Uint8List?>? _waiter;
  int _neededBytes = 0;
  bool _discardWaiter = false;

  void _onData(Uint8List chunk) {
    if (chunk.isEmpty || _disposed) {
      return;
    }
    _chunks.addLast(chunk);
    _bufferedLength += chunk.length;
    _tryFulfillWaiter();
  }

  void _onError(Object error, StackTrace stackTrace) {
    _error = error;
    _closed = true;
    _failWaiterIfInsufficient();
  }

  void _onDone() {
    _closed = true;
    _failWaiterIfInsufficient();
  }

  void _tryFulfillWaiter() {
    final waiter = _waiter;
    if (waiter == null || _bufferedLength < _neededBytes) {
      return;
    }
    final count = _neededBytes;
    final discard = _discardWaiter;
    _waiter = null;
    _neededBytes = 0;
    _discardWaiter = false;

    if (discard) {
      _discard(count);
      waiter.complete(null);
    } else {
      waiter.complete(_consume(count));
    }
  }

  void _failWaiterIfInsufficient() {
    final waiter = _waiter;
    if (waiter == null || _bufferedLength >= _neededBytes) {
      return;
    }
    final needed = _neededBytes;
    _waiter = null;
    _neededBytes = 0;
    _discardWaiter = false;
    waiter.completeError(_closedException(needed));
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
    if (_waiter != null) {
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
    if (_closed || _disposed) {
      throw _closedException(count);
    }

    final completer = Completer<Uint8List?>();
    _waiter = completer;
    _neededBytes = count;
    _discardWaiter = false;

    final result = await completer.future;
    return result!;
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

  /// Skips exactly [count] bytes from the stream.
  Future<void> skip(int count) async {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Must be non-negative');
    }
    if (_waiter != null) {
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
    if (_closed || _disposed) {
      throw _closedException(count);
    }

    final completer = Completer<Uint8List?>();
    _waiter = completer;
    _neededBytes = count;
    _discardWaiter = true;

    await completer.future;
  }

  /// Releases the underlying stream subscription and fails any pending read.
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _closed = true;

    final waiter = _waiter;
    final needed = _neededBytes;
    _waiter = null;
    _neededBytes = 0;
    _discardWaiter = false;

    _chunks.clear();
    _chunkOffset = 0;
    _bufferedLength = 0;

    if (waiter != null) {
      waiter.completeError(_closedException(needed));
    }

    await _subscription.cancel();
  }
}
