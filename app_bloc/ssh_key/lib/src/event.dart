part of 'bloc.dart';

sealed class SshKeyEvent extends Equatable {
  const SshKeyEvent();

  @override
  List<Object?> get props => [];
}

class SshKeyLoad extends SshKeyEvent {
  const SshKeyLoad();
}

class SshKeyAdd extends SshKeyEvent {
  final Completer<void>? completion;
  final String? name;
  final String? content;
  final String? password;
  final String? salt;
  final int? algorithm;

  const SshKeyAdd({
    this.completion,
    this.name,
    this.content,
    this.password,
    this.salt,
    this.algorithm,
  });

  @override
  List<Object?> get props => [name, content, password, salt, algorithm];
}

class SshKeyDelete extends SshKeyEvent {
  final SshKey sshKey;

  const SshKeyDelete(this.sshKey);

  @override
  List<Object?> get props => [sshKey];
}
