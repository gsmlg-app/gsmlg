import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_vnc/app_vnc.dart';
import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'keysym_mapper.dart';

/// How the remote VNC framebuffer is scaled inside the viewport.
enum VncScaleMode { fit, actualSize }

/// How touch gestures are translated into remote pointer events.
enum VncTouchMode { direct, trackpad }

/// Pure coordinate transformation helpers for mapping viewport coordinates
/// onto the remote VNC framebuffer.
abstract final class VncCoordinateMapper {
  /// Computes the rectangle inside the canvas content area where the
  /// framebuffer image is drawn for [scaleMode].
  static Rect computeFittedRect({
    required Size viewportSize,
    required int framebufferWidth,
    required int framebufferHeight,
    required VncScaleMode scaleMode,
  }) {
    if (framebufferWidth <= 0 ||
        framebufferHeight <= 0 ||
        viewportSize.width <= 0 ||
        viewportSize.height <= 0) {
      return Rect.zero;
    }

    switch (scaleMode) {
      case VncScaleMode.actualSize:
        return Rect.fromLTWH(
          0,
          0,
          framebufferWidth.toDouble(),
          framebufferHeight.toDouble(),
        );
      case VncScaleMode.fit:
        final scale = math.min(
          viewportSize.width / framebufferWidth,
          viewportSize.height / framebufferHeight,
        );
        final fittedWidth = framebufferWidth * scale;
        final fittedHeight = framebufferHeight * scale;
        final left = (viewportSize.width - fittedWidth) / 2.0;
        final top = (viewportSize.height - fittedHeight) / 2.0;
        return Rect.fromLTWH(left, top, fittedWidth, fittedHeight);
    }
  }

  /// Resolves the active source rectangle inside the remote framebuffer.
  ///
  /// Returns [Rect.zero] if framebuffer dimensions are non-positive. When
  /// [activeRegion] is `null` or invalid/out-of-bounds, falls back to the full
  /// framebuffer rectangle.
  static Rect resolveSourceRect({
    required int framebufferWidth,
    required int framebufferHeight,
    VncScreenInfo? activeRegion,
  }) {
    if (framebufferWidth <= 0 || framebufferHeight <= 0) {
      return Rect.zero;
    }
    final fullRect = Rect.fromLTWH(
      0,
      0,
      framebufferWidth.toDouble(),
      framebufferHeight.toDouble(),
    );
    if (activeRegion == null ||
        activeRegion.width <= 0 ||
        activeRegion.height <= 0 ||
        activeRegion.x >= framebufferWidth ||
        activeRegion.y >= framebufferHeight) {
      return fullRect;
    }
    final x = activeRegion.x.clamp(0, framebufferWidth - 1);
    final y = activeRegion.y.clamp(0, framebufferHeight - 1);
    final right = (activeRegion.x + activeRegion.width).clamp(
      x + 1,
      framebufferWidth,
    );
    final bottom = (activeRegion.y + activeRegion.height).clamp(
      y + 1,
      framebufferHeight,
    );
    return Rect.fromLTRB(
      x.toDouble(),
      y.toDouble(),
      right.toDouble(),
      bottom.toDouble(),
    );
  }

  /// Maps a point in viewport coordinates through the inverse of
  /// [transformMatrix] and [contentRect] into clamped remote framebuffer
  /// coordinates within [sourceRect] (or `[0, framebufferWidth - 1] ×
  /// [0, framebufferHeight - 1]` when [sourceRect] is omitted).
  ///
  /// Returns `null` if framebuffer dimensions or [contentRect] are non-positive
  /// or if [transformMatrix] is singular.
  static Offset? viewportToRemote({
    required Offset viewportPoint,
    required Matrix4 transformMatrix,
    required Rect contentRect,
    required int framebufferWidth,
    required int framebufferHeight,
    Rect? sourceRect,
  }) {
    if (framebufferWidth <= 0 ||
        framebufferHeight <= 0 ||
        contentRect.width <= 0 ||
        contentRect.height <= 0) {
      return null;
    }

    final effectiveSource =
        sourceRect ??
        Rect.fromLTWH(
          0,
          0,
          framebufferWidth.toDouble(),
          framebufferHeight.toDouble(),
        );
    if (effectiveSource.width <= 0 || effectiveSource.height <= 0) {
      return null;
    }

    final inverse = Matrix4.tryInvert(transformMatrix);
    if (inverse == null) return null;

    final contentPoint = MatrixUtils.transformPoint(inverse, viewportPoint);
    final rawX =
        effectiveSource.left +
        (contentPoint.dx - contentRect.left) *
            effectiveSource.width /
            contentRect.width;
    final rawY =
        effectiveSource.top +
        (contentPoint.dy - contentRect.top) *
            effectiveSource.height /
            contentRect.height;

    final maxX = math.max(effectiveSource.left, effectiveSource.right - 1.0);
    final maxY = math.max(effectiveSource.top, effectiveSource.bottom - 1.0);
    final remoteX = rawX.clamp(effectiveSource.left, maxX);
    final remoteY = rawY.clamp(effectiveSource.top, maxY);
    return Offset(remoteX, remoteY);
  }
}

/// Interactive VNC framebuffer canvas supporting zoom/pan, desktop mouse and
/// keyboard input, and direct/trackpad touch input.
class VncViewerCanvas extends StatefulWidget {
  const VncViewerCanvas({
    super.key,
    required this.frames,
    this.initialFrame,
    required this.framebufferWidth,
    required this.framebufferHeight,
    this.activeRegion,
    this.cursor,
    this.scaleMode = VncScaleMode.fit,
    this.touchMode = VncTouchMode.direct,
    this.viewOnly = false,
    this.focusNode,
    this.onPointerEvent,
    this.onKeyEvent,
  });

  final Stream<VncFrameData> frames;
  final VncFrameData? initialFrame;
  final int framebufferWidth;
  final int framebufferHeight;
  final VncScreenInfo? activeRegion;
  final VncCursorData? cursor;
  final VncScaleMode scaleMode;
  final VncTouchMode touchMode;
  final bool viewOnly;
  final FocusNode? focusNode;
  final void Function(int x, int y, int buttonMask)? onPointerEvent;
  final void Function(int keysym, bool down)? onKeyEvent;

  @override
  State<VncViewerCanvas> createState() => _VncViewerCanvasState();
}

class _VncViewerCanvasState extends State<VncViewerCanvas> {
  static const double _trackpadTapSlop = 8.0;

  late final TransformationController _transformationController;
  FocusNode? _ownedFocusNode;
  StreamSubscription<VncFrameData>? _frameSub;

  ui.Image? _image;
  int _frameStreamGeneration = 0;
  int _latestDecodedFrameId = -1;
  bool _isDecodingFrame = false;
  VncFrameData? _pendingFrame;
  Size? _lastViewportSize;

  ui.Image? _cursorImage;
  int _cursorGeneration = 0;

  bool _disposed = false;

  Rect _contentRect = Rect.zero;
  Matrix4? _scrollGuardMatrix;
  PointerDeviceKind? _lastPointerDownKind;
  Offset? _lastRemotePointer;
  int _lastMouseButtons = 0;
  Offset? _virtualCursor;

  final Map<int, Offset> _trackpadDownPositions = {};
  final Map<int, Offset> _trackpadLastPositions = {};
  int _trackpadMaxPointers = 0;
  bool _trackpadMoved = false;

  final Map<LogicalKeyboardKey, int> _pressedKeysyms = {};

  Rect get _sourceRect => VncCoordinateMapper.resolveSourceRect(
    framebufferWidth: widget.framebufferWidth,
    framebufferHeight: widget.framebufferHeight,
    activeRegion: widget.activeRegion,
  );

  Offset _clampToSourceRect(Offset pos, Rect srcRect) {
    final maxX = math.max(srcRect.left, srcRect.right - 1.0);
    final maxY = math.max(srcRect.top, srcRect.bottom - 1.0);
    return Offset(
      pos.dx.clamp(srcRect.left, maxX),
      pos.dy.clamp(srcRect.top, maxY),
    );
  }

  FocusNode get _effectiveFocusNode {
    if (widget.focusNode != null) return widget.focusNode!;
    return _ownedFocusNode ??= FocusNode(debugLabel: 'VncViewerCanvas');
  }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _subscribeFrames();
    if (widget.initialFrame != null) {
      _decodeFrame(widget.initialFrame!);
    }
    if (widget.cursor != null) {
      _decodeCursor(widget.cursor, notify: false);
    }
  }

  @override
  void didUpdateWidget(covariant VncViewerCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.frames != oldWidget.frames) {
      _frameSub?.cancel();
      _frameStreamGeneration++;
      _latestDecodedFrameId = -1;
      _isDecodingFrame = false;
      _pendingFrame = null;
      _subscribeFrames();
    }

    if (widget.initialFrame != oldWidget.initialFrame &&
        widget.initialFrame != null) {
      _decodeFrame(widget.initialFrame!);
    }

    if (widget.scaleMode != oldWidget.scaleMode) {
      _scrollGuardMatrix = null;
      _transformationController.value = Matrix4.identity();
    }

    final srcRect = _sourceRect;
    final dimensionsChanged =
        widget.framebufferWidth != oldWidget.framebufferWidth ||
        widget.framebufferHeight != oldWidget.framebufferHeight;
    if (widget.activeRegion != oldWidget.activeRegion || dimensionsChanged) {
      _scrollGuardMatrix = null;
      _transformationController.value = Matrix4.identity();
      if (dimensionsChanged &&
          _image != null &&
          (_image!.width != widget.framebufferWidth ||
              _image!.height != widget.framebufferHeight)) {
        final previous = _image;
        _image = null;
        previous?.dispose();
      }
      if (_virtualCursor != null && !srcRect.isEmpty) {
        _virtualCursor = _clampToSourceRect(srcRect.center, srcRect);
      }
    }

    if (widget.cursor != oldWidget.cursor) {
      _decodeCursor(widget.cursor, notify: false);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _releasePressedKeys();
      if (widget.focusNode != null) {
        _ownedFocusNode?.dispose();
        _ownedFocusNode = null;
      }
    }

    if (widget.touchMode != oldWidget.touchMode) {
      _resetTrackpadGesture();
    }

    if (widget.viewOnly && !oldWidget.viewOnly) {
      _releasePressedKeys();
      _releaseDesktopMouseButtons(ignoreViewOnly: true);
      _resetTrackpadGesture();
    }

    if (_virtualCursor != null && !srcRect.isEmpty) {
      _virtualCursor = _clampToSourceRect(_virtualCursor!, srcRect);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _releasePressedKeys();
    _frameSub?.cancel();
    _frameSub = null;
    _image?.dispose();
    _image = null;
    _cursorImage?.dispose();
    _cursorImage = null;
    _transformationController.dispose();
    _ownedFocusNode?.dispose();
    _ownedFocusNode = null;
    super.dispose();
  }

  void _subscribeFrames() {
    _frameSub = widget.frames.listen(
      _decodeFrame,
      onError: (Object _, StackTrace _) {},
    );
  }

  void _decodeFrame(VncFrameData frame) {
    if (_disposed) return;
    if (frame.width <= 0 || frame.height <= 0) return;
    if (frame.rgbaPixels.length < frame.width * frame.height * 4) return;
    if (frame.frameId < _latestDecodedFrameId) return;

    if (_isDecodingFrame) {
      final pending = _pendingFrame;
      if (pending == null || frame.frameId >= pending.frameId) {
        _pendingFrame = frame;
      }
      return;
    }

    _isDecodingFrame = true;
    final generation = _frameStreamGeneration;
    final frameId = frame.frameId;
    ui.decodeImageFromPixels(
      frame.rgbaPixels,
      frame.width,
      frame.height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        if (generation == _frameStreamGeneration) {
          _isDecodingFrame = false;
        }
        if (_disposed ||
            !mounted ||
            generation != _frameStreamGeneration ||
            frameId < _latestDecodedFrameId) {
          image.dispose();
        } else {
          _latestDecodedFrameId = frameId;
          final previous = _image;
          _image = image;
          previous?.dispose();
          setState(() {});
        }
        if (!_disposed && mounted && generation == _frameStreamGeneration) {
          final next = _pendingFrame;
          if (next != null) {
            _pendingFrame = null;
            _decodeFrame(next);
          }
        }
      },
    );
  }

  void _decodeCursor(VncCursorData? cursor, {bool notify = true}) {
    _cursorGeneration++;
    if (cursor == null ||
        cursor.width <= 0 ||
        cursor.height <= 0 ||
        cursor.rgbaPixels.length < cursor.width * cursor.height * 4) {
      if (_cursorImage != null) {
        final previous = _cursorImage;
        _cursorImage = null;
        previous?.dispose();
        if (notify && mounted && !_disposed) {
          setState(() {});
        }
      }
      return;
    }

    final generation = _cursorGeneration;
    ui.decodeImageFromPixels(
      cursor.rgbaPixels,
      cursor.width,
      cursor.height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        if (_disposed || !mounted || generation != _cursorGeneration) {
          image.dispose();
          return;
        }
        final previous = _cursorImage;
        _cursorImage = image;
        previous?.dispose();
        setState(() {});
      },
    );
  }

  bool _isDesktopPointer(PointerDeviceKind kind) {
    return kind == PointerDeviceKind.mouse ||
        kind == PointerDeviceKind.stylus ||
        kind == PointerDeviceKind.invertedStylus ||
        kind == PointerDeviceKind.trackpad;
  }

  int _mapMouseButtons(int flutterButtons) {
    var mask = 0;
    if ((flutterButtons & kPrimaryMouseButton) != 0) mask |= 1;
    if ((flutterButtons & kMiddleMouseButton) != 0) mask |= 2;
    if ((flutterButtons & kSecondaryMouseButton) != 0) mask |= 4;
    return mask;
  }

  Offset? _mapViewportPoint(Offset viewportPoint) {
    return VncCoordinateMapper.viewportToRemote(
      viewportPoint: viewportPoint,
      transformMatrix: _transformationController.value,
      contentRect: _contentRect,
      framebufferWidth: widget.framebufferWidth,
      framebufferHeight: widget.framebufferHeight,
      sourceRect: _sourceRect,
    );
  }

  void _emitPointer(Offset remote, int buttonMask) {
    if (widget.viewOnly || widget.onPointerEvent == null) return;
    widget.onPointerEvent!(remote.dx.round(), remote.dy.round(), buttonMask);
  }

  void _handleDesktopPointer(Offset viewportPoint, int buttonMask) {
    final remote = _mapViewportPoint(viewportPoint);
    if (remote == null) return;
    _lastRemotePointer = remote;
    if (_cursorImage != null && mounted) {
      setState(() {});
    }
    if (!widget.viewOnly) {
      _lastMouseButtons = buttonMask;
      _emitPointer(remote, buttonMask);
    }
  }

  void _releaseDesktopMouseButtons({bool ignoreViewOnly = false}) {
    if (_lastMouseButtons == 0) return;
    _lastMouseButtons = 0;
    final pos = _lastRemotePointer;
    final callback = widget.onPointerEvent;
    if (pos != null &&
        callback != null &&
        (ignoreViewOnly || !widget.viewOnly)) {
      callback(pos.dx.round(), pos.dy.round(), 0);
    }
  }

  void _handlePointerScrollFromChild(PointerScrollEvent event) {
    if (widget.viewOnly || widget.onPointerEvent == null) return;
    final remote = VncCoordinateMapper.viewportToRemote(
      viewportPoint: event.localPosition,
      transformMatrix: Matrix4.identity(),
      contentRect: _contentRect,
      framebufferWidth: widget.framebufferWidth,
      framebufferHeight: widget.framebufferHeight,
      sourceRect: _sourceRect,
    );
    if (remote == null) return;

    final baseButtons = _mapMouseButtons(event.buttons);
    final dy = event.scrollDelta.dy;
    final dx = event.scrollDelta.dx;

    if (dy < 0) {
      _emitPointer(remote, baseButtons | (1 << 3));
      _emitPointer(remote, baseButtons);
    } else if (dy > 0) {
      _emitPointer(remote, baseButtons | (1 << 4));
      _emitPointer(remote, baseButtons);
    }

    if (dx < 0) {
      _emitPointer(remote, baseButtons | (1 << 5));
      _emitPointer(remote, baseButtons);
    } else if (dx > 0) {
      _emitPointer(remote, baseButtons | (1 << 6));
      _emitPointer(remote, baseButtons);
    }
  }

  void _resetTrackpadGesture() {
    _trackpadDownPositions.clear();
    _trackpadLastPositions.clear();
    _trackpadMaxPointers = 0;
    _trackpadMoved = false;
  }

  Offset? _ensureVirtualCursor() {
    final srcRect = _sourceRect;
    if (srcRect.isEmpty) {
      return null;
    }
    return _virtualCursor ??= _clampToSourceRect(srcRect.center, srcRect);
  }

  void _handleTrackpadPointerDown(PointerDownEvent event) {
    if (widget.viewOnly) return;
    _ensureVirtualCursor();
    _trackpadDownPositions[event.pointer] = event.localPosition;
    _trackpadLastPositions[event.pointer] = event.localPosition;
    _trackpadMaxPointers = math.max(
      _trackpadMaxPointers,
      _trackpadDownPositions.length,
    );
    setState(() {});
  }

  void _handleTrackpadPointerMove(PointerMoveEvent event) {
    if (widget.viewOnly) return;
    final previous = _trackpadLastPositions[event.pointer];
    final origin = _trackpadDownPositions[event.pointer];
    if (previous == null || origin == null) return;

    final delta = event.localPosition - previous;
    _trackpadLastPositions[event.pointer] = event.localPosition;

    if (!_trackpadMoved) {
      if ((event.localPosition - origin).distance <= _trackpadTapSlop) {
        return;
      }
      _trackpadMoved = true;
    }

    if (_trackpadDownPositions.length == 1) {
      final current = _ensureVirtualCursor();
      final srcRect = _sourceRect;
      if (current == null || srcRect.isEmpty) return;

      final scaleX = _contentRect.width > 0
          ? srcRect.width / _contentRect.width
          : 1.0;
      final scaleY = _contentRect.height > 0
          ? srcRect.height / _contentRect.height
          : 1.0;

      final next = _clampToSourceRect(
        Offset(current.dx + delta.dx * scaleX, current.dy + delta.dy * scaleY),
        srcRect,
      );
      _virtualCursor = next;
      setState(() {});
      _emitPointer(next, 0);
    }
  }

  void _handleTrackpadPointerUp(PointerUpEvent event) {
    _trackpadDownPositions.remove(event.pointer);
    _trackpadLastPositions.remove(event.pointer);

    if (_trackpadDownPositions.isEmpty) {
      if (!widget.viewOnly && !_trackpadMoved) {
        final cursor = _ensureVirtualCursor();
        if (cursor != null) {
          if (_trackpadMaxPointers == 1) {
            _emitPointer(cursor, 1);
            _emitPointer(cursor, 0);
          } else if (_trackpadMaxPointers >= 2) {
            _emitPointer(cursor, 4);
            _emitPointer(cursor, 0);
          }
        }
      }
      _trackpadMaxPointers = 0;
      _trackpadMoved = false;
    }
  }

  void _handleTrackpadPointerCancel(PointerCancelEvent event) {
    _trackpadDownPositions.remove(event.pointer);
    _trackpadLastPositions.remove(event.pointer);
    if (_trackpadDownPositions.isEmpty) {
      _trackpadMaxPointers = 0;
      _trackpadMoved = false;
    }
  }

  void _handleDirectTapUp(TapUpDetails details) {
    if (widget.viewOnly ||
        widget.touchMode != VncTouchMode.direct ||
        details.kind != PointerDeviceKind.touch) {
      return;
    }
    _effectiveFocusNode.requestFocus();
    final remote = _mapViewportPoint(details.localPosition);
    if (remote == null) return;
    _emitPointer(remote, 1);
    _emitPointer(remote, 0);
  }

  void _handleDirectLongPressStart(LongPressStartDetails details) {
    if (widget.viewOnly ||
        widget.touchMode != VncTouchMode.direct ||
        _lastPointerDownKind != PointerDeviceKind.touch) {
      return;
    }
    _effectiveFocusNode.requestFocus();
    final remote = _mapViewportPoint(details.localPosition);
    if (remote == null) return;
    _emitPointer(remote, 4);
    _emitPointer(remote, 0);
  }

  void _releasePressedKeys() {
    if (_pressedKeysyms.isEmpty) return;
    final callback = widget.onKeyEvent;
    final keysyms = _pressedKeysyms.values.toList();
    _pressedKeysyms.clear();
    if (callback != null) {
      for (final ks in keysyms) {
        callback(ks, false);
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.viewOnly || widget.onKeyEvent == null) {
      return KeyEventResult.ignored;
    }

    final mapped = KeysymMapper.fromKeyEvent(event);
    if (event is KeyDownEvent) {
      if (mapped == null) return KeyEventResult.ignored;
      _pressedKeysyms[event.logicalKey] = mapped;
      widget.onKeyEvent!(mapped, true);
      return KeyEventResult.handled;
    }

    if (event is KeyRepeatEvent) {
      final ks = _pressedKeysyms[event.logicalKey] ?? mapped;
      if (ks == null) return KeyEventResult.ignored;
      widget.onKeyEvent!(ks, true);
      return KeyEventResult.handled;
    }

    if (event is KeyUpEvent) {
      final ks = _pressedKeysyms.remove(event.logicalKey) ?? mapped;
      if (ks == null) return KeyEventResult.ignored;
      widget.onKeyEvent!(ks, false);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sourceRect = _sourceRect;
    final sourceWidth = sourceRect.width.round();
    final sourceHeight = sourceRect.height.round();
    final isActualSize =
        widget.scaleMode == VncScaleMode.actualSize &&
        sourceWidth > 0 &&
        sourceHeight > 0;
    final panEnabled =
        widget.viewOnly || widget.touchMode == VncTouchMode.direct;

    return Focus(
      focusNode: _effectiveFocusNode,
      autofocus: true,
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          _releasePressedKeys();
        }
      },
      onKeyEvent: _handleKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = constraints.biggest;
          final previousViewport = _lastViewportSize;
          if (previousViewport != null &&
              previousViewport != viewportSize &&
              (previousViewport.width > previousViewport.height) !=
                  (viewportSize.width > viewportSize.height)) {
            _scrollGuardMatrix = null;
            _transformationController.value = Matrix4.identity();
          }
          _lastViewportSize = viewportSize;

          _contentRect = VncCoordinateMapper.computeFittedRect(
            viewportSize: viewportSize,
            framebufferWidth: sourceWidth,
            framebufferHeight: sourceHeight,
            scaleMode: widget.scaleMode,
          );

          final fitScale = (sourceWidth > 0 && sourceHeight > 0)
              ? math.min(
                  viewportSize.width / sourceWidth,
                  viewportSize.height / sourceHeight,
                )
              : 1.0;
          final minActualScale = math.min(0.25, math.max(0.05, fitScale));

          final childSize = isActualSize
              ? Size(
                  math.max(viewportSize.width, sourceRect.width),
                  math.max(viewportSize.height, sourceRect.height),
                )
              : viewportSize;

          final activeCursorPosition = widget.touchMode == VncTouchMode.trackpad
              ? _virtualCursor
              : _lastRemotePointer;

          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerHover: (event) {
              if (_isDesktopPointer(event.kind)) {
                _handleDesktopPointer(event.localPosition, 0);
              }
            },
            onPointerDown: (event) {
              _lastPointerDownKind = event.kind;
              _effectiveFocusNode.requestFocus();
              if (_isDesktopPointer(event.kind)) {
                _handleDesktopPointer(
                  event.localPosition,
                  _mapMouseButtons(event.buttons),
                );
              } else if (event.kind == PointerDeviceKind.touch &&
                  widget.touchMode == VncTouchMode.trackpad) {
                _handleTrackpadPointerDown(event);
              }
            },
            onPointerMove: (event) {
              if (_isDesktopPointer(event.kind)) {
                _handleDesktopPointer(
                  event.localPosition,
                  _mapMouseButtons(event.buttons),
                );
              } else if (event.kind == PointerDeviceKind.touch &&
                  widget.touchMode == VncTouchMode.trackpad) {
                _handleTrackpadPointerMove(event);
              }
            },
            onPointerUp: (event) {
              if (_isDesktopPointer(event.kind)) {
                _handleDesktopPointer(
                  event.localPosition,
                  _mapMouseButtons(event.buttons),
                );
              } else if (event.kind == PointerDeviceKind.touch &&
                  widget.touchMode == VncTouchMode.trackpad) {
                _handleTrackpadPointerUp(event);
              }
            },
            onPointerCancel: (event) {
              if (_isDesktopPointer(event.kind)) {
                final remote = _mapViewportPoint(event.localPosition);
                if (remote != null) {
                  _lastRemotePointer = remote;
                }
                _releaseDesktopMouseButtons();
              } else if (event.kind == PointerDeviceKind.touch &&
                  widget.touchMode == VncTouchMode.trackpad) {
                _handleTrackpadPointerCancel(event);
              }
            },
            onPointerSignal: (event) {
              final guarded = _scrollGuardMatrix;
              if (guarded != null) {
                _scrollGuardMatrix = null;
                _transformationController.value = guarded;
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp:
                  !widget.viewOnly && widget.touchMode == VncTouchMode.direct
                  ? _handleDirectTapUp
                  : null,
              onLongPressStart:
                  !widget.viewOnly && widget.touchMode == VncTouchMode.direct
                  ? _handleDirectLongPressStart
                  : null,
              child: ClipRect(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  constrained: !isActualSize,
                  minScale: isActualSize ? minActualScale : 1.0,
                  maxScale: 5.0,
                  panEnabled: panEnabled,
                  scaleEnabled: true,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerSignal: (event) {
                      if (!widget.viewOnly &&
                          event is PointerScrollEvent &&
                          _isDesktopPointer(event.kind)) {
                        _scrollGuardMatrix = _transformationController.value
                            .clone();
                        GestureBinding.instance.pointerSignalResolver.register(
                          event,
                          (_) => _handlePointerScrollFromChild(event),
                        );
                      }
                    },
                    child: RawGestureDetector(
                      behavior: HitTestBehavior.opaque,
                      gestures: widget.viewOnly
                          ? const <Type, GestureRecognizerFactory>{}
                          : <Type, GestureRecognizerFactory>{
                              _MouseDragClaimRecognizer:
                                  GestureRecognizerFactoryWithHandlers<
                                    _MouseDragClaimRecognizer
                                  >(
                                    () => _MouseDragClaimRecognizer(
                                      supportedDevices: const {
                                        PointerDeviceKind.mouse,
                                        PointerDeviceKind.stylus,
                                        PointerDeviceKind.invertedStylus,
                                      },
                                    ),
                                    (_) {},
                                  ),
                            },
                      child: SizedBox(
                        width: childSize.width,
                        height: childSize.height,
                        child: CustomPaint(
                          painter: _VncCanvasPainter(
                            image: _image,
                            sourceRect: sourceRect,
                            contentRect: _contentRect,
                            cursorImage: _cursorImage,
                            cursorData: widget.cursor,
                            cursorPosition: activeCursorPosition,
                            showVirtualCursor:
                                widget.touchMode == VncTouchMode.trackpad &&
                                _virtualCursor != null,
                            backgroundColor: colorScheme.surfaceContainerLowest,
                            cursorFillColor: colorScheme.primary,
                            cursorStrokeColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Immediately claims mouse/stylus drag gestures inside [InteractiveViewer]
/// when the canvas is interactive (`!viewOnly`), preventing local viewport
/// panning from stealing remote desktop mouse drags while leaving touch
/// pinch-zoom/pan unaffected.
class _MouseDragClaimRecognizer extends OneSequenceGestureRecognizer {
  _MouseDragClaimRecognizer({super.supportedDevices});

  @override
  String get debugDescription => 'vncMouseDragClaim';

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}
}

class _VncCanvasPainter extends CustomPainter {
  const _VncCanvasPainter({
    required this.image,
    required this.sourceRect,
    required this.contentRect,
    required this.cursorImage,
    required this.cursorData,
    required this.cursorPosition,
    required this.showVirtualCursor,
    required this.backgroundColor,
    required this.cursorFillColor,
    required this.cursorStrokeColor,
  });

  final ui.Image? image;
  final Rect sourceRect;
  final Rect contentRect;
  final ui.Image? cursorImage;
  final VncCursorData? cursorData;
  final Offset? cursorPosition;
  final bool showVirtualCursor;
  final Color backgroundColor;
  final Color cursorFillColor;
  final Color cursorStrokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    if (image != null && !contentRect.isEmpty && !sourceRect.isEmpty) {
      final imgW = image!.width.toDouble();
      final imgH = image!.height.toDouble();
      final safeLeft = sourceRect.left.clamp(0.0, imgW);
      final safeTop = sourceRect.top.clamp(0.0, imgH);
      final safeRight = sourceRect.right.clamp(safeLeft, imgW);
      final safeBottom = sourceRect.bottom.clamp(safeTop, imgH);
      final safeSrcRect = Rect.fromLTRB(
        safeLeft,
        safeTop,
        safeRight,
        safeBottom,
      );
      if (!safeSrcRect.isEmpty) {
        canvas.drawImageRect(
          image!,
          safeSrcRect,
          contentRect,
          Paint()..filterQuality = FilterQuality.medium,
        );
      }
    }

    if (!sourceRect.isEmpty && !contentRect.isEmpty && cursorPosition != null) {
      final cx = cursorPosition!.dx;
      final cy = cursorPosition!.dy;
      final inRegion =
          cx >= sourceRect.left &&
          cx < sourceRect.right &&
          cy >= sourceRect.top &&
          cy < sourceRect.bottom;
      if (inRegion) {
        final scaleX = contentRect.width / sourceRect.width;
        final scaleY = contentRect.height / sourceRect.height;
        final relX = cx - sourceRect.left;
        final relY = cy - sourceRect.top;

        if (cursorImage != null && cursorData != null) {
          final dst = Rect.fromLTWH(
            contentRect.left + (relX - cursorData!.hotspotX) * scaleX,
            contentRect.top + (relY - cursorData!.hotspotY) * scaleY,
            cursorData!.width * scaleX,
            cursorData!.height * scaleY,
          );
          final src = Rect.fromLTWH(
            0,
            0,
            cursorImage!.width.toDouble(),
            cursorImage!.height.toDouble(),
          );
          canvas.drawImageRect(
            cursorImage!,
            src,
            dst,
            Paint()..filterQuality = FilterQuality.low,
          );
        }

        if (showVirtualCursor) {
          final center = Offset(
            contentRect.left + relX * scaleX,
            contentRect.top + relY * scaleY,
          );
          canvas.drawCircle(
            center,
            7,
            Paint()..color = cursorFillColor.withValues(alpha: 0.85),
          );
          canvas.drawCircle(
            center,
            7,
            Paint()
              ..color = cursorStrokeColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VncCanvasPainter oldDelegate) {
    return image != oldDelegate.image ||
        sourceRect != oldDelegate.sourceRect ||
        contentRect != oldDelegate.contentRect ||
        cursorImage != oldDelegate.cursorImage ||
        cursorData != oldDelegate.cursorData ||
        cursorPosition != oldDelegate.cursorPosition ||
        showVirtualCursor != oldDelegate.showVirtualCursor ||
        backgroundColor != oldDelegate.backgroundColor ||
        cursorFillColor != oldDelegate.cursorFillColor ||
        cursorStrokeColor != oldDelegate.cursorStrokeColor;
  }
}
