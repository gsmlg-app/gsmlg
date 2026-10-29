import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/target_platform.dart';

void main() {
  group('TargetPlatformExtension', () {
    group('isApple', () {
      test('returns true for iOS', () {
        expect(TargetPlatform.iOS.isApple, isTrue);
      });

      test('returns true for macOS', () {
        expect(TargetPlatform.macOS.isApple, isTrue);
      });

      test('returns false for Android', () {
        expect(TargetPlatform.android.isApple, isFalse);
      });

      test('returns false for Linux', () {
        expect(TargetPlatform.linux.isApple, isFalse);
      });

      test('returns false for Windows', () {
        expect(TargetPlatform.windows.isApple, isFalse);
      });

      test('returns false for Fuchsia', () {
        expect(TargetPlatform.fuchsia.isApple, isFalse);
      });
    });

    group('isDesktop', () {
      test('returns true for Linux', () {
        expect(TargetPlatform.linux.isDesktop, isTrue);
      });

      test('returns true for macOS', () {
        expect(TargetPlatform.macOS.isDesktop, isTrue);
      });

      test('returns true for Windows', () {
        expect(TargetPlatform.windows.isDesktop, isTrue);
      });

      test('returns false for iOS', () {
        expect(TargetPlatform.iOS.isDesktop, isFalse);
      });

      test('returns false for Android', () {
        expect(TargetPlatform.android.isDesktop, isFalse);
      });

      test('returns false for Fuchsia', () {
        expect(TargetPlatform.fuchsia.isDesktop, isFalse);
      });
    });

    group('combinations', () {
      test('macOS is both Apple and Desktop', () {
        expect(TargetPlatform.macOS.isApple, isTrue);
        expect(TargetPlatform.macOS.isDesktop, isTrue);
      });

      test('iOS is Apple but not Desktop', () {
        expect(TargetPlatform.iOS.isApple, isTrue);
        expect(TargetPlatform.iOS.isDesktop, isFalse);
      });

      test('Linux is Desktop but not Apple', () {
        expect(TargetPlatform.linux.isApple, isFalse);
        expect(TargetPlatform.linux.isDesktop, isTrue);
      });

      test('Windows is Desktop but not Apple', () {
        expect(TargetPlatform.windows.isApple, isFalse);
        expect(TargetPlatform.windows.isDesktop, isTrue);
      });

      test('Android is neither Apple nor Desktop', () {
        expect(TargetPlatform.android.isApple, isFalse);
        expect(TargetPlatform.android.isDesktop, isFalse);
      });

      test('Fuchsia is neither Apple nor Desktop', () {
        expect(TargetPlatform.fuchsia.isApple, isFalse);
        expect(TargetPlatform.fuchsia.isDesktop, isFalse);
      });
    });

    group('all platforms', () {
      test('all TargetPlatform values can use extension', () {
        for (final platform in TargetPlatform.values) {
          // Should not throw - verify extension methods are callable
          expect(() => platform.isApple, returnsNormally);
          expect(() => platform.isDesktop, returnsNormally);
        }
      });

      test('exactly 2 platforms are Apple', () {
        final appleCount = TargetPlatform.values.where((p) => p.isApple).length;
        expect(appleCount, 2); // iOS, macOS
      });

      test('exactly 3 platforms are Desktop', () {
        final desktopCount = TargetPlatform.values
            .where((p) => p.isDesktop)
            .length;
        expect(desktopCount, 3); // Linux, macOS, Windows
      });
    });
  });
}
