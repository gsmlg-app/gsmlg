import 'package:equatable/equatable.dart';

enum AudioProviderType { backplane, customOpenAi }

class AudioSettings extends Equatable {
  const AudioSettings({
    this.providerType = AudioProviderType.backplane,
    this.baseUrl = defaultBackplaneUrl,
    this.accountId,
    this.useDummyToken = false,
    this.ttsModel = defaultBackplaneTtsModel,
    this.ttsVoice = defaultBackplaneTtsVoice,
    this.ttsSpeed = 1.0,
    this.ttsResponseFormat = 'mp3',
    this.asrModel = defaultBackplaneAsrModel,
    this.asrLanguage,
  });

  final AudioProviderType providerType;
  final String baseUrl;
  final int? accountId;
  final bool useDummyToken;
  final String ttsModel;
  final String ttsVoice;
  final double ttsSpeed;
  final String ttsResponseFormat;
  final String asrModel;
  final String? asrLanguage;

  static const defaultBackplaneUrl = 'https://backplane.gsmlg.net/v1';
  static const defaultBackplaneTtsModel = 'minimax-audio/speech-2.8-turbo';
  static const defaultBackplaneAsrModel = 'minimax-audio/asr-1.0';
  static const defaultBackplaneTtsVoice = 'female-tianmei';

  AudioSettings copyWith({
    AudioProviderType? providerType,
    String? baseUrl,
    int? accountId,
    bool clearAccount = false,
    bool? useDummyToken,
    String? ttsModel,
    String? ttsVoice,
    double? ttsSpeed,
    String? ttsResponseFormat,
    String? asrModel,
    String? asrLanguage,
    bool clearLanguage = false,
  }) {
    return AudioSettings(
      providerType: providerType ?? this.providerType,
      baseUrl: baseUrl ?? this.baseUrl,
      accountId: clearAccount ? null : accountId ?? this.accountId,
      useDummyToken: useDummyToken ?? this.useDummyToken,
      ttsModel: ttsModel ?? this.ttsModel,
      ttsVoice: ttsVoice ?? this.ttsVoice,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      ttsResponseFormat: ttsResponseFormat ?? this.ttsResponseFormat,
      asrModel: asrModel ?? this.asrModel,
      asrLanguage: clearLanguage ? null : asrLanguage ?? this.asrLanguage,
    );
  }

  Map<String, dynamic> toJson() => {
    'providerType': providerType.name,
    'baseUrl': baseUrl,
    'accountId': accountId,
    'useDummyToken': useDummyToken,
    'ttsModel': ttsModel,
    'ttsVoice': ttsVoice,
    'ttsSpeed': ttsSpeed,
    'ttsResponseFormat': ttsResponseFormat,
    'asrModel': asrModel,
    'asrLanguage': asrLanguage,
  };

  factory AudioSettings.fromJson(Map<String, dynamic> json) {
    return AudioSettings(
      providerType: AudioProviderType.values.firstWhere(
        (type) => type.name == json['providerType'],
        orElse: () => AudioProviderType.backplane,
      ),
      baseUrl: json['baseUrl'] as String? ?? defaultBackplaneUrl,
      accountId: json['accountId'] as int?,
      useDummyToken: json['useDummyToken'] as bool? ?? false,
      ttsModel: json['ttsModel'] as String? ?? defaultBackplaneTtsModel,
      ttsVoice: json['ttsVoice'] as String? ?? defaultBackplaneTtsVoice,
      ttsSpeed: (json['ttsSpeed'] as num?)?.toDouble() ?? 1.0,
      ttsResponseFormat: json['ttsResponseFormat'] as String? ?? 'mp3',
      asrModel: json['asrModel'] as String? ?? defaultBackplaneAsrModel,
      asrLanguage: json['asrLanguage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    providerType,
    baseUrl,
    accountId,
    useDummyToken,
    ttsModel,
    ttsVoice,
    ttsSpeed,
    ttsResponseFormat,
    asrModel,
    asrLanguage,
  ];
}
