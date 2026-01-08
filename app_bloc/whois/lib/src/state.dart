part of 'bloc.dart';

/// Base class for all Whois states.
sealed class WhoisState extends Equatable {
  const WhoisState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any lookup is performed.
final class WhoisInitial extends WhoisState {
  const WhoisInitial();
}

/// State while a Whois lookup is in progress.
final class WhoisLoading extends WhoisState {
  const WhoisLoading();
}

/// State when a Whois lookup completed successfully.
final class WhoisLoaded extends WhoisState {
  /// The domain/IP that was queried.
  final String domain;

  /// The Whois lookup results (one per server in the chain).
  final List<String> data;

  const WhoisLoaded(this.domain, this.data);

  @override
  List<Object?> get props => [domain, data];
}

/// State when a Whois lookup failed.
final class WhoisFailure extends WhoisState {
  /// The error message.
  final String error;

  const WhoisFailure(this.error);

  @override
  List<Object?> get props => [error];
}
