import 'package:bloc_test/bloc_test.dart';
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
        isA<TerminalSettingsLoaded>()
            .having(
              (s) => s.environmentVariables,
              'environmentVariables',
              isEmpty,
            )
            .having(
              (s) => s.maxOpenShells,
              'maxOpenShells',
              kTerminalDefaultMaxOpenShells,
            )
            .having((s) => s.restoreTerminalTabs, 'restoreTerminalTabs', false),
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
      'emits Loaded with stored settings when Load event is added',
      build: () {
        mockVault.seed({
          'terminal_max_open_shells': '25',
          'terminal_restore_tabs': 'true',
        });
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>()
            .having((s) => s.maxOpenShells, 'maxOpenShells', 25)
            .having((s) => s.restoreTerminalTabs, 'restoreTerminalTabs', true),
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
      'UpdateMaxOpenShells updates the max shells setting',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) =>
          bloc.add(TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 20)),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.maxOpenShells,
          'maxOpenShells',
          20,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateMaxOpenShells clamps value to minimum of 1',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) =>
          bloc.add(TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 0)),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.maxOpenShells,
          'maxOpenShells',
          1,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateMaxOpenShells clamps value to maximum of 50',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) =>
          bloc.add(TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 100)),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.maxOpenShells,
          'maxOpenShells',
          50,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'does not update when state is not Loaded',
      build: () => TerminalSettingsBloc(vault: mockVault),
      // Initial state is TerminalSettingsInitial
      act: (bloc) =>
          bloc.add(TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 20)),
      expect: () => [], // No state changes expected
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateRestoreTabs updates restore tabs setting',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateRestoreTabs(restoreTerminalTabs: true),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.restoreTerminalTabs,
          'restoreTerminalTabs',
          true,
        ),
      ],
    );
  });

  group('TerminalSettingsState', () {
    test('TerminalSettingsLoaded has default values', () {
      const state = TerminalSettingsLoaded();

      expect(state.environmentVariables, isEmpty);
      expect(state.maxOpenShells, equals(kTerminalDefaultMaxOpenShells));
      expect(state.restoreTerminalTabs, isFalse);
    });

    test('TerminalSettingsLoaded copyWith creates new instance', () {
      const original = TerminalSettingsLoaded(
        environmentVariables: {'KEY': 'value'},
        maxOpenShells: 15,
      );

      final copied = original.copyWith(maxOpenShells: 20);

      expect(copied.maxOpenShells, equals(20));
      expect(
        copied.environmentVariables,
        equals(original.environmentVariables),
      );
      expect(copied.restoreTerminalTabs, isFalse);
    });

    test('TerminalSettingsLoaded equality works correctly', () {
      const state1 = TerminalSettingsLoaded(maxOpenShells: 10);
      const state2 = TerminalSettingsLoaded(maxOpenShells: 10);
      const state3 = TerminalSettingsLoaded(maxOpenShells: 20);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('Default constants', () {
    test('kTerminalDefaultMaxOpenShells is 10', () {
      expect(kTerminalDefaultMaxOpenShells, equals(10));
    });
  });
}
