// @dart=3.13
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shared/macos_titlebar.dart';
import 'package:window_manager/window_manager.dart';

class _FakeWindow extends Fake implements Window {
  final listeners = <ListenerId, FutureOr<void> Function(WindowEvent)>{};
  var _nextId = 0;

  @override
  WindowId get id => 3;

  @override
  ListenerId addListener(FutureOr<void> Function(WindowEvent) callback) {
    listeners[++_nextId] = callback;
    return _nextId;
  }

  @override
  bool removeListener(ListenerId listenerId) =>
      listeners.remove(listenerId) != null;

  void emit(WindowEvent event) {
    for (final listener in listeners.values.toList()) {
      listener(event);
    }
  }
}

void main() {
  group('MacosTitlebar Constants', () {
    test('kMacosTitlebarHeight is 28.0', () {
      expect(kMacosTitlebarHeight, equals(28.0));
    });

    test('kMacosTitlebarHeight is a double', () {
      expect(kMacosTitlebarHeight, isA<double>());
    });

    test('kMacosTitlebarHeight is positive', () {
      expect(kMacosTitlebarHeight, greaterThan(0));
    });
  });

  group('MacosTitlebar', () {
    test('is a StatefulWidget', () {
      const titlebar = MacosTitlebar(color: Color(0xFF000000));
      expect(titlebar, isA<StatefulWidget>());
    });

    test('stores color property', () {
      const color = Color(0xFFFF0000);
      const titlebar = MacosTitlebar(color: color);
      expect(titlebar.color, equals(color));
    });

    test('can be const constructed', () {
      const titlebar = MacosTitlebar(color: Color(0xFF00FF00));
      expect(titlebar, isNotNull);
    });

    test('can have a key', () {
      final key = UniqueKey();
      final titlebar = MacosTitlebar(key: key, color: const Color(0xFF0000FF));
      expect(titlebar.key, equals(key));
    });
  });

  group('MacosTitlebar documentation', () {
    test('height constant matches typical macOS titlebar height', () {
      // macOS titlebars are typically 28 pixels
      // This ensures consistency with native macOS apps
      expect(kMacosTitlebarHeight, equals(28.0));
    });
  });

  testWidgets('collapses while the window is full screen', (tester) async {
    final window = _FakeWindow();
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: MacosTitlebar(color: const Color(0xFF000000), window: window),
      ),
    );
    double height() => tester.getSize(find.byType(MacosTitlebar)).height;
    expect(height(), kMacosTitlebarHeight);

    window.emit(WindowEnteredFullScreenEvent(windowId: window.id));
    await tester.pump();
    expect(height(), 0);

    window.emit(WindowFocusedEvent(windowId: window.id));
    await tester.pump();
    expect(height(), 0);

    window.emit(WindowExitedFullScreenEvent(windowId: window.id));
    await tester.pump();
    expect(height(), kMacosTitlebarHeight);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(window.listeners, isEmpty);
  });
}
