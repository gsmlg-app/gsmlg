part of 'bloc.dart';

sealed class AudioSettingsEvent extends Equatable {
  const AudioSettingsEvent();

  @override
  List<Object?> get props => [];
}

final class AudioSettingsLoad extends AudioSettingsEvent {
  const AudioSettingsLoad();
}

final class AudioSettingsSave extends AudioSettingsEvent {
  const AudioSettingsSave(this.settings);
  final AudioSettings settings;

  @override
  List<Object?> get props => [settings];
}

final class AudioSettingsResetToBackplane extends AudioSettingsEvent {
  const AudioSettingsResetToBackplane();
}
