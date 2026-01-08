part of 'bloc.dart';

/// Base class for all Whois events.
sealed class WhoisEvent {
  const WhoisEvent();
}

/// Event to reset the Whois state to initial.
final class WhoisReset extends WhoisEvent {
  const WhoisReset();
}

/// Event to perform a Whois lookup for a domain or IP address.
final class WhoisLookup extends WhoisEvent {
  /// The domain name or IP address to lookup.
  final String domain;

  const WhoisLookup(this.domain);
}
