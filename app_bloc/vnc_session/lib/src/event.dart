part of 'bloc.dart';

/// Events accepted by [VncSessionBloc].
@immutable
sealed class VncSessionEvent extends Equatable {
  const VncSessionEvent();

  @override
  List<Object?> get props => const [];
}

final class VncSessionConnect extends VncSessionEvent {
  const VncSessionConnect(this.config);

  final VncConnectionConfig config;

  @override
  List<Object?> get props => [config];
}

final class VncSessionSubmitCredentials extends VncSessionEvent {
  const VncSessionSubmitCredentials(this.credentials);

  final VncCredentials credentials;

  @override
  List<Object?> get props => [credentials];
}

final class VncSessionCancelAuth extends VncSessionEvent {
  const VncSessionCancelAuth();
}

final class VncSessionReconnect extends VncSessionEvent {
  const VncSessionReconnect({this.overrideCredentials});

  final VncCredentials? overrideCredentials;

  @override
  List<Object?> get props => [overrideCredentials];
}

final class VncSessionDisconnect extends VncSessionEvent {
  const VncSessionDisconnect();
}

final class VncSessionSendPointer extends VncSessionEvent {
  const VncSessionSendPointer({
    required this.x,
    required this.y,
    required this.buttonMask,
  });

  final int x;
  final int y;
  final int buttonMask;

  @override
  List<Object?> get props => [x, y, buttonMask];
}

final class VncSessionSendKey extends VncSessionEvent {
  const VncSessionSendKey({required this.keysym, required this.down});

  final int keysym;
  final bool down;

  @override
  List<Object?> get props => [keysym, down];
}

final class VncSessionSendClipboard extends VncSessionEvent {
  const VncSessionSendClipboard(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class VncSessionToggleViewOnly extends VncSessionEvent {
  const VncSessionToggleViewOnly();
}

final class VncSessionRequestRefresh extends VncSessionEvent {
  const VncSessionRequestRefresh();
}

final class _VncClientEventReceived extends VncSessionEvent {
  const _VncClientEventReceived(this.generation, this.clientEvent);

  final int generation;
  final VncClientEvent clientEvent;

  @override
  List<Object?> get props => [generation, clientEvent];
}
