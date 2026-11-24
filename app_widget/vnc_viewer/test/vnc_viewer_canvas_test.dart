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
  });
}
