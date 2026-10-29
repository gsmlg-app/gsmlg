import 'dart:convert';
import 'dart:io' show Platform;

import 'package:app_database/app_database.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:meta/meta.dart';

/// Re-export ShellProfile, ShellType, and CursorStyleType from app_database
export 'package:app_database/app_database.dart'
    show ShellProfile, ShellType, CursorStyleType;

part 'event.dart';
part 'state.dart';

/// BLoC for managing shell profiles.
///
/// Shell profiles store configuration for local shell sessions including:
/// - Shell type (sh, bash, zsh, fish)
/// - Environment variables
/// - Alias definitions
/// - Font settings
/// - Color theme
class ShellProfileBloc extends Bloc<ShellProfileEvent, ShellProfileState> {
  final AppDatabase database;

  ShellProfileBloc(this.database) : super(const ShellProfileInitial()) {
    on<LoadShellProfiles>(_onLoad);
    on<AddShellProfile>(_onAdd);
    on<UpdateShellProfile>(_onUpdate);
    on<DeleteShellProfile>(_onDelete);
    on<SetDefaultProfile>(_onSetDefault);
    on<EnsureDefaultProfile>(_onEnsureDefault);
  }

  Future<void> _onLoad(
    LoadShellProfiles event,
    Emitter<ShellProfileState> emit,
  ) async {
    emit(const ShellProfileLoading());
    try {
      final profiles = await database.select(database.shellProfiles).get();
      emit(ShellProfileLoaded(profiles));
    } catch (e) {
      emit(ShellProfileError(e));
    }
  }

  Future<void> _onAdd(
    AddShellProfile event,
    Emitter<ShellProfileState> emit,
  ) async {
    try {
      // If this is the default profile, clear other defaults first
      if (event.isDefault) {
        await _clearDefaultProfiles();
      }

      await database.into(database.shellProfiles).insert(
            ShellProfilesCompanion.insert(
              name: event.name,
              shellType: Value(event.shellType.value),
              environmentVariables:
                  Value(jsonEncode(event.environmentVariables)),
              aliases: Value(jsonEncode(event.aliases)),
              fontFamily: Value(event.fontFamily),
              fontSize: Value(event.fontSize),
              colorTheme: Value(event.colorTheme),
              workingDirectory: Value(event.workingDirectory),
              startupCommand: Value(event.startupCommand),
              cursorStyle: Value(event.cursorStyle),
              scrollbackLines: Value(event.scrollbackLines),
              isDefault: Value(event.isDefault),
              inheritCurrentState: Value(event.inheritCurrentState),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );

      // Reload profiles
      final profiles = await database.select(database.shellProfiles).get();
      emit(ShellProfileLoaded(profiles));
    } catch (e) {
      emit(ShellProfileError(e));
    }
  }

  Future<void> _onUpdate(
    UpdateShellProfile event,
    Emitter<ShellProfileState> emit,
  ) async {
    try {
      // If setting as default, clear other defaults first
      if (event.isDefault == true) {
        await _clearDefaultProfiles();
      }

      final update = ShellProfilesCompanion(
        name: event.name != null ? Value(event.name!) : const Value.absent(),
        shellType: event.shellType != null
            ? Value(event.shellType!.value)
            : const Value.absent(),
        environmentVariables: event.environmentVariables != null
            ? Value(jsonEncode(event.environmentVariables))
            : const Value.absent(),
        aliases: event.aliases != null
            ? Value(jsonEncode(event.aliases))
            : const Value.absent(),
        fontFamily: event.fontFamily != null
            ? Value(event.fontFamily!)
            : const Value.absent(),
        fontSize: event.fontSize != null
            ? Value(event.fontSize!)
            : const Value.absent(),
        colorTheme: event.colorTheme != null
            ? Value(event.colorTheme!)
            : const Value.absent(),
        workingDirectory: event.workingDirectory != null
            ? Value(event.workingDirectory!)
            : const Value.absent(),
        startupCommand: event.startupCommand != null
            ? Value(event.startupCommand!)
            : const Value.absent(),
        cursorStyle: event.cursorStyle != null
            ? Value(event.cursorStyle!)
            : const Value.absent(),
        scrollbackLines: event.scrollbackLines != null
            ? Value(event.scrollbackLines!)
            : const Value.absent(),
        isDefault: event.isDefault != null
            ? Value(event.isDefault!)
            : const Value.absent(),
        inheritCurrentState: event.inheritCurrentState != null
            ? Value(event.inheritCurrentState!)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      await (database.update(database.shellProfiles)
            ..where((t) => t.id.equals(event.id)))
          .write(update);

      // Reload profiles
      final profiles = await database.select(database.shellProfiles).get();
      emit(ShellProfileLoaded(profiles));
    } catch (e) {
      emit(ShellProfileError(e));
    }
  }

  Future<void> _onDelete(
    DeleteShellProfile event,
    Emitter<ShellProfileState> emit,
  ) async {
    try {
      final rowsAffected = await (database.delete(database.shellProfiles)
            ..where((t) => t.id.equals(event.profile.id)))
          .go();

      if (rowsAffected == 0) {
        throw Exception('Failed to delete shell profile');
      }

      // Reload profiles
      final profiles = await database.select(database.shellProfiles).get();
      emit(ShellProfileLoaded(profiles));
    } catch (e) {
      emit(ShellProfileError(e));
    }
  }

  Future<void> _onSetDefault(
    SetDefaultProfile event,
    Emitter<ShellProfileState> emit,
  ) async {
    try {
      // Clear all other defaults
      await _clearDefaultProfiles();

      // Set the new default
      await (database.update(database.shellProfiles)
            ..where((t) => t.id.equals(event.profile.id)))
          .write(const ShellProfilesCompanion(isDefault: Value(true)));

      // Reload profiles
      final profiles = await database.select(database.shellProfiles).get();
      emit(ShellProfileLoaded(profiles));
    } catch (e) {
      emit(ShellProfileError(e));
    }
  }

  Future<void> _onEnsureDefault(
    EnsureDefaultProfile event,
    Emitter<ShellProfileState> emit,
  ) async {
    try {
      final profiles = await database.select(database.shellProfiles).get();
      if (profiles.isEmpty) {
        // Determine default shell type based on platform
        final defaultShellType =
            (!kIsWeb && Platform.isMacOS) ? ShellType.zsh : ShellType.bash;

        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Default',
                shellType: Value(defaultShellType.value),
                fontFamily: const Value('Source Code Pro'),
                fontSize: const Value(14.0),
                isDefault: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
      }
    } catch (_) {
      // Non-fatal — profile loading will still work
    }
  }

  /// Clear the isDefault flag from all profiles.
  Future<void> _clearDefaultProfiles() async {
    await database.update(database.shellProfiles).write(
          const ShellProfilesCompanion(isDefault: Value(false)),
        );
  }
}
