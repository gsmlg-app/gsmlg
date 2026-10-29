import 'package:flutter/services.dart';

/// Plugin class for communicating with native iOS shell setup code.
class IosShellPlugin {
  static const MethodChannel _channel = MethodChannel('app.gsmlg/ios_shell');

  /// Initializes the shell environment.
  ///
  /// Returns a map containing:
  /// - `documentsPath`: The app's Documents directory
  /// - `homePath`: The user's home directory (same as Documents)
  /// - `tmpPath`: Temporary files directory
  /// - `initialized`: Whether initialization succeeded
  static Future<Map<String, String>> initialize() async {
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'initialize',
    );
    return result?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {};
  }

  /// Executes a shell command and returns the result.
  ///
  /// Returns a map containing:
  /// - `exitCode`: The command's exit code
  /// - `stdout`: Standard output
  /// - `stderr`: Standard error
  static Future<Map<String, dynamic>> execute(String command) async {
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'execute',
      {'command': command},
    );
    return result?.map((k, v) => MapEntry(k.toString(), v)) ?? {};
  }

  /// Returns the list of available commands.
  static Future<List<String>> listCommands() async {
    final result = await _channel.invokeMethod<List<Object?>>('listCommands');
    return result?.map((e) => e.toString()).toList() ?? [];
  }

  /// Checks if a specific command is available.
  static Future<bool> isCommandAvailable(String command) async {
    final result = await _channel.invokeMethod<bool>('isCommandAvailable', {
      'command': command,
    });
    return result ?? false;
  }

  /// Checks if the shell environment has been initialized.
  static Future<bool> isInitialized() async {
    final result = await _channel.invokeMethod<bool>('isInitialized');
    return result ?? false;
  }

  /// Sets the current working directory for command execution.
  static Future<bool> setCurrentDirectory(String path) async {
    final result = await _channel.invokeMethod<bool>('setCurrentDirectory', {
      'path': path,
    });
    return result ?? false;
  }

  /// Gets the current working directory.
  static Future<String> getCurrentDirectory() async {
    final result = await _channel.invokeMethod<String>('getCurrentDirectory');
    return result ?? '';
  }
}
