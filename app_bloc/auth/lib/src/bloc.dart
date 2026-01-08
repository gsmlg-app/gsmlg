import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'event.dart';
part 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AuthSyncState>(_onAuthSyncState);
    on<AuthSignedIn>(_onAuthSignIn);
    on<AuthSignOut>(_onAuthSignOut);
  }

  Future<void> _onAuthSyncState(
    AuthSyncState event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    await Future.delayed(const Duration(seconds: 1));

    if (state is AuthSuccess) {
      // User is already authenticated
      final currentState = state as AuthSuccess;
      emit(AuthSuccess(currentState.user, currentState.isNewUser));
    } else {
      emit(const AuthSignedOut());
    }
  }

  Future<void> _onAuthSignIn(
    AuthSignedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Simulate a successful sign-in
    final user = {
      'username': event.username,
      'email': '',
    };
    emit(AuthSuccess(user, false));
  }

  Future<void> _onAuthSignOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSignedOut());
  }
}
