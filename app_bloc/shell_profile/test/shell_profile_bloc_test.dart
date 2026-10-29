import 'package:app_database/app_database.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting();
  });

  tearDown(() async {
    await database.close();
  });

  group('ShellProfileState', () {
    test('ShellProfileInitial is equatable', () {
      expect(
        const ShellProfileInitial(),
        equals(const ShellProfileInitial()),
      );
    });

    test('ShellProfileLoading is equatable', () {
      expect(
        const ShellProfileLoading(),
        equals(const ShellProfileLoading()),
      );
    });

    test('ShellProfileLoaded is equatable', () {
      expect(
        const ShellProfileLoaded([]),
        equals(const ShellProfileLoaded([])),
      );
    });

    test('ShellProfileLoaded defaultProfile returns null when no default', () {
      const state = ShellProfileLoaded([]);
      expect(state.defaultProfile, isNull);
    });

    test('ShellProfileError contains error', () {
      final error = Exception('test error');
      final state = ShellProfileError(error);
      expect(state.error, error);
    });
  });

  group('ShellProfileEvent', () {
    test('LoadShellProfiles is equatable', () {
      expect(
        const LoadShellProfiles(),
        equals(const LoadShellProfiles()),
      );
    });

    test('AddShellProfile has correct default values', () {
      const event = AddShellProfile(name: 'Test Profile');
      expect(event.name, 'Test Profile');
      expect(event.shellType, ShellType.sh);
      expect(event.environmentVariables, isEmpty);
      expect(event.aliases, isEmpty);
      expect(event.fontFamily, 'Source Code Pro');
      expect(event.fontSize, 14.0);
      expect(event.colorTheme, 'default');
      expect(event.isDefault, false);
      expect(event.inheritCurrentState, false);
    });

    test('UpdateShellProfile stores id', () {
      const event = UpdateShellProfile(id: 1, name: 'New Name');
      expect(event.id, 1);
      expect(event.name, 'New Name');
    });

    test('SetDefaultProfile stores profile', () {
      final profile = ShellProfile(
        id: 1,
        name: 'Test',
        shellType: 1,
        environmentVariables: '{}',
        aliases: '{}',
        fontFamily: 'monospace',
        fontSize: 14.0,
        colorTheme: 'default',
        workingDirectory: '',
        startupCommand: '',
        cursorStyle: 0,
        scrollbackLines: 10000,
        isDefault: false,
        inheritCurrentState: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final event = SetDefaultProfile(profile);
      expect(event.profile, profile);
    });
  });

  group('ShellProfileBloc', () {
    blocTest<ShellProfileBloc, ShellProfileState>(
      'emits [ShellProfileLoading, ShellProfileLoaded] when LoadShellProfiles is added',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const LoadShellProfiles()),
      expect: () => [
        const ShellProfileLoading(),
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles, 'profiles', isEmpty),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'emits [ShellProfileLoaded] with new profile when AddShellProfile is added',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(name: 'My Profile')),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.length,
          'profiles length',
          1,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'adds profile with custom settings',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Custom Profile',
        shellType: ShellType.bash,
        environmentVariables: {'PATH': '/usr/bin'},
        aliases: {'ll': 'ls -la'},
        fontFamily: 'JetBrains Mono',
        fontSize: 16.0,
        colorTheme: 'dark',
        isDefault: true,
        inheritCurrentState: true,
      )),
      expect: () => [
        isA<ShellProfileLoaded>()
            .having(
              (s) => s.profiles.first.name,
              'name',
              'Custom Profile',
            )
            .having(
              (s) => s.profiles.first.inheritCurrentState,
              'inheritCurrentState',
              true,
            ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'deletes profile successfully',
      build: () => ShellProfileBloc(database),
      seed: () {
        // First add a profile
        database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'To Delete'),
            );
        return const ShellProfileInitial();
      },
      act: (bloc) async {
        // Load to get the profile
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(DeleteShellProfile(state.profiles.first));
      },
      skip: 2, // Skip LoadShellProfiles states
      expect: () => [
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles, 'profiles', isEmpty),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates profile name',
      build: () => ShellProfileBloc(database),
      act: (bloc) async {
        bloc.add(const AddShellProfile(name: 'Original Name'));
        await Future.delayed(const Duration(milliseconds: 100));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          name: 'Updated Name',
        ));
      },
      skip: 1, // Skip AddShellProfile state
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.name,
          'name',
          'Updated Name',
        ),
      ],
    );
  });
}
