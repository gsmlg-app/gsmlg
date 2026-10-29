import 'package:flutter/services.dart';

/// Plugin class for communicating with native Android shell setup code.
class AndroidShellPlugin {
  static const MethodChannel _channel = MethodChannel(
    'app.gsmlg/android_shell',
  );

  /// Initializes the shell environment by extracting binaries if needed.
  ///
  /// Returns a map containing:
  /// - `prefix`: The usr prefix directory
  /// - `binPath`: The bin directory containing shell binaries
  /// - `homePath`: The user's home directory
  /// - `shellPath`: Path to the sh executable
  /// - `arch`: Detected CPU architecture
  static Future<Map<String, String>> initialize() async {
    final result = await _channel.invokeMethod<Map<Object?, Object?>>(
      'initialize',
    );
    return result?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {};
  }

  /// Returns the detected CPU architecture.
  static Future<String> getArchitecture() async {
    final result = await _channel.invokeMethod<String>('getArchitecture');
    return result ?? 'arm64-v8a';
  }

  /// Checks if the shell environment has been initialized.
  static Future<bool> isInitialized() async {
    final result = await _channel.invokeMethod<bool>('isInitialized');
    return result ?? false;
  }

  /// Gets the version of the installed shell environment.
  static Future<String?> getVersion() async {
    return await _channel.invokeMethod<String>('getVersion');
  }
}
