import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:xterm/src/core/buffer/cell_offset.dart';
import 'package:xterm/src/core/mouse/button.dart';
import 'package:xterm/src/core/mouse/button_state.dart';
import 'package:xterm/src/core/mouse/mode.dart';
import 'package:xterm/src/terminal_view.dart';
import 'package:xterm/src/ui/controller.dart';
import 'package:xterm/src/ui/gesture/gesture_detector.dart';
import 'package:xterm/src/ui/pointer_input.dart';
import 'package:xterm/src/ui/render.dart';

enum _SelectionUnit { character, word, line }

class TerminalGestureHandler extends StatefulWidget {
  const TerminalGestureHandler({
    super.key,
    required this.terminalView,
    required this.terminalController,
    this.child,
    this.onTapUp,
    this.onSingleTapUp,
    this.onTapDown,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.readOnly = false,
  });

  final TerminalViewState terminalView;

  final TerminalController terminalController;

  final Widget? child;

  final GestureTapUpCallback? onTapUp;

  final GestureTapUpCallback? onSingleTapUp;

  final GestureTapDownCallback? onTapDown;

  final GestureTapDownCallback? onSecondaryTapDown;

  final GestureTapUpCallback? onSecondaryTapUp;

  final GestureTapDownCallback? onTertiaryTapDown;

  final GestureTapUpCallback? onTertiaryTapUp;

  final bool readOnly;

  @override
  State<TerminalGestureHandler> createState() => _TerminalGestureHandlerState();
}

class _TerminalGestureHandlerState extends State<TerminalGestureHandler> {
  static const _autoScrollInterval = Duration(milliseconds: 50);

  TerminalViewState get terminalView => widget.terminalView;

  RenderTerminal get renderTerminal => terminalView.renderTerminal;

  LongPressStartDetails? _lastLongPressStartDetails;

  _SelectionUnit _selectionUnit = _SelectionUnit.character;

  Offset? _dragStartContentOffset;

  Offset? _lastDragLocalPosition;

  Timer? _autoScrollTimer;

  bool _leftButtonReported = false;

  bool _reportingDrag = false;

  CellOffset? _lastReportedCell;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TerminalGestureDetector(
      child: widget.child,
      onTapUp: widget.onTapUp,
      onSingleTapUp: onSingleTapUp,
      onTapDown: onTapDown,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp,
      onTertiaryTapDown: onTertiaryTapDown,
      onTertiaryTapUp: onTertiaryTapUp,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      onDoubleTapDown: onDoubleTapDown,
      onTripleTapDown: onTripleTapDown,
    );
  }

  /// Holding Option (Alt) forces local selection even when the running
  /// program has enabled mouse reporting, like iTerm2.
  bool get _forceLocalSelection => HardwareKeyboard.instance.isAltPressed;

  bool get _shouldSendTapEvent =>
      !widget.readOnly &&
      !_forceLocalSelection &&
      widget.terminalController.shouldSendPointerInput(PointerInput.tap);

  bool get _shouldReportDrag =>
      !widget.readOnly &&
      !_forceLocalSelection &&
      terminalView.widget.terminal.mouseMode != MouseMode.none &&
      widget.terminalController.shouldSendPointerInput(PointerInput.drag);

  void _tapDown(
    GestureTapDownCallback? callback,
    TapDownDetails details,
    TerminalMouseButton button, {
    bool forceCallback = false,
  }) {
    var handled = false;
    if (_shouldSendTapEvent) {
      handled = renderTerminal.mouseEvent(
        button,
        TerminalMouseButtonState.down,
        details.localPosition,
      );
      if (handled && button == TerminalMouseButton.left) {
        _leftButtonReported = true;
      }
    }
    if (!handled || forceCallback) {
      callback?.call(details);
    }
  }

  void _tapUp(
    GestureTapUpCallback? callback,
    TapUpDetails details,
    TerminalMouseButton button, {
    bool forceCallback = false,
  }) {
    var handled = false;
    if (_shouldSendTapEvent) {
      handled = renderTerminal.mouseEvent(
        button,
        TerminalMouseButtonState.up,
        details.localPosition,
      );
    }
    if (button == TerminalMouseButton.left) {
      _leftButtonReported = false;
    }
    if (!handled || forceCallback) {
      callback?.call(details);
    }
  }

  void onTapDown(TapDownDetails details) {
    _selectionUnit = _SelectionUnit.character;

    if (_isExpandingSelection) {
      widget.onTapDown?.call(details);
      return;
    }

    // onTapDown is special, as it will always call the supplied callback.
    // The TerminalView depends on it to bring the terminal into focus.
    _tapDown(
      widget.onTapDown,
      details,
      TerminalMouseButton.left,
      forceCallback: true,
    );
  }

  void onSingleTapUp(TapUpDetails details) {
    if (_isExpandingSelection &&
        renderTerminal.extendSelection(details.localPosition)) {
      return;
    }

    _tapUp(widget.onSingleTapUp, details, TerminalMouseButton.left);
  }

  void onSecondaryTapDown(TapDownDetails details) {
    _tapDown(widget.onSecondaryTapDown, details, TerminalMouseButton.right);
  }

  void onSecondaryTapUp(TapUpDetails details) {
    _tapUp(widget.onSecondaryTapUp, details, TerminalMouseButton.right);
  }

  void onTertiaryTapDown(TapDownDetails details) {
    _tapDown(widget.onTertiaryTapDown, details, TerminalMouseButton.middle);
  }

  void onTertiaryTapUp(TapUpDetails details) {
    _tapUp(widget.onTertiaryTapUp, details, TerminalMouseButton.middle);
  }

  void onDoubleTapDown(TapDownDetails details) {
    if (_leftButtonReported) {
      return;
    }
    _selectionUnit = _SelectionUnit.word;
    renderTerminal.selectWord(details.localPosition);
  }

  void onTripleTapDown(TapDownDetails details) {
    if (_leftButtonReported) {
      return;
    }
    _selectionUnit = _SelectionUnit.line;
    renderTerminal.selectLine(details.localPosition);
  }

  void onLongPressStart(LongPressStartDetails details) {
    _lastLongPressStartDetails = details;
    renderTerminal.selectWord(details.localPosition);
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    renderTerminal.selectWord(
      _lastLongPressStartDetails!.localPosition,
      details.localPosition,
    );
  }

  void onDragStart(DragStartDetails details) {
    _lastDragLocalPosition = details.localPosition;
    _dragStartContentOffset =
        details.localPosition + Offset(0, renderTerminal.scrollOffset);

    if (_shouldReportDrag) {
      _reportingDrag = true;
      if (!_leftButtonReported) {
        _leftButtonReported = renderTerminal.mouseEvent(
          TerminalMouseButton.left,
          TerminalMouseButtonState.down,
          details.localPosition,
        );
      }
      _lastReportedCell = renderTerminal.getCellOffset(details.localPosition);
      return;
    }

    if (_isExpandingSelection) {
      renderTerminal.extendSelection(details.localPosition);
      return;
    }

    if (details.kind != PointerDeviceKind.mouse) {
      renderTerminal.selectWord(details.localPosition);
      return;
    }

    _applyDragSelection(details.localPosition, isStart: true);
  }

  void onDragUpdate(DragUpdateDetails details) {
    _lastDragLocalPosition = details.localPosition;

    if (_reportingDrag) {
      final cell = renderTerminal.getCellOffset(details.localPosition);
      if (cell != _lastReportedCell) {
        _lastReportedCell = cell;
        renderTerminal.mouseEvent(
          TerminalMouseButton.left,
          TerminalMouseButtonState.motion,
          details.localPosition,
        );
      }
      return;
    }

    if (_isExpandingSelection) {
      renderTerminal.extendSelection(details.localPosition);
      return;
    }

    _applyDragSelection(details.localPosition);
    _updateAutoScroll(details.localPosition);
  }

  void onDragEnd(DragEndDetails details) {
    _stopAutoScroll();

    if (_reportingDrag) {
      final position = _lastDragLocalPosition;
      if (position != null) {
        renderTerminal.mouseEvent(
          TerminalMouseButton.left,
          TerminalMouseButtonState.up,
          position,
        );
      }
    }
    _reportingDrag = false;
    _leftButtonReported = false;
    _lastReportedCell = null;
  }

  void _applyDragSelection(Offset localPosition, {bool isStart = false}) {
    final startContent = _dragStartContentOffset;
    if (startContent == null) {
      return;
    }
    final start = startContent - Offset(0, renderTerminal.scrollOffset);
    final end = isStart ? null : localPosition;

    switch (_selectionUnit) {
      case _SelectionUnit.character:
        renderTerminal.selectCharacters(start, end);
      case _SelectionUnit.word:
        renderTerminal.selectWord(start, end);
      case _SelectionUnit.line:
        renderTerminal.selectLine(start, end);
    }
  }

  double _autoScrollDelta(Offset localPosition) {
    final height = renderTerminal.size.height;
    final lineHeight = renderTerminal.lineHeight;
    final double distance;
    if (localPosition.dy < 0) {
      distance = localPosition.dy;
    } else if (localPosition.dy > height) {
      distance = localPosition.dy - height;
    } else {
      return 0;
    }
    final lines = (distance.abs() / lineHeight).ceil().clamp(1, 10);
    return distance.sign * lines * lineHeight;
  }

  void _updateAutoScroll(Offset localPosition) {
    if (_autoScrollDelta(localPosition) == 0) {
      _stopAutoScroll();
      return;
    }
    _autoScrollTimer ??= Timer.periodic(_autoScrollInterval, (_) {
      final position = _lastDragLocalPosition;
      if (!mounted || position == null) {
        _stopAutoScroll();
        return;
      }
      final delta = _autoScrollDelta(position);
      if (delta == 0) {
        _stopAutoScroll();
        return;
      }
      renderTerminal.scrollBy(delta);
      _applyDragSelection(position);
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  bool get _isExpandingSelection {
    return HardwareKeyboard.instance.isShiftPressed &&
        widget.terminalController.selection != null;
  }
}
