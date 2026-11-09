import 'package:app_database/app_database.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.forTesting());
  tearDown(() => database.close());

  blocTest<ShellProfileBloc, ShellProfileState>(
    'EnsureDefaultProfile publishes the created default before startup is ready',
    build: () => ShellProfileBloc(database),
    act: (bloc) => bloc.add(const EnsureDefaultProfile()),
    expect: () => [
      const ShellProfileLoading(),
      isA<ShellProfileLoaded>()
          .having((state) => state.profiles, 'profiles', hasLength(1))
          .having((state) => state.defaultProfile?.name, 'default', 'Default'),
    ],
    verify: (_) async {
      expect(await database.select(database.shellProfiles).get(), hasLength(1));
    },
  );

  blocTest<ShellProfileBloc, ShellProfileState>(
    'EnsureDefaultProfile loads existing profiles without inserting another',
    setUp: () => database.into(database.shellProfiles).insert(
          ShellProfilesCompanion.insert(name: 'Existing profile'),
        ),
    build: () => ShellProfileBloc(database),
    act: (bloc) => bloc.add(const EnsureDefaultProfile()),
    expect: () => [
      const ShellProfileLoading(),
      isA<ShellProfileLoaded>()
          .having((state) => state.profiles, 'profiles', hasLength(1))
          .having((state) => state.profiles.single.name, 'name',
              'Existing profile'),
    ],
  );

  blocTest<ShellProfileBloc, ShellProfileState>(
    'EnsureDefaultProfile surfaces storage failure',
    build: () => ShellProfileBloc(database),
    setUp: () => database.customStatement('DROP TABLE shell_profiles'),
    act: (bloc) => bloc.add(const EnsureDefaultProfile()),
    expect: () => [const ShellProfileLoading(), isA<ShellProfileError>()],
  );
}
