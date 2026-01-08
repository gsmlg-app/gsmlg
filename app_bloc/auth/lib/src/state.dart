part of 'bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  final dynamic user;
  final bool isNewUser;

  const AuthSuccess(this.user, this.isNewUser);

  @override
  List<Object?> get props => [user, isNewUser];
}

final class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}
