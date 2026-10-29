part of 'bloc.dart';

@immutable
sealed class SshHostEvent extends Equatable {
  const SshHostEvent();

  @override
  List<Object?> get props => [];
}

class SshHostLoad extends SshHostEvent {
  const SshHostLoad();
}

class SshHostAdd extends SshHostEvent {
  final Completer<void>? completion;
  final String? host;
  final String? hostname;
  final int? port;
  final String? username;
  final String? password;
  final String? salt;
  final int? identityType;
  final int? identityKeyId;

  const SshHostAdd({
    this.completion,
    this.host,
    this.hostname,
    this.port,
    this.username,
    this.password,
    this.salt,
    this.identityType,
    this.identityKeyId,
  });

  @override
  List<Object?> get props => [
        host,
        hostname,
        port,
        username,
        password,
        salt,
        identityType,
        identityKeyId,
      ];
}

class SshHostUpdate extends SshHostEvent {
  final Completer<void>? completion;
  final int id;
  final String? host;
  final String? hostname;
  final int? port;
  final String? username;
  final String? password;
  final String? salt;
  final int? identityType;
  final int? identityKeyId;

  const SshHostUpdate({
    this.completion,
    required this.id,
    this.host,
    this.hostname,
    this.port,
    this.username,
    this.password,
    this.salt,
    this.identityType,
    this.identityKeyId,
  });

  @override
  List<Object?> get props => [
        id,
        host,
        hostname,
        port,
        username,
        password,
        salt,
        identityType,
        identityKeyId,
      ];
}

class SshHostDelete extends SshHostEvent {
  final SshHost sshHost;

  const SshHostDelete(this.sshHost);

  @override
  List<Object?> get props => [sshHost];
}
