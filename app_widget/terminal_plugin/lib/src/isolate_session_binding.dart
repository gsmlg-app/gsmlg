import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:xterm/session_isolate.dart';
import 'package:xterm/session_isolate_probes.dart';

import 'zmodem/zmodem_file_access.dart';
import 'zmodem/zmodem_transfer_controller.dart';

typedef _Operation = Future<void> Function();

/// Owns one session transport and its canonical terminal worker. Only the
/// captured transport ever receives replies from this binding.
final class IsolateSessionBinding {
  IsolateSessionBinding(
    this._terminal,
    this._transport, {
    required this.onClosed,
    this.clipboardCapability,
    this.onClipboardWrite,
    this.projectOnlyWhenVisible = false,
    ZmodemFileAccess? transferFiles,
  }) {
    zmodem = transferFiles == null
        ? null
        : ZmodemTransferController(
            onTerminalOutput: _onTerminalOutput,
            writeToSession: _writeTransfer,
            files: transferFiles,
            awaitInitialFrame: true,
          );
  }

  static const _maxPendingOperations = 32;
  static const _maxFrameBytes = 256 * 1024;
  static const _operationTimeout = Duration(seconds: 5);

  final TerminalIsolateSession _terminal;
  final ExecutionSession _transport;
  final void Function(Object? error) onClosed;
  final int? Function()? clipboardCapability;

  @visibleForTesting
  void Function(int?)? onParseClipboardCapability;
  final void Function(int capability, String text)? onClipboardWrite;
  final bool projectOnlyWhenVisible;
  bool _viewVisible = false;
  int _projectionEpoch = 0;

  bool get _canProject => !projectOnlyWhenVisible || _viewVisible;

  void setProjectionVisible(bool visible) {
    if (_viewVisible == visible || _closing) return;
    _viewVisible = visible;
    if (!projectOnlyWhenVisible) return;
    _projectionEpoch++;
    if (visible) {
      _requestProjection(immediate: true);
    } else {
      _projectionTimer?.cancel();
      _projectionTimer = null;
      _projectionPending = false;
    }
  }

  final snapshot = ValueNotifier<TerminalIsolateSnapshot?>(null);
  final _operations = Queue<_Operation>();
  late final ZmodemTransferController? zmodem;
  BytesBuilder? _collectingTerminalOutput;
  Completer<void>? _prefixBarrier;
  Future<void> _egressTail = Future<void>.value();
  int _pendingWrites = 0;
  final _pendingQueries = <VoidCallback>{};
  int _pendingScrollRows = 0;
  int _pendingMouse = 0;
  final _mouseRoutes = <TerminalMouseButton, int>{};
  bool _followTail = false;
  bool _projectingViewportMove = false;
  StreamSubscription<Uint8List>? _output;
  Timer? _projectionTimer;
  bool _processing = false;
  bool _closing = false;
  bool _transportEnded = false;
  bool _projectionPending = false;
  Future<void>? _closeFuture;

  bool get isClosed => _closing;
  bool get canAcceptClipboardEffects => !_closing && !_transportEnded;

  void start() {
    if (_closing || _output != null) {
      throw StateError('Cannot start this terminal binding');
    }
    _output = _transport.output.listen(
      _onFrame,
      onError: _fail,
      onDone: () {
        _transportEnded = true;
        _schedule(() async {
          if (zmodem case final transfer?) {
            final probe = BytesBuilder(copy: false);
            _collectingTerminalOutput = probe;
            try {
              transfer.flushTerminalProbe();
            } finally {
              _collectingTerminalOutput = null;
            }
            await _parseTerminal(probe.takeBytes(), null);
          }
          await _apply(await _terminal.finishOutput());
          await _project();
          await close();
          onClosed(null);
        });
      },
    );
    // Observe transport errors without treating exitCode as final output EOF.
    unawaited(_transport.exitCode.then<void>((_) {}, onError: _fail));
    _schedule(_project);
  }

  void _onFrame(Uint8List frame) {
    if (_closing) return;
    final subscription = _output!;
    // Stamp on admission, never at eventual parse time.
    final capability = clipboardCapability?.call();
    subscription.pause();
    if (frame.length > _maxFrameBytes) {
      _fail(StateError('Terminal output frame exceeded the receive limit'));
      return;
    }
    // Once the controller owns ingress, handleSessionOutput only enqueues
    // binary protocol bytes. The first-frame barrier has already completed.
    final active = zmodem;
    if (active != null && active.isActive) {
      final pending = active.handleSessionOutput(frame);
      if (pending is Future<void>) {
        unawaited(pending
            .then<void>((_) => _finishFrame(subscription))
            .catchError(_fail));
      } else {
        _finishFrame(subscription);
      }
      return;
    }
    _schedule(() async {
      final transfer = zmodem;
      if (transfer == null) {
        await _parseTerminal(frame, capability);
        _finishFrame(subscription);
        return;
      }

      // Demux synchronously, then parse the ordinary prefix before the
      // transfer's first write. A picker may remain pending independently
      // of the worker/UI operations; only this channel's read stays paused.
      // A partial signature holds at most 19 lookahead bytes. Release that
      // frame's credit after its ordinary prefix; withholding the whole frame
      // would prevent the next one from completing the signature.
      final output = BytesBuilder(copy: false);
      final barrier = Completer<void>();
      _prefixBarrier = barrier;
      _collectingTerminalOutput = output;
      try {
        final activeBefore = transfer.isActive;
        // Scanner passthrough may contain an older frame's probe prefix.
        // Treat the whole output batch as untrusted rather than upgrading it
        // to the newest grant after bytes have been merged.
        final parseCapability =
            transfer.hasPendingTerminalProbe ? null : capability;
        final pending = transfer.handleSessionOutput(frame);
        final transferBegan = !activeBefore && transfer.isActive;
        if (pending is Future<void>) {
          // Observe failure right away, even while the parser prefix runs.
          unawaited(pending.then<void>((_) async {
            await barrier.future;
            _finishFrame(subscription);
          }).catchError(_fail));
        }
        _collectingTerminalOutput = null;
        await _parseTerminal(output.takeBytes(), parseCapability);
        if (transferBegan && !_closing) {
          _mouseRoutes.clear();
          await _apply(await _terminal.releaseMouse());
        }
        if (pending is! Future<void>) _finishFrame(subscription);
      } finally {
        _collectingTerminalOutput = null;
        _prefixBarrier = null;
        barrier.complete();
      }
    });
  }

  void _finishFrame(StreamSubscription<Uint8List> subscription) {
    if (_closing) return;
    _transport.ackRead();
    subscription.resume();
  }

  void _onTerminalOutput(Uint8List bytes) {
    if (_closing) return;
    if (_collectingTerminalOutput case final collecting?) {
      collecting.add(bytes);
    } else if (!_transportEnded) {
      // A deferred scanner probe must never receive a newer clipboard grant.
      _schedule(() => _parseTerminal(bytes, null));
    }
  }

  Future<void> _parseTerminal(Uint8List bytes, int? capability) async {
    for (var start = 0;
        start < bytes.length && !_closing;
        start += TerminalIsolateSession.maxCommandBytes) {
      final remaining = bytes.length - start;
      final count = remaining < TerminalIsolateSession.maxCommandBytes
          ? remaining
          : TerminalIsolateSession.maxCommandBytes;
      final parseCapability =
          capability == clipboardCapability?.call() ? capability : null;
      onParseClipboardCapability?.call(parseCapability);
      final consumed = await _terminal.appendOutput(
        Uint8List.sublistView(bytes, start, start + count),
        clipboardCapability: parseCapability,
      );
      await _apply(consumed);
    }
    if (bytes.isNotEmpty) _requestProjection();
  }

  Future<void> _writeTransfer(Uint8List bytes) async {
    final epoch = zmodem!.transferEpoch;
    if (_prefixBarrier case final barrier?) await barrier.future;
    await _write(bytes, stillCurrent: () => zmodem!.transferEpoch == epoch);
  }

  Future<void> _write(Uint8List bytes, {bool Function()? stillCurrent}) {
    if (_closing) return Future<void>.value();
    if (_pendingWrites >= 8 || bytes.length > _maxFrameBytes) {
      final error = StateError('Terminal transport write capacity reached');
      _fail(error);
      return Future<void>.value();
    }
    _pendingWrites++;
    final write = _egressTail.then((_) async {
      if (!_closing && (stillCurrent?.call() ?? true)) {
        await _transport.write(bytes).timeout(_operationTimeout);
      }
    }).whenComplete(() => _pendingWrites--);
    _egressTail = write.then<void>((_) {}, onError: _fail);
    return write;
  }

  bool get _transferOwnsInput =>
      (zmodem?.isActive ?? false) || (zmodem?.isDraining ?? false);

  bool key(TerminalKey key,
      {bool ctrl = false, bool alt = false, bool shift = false}) {
    if (_transferOwnsInput) {
      if (ctrl && key == TerminalKey.keyC) {
        unawaited(zmodem!.cancel().catchError(_fail));
      }
      return true;
    }
    return _send(
        () => _terminal.key(key, control: ctrl, alt: alt, shift: shift));
  }

  bool text(String text) => _sendText(text, _terminal.text);

  bool paste(String text) => _sendText(text, _terminal.paste);

  bool _sendText(
    String text,
    Future<TerminalIsolateResult> Function(String) apply,
  ) {
    if (_closing || _transportEnded) return false;
    if (_transferOwnsInput) return true;
    const limit = TerminalIsolateSession.maxCommandBytes;
    if (text.length > limit || utf8.encode(text).length > limit) {
      _fail(StateError('Terminal input exceeded the send limit'));
      return false;
    }
    return _send(() => apply(text));
  }

  bool _send(Future<TerminalIsolateResult> Function() action) {
    if (_transportEnded || _closing) return false;
    final current = snapshot.value;
    if (_pendingScrollRows != 0 ||
        (current != null && current.firstRow != current.historyRows)) {
      _pendingScrollRows = 0;
      _followTail = true;
      _requestProjection();
    }
    return _schedule(() async {
      if (_transferOwnsInput) return;
      final result = await action();
      if (!_transferOwnsInput) await _apply(result);
    });
  }

  void mouse(
    TerminalMouseButton button,
    int gesture,
    TerminalIsolatePoint? point,
  ) {
    if (_transportEnded || _closing) return;
    if (point == null) {
      if (_mouseRoutes[button] != gesture) return;
      _mouseRoutes.remove(button);
    } else {
      // Mouse traffic is best effort. Preserve queue space for parser work
      // and for terminating captured button routes.
      if (_transferOwnsInput ||
          _pendingScrollRows != 0 ||
          _followTail ||
          _projectingViewportMove ||
          _pendingMouse >= 8 ||
          _operations.length >= _maxPendingOperations - 8 ||
          _mouseRoutes.containsKey(button)) {
        return;
      }
      if (!button.isWheel) _mouseRoutes[button] = gesture;
    }
    _pendingMouse++;
    // A captured release may claim one of three reserved slots. A new down
    // cannot enter until the queue is back below its normal limit.
    _operations.addLast(() async {
      try {
        if (_transferOwnsInput) return;
        await _apply(await _terminal.mouse(button, gesture, point));
      } finally {
        _pendingMouse--;
      }
    });
    if (!_processing) unawaited(_drain());
  }

  void scrollRows(int rows) {
    if (_closing || rows == 0) return;
    _pendingScrollRows = (_pendingScrollRows + rows).clamp(-100000, 100000);
    _requestProjection();
  }

  Future<int?> beginSelection(TerminalIsolatePoint point) => _query(() async {
        final result = await _terminal.beginSelection(point);
        if (result.selectionId != null) _requestProjection();
        return result.selectionId;
      });

  Future<void> endSelection(int selectionId, TerminalIsolatePoint end) async {
    await _query(() => _terminal.endSelection(selectionId, end));
  }

  Future<String?> copySelection(int selectionId, TerminalIsolatePoint end) =>
      _query(() async {
        final result = await _terminal.copySelection(selectionId, end);
        return result.selectionText;
      });

  Future<T?> _query<T>(Future<T?> Function() execute) {
    final result = Completer<T?>();
    void discarded() {
      if (!result.isCompleted) result.complete(null);
    }

    _pendingQueries.add(discarded);
    if (!_schedule(() async {
      try {
        final value = await execute();
        if (!result.isCompleted) result.complete(_closing ? null : value);
      } finally {
        discarded();
        _pendingQueries.remove(discarded);
      }
    })) {
      _pendingQueries.remove(discarded);
      discarded();
    }
    return result.future;
  }

  bool resize(int columns, int rows) {
    if (_transportEnded) return false;
    return _schedule(() async {
      final result = await _terminal.resize(columns, rows);
      if (!_transferOwnsInput) await _apply(result);
      if (_closing) return;
      await _transport.resize(columns, rows).timeout(_operationTimeout);
      _requestProjection();
    });
  }

  Future<void> _apply(TerminalIsolateResult result) async {
    final effect = result.clipboardWrite;
    if (canAcceptClipboardEffects &&
        effect != null &&
        clipboardCapability?.call() == effect.$1) {
      onClipboardWrite?.call(effect.$1, effect.$2);
    }
    if (!_closing && result.output.isNotEmpty) {
      await _write(result.output);
    }
  }

  void _requestProjection({bool immediate = false}) {
    if (_closing || !_canProject || _projectionPending) return;
    final epoch = _projectionEpoch;
    _projectionPending = true;

    void schedule() {
      _projectionTimer = null;
      _schedule(() async {
        if (_projectionEpoch != epoch) return;
        _projectionPending = false;
        await _project();
      });
    }

    if (immediate) {
      schedule();
    } else {
      _projectionTimer = Timer(const Duration(milliseconds: 16), schedule);
    }
  }

  Future<void> _project() async {
    if (!_canProject || _closing) return;
    final epoch = _projectionEpoch;
    final scrollRows = _pendingScrollRows;
    final followTail = _followTail;
    _pendingScrollRows = 0;
    _followTail = false;
    _projectingViewportMove = scrollRows != 0 || followTail;
    try {
      final rpc = TerminalIsolateProbes.start();
      final result = await _terminal.snapshot(
        scrollRows: scrollRows,
        followTail: followTail,
      );
      TerminalIsolateProbes.finish('isolate.snapshot_rpc_wall', rpc);
      if (!_closing && _canProject && epoch == _projectionEpoch) {
        final publish = TerminalIsolateProbes.start();
        snapshot.value = result.snapshot;
        TerminalIsolateProbes.finish('isolate.snapshot_notify', publish);
      }
    } finally {
      _projectingViewportMove = false;
    }
  }

  bool _schedule(_Operation operation) {
    if (_closing) return false;
    if (_operations.length >= _maxPendingOperations) {
      _fail(StateError('Terminal operation capacity reached'));
      return false;
    }
    _operations.addLast(operation);
    if (!_processing) unawaited(_drain());
    return true;
  }

  Future<void> _drain() async {
    _processing = true;
    try {
      while (!_closing && _operations.isNotEmpty) {
        await _operations.removeFirst()();
      }
    } catch (error) {
      _fail(error);
    } finally {
      _processing = false;
    }
  }

  void _fail(Object error) {
    if (_closing) return;
    unawaited(close().catchError((Object _) {}));
    onClosed(error);
  }

  Future<void> close() {
    if (_closeFuture case final closing?) return closing;
    final completion = Completer<void>();
    _closeFuture = completion.future;
    _closing = true;
    _mouseRoutes.clear();
    _projectionTimer?.cancel();
    _operations.clear();
    for (final discarded in _pendingQueries.toList()) {
      discarded();
    }
    _pendingQueries.clear();
    // Do not depend on a stalled pending command or stream write for closing.
    completion.complete(Future.wait<void>([
      if (_output case final subscription?)
        subscription.cancel().timeout(_operationTimeout),
      if (zmodem case final transfer?)
        transfer.dispose().timeout(_operationTimeout),
      _terminal.close(),
      _transport.close().timeout(_operationTimeout),
    ]).then<void>((_) {}));
    return completion.future;
  }
}
