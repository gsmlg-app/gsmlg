import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:isolate_orchestrator/isolate_orchestrator.dart';

import 'core/buffer/buffer.dart';
import 'core/buffer/cell_offset.dart';
import 'core/buffer/line.dart';
import 'core/buffer/range_line.dart';
import 'core/input/keys.dart';
import 'core/escape/osc52_clipboard_write.dart';
import 'core/platform.dart';
import 'core/mouse/button.dart';
import 'core/mouse/button_state.dart';
import 'core/mouse/mode.dart';
import 'terminal.dart';

const _maxColumns = 512;
const _maxRows = 256;
const _maxScrollback = 100000;
const _maxReplyCodeUnits = 256 * 1024;
const _shutdownTimeout = Duration(seconds: 2);

/// An opaque copy of visible cells in the engine's native cell layout.
/// Each cell is foreground, background, flags, and packed content.
final class TerminalIsolateLine {
  const TerminalIsolateLine(this.id, this.text, this.cells, this.wrapped);

  final int id;

  final String text;
  final Uint32List cells;
  final bool wrapped;
}

final class TerminalIsolateSnapshot {
  const TerminalIsolateSnapshot({
    required this.columns,
    required this.rows,
    required this.cursorColumn,
    required this.cursorRow,
    required this.cursorVisible,
    required this.alternateScreen,
    required this.lines,
    required this.viewId,
    required this.revision,
    required this.firstRow,
    required this.historyRows,
    this.oldestRow = 0,
    this.mouseButtons = false,
    this.mouseWheel = false,
    required this.selectionId,
    required this.selectionAnchorRow,
  });

  final int columns;
  final int rows;
  final int cursorColumn;
  final int cursorRow;
  final bool cursorVisible;
  final bool alternateScreen;
  final List<TerminalIsolateLine> lines;
  final int viewId;
  final int revision;
  final int firstRow;
  final int historyRows;
  final int oldestRow;
  final bool mouseButtons;
  final bool mouseWheel;
  final int? selectionId;
  final int? selectionAnchorRow;
}

final class TerminalIsolatePoint {
  const TerminalIsolatePoint(this.viewId, this.row, this.lineId, this.column);

  final int viewId;
  final int row;
  final int lineId;
  final int column;

  @override
  bool operator ==(Object other) =>
      other is TerminalIsolatePoint &&
      other.viewId == viewId &&
      other.row == row &&
      other.lineId == lineId &&
      other.column == column;

  @override
  int get hashCode => Object.hash(viewId, row, lineId, column);
}

final class TerminalIsolateResult {
  const TerminalIsolateResult._({
    required this.sequence,
    required this.consumedBytes,
    required this.output,
    this.snapshot,
    this.selectionId,
    this.selectionText,
    this.clipboardWrite,
  });

  final int sequence;

  /// The byte credit returned after these bytes reached the UTF-8 decoder
  /// and the decoded characters were parsed, not when sent to the mailbox.
  final int consumedBytes;

  /// Terminal replies or input bytes to write to the session transport.
  final Uint8List output;
  final TerminalIsolateSnapshot? snapshot;
  final int? selectionId;
  final String? selectionText;

  /// At most one untrusted remote write proposal from this parse operation.
  /// The owner must revalidate its captured authority before OS dispatch.
  final (int, String)? clipboardWrite;
}

enum _Operation {
  output,
  finishOutput,
  paste,
  text,
  key,
  resize,
  snapshot,
  beginSelection,
  endSelection,
  copySelection,
  mouse,
  releaseMouse,
}

final class _Command {
  const _Command(this.sequence, this.operation, [this.payload]);

  final int sequence;
  final _Operation operation;
  final Object? payload;
}

final class _PendingCommand {
  _PendingCommand(this.command, this.bytes);

  final _Command command;
  final int bytes;
  final completion = Completer<TerminalIsolateResult>();
}

/// A canonical headless Terminal owned by one orchestrator worker.
///
/// The caller owns the hub and the transport. Submit commands in transport
/// order and await them before reading further when capacity is exhausted.
/// A failed or timed-out RPC does not get replayed.
final class TerminalIsolateSession {
  TerminalIsolateSession._(this._hub, this._name, this.workerId, this._timeout);

  static const maxPendingCommands = 32;
  static const maxPendingBytes = 256 * 1024;
  static const maxCommandBytes = 64 * 1024;

  static Future<TerminalIsolateSession> open(
    IsolateHub hub,
    String name, {
    int scrollback = 1000,
    TerminalTargetPlatform platform = TerminalTargetPlatform.unknown,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    RangeError.checkValueInInterval(
        scrollback, 24, _maxScrollback, 'scrollback');
    if (name.isEmpty ||
        name.contains('/') ||
        hub.lookupNode('/$name') != null) {
      throw ArgumentError.value(name, 'name', 'Expected a unique service name');
    }
    try {
      await hub.registerService(
        ChildSpec(
          name: name,
          entryPoint: _terminalEntry,
          restartType: ChildRestartType.temporary,
          shutdownTimeout: _shutdownTimeout,
          config: {'scrollback': scrollback, 'platform': platform.index},
        ),
      );
      final workerId = await hub.call<String>(
        '/$name',
        'identity',
        timeout: timeout,
      );
      return TerminalIsolateSession._(hub, '/$name', workerId, timeout);
    } catch (_) {
      if (hub.lookupNode('/$name') != null) {
        await hub.removeNode('/$name', timeout: _shutdownTimeout);
      }
      rethrow;
    }
  }

  final IsolateHub _hub;
  final String _name;
  final Duration _timeout;
  final String workerId;
  final _queue = Queue<_PendingCommand>();
  var _nextSequence = 1;
  var _pendingBytes = 0;
  bool _running = false;
  bool _closed = false;
  _PendingCommand? _inFlight;
  Future<void>? _closing;

  Future<TerminalIsolateResult> appendOutput(Uint8List bytes,
      {int? clipboardCapability}) {
    return _submit(
      _Operation.output,
      bytes.length,
      () => (TransferableTypedData.fromList([bytes]), clipboardCapability),
    );
  }

  /// Finalize a normal transport EOF before requesting a final snapshot.
  Future<TerminalIsolateResult> finishOutput() =>
      _submit(_Operation.finishOutput, 0, () => null);

  Future<TerminalIsolateResult> text(String text) =>
      _sendText(_Operation.text, text);

  Future<TerminalIsolateResult> paste(String text) =>
      _sendText(_Operation.paste, text);

  Future<TerminalIsolateResult> _sendText(_Operation operation, String text) {
    if (text.length > maxCommandBytes) {
      return Future.error(
          ArgumentError.value(text.length, 'input text length'));
    }
    return _submit(operation, utf8.encode(text).length, () => text);
  }

  Future<TerminalIsolateResult> key(
    TerminalKey key, {
    bool control = false,
    bool alt = false,
    bool shift = false,
  }) =>
      _submit(_Operation.key, 0, () => (key, control, alt, shift));

  Future<TerminalIsolateResult> resize(int columns, int rows) {
    RangeError.checkValueInInterval(columns, 2, _maxColumns, 'columns');
    RangeError.checkValueInInterval(rows, 1, _maxRows, 'rows');
    return _submit(_Operation.resize, 0, () => (columns, rows));
  }

  Future<TerminalIsolateResult> snapshot({
    int scrollRows = 0,
    bool followTail = false,
  }) =>
      _submit(_Operation.snapshot, 0, () => (scrollRows, followTail));

  /// Releases captured mouse buttons before an exclusive transport mode.
  Future<TerminalIsolateResult> releaseMouse() =>
      _submit(_Operation.releaseMouse, 0, () => null);

  Future<TerminalIsolateResult> mouse(
    TerminalMouseButton button,
    int gesture,
    TerminalIsolatePoint? point,
  ) =>
      _submit(_Operation.mouse, 0, () => (button, gesture, point));

  Future<TerminalIsolateResult> beginSelection(TerminalIsolatePoint point) =>
      _submit(_Operation.beginSelection, 0, () => point);

  Future<TerminalIsolateResult> endSelection(
    int selectionId,
    TerminalIsolatePoint end,
  ) =>
      _submit(_Operation.endSelection, 0, () => (selectionId, end));

  Future<TerminalIsolateResult> copySelection(
    int selectionId,
    TerminalIsolatePoint end,
  ) =>
      _submit(_Operation.copySelection, 0, () => (selectionId, end));

  Future<TerminalIsolateResult> _submit(
    _Operation operation,
    int bytes,
    Object? Function() payload,
  ) {
    if (_closed) return Future.error(StateError('Terminal session closed'));
    if (bytes > maxCommandBytes) {
      return Future.error(ArgumentError.value(bytes, 'command length'));
    }
    if (_queue.length + (_inFlight == null ? 0 : 1) >= maxPendingCommands ||
        _pendingBytes + bytes > maxPendingBytes) {
      return Future.error(StateError('Terminal session capacity reached'));
    }
    final pending = _PendingCommand(
      _Command(_nextSequence++, operation, payload()),
      bytes,
    );
    _pendingBytes += bytes;
    _queue.addLast(pending);
    if (!_running) unawaited(_drain());
    return pending.completion.future;
  }

  Future<void> _drain() async {
    _running = true;
    try {
      while (!_closed && _queue.isNotEmpty) {
        final pending = _queue.removeFirst();
        _inFlight = pending;
        try {
          final result = await _hub.call<TerminalIsolateResult>(
            _name,
            pending.command,
            timeout: _timeout,
          );
          if (!_closed) {
            if (result.sequence != pending.command.sequence ||
                result.consumedBytes !=
                    (pending.command.operation == _Operation.output
                        ? pending.bytes
                        : 0)) {
              throw StateError('Invalid terminal result or byte credit');
            }
            pending.completion.complete(result);
          }
        } catch (error, stackTrace) {
          if (!pending.completion.isCompleted) {
            pending.completion.completeError(error, stackTrace);
          }
          // A timeout is ambiguous: stop both the queue and its worker rather
          // than replaying an operation or proceeding on unknown parser state.
          unawaited(close().catchError((Object _) {}));
        } finally {
          _pendingBytes -= pending.bytes;
          _inFlight = null;
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<void> close() {
    if (_closing case final closing?) return closing;
    _closed = true;
    final error = StateError('Terminal session closed');
    final inFlight = _inFlight;
    if (inFlight != null && !inFlight.completion.isCompleted) {
      inFlight.completion.completeError(error);
    }
    while (_queue.isNotEmpty) {
      final pending = _queue.removeFirst();
      _pendingBytes -= pending.bytes;
      pending.completion.completeError(error);
    }
    return _closing = _hub.removeNode(_name, timeout: _shutdownTimeout);
  }
}

void _terminalEntry(SendPort hub) {
  runWorker<Object?>(hub, _TerminalWorker.new);
}

final class _TerminalWorker extends Worker<Object?>
    with WorkerMetricsMixin<Object?> {
  _TerminalWorker(this.context);

  @override
  final WorkerContext context;
  late final Terminal _terminal;
  late final ByteConversionSink _decoder;
  final _output = StringBuffer();
  int? _clipboardCapability;
  (int, String)? _clipboardWrite;
  var _expectedSequence = 1;
  bool _outputFinished = false;
  final _lineIds = Expando<int>();
  int _nextLineId = 0;
  int _revision = 0;
  int _geometryEpoch = 0;
  int _nextViewId = 0;
  final _mouseDowns = <TerminalMouseButton, (int, int, int, CellOffset)>{};
  final _frames = <int, _PublishedFrame>{};
  WeakReference<BufferLine>? _historyTop;
  int _selectionSequence = 0;
  _SelectionAnchor? _selection;
  (TerminalIsolatePoint, _PublishedFrame)? _selectionEnd;
  late final int _configuredScrollback;
  static const _maxCopyBytes = 64 * 1024;

  @override
  Future<void> onInit(Map<String, dynamic> config) async {
    initMetrics();
    _configuredScrollback = config['scrollback'] as int;
    _terminal = Terminal(
      maxLines: _configuredScrollback,
      platform: TerminalTargetPlatform.values[config['platform'] as int],
      onOutput: _writeReply,
      osc52Capability: () => _clipboardCapability,
      onPrivateOSC: (code, args) {
        final capability = _clipboardCapability;
        if (capability == null) return;
        final text = Osc52ClipboardWrite.decode(code, args);
        if (text != null) _clipboardWrite = (capability, text);
      },
      batchWrites: false,
    );
    _decoder = const Utf8Decoder(allowMalformed: true).startChunkedConversion(
      StringConversionSink.from(_TerminalTextSink(_terminal.write)),
    );
  }

  @override
  Future<Object?> onTask(
    Object? data, {
    String? taskType,
    Map<String, dynamic>? metadata,
  }) async =>
      throw UnsupportedError('Use the terminal session RPC');

  @override
  Future<Object?> onCall(
    Object? request, {
    required IsolateAddress sender,
    Map<String, dynamic>? metadata,
  }) async {
    if (request == 'identity') return context.id;
    if (request is! _Command || request.sequence != _expectedSequence) {
      throw StateError('Out-of-order terminal command');
    }
    _expectedSequence++;
    var consumed = 0;
    TerminalIsolateSnapshot? snapshot;
    int? selectionId;
    String? selectionText;
    switch (request.operation) {
      case _Operation.output:
        if (_outputFinished) throw StateError('Terminal output already ended');
        final (transfer, capability) =
            request.payload as (TransferableTypedData, int?);
        final bytes = transfer.materialize().asUint8List();
        _clipboardCapability = capability;
        try {
          _decoder.add(bytes);
        } finally {
          _clipboardCapability = null;
        }
        _retainConfiguredHistory();
        if (bytes.isNotEmpty) _revision++;
        consumed = bytes.length;
      case _Operation.finishOutput:
        if (!_outputFinished) {
          _outputFinished = true;
          _decoder.close();
          _retainConfiguredHistory();
          _revision++;
        }
      case _Operation.paste:
        _terminal.paste(request.payload as String);
      case _Operation.text:
        _terminal.textInput(request.payload as String);
      case _Operation.key:
        final (key, control, alt, shift) =
            request.payload as (TerminalKey, bool, bool, bool);
        _terminal.keyInput(key, ctrl: control, alt: alt, shift: shift);
      case _Operation.resize:
        final (columns, rows) = request.payload as (int, int);
        if (columns != _terminal.viewWidth || rows != _terminal.viewHeight) {
          for (final buffer in [_terminal.mainBuffer, _terminal.altBuffer]) {
            if (buffer.lines.maxLength < rows) buffer.lines.maxLength = rows;
          }
          _releaseMouse();
          _terminal.resize(columns, rows);
          _retainConfiguredHistory();
          _geometryEpoch++;
          _revision++;
          _selection = null;
          _selectionEnd = null;
        }
      case _Operation.snapshot:
        final (scrollRows, followTail) = request.payload as (int, bool);
        snapshot = _snapshot(scrollRows, followTail);
      case _Operation.releaseMouse:
        _releaseMouse();
      case _Operation.mouse:
        final (button, gesture, point) = request.payload as (
          TerminalMouseButton,
          int,
          TerminalIsolatePoint?
        );
        _mouse(button, gesture, point);
      case _Operation.beginSelection:
        selectionId = _beginSelection(request.payload as TerminalIsolatePoint);
      case _Operation.endSelection:
        final (id, end) = request.payload as (int, TerminalIsolatePoint);
        if (_endSelection(id, end)) selectionId = id;
      case _Operation.copySelection:
        final (id, end) = request.payload as (int, TerminalIsolatePoint);
        selectionText = _copySelection(id, end);
    }
    try {
      return TerminalIsolateResult._(
        sequence: request.sequence,
        consumedBytes: consumed,
        output: utf8.encode(_output.toString()),
        snapshot: snapshot,
        selectionId: selectionId,
        selectionText: selectionText,
        clipboardWrite: _clipboardWrite,
      );
    } finally {
      _output.clear();
      _clipboardWrite = null;
    }
  }

  void _writeReply(String data) {
    if (_output.length + data.length > _maxReplyCodeUnits) {
      throw StateError('Terminal reply capacity reached');
    }
    _output.write(data);
  }

  int _id(BufferLine line) => _lineIds[line] ??= ++_nextLineId;

  int? _lineIndex(Buffer buffer, BufferLine? line) {
    if (line == null || !line.attached) return null;
    final index = line.index;
    return index >= 0 &&
            index < buffer.height &&
            identical(buffer.lines[index], line)
        ? index
        : null;
  }

  int _contentHash(BufferLine line, int columns) => Object.hash(
        line.isWrapped,
        Object.hashAll(
          Iterable<int>.generate(columns, (column) => line.getContent(column)),
        ),
      );

  void _retainConfiguredHistory() {
    final buffer = _terminal.mainBuffer;
    final rows = _terminal.viewHeight;
    final retained =
        _configuredScrollback > rows ? _configuredScrollback : rows;
    final excess = buffer.height - retained;
    if (excess > 0) buffer.lines.trimStart(excess);
  }

  int _oldestRow(Buffer buffer) {
    if (_terminal.isUsingAltBuffer) return 0;
    final rows = _terminal.viewHeight;
    final retained =
        _configuredScrollback > rows ? _configuredScrollback : rows;
    return (buffer.height - retained).clamp(0, buffer.scrollBack);
  }

  void _releaseMouse() {
    for (final entry in _mouseDowns.entries) {
      final down = entry.value;
      if (down.$2 == _terminal.mouseContextEpoch && down.$3 == _geometryEpoch) {
        _terminal.mouseInput(entry.key, TerminalMouseButtonState.up, down.$4);
      }
    }
    _mouseDowns.clear();
  }

  void _mouse(
    TerminalMouseButton button,
    int gesture,
    TerminalIsolatePoint? point,
  ) {
    final context = _terminal.mouseContextEpoch;
    _mouseDowns.removeWhere(
        (_, entry) => entry.$2 != context || entry.$3 != _geometryEpoch);
    if (point == null) {
      final down = _mouseDowns[button];
      if (down == null || down.$1 != gesture) return;
      _mouseDowns.remove(button);
      _terminal.mouseInput(button, TerminalMouseButtonState.up, down.$4);
      return;
    }
    if (point.viewId != _nextViewId) return;
    final frame = _frames[point.viewId];
    if (frame == null ||
        frame.revision != _revision ||
        frame.epoch != _geometryEpoch ||
        frame.first != frame.historyRows ||
        !identical(frame.buffer, _terminal.buffer) ||
        point.column < 0 ||
        point.column >= _terminal.viewWidth ||
        _validatedHit(point) == null) {
      return;
    }
    if (button.isWheel) {
      if (!_terminal.isUsingAltBuffer ||
          !_terminal.mouseMode.reportScroll ||
          button == TerminalMouseButton.wheelLeft ||
          button == TerminalMouseButton.wheelRight) {
        return;
      }
    } else if (_mouseDowns.containsKey(button)) {
      return;
    }
    final cell = CellOffset(point.column, point.row);
    if (_terminal.mouseInput(button, TerminalMouseButtonState.down, cell) &&
        !button.isWheel) {
      _mouseDowns[button] = (gesture, context, _geometryEpoch, cell);
    }
  }

  TerminalIsolateSnapshot _snapshot(int scrollRows, bool followTail) {
    final buffer = _terminal.buffer;
    final columns = _terminal.viewWidth;
    final rows = _terminal.viewHeight;
    final alternate = _terminal.isUsingAltBuffer;
    final historyRows = alternate ? 0 : buffer.scrollBack;
    final oldest = _oldestRow(buffer);
    final top = alternate || followTail || _historyTop == null
        ? historyRows
        : _lineIndex(buffer, _historyTop?.target) ?? oldest;
    final first = (top + scrollRows).clamp(oldest, historyRows);
    if (!alternate) {
      _historyTop =
          first == historyRows ? null : WeakReference(buffer.lines[first]);
    }
    final viewId = ++_nextViewId;
    final publishedLines = <_PublishedLine>[];
    final lines = <TerminalIsolateLine>[];
    for (var index = first; index < first + rows; index++) {
      final line = buffer.lines[index];
      final id = _id(line);
      publishedLines.add(_PublishedLine(
        WeakReference(line),
        id,
        _contentHash(line, columns),
      ));
      lines.add(TerminalIsolateLine(
        id,
        line.getText(),
        Uint32List.fromList(Uint32List.sublistView(line.data, 0, columns * 4)),
        line.isWrapped,
      ));
    }
    if (_frames.length == 4) _frames.remove(_frames.keys.first);
    _frames[viewId] = _PublishedFrame(
      buffer: buffer,
      epoch: _geometryEpoch,
      revision: _revision,
      first: first,
      historyRows: historyRows,
      lines: publishedLines,
    );
    final selection = _selection;
    final selectedLine = selection?.line.reference.target;
    final index = selection != null && identical(selection.buffer, buffer)
        ? _lineIndex(buffer, selectedLine)
        : null;
    final anchorIndex = index != null &&
            index >= oldest &&
            selection != null &&
            selectedLine != null &&
            selection.line.contentHash == _contentHash(selectedLine, columns) &&
            (selection.revision == _revision ||
                selection.wasHistory && index < historyRows)
        ? index
        : null;
    final cursorRow = buffer.absoluteCursorY - first;
    return TerminalIsolateSnapshot(
      columns: columns,
      rows: rows,
      cursorColumn: buffer.cursorX,
      cursorRow: cursorRow,
      cursorVisible:
          _terminal.cursorVisibleMode && cursorRow >= 0 && cursorRow < rows,
      alternateScreen: alternate,
      lines: lines,
      viewId: viewId,
      revision: _revision,
      firstRow: first,
      historyRows: historyRows,
      oldestRow: oldest,
      mouseButtons:
          first == historyRows && _terminal.mouseMode != MouseMode.none,
      mouseWheel: alternate && _terminal.mouseMode.reportScroll,
      selectionId: anchorIndex == null ? null : selection?.id,
      selectionAnchorRow: anchorIndex,
    );
  }

  (_PublishedFrame, _PublishedLine, BufferLine)? _validatedHit(
    TerminalIsolatePoint point, {
    _PublishedFrame? pinned,
  }) {
    final frame = _frames[point.viewId] ?? pinned;
    final buffer = _terminal.buffer;
    final columns = _terminal.viewWidth;
    if (frame == null ||
        !identical(frame.buffer, buffer) ||
        frame.epoch != _geometryEpoch ||
        point.row < 0 ||
        point.row >= frame.lines.length ||
        point.column < 0 ||
        point.column > columns) {
      return null;
    }
    final stamp = frame.lines[point.row];
    final line = stamp.reference.target;
    final index = _lineIndex(buffer, line);
    if (line == null ||
        stamp.id != point.lineId ||
        index == null ||
        index < _oldestRow(buffer) ||
        stamp.contentHash != _contentHash(line, columns)) {
      return null;
    }
    final wasHistory = frame.first + point.row < frame.historyRows;
    final isHistory = line.index < buffer.scrollBack;
    if (frame.revision != _revision && !(wasHistory && isHistory)) return null;
    return (frame, stamp, line);
  }

  int? _beginSelection(TerminalIsolatePoint point) {
    final hit = _validatedHit(point);
    _selection = null;
    _selectionEnd = null;
    if (hit == null) return null;
    final (frame, stamp, _) = hit;
    final id = ++_selectionSequence;
    _selection = _SelectionAnchor(
      id: id,
      buffer: frame.buffer,
      revision: _revision,
      line: stamp,
      wasHistory: frame.first + point.row < frame.historyRows,
      column: point.column,
    );
    return id;
  }

  int _snapColumn(BufferLine line, int column, {required bool end}) {
    if (column > 0 && column < line.length && line.getWidth(column - 1) == 2) {
      return end ? column + 1 : column - 1;
    }
    return column;
  }

  bool _endSelection(int id, TerminalIsolatePoint point) {
    if (_selection?.id != id) return false;
    final hit = _validatedHit(point);
    _selectionEnd = hit == null ? null : (point, hit.$1);
    return hit != null;
  }

  String? _copySelection(int id, TerminalIsolatePoint point) {
    final selection = _selection;
    final endpoint = _selectionEnd;
    final hit = _validatedHit(point,
        pinned: endpoint?.$1 == point ? endpoint?.$2 : null);
    if (selection == null || selection.id != id || hit == null) return null;
    final (frame, _, end) = hit;
    final start = selection.line.reference.target;
    final columns = _terminal.viewWidth;
    final buffer = frame.buffer;
    final startIndex = _lineIndex(buffer, start);
    if (start == null ||
        !identical(selection.buffer, buffer) ||
        startIndex == null ||
        startIndex < _oldestRow(buffer) ||
        selection.line.contentHash != _contentHash(start, columns)) {
      return null;
    }
    final bothInHistory = selection.wasHistory &&
        frame.first + point.row < frame.historyRows &&
        start.index < buffer.scrollBack &&
        end.index < buffer.scrollBack;
    if (selection.revision != _revision && !bothInHistory) return null;
    final rowDistance = (start.index - end.index).abs();
    if ((rowDistance + 1) * (columns * 4 + 1) > _maxCopyBytes) return null;

    if (start.index == end.index && selection.column == point.column) {
      return null;
    }
    final forward = start.index < end.index ||
        (start.index == end.index && selection.column <= point.column);
    final endColumn = _snapColumn(end, point.column, end: forward);
    final beginColumn = _snapColumn(start, selection.column, end: !forward);
    return buffer.getText(BufferRangeLine(
      CellOffset(beginColumn, start.index),
      CellOffset(endColumn, end.index),
    ));
  }

  @override
  Future<void> onShutdown() async {
    // Closing the session aborts; graceful EOF is a serialized operation.
    _terminal.dispose();
  }
}

final class _TerminalTextSink implements Sink<String> {
  const _TerminalTextSink(this.write);

  final void Function(String) write;

  @override
  void add(String data) => write(data);

  @override
  void close() {}
}

final class _PublishedLine {
  const _PublishedLine(this.reference, this.id, this.contentHash);
  final WeakReference<BufferLine> reference;
  final int id;
  final int contentHash;
}

final class _PublishedFrame {
  const _PublishedFrame({
    required this.buffer,
    required this.epoch,
    required this.revision,
    required this.first,
    required this.historyRows,
    required this.lines,
  });
  final Buffer buffer;
  final int epoch;
  final int revision;
  final int first;
  final int historyRows;
  final List<_PublishedLine> lines;
}

final class _SelectionAnchor {
  const _SelectionAnchor({
    required this.id,
    required this.buffer,
    required this.revision,
    required this.line,
    required this.wasHistory,
    required this.column,
  });
  final int id;
  final Buffer buffer;
  final int revision;
  final _PublishedLine line;
  final bool wasHistory;
  final int column;
}
