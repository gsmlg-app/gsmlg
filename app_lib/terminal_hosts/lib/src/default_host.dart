import 'dart:io';

import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/android_spec.dart';
import 'package:terminal_hosts/src/ios_spec.dart';
import 'package:terminal_hosts/src/local_spec.dart';

/// Creates the default host specification for the current platform.
///
/// [name] - Optional display name for the session tab.
/// [environment] - Optional environment variables from shell profile.
/// [initCommands] - Optional init commands (exports/aliases) to run on start.
///
/// Returns:
/// - [AndroidHostSpec] on Android (sandboxed shell with bundled busybox)
/// - [IosHostSpec] on iOS (ios_system framework from a-shell)
/// - [LocalHostSpec] on all other platforms (macOS, Linux, Windows)
HostSpec createDefaultHostSpec({
  String? name,
  Map<String, String>? environment,
  String? initCommands,
  String? workingDirectory,
  String? shellCommand,
}) {
  if (Platform.isAndroid) {
    return AndroidHostSpec(
      name: name ?? 'Android',
      environment: environment ?? const {},
      initCommands: initCommands,
    );
  }
  if (Platform.isIOS) {
    return IosHostSpec(
      name: name ?? 'iOS',
      environment: environment ?? const {},
      initCommands: initCommands,
    );
  }
  return LocalHostSpec(
    name: name ?? 'Local',
    environment: environment ?? const {},
    initCommands: initCommands,
    workingDirectory: workingDirectory,
    shellCommand: shellCommand,
  );
}
