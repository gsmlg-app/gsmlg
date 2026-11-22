import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';

/// Mock implementation of VaultRepository for testing.
class MockVaultRepository implements VaultRepository {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.from(_storage);
  }

  /// Pre-populate storage for testing
  void seed(Map<String, String> data) {
    _storage.addAll(data);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('remote clipboard policy', () {
    test(
      'defaults to enabled and preserves explicit choices across reloads',
      () async {
        final vault = MockVaultRepository();
        final bloc = TerminalSettingsBloc(vault: vault);
        addTearDown(bloc.close);
        bloc.add(const TerminalSettingsLoad());
        var loaded = await bloc.stream
            .where((state) => state is TerminalSettingsLoaded)
            .cast<TerminalSettingsLoaded>()
            .first;
        expect(loaded.allowRemoteClipboardWrites, isTrue);

        bloc.add(const TerminalSettingsUpdateRemoteClipboard(allowed: false));
        loaded = await bloc.stream
            .where((state) => state is TerminalSettingsLoaded)
            .cast<TerminalSettingsLoaded>()
            .first;
        expect(loaded.allowRemoteClipboardWrites, isFalse);
        expect(await vault.readAll(), isEmpty);

        bloc.add(const TerminalSettingsLoad());
        loaded = await bloc.stream
            .where((state) => state is TerminalSettingsLoaded)
            .cast<TerminalSettingsLoaded>()
            .first;
        expect(loaded.allowRemoteClipboardWrites, isFalse);

        bloc.add(const TerminalSettingsUpdateRemoteClipboard(allowed: true));
        loaded = await bloc.stream
            .where((state) => state is TerminalSettingsLoaded)
            .cast<TerminalSettingsLoaded>()
            .first;
        expect(loaded.allowRemoteClipboardWrites, isTrue);
        bloc.add(const TerminalSettingsLoad());
        loaded = await bloc.stream
            .where((state) => state is TerminalSettingsLoaded)
            .cast<TerminalSettingsLoaded>()
            .first;
        expect(loaded.allowRemoteClipboardWrites, isTrue);
      },
    );

    test('unknown stored values fail closed', () async {
      SharedPreferences.setMockInitialValues({
        'terminal_allow_remote_clipboard_writes': 'unexpected',
      });
      final bloc = TerminalSettingsBloc(vault: MockVaultRepository());
      addTearDown(bloc.close);
      bloc.add(const TerminalSettingsLoad());
      final state = await bloc.stream
          .where((state) => state is TerminalSettingsLoaded)
          .cast<TerminalSettingsLoaded>()
          .first;
      expect(state.allowRemoteClipboardWrites, isFalse);
    });
  });
  group('TerminalSettingsBloc', () {
    late MockVaultRepository mockVault;

    setUp(() {
      mockVault = MockVaultRepository();
    });

    test('initial state is TerminalSettingsInitial', () {
      final bloc = TerminalSettingsBloc(vault: mockVault);
      expect(bloc.state, isA<TerminalSettingsInitial>());
    });

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'emits [Loading, Loaded] when Load event is added with empty storage',
      build: () => TerminalSettingsBloc(vault: mockVault),
      act: (bloc) => bloc.add(TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          isEmpty,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'emits Loaded with stored env vars when Load event is added',
      build: () {
        mockVault.seed({
          'terminal_env_PATH': '/usr/bin',
          'terminal_env_HOME': '/home/user',
        });
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          {'PATH': '/usr/bin', 'HOME': '/home/user'},
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateEnvVar adds new environment variable',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        TerminalSettingsUpdateEnvVar(key: 'API_KEY', value: 'secret123'),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          {'API_KEY': 'secret123'},
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateEnvVar removes variable when value is empty',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(
        environmentVariables: {'API_KEY': 'secret123'},
      ),
      act: (bloc) =>
          bloc.add(TerminalSettingsUpdateEnvVar(key: 'API_KEY', value: '')),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          isEmpty,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'RemoveEnvVar removes specified variable',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(
        environmentVariables: {'API_KEY': 'secret', 'OTHER': 'value'},
      ),
      act: (bloc) => bloc.add(TerminalSettingsRemoveEnvVar(key: 'API_KEY')),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          {'OTHER': 'value'},
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'ClearEnvVars removes all environment variables',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(
        environmentVariables: {'VAR1': 'a', 'VAR2': 'b', 'VAR3': 'c'},
      ),
      act: (bloc) => bloc.add(TerminalSettingsClearEnvVars()),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          isEmpty,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'does not update when state is not Loaded',
      build: () => TerminalSettingsBloc(vault: mockVault),
      // Initial state is TerminalSettingsInitial
      act: (bloc) => bloc.add(
        TerminalSettingsUpdateDownloadDirectory(downloadDirectory: '/tmp/20'),
      ),
      expect: () => [], // No state changes expected
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load defaults optionKeyBehavior to leftMeta',
      build: () => TerminalSettingsBloc(vault: mockVault),
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.optionKeyBehavior,
          'optionKeyBehavior',
          TerminalOptionKeyBehavior.leftMeta,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load restores persisted optionKeyBehavior',
      build: () {
        mockVault.seed({'terminal_option_key_behavior': 'bothMeta'});
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.optionKeyBehavior,
          'optionKeyBehavior',
          TerminalOptionKeyBehavior.bothMeta,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load falls back to leftMeta for unknown persisted value',
      build: () {
        mockVault.seed({'terminal_option_key_behavior': 'bogus'});
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.optionKeyBehavior,
          'optionKeyBehavior',
          TerminalOptionKeyBehavior.leftMeta,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateOptionKeyBehavior updates and persists the setting',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateOptionKeyBehavior(
          optionKeyBehavior: TerminalOptionKeyBehavior.normal,
        ),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.optionKeyBehavior,
          'optionKeyBehavior',
          TerminalOptionKeyBehavior.normal,
        ),
      ],
      verify: (_) async {
        expect(
          (await SharedPreferences.getInstance()).getString(
            'terminal_option_key_behavior',
          ),
          'normal',
        );
      },
    );
  });

  group('download settings', () {
    late MockVaultRepository mockVault;

    setUp(() => mockVault = MockVaultRepository());

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load defaults to saving into the system Downloads folder',
      build: () => TerminalSettingsBloc(vault: mockVault),
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>()
            .having(
              (s) => s.downloadMode,
              'downloadMode',
              TerminalDownloadMode.saveToFolder,
            )
            .having((s) => s.downloadDirectory, 'downloadDirectory', isNull),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'loads download mode and directory from vault',
      build: () {
        mockVault.seed({
          'terminal_download_mode': 'ask',
          'terminal_download_directory': '/Users/me/Transfers',
        });
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>()
            .having(
              (s) => s.downloadMode,
              'downloadMode',
              TerminalDownloadMode.ask,
            )
            .having(
              (s) => s.downloadDirectory,
              'downloadDirectory',
              '/Users/me/Transfers',
            ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateDownloadMode persists terminal_download_mode',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateDownloadMode(
          downloadMode: TerminalDownloadMode.ask,
        ),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.downloadMode,
          'downloadMode',
          TerminalDownloadMode.ask,
        ),
      ],
      verify: (_) async {
        expect(
          (await SharedPreferences.getInstance()).getString(
            'terminal_download_mode',
          ),
          'ask',
        );
      },
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateDownloadDirectory persists the folder',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateDownloadDirectory(
          downloadDirectory: '/tmp/dl',
        ),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.downloadDirectory,
          'downloadDirectory',
          '/tmp/dl',
        ),
      ],
      verify: (_) async {
        expect(
          (await SharedPreferences.getInstance()).getString(
            'terminal_download_directory',
          ),
          '/tmp/dl',
        );
      },
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateDownloadDirectory(null) deletes the key',
      build: () {
        mockVault.seed({'terminal_download_directory': '/tmp/dl'});
        return TerminalSettingsBloc(vault: mockVault);
      },
      seed: () => const TerminalSettingsLoaded(downloadDirectory: '/tmp/dl'),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateDownloadDirectory(downloadDirectory: null),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.downloadDirectory,
          'downloadDirectory',
          isNull,
        ),
      ],
      verify: (_) async {
        expect(
          (await SharedPreferences.getInstance()).getString(
            'terminal_download_directory',
          ),
          '',
        );
      },
    );
  });

  group('TerminalSettingsState', () {
    test('TerminalSettingsLoaded has default values', () {
      const state = TerminalSettingsLoaded();

      expect(state.environmentVariables, isEmpty);
    });

    test('TerminalSettingsLoaded copyWith creates new instance', () {
      const original = TerminalSettingsLoaded(
        environmentVariables: {'KEY': 'value'},
        downloadDirectory: '/tmp/15',
      );

      final copied = original.copyWith(downloadDirectory: '/tmp/20');

      expect(copied.downloadDirectory, equals('/tmp/20'));
      expect(
        copied.environmentVariables,
        equals(original.environmentVariables),
      );
    });

    test('TerminalSettingsLoaded equality works correctly', () {
      const state1 = TerminalSettingsLoaded(downloadDirectory: '/tmp/10');
      const state2 = TerminalSettingsLoaded(downloadDirectory: '/tmp/10');
      const state3 = TerminalSettingsLoaded(downloadDirectory: '/tmp/20');

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}
