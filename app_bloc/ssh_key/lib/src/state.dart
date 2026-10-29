part of 'bloc.dart';

sealed class SshKeyState extends Equatable {
  const SshKeyState();

  @override
  List<Object?> get props => [];
}

final class SshKeyInitial extends SshKeyState {
  const SshKeyInitial();
}

final class SshKeyLoaded extends SshKeyState {
  final List<SshKey> sshKeys;

  const SshKeyLoaded(this.sshKeys);

  @override
  List<Object?> get props => [sshKeys];
}

final class SshKeyError extends SshKeyState {
  final Object error;

  const SshKeyError(this.error);

  @override
  List<Object?> get props => [error];
}
