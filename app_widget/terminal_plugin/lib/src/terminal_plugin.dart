import 'dart:async';
import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/src/terminal_extra_keys.dart';
import 'package:terminal_plugin/src/terminal_menu.dart';
import 'package:terminal_plugin/src/terminal_shortcut_handler.dart';
import 'package:terminal_plugin/src/zmodem/io_zmodem_file_access.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_file_access.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_progress_panel.dart';
import 'package:terminal_plugin/src/zmodem/zmodem_transfer_controller.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:xterm/xterm.dart';

class TerminalPlugin extends Plugin {
  TerminalPlugin({
    this.profileFontSize = 14.0,
    this.profileFontFamily = 'Source Code Pro',
    this.profileCursorType = TerminalCursorType.block,
    int scrollbackLines = 10000,
    ZmodemFileAccess? fileAccess,
  })  : fileAccess = fileAccess ??
            IoZmodemFileAccess(
              settings: () =>
                  (mode: ZmodemDownloadMode.saveToFolder, directory: null),
            ),
        terminal = Terminal(
          maxLines: scrollbackLines,
          batchWrites: true,
          platform: _terminalTargetPlatform(),
        );

  final Terminal terminal;

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

  /// Error message from connection failure, displayed as selectable text.
  final connectionError = ValueNotifier<String?>(null);

  var terminalTitle = '';

  String? _workingDirectoryTitle;

  ExecutionSession? session;

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

  /// The shell's current working directory as reported by the operating
  /// system, or null when the session cannot report it.
  Future<String?> liveWorkingDirectory() async {
    final activeSession = session;
    if (activeSession is! WorkingDirectoryAware) return null;
    try {
      final directory = await (activeSession as WorkingDirectoryAware)
          .currentWorkingDirectory();
      return directory == null || directory.isEmpty ? null : directory;
    } catch (_) {
      return null;
    }
  }

  StreamSubscription<Uint8List>? _outputSubscription;
  int _sessionGeneration = 0;

  void _updateTitle() {
    final nextTitle = (_workingDirectoryTitle ?? terminalTitle).trim();
    title.value = nextTitle.isEmpty ? 'Terminal' : nextTitle;
  }

  @override
  void didMounted() {
    _workingDirectoryTitle = null;
    title.value = 'Connecting';

    terminal.onTitleChange = (title) {
      terminalTitle = title;
      _updateTitle();
    };

    terminal.onPrivateOSC = (code, args) {
      if (code == '7' && args.isNotEmpty) {
        final workingDirectory = _workingDirectoryFromFileUri(args.first);
        if (workingDirectory != null) {
          _workingDirectoryTitle = workingDirectory;
          _updateTitle();
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
    _workingDirectoryTitle = null;
    title.value = 'Terminal';

    try {
      final initialWidth = terminal.viewWidth;
      final initialHeight = terminal.viewHeight;
      final openedSession = await connectedHost.shell(
        width: initialWidth,
        height: initialHeight,
      );
      if (!mounted || !connected || generation != _sessionGeneration) {
        await openedSession.close();
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
      terminal.write('\r\n\x1b[31mError: Failed to start shell: $e\x1b[0m\r\n');
    }
  }

  /// Runs [debugAttachSession]'s wiring for a freshly opened session.
  void _attachSession(ExecutionSession openedSession) {
    session = openedSession;
    final decoder = const Utf8Decoder(allowMalformed: true)
        .startChunkedConversion(_TerminalTextSink(terminal.write));
    final zmodem = ZmodemTransferController(
      onTerminalOutput: decoder.add,
      writeToSession: openedSession.write,
      files: fileAccess,
      supported: kIsWeb ||
          (defaultTargetPlatform != TargetPlatform.iOS &&
              defaultTargetPlatform != TargetPlatform.android),
    );
    _zmodem = zmodem;
    zmodem.progress.addListener(() {
      if (identical(_zmodem, zmodem)) {
        transferProgress.value = zmodem.progress.value;
      }
    });
    _zmodemResults = zmodem.results.listen(_transferResults.add);

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

  void _closeSession() {
    _sessionGeneration++;
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
    terminal.dispose();
  }

  @override
  void didDisconnected() {
    _closeSession();
    _workingDirectoryTitle = null;
    title.value = 'Disconnected';
  }

  @override
  void onConnectionStatus(HostConnectorStatus status) {
    switch (status) {
      case HostConnectorStatus.connecting:
        _workingDirectoryTitle = null;
        title.value = 'Connecting';
        break;
      case HostConnectorStatus.connected:
        _workingDirectoryTitle = null;
        title.value = 'Terminal';
        break;
      case HostConnectorStatus.disconnected:
        _workingDirectoryTitle = null;
        title.value = 'Disconnected';
        break;
      default:
    }
  }

  @override
  void onConnectionError(Object error) {
    _workingDirectoryTitle = null;
    title.value = 'Connection Failed';
    connectionError.value = '$error';
  }

  @override
  Widget build(BuildContext context) {
    return TerminalTabView(this);
  }

  String? _workingDirectoryFromFileUri(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'file' || uri.path.isEmpty) {
      return null;
    }
    return Uri.decodeComponent(uri.path);
  }
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
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final l10n = context.l10n;
    final files = widget.plugin.fileAccess;
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
