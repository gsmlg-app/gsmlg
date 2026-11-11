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

/// Where files downloaded with `sz` are saved.
enum TerminalDownloadMode {
  /// Save straight into the download folder.
  saveToFolder,

  /// Ask for a folder each time.
  ask,
}

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

  /// Where `sz` downloads are saved.
  final TerminalDownloadMode downloadMode;

  /// Download folder; null means the system Downloads folder.
  final String? downloadDirectory;

  const TerminalSettingsLoaded({
    this.environmentVariables = const {},
    this.maxOpenShells = kTerminalDefaultMaxOpenShells,
    this.restoreTerminalTabs = false,
    this.optionKeyBehavior = kTerminalDefaultOptionKeyBehavior,
    this.downloadMode = TerminalDownloadMode.saveToFolder,
    this.downloadDirectory,
  });

  @override
  List<Object?> get props => [
    environmentVariables,
    maxOpenShells,
    restoreTerminalTabs,
    optionKeyBehavior,
    downloadMode,
    downloadDirectory,
  ];

  /// Pass [clearDownloadDirectory] to reset the folder to the default.
  TerminalSettingsLoaded copyWith({
    Map<String, String>? environmentVariables,
    int? maxOpenShells,
    bool? restoreTerminalTabs,
    TerminalOptionKeyBehavior? optionKeyBehavior,
    TerminalDownloadMode? downloadMode,
    String? downloadDirectory,
    bool clearDownloadDirectory = false,
  }) {
    return TerminalSettingsLoaded(
      environmentVariables: environmentVariables ?? this.environmentVariables,
      maxOpenShells: maxOpenShells ?? this.maxOpenShells,
      restoreTerminalTabs: restoreTerminalTabs ?? this.restoreTerminalTabs,
      optionKeyBehavior: optionKeyBehavior ?? this.optionKeyBehavior,
      downloadMode: downloadMode ?? this.downloadMode,
      downloadDirectory: clearDownloadDirectory
          ? null
          : downloadDirectory ?? this.downloadDirectory,
    );
  }
}

final class TerminalSettingsError extends TerminalSettingsState {
  final Object error;

  const TerminalSettingsError({required this.error});

  @override
  List<Object?> get props => [error];
}
