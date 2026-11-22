import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'session_isolate.dart';
import 'session_isolate_probes.dart';
import 'src/core/cell.dart';
import 'src/ui/cursor_type.dart';
import 'src/ui/custom_text_edit.dart';
import 'src/ui/input_map.dart';
import 'src/ui/painter.dart';
import 'src/ui/terminal_text_style.dart';
import 'src/ui/themes.dart';

typedef TerminalIsolateMouse = void Function(
  TerminalMouseButton button,
  int gesture,
  TerminalIsolatePoint? point,
);

typedef TerminalIsolateKey = bool Function(
  TerminalKey key, {
  required bool ctrl,
  required bool alt,
  required bool shift,
});

/// Paints a worker snapshot directly. It does not run a terminal parser.
class TerminalIsolateView extends StatefulWidget {
  const TerminalIsolateView({
    super.key,
    required this.snapshot,
    required this.onKey,
    required this.onText,
    required this.onResize,
    this.onShortcut,
    this.focusRequests,
    this.onPaste,
    this.onScrollRows,
    this.onBeginSelection,
    this.onMouse,
    this.onClipboardVisibility,
    this.onProjectionVisibility,
    this.onEndSelection,
    this.onCopySelection,
    required this.textStyle,
    required this.cursorType,
  });

  final ValueListenable<TerminalIsolateSnapshot?> snapshot;
  final TerminalIsolateKey onKey;
  final ValueChanged<String> onText;
  final void Function(int columns, int rows) onResize;
  final FocusOnKeyEventCallback? onShortcut;
  final Listenable? focusRequests;
  final ValueChanged<String>? onPaste;
  final ValueChanged<int>? onScrollRows;
  final TerminalIsolateMouse? onMouse;

  /// Reports focused foreground visibility, not clipboard authority.
  final ValueChanged<bool>? onClipboardVisibility;

  /// Projection follows attached, visible routes regardless of focus.
  final ValueChanged<bool>? onProjectionVisibility;
  final Future<int?> Function(TerminalIsolatePoint)? onBeginSelection;
  final Future<void> Function(int, TerminalIsolatePoint)? onEndSelection;
  final Future<String?> Function(int, TerminalIsolatePoint)? onCopySelection;
  final TerminalStyle textStyle;
  final TerminalCursorType cursorType;

  @override
  State<TerminalIsolateView> createState() => _TerminalIsolateViewState();
}

class _TerminalIsolateViewState extends State<TerminalIsolateView>
    with WidgetsBindingObserver {
  final _focus = FocusNode();
  final _editor = GlobalKey<CustomTextEditState>();
  final _viewport = GlobalKey();
  (int, int)? _requestedSize;
  TerminalPainter? _painter;
  String? _composing;
  bool _geometryScheduled = false;
  int _selectionGeneration = 0;
  bool _dragging = false;
  bool _pinEndWhenReady = false;
  int? _selectionId;
  int? _originalAnchorRow;
  int? _anchorViewId;
  bool? _selectionAlternate;
  int? _endpointRevision;
  int? _anchorColumn;
  int? _endpointRow;
  TerminalIsolatePoint? _endpoint;
  double _scrollRemainder = 0;
  final _remotePointers = <int, (TerminalMouseButton, int)>{};
  int? _localPointer;
  Offset? _localDown;
  int _mouseSequence = 0;
  bool _viewActive = true;
  bool _routeVisible = false;

  bool get _desktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focus.addListener(_onFocusChanged);
    widget.focusRequests?.addListener(_requestFocus);
  }

  @override
  void didUpdateWidget(TerminalIsolateView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot != widget.snapshot) {
      _releaseMouse(oldWidget.onMouse);
      _localPointer = null;
      _clearSelection();
    }
    if (oldWidget.focusRequests != widget.focusRequests) {
      oldWidget.focusRequests?.removeListener(_requestFocus);
      widget.focusRequests?.addListener(_requestFocus);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeVisible =
        (ModalRoute.isCurrentOf(context) ?? true) && TickerMode.of(context);
    _reportProjectionVisibility();
    _reportClipboardVisibility();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _reportClipboardVisibility(state);
  }

  void _reportClipboardVisibility([AppLifecycleState? state]) {
    widget.onClipboardVisibility?.call(
      _viewActive &&
          _routeVisible &&
          _focus.hasFocus &&
          (state ?? WidgetsBinding.instance.lifecycleState) ==
              AppLifecycleState.resumed,
    );
  }

  void _reportProjectionVisibility() {
    widget.onProjectionVisibility?.call(_viewActive && _routeVisible);
  }

  @override
  void activate() {
    super.activate();
    _viewActive = true;
    _reportProjectionVisibility();
    _reportClipboardVisibility();
  }

  void _requestFocus() {
    if (mounted) _focus.requestFocus();
  }

  void _onFocusChanged() {
    _reportClipboardVisibility();
    setState(() {
      if (!_focus.hasFocus) {
        _composing = null;
        _releaseMouse(widget.onMouse);
        _localPointer = null;
        _clearSelection();
      }
    });
  }

  @override
  void deactivate() {
    _viewActive = false;
    _reportProjectionVisibility();
    _reportClipboardVisibility();
    _releaseMouse(widget.onMouse);
    _localPointer = null;
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewActive = false;
    _reportProjectionVisibility();
    _reportClipboardVisibility();
    widget.focusRequests?.removeListener(_requestFocus);
    _clearSelection();
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    super.dispose();
  }

  void _scheduleGeometry(BoxConstraints constraints, Size size) {
    if (!constraints.hasBoundedWidth ||
        !constraints.hasBoundedHeight ||
        _geometryScheduled) {
      return;
    }
    final dimensions = (
      (constraints.maxWidth / size.width).floor().clamp(2, 512),
      (constraints.maxHeight / size.height).floor().clamp(1, 256),
    );
    _geometryScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geometryScheduled = false;
      if (!mounted) return;
      if (_requestedSize != dimensions) {
        if (_requestedSize != null && _anchorColumn != null) {
          setState(_clearSelection);
        }
        _requestedSize = dimensions;
        widget.onResize(dimensions.$1, dimensions.$2);
      }
      final viewport = _viewport.currentContext?.findRenderObject();
      final current = widget.snapshot.value;
      if (!_focus.hasFocus ||
          viewport is! RenderBox ||
          current == null ||
          !current.cursorVisible) {
        return;
      }
      final origin = viewport.localToGlobal(Offset.zero);
      final caret = origin.translate(
        current.cursorColumn * size.width,
        current.cursorRow * size.height,
      );
      _editor.currentState?.setEditableRect(
        origin & viewport.size,
        caret & size,
      );
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_focus.hasFocus || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    const modifiers = [
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.altRight,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.metaRight,
      LogicalKeyboardKey.capsLock,
      LogicalKeyboardKey.numLock,
      LogicalKeyboardKey.scrollLock,
    ];
    if (modifiers.contains(event.logicalKey)) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    final ctrl = keyboard.isControlPressed;
    final alt = keyboard.isAltPressed;
    final shift = keyboard.isShiftPressed;
    final mac = defaultTargetPlatform == TargetPlatform.macOS;
    final localClipboard = mac ? keyboard.isMetaPressed : ctrl && shift;
    if (localClipboard &&
        event.logicalKey == LogicalKeyboardKey.keyC &&
        _selectionId != null &&
        _endpoint != null) {
      unawaited(_copySelection());
      return KeyEventResult.handled;
    }
    if (localClipboard &&
        event.logicalKey == LogicalKeyboardKey.keyV &&
        widget.onPaste != null) {
      unawaited(_pasteClipboard());
      return KeyEventResult.handled;
    }
    if (keyboard.isMetaPressed) return KeyEventResult.ignored;
    final key = keyToTerminalKey(event.logicalKey);
    if (key == null) return KeyEventResult.ignored;
    final chars = event.character;
    // Let TextInput handle printable/IME composition without double delivery.
    if (!ctrl &&
        !alt &&
        chars != null &&
        chars.isNotEmpty &&
        chars.codeUnitAt(0) >= 0x20 &&
        chars.codeUnitAt(0) != 0x7f) {
      return KeyEventResult.ignored;
    }
    return widget.onKey(key, ctrl: ctrl, alt: alt, shift: shift)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  void _clearSelection() {
    _selectionGeneration++;
    _dragging = false;
    _pinEndWhenReady = false;
    _selectionId = null;
    _originalAnchorRow = null;
    _anchorViewId = null;
    _selectionAlternate = null;
    _endpointRevision = null;
    _anchorColumn = null;
    _endpointRow = null;
    _endpoint = null;
  }

  TerminalIsolatePoint? _hit(
      TerminalIsolateSnapshot? frame, Size metrics, Offset position) {
    if (frame == null || metrics.isEmpty) return null;
    final row = (position.dy / metrics.height).floor().clamp(0, frame.rows - 1);
    final column =
        (position.dx / metrics.width).round().clamp(0, frame.columns);
    return TerminalIsolatePoint(frame.viewId, row, frame.lines[row].id, column);
  }

  Future<void> _beginSelection(
      TerminalIsolateSnapshot? frame, Size metrics, Offset position) async {
    final begin = widget.onBeginSelection;
    final point = _hit(frame, metrics, position);
    if (begin == null || point == null || frame == null) return;
    _focus.requestFocus();
    _dragging = true;
    _pinEndWhenReady = false;
    final generation = ++_selectionGeneration;
    setState(() {
      _selectionId = null;
      _originalAnchorRow = frame.firstRow + point.row;
      _anchorViewId = frame.viewId;
      _selectionAlternate = frame.alternateScreen;
      _endpointRevision = frame.revision;
      _anchorColumn = point.column;
      _endpoint = point;
      _endpointRow = _originalAnchorRow;
    });
    final id = await begin(point);
    if (!mounted || generation != _selectionGeneration || !_focus.hasFocus) {
      return;
    }
    setState(() {
      if (id == null) {
        _clearSelection();
      } else {
        _selectionId = id;
      }
    });
    if (_pinEndWhenReady && id != null) _finishSelection();
  }

  void _extendSelection(
      TerminalIsolateSnapshot? frame, Size metrics, Offset position) {
    final hit = _hit(frame, metrics, position);
    if (_anchorColumn == null || frame == null || hit == null) return;
    setState(() {
      _endpoint = hit;
      _endpointRevision = frame.revision;
      _endpointRow = frame.firstRow + hit.row;
    });
  }

  void _finishSelection() {
    _dragging = false;
    _pinEndWhenReady = true;
    final id = _selectionId;
    final endpoint = _endpoint;
    if (id != null && endpoint != null) {
      unawaited(widget.onEndSelection?.call(id, endpoint));
    }
  }

  Future<void> _copySelection() async {
    final copy = widget.onCopySelection;
    final id = _selectionId;
    final end = _endpoint;
    if (copy == null || id == null || end == null) return;
    final generation = _selectionGeneration;
    try {
      final text = await copy(id, end);
      if (!mounted ||
          !_focus.hasFocus ||
          generation != _selectionGeneration ||
          widget.snapshot.value?.alternateScreen != _selectionAlternate ||
          !identical(_endpoint, end)) {
        return;
      }
      if (text == null) {
        setState(_clearSelection);
      } else if (text.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: text));
      }
    } catch (_) {
      // A detached or stale selection never changes clipboard contents.
    }
  }

  TerminalIsolatePoint? _mouseHit(
      TerminalIsolateSnapshot frame, Size metrics, Offset position) {
    if (metrics.isEmpty || _requestedSize != (frame.columns, frame.rows)) {
      return null;
    }
    final row = (position.dy / metrics.height).floor();
    final column = (position.dx / metrics.width).floor();
    if (row < 0 ||
        row >= frame.lines.length ||
        column < 0 ||
        column >= frame.columns) {
      return null;
    }
    return TerminalIsolatePoint(frame.viewId, row, frame.lines[row].id, column);
  }

  void _mouseDown(
      PointerDownEvent event, TerminalIsolateSnapshot? frame, Size metrics) {
    if (!_desktop || event.kind != PointerDeviceKind.mouse) return;
    final button = switch (event.buttons) {
      kPrimaryMouseButton => TerminalMouseButton.left,
      kMiddleMouseButton => TerminalMouseButton.middle,
      kSecondaryMouseButton => TerminalMouseButton.right,
      _ => null,
    };
    if (button == null) return;
    if (frame != null &&
        frame.mouseButtons &&
        !HardwareKeyboard.instance.isAltPressed &&
        widget.onMouse != null) {
      final hit = _mouseHit(frame, metrics, event.localPosition);
      if (hit == null ||
          _remotePointers.length >= 3 ||
          _remotePointers.values.any((route) => route.$1 == button)) {
        return;
      }
      final gesture = ++_mouseSequence;
      _remotePointers[event.pointer] = (button, gesture);
      widget.onMouse!(button, gesture, hit);
      _editor.currentState?.requestKeyboard();
    } else if (button == TerminalMouseButton.left && _localPointer == null) {
      _localPointer = event.pointer;
      _localDown = event.localPosition;
    }
  }

  void _mouseMove(
      PointerMoveEvent event, TerminalIsolateSnapshot? frame, Size metrics) {
    if (_localPointer != event.pointer) return;
    final origin = _localDown!;
    if (!_dragging && (event.localPosition - origin).distance >= kTouchSlop) {
      unawaited(_beginSelection(frame, metrics, origin));
    }
    if (_dragging) _extendSelection(frame, metrics, event.localPosition);
  }

  void _mouseEnd(
      PointerEvent event, TerminalIsolateSnapshot? frame, Size metrics) {
    final route = _remotePointers.remove(event.pointer);
    if (route != null) {
      widget.onMouse?.call(route.$1, route.$2, null);
      return;
    }
    if (_localPointer != event.pointer) return;
    _localPointer = null;
    if (event is PointerCancelEvent) {
      if (_dragging) setState(_clearSelection);
    } else if (_dragging) {
      _finishSelection();
    } else {
      _localTap(frame, metrics, event.localPosition);
    }
  }

  void _releaseMouse(TerminalIsolateMouse? send) {
    for (final route in _remotePointers.values) {
      send?.call(route.$1, route.$2, null);
    }
    _remotePointers.clear();
  }

  void _localTap(
      TerminalIsolateSnapshot? snapshot, Size metrics, Offset position) {
    if (HardwareKeyboard.instance.isShiftPressed && _anchorColumn != null) {
      _extendSelection(snapshot, metrics, position);
      _finishSelection();
    } else {
      if (_anchorColumn != null) setState(_clearSelection);
      _editor.currentState?.requestKeyboard();
    }
  }

  void _onScroll(
      PointerSignalEvent event, Size metrics, TerminalIsolateSnapshot? frame) {
    final sendRows = widget.onScrollRows;
    if (sendRows == null || event is! PointerScrollEvent || metrics.isEmpty) {
      return;
    }
    if (_desktop &&
        frame != null &&
        frame.mouseWheel &&
        event.kind == PointerDeviceKind.mouse &&
        event.scrollDelta.dy != 0 &&
        !HardwareKeyboard.instance.isAltPressed &&
        widget.onMouse != null) {
      final hit = _mouseHit(frame, metrics, event.localPosition);
      if (hit != null) {
        widget.onMouse!(
          event.scrollDelta.dy < 0
              ? TerminalMouseButton.wheelUp
              : TerminalMouseButton.wheelDown,
          ++_mouseSequence,
          hit,
        );
      }
      return;
    }
    _scrollRemainder += event.scrollDelta.dy;
    final rows = (_scrollRemainder / metrics.height).truncate();
    if (rows != 0) {
      _scrollRemainder -= rows * metrics.height;
      sendRows(rows);
    }
  }

  (int, int, int, int)? _highlight(TerminalIsolateSnapshot? frame) {
    final end = _endpoint;
    final anchorColumn = _anchorColumn;
    if (frame == null ||
        anchorColumn == null ||
        end == null ||
        frame.alternateScreen != _selectionAlternate) {
      return null;
    }
    final anchor = _selectionId != null && frame.selectionId == _selectionId
        ? frame.selectionAnchorRow
        : frame.viewId == _anchorViewId
            ? _originalAnchorRow
            : null;
    if (anchor == null) return null;
    final int? endpointRow;
    if (frame.revision == _endpointRevision) {
      endpointRow = _endpointRow;
    } else {
      final index = frame.lines.indexWhere((line) => line.id == end.lineId);
      endpointRow = index < 0 ? null : frame.firstRow + index;
    }
    if (endpointRow == null) return null;
    return (anchor, anchorColumn, endpointRow, end.column);
  }

  Future<void> _pasteClipboard() async {
    final paste = widget.onPaste;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (mounted && _focus.hasFocus) {
        final text = data?.text;
        if (text != null) paste?.call(text);
      }
    } catch (_) {
      // Clipboard access is best effort.
    }
  }

  void _sendKey(TerminalKey key) {
    if (mounted && _focus.hasFocus) {
      widget.onKey(key, ctrl: false, alt: false, shift: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = TerminalIsolateProbes.start();
    try {
      return _buildView(context);
    } finally {
      TerminalIsolateProbes.finish('isolate.widget_build', start);
    }
  }

  Widget _buildView(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context);
    final painter = _painter ??= TerminalPainter(
      theme: TerminalThemes.defaultTheme,
      textStyle: widget.textStyle,
      textScaler: scale,
      normalizedParagraphKeys:
          TerminalIsolateProbes.normalizedParagraphKeysForBenchmark ?? true,
    );
    painter.textStyle = widget.textStyle;
    painter.textScaler = scale;
    return CustomTextEdit(
      key: _editor,
      focusNode: _focus,
      autofocus: true,
      onKeyEventOverride: widget.onShortcut,
      onKeyEvent: _onKey,
      onInsert: (text) {
        if (mounted && _focus.hasFocus && text.isNotEmpty) widget.onText(text);
      },
      onDelete: () => _sendKey(TerminalKey.backspace),
      onAction: (action) {
        if (action == TextInputAction.newline ||
            action == TextInputAction.done) {
          _sendKey(TerminalKey.enter);
        }
      },
      onComposing: (text) {
        if (mounted && _focus.hasFocus && text != _composing) {
          setState(() => _composing = text);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) => ValueListenableBuilder(
          valueListenable: widget.snapshot,
          builder: (context, snapshot, _) {
            final start = TerminalIsolateProbes.start();
            try {
              final metrics = painter.cellSize;
              _scheduleGeometry(constraints, metrics);
              return Listener(
                onPointerSignal: (event) => _onScroll(event, metrics, snapshot),
                onPointerDown: (event) => _mouseDown(event, snapshot, metrics),
                onPointerMove: (event) => _mouseMove(event, snapshot, metrics),
                onPointerUp: (event) => _mouseEnd(event, snapshot, metrics),
                onPointerCancel: (event) => _mouseEnd(event, snapshot, metrics),
                child: GestureDetector(
                  supportedDevices: _desktop
                      ? PointerDeviceKind.values
                          .where((kind) => kind != PointerDeviceKind.mouse)
                          .toSet()
                      : null,
                  dragStartBehavior: DragStartBehavior.down,
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (event) =>
                      _localTap(snapshot, metrics, event.localPosition),
                  onPanStart: (event) => unawaited(
                    _beginSelection(snapshot, metrics, event.localPosition),
                  ),
                  onPanUpdate: (event) =>
                      _extendSelection(snapshot, metrics, event.localPosition),
                  onPanEnd: (_) => _finishSelection(),
                  onPanCancel: () {
                    if (_dragging) setState(_clearSelection);
                  },
                  child: SizedBox.expand(
                    key: _viewport,
                    child: ClipRect(
                      child: CustomPaint(
                        painter: _SnapshotPainter(
                          painter,
                          snapshot,
                          widget.cursorType,
                          _composing,
                          _focus.hasFocus,
                          metrics,
                          _highlight(snapshot),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } finally {
              TerminalIsolateProbes.finish(
                  'isolate.snapshot_widget_build', start);
            }
          },
        ),
      ),
    );
  }
}

final class _SnapshotPainter extends CustomPainter {
  _SnapshotPainter(this.terminal, this.snapshot, this.cursorType,
      this.composing, this.focused, this.cellSize, this.highlight);

  final TerminalPainter terminal;
  final TerminalIsolateSnapshot? snapshot;
  final TerminalCursorType cursorType;
  final String? composing;
  final bool focused;
  final Size cellSize;
  final (int, int, int, int)? highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final start = TerminalIsolateProbes.start();
    final counters = TerminalIsolateProbes.beginGlyphFrame();
    try {
      _paintSnapshot(canvas, size);
    } finally {
      TerminalIsolateProbes.endGlyphFrame(counters);
      TerminalIsolateProbes.finish('isolate.snapshot_paint_recording', start);
    }
  }

  void _paintSnapshot(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = terminal.theme.background);
    final frame = snapshot;
    if (frame == null) return;
    final counters = TerminalIsolateProbes.activeGlyphFrame;
    if (counters != null) counters.rows += frame.lines.length;
    final cell = CellData.empty();
    final spacing = terminal.cellSize;
    final (startRow, startColumn, endRow, endColumn) = switch (highlight) {
      (final startRow, final startColumn, final endRow, final endColumn)
          when startRow < endRow ||
              startRow == endRow && startColumn <= endColumn =>
        (startRow, startColumn, endRow, endColumn),
      (final startRow, final startColumn, final endRow, final endColumn) => (
          endRow,
          endColumn,
          startRow,
          startColumn
        ),
      null => (-1, 0, -1, 0),
    };
    for (var row = 0; row < frame.lines.length; row++) {
      final cells = frame.lines[row].cells;
      for (var column = 0; column < frame.columns; column++) {
        final i = column * 4;
        cell
          ..foreground = cells[i]
          ..background = cells[i + 1]
          ..flags = cells[i + 2]
          ..content = cells[i + 3];
        final offset = Offset(column * spacing.width, row * spacing.height);
        final width = cell.content >> CellContent.widthShift == 2 ? 2 : 1;
        final absoluteRow = frame.firstRow + row;
        final selected = absoluteRow >= startRow &&
            absoluteRow <= endRow &&
            (absoluteRow != startRow || column + width > startColumn) &&
            (absoluteRow != endRow || column < endColumn);
        terminal.paintCellBackground(canvas, offset, cell);
        if (selected) {
          terminal.paintHighlight(
              canvas, offset, width, terminal.theme.selection);
        }
        terminal.paintCellForeground(canvas, offset, cell);
        if (cell.content >> CellContent.widthShift == 2) column++;
      }
    }
    final offset = Offset(
      frame.cursorColumn * spacing.width,
      frame.cursorRow * spacing.height,
    );
    if (frame.cursorVisible) {
      terminal.paintCursor(canvas, offset,
          cursorType: cursorType, hasFocus: focused);
    }
    if (composing case final text? when frame.cursorVisible) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: terminal.textStyle.toTextStyle().copyWith(
                color: terminal.theme.foreground,
                backgroundColor: terminal.theme.background,
                decoration: TextDecoration.underline,
              ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(
          maxWidth: (size.width - offset.dx).clamp(0.0, size.width).toDouble());
      painter.paint(canvas, offset);
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(_SnapshotPainter oldDelegate) =>
      snapshot != oldDelegate.snapshot ||
      cursorType != oldDelegate.cursorType ||
      composing != oldDelegate.composing ||
      focused != oldDelegate.focused ||
      cellSize != oldDelegate.cellSize ||
      highlight != oldDelegate.highlight;
}
