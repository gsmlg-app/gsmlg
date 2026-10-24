import 'dart:async';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_editor/app_editor.dart';
import 'package:app_locale/app_locale.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart' as dm;
import 'package:editor_bloc/editor_bloc.dart' as editor;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/toolbox_screen.dart';

class EditorScreen extends StatefulWidget {
  static const name = 'Editor';
  static const path = 'editor';

  const EditorScreen({super.key});

  static final _confirming = Expando<Completer<bool>>();

  static Future<bool> confirmExit(BuildContext context) =>
      _confirmChanges(context, discard: true);

  static Future<bool> _confirmChanges(
    BuildContext context, {
    bool discard = false,
  }) async {
    final cubit = context.read<editor.EditorCubit>();
    if (cubit.state.busy || _confirming[cubit] != null) return false;
    final confirmation = Completer<bool>();
    _confirming[cubit] = confirmation;
    var acceptedExit = false;
    try {
      if (!cubit.state.isDirty) {
        acceptedExit = discard;
        return true;
      }
      final l10n = context.l10n;
      final choice = await showDialog<_UnsavedChoice>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.editorConfirmTitle),
          content: Text(l10n.editorConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _UnsavedChoice.cancel),
              child: Text(l10n.editorCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _UnsavedChoice.discard),
              child: Text(l10n.editorDiscard),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, _UnsavedChoice.save),
              child: Text(l10n.editorSave),
            ),
          ],
        ),
      );
      if (choice == _UnsavedChoice.save) {
        final saved = await cubit.save();
        acceptedExit = discard && saved;
        return saved;
      }
      if (choice == _UnsavedChoice.discard) {
        // Open retains the old document until its picker and read succeed.
        if (discard) cubit.discardChanges();
        acceptedExit = discard;
        return true;
      }
      return false;
    } finally {
      // An accepted exit remains marked until the route actually unmounts.
      if (!acceptedExit) _confirming[cubit] = null;
      confirmation.complete(acceptedExit);
    }
  }

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

enum _UnsavedChoice { save, discard, cancel }

class _EditorScreenState extends State<EditorScreen> {
  late final editor.EditorCubit _cubit;
  late final EditorFileService _files;
  late dm.EditorViewController _controller;
  StreamSubscription<void>? _openRequests;
  GoRouter? _router;
  bool _working = false;
  bool _draining = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<editor.EditorCubit>();
    if (EditorScreen._confirming[_cubit]?.isCompleted ?? false) {
      EditorScreen._confirming[_cubit] = null;
    }
    _files = context.read<EditorFileService>();
    _controller = _newController(_cubit.state.text);
    _openRequests = _files.openRequests.listen((_) => _drainPendingFiles());
    WidgetsBinding.instance.addPostFrameCallback((_) => _drainPendingFiles());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (_router == router) return;
    _router?.routerDelegate.removeListener(_routeChanged);
    _router = router;
    router.routerDelegate.addListener(_routeChanged);
  }

  void _routeChanged() {
    final router = _router!;
    if (!_files.hasPendingFiles ||
        router.routerDelegate.currentConfiguration.uri.path ==
            router.namedLocation(EditorScreen.name)) {
      return;
    }
    // Delegate notifications mean the exit committed. Re-enter only after the
    // old route has been removed, leaving its queued files for the new screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_files.hasPendingFiles &&
          router.routerDelegate.currentConfiguration.uri.path !=
              router.namedLocation(EditorScreen.name)) {
        router.goNamed(EditorScreen.name);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  dm.EditorViewController _newController(String text) =>
      dm.EditorViewController(text: text, extensions: [dm.historyExtension()]);

  void _syncDocument(editor.EditorState state, {bool resetHistory = false}) {
    if (!resetHistory && _controller.text == state.text) return;
    final previous = _controller;
    setState(() => _controller = _newController(state.text));
    WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_working || _cubit.state.busy) return;
    setState(() => _working = true);
    try {
      await operation();
    } finally {
      if (mounted) {
        setState(() => _working = false);
        unawaited(_drainPendingFiles());
      }
    }
  }

  Future<void> _drainPendingFiles() async {
    if (!mounted || _working || _draining || !_files.hasPendingFiles) return;
    _draining = true;
    try {
      while (_files.hasPendingFiles) {
        // A route/app exit owns its confirmation, including any pending save.
        // Keep incoming requests queued until that decision has finished.
        final confirmation = EditorScreen._confirming[_cubit];
        if (confirmation != null && await confirmation.future) return;
        if (!mounted) return;
        if (EditorScreen._confirming[_cubit] != null) continue;
        if (_working || _cubit.state.busy) return;
        final uri = _files.takePendingFile();
        if (uri == null) break;
        await _run(() async {
          if (await EditorScreen._confirmChanges(context) && mounted) {
            if (await _cubit.openFile(uri) && mounted) {
              _syncDocument(_cubit.state, resetHistory: true);
            }
          }
        });
      }
    } finally {
      _draining = false;
    }
  }

  Future<void> _newDocument() => _run(() async {
    if (await EditorScreen._confirmChanges(context) && mounted) {
      _cubit.newDocument();
      _syncDocument(_cubit.state, resetHistory: true);
    }
  });

  Future<void> _openFile() => _run(() async {
    if (await EditorScreen._confirmChanges(context) && mounted) {
      if (await _cubit.openFile() && mounted) {
        _syncDocument(_cubit.state, resetHistory: true);
      }
    }
  });

  Future<void> _save() => _run(() async {
    await _cubit.save();
  });
  Future<void> _saveAs() => _run(() async {
    await _cubit.saveAs();
  });

  String? _language(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return null;
    return dm.LanguageRegistry.byExtension(
      name.substring(dot + 1).toLowerCase(),
    )?.language.name;
  }

  String _failureMessage(BuildContext context, editor.EditorFailure failure) {
    final l10n = context.l10n;
    return switch (failure) {
      editor.EditorFailure.unsupportedEncoding =>
        l10n.editorUnsupportedEncoding,
      editor.EditorFailure.binaryFile => l10n.editorBinaryFile,
      editor.EditorFailure.tooLarge => l10n.editorTooLarge,
      editor.EditorFailure.readFailed => l10n.editorReadFailed,
      editor.EditorFailure.writeFailed => l10n.editorWriteFailed,
    };
  }

  @override
  void dispose() {
    _openRequests?.cancel();
    _router?.routerDelegate.removeListener(_routeChanged);
    if (EditorScreen._confirming[_cubit]?.isCompleted ?? false) {
      EditorScreen._confirming[_cubit] = null;
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<editor.EditorCubit, editor.EditorState>(
    listener: (context, state) => _syncDocument(state),
    builder: (context, state) {
      final l10n = context.l10n;
      final disabled = _working || state.busy;
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _save,
          const SingleActivator(
            LogicalKeyboardKey.keyS,
            control: true,
            shift: true,
          ): _saveAs,
          const SingleActivator(
            LogicalKeyboardKey.keyS,
            meta: true,
            shift: true,
          ): _saveAs,
        },
        child: AppAdaptiveScaffold(
          navigationRestoreInHeader: true,
          selectedIndex: Destinations.indexOf(
            const Key(ToolboxScreen.name),
            context,
          ),
          destinations: Destinations.navs(context),
          onSelectedIndexChange: (idx) =>
              Destinations.changeHandler(idx, context),
          body: (_) => SafeArea(
            minimum: const EdgeInsets.symmetric(
              horizontal: Constants.defaultGridGap,
            ),
            child: CustomScrollView(
              slivers: [
                dm.DmNavigationHeader(
                  builder: (context, header) => SliverAppBar(
                    leading: header.leading,
                    leadingWidth: header.leadingWidth,
                    automaticallyImplyLeading: header.automaticallyImplyLeading,
                    floating: true,
                    title: Text(l10n.editorTitle),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '${state.name}${state.isDirty ? ' •' : ''}',
                          semanticsLabel:
                              '${state.name}${state.isDirty ? ', ${l10n.editorUnsaved}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Wrap(
                        children: [
                          _action(
                            l10n.editorNew,
                            Icons.note_add_outlined,
                            disabled ? null : _newDocument,
                          ),
                          _action(
                            l10n.editorOpen,
                            Icons.folder_open,
                            disabled ? null : _openFile,
                          ),
                          _action(
                            l10n.editorSave,
                            Icons.save_outlined,
                            disabled ? null : _save,
                          ),
                          _action(
                            l10n.editorSaveAs,
                            Icons.save_as_outlined,
                            disabled ? null : _saveAs,
                          ),
                          _action(
                            l10n.editorUndo,
                            Icons.undo,
                            disabled
                                ? null
                                : () {
                                    final transaction = dm.EditorCommands.undo(
                                      _controller.state,
                                    );
                                    if (transaction != null) {
                                      _controller.dispatch(transaction);
                                    }
                                  },
                          ),
                          _action(
                            l10n.editorRedo,
                            Icons.redo,
                            disabled
                                ? null
                                : () {
                                    final transaction = dm.EditorCommands.redo(
                                      _controller.state,
                                    );
                                    if (transaction != null) {
                                      _controller.dispatch(transaction);
                                    }
                                  },
                          ),
                        ],
                      ),
                      if (state.failure != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              _failureMessage(context, state.failure!),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      if (state.busy) const LinearProgressIndicator(),
                      Expanded(
                        // TODO(upstream): duskmoon-dev/flutter-duskmoon-ui#28
                        // Mobile touch editing is blocked until the editor
                        // requests the soft keyboard on initial and repeat taps.
                        // TODO(upstream): duskmoon-dev/flutter-duskmoon-ui#26
                        // WORKAROUND(upstream): duskmoon-dev/flutter-duskmoon-ui#26
                        // Detach a focused IME while file operations are busy.
                        // Remove after upgrading to an upstream dynamic readOnly
                        // fix and verifying the focused IME regression passes.
                        child: ExcludeFocus(
                          excluding: disabled,
                          child: dm.DmCodeEditor(
                            controller: _controller,
                            language: _language(state.name),
                            readOnly: disabled,
                            onChanged: _cubit.updateText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _action(String label, IconData icon, VoidCallback? onPressed) =>
      IconButton(tooltip: label, onPressed: onPressed, icon: Icon(icon));
}
