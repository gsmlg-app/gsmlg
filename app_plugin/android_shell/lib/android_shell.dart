/// Android self-contained shell environment using bundled busybox.
///
/// Provides a Termux-like shell experience without requiring root.
/// Busybox binaries are bundled as assets and extracted on first run.
library;

export 'src/android_shell_env.dart';
export 'src/android_shell_plugin.dart';
