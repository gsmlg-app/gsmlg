import 'package:app_editor/app_editor.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

const _unchanged = Object();

class EditorState extends Equatable {
  const EditorState({
    this.text = '',
    this.savedText = '',
    this.file,
    this.busy = false,
    this.failure,
  });

  final String text;
  final String savedText;
  final EditorFile? file;
  final bool busy;
  final EditorFailure? failure;
  bool get isDirty => text != savedText;
  String get name => file?.name ?? 'untitled.txt';

  EditorState copyWith({
    String? text,
    String? savedText,
    Object? file = _unchanged,
    bool? busy,
    Object? failure = _unchanged,
  }) => EditorState(
    text: text ?? this.text,
    savedText: savedText ?? this.savedText,
    file: identical(file, _unchanged) ? this.file : file as EditorFile?,
    busy: busy ?? this.busy,
    failure: identical(failure, _unchanged)
        ? this.failure
        : failure as EditorFailure?,
  );

  @override
  List<Object?> get props => [text, savedText, file, busy, failure];
}

class EditorCubit extends Cubit<EditorState> {
  EditorCubit(this.files) : super(const EditorState());

  final EditorFileService files;
  EditorText _format = const EditorText();

  void updateText(String text) {
    if (!state.busy && state.text != text) {
      emit(state.copyWith(text: text, failure: null));
    }
  }

  void newDocument() {
    if (state.busy) return;
    _format = const EditorText();
    emit(const EditorState());
  }

  Future<bool> openFile([String? uri]) async {
    if (state.busy) return false;
    emit(state.copyWith(busy: true, failure: null));
    try {
      final file = uri == null
          ? await files.pickFile()
          : await files.readFile(uri);
      if (isClosed) return false;
      if (file == null) {
        emit(state.copyWith(busy: false));
        return false;
      }
      final decoded = EditorText.decode(file.bytes);
      _format = decoded;
      emit(
        EditorState(text: decoded.text, savedText: decoded.text, file: file),
      );
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(busy: false, failure: _failure(error, saving: false)),
        );
      }
      return false;
    }
  }

  Future<bool> save() async {
    if (state.busy) return false;
    final file = state.file;
    if (file == null || !file.writable) return saveAs();
    if (!state.isDirty) return true;
    emit(state.copyWith(busy: true, failure: null));
    final text = state.text;
    try {
      await files.writeFile(file, _format.encode(text));
      if (isClosed) return false;
      emit(state.copyWith(savedText: text, busy: false));
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(busy: false, failure: _failure(error, saving: true)),
        );
      }
      return false;
    }
  }

  Future<bool> saveAs() async {
    if (state.busy) return false;
    emit(state.copyWith(busy: true, failure: null));
    final text = state.text;
    try {
      final file = await files.saveFileAs(state.name, _format.encode(text));
      if (isClosed) return false;
      if (file == null) {
        emit(state.copyWith(busy: false));
        return false;
      }
      emit(state.copyWith(file: file, savedText: text, busy: false));
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(busy: false, failure: _failure(error, saving: true)),
        );
      }
      return false;
    }
  }

  void discardChanges() {
    if (!state.busy) emit(state.copyWith(text: state.savedText, failure: null));
  }

  void clearError() => emit(state.copyWith(failure: null));

  EditorFailure _failure(Object error, {required bool saving}) {
    if (error is EditorFileException) return error.failure;
    if (error is PlatformException && error.code == 'too_large') {
      return EditorFailure.tooLarge;
    }
    return saving ? EditorFailure.writeFailed : EditorFailure.readFailed;
  }
}
