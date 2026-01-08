part of 'bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

@immutable
final class AuthSyncState extends AuthEvent {
  const AuthSyncState();
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

@immutable
class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

final class AuthSignedUp extends AuthEvent {
  final String username;

  const AuthSignedUp(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedIn extends AuthEvent {
  final String username;

  const AuthSignedIn(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedInNewPasswordRequired extends AuthEvent {
  final String username;

  const AuthSignedInNewPasswordRequired(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedInMFA extends AuthEvent {
  final String username;

  const AuthSignedInMFA(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedInConfirmSignUp extends AuthEvent {
  final String username;

  const AuthSignedInConfirmSignUp(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedInForgotPassword extends AuthEvent {
  final String username;

  const AuthSignedInForgotPassword(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedInResetPassword extends AuthEvent {
  final String username;

  const AuthSignedInResetPassword(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedInChangePassword extends AuthEvent {
  final String username;

  const AuthSignedInChangePassword(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedInChangeEmail extends AuthEvent {
  final String username;

  const AuthSignedInChangeEmail(this.username);

  @override
  List<Object?> get props => [username];
}

final class AuthSignedInVerifyContact extends AuthEvent {
  final String username;

  const AuthSignedInVerifyContact(this.username);

  @override
  List<Object?> get props => [username];
}
