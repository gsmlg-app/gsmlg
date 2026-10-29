part of 'bloc.dart';

/// Base class for shell profile events.
@immutable
sealed class ShellProfileEvent extends Equatable {
  const ShellProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load all shell profiles from database.
final class LoadShellProfiles extends ShellProfileEvent {
  const LoadShellProfiles();
}

/// Add a new shell profile.
final class AddShellProfile extends ShellProfileEvent {
  final String name;
  final ShellType shellType;
  final Map<String, String> environmentVariables;
  final Map<String, String> aliases;
  final String fontFamily;
  final double fontSize;
  final String colorTheme;
  final String workingDirectory;
  final String startupCommand;
  final int cursorStyle;
  final int scrollbackLines;
  final bool isDefault;
  final bool inheritCurrentState;

  const AddShellProfile({
    required this.name,
    this.shellType = ShellType.sh,
    this.environmentVariables = const {},
    this.aliases = const {},
    this.fontFamily = 'Source Code Pro',
    this.fontSize = 14.0,
    this.colorTheme = 'default',
    this.workingDirectory = '',
    this.startupCommand = '',
    this.cursorStyle = 0,
    this.scrollbackLines = 10000,
    this.isDefault = false,
    this.inheritCurrentState = false,
  });

  @override
  List<Object?> get props => [
        name,
        shellType,
        environmentVariables,
        aliases,
        fontFamily,
        fontSize,
        colorTheme,
        workingDirectory,
        startupCommand,
        cursorStyle,
        scrollbackLines,
        isDefault,
        inheritCurrentState,
      ];
}

/// Update an existing shell profile.
final class UpdateShellProfile extends ShellProfileEvent {
  final int id;
  final String? name;
  final ShellType? shellType;
  final Map<String, String>? environmentVariables;
  final Map<String, String>? aliases;
  final String? fontFamily;
  final double? fontSize;
  final String? colorTheme;
  final String? workingDirectory;
  final String? startupCommand;
  final int? cursorStyle;
  final int? scrollbackLines;
  final bool? isDefault;
  final bool? inheritCurrentState;

  const UpdateShellProfile({
    required this.id,
    this.name,
    this.shellType,
    this.environmentVariables,
    this.aliases,
    this.fontFamily,
    this.fontSize,
    this.colorTheme,
    this.workingDirectory,
    this.startupCommand,
    this.cursorStyle,
    this.scrollbackLines,
    this.isDefault,
    this.inheritCurrentState,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        shellType,
        environmentVariables,
        aliases,
        fontFamily,
        fontSize,
        colorTheme,
        workingDirectory,
        startupCommand,
        cursorStyle,
        scrollbackLines,
        isDefault,
        inheritCurrentState,
      ];
}

/// Delete a shell profile.
final class DeleteShellProfile extends ShellProfileEvent {
  final ShellProfile profile;

  const DeleteShellProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Ensure a default profile exists (creates one if none exist).
final class EnsureDefaultProfile extends ShellProfileEvent {
  const EnsureDefaultProfile();
}

/// Set a profile as the default.
final class SetDefaultProfile extends ShellProfileEvent {
  final ShellProfile profile;

  const SetDefaultProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}
