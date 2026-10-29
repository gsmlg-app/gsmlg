import 'dart:convert';

import 'package:app_database/app_database.dart';

/// Extension methods for working with ShellProfile data.
extension ShellProfileParsing on ShellProfile {
  /// Parse environment variables from JSON string to Map.
  Map<String, String> get parsedEnvironmentVariables {
    if (environmentVariables.isEmpty) return {};
    try {
      final decoded = jsonDecode(environmentVariables) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  /// Parse aliases from JSON string to Map.
  Map<String, String> get parsedAliases {
    if (aliases.isEmpty) return {};
    try {
      final decoded = jsonDecode(aliases) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  /// Get the ShellType enum from the stored integer.
  ShellType get parsedShellType {
    return ShellType.fromValue(shellType) ?? ShellType.sh;
  }

  /// Get the CursorStyleType enum from the stored integer.
  CursorStyleType get parsedCursorStyle {
    return CursorStyleType.fromValue(cursorStyle);
  }

  /// Generate shell initialization commands from profile settings.
  ///
  /// This produces commands to:
  /// 1. Export environment variables (when [includeEnvExports] is true)
  /// 2. Define aliases
  /// 3. Run startup command
  String generateInitCommands({bool includeEnvExports = true}) {
    final buffer = StringBuffer();

    // Export environment variables
    if (includeEnvExports) {
      for (final entry in parsedEnvironmentVariables.entries) {
        final escapedValue = entry.value.replaceAll("'", "'\\''");
        buffer.writeln("export ${entry.key}='$escapedValue'");
      }
    }

    // Define aliases
    for (final entry in parsedAliases.entries) {
      final escapedValue = entry.value.replaceAll("'", "'\\''");
      buffer.writeln("alias ${entry.key}='$escapedValue'");
    }

    // Run startup command if set
    if (startupCommand.isNotEmpty) {
      buffer.writeln(startupCommand);
    }

    return buffer.toString();
  }
}

/// Utility class for encoding shell profile data to JSON.
class ShellProfileEncoder {
  /// Encode environment variables Map to JSON string.
  static String encodeEnvironmentVariables(Map<String, String> vars) {
    return jsonEncode(vars);
  }

  /// Encode aliases Map to JSON string.
  static String encodeAliases(Map<String, String> aliases) {
    return jsonEncode(aliases);
  }
}
