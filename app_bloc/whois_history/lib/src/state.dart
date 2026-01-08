part of 'bloc.dart';

sealed class WhoisHistoryState extends Equatable {
  const WhoisHistoryState();

  @override
  List<Object?> get props => [];
}

final class WhoisHistoryInitial extends WhoisHistoryState {
  const WhoisHistoryInitial();
}

final class WhoisHistoryLoading extends WhoisHistoryState {
  const WhoisHistoryLoading();
}

final class WhoisHistoryLoaded extends WhoisHistoryState {
  final List<WhoisHistoryTableData> data;

  const WhoisHistoryLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

final class WhoisHistoryFailure extends WhoisHistoryState {
  final String error;

  const WhoisHistoryFailure(this.error);

  @override
  List<Object?> get props => [error];
}
