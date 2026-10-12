import 'package:flutter_test/flutter_test.dart';
import 'package:app_audio/audio.dart';

void main() {
  group('AudioSettings', () {
    test('defaults to Backplane configuration', () {
      const settings = AudioSettings();
      expect(settings.providerType, AudioProviderType.backplane);
      expect(settings.baseUrl, 'https://backplane.gsmlg.net/v1');
      expect(settings.accountId, isNull);
      expect(settings.useDummyToken, isFalse);
      expect(settings.ttsModel, 'minimax-audio/speech-2.8-turbo');
      expect(settings.ttsVoice, 'alloy');
      expect(settings.ttsSpeed, 1.0);
      expect(settings.ttsResponseFormat, 'mp3');
      expect(settings.asrModel, 'minimax-audio/asr-1.0');
      expect(settings.asrLanguage, isNull);
    });

    test('serializes to and from json', () {
      const settings = AudioSettings(
        providerType: AudioProviderType.customOpenAi,
        baseUrl: 'https://custom.api/v1',
        accountId: 42,
        useDummyToken: false,
        ttsModel: 'tts-1-hd',
        ttsVoice: 'echo',
        ttsSpeed: 1.25,
        ttsResponseFormat: 'wav',
        asrModel: 'whisper-large',
        asrLanguage: 'en',
      );

      final json = settings.toJson();
      expect(json['providerType'], 'customOpenAi');
      expect(json['baseUrl'], 'https://custom.api/v1');
      expect(json['accountId'], 42);
      expect(json['useDummyToken'], isFalse);
      expect(json['ttsModel'], 'tts-1-hd');
      expect(json['ttsVoice'], 'echo');
      expect(json['ttsSpeed'], 1.25);
      expect(json['ttsResponseFormat'], 'wav');
      expect(json['asrModel'], 'whisper-large');
      expect(json['asrLanguage'], 'en');

      final reconstructed = AudioSettings.fromJson(json);
      expect(reconstructed, equals(settings));
    });

    test('fromJson handles fallback defaults when keys missing', () {
      final reconstructed = AudioSettings.fromJson(const {});
      expect(reconstructed.providerType, AudioProviderType.backplane);
      expect(reconstructed.baseUrl, 'https://backplane.gsmlg.net/v1');
      expect(reconstructed.ttsModel, 'minimax-audio/speech-2.8-turbo');
      expect(reconstructed.ttsVoice, 'alloy');
      expect(reconstructed.ttsSpeed, 1.0);
      expect(reconstructed.ttsResponseFormat, 'mp3');
      expect(reconstructed.asrModel, 'minimax-audio/asr-1.0');
      expect(reconstructed.asrLanguage, isNull);
    });

    test('copyWith updates individual fields and clears nullable fields', () {
      const original = AudioSettings(accountId: 10, asrLanguage: 'zh');

      final modified = original.copyWith(
        providerType: AudioProviderType.customOpenAi,
        baseUrl: 'https://example.com/v1',
        ttsModel: 'custom-tts',
        ttsVoice: 'nova',
        ttsSpeed: 1.5,
        ttsResponseFormat: 'opus',
        asrModel: 'whisper-2',
        useDummyToken: true,
      );

      expect(modified.providerType, AudioProviderType.customOpenAi);
      expect(modified.baseUrl, 'https://example.com/v1');
      expect(modified.accountId, 10);
      expect(modified.ttsModel, 'custom-tts');
      expect(modified.ttsVoice, 'nova');
      expect(modified.ttsSpeed, 1.5);
      expect(modified.ttsResponseFormat, 'opus');
      expect(modified.asrModel, 'whisper-2');
      expect(modified.useDummyToken, isTrue);
      expect(modified.asrLanguage, 'zh');

      final cleared = modified.copyWith(
        clearAccount: true,
        clearLanguage: true,
      );
      expect(cleared.accountId, isNull);
      expect(cleared.asrLanguage, isNull);
    });

    test('props contains all fields for equality comparison', () {
      const settings1 = AudioSettings(accountId: 1);
      const settings2 = AudioSettings(accountId: 1);
      const settings3 = AudioSettings(accountId: 2);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });
  });
}
