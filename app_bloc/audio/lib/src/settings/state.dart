part of 'bloc.dart';

enum AudioSettingsStatus { initial, loading, ready, failure }

class AudioSettingsState extends Equatable {
  const AudioSettingsState({
    this.settings = const AudioSettings(),
    this.status = AudioSettingsStatus.initial,
    this.errorMessage,
  });

  final AudioSettings settings;
  final AudioSettingsStatus status;
  final String? errorMessage;

  AudioSettingsState copyWith({
    AudioSettings? settings,
    AudioSettingsStatus? status,
    String? errorMessage,
  }) {
    return AudioSettingsState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [settings, status, errorMessage];
}
