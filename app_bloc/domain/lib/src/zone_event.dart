part of 'zone_bloc.dart';

sealed class ZoneEvent {
  const ZoneEvent();
}

/// Load all DNS zones from the database.
final class ZoneSync extends ZoneEvent {
  const ZoneSync();
}

/// Add a new DNS zone linked to a service account.
final class ZoneAdd extends ZoneEvent {
  final DnsProvider provider;
  final String zoneId;
  final String zoneName;
  final int serviceAccountId;
  final String? comment;

  const ZoneAdd({
    required this.provider,
    required this.zoneId,
    required this.zoneName,
    required this.serviceAccountId,
    this.comment,
  });
}

/// Update an existing DNS zone.
final class ZoneUpdate extends ZoneEvent {
  final DnsZoneTableData zone;
  final String? zoneName;
  final int? serviceAccountId;
  final String? comment;

  const ZoneUpdate({
    required this.zone,
    this.zoneName,
    this.serviceAccountId,
    this.comment,
  });
}

/// Remove a DNS zone.
final class ZoneRemove extends ZoneEvent {
  final DnsZoneTableData zone;

  const ZoneRemove(this.zone);
}
