part of 'bloc.dart';

/// Default maximum number of open shells.
const kTerminalDefaultMaxOpenShells = 10;

/// How the Option keys behave in the terminal on macOS.
enum TerminalOptionKeyBehavior {
  /// Left Option acts as Meta, right Option types special characters.
  leftMeta,

  /// Both Option keys act as Meta.
  bothMeta,

  /// Both Option keys type special characters.
  normal,
}

/// Default Option key behavior on macOS.
const kTerminalDefaultOptionKeyBehavior = TerminalOptionKeyBehavior.leftMeta;

@immutable
sealed class TerminalSettingsState extends Equatable {
  const TerminalSettingsState();

  @override
  List<Object?> get props => [];
}

final class TerminalSettingsInitial extends TerminalSettingsState {
  const TerminalSettingsInitial();
}

final class TerminalSettingsLoading extends TerminalSettingsState {
  const TerminalSettingsLoading();
}

final class TerminalSettingsLoaded extends TerminalSettingsState {
  /// Custom environment variables to inject into new shell sessions.
  final Map<String, String> environmentVariables;

  /// Maximum number of concurrent shell sessions allowed.
  final int maxOpenShells;

  /// Whether open terminal tabs should be restored after app restart.
  final bool restoreTerminalTabs;

  /// How the Option keys behave in the terminal on macOS.
  final TerminalOptionKeyBehavior optionKeyBehavior;

  const TerminalSettingsLoaded({
    this.environmentVariables = const {},
    this.maxOpenShells = kTerminalDefaultMaxOpenShells,
    this.restoreTerminalTabs = false,
    this.optionKeyBehavior = kTerminalDefaultOptionKeyBehavior,
  });

  @override
  List<Object?> get props => [
    environmentVariables,
    maxOpenShells,
    restoreTerminalTabs,
    optionKeyBehavior,
  ];

  TerminalSettingsLoaded copyWith({
    Map<String, String>? environmentVariables,
    int? maxOpenShells,
    bool? restoreTerminalTabs,
    TerminalOptionKeyBehavior? optionKeyBehavior,
  }) {
    return TerminalSettingsLoaded(
      environmentVariables: environmentVariables ?? this.environmentVariables,
      maxOpenShells: maxOpenShells ?? this.maxOpenShells,
      restoreTerminalTabs: restoreTerminalTabs ?? this.restoreTerminalTabs,
      optionKeyBehavior: optionKeyBehavior ?? this.optionKeyBehavior,
    );
  }
}

final class TerminalSettingsError extends TerminalSettingsState {
  final Object error;

  const TerminalSettingsError({required this.error});

  @override
  List<Object?> get props => [error];
}
