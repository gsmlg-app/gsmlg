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

  /// Maps a point in viewport coordinates through the inverse of
  /// [transformMatrix] and [contentRect] into clamped remote framebuffer
  /// coordinates `[0, framebufferWidth - 1] × [0, framebufferHeight - 1]`.
  ///
  /// Returns `null` if framebuffer dimensions or [contentRect] are non-positive
  /// or if [transformMatrix] is singular.
  static Offset? viewportToRemote({
    required Offset viewportPoint,
    required Matrix4 transformMatrix,
    required Rect contentRect,
    required int framebufferWidth,
    required int framebufferHeight,
  }) {
    if (framebufferWidth <= 0 ||
        framebufferHeight <= 0 ||
        contentRect.width <= 0 ||
        contentRect.height <= 0) {
      return null;
    }

    final inverse = Matrix4.tryInvert(transformMatrix);
    if (inverse == null) return null;

    final contentPoint = MatrixUtils.transformPoint(inverse, viewportPoint);
    final rawX =
        (contentPoint.dx - contentRect.left) *
        framebufferWidth /
        contentRect.width;
    final rawY =
        (contentPoint.dy - contentRect.top) *
        framebufferHeight /
        contentRect.height;

    final remoteX = rawX.clamp(0.0, (framebufferWidth - 1).toDouble());
    final remoteY = rawY.clamp(0.0, (framebufferHeight - 1).toDouble());
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

    if (_virtualCursor != null &&
        widget.framebufferWidth > 0 &&
        widget.framebufferHeight > 0) {
      _virtualCursor = Offset(
        _virtualCursor!.dx.clamp(0.0, (widget.framebufferWidth - 1).toDouble()),
        _virtualCursor!.dy.clamp(
          0.0,
          (widget.framebufferHeight - 1).toDouble(),
        ),
      );
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

    final generation = _frameStreamGeneration;
    final frameId = frame.frameId;
    ui.decodeImageFromPixels(
      frame.rgbaPixels,
      frame.width,
      frame.height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        if (_disposed ||
            !mounted ||
            generation != _frameStreamGeneration ||
            frameId < _latestDecodedFrameId) {
          image.dispose();
          return;
        }
        _latestDecodedFrameId = frameId;
        final previous = _image;
        _image = image;
        previous?.dispose();
        setState(() {});
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
    if (widget.framebufferWidth <= 0 || widget.framebufferHeight <= 0) {
      return null;
    }
    return _virtualCursor ??= Offset(
      widget.framebufferWidth / 2.0,
      widget.framebufferHeight / 2.0,
    );
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
      if (current == null) return;

      final scaleX = _contentRect.width > 0
          ? widget.framebufferWidth / _contentRect.width
          : 1.0;
      final scaleY = _contentRect.height > 0
          ? widget.framebufferHeight / _contentRect.height
          : 1.0;

      final next = Offset(
        (current.dx + delta.dx * scaleX).clamp(
          0.0,
          (widget.framebufferWidth - 1).toDouble(),
        ),
        (current.dy + delta.dy * scaleY).clamp(
          0.0,
          (widget.framebufferHeight - 1).toDouble(),
        ),
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
    final isActualSize =
        widget.scaleMode == VncScaleMode.actualSize &&
        widget.framebufferWidth > 0 &&
        widget.framebufferHeight > 0;
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
          _contentRect = VncCoordinateMapper.computeFittedRect(
            viewportSize: viewportSize,
            framebufferWidth: widget.framebufferWidth,
            framebufferHeight: widget.framebufferHeight,
            scaleMode: widget.scaleMode,
          );

          final childSize = isActualSize
              ? Size(
                  math.max(
                    viewportSize.width,
                    widget.framebufferWidth.toDouble(),
                  ),
                  math.max(
                    viewportSize.height,
                    widget.framebufferHeight.toDouble(),
                  ),
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
                  minScale: isActualSize ? 0.25 : 1.0,
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
                            contentRect: _contentRect,
                            framebufferWidth: widget.framebufferWidth,
                            framebufferHeight: widget.framebufferHeight,
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
    required this.contentRect,
    required this.framebufferWidth,
    required this.framebufferHeight,
    required this.cursorImage,
    required this.cursorData,
    required this.cursorPosition,
    required this.showVirtualCursor,
    required this.backgroundColor,
    required this.cursorFillColor,
    required this.cursorStrokeColor,
  });

  final ui.Image? image;
  final Rect contentRect;
  final int framebufferWidth;
  final int framebufferHeight;
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

    if (image != null && !contentRect.isEmpty) {
      final srcRect = Rect.fromLTWH(
        0,
        0,
        image!.width.toDouble(),
        image!.height.toDouble(),
      );
      canvas.drawImageRect(
        image!,
        srcRect,
        contentRect,
        Paint()..filterQuality = FilterQuality.medium,
      );
    }

    if (framebufferWidth > 0 &&
        framebufferHeight > 0 &&
        !contentRect.isEmpty &&
        cursorPosition != null) {
      final scaleX = contentRect.width / framebufferWidth;
      final scaleY = contentRect.height / framebufferHeight;

      if (cursorImage != null && cursorData != null) {
        final dst = Rect.fromLTWH(
          contentRect.left +
              (cursorPosition!.dx - cursorData!.hotspotX) * scaleX,
          contentRect.top +
              (cursorPosition!.dy - cursorData!.hotspotY) * scaleY,
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
          contentRect.left + cursorPosition!.dx * scaleX,
          contentRect.top + cursorPosition!.dy * scaleY,
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

  @override
  bool shouldRepaint(covariant _VncCanvasPainter oldDelegate) {
    return image != oldDelegate.image ||
        contentRect != oldDelegate.contentRect ||
        framebufferWidth != oldDelegate.framebufferWidth ||
        framebufferHeight != oldDelegate.framebufferHeight ||
        cursorImage != oldDelegate.cursorImage ||
        cursorData != oldDelegate.cursorData ||
        cursorPosition != oldDelegate.cursorPosition ||
        showVirtualCursor != oldDelegate.showVirtualCursor ||
        backgroundColor != oldDelegate.backgroundColor ||
        cursorFillColor != oldDelegate.cursorFillColor ||
        cursorStrokeColor != oldDelegate.cursorStrokeColor;
  }
}
