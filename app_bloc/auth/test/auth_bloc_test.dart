import 'package:auth_bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when AuthSignedIn is added',
      build: () => AuthBloc(),
      act: (bloc) => bloc.add(const AuthSignedIn('testuser')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>()
            .having((s) => s.user['username'], 'username', 'testuser')
            .having((s) => s.isNewUser, 'isNewUser', false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthSignedOutState] when AuthSignOut is added',
      build: () => AuthBloc(),
      act: (bloc) => bloc.add(const AuthSignOut()),
      expect: () => [
        isA<AuthSignedOut>(),
      ],
    );
  });
}
