import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_tabs/src/shortcut/intents.dart';

void main() {
  group('Intent Classes', () {
    group('NewWindowIntent', () {
      test('extends Intent', () {
        const intent = NewWindowIntent();
        expect(intent, isA<Intent>());
      });

      test('is const constructible', () {
        const intent1 = NewWindowIntent();
        const intent2 = NewWindowIntent();
        expect(intent1, isNotNull);
        expect(intent2, isNotNull);
      });

      test('multiple instances are equal due to const', () {
        const intent1 = NewWindowIntent();
        const intent2 = NewWindowIntent();
        expect(identical(intent1, intent2), isTrue);
      });
    });

    group('ToggleFullscreenIntent', () {
      test('extends Intent', () {
        const intent = ToggleFullscreenIntent();
        expect(intent, isA<Intent>());
      });

      test('is const constructible', () {
        const intent1 = ToggleFullscreenIntent();
        const intent2 = ToggleFullscreenIntent();
        expect(intent1, isNotNull);
        expect(intent2, isNotNull);
      });

      test('multiple instances are equal due to const', () {
        const intent1 = ToggleFullscreenIntent();
        const intent2 = ToggleFullscreenIntent();
        expect(identical(intent1, intent2), isTrue);
      });
    });

    group('Intent distinct types', () {
      test(
        'NewWindowIntent and ToggleFullscreenIntent are different types',
        () {
          const newWindowIntent = NewWindowIntent();
          const toggleFullscreenIntent = ToggleFullscreenIntent();

          expect(
            newWindowIntent.runtimeType,
            isNot(toggleFullscreenIntent.runtimeType),
          );
        },
      );
    });
  });
}
