import 'log_query_builder.dart';
import 'models/log_record_item.dart';

/// Query and maintenance API of the log store used by the Log Center.
///
/// Implemented by [AppDuckDb] (direct, in-isolate) and `LogStoreClient`
/// (through the `logstore` isolate).
abstract interface class LogStore {
  /// Rows of a log table or `v_all_logs`, newest first.
  Future<List<LogRecordItem>> queryLogs({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
    int limit = 50,
    int offset = 0,
  });

  /// Number of rows [queryLogs] pages over.
  Future<int> countLogs({
    required String tableOrView,
    LogFilter filter = const LogFilter(),
  });

  /// Distinct API exchange categories, sorted.
  Future<List<String>> listCategories();

  /// One summary row per agent run, latest activity first.
  Future<List<Map<String, dynamic>>> queryAgentRuns({
    LogFilter filter = const LogFilter(),
    int limit = 50,
    int offset = 0,
  });

  /// Number of runs [queryAgentRuns] pages over.
  Future<int> countAgentRuns({LogFilter filter = const LogFilter()});

  /// Deletes rows older than [days] days from [tables].
  Future<void> deleteOlderThan({
    required int days,
    required List<String> tables,
  });

  /// Deletes every row of [table].
  Future<void> clearLogsTable({required String table});

  /// Matching rows of [table] as JSON Lines, oldest first.
  Future<String> exportJsonl({
    required String table,
    LogFilter filter = const LogFilter(),
  });

  /// Result rows of [sql] as a JSON array string.
  Future<String> queryJson(String sql);

  /// Writes every record buffered so far.
  Future<void> flush();
}
