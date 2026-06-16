import 'package:flutter_test/flutter_test.dart';
import 'package:tts_dataset/tts_dataset.dart';

void main() {
  group('starter prompts', () {
    test('provide at least 50 preset English US prompts', () {
      expect(englishStarterPrompts, hasLength(greaterThanOrEqualTo(50)));
      expect(
        englishStarterPrompts.toSet(),
        hasLength(englishStarterPrompts.length),
      );
    });

    test('provide at least 50 preset Chinese prompts', () {
      expect(chineseStarterPrompts, hasLength(greaterThanOrEqualTo(50)));
      expect(
        chineseStarterPrompts.toSet(),
        hasLength(chineseStarterPrompts.length),
      );
    });

    test('select prompts from the project language', () {
      expect(starterPromptsForLanguage('English (US)'), englishStarterPrompts);
      expect(starterPromptsForLanguage('en-US'), englishStarterPrompts);
      expect(starterPromptsForLanguage('Chinese'), chineseStarterPrompts);
      expect(starterPromptsForLanguage('zh-CN'), chineseStarterPrompts);
    });
  });
}
