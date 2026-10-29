import 'package:app_utils/app_utils.dart';
import 'package:test/test.dart';

void main() {
  group('PlatformExt', () {
    group('isDesktop', () {
      test('is true on macOS', () {
        if (Platform.isMacOS) {
          expect(PlatformExt.isDesktop, isTrue);
        }
      });

      test('is true on Windows', () {
        if (Platform.isWindows) {
          expect(PlatformExt.isDesktop, isTrue);
        }
      });

      test('is true on Linux', () {
        if (Platform.isLinux) {
          expect(PlatformExt.isDesktop, isTrue);
        }
      });

      test('matches expected value based on platform', () {
        final expected =
            Platform.isMacOS || Platform.isWindows || Platform.isLinux;
        expect(PlatformExt.isDesktop, expected);
      });
    });

    group('isMobile', () {
      test('is false on macOS', () {
        if (Platform.isMacOS) {
          expect(PlatformExt.isMobile, isFalse);
        }
      });

      test('is false on Windows', () {
        if (Platform.isWindows) {
          expect(PlatformExt.isMobile, isFalse);
        }
      });

      test('is false on Linux', () {
        if (Platform.isLinux) {
          expect(PlatformExt.isMobile, isFalse);
        }
      });

      test('matches expected value based on platform', () {
        final expected = Platform.isAndroid || Platform.isIOS;
        expect(PlatformExt.isMobile, expected);
      });
    });

    group('isWeb', () {
      test('is false in non-web test environment', () {
        // When running tests with dart test or flutter test,
        // we're not in a web environment
        expect(PlatformExt.isWeb, isFalse);
      });
    });

    group('isAIM (Android, iOS, macOS)', () {
      test('is true on macOS', () {
        if (Platform.isMacOS) {
          expect(PlatformExt.isAIM, isTrue);
        }
      });

      test('is false on Windows', () {
        if (Platform.isWindows) {
          expect(PlatformExt.isAIM, isFalse);
        }
      });

      test('is false on Linux', () {
        if (Platform.isLinux) {
          expect(PlatformExt.isAIM, isFalse);
        }
      });

      test('matches expected value based on platform', () {
        final expected =
            Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
        expect(PlatformExt.isAIM, expected);
      });
    });

    group('mutual exclusivity', () {
      test('desktop and mobile are mutually exclusive', () {
        // On any platform, can't be both desktop and mobile
        expect(PlatformExt.isDesktop && PlatformExt.isMobile, isFalse);
      });

      test('isAIM includes macOS but not Windows/Linux', () {
        if (Platform.isMacOS) {
          expect(PlatformExt.isAIM, isTrue);
          expect(PlatformExt.isDesktop, isTrue);
        } else if (Platform.isWindows || Platform.isLinux) {
          expect(PlatformExt.isAIM, isFalse);
          expect(PlatformExt.isDesktop, isTrue);
        }
      });
    });
  });

  group('PlatformExtension', () {
    // Note: PlatformExtension provides static extension methods on Platform
    // These should have identical behavior to PlatformExt

    group('isDesktop', () {
      test('matches PlatformExt.isDesktop', () {
        expect(PlatformExtension.isDesktop, PlatformExt.isDesktop);
      });

      test('returns correct value for current platform', () {
        final expected =
            Platform.isMacOS || Platform.isWindows || Platform.isLinux;
        expect(PlatformExtension.isDesktop, expected);
      });
    });

    group('isMobile', () {
      test('matches PlatformExt.isMobile', () {
        expect(PlatformExtension.isMobile, PlatformExt.isMobile);
      });

      test('returns correct value for current platform', () {
        final expected = Platform.isAndroid || Platform.isIOS;
        expect(PlatformExtension.isMobile, expected);
      });
    });

    group('isWeb', () {
      test('matches PlatformExt.isWeb', () {
        expect(PlatformExtension.isWeb, PlatformExt.isWeb);
      });

      test('is false in non-web environment', () {
        expect(PlatformExtension.isWeb, isFalse);
      });
    });

    group('isAIM', () {
      test('matches PlatformExt.isAIM', () {
        expect(PlatformExtension.isAIM, PlatformExt.isAIM);
      });

      test('returns correct value for current platform', () {
        final expected =
            Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
        expect(PlatformExtension.isAIM, expected);
      });
    });
  });

  group('Platform consistency', () {
    test('one platform flag is always true', () {
      final platformFlags = [
        Platform.isAndroid,
        Platform.isFuchsia,
        Platform.isIOS,
        Platform.isLinux,
        Platform.isMacOS,
        Platform.isWindows,
      ];

      expect(platformFlags.where((f) => f).length, 1);
    });

    test('desktop platforms do not include mobile platforms', () {
      if (PlatformExt.isDesktop) {
        expect(Platform.isAndroid, isFalse);
        expect(Platform.isIOS, isFalse);
      }
    });

    test('mobile platforms do not include desktop platforms', () {
      if (PlatformExt.isMobile) {
        expect(Platform.isMacOS, isFalse);
        expect(Platform.isWindows, isFalse);
        expect(Platform.isLinux, isFalse);
      }
    });
  });

  group('Platform properties', () {
    test('operatingSystem returns non-empty string', () {
      expect(Platform.operatingSystem, isNotEmpty);
    });

    test('operatingSystemVersion returns non-empty string', () {
      expect(Platform.operatingSystemVersion, isNotEmpty);
    });

    test('localeName returns non-empty string', () {
      expect(Platform.localeName, isNotEmpty);
    });

    test('numberOfProcessors is positive', () {
      expect(Platform.numberOfProcessors, greaterThan(0));
    });

    test('pathSeparator is valid', () {
      if (Platform.isWindows) {
        expect(Platform.pathSeparator, '\\');
      } else {
        expect(Platform.pathSeparator, '/');
      }
    });
  });

  group('Platform environment', () {
    test('environment is not empty', () {
      expect(Platform.environment, isNotEmpty);
    });

    test('PATH environment variable exists', () {
      // PATH on Unix, Path or PATH on Windows
      final hasPath = Platform.environment.containsKey('PATH') ||
          Platform.environment.containsKey('Path');
      expect(hasPath, isTrue);
    });
  });

  group('Exported Platform class', () {
    test('Platform is re-exported from dart:io', () {
      // Verify that Platform is accessible through app_utils
      expect(
          Platform.isMacOS ||
              Platform.isWindows ||
              Platform.isLinux ||
              Platform.isAndroid ||
              Platform.isIOS ||
              Platform.isFuchsia,
          isTrue);
    });
  });
}
