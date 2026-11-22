part of 'bloc.dart';

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

/// Default permission for clipboard writes from explicitly trusted sessions.
const kTerminalDefaultAllowRemoteClipboardWrites = true;

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

  /// Last error reading environment variables from the secure vault.
  final Object? secureStorageError;
  final Object? preferenceError;

  /// How the Option keys behave in the terminal on macOS.
  final TerminalOptionKeyBehavior optionKeyBehavior;

  /// Where `sz` downloads are saved.
  final TerminalDownloadMode downloadMode;

  /// Download folder; null means the system Downloads folder.
  final String? downloadDirectory;

  /// Allows OSC 52 writes in sessions explicitly trusted by the user.
  final bool allowRemoteClipboardWrites;

  const TerminalSettingsLoaded({
    this.environmentVariables = const {},
    this.secureStorageError,
    this.preferenceError,
    this.optionKeyBehavior = kTerminalDefaultOptionKeyBehavior,
    this.downloadMode = TerminalDownloadMode.saveToFolder,
    this.downloadDirectory,
    this.allowRemoteClipboardWrites =
        kTerminalDefaultAllowRemoteClipboardWrites,
  });

  @override
  List<Object?> get props => [
    environmentVariables,
    secureStorageError,
    preferenceError,
    optionKeyBehavior,
    downloadMode,
    downloadDirectory,
    allowRemoteClipboardWrites,
  ];

  /// Pass [clearDownloadDirectory] to reset the folder to the default.
  TerminalSettingsLoaded copyWith({
    Map<String, String>? environmentVariables,
    Object? secureStorageError,
    Object? preferenceError,
    bool clearPreferenceError = false,
    TerminalOptionKeyBehavior? optionKeyBehavior,
    TerminalDownloadMode? downloadMode,
    String? downloadDirectory,
    bool clearDownloadDirectory = false,
    bool? allowRemoteClipboardWrites,
  }) {
    return TerminalSettingsLoaded(
      environmentVariables: environmentVariables ?? this.environmentVariables,
      secureStorageError: secureStorageError ?? this.secureStorageError,
      preferenceError: clearPreferenceError
          ? null
          : preferenceError ?? this.preferenceError,
      optionKeyBehavior: optionKeyBehavior ?? this.optionKeyBehavior,
      downloadMode: downloadMode ?? this.downloadMode,
      downloadDirectory: clearDownloadDirectory
          ? null
          : downloadDirectory ?? this.downloadDirectory,
      allowRemoteClipboardWrites:
          allowRemoteClipboardWrites ?? this.allowRemoteClipboardWrites,
    );
  }
}

final class TerminalSettingsError extends TerminalSettingsState {
  final Object error;

  const TerminalSettingsError({required this.error});

  @override
  List<Object?> get props => [error];
}
