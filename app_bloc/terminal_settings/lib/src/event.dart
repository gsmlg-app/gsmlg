part of 'bloc.dart';

sealed class TerminalSettingsEvent extends Equatable {
  const TerminalSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load terminal settings from storage.
class TerminalSettingsLoad extends TerminalSettingsEvent {
  const TerminalSettingsLoad();
}

/// Update or add an environment variable.
class TerminalSettingsUpdateEnvVar extends TerminalSettingsEvent {
  final String key;
  final String value;

  const TerminalSettingsUpdateEnvVar({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

/// Remove an environment variable.
class TerminalSettingsRemoveEnvVar extends TerminalSettingsEvent {
  final String key;

  const TerminalSettingsRemoveEnvVar({required this.key});

  @override
  List<Object?> get props => [key];
}

/// Clear all custom environment variables.
class TerminalSettingsClearEnvVars extends TerminalSettingsEvent {
  const TerminalSettingsClearEnvVars();
}

/// Update the maximum number of open shells.
class TerminalSettingsUpdateMaxOpenShells extends TerminalSettingsEvent {
  final int maxOpenShells;

  const TerminalSettingsUpdateMaxOpenShells({required this.maxOpenShells});

  @override
  List<Object?> get props => [maxOpenShells];
}

/// Update whether terminal tabs are restored across app restarts.
class TerminalSettingsUpdateRestoreTabs extends TerminalSettingsEvent {
  final bool restoreTerminalTabs;

  const TerminalSettingsUpdateRestoreTabs({required this.restoreTerminalTabs});

  @override
  List<Object?> get props => [restoreTerminalTabs];
}
