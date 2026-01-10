part of 'record_bloc.dart';

sealed class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object?> get props => [];
}

final class RecordInitial extends RecordState {
  const RecordInitial();
}

final class RecordLoading extends RecordState {
  final DnsZoneTableData zone;
  final List<DnsRecordModel>? records;

  const RecordLoading(this.zone, {this.records});

  @override
  List<Object?> get props => [zone, records];
}

final class RecordLoaded extends RecordState {
  final DnsZoneTableData zone;
  final List<DnsRecordModel> records;

  const RecordLoaded({
    required this.zone,
    required this.records,
  });

  @override
  List<Object?> get props => [zone, records];
}

final class RecordFailure extends RecordState {
  final DnsZoneTableData zone;
  final String error;

  const RecordFailure({
    required this.zone,
    required this.error,
  });

  @override
  List<Object?> get props => [zone, error];
}
