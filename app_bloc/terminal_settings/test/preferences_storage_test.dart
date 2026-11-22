import 'dart:io';
import 'package:hive_ce/hive_ce.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';

class _Vault extends Fake implements VaultRepository {
  final values = <String, String>{
    'terminal_option_key_behavior': 'bothMeta',
    'terminal_download_directory': '/legacy',
    'terminal_env_TOKEN': 'secret',
  };
  bool unavailable = false;
  @override
  Future<Map<String, String>> readAll() async {
    if (unavailable) throw StateError('Keychain unavailable');
    return Map.of(values);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'ordinary preferences migrate once and override legacy values independently of Keychain',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final vault = _Vault();
      final directory = await Directory.systemTemp.createTemp(
        'terminal-prefs-',
      );
      final configuration = await Hive.openBox<dynamic>(
        'preferences',
        path: directory.path,
      );
      addTearDown(() async {
        await configuration.close();
        await directory.delete(recursive: true);
      });
      final bloc = TerminalSettingsBloc(
        vault: vault,
        preferences: prefs,
        configuration: configuration,
      );
      addTearDown(bloc.close);
      Future<TerminalSettingsLoaded> load() async {
        final ready = bloc.stream.firstWhere(
          (s) => s is TerminalSettingsLoaded,
        );
        bloc.add(const TerminalSettingsLoad());
        return await ready as TerminalSettingsLoaded;
      }

      final migrated = await load();
      expect(migrated.optionKeyBehavior, TerminalOptionKeyBehavior.bothMeta);
      expect(configuration.get('terminal_option_key_behavior'), 'bothMeta');
      expect(
        configuration.keys.whereType<String>().any(
          (key) => key.contains('TOKEN'),
        ),
        isFalse,
      );
      expect(migrated.environmentVariables, {'TOKEN': 'secret'});
      await configuration.put('terminal_option_key_behavior', 'normal');
      await configuration.put('terminal_download_directory', '');
      final priority = await load();
      expect(priority.optionKeyBehavior, TerminalOptionKeyBehavior.normal);
      expect(priority.downloadDirectory, isNull);
      vault.unavailable = true;
      final locked = await load();
      expect(locked.optionKeyBehavior, TerminalOptionKeyBehavior.normal);
      expect(locked.secureStorageError, isNotNull);
      expect(locked.downloadDirectory, isNull);
    },
  );
}
