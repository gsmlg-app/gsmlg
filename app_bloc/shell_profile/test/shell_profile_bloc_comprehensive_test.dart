import 'dart:convert';

import 'package:app_database/app_database.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
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

  group('Event Equatable Tests', () {
    test('LoadShellProfiles instances are equal', () {
      expect(
        const LoadShellProfiles(),
        equals(const LoadShellProfiles()),
      );
    });

    test('AddShellProfile instances with same values are equal', () {
      const event1 = AddShellProfile(
        name: 'Test',
        shellType: ShellType.bash,
        environmentVariables: {'PATH': '/usr/bin'},
        aliases: {'ll': 'ls -la'},
        fontFamily: 'JetBrains Mono',
        fontSize: 16.0,
        colorTheme: 'dark',
        isDefault: true,
      );
      const event2 = AddShellProfile(
        name: 'Test',
        shellType: ShellType.bash,
        environmentVariables: {'PATH': '/usr/bin'},
        aliases: {'ll': 'ls -la'},
        fontFamily: 'JetBrains Mono',
        fontSize: 16.0,
        colorTheme: 'dark',
        isDefault: true,
      );
      expect(event1, equals(event2));
    });

    test('AddShellProfile instances with different names are not equal', () {
      const event1 = AddShellProfile(name: 'Profile1');
      const event2 = AddShellProfile(name: 'Profile2');
      expect(event1, isNot(equals(event2)));
    });

    test('UpdateShellProfile instances with same values are equal', () {
      const event1 = UpdateShellProfile(id: 1, name: 'Updated');
      const event2 = UpdateShellProfile(id: 1, name: 'Updated');
      expect(event1, equals(event2));
    });

    test('UpdateShellProfile instances with different ids are not equal', () {
      const event1 = UpdateShellProfile(id: 1, name: 'Updated');
      const event2 = UpdateShellProfile(id: 2, name: 'Updated');
      expect(event1, isNot(equals(event2)));
    });

    test('DeleteShellProfile instances with same profile are equal', () {
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
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final event1 = DeleteShellProfile(profile);
      final event2 = DeleteShellProfile(profile);
      expect(event1, equals(event2));
    });

    test('SetDefaultProfile instances with same profile are equal', () {
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
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final event1 = SetDefaultProfile(profile);
      final event2 = SetDefaultProfile(profile);
      expect(event1, equals(event2));
    });
  });

  group('State Equatable Tests', () {
    test('ShellProfileLoaded instances with same profiles are equal', () {
      final profile1 = ShellProfile(
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
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final profile2 = ShellProfile(
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
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(
        ShellProfileLoaded([profile1]),
        equals(ShellProfileLoaded([profile2])),
      );
    });

    test('ShellProfileLoaded instances with different profiles are not equal',
        () {
      final profile1 = ShellProfile(
        id: 1,
        name: 'Test1',
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
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final profile2 = ShellProfile(
        id: 2,
        name: 'Test2',
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
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(
        ShellProfileLoaded([profile1]),
        isNot(equals(ShellProfileLoaded([profile2]))),
      );
    });

    test('ShellProfileLoaded.defaultProfile returns default profile', () {
      final profile1 = ShellProfile(
        id: 1,
        name: 'Regular',
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
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final profile2 = ShellProfile(
        id: 2,
        name: 'Default',
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
        isDefault: true,
        inheritCurrentState: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final state = ShellProfileLoaded([profile1, profile2]);
      expect(state.defaultProfile, equals(profile2));
    });

    test('ShellProfileError instances with same error are equal', () {
      final error = Exception('Test error');
      expect(
        ShellProfileError(error),
        equals(ShellProfileError(error)),
      );
    });
  });

  group('BLoC Initial State', () {
    test('initial state is ShellProfileInitial', () {
      final bloc = ShellProfileBloc(database);
      expect(bloc.state, isA<ShellProfileInitial>());
      bloc.close();
    });
  });

  group('LoadShellProfiles', () {
    blocTest<ShellProfileBloc, ShellProfileState>(
      'emits [Loading, Loaded] with empty list when no profiles exist',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const LoadShellProfiles()),
      expect: () => [
        const ShellProfileLoading(),
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles, 'profiles', isEmpty),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'emits [Loading, Loaded] with profiles when profiles exist',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 1'),
            );
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 2'),
            );
      },
      act: (bloc) => bloc.add(const LoadShellProfiles()),
      expect: () => [
        const ShellProfileLoading(),
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles.length, 'profiles length', 2),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'can be called multiple times',
      build: () => ShellProfileBloc(database),
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const LoadShellProfiles());
      },
      expect: () => [
        const ShellProfileLoading(),
        isA<ShellProfileLoaded>(),
        const ShellProfileLoading(),
        isA<ShellProfileLoaded>(),
      ],
    );
  });

  group('AddShellProfile', () {
    blocTest<ShellProfileBloc, ShellProfileState>(
      'adds profile with default values',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(name: 'My Profile')),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final profile = s.profiles.first;
            return profile.name == 'My Profile' &&
                profile.shellType == ShellType.sh.value &&
                profile.fontFamily == 'Source Code Pro' &&
                profile.fontSize == 14.0 &&
                profile.colorTheme == 'default' &&
                profile.isDefault == false;
          },
          'profile has correct default values',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'adds profile with custom shell type',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Bash Profile',
        shellType: ShellType.bash,
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.shellType,
          'shellType',
          ShellType.bash.value,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'adds profile with environment variables',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Profile with ENV',
        environmentVariables: {
          'PATH': '/usr/local/bin:/usr/bin',
          'EDITOR': 'vim',
        },
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final envVars = jsonDecode(s.profiles.first.environmentVariables)
                as Map<String, dynamic>;
            return envVars['PATH'] == '/usr/local/bin:/usr/bin' &&
                envVars['EDITOR'] == 'vim';
          },
          'environment variables',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'adds profile with aliases',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Profile with Aliases',
        aliases: {
          'll': 'ls -la',
          'gs': 'git status',
        },
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final aliases =
                jsonDecode(s.profiles.first.aliases) as Map<String, dynamic>;
            return aliases['ll'] == 'ls -la' && aliases['gs'] == 'git status';
          },
          'aliases',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'adds profile with custom font settings',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Custom Font Profile',
        fontFamily: 'JetBrains Mono',
        fontSize: 18.0,
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) =>
              s.profiles.first.fontFamily == 'JetBrains Mono' &&
              s.profiles.first.fontSize == 18.0,
          'font settings',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'adds profile with custom color theme',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Dark Theme Profile',
        colorTheme: 'dracula',
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.colorTheme,
          'colorTheme',
          'dracula',
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'sets profile as default when isDefault is true',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Default Profile',
        isDefault: true,
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.isDefault,
          'isDefault',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'clears existing default when adding new default profile',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Old Default',
                isDefault: const Value(true),
              ),
            );
      },
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'New Default',
        isDefault: true,
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final oldDefault = s.profiles.firstWhere(
              (p) => p.name == 'Old Default',
            );
            final newDefault = s.profiles.firstWhere(
              (p) => p.name == 'New Default',
            );
            return !oldDefault.isDefault && newDefault.isDefault;
          },
          'only new profile is default',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'adds multiple profiles successfully',
      build: () => ShellProfileBloc(database),
      act: (bloc) async {
        bloc.add(const AddShellProfile(name: 'Profile 1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AddShellProfile(name: 'Profile 2'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AddShellProfile(name: 'Profile 3'));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles.length, 'profiles length', 3),
      ],
    );
  });

  group('UpdateShellProfile', () {
    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates profile name',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Original Name'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          name: 'Updated Name',
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.name,
          'name',
          'Updated Name',
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates shell type',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Test',
                shellType: Value(ShellType.sh.value),
              ),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          shellType: ShellType.zsh,
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.shellType,
          'shellType',
          ShellType.zsh.value,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates environment variables',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          environmentVariables: {'NEW_VAR': 'value'},
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final envVars = jsonDecode(s.profiles.first.environmentVariables)
                as Map<String, dynamic>;
            return envVars['NEW_VAR'] == 'value';
          },
          'environment variables updated',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates aliases',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          aliases: {'new_alias': 'command'},
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final aliases =
                jsonDecode(s.profiles.first.aliases) as Map<String, dynamic>;
            return aliases['new_alias'] == 'command';
          },
          'aliases updated',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates font family',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          fontFamily: 'Fira Code',
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.fontFamily,
          'fontFamily',
          'Fira Code',
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates font size',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          fontSize: 20.0,
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.fontSize,
          'fontSize',
          20.0,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates color theme',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          colorTheme: 'solarized',
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.colorTheme,
          'colorTheme',
          'solarized',
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates multiple fields at once',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          name: 'Multi Update',
          shellType: ShellType.fish,
          fontFamily: 'Hack',
          fontSize: 16.0,
          colorTheme: 'nord',
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final profile = s.profiles.first;
            return profile.name == 'Multi Update' &&
                profile.shellType == ShellType.fish.value &&
                profile.fontFamily == 'Hack' &&
                profile.fontSize == 16.0 &&
                profile.colorTheme == 'nord';
          },
          'multiple fields updated',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'sets profile as default when isDefault is true',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(UpdateShellProfile(
          id: state.profiles.first.id,
          isDefault: true,
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.isDefault,
          'isDefault',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'clears existing default when updating another profile to default',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Old Default',
                isDefault: const Value(true),
              ),
            );
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'New Default'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        final profileToUpdate = state.profiles.firstWhere(
          (p) => p.name == 'New Default',
        );
        bloc.add(UpdateShellProfile(
          id: profileToUpdate.id,
          isDefault: true,
        ));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final oldDefault = s.profiles.firstWhere(
              (p) => p.name == 'Old Default',
            );
            final newDefault = s.profiles.firstWhere(
              (p) => p.name == 'New Default',
            );
            return !oldDefault.isDefault && newDefault.isDefault;
          },
          'only updated profile is default',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'updates non-existent profile gracefully',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const UpdateShellProfile(
        id: 999,
        name: 'Non-existent',
      )),
      expect: () => [
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles, 'profiles', isEmpty),
      ],
    );
  });

  group('DeleteShellProfile', () {
    blocTest<ShellProfileBloc, ShellProfileState>(
      'deletes profile successfully',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'To Delete'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(DeleteShellProfile(state.profiles.first));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles, 'profiles', isEmpty),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'deletes correct profile when multiple exist',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Keep 1'),
            );
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Delete Me'),
            );
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Keep 2'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        final profileToDelete = state.profiles.firstWhere(
          (p) => p.name == 'Delete Me',
        );
        bloc.add(DeleteShellProfile(profileToDelete));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final names = s.profiles.map((p) => p.name).toList();
            return s.profiles.length == 2 &&
                names.contains('Keep 1') &&
                names.contains('Keep 2') &&
                !names.contains('Delete Me');
          },
          'correct profile deleted',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'emits error when trying to delete non-existent profile',
      build: () => ShellProfileBloc(database),
      act: (bloc) {
        final fakeProfile = ShellProfile(
          id: 999,
          name: 'Non-existent',
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
        bloc.add(DeleteShellProfile(fakeProfile));
      },
      expect: () => [
        isA<ShellProfileError>().having(
          (s) => s.error.toString(),
          'error',
          contains('Failed to delete shell profile'),
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'deletes default profile successfully',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Default Profile',
                isDefault: const Value(true),
              ),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(DeleteShellProfile(state.profiles.first));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles, 'profiles', isEmpty),
      ],
    );
  });

  group('SetDefaultProfile', () {
    blocTest<ShellProfileBloc, ShellProfileState>(
      'sets profile as default',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test Profile'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        bloc.add(SetDefaultProfile(state.profiles.first));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.isDefault,
          'isDefault',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'clears previous default when setting new default',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Old Default',
                isDefault: const Value(true),
              ),
            );
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'New Default'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        final newDefaultProfile = state.profiles.firstWhere(
          (p) => p.name == 'New Default',
        );
        bloc.add(SetDefaultProfile(newDefaultProfile));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final defaults = s.profiles.where((p) => p.isDefault).toList();
            return defaults.length == 1 && defaults.first.name == 'New Default';
          },
          'only one default profile',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'handles setting default among multiple profiles',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 1'),
            );
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 2'),
            );
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 3'),
            );
      },
      act: (bloc) async {
        bloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as ShellProfileLoaded;
        final middleProfile = state.profiles[1];
        bloc.add(SetDefaultProfile(middleProfile));
      },
      skip: 2,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final defaults = s.profiles.where((p) => p.isDefault).toList();
            return defaults.length == 1 && defaults.first.name == 'Profile 2';
          },
          'middle profile is default',
          true,
        ),
      ],
    );
  });

  group('Edge Cases and Complex Scenarios', () {
    blocTest<ShellProfileBloc, ShellProfileState>(
      'handles rapid CRUD operations',
      build: () => ShellProfileBloc(database),
      act: (bloc) async {
        bloc.add(const AddShellProfile(name: 'Profile 1'));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(const AddShellProfile(name: 'Profile 2'));
        await Future.delayed(const Duration(milliseconds: 20));
        bloc.add(const LoadShellProfiles());
      },
      skip: 2,
      expect: () => [
        const ShellProfileLoading(),
        isA<ShellProfileLoaded>()
            .having((s) => s.profiles.length, 'profiles length', 2),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'handles adding default profile to empty database',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'First Profile',
        isDefault: true,
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.profiles.first.isDefault && s.profiles.length == 1,
          'first profile is default',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'defaultProfile getter returns null when no default exists',
      build: () => ShellProfileBloc(database),
      setUp: () async {
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 1'),
            );
        await database.into(database.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 2'),
            );
      },
      act: (bloc) => bloc.add(const LoadShellProfiles()),
      skip: 1,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) => s.defaultProfile,
          'defaultProfile',
          isNull,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'handles profile with complex environment variables',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Complex ENV',
        environmentVariables: {
          'PATH': '/usr/local/bin:/usr/bin:/bin',
          'LS_COLORS':
              'di=01;34:ln=01;36:so=01;35:pi=40;33:ex=01;32:bd=40;33;01',
          'PS1':
              r'\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$',
          'EMPTY': '',
        },
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final envVars = jsonDecode(s.profiles.first.environmentVariables)
                as Map<String, dynamic>;
            return envVars.length == 4 &&
                envVars['PATH'] == '/usr/local/bin:/usr/bin:/bin' &&
                envVars['EMPTY'] == '';
          },
          'complex environment variables stored',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'handles profile with special characters in aliases',
      build: () => ShellProfileBloc(database),
      act: (bloc) => bloc.add(const AddShellProfile(
        name: 'Special Aliases',
        aliases: {
          'grep': 'grep --color=auto',
          'la': 'ls -A',
          'l': 'ls -CF',
          '..': 'cd ..',
          '...': 'cd ../..',
        },
      )),
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            final aliases =
                jsonDecode(s.profiles.first.aliases) as Map<String, dynamic>;
            return aliases.length == 5 &&
                aliases['grep'] == 'grep --color=auto' &&
                aliases['..'] == 'cd ..';
          },
          'special character aliases stored',
          true,
        ),
      ],
    );

    blocTest<ShellProfileBloc, ShellProfileState>(
      'handles all shell types correctly',
      build: () => ShellProfileBloc(database),
      act: (bloc) async {
        bloc.add(const AddShellProfile(name: 'Sh', shellType: ShellType.sh));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(
          const AddShellProfile(name: 'Bash', shellType: ShellType.bash),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AddShellProfile(name: 'Zsh', shellType: ShellType.zsh));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(
          const AddShellProfile(name: 'Fish', shellType: ShellType.fish),
        );
      },
      skip: 3,
      expect: () => [
        isA<ShellProfileLoaded>().having(
          (s) {
            return s.profiles.length == 4 &&
                s.profiles.any((p) =>
                    p.name == 'Sh' && p.shellType == ShellType.sh.value) &&
                s.profiles.any((p) =>
                    p.name == 'Bash' && p.shellType == ShellType.bash.value) &&
                s.profiles.any((p) =>
                    p.name == 'Zsh' && p.shellType == ShellType.zsh.value) &&
                s.profiles.any((p) =>
                    p.name == 'Fish' && p.shellType == ShellType.fish.value);
          },
          'all shell types stored correctly',
          true,
        ),
      ],
    );

    test('verifies timestamps are properly maintained', () async {
      await database.into(database.shellProfiles).insert(
            ShellProfilesCompanion.insert(name: 'Test'),
          );

      final profile = await database.select(database.shellProfiles).getSingle();
      final originalCreatedAt = profile.createdAt;

      await Future.delayed(const Duration(milliseconds: 100));

      await (database.update(database.shellProfiles)
            ..where((t) => t.id.equals(profile.id)))
          .write(ShellProfilesCompanion(
        name: const Value('Updated'),
        updatedAt: Value(DateTime.now()),
      ));

      final updated = await database.select(database.shellProfiles).getSingle();

      expect(updated.createdAt, equals(originalCreatedAt));
      expect(updated.updatedAt, isNotNull);
      if (originalCreatedAt != null && updated.updatedAt != null) {
        expect(
          updated.updatedAt!.isAfter(originalCreatedAt),
          true,
          reason: 'updatedAt should be after createdAt',
        );
      }
    });
  });
}
