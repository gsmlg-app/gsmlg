import 'dart:async';

import 'package:app_vnc/app_vnc.dart';
import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vnc_viewer_widgets/vnc_viewer_widgets.dart';

VncFrameData _makeSolidFrame(
  int frameId,
  int width,
  int height,
  int r,
  int g,
  int b,
) {
  final pixels = Uint8List(width * height * 4);
  for (var i = 0; i < pixels.length; i += 4) {
    pixels[i] = r;
    pixels[i + 1] = g;
    pixels[i + 2] = b;
    pixels[i + 3] = 255;
  }
  return VncFrameData(
    frameId: frameId,
    width: width,
    height: height,
    rgbaPixels: pixels,
  );
}

void main() {
  group('VncCoordinateMapper', () {
    test('computeFittedRect computes letterboxed rect in fit mode', () {
      final rect = VncCoordinateMapper.computeFittedRect(
        viewportSize: const Size(800, 600),
        framebufferWidth: 1600,
        framebufferHeight: 800,
        scaleMode: VncScaleMode.fit,
      );
      expect(rect, const Rect.fromLTWH(0, 100, 800, 400));
    });

    test('computeFittedRect computes pillarboxed rect in fit mode', () {
      final rect = VncCoordinateMapper.computeFittedRect(
        viewportSize: const Size(800, 600),
        framebufferWidth: 300,
        framebufferHeight: 600,
        scaleMode: VncScaleMode.fit,
      );
      expect(rect, const Rect.fromLTWH(250, 0, 300, 600));
    });

    test('computeFittedRect returns 1:1 rect in actualSize mode', () {
      final rect = VncCoordinateMapper.computeFittedRect(
        viewportSize: const Size(800, 600),
        framebufferWidth: 1920,
        framebufferHeight: 1080,
        scaleMode: VncScaleMode.actualSize,
      );
      expect(rect, const Rect.fromLTWH(0, 0, 1920, 1080));
    });

    test('computeFittedRect returns Rect.zero for zero dimensions', () {
      expect(
        VncCoordinateMapper.computeFittedRect(
          viewportSize: const Size(800, 600),
          framebufferWidth: 0,
          framebufferHeight: 600,
          scaleMode: VncScaleMode.fit,
        ),
        Rect.zero,
      );
      expect(
        VncCoordinateMapper.computeFittedRect(
          viewportSize: Size.zero,
          framebufferWidth: 800,
          framebufferHeight: 600,
          scaleMode: VncScaleMode.fit,
        ),
        Rect.zero,
      );
    });

    test(
      'viewportToRemote maps letterboxed fit coordinates and clamps margins',
      () {
        const contentRect = Rect.fromLTWH(0, 100, 800, 400);
        final identity = Matrix4.identity();

        final center = VncCoordinateMapper.viewportToRemote(
          viewportPoint: const Offset(400, 300),
          transformMatrix: identity,
          contentRect: contentRect,
          framebufferWidth: 1600,
          framebufferHeight: 800,
        );
        expect(center, const Offset(800, 400));

        // Click inside top letterbox margin clamps Y to 0.
        final topMargin = VncCoordinateMapper.viewportToRemote(
          viewportPoint: const Offset(100, 20),
          transformMatrix: identity,
          contentRect: contentRect,
          framebufferWidth: 1600,
          framebufferHeight: 800,
        );
        expect(topMargin, const Offset(200, 0));

        // Click past bottom-right corner clamps to (width - 1, height - 1).
        final bottomRight = VncCoordinateMapper.viewportToRemote(
          viewportPoint: const Offset(900, 700),
          transformMatrix: identity,
          contentRect: contentRect,
          framebufferWidth: 1600,
          framebufferHeight: 800,
        );
        expect(bottomRight, const Offset(1599, 799));
      },
    );

    test('viewportToRemote maps actualSize 1:1 coordinates', () {
      const contentRect = Rect.fromLTWH(0, 0, 1920, 1080);
      final remote = VncCoordinateMapper.viewportToRemote(
        viewportPoint: const Offset(123, 456),
        transformMatrix: Matrix4.identity(),
        contentRect: contentRect,
        framebufferWidth: 1920,
        framebufferHeight: 1080,
      );
      expect(remote, const Offset(123, 456));
    });

    test('viewportToRemote accounts for 2x zoom and pan translation', () {
      const contentRect = Rect.fromLTWH(0, 0, 800, 600);
      // Transform: viewport = scale(2) * content + translate(-100, -50)
      final transform = Matrix4.translationValues(-100, -50, 0)
        ..multiply(Matrix4.diagonal3Values(2, 2, 1));

      // Content point (200, 150) appears at viewport (2*200 - 100, 2*150 - 50) = (300, 250)
      final remote = VncCoordinateMapper.viewportToRemote(
        viewportPoint: const Offset(300, 250),
        transformMatrix: transform,
        contentRect: contentRect,
        framebufferWidth: 1600,
        framebufferHeight: 1200,
      );
      expect(remote, isNotNull);
      expect(remote!.dx, closeTo(400, 1e-6));
      expect(remote.dy, closeTo(300, 1e-6));
    });

    test(
      'viewportToRemote returns null for invalid dimensions or singular matrix',
      () {
        expect(
          VncCoordinateMapper.viewportToRemote(
            viewportPoint: const Offset(10, 10),
            transformMatrix: Matrix4.identity(),
            contentRect: const Rect.fromLTWH(0, 0, 100, 100),
            framebufferWidth: 0,
            framebufferHeight: 100,
          ),
          isNull,
        );
        expect(
          VncCoordinateMapper.viewportToRemote(
            viewportPoint: const Offset(10, 10),
            transformMatrix: Matrix4.zero(),
            contentRect: const Rect.fromLTWH(0, 0, 100, 100),
            framebufferWidth: 100,
            framebufferHeight: 100,
          ),
          isNull,
        );
      },
    );

    test(
      'resolveSourceRect handles null, valid, clamped, and invalid regions',
      () {
        expect(
          VncCoordinateMapper.resolveSourceRect(
            framebufferWidth: 0,
            framebufferHeight: 1080,
          ),
          Rect.zero,
        );

        expect(
          VncCoordinateMapper.resolveSourceRect(
            framebufferWidth: 3840,
            framebufferHeight: 1080,
          ),
          const Rect.fromLTWH(0, 0, 3840, 1080),
        );

        expect(
          VncCoordinateMapper.resolveSourceRect(
            framebufferWidth: 3840,
            framebufferHeight: 1080,
            activeRegion: const VncScreenInfo(
              id: 2,
              x: 1920,
              y: 0,
              width: 1920,
              height: 1080,
            ),
          ),
          const Rect.fromLTWH(1920, 0, 1920, 1080),
        );

        // Region extending past framebuffer bounds is clamped.
        expect(
          VncCoordinateMapper.resolveSourceRect(
            framebufferWidth: 3840,
            framebufferHeight: 1080,
            activeRegion: const VncScreenInfo(
              id: 2,
              x: 3000,
              y: 500,
              width: 2000,
              height: 1000,
            ),
          ),
          const Rect.fromLTRB(3000, 500, 3840, 1080),
        );

        // Invalid / out-of-bounds regions fall back to the full framebuffer rect.
        expect(
          VncCoordinateMapper.resolveSourceRect(
            framebufferWidth: 3840,
            framebufferHeight: 1080,
            activeRegion: const VncScreenInfo(
              id: 3,
              x: 4000,
              y: 0,
              width: 1920,
              height: 1080,
            ),
          ),
          const Rect.fromLTWH(0, 0, 3840, 1080),
        );
        expect(
          VncCoordinateMapper.resolveSourceRect(
            framebufferWidth: 3840,
            framebufferHeight: 1080,
            activeRegion: const VncScreenInfo(
              id: 4,
              x: 0,
              y: 0,
              width: 0,
              height: 1080,
            ),
          ),
          const Rect.fromLTWH(0, 0, 3840, 1080),
        );
      },
    );

    test('viewportToRemote maps coordinates within a cropped sourceRect', () {
      const sourceRect = Rect.fromLTWH(1920, 0, 1920, 1080);
      const contentRect = Rect.fromLTWH(0, 0, 960, 540);
      final identity = Matrix4.identity();

      // Left edge maps to x=1920.
      final leftEdge = VncCoordinateMapper.viewportToRemote(
        viewportPoint: const Offset(0, 270),
        transformMatrix: identity,
        contentRect: contentRect,
        framebufferWidth: 3840,
        framebufferHeight: 1080,
        sourceRect: sourceRect,
      );
      expect(leftEdge, const Offset(1920, 540));

      // Center maps to x=2880.
      final center = VncCoordinateMapper.viewportToRemote(
        viewportPoint: const Offset(480, 270),
        transformMatrix: identity,
        contentRect: contentRect,
        framebufferWidth: 3840,
        framebufferHeight: 1080,
        sourceRect: sourceRect,
      );
      expect(center, const Offset(2880, 540));

      // Right edge clamps to x=3839, y=1079.
      final rightEdge = VncCoordinateMapper.viewportToRemote(
        viewportPoint: const Offset(960, 540),
        transformMatrix: identity,
        contentRect: contentRect,
        framebufferWidth: 3840,
        framebufferHeight: 1080,
        sourceRect: sourceRect,
      );
      expect(rightEdge, const Offset(3839, 1079));
    });
  });

  group('VncViewerCanvas', () {
    testWidgets(
      'renders streamed frames, forwards tap and key events, and disposes cleanly',
      (tester) async {
        final controller = StreamController<VncFrameData>.broadcast();
        final pointerEvents = <(int, int, int)>[];
        final keyEvents = <(int, bool)>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: VncViewerCanvas(
                    frames: controller.stream,
                    framebufferWidth: 400,
                    framebufferHeight: 400,
                    onPointerEvent: (x, y, mask) =>
                        pointerEvents.add((x, y, mask)),
                    onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
                  ),
                ),
              ),
            ),
          ),
        );

        // Feed two 4x4 RGBA frames via stream.
        await tester.runAsync(() async {
          controller.add(_makeSolidFrame(1, 4, 4, 255, 0, 0));
          await Future<void>.delayed(const Duration(milliseconds: 20));
          controller.add(_makeSolidFrame(2, 4, 4, 0, 255, 0));
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pump();

        expect(find.byType(CustomPaint), findsWidgets);

        // Tap center of 400x400 canvas -> (200, 200) left press + release.
        await tester.tap(find.byType(VncViewerCanvas));
        await tester.pump();

        expect(pointerEvents, [(200, 200, 1), (200, 200, 0)]);

        // Send a hardware KeyEvent.
        await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        expect(keyEvents, [
          (X11Keysym.escape, true),
          (X11Keysym.escape, false),
        ]);

        // Dispose cleanly without throwing.
        await tester.pumpWidget(const SizedBox.shrink());
        await controller.close();
      },
    );

    testWidgets('maps mouse buttons and wheel scroll events', (tester) async {
      final controller = StreamController<VncFrameData>.broadcast();
      final pointerEvents = <(int, int, int)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 200,
                height: 200,
                child: VncViewerCanvas(
                  frames: controller.stream,
                  framebufferWidth: 200,
                  framebufferHeight: 200,
                  onPointerEvent: (x, y, mask) =>
                      pointerEvents.add((x, y, mask)),
                ),
              ),
            ),
          ),
        ),
      );

      final mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await mouse.down(const Offset(50, 60));
      await tester.pump();
      await mouse.up();
      await tester.pump();

      // Secondary mouse button maps to RFB bit 2 (mask 4).
      expect(pointerEvents, [(50, 60, 4), (50, 60, 0)]);

      pointerEvents.clear();
      // Wheel scroll down sends bit 4 (16) then 0.
      tester.binding.handlePointerEvent(
        const PointerScrollEvent(
          position: Offset(50, 60),
          scrollDelta: Offset(0, 20),
        ),
      );
      await tester.pump();

      expect(pointerEvents, [(50, 60, 16), (50, 60, 0)]);

      await controller.close();
    });

    testWidgets('viewOnly suppresses pointer and key callbacks', (
      tester,
    ) async {
      final controller = StreamController<VncFrameData>.broadcast();
      final pointerEvents = <(int, int, int)>[];
      final keyEvents = <(int, bool)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: VncViewerCanvas(
                frames: controller.stream,
                framebufferWidth: 200,
                framebufferHeight: 200,
                viewOnly: true,
                onPointerEvent: (x, y, mask) => pointerEvents.add((x, y, mask)),
                onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VncViewerCanvas));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(pointerEvents, isEmpty);
      expect(keyEvents, isEmpty);

      await controller.close();
    });

    testWidgets(
      'trackpad mode moves virtual cursor and supports 1-finger and 2-finger taps',
      (tester) async {
        final controller = StreamController<VncFrameData>.broadcast();
        final pointerEvents = <(int, int, int)>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: VncViewerCanvas(
                    frames: controller.stream,
                    framebufferWidth: 200,
                    framebufferHeight: 200,
                    touchMode: VncTouchMode.trackpad,
                    onPointerEvent: (x, y, mask) =>
                        pointerEvents.add((x, y, mask)),
                  ),
                ),
              ),
            ),
          ),
        );

        // 1-finger drag by (+20, -10) moves virtual cursor from center (100, 100) to (120, 90).
        final drag = await tester.startGesture(const Offset(50, 50));
        await drag.moveBy(const Offset(20, -10));
        await tester.pump();
        await drag.up();
        await tester.pump();

        expect(pointerEvents, [(120, 90, 0)]);

        // 1-finger tap sends left click at virtual cursor (120, 90).
        pointerEvents.clear();
        final tap1 = await tester.startGesture(const Offset(60, 60));
        await tap1.up();
        await tester.pump();
        expect(pointerEvents, [(120, 90, 1), (120, 90, 0)]);

        // 2-finger tap sends right click at virtual cursor (120, 90).
        pointerEvents.clear();
        final f1 = await tester.startGesture(const Offset(60, 60), pointer: 10);
        final f2 = await tester.startGesture(const Offset(90, 60), pointer: 11);
        await f1.up();
        await f2.up();
        await tester.pump();
        expect(pointerEvents, [(120, 90, 4), (120, 90, 0)]);

        // Small jitter within tap slop does not move cursor before clicking.
        pointerEvents.clear();
        final jitterTap = await tester.startGesture(const Offset(70, 70));
        await jitterTap.moveBy(const Offset(3, 2));
        await tester.pump();
        await jitterTap.up();
        await tester.pump();
        expect(pointerEvents, [(120, 90, 1), (120, 90, 0)]);

        await controller.close();
      },
    );

    testWidgets(
      'desktop mouse drag and wheel forward remote events without altering InteractiveViewer transform',
      (tester) async {
        final controller = StreamController<VncFrameData>.broadcast();
        final pointerEvents = <(int, int, int)>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: VncViewerCanvas(
                    frames: controller.stream,
                    framebufferWidth: 1000,
                    framebufferHeight: 1000,
                    scaleMode: VncScaleMode.actualSize,
                    onPointerEvent: (x, y, mask) =>
                        pointerEvents.add((x, y, mask)),
                  ),
                ),
              ),
            ),
          ),
        );

        final viewer = tester.widget<InteractiveViewer>(
          find.byType(InteractiveViewer),
        );
        final transformController = viewer.transformationController!;
        expect(transformController.value, Matrix4.identity());

        // Mouse drag across actualSize canvas (would pan InteractiveViewer if not claimed).
        final mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          buttons: kPrimaryMouseButton,
        );
        await mouse.down(const Offset(40, 40));
        await mouse.moveBy(const Offset(60, 50));
        await mouse.up();
        await tester.pump();

        expect(pointerEvents, [(40, 40, 1), (100, 90, 1), (100, 90, 0)]);
        expect(transformController.value, Matrix4.identity());

        // Mouse wheel scroll (would zoom InteractiveViewer if not claimed via pointerSignalResolver).
        pointerEvents.clear();
        tester.binding.handlePointerEvent(
          const PointerScrollEvent(
            position: Offset(80, 70),
            scrollDelta: Offset(0, -30),
          ),
        );
        await tester.pump();

        expect(pointerEvents, [(80, 70, 8), (80, 70, 0)]);
        expect(transformController.value, Matrix4.identity());

        await controller.close();
      },
    );

    testWidgets('held hardware keys release on blur and on dispose', (
      tester,
    ) async {
      final controller = StreamController<VncFrameData>.broadcast();
      final focusNode = FocusNode();
      final keyEvents = <(int, bool)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: VncViewerCanvas(
                frames: controller.stream,
                framebufferWidth: 200,
                framebufferHeight: 200,
                focusNode: focusNode,
                onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
              ),
            ),
          ),
        ),
      );

      // Hold Shift then unfocus -> Shift must be released on blur.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(keyEvents, [(X11Keysym.shiftL, true)]);

      focusNode.unfocus();
      await tester.pump();
      expect(keyEvents, [(X11Keysym.shiftL, true), (X11Keysym.shiftL, false)]);

      // Refocus, hold Control, then dispose -> Control must be released on dispose.
      keyEvents.clear();
      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(keyEvents, [(X11Keysym.controlL, true)]);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(keyEvents, [
        (X11Keysym.controlL, true),
        (X11Keysym.controlL, false),
      ]);

      // Release simulated keyboard state cleanly for subsequent tests.
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      focusNode.dispose();
      await controller.close();
    });

    testWidgets(
      'didUpdateWidget handles stream swap, cursor clear, viewOnly release, and touchMode switch',
      (tester) async {
        final stream1 = StreamController<VncFrameData>.broadcast();
        final stream2 = StreamController<VncFrameData>.broadcast();
        final pointerEvents = <(int, int, int)>[];
        final keyEvents = <(int, bool)>[];

        Widget buildCanvas({
          required Stream<VncFrameData> frames,
          VncCursorData? cursor,
          bool viewOnly = false,
          VncTouchMode touchMode = VncTouchMode.trackpad,
        }) {
          return MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: VncViewerCanvas(
                    frames: frames,
                    framebufferWidth: 200,
                    framebufferHeight: 200,
                    cursor: cursor,
                    viewOnly: viewOnly,
                    touchMode: touchMode,
                    onPointerEvent: (x, y, mask) =>
                        pointerEvents.add((x, y, mask)),
                    onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
                  ),
                ),
              ),
            ),
          );
        }

        final cursor = VncCursorData(
          width: 2,
          height: 2,
          hotspotX: 0,
          hotspotY: 0,
          rgbaPixels: Uint8List(16)..fillRange(0, 16, 255),
        );

        await tester.pumpWidget(
          buildCanvas(frames: stream1.stream, cursor: cursor),
        );
        await tester.runAsync(() async {
          stream1.add(_makeSolidFrame(5, 4, 4, 255, 0, 0));
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pump();

        // Swap to stream2 and clear cursor.
        await tester.pumpWidget(
          buildCanvas(frames: stream2.stream, cursor: null),
        );
        await tester.runAsync(() async {
          stream2.add(_makeSolidFrame(1, 4, 4, 0, 0, 255));
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pump();

        // Start a trackpad gesture, then switch touchMode to direct mid-gesture.
        final gesture = await tester.startGesture(const Offset(50, 50));
        await tester.pumpWidget(
          buildCanvas(frames: stream2.stream, touchMode: VncTouchMode.direct),
        );
        await gesture.up();
        await tester.pump();
        expect(pointerEvents, isEmpty);

        // Press mouse button + hardware key, then switch viewOnly -> true.
        final mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          buttons: kPrimaryMouseButton,
        );
        await mouse.down(const Offset(30, 40));
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.pump();
        expect(pointerEvents, [(30, 40, 1)]);
        expect(keyEvents, [(X11Keysym.altL, true)]);

        await tester.pumpWidget(
          buildCanvas(
            frames: stream2.stream,
            touchMode: VncTouchMode.direct,
            viewOnly: true,
          ),
        );
        await tester.pump();

        expect(pointerEvents, [(30, 40, 1), (30, 40, 0)]);
        expect(keyEvents, [(X11Keysym.altL, true), (X11Keysym.altL, false)]);

        await mouse.up();
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await stream1.close();
        await stream2.close();
      },
    );

    testWidgets(
      'crops activeRegion and translates tap coordinates into remote display offsets',
      (tester) async {
        final controller = StreamController<VncFrameData>.broadcast();
        final pointerEvents = <(int, int, int)>[];

        const display2 = VncScreenInfo(
          id: 2,
          x: 1920,
          y: 0,
          width: 1920,
          height: 1080,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 640,
                  height: 360,
                  child: VncViewerCanvas(
                    frames: controller.stream,
                    framebufferWidth: 3840,
                    framebufferHeight: 1080,
                    activeRegion: display2,
                    onPointerEvent: (x, y, mask) =>
                        pointerEvents.add((x, y, mask)),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.runAsync(() async {
          controller.add(_makeSolidFrame(1, 3840, 1080, 10, 20, 30));
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pump();

        // Tap center of canvas -> should map to center of Display 2 (2880, 540), NOT (1920, 540).
        await tester.tap(find.byType(VncViewerCanvas));
        await tester.pump();

        expect(pointerEvents, hasLength(2));
        expect(pointerEvents[0].$1, closeTo(2880, 2));
        expect(pointerEvents[0].$2, closeTo(540, 2));
        expect(pointerEvents[0].$3, 1);
        expect(pointerEvents[1].$1, closeTo(2880, 2));
        expect(pointerEvents[1].$2, closeTo(540, 2));
        expect(pointerEvents[1].$3, 0);

        await controller.close();
      },
    );
  });

  group('VncShortcutBar', () {
    testWidgets(
      'toggling Command + tapping Tab sends superL down, tab down/up, superL up',
      (tester) async {
        final keyEvents = <(int, bool)>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VncShortcutBar(
                onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
              ),
            ),
          ),
        );

        await tester.tap(find.text('⌘'));
        await tester.pump();
        await tester.tap(find.text('Tab'));
        await tester.pump();

        expect(keyEvents, [
          (X11Keysym.superL, true),
          (X11Keysym.tab, true),
          (X11Keysym.tab, false),
          (X11Keysym.superL, false),
        ]);
      },
    );

    testWidgets('Ctrl+Alt+Del sends all 3 keys down then up', (tester) async {
      final keyEvents = <(int, bool)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VncShortcutBar(
              onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ctrl+Alt+Del'));
      await tester.pump();

      expect(keyEvents, [
        (X11Keysym.controlL, true),
        (X11Keysym.altL, true),
        (X11Keysym.delete, true),
        (X11Keysym.delete, false),
        (X11Keysym.altL, false),
        (X11Keysym.controlL, false),
      ]);
    });

    testWidgets('releases active sticky modifiers on dispose', (tester) async {
      final keyEvents = <(int, bool)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VncShortcutBar(
              onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
            ),
          ),
        ),
      );

      await tester.tap(find.text('⌃'));
      await tester.pump();
      expect(keyEvents, [(X11Keysym.controlL, true)]);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(keyEvents, [
        (X11Keysym.controlL, true),
        (X11Keysym.controlL, false),
      ]);
    });

    testWidgets('soft keyboard input sends characters, backspace, and enter', (
      tester,
    ) async {
      final keyEvents = <(int, bool)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VncShortcutBar(
              onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);

      // Type 'a' (keeps sentinel '\u200B' + 'a')
      await tester.enterText(find.byType(TextField), '\u200Ba');
      await tester.pump();
      expect(keyEvents, [
        ('a'.codeUnitAt(0), true),
        ('a'.codeUnitAt(0), false),
      ]);

      // Clear text to simulate backspace deleting the sentinel
      keyEvents.clear();
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(keyEvents, [
        (X11Keysym.backSpace, true),
        (X11Keysym.backSpace, false),
      ]);

      // Submit sends Return
      keyEvents.clear();
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      expect(keyEvents, [
        (X11Keysym.returnKey, true),
        (X11Keysym.returnKey, false),
      ]);
    });

    testWidgets(
      'switching enabled to false releases active modifiers and closes soft keyboard',
      (tester) async {
        final keyEvents = <(int, bool)>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VncShortcutBar(
                enabled: true,
                onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
              ),
            ),
          ),
        );

        await tester.tap(find.text('⌘'));
        await tester.tap(find.byIcon(Icons.keyboard_outlined));
        await tester.pump();
        expect(keyEvents, [(X11Keysym.superL, true)]);
        expect(find.byType(TextField), findsOneWidget);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VncShortcutBar(
                enabled: false,
                onKeyEvent: (ks, down) => keyEvents.add((ks, down)),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(keyEvents, [
          (X11Keysym.superL, true),
          (X11Keysym.superL, false),
        ]);
        expect(find.byType(TextField), findsNothing);
      },
    );
  });
}
