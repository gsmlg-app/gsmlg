import 'dart:async';
import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/src/isolate_session_binding.dart';
import 'package:terminal_plugin/src/remote_clipboard.dart';
import 'package:terminal_plugin/src/terminal_extra_keys.dart';
import 'package:terminal_plugin/src/terminal_menu.dart';
import 'package:terminal_plugin/src/terminal_shortcut_handler.dart';
import 'package:terminal_plugin/src/zmodem/io_zmodem_file_access.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_file_access.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_progress_panel.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_transfer_controller.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:xterm/session_isolate.dart';
import 'package:xterm/session_isolate_view.dart';
import 'package:xterm/xterm.dart';

class TerminalPlugin extends Plugin {
  TerminalPlugin({
    this.profileFontSize = 14.0,
    this.profileFontFamily = 'Source Code Pro',
    this.profileCursorType = TerminalCursorType.block,
    int scrollbackLines = 10000,
    ZmodemFileAccess? fileAccess,
    bool useIsolatedTerminal =
        const bool.fromEnvironment('WEB_TERMINAL_EXPERIMENTAL_ISOLATE'),
    this.startDirectory,
    bool Function()? remoteClipboardWritesAllowed,
    this.isExperimentalClipboardTabActive,
    Future<void> Function(String text)? writeClipboard,
  })  : _useIsolatedTerminal = useIsolatedTerminal &&
            !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.windows),
        _scrollbackLines = scrollbackLines,
        remoteClipboard = RemoteClipboard(
          writesAllowed: remoteClipboardWritesAllowed ??
              () => kTerminalDefaultAllowRemoteClipboardWrites,
          writeClipboard: writeClipboard,
        ),
        fileAccess = fileAccess ??
            IoZmodemFileAccess(
              settings: () =>
                  (mode: ZmodemDownloadMode.saveToFolder, directory: null),
            );

  final bool _useIsolatedTerminal;
  final int _scrollbackLines;
  late final Terminal terminal = Terminal(
    maxLines: _scrollbackLines,
    batchWrites: true,
    platform: _terminalTargetPlatform(),
  );

  bool get isolatedTerminalEnabled => _useIsolatedTerminal;

  final _isolateBinding = ValueNotifier<IsolateSessionBinding?>(null);
  IsolateHub? _isolateHub;
  final bool Function()? isExperimentalClipboardTabActive;
  bool _isolateClipboardVisible = false;
  bool _isolateClipboardPreviouslyEligible = false;
  int _isolateClipboardEpoch = 0;

  final RemoteClipboard remoteClipboard;

  /// File access for `sz`/`rz` transfers.
  final ZmodemFileAccess fileAccess;

  ZmodemTransferController? _zmodem;
  StreamSubscription<ZmodemTransferResult>? _zmodemResults;

  /// The ZMODEM controller of the current session.
  @visibleForTesting
  ZmodemTransferController? get zmodem => _zmodem;

  /// Progress of the running `sz`/`rz` transfer, or null.
  final transferProgress = ValueNotifier<ZmodemProgress?>(null);

  final _transferResults = StreamController<ZmodemTransferResult>.broadcast();

  /// Finished, cancelled or failed transfers.
  Stream<ZmodemTransferResult> get transferResults => _transferResults.stream;

  /// Cancels the running transfer, if any.
  void cancelTransfer() => unawaited(_zmodem?.cancel());

  /// Font size from the shell profile.
  final double profileFontSize;

  /// Font family from the shell profile.
  final String profileFontFamily;

  /// Cursor type from the shell profile.
  final TerminalCursorType profileCursorType;

  final terminalController = TerminalController();

  Future<void> copySelection() async {
    if (_useIsolatedTerminal) return;
    final selection = terminalController.selection;
    if (selection == null) return;
    try {
      await Clipboard.setData(
        ClipboardData(text: terminal.buffer.getText(selection)),
      );
    } catch (_) {
      // Clipboard access may be unavailable while the terminal remains usable.
    }
  }

  Future<void> pasteClipboard() async {
    final activeSession = session;
    final binding = _isolateBinding.value;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text != null && identical(session, activeSession)) {
        if (_useIsolatedTerminal) {
          if (binding != null && identical(_isolateBinding.value, binding)) {
            binding.paste(text);
          }
        } else {
          terminal.paste(text);
        }
      }
    } catch (_) {
      // Local clipboard access is best effort.
    }
  }

  void selectAll() {
    if (_useIsolatedTerminal) return;
    if (terminal.buffer.lines.length == 0) return;
    terminalController.setSelection(
      terminal.buffer.createAnchor(0, 0),
      terminal.buffer.createAnchor(
        terminal.viewWidth,
        terminal.buffer.lines.length - 1,
      ),
      mode: SelectionMode.line,
    );
  }

  void setRemoteClipboardTrusted(bool trusted) {
    invalidateIsolatedClipboardContext();
    remoteClipboard.setTrusted(false);
    if (!_useIsolatedTerminal) terminal.flush();
    remoteClipboard.setTrusted(trusted);
  }

  /// Invalidates any output or OS write already pending when this scope
  /// changes. This does not grant trust or alter the user's setting.
  void invalidateIsolatedClipboardContext() {
    if (_useIsolatedTerminal) _isolateClipboardEpoch++;
  }

  int? _isolateClipboardCapability(IsolateSessionBinding binding) {
    final eligible = _isolateClipboardVisible &&
        identical(_isolateBinding.value, binding) &&
        binding.canAcceptClipboardEffects &&
        (isExperimentalClipboardTabActive?.call() ?? false) &&
        remoteClipboard.sessionActive &&
        remoteClipboard.trusted;
    if (eligible != _isolateClipboardPreviouslyEligible) {
      _isolateClipboardPreviouslyEligible = eligible;
      _isolateClipboardEpoch++;
    }
    return eligible ? _isolateClipboardEpoch : null;
  }

  void _setIsolateClipboardVisible(
      IsolateSessionBinding binding, bool visible) {
    if (!identical(_isolateBinding.value, binding)) return;
    if (_isolateClipboardVisible != visible) {
      _isolateClipboardVisible = visible;
      invalidateIsolatedClipboardContext();
    }
  }

  /// Error message from connection failure, displayed as selectable text.
  final connectionError = ValueNotifier<String?>(null);

  var terminalTitle = '';

  final _cwdSession = ValueNotifier<ExecutionSession?>(null);
  final _reportedWorkingDirectory = ValueNotifier<String?>(null);
  final _cwdQueries = Map<ExecutionSession, Future<String?>>.identity();
  int _cwdReportRevision = 0;

  ValueListenable<ExecutionSession?> get cwdSession => _cwdSession;
  ValueListenable<String?> get reportedWorkingDirectory =>
      _reportedWorkingDirectory;

  /// Publishes the shell directory from OSC 7 or a successful session query.
  void reportWorkingDirectory(String directory) {
    _cwdReportRevision++;
    _reportedWorkingDirectory.value = directory;
    _updateTitle();
  }

  ExecutionSession? get session => _cwdSession.value;

  set session(ExecutionSession? value) {
    if (identical(session, value)) return;
    _cwdReportRevision++;
    _reportedWorkingDirectory.value = null;
    _cwdSession.value = value;
  }

  /// Whether closing this terminal would kill a running program.
  ///
  /// Sessions that cannot report their foreground process (e.g. SSH) are
  /// treated as busy while open, since closing them drops the connection.
  Future<bool> isBusy() async {
    final activeSession = session;
    if (activeSession == null) return false;
    if (activeSession case final ForegroundProcessAware aware) {
      try {
        return await aware.hasForegroundProcess();
      } catch (_) {
        return true;
      }
    }
    return true;
  }

  /// Directory the shell starts in, on hosts that support choosing one.
  final String? startDirectory;

  /// The shell's current working directory as reported by the operating
  /// system, or null when the session cannot report it.
  Future<String?> liveWorkingDirectory() {
    final activeSession = session;
    if (activeSession is! WorkingDirectoryAware) {
      return Future.value(_reportedWorkingDirectory.value);
    }
    final source = activeSession!;
    final pending = _cwdQueries[source];
    if (pending != null) return pending;
    // A replacement may probe while one old SSH exec is settling. Repeated
    // reconnects must not accumulate pending execs on the shared client.
    if (_cwdQueries.length >= 2) {
      return Future.value(_reportedWorkingDirectory.value);
    }
    final query = _queryDirectory(source, _cwdReportRevision);
    _cwdQueries[source] = query;
    return query;
  }

  Future<String?> _queryDirectory(
    ExecutionSession source,
    int reportRevision,
  ) async {
    try {
      final directory = await Future<String?>.sync(
        (source as WorkingDirectoryAware).currentWorkingDirectory,
      );
      if (!identical(source, session)) return null;
      if (_cwdReportRevision != reportRevision) {
        return _reportedWorkingDirectory.value;
      }
      return directory == null || directory.isEmpty ? null : directory;
    } catch (_) {
      return null;
    } finally {
      _cwdQueries.remove(source);
    }
  }

  StreamSubscription<Uint8List>? _outputSubscription;
  int _sessionGeneration = 0;

  void _updateTitle() {
    final nextTitle = (_reportedWorkingDirectory.value ?? terminalTitle).trim();
    title.value = nextTitle.isEmpty ? 'Terminal' : nextTitle;
  }

  @override
  void didMounted() {
    _reportedWorkingDirectory.value = null;
    title.value = 'Connecting';

    if (_useIsolatedTerminal) {
      super.didMounted();
      return;
    }

    terminal.onTitleChange = (title) {
      terminalTitle = title;
      _updateTitle();
    };

    terminal.onPrivateOSC = (code, args) {
      remoteClipboard.handleOSC(code, args);
      if (code == '7' && args.isNotEmpty) {
        final workingDirectory = _workingDirectoryFromFileUri(args.first);
        if (workingDirectory != null) {
          reportWorkingDirectory(workingDirectory);
        }
      }
    };

    terminal.onOutput = (data) {
      final bytes = const Utf8Encoder().convert(data);
      if (_zmodem?.handleKeyboardInput(bytes) ?? false) return;
      session?.write(bytes);
    };

    terminal.onResize = (w, h, pw, ph) {
      session?.resize(w, h);
    };

    super.didMounted();
  }

  @override
  void didConnected() async {
    final generation = ++_sessionGeneration;
    final connectedHost = host;
    _reportedWorkingDirectory.value = null;
    title.value = 'Terminal';

    try {
      final initialWidth = _useIsolatedTerminal ? 80 : terminal.viewWidth;
      final initialHeight = _useIsolatedTerminal ? 24 : terminal.viewHeight;
      final directory = startDirectory;
      final openedSession =
          directory != null && connectedHost is DirectoryShellHost
              ? await (connectedHost as DirectoryShellHost).shellIn(
                  directory,
                  width: initialWidth,
                  height: initialHeight,
                )
              : await connectedHost.shell(
                  width: initialWidth,
                  height: initialHeight,
                );
      if (!mounted || !connected || generation != _sessionGeneration) {
        await openedSession.close();
        return;
      }
      if (_useIsolatedTerminal) {
        await _attachIsolateSession(openedSession, generation);
        return;
      }
      _attachSession(openedSession);
      if (terminal.viewWidth != initialWidth ||
          terminal.viewHeight != initialHeight) {
        unawaited(
          openedSession.resize(terminal.viewWidth, terminal.viewHeight),
        );
      }
    } catch (e) {
      if (!mounted || generation != _sessionGeneration) return;
      if (_useIsolatedTerminal) {
        onConnectionError(e);
      } else {
        terminal
            .write('\r\n\x1b[31mError: Failed to start shell: $e\x1b[0m\r\n');
      }
    }
  }

  Future<void> _attachIsolateSession(
    ExecutionSession openedSession,
    int generation,
  ) async {
    final hub = IsolateHub();
    try {
      await hub.start();
      final worker = await TerminalIsolateSession.open(
        hub,
        'terminal',
        scrollback: _scrollbackLines,
        platform: _terminalTargetPlatform(),
      );
      if (!mounted || !connected || generation != _sessionGeneration) {
        try {
          await openedSession.close();
        } finally {
          await hub.stop();
        }
        return;
      }
      late final IsolateSessionBinding binding;
      binding = IsolateSessionBinding(
        worker,
        openedSession,
        transferFiles: fileAccess,
        projectOnlyWhenVisible: true,
        clipboardCapability: () => _isolateClipboardCapability(binding),
        onClipboardWrite: (capability, text) {
          remoteClipboard.writeValidated(
            text,
            stillEligible: () =>
                _isolateClipboardCapability(binding) == capability,
          );
        },
        onClosed: (error) {
          if (!identical(_isolateBinding.value, binding)) return;
          if (error != null) {
            onConnectionError(error);
            unawaited(_closeIsolateSession().catchError((Object _) {}));
          } else if (mounted) {
            manager.remove(this);
          }
        },
      );
      _isolateHub = hub;
      _isolateClipboardVisible = false;
      invalidateIsolatedClipboardContext();
      remoteClipboard.startSession();
      session = openedSession;
      _isolateBinding.value = binding;
      if (binding.zmodem case final transfer?) _observeZmodem(transfer);
      binding.start();
    } catch (_) {
      if (identical(_isolateHub, hub)) {
        await _closeIsolateSession().catchError((Object _) {});
      } else {
        try {
          await openedSession.close();
        } finally {
          await hub.stop();
        }
      }
      rethrow;
    }
  }

  Future<void> _closeIsolateSession() async {
    final binding = _isolateBinding.value;
    final hub = _isolateHub;
    _isolateClipboardVisible = false;
    invalidateIsolatedClipboardContext();
    remoteClipboard.endSession();
    _isolateBinding.value = null;
    _zmodem = null;
    transferProgress.value = null;
    final results = _zmodemResults;
    _zmodemResults = null;
    unawaited(results?.cancel());
    _isolateHub = null;
    session = null;
    try {
      await binding?.close();
    } finally {
      await hub?.stop();
    }
  }

  /// Runs [debugAttachSession]'s wiring for a freshly opened session.
  void _attachSession(ExecutionSession openedSession) {
    remoteClipboard.endSession();
    terminal.resetInput();
    session = openedSession;
    remoteClipboard.startSession();
    final decoder = const Utf8Decoder(allowMalformed: true)
        .startChunkedConversion(_TerminalTextSink((text) {
      if (identical(session, openedSession)) terminal.write(text);
    }));
    final zmodem = ZmodemTransferController(
      onTerminalOutput: decoder.add,
      writeToSession: openedSession.write,
      files: fileAccess,
      supported: kIsWeb ||
          (defaultTargetPlatform != TargetPlatform.iOS &&
              defaultTargetPlatform != TargetPlatform.android),
    );
    _observeZmodem(zmodem);

    late final StreamSubscription<Uint8List> subscription;
    subscription = openedSession.output.listen(
      (data) {
        final pending = zmodem.handleSessionOutput(data);
        if (pending is Future<void>) {
          subscription.pause();
          pending.whenComplete(() {
            openedSession.ackRead();
            subscription.resume();
          });
        } else {
          openedSession.ackRead();
        }
      },
      onError: (Object error) {
        if (mounted && identical(session, openedSession)) {
          onConnectionError(error);
        }
      },
    );
    _outputSubscription = subscription;

    openedSession.exitCode.then((code) {
      if (!identical(session, openedSession)) return;
      remoteClipboard.endSession();
      session = null;
      unawaited(_outputSubscription?.cancel());
      _outputSubscription = null;
      _disposeZmodem();
      if (mounted) {
        manager.remove(this);
      }
    }, onError: (Object error) {
      if (mounted && identical(session, openedSession)) {
        onConnectionError(error);
      }
    });
  }

  /// Wires [openedSession] like a real connection, for tests.
  @visibleForTesting
  void debugAttachSession(ExecutionSession openedSession) =>
      _attachSession(openedSession);

  void _observeZmodem(ZmodemTransferController zmodem) {
    _zmodem = zmodem;
    zmodem.progress.addListener(() {
      if (identical(_zmodem, zmodem)) {
        transferProgress.value = zmodem.progress.value;
      }
    });
    _zmodemResults = zmodem.results.listen((result) {
      if (!_useIsolatedTerminal || identical(_zmodem, zmodem)) {
        _transferResults.add(result);
      }
    });
  }

  void _disposeZmodem() {
    final zmodem = _zmodem;
    final results = _zmodemResults;
    _zmodem = null;
    _zmodemResults = null;
    transferProgress.value = null;
    if (zmodem == null) return;
    // Keep forwarding until disposed, so a final "cancelled" result arrives.
    unawaited(zmodem.dispose().whenComplete(() => results?.cancel()));
  }

  @override
  Future<void> closeForAppExit() async {
    _sessionGeneration++;
    if (_useIsolatedTerminal) {
      await _closeIsolateSession();
      return;
    }
    remoteClipboard.endSession();
    final activeSession = session;
    session = null;
    await _outputSubscription?.cancel();
    _outputSubscription = null;
    final zmodem = _zmodem;
    _zmodem = null;
    await zmodem?.dispose();
    await _zmodemResults?.cancel();
    _zmodemResults = null;
    await activeSession?.close();
  }

  void _closeSession() {
    _sessionGeneration++;
    if (_useIsolatedTerminal) {
      unawaited(_closeIsolateSession().catchError((Object _) {}));
      return;
    }
    remoteClipboard.endSession();
    final activeSession = session;
    session = null;
    unawaited(_outputSubscription?.cancel());
    _outputSubscription = null;
    _disposeZmodem();
    unawaited(activeSession?.close());
  }

  @override
  void didUnmounted() {
    _closeSession();
    if (!_useIsolatedTerminal) terminal.dispose();
  }

  @override
  void didDisconnected() {
    _closeSession();
    _reportedWorkingDirectory.value = null;
    title.value = 'Disconnected';
  }

  @override
  void onConnectionStatus(HostConnectorStatus status) {
    switch (status) {
      case HostConnectorStatus.connecting:
        _reportedWorkingDirectory.value = null;
        title.value = 'Connecting';
        break;
      case HostConnectorStatus.connected:
        _reportedWorkingDirectory.value = null;
        title.value = 'Terminal';
        break;
      case HostConnectorStatus.disconnected:
        _reportedWorkingDirectory.value = null;
        title.value = 'Disconnected';
        break;
      default:
    }
  }

  @override
  void onConnectionError(Object error) {
    _reportedWorkingDirectory.value = null;
    title.value = 'Connection Failed';
    connectionError.value = '$error';
  }

  @override
  Widget build(BuildContext context) {
    if (!_useIsolatedTerminal) return TerminalTabView(this);
    return ValueListenableBuilder(
      valueListenable: _isolateBinding,
      builder: (context, binding, _) {
        if (binding == null) {
          return ValueListenableBuilder(
            valueListenable: connectionError,
            builder: (context, error, _) => error == null
                ? const SizedBox.expand()
                : Center(child: Text(error)),
          );
        }
        final shortcuts = TerminalShortcutHandler.of(context);
        final view = TerminalIsolateView(
          key: ObjectKey(binding),
          snapshot: binding.snapshot,
          onKey: binding.key,
          onText: binding.text,
          onResize: binding.resize,
          onShortcut: shortcuts?.onKeyEvent,
          focusRequests: shortcuts?.focusNotifier,
          onPaste: binding.paste,
          onScrollRows: binding.scrollRows,
          onBeginSelection: binding.beginSelection,
          onMouse: binding.mouse,
          onProjectionVisibility: binding.setProjectionVisible,
          onClipboardVisibility: (visible) =>
              _setIsolateClipboardVisible(binding, visible),
          onEndSelection: binding.endSelection,
          onCopySelection: binding.copySelection,
          textStyle: TerminalStyle(
            fontSize: profileFontSize,
            fontFamily: profileFontFamily,
          ),
          cursorType: profileCursorType,
        );
        return _IsolateTransferPresentation(
          key: ObjectKey(binding),
          plugin: this,
          binding: binding,
          child: view,
        );
      },
    );
  }

  String? _workingDirectoryFromFileUri(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'file' || uri.path.isEmpty) {
      return null;
    }
    return Uri.decodeComponent(uri.path);
  }
}

void _showTerminalTransferResult(
    BuildContext context, TerminalPlugin plugin, ZmodemTransferResult result) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final l10n = context.l10n;
  final files = plugin.fileAccess;
  final (String message, String? reveal) = switch (result) {
    ZmodemDownloadCompleted(:final paths) when paths.length == 1 => (
        l10n.zmodemSavedTo(paths.single),
        paths.single,
      ),
    ZmodemDownloadCompleted(:final paths) => (
        l10n.zmodemSavedFiles(paths.length, p.dirname(paths.first)),
        p.dirname(paths.first),
      ),
    ZmodemUploadCompleted(:final count, :final skipped) => (
        [
          if (count > 0) l10n.zmodemUploaded(count),
          if (skipped.isNotEmpty)
            l10n.zmodemSkippedExisting(skipped.length, skipped.first),
        ].join(' · '),
        null,
      ),
    ZmodemTransferCancelled() => (l10n.zmodemCancelled, null),
    ZmodemTransferFailed(:final reason) => (l10n.zmodemFailed(reason), null),
  };
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      action: reveal == null
          ? null
          : SnackBarAction(
              label: l10n.zmodemShowInFinder,
              onPressed: () => unawaited(files.reveal(reveal)),
            ),
    ),
  );
}

class _IsolateTransferPresentation extends StatefulWidget {
  const _IsolateTransferPresentation({
    super.key,
    required this.plugin,
    required this.binding,
    required this.child,
  });

  final TerminalPlugin plugin;
  final IsolateSessionBinding binding;
  final Widget child;

  @override
  State<_IsolateTransferPresentation> createState() =>
      _IsolateTransferPresentationState();
}

class _IsolateTransferPresentationState
    extends State<_IsolateTransferPresentation> {
  StreamSubscription<ZmodemTransferResult>? _results;

  @override
  void initState() {
    super.initState();
    _results = widget.binding.zmodem?.results.listen((result) {
      if (mounted &&
          identical(widget.plugin._isolateBinding.value, widget.binding) &&
          (ModalRoute.isCurrentOf(context) ?? true)) {
        _showTerminalTransferResult(context, widget.plugin, result);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_results?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ValueListenableBuilder<ZmodemProgress?>(
            valueListenable: widget.plugin.transferProgress,
            builder: (context, progress, _) {
              if (progress == null) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ZmodemProgressPanel(
                      progress: progress,
                      onCancel: widget.plugin.cancelTransfer,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
}

class TerminalTabView extends StatefulWidget {
  const TerminalTabView(this.plugin, {super.key});

  final TerminalPlugin plugin;

  @override
  State<StatefulWidget> createState() => _TerminalTabViewState();
}

class _TerminalTabViewState extends State<TerminalTabView>
    with WidgetsBindingObserver {
  final _terminalFocusNode = FocusNode(debugLabel: 'TerminalViewFocus');
  ValueNotifier<int>? _focusNotifier;
  bool _keyboardVisible = false;
  bool _ctrlPressed = false;
  bool _altPressed = false;

  StreamSubscription<ZmodemTransferResult>? _transferResults;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _terminalFocusNode.addListener(_onTerminalFocusChanged);
    _listenTransferResults();
  }

  void _listenTransferResults() {
    unawaited(_transferResults?.cancel());
    _transferResults =
        widget.plugin.transferResults.listen(_showTransferResult);
  }

  void _showTransferResult(ZmodemTransferResult result) {
    if (mounted) _showTerminalTransferResult(context, widget.plugin, result);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _keyboardVisible = View.of(context).viewInsets.bottom > 0;
    final newNotifier = TerminalShortcutHandler.of(context)?.focusNotifier;
    if (newNotifier != _focusNotifier) {
      _focusNotifier?.removeListener(_onFocusRequested);
      _focusNotifier = newNotifier;
      _focusNotifier?.addListener(_onFocusRequested);
    }
  }

  @override
  void didUpdateWidget(TerminalTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plugin != oldWidget.plugin) {
      _ctrlPressed = false;
      _altPressed = false;
      _listenTransferResults();
    }
  }

  @override
  void didChangeMetrics() {
    final visible = View.of(context).viewInsets.bottom > 0;
    if (visible == _keyboardVisible) return;
    setState(() {
      _keyboardVisible = visible;
      if (!visible) {
        _ctrlPressed = false;
        _altPressed = false;
      }
    });
  }

  void _onTerminalFocusChanged() {
    if (!mounted) return;
    setState(() {
      if (!_terminalFocusNode.hasFocus) {
        _ctrlPressed = false;
        _altPressed = false;
      }
    });
  }

  void _clearModifiers() {
    if (!_ctrlPressed && !_altPressed) return;
    setState(() {
      _ctrlPressed = false;
      _altPressed = false;
    });
  }

  void _sendKey(TerminalKey key) {
    widget.plugin.terminal.keyInput(
      key,
      ctrl: _ctrlPressed || HardwareKeyboard.instance.isControlPressed,
      alt: _altPressed || HardwareKeyboard.instance.isAltPressed,
      shift: HardwareKeyboard.instance.isShiftPressed,
    );
    _clearModifiers();
  }

  void _sendText(String text) {
    if (!_onTextInput(text)) {
      widget.plugin.terminal.textInput(text);
    }
  }

  void _hideKeyboard() {
    _clearModifiers();
    _terminalFocusNode.unfocus();
  }

  bool _onKeyInput(TerminalKey key) {
    if (!_ctrlPressed && !_altPressed) return false;
    _sendKey(key);
    return true;
  }

  bool _onTextInput(String text) {
    if (!_ctrlPressed && !_altPressed) return false;
    final ctrl = _ctrlPressed;
    final alt = _altPressed;
    _clearModifiers();

    if (text.length != 1 || text.codeUnitAt(0) > 0x7f) {
      widget.plugin.terminal.textInput(text);
      return true;
    }

    var code = text.codeUnitAt(0);
    if (ctrl) {
      if (code == 0x20 || (code >= 0x40 && code <= 0x7e)) {
        code &= 0x1f;
      } else if (code == 0x3f) {
        code = 0x7f;
      }
    }
    final input = String.fromCharCode(code);
    widget.plugin.terminal.textInput(alt ? '\x1b$input' : input);
    return true;
  }

  void _onFocusRequested() {
    if (mounted) {
      _terminalFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNotifier?.removeListener(_onFocusRequested);
    _terminalFocusNode.removeListener(_onTerminalFocusChanged);
    _terminalFocusNode.dispose();
    unawaited(_transferResults?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showExtraKeys = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) &&
        _keyboardVisible &&
        _terminalFocusNode.hasFocus;
    return CupertinoPageScaffold(
      key: ValueKey(widget.plugin),
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ClipRect(
                    child: TerminalView(
                      widget.plugin.terminal,
                      controller: widget.plugin.terminalController,
                      focusNode: _terminalFocusNode,
                      onKeyEvent:
                          TerminalShortcutHandler.of(context)?.onKeyEvent,
                      onTextInput: _onTextInput,
                      onKeyInput: _onKeyInput,
                      deleteDetection: !kIsWeb &&
                          defaultTargetPlatform == TargetPlatform.iOS,
                      onSecondaryTapDown: (_, __) => showMenu(),
                      backgroundOpacity: 0.8,
                      autofocus: true,
                      cursorType: widget.plugin.profileCursorType,
                      macOptionKeyBehavior: _selectMacOptionKeyBehavior(
                        context,
                      ),
                      textStyle: TerminalStyle(
                        fontSize: widget.plugin.profileFontSize,
                        fontFamily: widget.plugin.profileFontFamily,
                      ),
                    ),
                  ),
                ),
                if (showExtraKeys)
                  TerminalExtraKeys(
                    ctrlPressed: _ctrlPressed,
                    altPressed: _altPressed,
                    onToggleCtrl: () => setState(() {
                      _ctrlPressed = !_ctrlPressed;
                    }),
                    onToggleAlt: () => setState(() {
                      _altPressed = !_altPressed;
                    }),
                    onKey: _sendKey,
                    onText: _sendText,
                    onHideKeyboard: _hideKeyboard,
                  ),
              ],
            ),
            ValueListenableBuilder<String?>(
              valueListenable: widget.plugin.connectionError,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();
                return _ConnectionErrorOverlay(
                  error: error,
                  onDismiss: () {
                    widget.plugin.connectionError.value = null;
                  },
                  onRetry: () {
                    widget.plugin.connectionError.value = null;
                    if (widget.plugin.mounted) {
                      unawaited(widget.plugin.manager.connect());
                    }
                  },
                );
              },
            ),
            ValueListenableBuilder<ZmodemProgress?>(
              valueListenable: widget.plugin.transferProgress,
              builder: (context, progress, _) {
                if (progress == null) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ZmodemProgressPanel(
                        progress: progress,
                        onCancel: widget.plugin.cancelTransfer,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showMenu() {
    final menu = TerminalContextMenu(plugin: widget.plugin);
    context.contextMenuOverlay.show(menu);
  }
}

class _ConnectionErrorOverlay extends StatelessWidget {
  const _ConnectionErrorOverlay({
    required this.error,
    required this.onDismiss,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onDismiss;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Connection Failed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

TerminalTargetPlatform _terminalTargetPlatform() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
    return TerminalTargetPlatform.macos;
  }
  return TerminalTargetPlatform.unknown;
}

MacOptionKeyBehavior _selectMacOptionKeyBehavior(BuildContext context) {
  return context.select<TerminalSettingsBloc?, MacOptionKeyBehavior>(
    (TerminalSettingsBloc? bloc) {
      final state = bloc?.state;
      final behavior = state is TerminalSettingsLoaded
          ? state.optionKeyBehavior
          : kTerminalDefaultOptionKeyBehavior;
      switch (behavior) {
        case TerminalOptionKeyBehavior.leftMeta:
          return MacOptionKeyBehavior.leftMeta;
        case TerminalOptionKeyBehavior.bothMeta:
          return MacOptionKeyBehavior.bothMeta;
        case TerminalOptionKeyBehavior.normal:
          return MacOptionKeyBehavior.normal;
      }
    },
  );
}

/// Forwards decoded text to the terminal.
class _TerminalTextSink implements Sink<String> {
  _TerminalTextSink(this._write);

  final void Function(String text) _write;

  @override
  void add(String data) {
    if (data.isNotEmpty) _write(data);
  }

  @override
  void close() {}
}
