import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_secure_storage/app_secure_storage.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for managing terminal settings including environment variables,
/// ordinary terminal preferences.
///
/// Environment variables are stored securely using [VaultRepository] as they
/// may contain sensitive information like API keys and tokens.
/// Ordinary preferences are stored independently of credentials.
class TerminalSettingsBloc
    extends Bloc<TerminalSettingsEvent, TerminalSettingsState> {
  /// Prefix for environment variable keys in secure storage.
  static const _envKeyPrefix = 'terminal_env_';

  /// Key for the macOS Option key behavior.
  static const _optionKeyBehaviorKey = 'terminal_option_key_behavior';

  /// Keys for where `sz` downloads are saved.
  static const _downloadModeKey = 'terminal_download_mode';
  static const _downloadDirectoryKey = 'terminal_download_directory';
  static const _remoteClipboardKey = 'terminal_allow_remote_clipboard_writes';

  final VaultRepository _vault;
  final SharedPreferences? _preferences;
  final Box<dynamic>? _configuration;

  Future<SharedPreferences> get _prefs async =>
      _preferences ?? await SharedPreferences.getInstance();

  TerminalSettingsBloc({
    required VaultRepository vault,
    SharedPreferences? preferences,
    Box<dynamic>? configuration,
  }) : _configuration = configuration,
       _preferences = preferences,
       _vault = vault,
       super(const TerminalSettingsInitial()) {
    on<TerminalSettingsEvent>((event, emit) async {
      try {
        switch (event) {
          case TerminalSettingsLoad():
            await _onLoad(event, emit);
          case TerminalSettingsUpdateEnvVar():
            await _onUpdateEnvVar(event, emit);
          case TerminalSettingsRemoveEnvVar():
            await _onRemoveEnvVar(event, emit);
          case TerminalSettingsClearEnvVars():
            await _onClearEnvVars(event, emit);
          case TerminalSettingsUpdateOptionKeyBehavior():
            await _onUpdateOptionKeyBehavior(event, emit);
          case TerminalSettingsUpdateDownloadMode():
            await _onUpdateDownloadMode(event, emit);
          case TerminalSettingsUpdateDownloadDirectory():
            await _onUpdateDownloadDirectory(event, emit);
          case TerminalSettingsUpdateRemoteClipboard():
            final current = state;
            if (current is TerminalSettingsLoaded) {
              await _writePreference(_remoteClipboardKey, '${event.allowed}');
              emit(
                current.copyWith(
                  allowRemoteClipboardWrites: event.allowed,
                  clearPreferenceError: true,
                ),
              );
            }
        }
      } catch (error) {
        final current = state;
        if (current is TerminalSettingsLoaded) {
          final secret =
              event is TerminalSettingsUpdateEnvVar ||
              event is TerminalSettingsRemoveEnvVar ||
              event is TerminalSettingsClearEnvVars;
          emit(
            secret
                ? current.copyWith(secureStorageError: error)
                : current.copyWith(preferenceError: error),
          );
        }
      }
    }, transformer: (events, mapper) => events.asyncExpand(mapper));
  }

  Future<void> _writePreference(String key, String value) async {
    final configuration = _configuration;
    if (configuration == null) {
      if (!await (await _prefs).setString(key, value)) {
        throw StateError('Could not save terminal preference');
      }
    } else {
      await configuration.put(key, value);
      await configuration.flush();
    }
  }

  Future<void> _onLoad(
    TerminalSettingsLoad event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    emit(const TerminalSettingsLoading());

    try {
      final prefs = await _prefs;
      var allSecrets = <String, String>{};
      Object? secureStorageError;
      try {
        allSecrets = await _vault.readAll();
      } catch (error) {
        secureStorageError = error;
      }
      final options = <String, String?>{};
      for (final key in [
        _optionKeyBehaviorKey,
        _downloadModeKey,
        _downloadDirectoryKey,
        _remoteClipboardKey,
      ]) {
        final configuration = _configuration;
        if (configuration != null && configuration.containsKey(key)) {
          options[key] = configuration.get(key) as String?;
        } else {
          final value = prefs.containsKey(key)
              ? prefs.getString(key)
              : allSecrets[key];
          options[key] = value;
          if (value != null) await _writePreference(key, value);
        }
      }
      final envVars = <String, String>{};

      // Filter for environment variable keys
      for (final entry in allSecrets.entries) {
        if (entry.key.startsWith(_envKeyPrefix)) {
          final envKey = entry.key.substring(_envKeyPrefix.length);
          envVars[envKey] = entry.value;
        }
      }

      // Load other settings with defaults
      final optionKeyBehavior = TerminalOptionKeyBehavior.values.firstWhere(
        (TerminalOptionKeyBehavior value) =>
            value.name == options[_optionKeyBehaviorKey],
        orElse: () => kTerminalDefaultOptionKeyBehavior,
      );
      final downloadMode = TerminalDownloadMode.values.firstWhere(
        (TerminalDownloadMode value) => value.name == options[_downloadModeKey],
        orElse: () => TerminalDownloadMode.saveToFolder,
      );
      final downloadDirectory = options[_downloadDirectoryKey];

      emit(
        TerminalSettingsLoaded(
          environmentVariables: envVars,
          secureStorageError: secureStorageError,
          optionKeyBehavior: optionKeyBehavior,
          downloadMode: downloadMode,
          allowRemoteClipboardWrites: options[_remoteClipboardKey] == null
              ? kTerminalDefaultAllowRemoteClipboardWrites
              : options[_remoteClipboardKey] == 'true',
          downloadDirectory:
              downloadDirectory == null || downloadDirectory.isEmpty
              ? null
              : downloadDirectory,
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

  Future<void> _onUpdateOptionKeyBehavior(
    TerminalSettingsUpdateOptionKeyBehavior event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    final current = state;
    if (current is! TerminalSettingsLoaded) return;
    await _writePreference(_optionKeyBehaviorKey, event.optionKeyBehavior.name);
    emit(
      current.copyWith(
        optionKeyBehavior: event.optionKeyBehavior,
        clearPreferenceError: true,
      ),
    );
  }

  Future<void> _onUpdateDownloadMode(
    TerminalSettingsUpdateDownloadMode event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    final current = state;
    if (current is! TerminalSettingsLoaded) return;
    await _writePreference(_downloadModeKey, event.downloadMode.name);
    emit(
      current.copyWith(
        downloadMode: event.downloadMode,
        clearPreferenceError: true,
      ),
    );
  }

  Future<void> _onUpdateDownloadDirectory(
    TerminalSettingsUpdateDownloadDirectory event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    final current = state;
    if (current is! TerminalSettingsLoaded) return;
    final directory = event.downloadDirectory?.trim();
    final cleared = directory == null || directory.isEmpty;
    await _writePreference(_downloadDirectoryKey, cleared ? '' : directory);
    emit(
      current.copyWith(
        downloadDirectory: cleared ? null : directory,
        clearDownloadDirectory: cleared,
        clearPreferenceError: true,
      ),
    );
  }
}
