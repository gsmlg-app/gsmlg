part of 'bloc.dart';

sealed class WhoisHistoryEvent {
  const WhoisHistoryEvent();
}

/// Load all WHOIS history records from the database.
final class WhoisHistorySync extends WhoisHistoryEvent {
  const WhoisHistorySync();
}

/// Remove a single WHOIS history record.
final class WhoisHistoryRemoveOne extends WhoisHistoryEvent {
  final WhoisHistoryTableData whoisHistory;

  const WhoisHistoryRemoveOne(this.whoisHistory);
}

/// Remove all WHOIS history records.
final class WhoisHistoryRemoveAll extends WhoisHistoryEvent {
  const WhoisHistoryRemoveAll();
}
