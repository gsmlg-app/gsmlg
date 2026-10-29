import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_pty/src/flutter_pty_bindings_generated.dart';

const _libName = 'flutter_pty';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isLinux) {
    // On Linux, resolve the library path relative to the executable since
    // Dart's dlopen doesn't use the executable's RUNPATH.
    final exePath = File(Platform.resolvedExecutable).parent.path;
    return DynamicLibrary.open('$exePath/lib/lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final _bindings = FlutterPtyBindings(_dylib);

final _init = () {
  return _bindings.Dart_InitializeApiDL(NativeApi.initializeApiDLData);
}();

void _ensureInitialized() {
  if (_init != 0) {
    throw StateError('Failed to initialize native bindings');
  }
}

/// Pty represents a process running in a pseudo-terminal.
///
/// To create a Pty, use [Pty.start].
class Pty {
  final String executable;

  final List<String> arguments;

  /// Spawns a process in a pseudo-terminal. The arguments have the same meaning
  /// as in [Process.start].
  /// [ackRead] indicates if the pty should wait for a call to [Pty.ackRead] before sending the next data.
  Pty.start(
    this.executable, {
    this.arguments = const [],
    String? workingDirectory,
    Map<String, String>? environment,
    int rows = 25,
    int columns = 80,
    bool ackRead = false,
  }) {
    _ensureInitialized();

    final effectiveEnv = <String, String>{};

    effectiveEnv['TERM'] = 'xterm-256color';
    // Without this, tools like "vi" produce sequences that are not UTF-8 friendly
    effectiveEnv['LANG'] = 'en_US.UTF-8';

    const envValuesToCopy = {
      'LOGNAME',
      'USER',
      'DISPLAY',
      'LC_TYPE',
      'HOME',
      'PATH'
    };

    for (var entry in Platform.environment.entries) {
      if (envValuesToCopy.contains(entry.key)) {
        effectiveEnv[entry.key] = entry.value;
      }
    }

    if (environment != null) {
      for (var entry in environment.entries) {
        effectiveEnv[entry.key] = entry.value;
      }
    }

    _stdoutPort.listen(_onOutput);
    try {
      _handle = using((arena) {
        final argv = arena<Pointer<Utf8>>(arguments.length + 2);
        argv[0] = executable.toNativeUtf8(allocator: arena);
        for (var i = 0; i < arguments.length; i++) {
          argv[i + 1] = arguments[i].toNativeUtf8(allocator: arena);
        }
        argv[arguments.length + 1] = nullptr;

        final envp = arena<Pointer<Utf8>>(effectiveEnv.length + 1);
        var index = 0;
        for (final entry in effectiveEnv.entries) {
          envp[index++] = '${entry.key}=${entry.value}'.toNativeUtf8(
            allocator: arena,
          );
        }
        envp[index] = nullptr;

        final options = arena<PtyOptions>();
        options.ref
          ..rows = rows
          ..cols = columns
          ..executable = argv[0].cast()
          ..arguments = argv.cast()
          ..environment = envp.cast()
          ..working_directory = workingDirectory == null
              ? nullptr
              : workingDirectory.toNativeUtf8(allocator: arena).cast()
          ..stdout_port = _stdoutPort.sendPort.nativePort
          ..exit_port = _exitPort.sendPort.nativePort
          ..ackRead = ackRead;
        return _bindings.pty_create(options);
      });
      if (_handle == nullptr) {
        throw ProcessException(
          executable,
          arguments,
          _getPtyError() ?? 'Failed to create PTY',
        );
      }
      _pid = _bindings.pty_getpid(_handle);
    } catch (_) {
      _stdoutPort.close();
      _exitPort.close();
      unawaited(_outputController.close());
      rethrow;
    }

    _exitPort.first.then(_onExitCode);
  }

  final _stdoutPort = ReceivePort();

  final _exitPort = ReceivePort();

  final _exitCodeCompleter = Completer<int>();

  Pointer<PtyHandle> _handle = nullptr;
  late final int _pid;
  final _outputController = StreamController<Uint8List>();
  Future<void>? _closeFuture;

  /// The output stream from the pseudo-terminal. Note that pseudo-terminals
  /// do not distinguish between stdout and stderr.
  Stream<Uint8List> get output => _outputController.stream;

  /// A `Future` which completes with the exit code of the process
  /// when the process completes.
  ///
  /// The handling of exit codes is platform specific.
  ///
  /// On Linux and OS X a normal exit code will be a positive value in
  /// the range `[0..255]`. If the process was terminated due to a signal
  /// the exit code will be a negative value in the range `[-255..-1]`,
  /// where the absolute value of the exit code is the signal
  /// number. For example, if a process crashes due to a segmentation
  /// violation the exit code will be -11, as the signal SIGSEGV has the
  /// number 11.
  ///
  /// On Windows a process can report any 32-bit value as an exit
  /// code. When returning the exit code this exit code is turned into
  /// a signed value. Some special values are used to report
  /// termination due to some system event. E.g. if a process crashes
  /// due to an access violation the 32-bit exit code is `0xc0000005`,
  /// which will be returned as the negative number `-1073741819`. To
  /// get the original 32-bit value use `(0x100000000 + exitCode) &
  /// 0xffffffff`.
  ///
  /// There is no guarantee that [output] have finished reporting the buffered
  /// output of the process when the returned future completes.
  /// To be sure that all output is captured, wait for the done event on the
  /// streams.
  Future<int> get exitCode => _exitCodeCompleter.future;

  /// The process id of the process running in the pseudo-terminal.
  int get pid => _pid;

  /// Write data to the pseudo-terminal.
  void write(Uint8List data) {
    if (_handle == nullptr || _closeFuture != null) return;
    final buf = malloc<Int8>(data.length);
    buf.asTypedList(data.length).setAll(0, data);
    _bindings.pty_write(_handle, buf.cast(), data.length);
    malloc.free(buf);
  }

  /// Resize the pseudo-terminal.
  void resize(int rows, int cols) {
    if (_handle == nullptr || _closeFuture != null) return;
    _bindings.pty_resize(_handle, rows, cols);
  }

  /// Kill the process running in the pseudo-terminal.
  ///
  /// When possible, [signal] will be sent to the process. This includes
  /// Linux and OS X. The default signal is [ProcessSignal.sigterm]
  /// which will normally terminate the process.
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    if (_handle == nullptr) return false;
    return Platform.isWindows
        ? Process.killPid(pid, signal)
        : _bindings.pty_kill(_handle, signal.signalNumber) == 0;
  }

  /// Ends the shell and its foreground process group, waits for exit, and
  /// releases native resources. Repeated calls share the same completion.
  Future<void> close() => _closeFuture ??= _close();

  Future<void> _close() async {
    for (final signal in [
      if (!Platform.isWindows) ProcessSignal.sighup,
      ProcessSignal.sigterm,
      ProcessSignal.sigkill,
    ]) {
      if (_handle == nullptr) return;
      if (Platform.isWindows) {
        kill(signal);
      } else {
        _bindings.pty_terminate(_handle, signal.signalNumber);
      }
      try {
        await exitCode.timeout(
          signal == ProcessSignal.sigkill
              ? const Duration(seconds: 2)
              : const Duration(milliseconds: 250),
        );
        return;
      } on TimeoutException {
        if (signal == ProcessSignal.sigkill) rethrow;
      }
    }
  }

  /// indicates that a data chunk has been processed.
  /// This is needed when ackRead is set to true as the pty will wait for this signal to happen
  /// before any additional data is sent.
  void ackRead() {
    if (_handle == nullptr) return;
    _bindings.pty_ack_read(_handle);
  }

  void _onOutput(dynamic data) {
    if (data == null) {
      _stdoutPort.close();
      unawaited(_outputController.close());
    } else {
      _outputController.add(data as Uint8List);
    }
  }

  void _onExitCode(dynamic exitCode) {
    if (!Platform.isWindows) {
      _bindings.pty_destroy(_handle);
    } else {
      _onOutput(null);
    }
    _handle = nullptr;
    _exitPort.close();
    _exitCodeCompleter.complete(exitCode as int);
  }
}

String? _getPtyError() {
  final error = _bindings.pty_error();

  if (error == nullptr) {
    return null;
  }

  return error.cast<Utf8>().toDartString();
}
