part of 'bloc.dart';

@immutable
sealed class VncHostEvent extends Equatable {
  const VncHostEvent();

  @override
  List<Object?> get props => [];
}

final class VncHostLoad extends VncHostEvent {
  const VncHostLoad();
}

final class VncHostAdd extends VncHostEvent {
  const VncHostAdd({
    required this.name,
    required this.host,
    this.port = 5900,
    this.authType = VncHostAuthType.auto,
    this.username,
    this.password,
    this.sshHostId,
    this.viewOnly = false,
  });

  final String name;
  final String host;
  final int port;
  final VncHostAuthType authType;
  final String? username;
  final String? password;
  final int? sshHostId;
  final bool viewOnly;

  @override
  List<Object?> get props => [
    name,
    host,
    port,
    authType,
    username,
    password,
    sshHostId,
    viewOnly,
  ];
}

final class VncHostUpdate extends VncHostEvent {
  const VncHostUpdate({
    required this.id,
    required this.name,
    required this.host,
    this.port = 5900,
    this.authType = VncHostAuthType.auto,
    this.username,
    this.password,
    this.clearPassword = false,
    this.sshHostId,
    this.viewOnly = false,
  });

  final int id;
  final String name;
  final String host;
  final int port;
  final VncHostAuthType authType;
  final String? username;
  final String? password;
  final bool clearPassword;
  final int? sshHostId;
  final bool viewOnly;

  @override
  List<Object?> get props => [
    id,
    name,
    host,
    port,
    authType,
    username,
    password,
    clearPassword,
    sshHostId,
    viewOnly,
  ];
}

final class VncHostDelete extends VncHostEvent {
  const VncHostDelete(this.host);

  final VncHost host;

  @override
  List<Object?> get props => [host];
}

final class VncHostMarkConnected extends VncHostEvent {
  const VncHostMarkConnected(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

final class VncHostDiscoverLan extends VncHostEvent {
  const VncHostDiscoverLan({this.timeout = const Duration(seconds: 5)});

  final Duration timeout;

  @override
  List<Object?> get props => [timeout];
}
