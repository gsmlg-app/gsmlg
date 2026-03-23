part of 'bloc.dart';

@immutable
sealed class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all service accounts from database
final class AccountsLoad extends AccountsEvent {
  const AccountsLoad();
}

/// Add a new service account
final class AccountsAdd extends AccountsEvent {
  const AccountsAdd({
    required this.provider,
    required this.name,
    required this.apiKey,
    this.description = '',
  });

  final ServiceProvider provider;
  final String name;
  final String description;
  final String apiKey;

  @override
  List<Object?> get props => [provider, name, description, apiKey];
}

/// Update an existing service account
final class AccountsUpdate extends AccountsEvent {
  const AccountsUpdate({
    required this.id,
    required this.name,
    this.description = '',
  });

  final int id;
  final String name;
  final String description;

  @override
  List<Object?> get props => [id, name, description];
}

/// Update an existing service account API key
final class AccountsUpdateApiKey extends AccountsEvent {
  const AccountsUpdateApiKey({
    required this.id,
    required this.apiKey,
  });

  final int id;
  final String apiKey;

  @override
  List<Object?> get props => [id, apiKey];
}

/// Delete a service account
final class AccountsDelete extends AccountsEvent {
  const AccountsDelete({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}
