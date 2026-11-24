sealed class VncException implements Exception {
  const VncException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' ($cause)' : ''}';
}

final class VncConnectionException extends VncException {
  const VncConnectionException(super.message, [super.cause]);
}

final class VncSshTunnelException extends VncException {
  const VncSshTunnelException(super.message, [super.cause]);
}

final class VncAuthenticationException extends VncException {
  const VncAuthenticationException(super.message, [super.cause]);
}

final class VncUnsupportedSecurityTypeException extends VncException {
  const VncUnsupportedSecurityTypeException(
    this.offeredTypes, {
    String? message,
  }) : super(
         message ??
             'Server offered unsupported VNC security types: $offeredTypes',
       );

  final List<int> offeredTypes;
}

final class VncProtocolException extends VncException {
  const VncProtocolException(super.message, [super.cause]);
}
