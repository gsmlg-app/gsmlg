import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shortcuts.dart';

void main() {
  group('Keyboard Shortcuts', () {
    group('openSettings', () {
      test('returns meta+comma on Apple platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = openSettings;

        expect(shortcut.trigger, LogicalKeyboardKey.comma);
        expect(shortcut.meta, isTrue);
        expect(shortcut.control, isFalse);
      });

      test('returns control+comma on non-Apple platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = openSettings;

        expect(shortcut.trigger, LogicalKeyboardKey.comma);
        expect(shortcut.control, isTrue);
        expect(shortcut.meta, isFalse);
      });

      test('uses meta on iOS', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = openSettings;

        expect(shortcut.meta, isTrue);
        expect(shortcut.control, isFalse);
      });

      test('uses control on Linux', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = openSettings;

        expect(shortcut.control, isTrue);
        expect(shortcut.meta, isFalse);
      });

      test('uses control on Android', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = openSettings;

        expect(shortcut.control, isTrue);
        expect(shortcut.meta, isFalse);
      });
    });

    group('openDevTools', () {
      test('returns F12', () {
        final shortcut = openDevTools;

        expect(shortcut.trigger, LogicalKeyboardKey.f12);
        expect(shortcut.meta, isFalse);
        expect(shortcut.control, isFalse);
        expect(shortcut.alt, isFalse);
        expect(shortcut.shift, isFalse);
      });

      test('is same on all platforms', () {
        for (final platform in TargetPlatform.values) {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);

          final shortcut = openDevTools;
          expect(shortcut.trigger, LogicalKeyboardKey.f12);
        }
      });
    });

    group('openNewWindow', () {
      test('returns meta+N on macOS', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = openNewWindow;

        expect(shortcut.trigger, LogicalKeyboardKey.keyN);
        expect(shortcut.meta, isTrue);
        expect(shortcut.control, isFalse);
      });

      test('returns control+N on Windows', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = openNewWindow;

        expect(shortcut.trigger, LogicalKeyboardKey.keyN);
        expect(shortcut.control, isTrue);
        expect(shortcut.meta, isFalse);
      });
    });

    group('tabClose', () {
      test('returns meta+W on macOS', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = tabClose;

        expect(shortcut.trigger, LogicalKeyboardKey.keyW);
        expect(shortcut.meta, isTrue);
        expect(shortcut.shift, isFalse);
      });

      test('returns meta+shift+W on Windows', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = tabClose;

        expect(shortcut.trigger, LogicalKeyboardKey.keyW);
        expect(shortcut.meta, isTrue);
        expect(shortcut.shift, isTrue);
      });
    });

    group('terminalCopy', () {
      test('returns meta+C on Apple platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = terminalCopy;

        expect(shortcut.trigger, LogicalKeyboardKey.keyC);
        expect(shortcut.meta, isTrue);
        expect(shortcut.control, isFalse);
        expect(shortcut.shift, isFalse);
      });

      test('returns control+shift+C on non-Apple platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = terminalCopy;

        expect(shortcut.trigger, LogicalKeyboardKey.keyC);
        expect(shortcut.control, isTrue);
        expect(shortcut.shift, isTrue);
        expect(shortcut.meta, isFalse);
      });
    });

    group('terminalPaste', () {
      test('returns meta+V on Apple platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = terminalPaste;

        expect(shortcut.trigger, LogicalKeyboardKey.keyV);
        expect(shortcut.meta, isTrue);
        expect(shortcut.control, isFalse);
        expect(shortcut.shift, isFalse);
      });

      test('returns control+shift+V on non-Apple platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = terminalPaste;

        expect(shortcut.trigger, LogicalKeyboardKey.keyV);
        expect(shortcut.control, isTrue);
        expect(shortcut.shift, isTrue);
        expect(shortcut.meta, isFalse);
      });
    });

    group('terminalSelectAll', () {
      test('returns meta+A on Apple platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = terminalSelectAll;

        expect(shortcut.trigger, LogicalKeyboardKey.keyA);
        expect(shortcut.meta, isTrue);
        expect(shortcut.control, isFalse);
        expect(shortcut.shift, isFalse);
      });

      test('returns control+shift+A on non-Apple platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        final shortcut = terminalSelectAll;

        expect(shortcut.trigger, LogicalKeyboardKey.keyA);
        expect(shortcut.control, isTrue);
        expect(shortcut.shift, isTrue);
        expect(shortcut.meta, isFalse);
      });
    });

    group('toggleFullscreen', () {
      test('returns F11', () {
        final shortcut = toggleFullscreen;

        expect(shortcut.trigger, LogicalKeyboardKey.f11);
        expect(shortcut.meta, isFalse);
        expect(shortcut.control, isFalse);
        expect(shortcut.alt, isFalse);
        expect(shortcut.shift, isFalse);
      });

      test('is same on all platforms', () {
        for (final platform in TargetPlatform.values) {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);

          final shortcut = toggleFullscreen;
          expect(shortcut.trigger, LogicalKeyboardKey.f11);
        }
      });
    });

    group('SingleActivator properties', () {
      test('all shortcuts return SingleActivator instances', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        expect(openSettings, isA<SingleActivator>());
        expect(openDevTools, isA<SingleActivator>());
        expect(openNewWindow, isA<SingleActivator>());
        expect(tabClose, isA<SingleActivator>());
        expect(terminalCopy, isA<SingleActivator>());
        expect(terminalPaste, isA<SingleActivator>());
        expect(terminalSelectAll, isA<SingleActivator>());
        expect(toggleFullscreen, isA<SingleActivator>());
      });

      test('shortcuts are not null', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        expect(openSettings.trigger, isNotNull);
        expect(openDevTools.trigger, isNotNull);
        expect(openNewWindow.trigger, isNotNull);
        expect(tabClose.trigger, isNotNull);
        expect(terminalCopy.trigger, isNotNull);
        expect(terminalPaste.trigger, isNotNull);
        expect(terminalSelectAll.trigger, isNotNull);
        expect(toggleFullscreen.trigger, isNotNull);
      });
    });

    group('Platform consistency', () {
      test('Apple platforms use meta modifier consistently', () {
        for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);

          expect(
            openSettings.meta,
            isTrue,
            reason: 'openSettings should use meta on $platform',
          );
          expect(
            openNewWindow.meta,
            isTrue,
            reason: 'openNewWindow should use meta on $platform',
          );
          expect(
            terminalCopy.meta,
            isTrue,
            reason: 'terminalCopy should use meta on $platform',
          );
          expect(
            terminalPaste.meta,
            isTrue,
            reason: 'terminalPaste should use meta on $platform',
          );
          expect(
            terminalSelectAll.meta,
            isTrue,
            reason: 'terminalSelectAll should use meta on $platform',
          );
        }
      });

      test(
        'Non-Apple platforms use control modifier (except tabClose which uses meta)',
        () {
          for (final platform in [
            TargetPlatform.windows,
            TargetPlatform.linux,
            TargetPlatform.android,
          ]) {
            debugDefaultTargetPlatformOverride = platform;
            addTearDown(() => debugDefaultTargetPlatformOverride = null);

            expect(
              openSettings.control,
              isTrue,
              reason: 'openSettings should use control on $platform',
            );
            expect(
              openNewWindow.control,
              isTrue,
              reason: 'openNewWindow should use control on $platform',
            );
            expect(
              terminalCopy.control,
              isTrue,
              reason: 'terminalCopy should use control on $platform',
            );
            expect(
              terminalPaste.control,
              isTrue,
              reason: 'terminalPaste should use control on $platform',
            );
            expect(
              terminalSelectAll.control,
              isTrue,
              reason: 'terminalSelectAll should use control on $platform',
            );
          }
        },
      );
    });
  });
}
