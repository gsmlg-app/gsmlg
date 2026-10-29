import 'package:drift/drift.dart';

/// Available shell types for local shell profiles
enum ShellType {
  sh(1),
  bash(2),
  zsh(3),
  fish(4);

  const ShellType(this.value);
  final int value;

  static ShellType? fromValue(int? value) {
    if (value == null) return null;
    return ShellType.values.cast<ShellType?>().firstWhere(
          (e) => e?.value == value,
          orElse: () => null,
        );
  }
}

/// Available cursor styles for terminal display
enum CursorStyleType {
  block(0),
  underline(1),
  verticalBar(2);

  const CursorStyleType(this.value);
  final int value;

  static CursorStyleType fromValue(int value) {
    return CursorStyleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CursorStyleType.block,
    );
  }
}

/// Table for storing shell profile configurations
@DataClassName('ShellProfile')
class ShellProfiles extends Table {
  /// Primary key - auto increment
  IntColumn get id => integer().autoIncrement()();

  /// Display name for the profile
  TextColumn get name => text()();

  /// Shell type (1=sh, 2=bash, 3=zsh, 4=fish)
  IntColumn get shellType => integer().withDefault(const Constant(1))();

  /// Environment variables as JSON string (key-value pairs)
  /// Example: {"TERM": "xterm-256color", "LANG": "en_US.UTF-8"}
  TextColumn get environmentVariables =>
      text().withDefault(const Constant('{}'))();

  /// Alias definitions as JSON string (name-command pairs)
  /// Example: {"ll": "ls -la", "gs": "git status"}
  TextColumn get aliases => text().withDefault(const Constant('{}'))();

  /// Font family for terminal display
  TextColumn get fontFamily =>
      text().withDefault(const Constant('monospace'))();

  /// Font size for terminal display (in logical pixels)
  RealColumn get fontSize => real().withDefault(const Constant(14.0))();

  /// Color theme name (references terminal theme)
  TextColumn get colorTheme => text().withDefault(const Constant('default'))();

  /// Working directory to start the shell in (empty = system default)
  TextColumn get workingDirectory => text().withDefault(const Constant(''))();

  /// Command to run automatically when the shell opens (e.g., tmux)
  TextColumn get startupCommand => text().withDefault(const Constant(''))();

  /// Cursor style (0=block, 1=underline, 2=verticalBar)
  IntColumn get cursorStyle => integer().withDefault(const Constant(0))();

  /// Number of lines to keep in scroll history
  IntColumn get scrollbackLines =>
      integer().withDefault(const Constant(10000))();

  /// Whether this is the default profile for new sessions
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Whether new shells from this profile inherit state from the active tab.
  BoolColumn get inheritCurrentState =>
      boolean().withDefault(const Constant(false))();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
