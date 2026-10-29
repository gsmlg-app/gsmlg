import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:app_secure_storage/app_secure_storage.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for managing terminal settings including environment variables,
/// font settings, and session limits.
///
/// Environment variables are stored securely using [VaultRepository] as they
/// may contain sensitive information like API keys and tokens.
/// Other settings are also stored in the vault for consistency.
class TerminalSettingsBloc
    extends Bloc<TerminalSettingsEvent, TerminalSettingsState> {
  /// Prefix for environment variable keys in secure storage.
  static const _envKeyPrefix = 'terminal_env_';

  /// Key for max open shells setting.
  static const _maxOpenShellsKey = 'terminal_max_open_shells';

  /// Key for restoring open terminal tabs after app restart.
  static const _restoreTabsKey = 'terminal_restore_tabs';

  final VaultRepository _vault;

  TerminalSettingsBloc({required VaultRepository vault})
    : _vault = vault,
      super(const TerminalSettingsInitial()) {
    on<TerminalSettingsLoad>(_onLoad);
    on<TerminalSettingsUpdateEnvVar>(_onUpdateEnvVar);
    on<TerminalSettingsRemoveEnvVar>(_onRemoveEnvVar);
    on<TerminalSettingsClearEnvVars>(_onClearEnvVars);
    on<TerminalSettingsUpdateMaxOpenShells>(_onUpdateMaxOpenShells);
    on<TerminalSettingsUpdateRestoreTabs>(_onUpdateRestoreTabs);
  }

  Future<void> _onLoad(
    TerminalSettingsLoad event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    emit(const TerminalSettingsLoading());

    try {
      final allSecrets = await _vault.readAll();
      final envVars = <String, String>{};

      // Filter for environment variable keys
      for (final entry in allSecrets.entries) {
        if (entry.key.startsWith(_envKeyPrefix)) {
          final envKey = entry.key.substring(_envKeyPrefix.length);
          envVars[envKey] = entry.value;
        }
      }

      // Load other settings with defaults
      final maxOpenShells =
          int.tryParse(allSecrets[_maxOpenShellsKey] ?? '') ??
          kTerminalDefaultMaxOpenShells;
      final restoreTerminalTabs = allSecrets[_restoreTabsKey] == 'true';

      emit(
        TerminalSettingsLoaded(
          environmentVariables: envVars,
          maxOpenShells: maxOpenShells,
          restoreTerminalTabs: restoreTerminalTabs,
        ),
      );
    } catch (e) {
      emit(TerminalSettingsError(error: e));
    }
  }

  Future<void> _onUpdateEnvVar(
    TerminalSettingsUpdateEnvVar event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    if (state is! TerminalSettingsLoaded) return;

    final currentState = state as TerminalSettingsLoaded;
    final newEnvVars = Map<String, String>.from(
      currentState.environmentVariables,
    );

    if (event.value.isEmpty) {
      newEnvVars.remove(event.key);
      await _vault.delete(key: '$_envKeyPrefix${event.key}');
    } else {
      newEnvVars[event.key] = event.value;
      await _vault.write(key: '$_envKeyPrefix${event.key}', value: event.value);
    }

    emit(currentState.copyWith(environmentVariables: newEnvVars));
  }

  Future<void> _onRemoveEnvVar(
    TerminalSettingsRemoveEnvVar event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    if (state is! TerminalSettingsLoaded) return;

    final currentState = state as TerminalSettingsLoaded;
    final newEnvVars = Map<String, String>.from(
      currentState.environmentVariables,
    );
    newEnvVars.remove(event.key);

    await _vault.delete(key: '$_envKeyPrefix${event.key}');
    emit(currentState.copyWith(environmentVariables: newEnvVars));
  }

  Future<void> _onClearEnvVars(
    TerminalSettingsClearEnvVars event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    if (state is! TerminalSettingsLoaded) return;

    final currentState = state as TerminalSettingsLoaded;

    // Delete all environment variable keys from vault
    for (final key in currentState.environmentVariables.keys) {
      await _vault.delete(key: '$_envKeyPrefix$key');
    }

    emit(currentState.copyWith(environmentVariables: const {}));
  }

  Future<void> _onUpdateMaxOpenShells(
    TerminalSettingsUpdateMaxOpenShells event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    if (state is! TerminalSettingsLoaded) return;

    final currentState = state as TerminalSettingsLoaded;
    final value = event.maxOpenShells.clamp(1, 50); // Reasonable limits

    emit(currentState.copyWith(maxOpenShells: value));
    try {
      await _vault.write(key: _maxOpenShellsKey, value: value.toString());
    } catch (_) {
      // Persistence failure; setting still applies for current session.
    }
  }

  Future<void> _onUpdateRestoreTabs(
    TerminalSettingsUpdateRestoreTabs event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    if (state is! TerminalSettingsLoaded) return;

    final currentState = state as TerminalSettingsLoaded;

    emit(currentState.copyWith(restoreTerminalTabs: event.restoreTerminalTabs));
    try {
      await _vault.write(
        key: _restoreTabsKey,
        value: event.restoreTerminalTabs.toString(),
      );
    } catch (_) {
      // Persistence failure; setting still applies for current session.
    }
  }
}
