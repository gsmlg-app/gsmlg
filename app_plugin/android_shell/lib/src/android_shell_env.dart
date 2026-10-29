import 'dart:io';

import 'package:path/path.dart' as p;

import 'android_shell_plugin.dart';

/// Callback for reporting initialization progress.
typedef ProgressCallback = void Function(String message, double progress);

/// Singleton managing the Android sandboxed Linux shell environment.
///
/// Uses PRoot and a minimal Alpine Linux rootfs to provide a true Termux-like
/// Linux userland without requiring root privileges.
class AndroidShellEnv {
  AndroidShellEnv._();

  static AndroidShellEnv? _instance;

  /// Gets the singleton instance.
  ///
  /// You must call [initialize] before using other properties.
  static AndroidShellEnv get instance {
    _instance ??= AndroidShellEnv._();
    return _instance!;
  }

  bool _initialized = false;
  late String _filesDir;
  late String _rootfsPath;
  late String _nativeLibDir;
  late String _prootPath;
  late String _loaderPath;
  late String _loader32Path;
  late String _tmpPath;
  late String _homePath;
  late String _arch;
  late String _shellPath;
  late String _userName;
  late String _userId;
  late String _groupId;
  late String _guestHome;
  late String _guestShell;
  bool _usesSystemShell = false;

  /// Whether the environment has been initialized.
  bool get isInitialized => _initialized;

  /// The app's internal files directory.
  /// e.g., /data/data/app.gsmlg.webterminal/files
  String get filesDir => _filesDir;

  /// The rootfs directory containing the Linux distribution.
  /// e.g., /data/data/app.gsmlg.webterminal/files/rootfs
  String get rootfsPath => _rootfsPath;

  /// The native library directory containing executable ELF binaries (.so).
  String get nativeLibDir => _nativeLibDir;

  /// Path to the proot executable.
  String get prootPath => _prootPath;

  /// Path to the 64-bit proot loader.
  String get loaderPath => _loaderPath;

  /// Path to the 32-bit proot loader (if available).
  String get loader32Path => _loader32Path;

  /// The usr prefix directory inside rootfs.
  /// e.g., /data/data/app.gsmlg.webterminal/files/rootfs/usr
  String get prefix => p.join(_rootfsPath, 'usr');

  /// The bin directory containing shell binaries.
  String get binPath => p.join(prefix, 'bin');

  /// The etc directory containing configuration files.
  String get etcPath => p.join(_rootfsPath, 'etc');

  /// The user's home directory on the host filesystem.
  /// e.g., /data/data/app.gsmlg.webterminal/files/rootfs/root
  String get homePath => _homePath;

  /// Configured daily login user inside the Linux rootfs.
  String get userName => _userName;

  /// Host path of the administrator's existing home directory.
  String get rootHomePath => p.join(rootfsPath, 'root');

  /// The temporary files directory on the host filesystem.
  /// e.g., /data/data/app.gsmlg.webterminal/files/tmp
  String get tmpPath => _tmpPath;

  /// The executable path for starting the shell session.
  String get shellPath => _shellPath;

  /// Whether we're falling back to the system shell instead of PRoot.
  bool get usesSystemShell => _usesSystemShell;

  /// The detected CPU architecture.
  String get arch => _arch;

  /// Path to the shell profile.
  String get profilePath => p.join(etcPath, 'profile');

  /// Initializes the shell environment.
  ///
  /// Extracts the Alpine Linux rootfs and sets up PRoot on first run.
  /// Subsequent calls are no-ops if already initialized.
  ///
  /// [onProgress] - Optional callback for progress updates during extraction.
  Future<void> initialize({ProgressCallback? onProgress}) async {
    if (_initialized) return;

    onProgress?.call('Initializing Linux environment...', 0.1);

    // Call native plugin to extract rootfs and configure PRoot
    final paths = await AndroidShellPlugin.initialize();

    _filesDir = paths['filesDir'] ?? '';
    _rootfsPath = paths['rootfsPath'] ?? p.join(_filesDir, 'rootfs');
    _nativeLibDir = paths['nativeLibDir'] ?? '';
    _prootPath = paths['prootPath'] ?? '';
    _loaderPath = paths['loaderPath'] ?? '';
    _loader32Path = paths['loader32Path'] ?? '';
    _tmpPath = paths['tmpPath'] ?? p.join(_filesDir, 'tmp');
    _homePath = paths['homePath'] ?? p.join(_rootfsPath, 'root');
    _userName = paths['userName'] ?? 'root';
    _userId = paths['userId'] ?? '0';
    _groupId = paths['groupId'] ?? '0';
    _guestHome = paths['guestHome'] ?? '/root';
    _guestShell = paths['guestShell'] ?? '/bin/sh';
    _arch = paths['arch'] ?? 'arm64-v8a';

    // Verify if PRoot binary exists and can be used
    if (_prootPath.isNotEmpty && await File(_prootPath).exists()) {
      _usesSystemShell = false;
      _shellPath = _prootPath;
    } else {
      // Fallback to system shell if PRoot binary is missing
      _usesSystemShell = true;
      _shellPath = '/system/bin/sh';
    }

    // Ensure home and tmp directories exist
    await Directory(homePath).create(recursive: true);
    await Directory(tmpPath).create(recursive: true);

    onProgress?.call('Linux environment ready', 1.0);
    _initialized = true;
  }

  /// Returns environment variables for the sandboxed Linux shell.
  ///
  /// These should be passed to the PTY when starting a shell session.
  Map<String, String> getEnvironment({bool root = false}) {
    if (_usesSystemShell) {
      return {
        'PREFIX': prefix,
        'HOME': homePath,
        'PATH': '/system/bin:/system/xbin',
        'SHELL': shellPath,
        'TERM': 'xterm-256color',
        'LANG': 'C.UTF-8',
        'TMPDIR': tmpPath,
        'ANDROID_DATA': '/data',
        'ANDROID_ROOT': '/system',
      };
    }

    final env = <String, String>{
      'PREFIX': prefix,
      'HOME': root ? '/root' : _guestHome,
      'USER': root ? 'root' : _userName,
      'LOGNAME': root ? 'root' : _userName,
      'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      'SHELL': _guestShell,
      'WEB_TERMINAL_USER': root ? 'root' : _userName,
      'TERM': 'xterm-256color',
      'LANG': 'C.UTF-8',
      'TMPDIR': '/tmp',
      'ANDROID_DATA': '/data',
      'ANDROID_ROOT': '/system',
      'ENV': '/etc/profile',
    };

    if (!_usesSystemShell && _prootPath.isNotEmpty) {
      env['LD_LIBRARY_PATH'] = nativeLibDir;
      env['PROOT_TMP_DIR'] = tmpPath;
      env['PROOT_IGNORE_MISSING_BINDINGS'] = '1';
      if (_loaderPath.isNotEmpty) {
        env['PROOT_LOADER'] = _loaderPath;
      }
      if (_loader32Path.isNotEmpty && File(_loader32Path).existsSync()) {
        env['PROOT_LOADER_32'] = _loader32Path;
      }
    }

    return env;
  }

  /// Returns the shell command and arguments for starting a login shell.
  ///
  /// Uses the configured daily identity, or fake root for administrator sessions.
  (String, List<String>) getShellCommand({bool root = false}) {
    if (_usesSystemShell || _prootPath.isEmpty) {
      return (shellPath, ['-i']);
    }

    return (_prootPath, [..._getProotArguments(root: root), _guestShell, '-l']);
  }

  /// Builds a command invocation with the same mounts and identity as a shell.
  (String, List<String>) getExecutionCommand(
    String executable, {
    List<String> arguments = const [],
    bool root = false,
  }) {
    if (_usesSystemShell || _prootPath.isEmpty) {
      return (executable, arguments);
    }
    return (
      _prootPath,
      [
        ..._getProotArguments(root: root),
        '/bin/sh',
        '-c',
        r'exec "$0" "$@"',
        executable,
        ...arguments,
      ],
    );
  }

  List<String> _getProotArguments({required bool root}) {
    return [
      '-r',
      rootfsPath,
      if (root) '-0' else ...['-i', '$_userId:$_groupId'],
      '--link2symlink',
      '--sysvipc',
      '--kill-on-exit',
      '-b',
      '/dev',
      '-b',
      '/proc',
      '-b',
      '/sys',
      '-b',
      '/dev/urandom:/dev/random',
      '-b',
      '/proc/self/fd:/dev/fd',
      '-b',
      '/proc/self/fd/0:/dev/stdin',
      '-b',
      '/proc/self/fd/1:/dev/stdout',
      '-b',
      '/proc/self/fd/2:/dev/stderr',
      '-b',
      '$tmpPath:/tmp',
      '-b',
      '$tmpPath:/dev/shm',
      '-w',
      root ? '/root' : _guestHome,
    ];
  }

  /// Resets the singleton instance (useful for testing).
  static void reset() {
    _instance = null;
  }
}
