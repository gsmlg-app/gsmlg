part of 'bloc.dart';

/// Base class for shell profile states.
@immutable
sealed class ShellProfileState extends Equatable {
  const ShellProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before profiles are loaded.
final class ShellProfileInitial extends ShellProfileState {
  const ShellProfileInitial();
}

/// Profiles are being loaded.
final class ShellProfileLoading extends ShellProfileState {
  const ShellProfileLoading();
}

/// Profiles loaded successfully.
final class ShellProfileLoaded extends ShellProfileState {
  /// All available shell profiles.
  final List<ShellProfile> profiles;

  /// The default profile (if any).
  ShellProfile? get defaultProfile =>
      profiles.where((p) => p.isDefault).firstOrNull;

  const ShellProfileLoaded(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

/// Error occurred while loading/saving profiles.
final class ShellProfileError extends ShellProfileState {
  final Object error;

  const ShellProfileError(this.error);

  @override
  List<Object?> get props => [error];
}
