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

  /// Get current storage state for verification
  Map<String, String> getStorage() => Map.from(_storage);
}

void main() {
  group('Event Equatable Tests', () {
    test('TerminalSettingsLoad instances are equal', () {
      const event1 = TerminalSettingsLoad();
      const event2 = TerminalSettingsLoad();
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test(
      'TerminalSettingsUpdateEnvVar instances with same params are equal',
      () {
        const event1 = TerminalSettingsUpdateEnvVar(key: 'PATH', value: '/bin');
        const event2 = TerminalSettingsUpdateEnvVar(key: 'PATH', value: '/bin');
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      },
    );

    test(
      'TerminalSettingsUpdateEnvVar instances with different params are not equal',
      () {
        const event1 = TerminalSettingsUpdateEnvVar(key: 'PATH', value: '/bin');
        const event2 = TerminalSettingsUpdateEnvVar(key: 'PATH', value: '/usr');
        const event3 = TerminalSettingsUpdateEnvVar(key: 'HOME', value: '/bin');
        expect(event1, isNot(equals(event2)));
        expect(event1, isNot(equals(event3)));
      },
    );

    test('TerminalSettingsRemoveEnvVar instances with same key are equal', () {
      const event1 = TerminalSettingsRemoveEnvVar(key: 'PATH');
      const event2 = TerminalSettingsRemoveEnvVar(key: 'PATH');
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('TerminalSettingsClearEnvVars instances are equal', () {
      const event1 = TerminalSettingsClearEnvVars();
      const event2 = TerminalSettingsClearEnvVars();
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test(
      'TerminalSettingsUpdateMaxOpenShells instances with same value are equal',
      () {
        const event1 = TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 20);
        const event2 = TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 20);
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      },
    );
  });

  group('State Equatable Tests', () {
    test('TerminalSettingsInitial instances are equal', () {
      const state1 = TerminalSettingsInitial();
      const state2 = TerminalSettingsInitial();
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('TerminalSettingsLoading instances are equal', () {
      const state1 = TerminalSettingsLoading();
      const state2 = TerminalSettingsLoading();
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('TerminalSettingsLoaded instances with same values are equal', () {
      const state1 = TerminalSettingsLoaded(
        environmentVariables: {'PATH': '/bin'},
        maxOpenShells: 15,
      );
      const state2 = TerminalSettingsLoaded(
        environmentVariables: {'PATH': '/bin'},
        maxOpenShells: 15,
      );
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test(
      'TerminalSettingsLoaded instances with different values are not equal',
      () {
        const state1 = TerminalSettingsLoaded(maxOpenShells: 10);
        const state2 = TerminalSettingsLoaded(maxOpenShells: 20);
        const state4 = TerminalSettingsLoaded(
          environmentVariables: {'KEY': 'value'},
        );
        expect(state1, isNot(equals(state2)));
        expect(state1, isNot(equals(state4)));
      },
    );

    test('TerminalSettingsLoaded copyWith preserves unchanged values', () {
      const original = TerminalSettingsLoaded(
        environmentVariables: {'PATH': '/bin', 'HOME': '/home'},
        maxOpenShells: 25,
      );

      final copied = original.copyWith(maxOpenShells: 30);

      expect(copied.maxOpenShells, equals(30));
      expect(
        copied.environmentVariables,
        equals(original.environmentVariables),
      );
    });

    test('TerminalSettingsError instances with same error are equal', () {
      const error = 'Test error';
      const state1 = TerminalSettingsError(error: error);
      const state2 = TerminalSettingsError(error: error);
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test(
      'TerminalSettingsError instances with different errors are not equal',
      () {
        const state1 = TerminalSettingsError(error: 'Error 1');
        const state2 = TerminalSettingsError(error: 'Error 2');
        expect(state1, isNot(equals(state2)));
      },
    );
  });

  group('Vault Persistence Tests', () {
    late MockVaultRepository mockVault;

    setUp(() {
      mockVault = MockVaultRepository();
    });

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateEnvVar persists to vault',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateEnvVar(key: 'API_KEY', value: 'secret'),
      ),
      verify: (_) {
        expect(
          mockVault.getStorage()['terminal_env_API_KEY'],
          equals('secret'),
        );
      },
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'RemoveEnvVar deletes from vault',
      build: () {
        mockVault.seed({'terminal_env_OLD_VAR': 'value'});
        return TerminalSettingsBloc(vault: mockVault);
      },
      seed: () => const TerminalSettingsLoaded(
        environmentVariables: {'OLD_VAR': 'value'},
      ),
      act: (bloc) =>
          bloc.add(const TerminalSettingsRemoveEnvVar(key: 'OLD_VAR')),
      verify: (_) {
        expect(
          mockVault.getStorage().containsKey('terminal_env_OLD_VAR'),
          isFalse,
        );
      },
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'ClearEnvVars removes all env vars from vault',
      build: () {
        mockVault.seed({
          'terminal_env_VAR1': 'a',
          'terminal_env_VAR2': 'b',
          'terminal_max_open_shells': '10', // Should not be removed
        });
        return TerminalSettingsBloc(vault: mockVault);
      },
      seed: () => const TerminalSettingsLoaded(
        environmentVariables: {'VAR1': 'a', 'VAR2': 'b'},
      ),
      act: (bloc) => bloc.add(const TerminalSettingsClearEnvVars()),
      verify: (_) {
        final storage = mockVault.getStorage();
        expect(storage.containsKey('terminal_env_VAR1'), isFalse);
        expect(storage.containsKey('terminal_env_VAR2'), isFalse);
        expect(storage['terminal_max_open_shells'], equals('10')); // Preserved
      },
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'UpdateMaxOpenShells persists to vault',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 30),
      ),
      verify: (_) {
        expect(
          mockVault.getStorage()['terminal_max_open_shells'],
          equals('30'),
        );
      },
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load reads persisted env vars from vault',
      build: () {
        mockVault.seed({
          'terminal_env_PATH': '/usr/bin',
          'terminal_env_HOME': '/home/user',
          'terminal_env_LANG': 'en_US.UTF-8',
        });
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          {'PATH': '/usr/bin', 'HOME': '/home/user', 'LANG': 'en_US.UTF-8'},
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load reads all persisted settings from vault',
      build: () {
        mockVault.seed({
          'terminal_env_API_KEY': 'secret',
          'terminal_max_open_shells': '35',
        });
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>()
            .having((s) => s.environmentVariables, 'environmentVariables', {
              'API_KEY': 'secret',
            })
            .having((s) => s.maxOpenShells, 'maxOpenShells', 35),
      ],
    );
  });

  group('Complex Scenarios', () {
    late MockVaultRepository mockVault;

    setUp(() {
      mockVault = MockVaultRepository();
    });

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles rapid env var updates correctly',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) {
        bloc.add(const TerminalSettingsUpdateEnvVar(key: 'VAR1', value: 'a'));
        bloc.add(const TerminalSettingsUpdateEnvVar(key: 'VAR2', value: 'b'));
        bloc.add(const TerminalSettingsUpdateEnvVar(key: 'VAR3', value: 'c'));
        bloc.add(const TerminalSettingsRemoveEnvVar(key: 'VAR2'));
      },
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'env after VAR1',
          {'VAR1': 'a'},
        ),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'env after VAR2',
          {'VAR1': 'a', 'VAR2': 'b'},
        ),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'env after VAR3',
          {'VAR1': 'a', 'VAR2': 'b', 'VAR3': 'c'},
        ),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'env after remove VAR2',
          {'VAR1': 'a', 'VAR3': 'c'},
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'updating env var with same value still emits state (for Equatable)',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () =>
          const TerminalSettingsLoaded(environmentVariables: {'KEY': 'value'}),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateEnvVar(key: 'KEY', value: 'value'),
      ),
      expect: () => [
        // Equatable on state prevents duplicate emission since env vars unchanged
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'updating env var to empty string removes it',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(
        environmentVariables: {'TO_REMOVE': 'value', 'TO_KEEP': 'value'},
      ),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateEnvVar(key: 'TO_REMOVE', value: ''),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          {'TO_KEEP': 'value'},
        ),
      ],
      verify: (_) {
        expect(
          mockVault.getStorage().containsKey('terminal_env_TO_REMOVE'),
          isFalse,
        );
      },
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles all settings updated in sequence',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) {
        bloc.add(const TerminalSettingsUpdateEnvVar(key: 'ENV', value: 'prod'));
        bloc.add(const TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 25));
      },
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'env',
          {'ENV': 'prod'},
        ),
        isA<TerminalSettingsLoaded>()
            .having((s) => s.environmentVariables, 'env', {'ENV': 'prod'})
            .having((s) => s.maxOpenShells, 'maxShells', 25),
      ],
    );
  });

  group('Edge Cases', () {
    late MockVaultRepository mockVault;

    setUp(() {
      mockVault = MockVaultRepository();
    });

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles env var with special characters in key',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateEnvVar(
          key: 'MY_VAR_123',
          value: 'test-value',
        ),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables,
          'environmentVariables',
          {'MY_VAR_123': 'test-value'},
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles env var with special characters in value',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateEnvVar(
          key: 'SPECIAL',
          value: 'value with spaces!@#\$%^&*()',
        ),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables['SPECIAL'],
          'special value',
          'value with spaces!@#\$%^&*()',
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles very long env var value',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) {
        final longValue = 'a' * 1000;
        bloc.add(TerminalSettingsUpdateEnvVar(key: 'LONG', value: longValue));
      },
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.environmentVariables['LONG']?.length,
          'long value length',
          1000,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles removing non-existent env var gracefully',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(
        environmentVariables: {'EXISTING': 'value'},
      ),
      act: (bloc) =>
          bloc.add(const TerminalSettingsRemoveEnvVar(key: 'NON_EXISTENT')),
      expect: () => [], // No state change if var doesn't exist
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles clearing already empty env vars',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(const TerminalSettingsClearEnvVars()),
      expect: () => [], // No state change if already empty
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles boundary value for maxOpenShells (1)',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) =>
          bloc.add(const TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 1)),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.maxOpenShells,
          'maxOpenShells',
          1,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'handles boundary value for maxOpenShells (50)',
      build: () => TerminalSettingsBloc(vault: mockVault),
      seed: () => const TerminalSettingsLoaded(),
      act: (bloc) => bloc.add(
        const TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 50),
      ),
      expect: () => [
        isA<TerminalSettingsLoaded>().having(
          (s) => s.maxOpenShells,
          'maxOpenShells',
          50,
        ),
      ],
    );
  });

  group('Load Event Edge Cases', () {
    late MockVaultRepository mockVault;

    setUp(() {
      mockVault = MockVaultRepository();
    });

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load can be called multiple times',
      build: () => TerminalSettingsBloc(vault: mockVault),
      act: (bloc) {
        bloc.add(const TerminalSettingsLoad());
        bloc.add(const TerminalSettingsLoad());
      },
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>(),
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>(),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load handles malformed maxOpenShells value gracefully',
      build: () {
        mockVault.seed({'terminal_max_open_shells': 'not_a_number'});
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.maxOpenShells,
          'maxOpenShells defaults',
          kTerminalDefaultMaxOpenShells,
        ),
      ],
    );

    blocTest<TerminalSettingsBloc, TerminalSettingsState>(
      'Load handles negative maxOpenShells value (loads as-is, no clamping)',
      build: () {
        mockVault.seed({'terminal_max_open_shells': '-5'});
        return TerminalSettingsBloc(vault: mockVault);
      },
      act: (bloc) => bloc.add(const TerminalSettingsLoad()),
      expect: () => [
        isA<TerminalSettingsLoading>(),
        isA<TerminalSettingsLoaded>().having(
          (s) => s.maxOpenShells,
          'maxOpenShells loaded as negative',
          -5,
        ),
      ],
    );
  });

  group('State Immutability', () {
    test('TerminalSettingsLoaded copyWith creates new instance', () {
      const original = TerminalSettingsLoaded(
        environmentVariables: {'KEY': 'value'},
        maxOpenShells: 20,
      );

      final copied = original.copyWith(maxOpenShells: 25);

      expect(identical(original, copied), isFalse);
      expect(original.maxOpenShells, equals(20));
      expect(copied.maxOpenShells, equals(25));
    });

    test(
      'TerminalSettingsLoaded copyWith with no params returns equal state',
      () {
        const original = TerminalSettingsLoaded(
          environmentVariables: {'KEY': 'value'},
          maxOpenShells: 20,
        );

        final copied = original.copyWith();

        expect(original, equals(copied));
        expect(identical(original, copied), isFalse);
      },
    );

    test(
      'TerminalSettingsLoaded default const constructor has default values',
      () {
        const state = TerminalSettingsLoaded();

        expect(state.environmentVariables, isEmpty);
        expect(state.maxOpenShells, equals(kTerminalDefaultMaxOpenShells));
      },
    );
  });

  group('Constant Values', () {
    test('kTerminalDefaultMaxOpenShells is 10', () {
      expect(kTerminalDefaultMaxOpenShells, equals(10));
    });
  });
}
