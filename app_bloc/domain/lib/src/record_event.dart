part of 'record_bloc.dart';

sealed class RecordEvent {
  const RecordEvent();
}

/// Load all DNS records for a zone.
final class RecordSync extends RecordEvent {
  final DnsZoneTableData zone;

  const RecordSync(this.zone);
}

/// Add a new DNS record.
final class RecordAdd extends RecordEvent {
  final DnsZoneTableData zone;
  final DnsRecordModel record;

  const RecordAdd({
    required this.zone,
    required this.record,
  });
}

/// Update an existing DNS record.
final class RecordUpdate extends RecordEvent {
  final DnsZoneTableData zone;
  final DnsRecordModel record;

  const RecordUpdate({
    required this.zone,
    required this.record,
  });
}

/// Remove a DNS record.
final class RecordRemove extends RecordEvent {
  final DnsZoneTableData zone;
  final DnsRecordModel record;

  const RecordRemove({
    required this.zone,
    required this.record,
  });
}
