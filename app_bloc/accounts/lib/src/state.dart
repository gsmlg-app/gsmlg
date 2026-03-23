part of 'bloc.dart';

@immutable
sealed class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
final class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

/// Loading state
final class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

/// Successfully loaded accounts
final class AccountsLoaded extends AccountsState {
  const AccountsLoaded({
    required this.accounts,
    this.error,
  });

  final List<ServiceAccountTableData> accounts;
  final String? error;

  List<ServiceAccountTableData> byProvider(ServiceProvider provider) =>
      accounts.where((a) => a.provider == provider).toList();

  @override
  List<Object?> get props => [accounts, error];
}

/// Error state
final class AccountsError extends AccountsState {
  const AccountsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
