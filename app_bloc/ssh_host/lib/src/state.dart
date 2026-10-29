part of 'bloc.dart';

@immutable
sealed class SshHostState extends Equatable {
  const SshHostState();

  @override
  List<Object?> get props => [];
}

final class SshHostInitial extends SshHostState {
  const SshHostInitial();
}

final class SshHostLoaded extends SshHostState {
  final List<SshHost> sshHosts;

  const SshHostLoaded(this.sshHosts);

  @override
  List<Object?> get props => [sshHosts];
}

final class SshHostError extends SshHostState {
  final Object error;

  const SshHostError(this.error);

  @override
  List<Object?> get props => [error];
}
