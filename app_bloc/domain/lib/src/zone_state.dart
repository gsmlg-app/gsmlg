part of 'zone_bloc.dart';

sealed class ZoneState extends Equatable {
  const ZoneState();

  @override
  List<Object?> get props => [];
}

final class ZoneInitial extends ZoneState {
  const ZoneInitial();
}

final class ZoneLoading extends ZoneState {
  const ZoneLoading();
}

final class ZoneLoaded extends ZoneState {
  final List<DnsZoneTableData> zones;

  const ZoneLoaded(this.zones);

  @override
  List<Object?> get props => [zones];
}

final class ZoneFailure extends ZoneState {
  final String error;

  const ZoneFailure(this.error);

  @override
  List<Object?> get props => [error];
}
